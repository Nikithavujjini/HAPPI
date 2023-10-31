
import Combine
import Foundation

enum AsyncError: Error {
    case finishedWithoutValue
}

extension AnyPublisher {
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var finishedWithoutValue = true
            cancellable = first()
                .sink { result in
                    switch result {
                    case .finished:
                        if finishedWithoutValue {
                            DispatchQueue.main.async {
                                continuation.resume(throwing: AsyncError.finishedWithoutValue)
                            }
                        }
                    case let .failure(error):
                        if let error = error as? CoreError {
                            if error.type != .loginRequired {
                                DispatchQueue.main.async {
                                    continuation.resume(throwing: error)
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                continuation.resume(throwing: CoreError(nserror: error as NSError))
                            }
                        }
                    }
                    
                    cancellable?.cancel()
                } receiveValue: { value in
                    finishedWithoutValue = false
                    DispatchQueue.main.async {
                        continuation.resume(with: .success(value))
                    }
                }
        }
    }
}
