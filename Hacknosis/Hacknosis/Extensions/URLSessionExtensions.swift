

import Foundation
import Combine

extension URLSession {
    
    public func downloadTaskPublisher(for url: URL) -> URLSession.DownloadTaskPublisher {
        self.downloadTaskPublisher(for: URLRequest(url: url))
    }
    
    public func downloadTaskPublisher(for request: URLRequest) -> URLSession.DownloadTaskPublisher {
        DownloadTaskPublisher(request: request, session: self)
    }
    
    public func uploadTaskPublisher(for url: URL, fileUrl:URL?, taskDescription:String) -> URLSession.UploadTaskPublisher {
        self.uploadTaskPublisher(for: URLRequest(url: url), fileUrl: fileUrl, taskDescription: taskDescription)
    }
    
    public func uploadTaskPublisher(for request: URLRequest, fileUrl:URL?, taskDescription:String) -> URLSession.UploadTaskPublisher {
        UploadTaskPublisher(request: request, session: self, fileUrl: fileUrl, taskDescription: taskDescription)
    }
}

//MARK: - Download Task
extension URLSession {
    public struct DownloadTaskPublisher: Publisher {
        
        public typealias Output = (url: URL?, response: URLResponse?, progress: Double?)
        public typealias Failure = URLError
        
        public let request: URLRequest
        public let session: URLSession
        
        public init(request: URLRequest, session: URLSession) {
            self.request = request
            self.session = session
        }
        
        public func receive<S>(subscriber: S) where S: Subscriber,
                                                    DownloadTaskPublisher.Failure == S.Failure,
                                                    DownloadTaskPublisher.Output == S.Input
        {
            if session.configuration.identifier == DOWNLOAD_BACKGROUND_SESSION_IDENTIFIER {
                let subscription = BackgroundDownloadTaskSubscription(subscriber: subscriber, session: self.session, request: self.request)
                subscriber.receive(subscription: subscription)

            } else {
                let subscription = DownloadTaskSubscription(subscriber: subscriber, session: self.session, request: self.request)
                subscriber.receive(subscription: subscription)
            }
        }
    }
    
    final class DownloadTaskSubscriber: Subscriber {
        typealias Input = (url: URL?, response: URLResponse?, progress: Double?)
        typealias Failure = URLError

        var subscription: Subscription?

        func receive(subscription: Subscription) {
            self.subscription = subscription
            self.subscription?.request(.unlimited)
        }

        func receive(_ input: Input) -> Subscribers.Demand {
            return .unlimited
        }

        func receive(completion: Subscribers.Completion<Failure>) {
            self.subscription?.cancel()
            self.subscription = nil
        }
    }
    
    final class BackgroundDownloadTaskSubscription<SubscriberType: Subscriber>:NSObject, Subscription where
        SubscriberType.Input == (url: URL?, response: URLResponse?, progress: Double?),
        SubscriberType.Failure == URLError
    {
        private var subscriber: SubscriberType?
        private weak var session: URLSession!
        private var request: URLRequest!
        private var task: URLSessionDownloadTask!
        private var progressObserver: NSKeyValueObservation?

        init(subscriber: SubscriberType, session: URLSession, request: URLRequest) {
            self.subscriber = subscriber
            self.session = session
            self.request = request
        }

        func request(_ demand: Subscribers.Demand) {
            guard demand > 0 else {
                return
            }
            self.task = self.session.downloadTask(with: request)
            self.task.resume()
        }

        func cancel() {
            progressObserver?.invalidate()
            self.task.cancel()
        }
    }
    
    final class DownloadTaskSubscription<SubscriberType: Subscriber>:NSObject, Subscription where
        SubscriberType.Input == (url: URL?, response: URLResponse?, progress: Double?),
        SubscriberType.Failure == URLError
    {
        private var subscriber: SubscriberType?
        private weak var session: URLSession!
        private var request: URLRequest!
        private var task: URLSessionDownloadTask!
        private var progressObserver: NSKeyValueObservation?

        init(subscriber: SubscriberType, session: URLSession, request: URLRequest) {
            self.subscriber = subscriber
            self.session = session
            self.request = request
        }

        func request(_ demand: Subscribers.Demand) {
            guard demand > 0 else {
                return
            }
            self.task = self.session.downloadTask(with: request) { [weak self] location, response, error in
                if let error = error as? URLError {
                    self?.subscriber?.receive(completion: .failure(error))
                    return
                }
                guard let response = response else {
                    self?.subscriber?.receive(completion: .failure(URLError(.badServerResponse)))
                    return
                }
                guard let location = location else {
                    self?.subscriber?.receive(completion: .failure(URLError(.badURL)))
                    return
                }

                do {
                    let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                    let fileUrl = cacheDir.appendingPathComponent((UUID().uuidString))
                    
                    try FileManager.default.moveItem(atPath: location.path, toPath: fileUrl.path)
                    
                    _ = self?.subscriber?.receive((url: fileUrl, response: response, progress: nil))
                    self?.subscriber?.receive(completion: .finished)
                }
                catch {
                    self?.subscriber?.receive(completion: .failure(URLError(.cannotCreateFile)))
                }
            }
            progressObserver = self.task.progress.observe(\.fractionCompleted) { [weak self] progress, _ in
                _ = self?.subscriber?.receive((url: nil, response: nil, progress: progress.fractionCompleted))
            }
            self.task.resume()
        }

        func cancel() {
            progressObserver?.invalidate()
            self.task.cancel()
        }
    }
}
    
//MARK: - Upload Task
extension URLSession {
    public struct UploadTaskPublisher: Publisher {
        
        public typealias Output = (data: Data?, response: URLResponse?, progress: Double?)
        public typealias Failure = URLError
        
