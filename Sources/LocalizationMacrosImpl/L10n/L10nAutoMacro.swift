//
//  L10nAutoMacro.swift
//  AppBooster
//
//  Created by Codex on 3/11/26.
//

import Foundation
import MacroExtensions
import MacroToolkit
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct L10nAutoMacro: MemberMacro {
    enum Error: Swift.Error, Diagnostiable {
        case enumOnly
        case bundleRequired
        case caseWithAssociatedValue(String)
        case invalidParameter(String)
        case missingParameterValues

        var id: String {
            switch self {
            case .enumOnly:
                return "EnumOnly"
            case .bundleRequired:
                return "BundleRequired"
            case .caseWithAssociatedValue:
                return "CaseWithAssociatedValue"
            case .invalidParameter:
                return "InvalidParameter"
            case .missingParameterValues:
                return "MissingParameterValues"
            }
        }

        var domain: String {
            "L10nAutoMacro"
        }

        var description: String {
            switch self {
            case .enumOnly:
                return "@L10nAuto can only be applied to an enum"
            case .bundleRequired:
                return "@L10nAuto requires a 'bundle' argument"
            case let .caseWithAssociatedValue(name):
                return "@L10nAuto only supports simple enum cases, found associated values on '\(name)'"
            case let .invalidParameter(label):
                return "@L10nParameter only supports int, uint, double, or string values, invalid argument at '\(label)'"
            case .missingParameterValues:
                return "@L10nParameter requires at least one value argument"
            }
        }
    }

    struct Parameter {
        let name: String
        let swiftType: String
        let placeholder: String
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.as(EnumDeclSyntax.self) != nil else {
            let diagnostic = DiagnosticBuilder(for: Syntax(declaration))
                .error(Error.enumOnly)
                .build()
            context.diagnose(diagnostic)
            return []
        }

        guard let bundleExpression = MacroAttribute(node).argument(labeled: "bundle")?._syntax.trimmedDescription,
              !bundleExpression.isEmpty else {
            let diagnostic = DiagnosticBuilder(for: Syntax(node))
                .error(Error.bundleRequired)
                .build()
            context.diagnose(diagnostic)
            return []
        }

        let accessPrefix = AccessModifier(firstModifierOfKindIn: declaration.modifiers).flatMap { $0.name + " " } ?? ""

        var members: [DeclSyntax] = []
        var didGenerateLocalizedMember = false

        for member in declaration.memberBlock.members {
            guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else {
                continue
            }

            let hasPlain = caseDecl.attributes.containsAttribute(named: "L10nPlain")
            let parameterAttribute = caseDecl.attributes.attribute(named: "L10nParameter")

            guard hasPlain || parameterAttribute != nil else {
                continue
            }

            for element in caseDecl.elements {
                if element.parameterClause != nil {
                    let diagnostic = DiagnosticBuilder(for: Syntax(element))
                        .error(Error.caseWithAssociatedValue(element.name.text))
                        .build()
                    context.diagnose(diagnostic)
                    return []
                }

                didGenerateLocalizedMember = true

                if hasPlain {
                    let propertyName = camelCase(element.name.text)
                    members.append(
                        """
                        \(raw: accessPrefix)static var \(raw: propertyName): String {
                            NSLocalizedString("\(raw: element.name.text)", bundle: \(raw: bundleExpression), comment: "")
                        }
                        """
                    )
                } else if let parameterAttribute {
                    guard let parameters = parameters(from: parameterAttribute, in: context) else {
                        return []
                    }

                    let functionName = camelCase(element.name.text)
                    let signature = parameters
                        .map { "\($0.name): \($0.swiftType)" }
                        .joined(separator: ", ")
                    let comment = parameters.enumerated()
                        .map { index, parameter in
                            "use %\(index + 1)${\(parameter.name)}\(parameter.placeholder) to represent \(parameter.name)"
                        }
                        .joined(separator: ", ")
                    let replacements = parameters.enumerated()
                        .map { index, parameter in
                            "\"%\(index + 1)${\(parameter.name)}\(parameter.placeholder)\": String(describing: \(parameter.name))"
                        }
                        .joined(separator: ", ")

                    members.append(
                        """
                        \(raw: accessPrefix)static func \(raw: functionName)(\(raw: signature)) -> String {
                            let comment = "\(raw: comment)"
                            let format = NSLocalizedString("\(raw: element.name.text)", bundle: \(raw: bundleExpression), comment: comment)
                            return __l10nReplace(format, replacements: [\(raw: replacements)])
                        }
                        """
                    )
                }
            }
        }

        guard didGenerateLocalizedMember else {
            return []
        }

        members.append(
            """
            private static func __l10nReplace(_ format: String, replacements: [String: String]) -> String {
                var result = format
                for entry in replacements.sorted(by: { $0.key.count > $1.key.count }) {
                    result = result.replacingOccurrences(of: entry.key, with: entry.value)
                }
                return result
            }
            """
        )

        return members
    }

    static func parameters(from attribute: AttributeSyntax, in context: some MacroExpansionContext) -> [Parameter]? {
        let arguments = MacroAttribute(attribute)
            .arguments
            .filter { ($0.label ?? "").hasPrefix("value") }
            .sorted(by: { lhs, rhs in
                (lhs.label ?? "").localizedStandardCompare(rhs.label ?? "") == .orderedAscending
            }
            )

        guard !arguments.isEmpty else {
            let diagnostic = DiagnosticBuilder(for: Syntax(attribute))
                .error(Error.missingParameterValues)
                .build()
            context.diagnose(diagnostic)
            return nil
        }

        var parameters: [Parameter] = []

        for argument in arguments {
            guard let functionCall = argument.expr._syntax.as(FunctionCallExprSyntax.self),
                  let memberAccess = functionCall.calledExpression.as(MemberAccessExprSyntax.self),
                  let firstArgument = functionCall.arguments.first,
                  let name = firstArgument.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue else {
                let diagnostic = DiagnosticBuilder(for: argument.expr._syntax)
                    .error(Error.invalidParameter(argument.label ?? "value"))
                    .build()
                context.diagnose(diagnostic)
                return nil
            }

            let parameter: Parameter?
            switch memberAccess.declName.baseName.text {
            case "int":
                parameter = Parameter(name: name, swiftType: "Int", placeholder: "lld")
            case "uint":
                parameter = Parameter(name: name, swiftType: "UInt", placeholder: "llu")
            case "double":
                parameter = Parameter(name: name, swiftType: "Double", placeholder: "lf")
            case "string":
                parameter = Parameter(name: name, swiftType: "String", placeholder: "@")
            default:
                parameter = nil
            }

            guard let parameter else {
                let diagnostic = DiagnosticBuilder(for: argument.expr._syntax)
                    .error(Error.invalidParameter(argument.label ?? "value"))
                    .build()
                context.diagnose(diagnostic)
                return nil
            }

            parameters.append(parameter)
        }

        return parameters
    }

    static func camelCase(_ text: String) -> String {
        let parts = text.split(separator: "_").filter { !$0.isEmpty }
        guard let first = parts.first else {
            return text
        }

        return first.lowercased() + parts.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }.joined()
    }
}

extension AttributeListSyntax {
    fileprivate func containsAttribute(named name: String) -> Bool {
        attribute(named: name) != nil
    }

    fileprivate func attribute(named name: String) -> AttributeSyntax? {
        for element in self {
            guard let attribute = element.as(AttributeSyntax.self) else {
                continue
            }

            if attribute.attributeName.as(IdentifierTypeSyntax.self)?.name.text == name {
                return attribute
            }
        }

        return nil
    }
}
