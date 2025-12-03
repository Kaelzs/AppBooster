//
//  Base64EncodeMacro.swift
//  AppBooster
//
//  Created by Kael on 12/3/25.
//

import Foundation
import MacroExtensions
import MacroToolkit
import SwiftSyntax
import SwiftSyntaxMacros

public struct Base64EncodeMacro: ExpressionMacro {
    public enum Error: Swift.Error, Diagnostiable {
        case argumentMissing
        case invalidArgument
        case invalidBase64String(String)

        public var id: String {
            switch self {
            case .argumentMissing:
                return "ArgumentMissing"
            case .invalidArgument:
                return "InvalidArgument"
            case .invalidBase64String:
                return "InvalidBase64String"
            }
        }

        public var domain: String {
            "Base64EncodeMacro"
        }

        public var description: String {
            switch self {
            case .argumentMissing:
                return "requires exactly one static string argument"
            case .invalidArgument:
                return "argument must be a single static string literal"
            case .invalidBase64String(let string):
                return "not a valid base64 encodable string: '\(string)'"
            }
        }
    }

    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            let diagnostic = DiagnosticBuilder(for: Syntax(node.macroName))
                .error(Error.argumentMissing)
                .build()
            context.diagnose(diagnostic)
            return ""
        }

        guard let literal = StringLiteral(argument),
              let literalValue = literal.value,
              !literalValue.isEmpty else {
            let diagnostic = DiagnosticBuilder(for: Syntax(argument))
                .error(Error.invalidArgument)
                .build()
            context.diagnose(diagnostic)
            return ""
        }

        guard let data = literalValue.data(using: .utf8) else {
            let diagnostic = DiagnosticBuilder(for: Syntax(argument))
                .error(Error.invalidBase64String(literalValue))
                .build()
            context.diagnose(diagnostic)
            return ""
        }

        return "\"\(raw: data.base64EncodedString())\""
    }
}
