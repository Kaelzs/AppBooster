//
//  AppInfoUtil.swift
//  AppBooster
//
//  Created by Kael on 9/22/25.
//

import Foundation

public enum AppInfoUtil {
    public static func isTestFlight() -> Bool {
        return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }

    public static func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    public static func appBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""
    }

    public static func versionBuild() -> String {
        let version = appVersion(), build = appBuild()
        return version == build ? "v\(version)" : "v\(version)(\(build))"
    }

    public static func language() -> String {
        let object = UserDefaults.standard.object(forKey: "AppleLanguages")
        if let string = object as? String {
            return string
        } else if let array = object as? [String],
                  let firstLanguage = array.first {
            return firstLanguage
        } else {
            return "None"
        }
    }
}
