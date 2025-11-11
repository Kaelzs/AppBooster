// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import FoundationMacroShared

// MARK: - URL

@freestanding(expression)
public macro url(_ string: String) -> URL = #externalMacro(module: "FoundationMacrosImpl", type: "URLMacro")

// MARK: - Available

@freestanding(expression)
public macro osAvailable(_ string: String) -> URL = #externalMacro(module: "FoundationMacrosImpl", type: "OSAvailableMacro")

// MARK: - CodingKeys

@attached(member, names: named(CodingKeys))
public macro CodingKeys(pattern: CodingKeyPattern = .normal) = #externalMacro(module: "FoundationMacrosImpl", type: "CodingKeysMacro")

@attached(peer)
public macro CodingKey(custom: String) = #externalMacro(module: "FoundationMacrosImpl", type: "CustomCodingKeyMacro")

@attached(peer)
public macro CodingKeyIgnored() = #externalMacro(module: "FoundationMacrosImpl", type: "CodingKeyIgnoredMacro")
