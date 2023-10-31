//
//  Misc.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 11/10/23.
//

import Foundation

let AppGroup: String = "group.\(AppBundleIdentifier)"
let AppBundleIdentifier: String = Bundle.main.appBundleId

let EMPTY_STRING:String = ""
let OAUTH2_CLIENT_ID:String = "sha"
let rootFolderid: String = "c6a66816-c240-4cec-a177-fb99cb53d64a"

//MARK: - User Default Keys
public enum UserDefaultsKeys: String {
    case subscriptionName = "subscription_name"
    case environmentName = "environment_name"
}

enum AuthTokenType: String {
    case refreshToken = "refreshToken"
    case accessToken = "accessToken"
}

enum HTTPHeaderFieldName:String {
    case acceptContentType = "Accept"
    case contentType = "Content-Type"
    case authorization = "Authorization"
    case csrfToken = "X-CCM-XSRF-TOKEN"
}

let CSRF_COOKIE = "CCM-XSRF-TOKEN"

extension Notification.Name {
    static let accessTokenRefreshed = Notification.Name(rawValue: "accessTokenRefreshed")
    static let returnToLogin = Notification.Name(rawValue: "returnToLogin")
    static let showHome = Notification.Name(rawValue: "showHome")
    static let popFromViewer = Notification.Name(rawValue: "popFromViewer")
    static let uploadSuccess = Notification.Name(rawValue: "uploadSuccess")
    static let userSuccess = Notification.Name(rawValue: "userSuccess")
    static let refreshUI = Notification.Name(rawValue: "refreshUI")
}


public let BACKGROUND_SESSION_IDENTIFIER:String = AppBundleIdentifier + ".backgroundsession"
public let UPLOAD_BACKGROUND_SESSION_IDENTIFIER:String = AppBundleIdentifier + ".uploadbackgroundsession"
public let DOWNLOAD_BACKGROUND_SESSION_IDENTIFIER:String = AppBundleIdentifier + ".downloadbackgroundsession"
//Loader size
let LOADING_SPINNER_SIZE:CGFloat = 40
let LOADING_SPINNER_STROKE_WIDTH:CGFloat = 10

//progress bar size
let PROGRESS_SPINNER_SIZE:CGFloat = 84
let PROGRESS_SPINNER_STROKE_WIDTH:CGFloat = 8
let LOADING_TOP_PADDING:CGFloat = 44
let ACTION_SHEET_TOP_PADDING:CGFloat = 60

public let MULTIPART_TEMP_FOLDER = "multipartformdata"
public let gcpProjectName = "secure-health-app-402315"

let INTER_REGULAR_FONT = "Inter-Regular"
let INTER_MEDIUM_FONT = "Inter-Medium"
let INTER_BOLD_FONT = "Inter-Bold"
let INTER_SEMIBOLD_FONT = "Inter-SemiBold"
let INTER_EXTRABOLD_FONT = "Inter-ExtraBold"
let INTER_BLACK_FONT = "Inter-Black"
let INTER_LIGHT_FONT = "Inter-Light"
let INTER_EXTRALIGHT_FONT = "Inter-ExtraLight"
let INTER_THIN_FONT = "Inter-Thin"

