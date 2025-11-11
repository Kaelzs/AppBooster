//
//  MacroPlugin.swift
//  AppBooster
//
//  Created by Kael on 8/22/25.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct Plugins: CompilerPlugin {
    var providingMacros: [any Macro.Type] = [
        URLMacro.self,
        OSAvailableMacro.self,
        CodingKeysMacro.self,
        CustomCodingKeyMacro.self,
        CodingKeyIgnoredMacro.self
    ]
}
