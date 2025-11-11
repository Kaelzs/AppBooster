//
//  UIColorMacro.swift
//  AppBooster
//
//  Created by Kael on 8/29/25.
//

import Foundation
import MacroExtensions
import MacroToolkit
import SwiftSyntax
import SwiftSyntaxMacros
import UIKitMacroShared

public enum HexColorMacroError: Swift.Error, Diagnostiable {
    case argumentMissing
    case invalidStringLiteral(String? = nil)
    case intergerLiteralWith0PrefixIsNotAllowed(String)
    case hexLiteralMustInHexFormat(String)

    public var id: String {
        switch self {
        case .argumentMissing:
            return "ArgumentMissing"
        case .invalidStringLiteral:
            return "InvalidStringLiteral"
        case .intergerLiteralWith0PrefixIsNotAllowed:
            return "IntergerLiteralWith0PrefixIsNotAllowed"
        case .hexLiteralMustInHexFormat:
            return "HexLiteralMustInHexFormat"
        }
    }

    public var domain: String {
        "UIColorMacro"
    }

    public var description: String {
        switch self {
        case .argumentMissing:
            return "requires exactly one static string or hex integer argument"
        case .invalidStringLiteral(let value):
            if let value {
                return "argument must be a valid hex color string literal, got: '\(value)'"
            } else {
                return "argument must be a non-empty static string literal"
            }
        case .intergerLiteralWith0PrefixIsNotAllowed(let value):
            return "0 as the prefix of an integer literal is not meaningful, got: '\(value)'"
        case .hexLiteralMustInHexFormat(let value):
            return "hex integer literal must start with '0x', got: '\(value)'"
        }
    }
}

public protocol HexColorExpressable {
    static func expansion(of red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> ExprSyntax
}

public extension HexColorExpressable where Self: ExpressionMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            let diagnostic = DiagnosticBuilder(for: Syntax(node.macroName))
                .error(HexColorMacroError.argumentMissing)
                .build()
            context.diagnose(diagnostic)
            return ""
        }

        let string: String

        if let literal = StringLiteral(argument) {
            if let literalValue = literal.value,
               !literalValue.isEmpty {
                string = literalValue
            } else {
                let diagnostic = DiagnosticBuilder(for: Syntax(argument))
                    .error(HexColorMacroError.invalidStringLiteral())
                    .build()
                context.diagnose(diagnostic)
                return ""
            }
        } else if let literal = IntegerLiteral(argument) {
            if literal._syntax.literal.text.starts(with: "0x") {
                string = String(format: "%X", literal.value)
                let intergerCount = literal._syntax.literal.text.count - 2
                if intergerCount != string.count {
                    let diagnostic = DiagnosticBuilder(for: Syntax(argument))
                        .error(HexColorMacroError.intergerLiteralWith0PrefixIsNotAllowed(literal._syntax.literal.text))
                        .build()
                    context.diagnose(diagnostic)
                    return ""
                }
            } else {
                let diagnostic = DiagnosticBuilder(for: Syntax(argument))
                    .error(HexColorMacroError.hexLiteralMustInHexFormat(literal._syntax.literal.text))
                    .build()
                context.diagnose(diagnostic)
                return ""
            }
        } else {
            let diagnostic = DiagnosticBuilder(for: Syntax(argument))
                .error(HexColorMacroError.argumentMissing)
                .build()
            context.diagnose(diagnostic)
            return ""
        }

        guard let rgba = ColorUtil.stringToRGBA(string) else {
            let diagnostic = DiagnosticBuilder(for: Syntax(argument))
                .error(HexColorMacroError.invalidStringLiteral(string))
                .build()
            context.diagnose(diagnostic)
            return ""
        }

        return expansion(of: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
    }
}

public struct UIColorMacro: ExpressionMacro, HexColorExpressable {
    public static func expansion(of red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> ExprSyntax {
        "UIKit.UIColor(red: \(raw: red), green: \(raw: green), blue: \(raw: blue), alpha: \(raw: alpha))"
    }
}

public struct ColorMacro: ExpressionMacro, HexColorExpressable {
    public static func expansion(of red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> ExprSyntax {
        "SwiftUI.Color(red: \(raw: red), green: \(raw: green), blue: \(raw: blue), opacity: \(raw: alpha))"
    }
}

public struct NSColorMacro: ExpressionMacro, HexColorExpressable {
    public static func expansion(of red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> ExprSyntax {
        "AppKit.NSColor(red: \(raw: red), green: \(raw: green), blue: \(raw: blue), alpha: \(raw: alpha))"
    }
}

public struct CGColorMacro: ExpressionMacro, HexColorExpressable {
    public static func expansion(of red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> ExprSyntax {
        "CoreGraphics.CGColor(red: \(raw: red), green: \(raw: green), blue: \(raw: blue), alpha: \(raw: alpha))"
    }
}
