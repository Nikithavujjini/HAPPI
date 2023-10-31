//
//  EnvironmentManager.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 11/10/23.
//


import Foundation

class EnvironmentManager
{
    //MARK: - Variables
    public static let shared:EnvironmentManager = EnvironmentManager()
    public var environments:[EnvironmentModel] = [EnvironmentModel]()
    public var tenantId:String = "110f8020-9556-4bb6-8d36-23104705a228"
    
    
    fileprivate let ENVIRONMENTS_FILE_NAME:String = "Environment_1"
    
    
    fileprivate let PLIST_EXTENSTION:String = "plist"
    fileprivate let KEY_NAME_LOCALIZED:String = "nameLocalizedKey"
    fileprivate let KEY_DOMAIN:String = "domain"
    fileprivate let KEY_AUTHENTICATION_URL:String = "authenticationUrl"
    fileprivate let KEY_SHARED_AUTHENTICATION_URL:String = "sharedAuthenticationUrl"
    fileprivate let KEY_TOKEN_URL:String = "tokenUrl"
    fileprivate let HTTPS_SCHEME:String = "https"
    fileprivate let PUBLIC_KEY:String = "publicKey"
    fileprivate let KEY_CMS_DOMAIN:String = "cmsDomain"
    fileprivate let KEY_CSS_DOMAIN:String = "cssDomain"
    fileprivate let KEY_GCP_DOMAIN:String = "googleDomain"
    fileprivate let GCP_API_KEY:String = "gcpApiKey"
    
    public var currentEnvironment:EnvironmentModel? {
        get {
            let key = UserDefaults.appGroup?.value(forKey: UserDefaultsKeys.environmentName.rawValue) as? String
            return environments.filter{ $0.nameLocalizedKey == key }.last
        } set {
            if let key = newValue?.nameLocalizedKey {
                UserDefaults.appGroup?.setValue(key, forKey: UserDefaultsKeys.environmentName.rawValue)
            }
        }
    }
   
    var userSubscriptionUniqueKey:String? {
        if let userModel = UserHelper.getCurrentUserFromRealm() {
            var key = userModel.subscriptionUserId
            key.append(EnvironmentManager.shared.subscriptionName)
            return key
        }
        return nil
    }
    
    public var cmsUrl:URL? {
        get {
            guard let currentEnvironment = currentEnvironment else { return nil }
            var urlComponents:URLComponents = URLComponents()
            urlComponents.scheme = HTTPS_SCHEME
            urlComponents.host = currentEnvironment.cmsDomain
            var url = urlComponents.url
//            url = url?.appendingPathComponent("subscriptions")
//            url = url?.appendingPathComponent(subscriptionName)
            return url
        }
    }
    
    public var cssUrl:URL? {
        get {
            guard let currentEnvironment = currentEnvironment else { return nil }
            var urlComponents:URLComponents = URLComponents()
            urlComponents.scheme = HTTPS_SCHEME
            urlComponents.host = currentEnvironment.cssDomain
            var url = urlComponents.url
//            url = url?.appendingPathComponent("subscriptions")
//            url = url?.appendingPathComponent(subscriptionName)
            return url
        }
    }
    
    public var gcpApiKey: String {
        get {
            guard let currentEnvironment = currentEnvironment else { return "" }
            var apiKey:String
            apiKey = currentEnvironment.gcpApiKey
            return apiKey
        }
    }
    
    public var gcpUrl:URL? {
        get {
            guard let currentEnvironment = currentEnvironment else { return nil }
            var urlComponents:URLComponents = URLComponents()
            urlComponents.scheme = HTTPS_SCHEME
            urlComponents.host = currentEnvironment.gcpDomain
            var url = urlComponents.url
//            url = url?.appendingPathComponent("subscriptions")
//            url = url?.appendingPathComponent(subscriptionName)
            return url
        }
    }
    
    public var currentEnvironmentUrlWithSubscription:URL? {
        get {
            guard let currentEnvironment = currentEnvironment else { return nil }
            var urlComponents:URLComponents = URLComponents()
            urlComponents.scheme = HTTPS_SCHEME
            urlComponents.host = currentEnvironment.domain
            var url = urlComponents.url
            url = url?.appendingPathComponent("subscriptions")
            url = url?.appendingPathComponent(subscriptionName)
            return url
        }
    }
    
    public var subscriptionName:String {
        set {
            UserDefaults.appGroup?.setValue(newValue, forKey: UserDefaultsKeys.subscriptionName.rawValue)
        }
        get {
            return UserDefaults.appGroup?.string(forKey: UserDefaultsKeys.subscriptionName.rawValue) ?? ""
        }
    }
    
    //MARK: - Initialization
    fileprivate init() {
        getEnvironments()
    }
    

    
    
    //MARK: - Private Functions
    /**
     Get environment information from the `plist` file.
     */
    fileprivate func getEnvironments() {
        guard let path = Bundle.main.path(forResource: ENVIRONMENTS_FILE_NAME, ofType: PLIST_EXTENSTION), let environmentObjectArray = NSArray(contentsOfFile: path) as? [[String: Any]] else { return }
        environments = [EnvironmentModel]()
        for environmentObject in environmentObjectArray {
            if let environmentNameLocalizedKey = environmentObject[KEY_NAME_LOCALIZED] as? String, let environmentDomain = environmentObject[KEY_DOMAIN] as? String, let environmentAuthenticationUrl = environmentObject[KEY_AUTHENTICATION_URL] as? String, let envSharedAuthenticationUrl = environmentObject[KEY_SHARED_AUTHENTICATION_URL] as? String, let environmentTokenUrl = environmentObject[KEY_TOKEN_URL] as? String, let environmentCmsDomain = environmentObject[KEY_CMS_DOMAIN], let environmentCssDomain = environmentObject[KEY_CSS_DOMAIN], let environmentGcpDomain = environmentObject[KEY_GCP_DOMAIN], let gcpApiKey = environmentObject[GCP_API_KEY] {
                environments.append(EnvironmentModel(nameLocalizedKey: environmentNameLocalizedKey, domain: environmentDomain, authenticationUrl: environmentAuthenticationUrl, sharedAuthenticationUrl: envSharedAuthenticationUrl, tokenUrl: environmentTokenUrl, publicKey: environmentObject[PUBLIC_KEY] as? String ?? "" , isHidden: false, cmsDomain: environmentCmsDomain as? String ?? "",cssDomain: environmentCssDomain as? String ?? "", gcpDomain: environmentGcpDomain as? String ?? "", gcpApiKey: gcpApiKey as? String ?? ""))
            }
        }
        
        
        
//
//        if fetchSavedEnvironment() == nil {
//            currentEnvironment = environments.first
//        }
    }
    
    func updateEnvironments() {
        getEnvironments()
    }
    
    func updateCurrentEnvironment(environmentKey:String){
        guard let envrionment = environments.filter({$0.nameLocalizedKey == environmentKey}).first else { return }
        currentEnvironment = envrionment
    }
    
}

