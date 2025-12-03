//
//  ShiftEncodeMacro.swift
//  AppBooster
//
//  Created by Kael on 12/3/25.
//

import Foundation
import MacroExtensions
import MacroToolkit
import SwiftSyntax
import SwiftSyntaxMacros

public struct ShiftEncodeMacro: ExpressionMacro {
    public enum Error: Swift.Error, Diagnostiable {
        case argumentMissing
        case invalidStringArgument
        case invalidIntegerArgument
        case invalidShiftString(String)

        public var id: String {
            switch self {
            case .argumentMissing:
                return "ArgumentMissing"
            case .invalidStringArgument:
                return "InvalidStringArgument"
            case .invalidIntegerArgument:
                return "InvalidIntegerArgument"
            case .invalidShiftString:
                return "InvalidShiftString"
            }
        }

        public var domain: String {
            "ShiftEncodeMacro"
        }

        public var description: String {
            switch self {
            case .argumentMissing:
                return "requires exactly one static string argument and one static integer argument"
            case .invalidStringArgument:
                return "first argument must be a static non-empty string literal"
            case .invalidIntegerArgument:
                return "second argument must be a static integer literal"
            case .invalidShiftString(let string):
                return "not a valid base64 encodable string: '\(string)'"
            }
        }
    }

    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        guard let stringArgument = node.arguments.first?.expression,
              let shiftArgument = node.arguments.dropFirst().first?.expression else {
            let diagnostic = DiagnosticBuilder(for: Syntax(node.macroName))
                .error(Error.argumentMissing)
                .build()
            context.diagnose(diagnostic)
            return ""
        }

        guard let literal = StringLiteral(stringArgument),
              let literalValue = literal.value,
              !literalValue.isEmpty else {
            let diagnostic = DiagnosticBuilder(for: Syntax(stringArgument))
                .error(Error.invalidStringArgument)
                .build()
            context.diagnose(diagnostic)
            return ""
        }

        guard let shift = IntegerLiteral(shiftArgument) else {
            let diagnostic = DiagnosticBuilder(for: Syntax(shiftArgument))
                .error(Error.invalidIntegerArgument)
                .build()
            context.diagnose(diagnostic)
            return ""
        }

        let shiftValue = shift.value

        var result: String = ""
        do {
            let array =  try literalValue.unicodeScalars.map { scalar throws(Error) -> UnicodeScalar in
                guard let result = UnicodeScalar(UInt32(Int(scalar.value) + shiftValue)) else {
                    throw Error.invalidShiftString(literalValue)
                }
                return result
            }
            result.unicodeScalars.append(contentsOf: array)
        } catch {
            let diagnostic = DiagnosticBuilder(for: Syntax(stringArgument))
                .error(error)
                .build()
            context.diagnose(diagnostic)
            return ""
        }

        return "\"\(raw: result)\""
    }
}
