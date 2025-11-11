//
//  AvailableMacro.swift
//  AppBooster
//
//  Created by Kael on 9/5/25.
//

import Foundation
import MacroExtensions
import MacroToolkit
import SwiftSyntax
import SwiftSyntaxMacros

public struct OSAvailableMacro: ExpressionMacro {
    public enum Error: Swift.Error, Diagnostiable {
        case argumentMissing
        case invalidArgument

        public var id: String {
            switch self {
            case .argumentMissing:
                return "ArgumentMissing"
            case .invalidArgument:
                return "InvalidArgument"
            }
        }

        public var domain: String {
            "AvailableMacro"
        }

        public var description: String {
            switch self {
            case .argumentMissing:
                return "requires at least one argument"
            case .invalidArgument:
                return "argument must be a single static string literal"
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

        return """
        { if #available(\(raw: literalValue), *) { return true } else { return false } }()
        """
    }
}
