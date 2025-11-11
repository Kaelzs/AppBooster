//
//  URLMacro.swift
//  AppBooster
//
//  Created by Kael on 8/1/25.
//

import Foundation
import MacroExtensions
import MacroToolkit
import SwiftSyntax
import SwiftSyntaxMacros

public struct URLMacro: ExpressionMacro {
    public enum Error: Swift.Error, Diagnostiable {
        case argumentMissing
        case invalidArgument
        case invalidURL(String)

        public var id: String {
            switch self {
            case .argumentMissing:
                return "ArgumentMissing"
            case .invalidArgument:
                return "InvalidArgument"
            case .invalidURL:
                return "InvalidURL"
            }
        }

        public var domain: String {
            "URLMacro"
        }

        public var description: String {
            switch self {
            case .argumentMissing:
                return "requires exactly one static string argument"
            case .invalidArgument:
                return "argument must be a single static string literal"
            case .invalidURL(let urlString):
                return "not a valid URL: '\(urlString)'"
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

        guard URL(string: literalValue) != nil else {
            let diagnostic = DiagnosticBuilder(for: Syntax(argument))
                .error(Error.invalidURL(literalValue))
                .build()
            context.diagnose(diagnostic)
            return ""
        }

        return "URL(string: \(argument))!"
    }
}
