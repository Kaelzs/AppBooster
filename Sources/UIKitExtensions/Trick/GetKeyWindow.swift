//
//  GetKeyWindow.swift
//  AppBooster
//
//  Created by Kael on 9/8/25.
//

#if canImport(UIKit)
import UIKit
import SwiftUI

extension UIScene.ActivationState {
    var valueForComparison: Int {
        switch self {
        case .unattached: return 0
        case .background: return 1
        case .foregroundInactive: return 2
        case .foregroundActive: return 3
        @unknown default: return 0
        }
    }
}

public extension UIApplication {
    func getKeyWindow() -> UIWindow? {
        connectedScenes
            .filter { $0.activationState != .unattached }
            .compactMap { $0 as? UIWindowScene }
            .sorted(by: { $0.activationState.valueForComparison >= $1.activationState.valueForComparison })
            .compactMap { $0.windows.filter { $0.isKeyWindow }.first }
            .first
    }
}

#endif
