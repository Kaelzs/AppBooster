//
//  MacroPlugin.swift
//  AppBooster
//
//  Created by Kael on 9/1/25.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct Plugins: CompilerPlugin {
    var providingMacros: [any Macro.Type] = [
        UIColorMacro.self,
        ColorMacro.self,
        NSColorMacro.self,
        CGColorMacro.self,
    ]
}
