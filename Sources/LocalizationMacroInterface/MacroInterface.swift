//
//  MacroInterface.swift
//  AppBooster
//
//  Created by Codex on 3/11/26.
//

import Foundation
import LocalizationMacroShared

@attached(member, names: arbitrary)
public macro L10nAuto(bundle: Bundle) = #externalMacro(module: "LocalizationMacrosImpl", type: "L10nAutoMacro")

@attached(peer)
public macro L10nPlain() = #externalMacro(module: "LocalizationMacrosImpl", type: "L10nPlainMacro")

@attached(peer)
public macro L10nParameter(
    value: L10nValue? = nil,
    value2: L10nValue? = nil,
    value3: L10nValue? = nil,
    value4: L10nValue? = nil
) = #externalMacro(module: "LocalizationMacrosImpl", type: "L10nParameterMacro")