        public let request: URLRequest
        public let session: URLSession
        public let fileUrl: URL?
        private let taskDescription: String
        public init(request: URLRequest, session: URLSession, fileUrl:URL?, taskDescription:String) {
            self.request = request
            self.session = session
            self.fileUrl = fileUrl
            self.taskDescription = taskDescription
        }
        
        public func receive<S>(subscriber: S) where S: Subscriber,
                                                    UploadTaskPublisher.Failure == S.Failure,
                                                    UploadTaskPublisher.Output == S.Input
        {
            let subscription = UploadTaskSubscription(subscriber: subscriber, session: self.session, request: self.request, fileUrl: fileUrl, taskDescription: taskDescription)
            
            subscriber.receive(subscription: subscription)
        }
    }
    
    final class UploadTaskSubscriber: Subscriber {
        typealias Input = (data: Data?, response: URLResponse?, progress: Double?)
        typealias Failure = URLError

        var subscription: Subscription?

        func receive(subscription: Subscription) {
            self.subscription = subscription
            self.subscription?.request(.unlimited)
        }

        func receive(_ input: Input) -> Subscribers.Demand {
            return .unlimited
        }

        func receive(completion: Subscribers.Completion<Failure>) {
            self.subscription?.cancel()
            self.subscription = nil
        }
    }
    
    final class UploadTaskSubscription<SubscriberType: Subscriber>:NSObject, Subscription where
        SubscriberType.Input == (data: Data?, response: URLResponse?, progress: Double?),
        SubscriberType.Failure == URLError
    {
        private var subscriber: SubscriberType?
        private weak var session: URLSession!
        private var request: URLRequest!
        private var task: URLSessionUploadTask!
        private var fileUrl: URL?
        private var taskDescription: String

        private var progressObserver: NSKeyValueObservation?

        init(subscriber: SubscriberType, session: URLSession, request: URLRequest, fileUrl:URL?, taskDescription:String) {
            self.subscriber = subscriber
            self.session = session
            self.request = request
            self.fileUrl = fileUrl
            self.taskDescription = taskDescription
        }

        func request(_ demand: Subscribers.Demand) {
            guard demand > 0, let fileUrl = fileUrl else {
                return
            }
            self.task = self.session.uploadTask(with: request, fromFile: fileUrl)
            self.task.taskDescription = taskDescription
            self.task.resume()
        }

        func cancel() {
            progressObserver?.invalidate()
            self.task.cancel()
        }
    }
}
extension URLSession: CoreURLSession {
    
    /**
    Return a data task publisher based on a urlrequest and optional access token
     - parameters:
        - urlRequest: A URLRequest for the data task.
        - accessToken: An optional access token for authentication. If included then the __Bearer__ header is added to the request.
     */
    func publisher(urlRequest: URLRequest, accessToken: String?) -> AnyPublisher<URLSession.DataTaskPublisher.Output, CoreError> {
        var urlRequest = urlRequest
        if let accessToken = accessToken {
            urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: HTTPHeaderFieldName.authorization.rawValue)
        }
        return dataTaskPublisher(for: urlRequest)
            .mapError({ error in
                if (error as NSError).code == NSURLErrorCancelled {
                    print("Request Cancelled")
                    return CoreError(type: .requestCancelled)
                } else {
                    return CoreError(message: error.localizedDescription)
                }
            })
            .eraseToAnyPublisher()
    }
    
    func downloadPublisher(urlRequest: URLRequest, accessToken: String?) -> AnyPublisher<URLSession.DownloadTaskPublisher.Output, CoreError> {
        var urlRequest = urlRequest
        if let accessToken = accessToken {
            urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: HTTPHeaderFieldName.authorization.rawValue)
        }
        
        return downloadTaskPublisher(for : urlRequest)
            .mapError({ error in
                if (error as NSError).code == NSURLErrorCancelled {
                    return CoreError(type: .requestCancelled)
                } else {
                    return CoreError(message: error.localizedDescription)
                }
            })
            .eraseToAnyPublisher()
    }
    
    func uploadPublisher(urlRequest request: URLRequest, accessToken: String?, fromFile fileUrl: URL?, taskDescription:String) -> AnyPublisher<URLSession.UploadTaskPublisher.Output, CoreError> {
        var urlRequest = request
        if let accessToken = accessToken {
            urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: HTTPHeaderFieldName.authorization.rawValue)
        }
        
        return uploadTaskPublisher(for : urlRequest, fileUrl: fileUrl, taskDescription: taskDescription)
            .mapError({ error in
                if (error as NSError).code == NSURLErrorCancelled {
                    return CoreError(type: .requestCancelled)
                } else {
                    return CoreError(message: error.localizedDescription)
                }
            })
            .eraseToAnyPublisher()
    }
    
    /**
     Cancel all requests for the URLSession
     - parameters:
        - completion: Once all tasks have been cancelled then the completion handler will be called.
     */
    func cancelAllRequests(completion:@escaping() -> Void) {
        getAllTasks(completionHandler:{ tasks in
            tasks.forEach({$0.cancel()})
            completion()
        })
    }

}


// to observe the download progress of a task
//using combine, URLSessionTask is not accessible for observations!
extension URLSession {
    func progress(for req: URLRequest, completion: @escaping ((Double) -> Void)) {
        self.getAllTasks { tasks in
            let task = tasks.first { req.url == $0.originalRequest?.url  }
            switch task {
            case .some(let task) where task.state == .running:
                guard task.countOfBytesExpectedToReceive > 0 else {
                    completion(0.0)
                    return
                }
                completion(Double(task.countOfBytesReceived) / Double(task.countOfBytesExpectedToReceive))
            default:
                completion(100.0)
            }
        }
    }
}

