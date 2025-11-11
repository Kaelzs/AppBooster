//
//  OperatingSystemVersion.swift
//  AppBooster
//
//  Created by Kael on 9/22/25.
//

import Foundation

public extension OperatingSystemVersion {
    var stringForHeader: String {
        [majorVersion,
         minorVersion,
         patchVersion,
        ].map { "\($0)" }.joined(separator: ".")
    }
}
