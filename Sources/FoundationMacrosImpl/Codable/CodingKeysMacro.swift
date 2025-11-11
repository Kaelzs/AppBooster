//
//  CodingKeysMacro.swift
//  AppBooster
//
//  Created by Kael on 8/25/25.
//

import Foundation
import FoundationMacroShared
import MacroExtensions
import MacroToolkit
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct CodingKeysMacro: MemberMacro {
    public enum Error: Swift.Error, Diagnostiable {
        case customCodingKeyRequired

        public var id: String {
            switch self {
            case .customCodingKeyRequired:
                return "CustomCodingKeyRequired"
            }
        }

        public var domain: String {
            "CodingKeysMacro"
        }

        public var description: String {
            switch self {
            case .customCodingKeyRequired:
                return "@CodingKey attribute requires a 'custom' argument"
            }
        }
    }

    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        let pattern = pattern(from: node)

        var codingCases: [String] = []
        for memberNode in declaration.memberBlock.members {
            guard let variable = Variable(memberNode.decl),
                  variable.isStoredProperty,
                  !variable.isClass,
                  !variable.isStatic,
                  let identifier = variable.identifiers.first else {
                continue
            }

            guard variable.attribute(named: "CodingKeyIgnored") == nil else {
                continue
            }

            if let codingKey = variable.attribute(named: "CodingKey") {
                if let customAttribute = codingKey.asMacroAttribute?.argument(labeled: "custom")?.asStringLiteral?.value {
                    codingCases.append("case \(identifier) = \"\(customAttribute)\"")
                } else {
                    let diagnostic = DiagnosticBuilder(for: Syntax(variable._syntax))
                        .error(Error.customCodingKeyRequired)
                        .build()
                    context.diagnose(diagnostic)
                    return []
                }
            } else {
                codingCases.append("case \(identifier) = \"\(apply(pattern: pattern, to: identifier))\"")
            }
        }

        guard !codingCases.isEmpty else {
            return []
        }

        let accessPrefix = AccessModifier(firstModifierOfKindIn: declaration.modifiers).flatMap { $0.name + " " } ?? ""

        return [
            """
            \(raw: accessPrefix)enum CodingKeys: String, CodingKey {
                \(raw: codingCases.joined(separator: "\n    "))
            }
            """
        ]
    }

    static func pattern(from node: AttributeSyntax) -> CodingKeyPattern {
        guard let patternArgument = MacroAttribute(node).argument(labeled: "pattern"),
              let rawText = patternArgument._syntax.as(MemberAccessExprSyntax.self)?.declName.baseName.text,
              let pattern = CodingKeyPattern(rawValue: rawText) else {
            return .normal
        }

        return pattern
    }

    static func apply(pattern: CodingKeyPattern, to identifier: String) -> String {
        if pattern == .normal {
            return identifier
        }

        var tokens: [[Character]] = []

        var previousUppercase = false
        for char in identifier {
            if char == "_" {
                previousUppercase = false
                if tokens.last?.isEmpty == false {
                    tokens.append([])
                }
                continue
            } else if char.isUppercase {
                if !previousUppercase {
                    if tokens.last?.isEmpty == true {
                        tokens[tokens.count - 1].append(char)
                    } else {
                        tokens.append([char])
                    }
                } else {
                    if tokens.isEmpty {
                        tokens.append([char])
                    } else {
                        tokens[tokens.count - 1].append(char)
                    }
                }
                previousUppercase = true
            } else {
                if previousUppercase {
                    if tokens[tokens.count - 1].count > 1 {
                        let last = tokens[tokens.count - 1].removeLast()
                        tokens.append([last, char])
                    } else {
                        tokens[tokens.count - 1].append(char)
                    }
                } else {
                    if tokens.isEmpty {
                        tokens.append([char])
                    } else {
                        tokens[tokens.count - 1].append(char)
                    }
                }
                previousUppercase = false
            }
        }

        let merged = tokens.map { $0.map { $0.lowercased() }.joined() }

        switch pattern {
        case .camelCased:
            if merged.count == 1 {
                return merged[0]
            } else {
                return merged[0] + merged[1...].map(\.capitalized).joined()
            }
        case .snakeCased:
            return merged.joined(separator: "_")
        default:
            fatalError("unreachable")
        }
    }
}
