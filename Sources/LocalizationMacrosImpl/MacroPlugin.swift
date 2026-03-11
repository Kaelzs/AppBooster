//
//  MacroPlugin.swift
//  AppBooster
//
//  Created by Codex on 3/11/26.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct Plugins: CompilerPlugin {
    var providingMacros: [any Macro.Type] = [
        L10nAutoMacro.self,
        L10nPlainMacro.self,
        L10nParameterMacro.self,
    ]
}
