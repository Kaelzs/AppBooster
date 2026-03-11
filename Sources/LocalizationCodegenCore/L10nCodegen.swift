import Foundation

public struct L10nParameterSpec: Equatable {
    public let name: String
    public let swiftType: String
    public let placeholder: String

    public init(name: String, swiftType: String, placeholder: String) {
        self.name = name
        self.swiftType = swiftType
        self.placeholder = placeholder
    }
}

public enum L10nCaseSpec: Equatable {
    case plain(name: String)
    case parameterized(name: String, parameters: [L10nParameterSpec])
}

public struct L10nContainerSpec: Equatable {
    public let name: String
    public let accessModifier: String?
    public let bundleName: String
    public let cases: [L10nCaseSpec]

    public init(name: String, accessModifier: String?, bundleName: String, cases: [L10nCaseSpec]) {
        self.name = name
        self.accessModifier = accessModifier
        self.bundleName = bundleName
        self.cases = cases
    }
}

public enum L10nCodegenError: Error, CustomStringConvertible, Equatable {
    case missingBundle(String)
    case unsupportedAssociatedValues(String)
    case invalidParameter(String)

    public var description: String {
        switch self {
        case let .missingBundle(typeName):
            return "\(typeName) must define 'static let bundle'"
        case let .unsupportedAssociatedValues(name):
            return "only Int, UInt, Double, and String parameters are supported, invalid parameter on '\(name)'"
        case let .invalidParameter(typeName):
            return "only Int, UInt, Double, and String parameters are supported, invalid parameter '\(typeName)'"
        }
    }
}

public enum L10nCodegen {
    public static func parseContainers(in source: String) throws -> [L10nContainerSpec] {
        let lines = source.components(separatedBy: .newlines)
        let outerEnumRegex = try NSRegularExpression(pattern: #"^\s*(public|internal|package|fileprivate|private)?\s*enum\s+([A-Za-z_][A-Za-z0-9_]*)\b"#)
        let bundleRegex = try NSRegularExpression(pattern: #"^\s*(?:public|internal|package|fileprivate|private)?\s*static\s+let\s+bundle\s*=\s*(.+)$"#)
        let definitionsRegex = try NSRegularExpression(pattern: #"^\s*(?:public|internal|package|fileprivate|private)?\s*enum\s+L10NDefinitions\b"#)

        var containers: [L10nContainerSpec] = []
        var outerName: String?
        var outerAccess: String?
        var outerDepth = 0
        var definitionsDepth: Int?
        var foundDefinitions = false
        var bundleName: String?
        var cases: [L10nCaseSpec] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            let lineRange = NSRange(line.startIndex..., in: line)

            if outerName == nil,
               let match = outerEnumRegex.firstMatch(in: line, range: lineRange),
               let nameRange = Range(match.range(at: 2), in: line) {
                outerName = String(line[nameRange])
                if let accessRange = Range(match.range(at: 1), in: line), !accessRange.isEmpty {
                    outerAccess = String(line[accessRange])
                } else {
                    outerAccess = nil
                }

                outerDepth = line.filter { $0 == "{" }.count - line.filter { $0 == "}" }.count
                definitionsDepth = nil
                foundDefinitions = false
                bundleName = nil
                cases = []
                continue
            }

            guard let currentOuterName = outerName else {
                continue
            }

            if definitionsDepth == nil,
               let match = bundleRegex.firstMatch(in: line, range: lineRange),
               let bundleRange = Range(match.range(at: 1), in: line) {
                let expression = String(line[bundleRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                if expression.hasSuffix(".bundle") || expression.contains(".bundle") {
                    bundleName = "bundle"
                } else {
                    bundleName = "bundle"
                }
            }

            if definitionsDepth == nil,
               definitionsRegex.firstMatch(in: line, range: lineRange) != nil {
                foundDefinitions = true
                let opens = line.filter { $0 == "{" }.count
                let closes = line.filter { $0 == "}" }.count
                outerDepth += opens - closes
                definitionsDepth = outerDepth
                continue
            }

            if definitionsDepth != nil, trimmed.hasPrefix("case ") {
                let parsedCases = try parseCases(from: trimmed)
                cases.append(contentsOf: parsedCases)
            }

            let opens = line.filter { $0 == "{" }.count
            let closes = line.filter { $0 == "}" }.count
            outerDepth += opens - closes

            if let depth = definitionsDepth, outerDepth < depth {
                definitionsDepth = nil
            }

            if outerDepth == 0 {
                if foundDefinitions {
                    guard let bundleName else {
                        throw L10nCodegenError.missingBundle(currentOuterName)
                    }

                    containers.append(
                        L10nContainerSpec(
                            name: currentOuterName,
                            accessModifier: outerAccess,
                            bundleName: bundleName,
                            cases: cases
                        )
                    )
                }

                outerName = nil
                outerAccess = nil
                definitionsDepth = nil
                foundDefinitions = false
                bundleName = nil
                cases = []
            }
        }

        return containers
    }

    public static func render(container spec: L10nContainerSpec) -> String {
        let publicPrefix = spec.accessModifier.map { "\($0) " } ?? ""
        let members = spec.cases.map { render(case: $0, accessPrefix: publicPrefix, bundleName: spec.bundleName) }.joined(separator: "\n\n")

        return """
        private extension \(spec.name) {
            private static func __l10nReplace(_ format: String, replacements: [String: String]) -> String {
                var result = format
                for entry in replacements.sorted(by: { $0.key.count > $1.key.count }) {
                    result = result.replacingOccurrences(of: entry.key, with: entry.value)
                }
                return result
            }
        }

        \(publicPrefix)extension \(spec.name) {
        \(indent(members))
        }
        """
    }

    public static func renderFile(from source: String) throws -> String {
        let specs = try parseContainers(in: source)
        guard !specs.isEmpty else {
            return ""
        }

        return "import Foundation\n\n" + specs.map(render(container:)).joined(separator: "\n\n")
    }

    private static func render(case spec: L10nCaseSpec, accessPrefix: String, bundleName: String) -> String {
        switch spec {
        case let .plain(name):
            return """
            \(accessPrefix)static var \(camelCase(name)): String {
                NSLocalizedString("\(name)", bundle: Self.\(bundleName), comment: "")
            }
            """
        case let .parameterized(name, parameters):
            let functionName = camelCase(name)
            let signature = parameters.map { "\($0.name): \($0.swiftType)" }.joined(separator: ", ")
            let comment = parameters.enumerated().map { index, parameter in
                "use %\(index + 1)${\(parameter.name)}\(parameter.placeholder) to represent \(parameter.name)"
            }.joined(separator: ", ")
            let replacements = parameters.enumerated().map { index, parameter in
                "\"%\(index + 1)${\(parameter.name)}\(parameter.placeholder)\": String(describing: \(parameter.name))"
            }.joined(separator: ", ")

            return """
            \(accessPrefix)static func \(functionName)(\(signature)) -> String {
                let comment = "\(comment)"
                let format = NSLocalizedString("\(name)", bundle: Self.\(bundleName), comment: comment)
                return __l10nReplace(format, replacements: [\(replacements)])
            }
            """
        }
    }

    private static func parseCases(from line: String) throws -> [L10nCaseSpec] {
        guard let caseRange = line.range(of: "case ") else {
            return []
        }

        let remainder = line[caseRange.upperBound...]
        return try splitTopLevelCommaSeparated(String(remainder)).map { rawCase in
            let trimmed = rawCase.trimmingCharacters(in: .whitespaces)
            guard let firstParen = trimmed.firstIndex(of: "(") else {
                return .plain(name: trimmed)
            }

            guard let lastParen = trimmed.lastIndex(of: ")") else {
                throw L10nCodegenError.unsupportedAssociatedValues(String(trimmed[..<firstParen]))
            }

            let name = String(trimmed[..<firstParen])
            let parametersSlice = trimmed[trimmed.index(after: firstParen)..<lastParen]
            let parameters = try parseParameters(from: String(parametersSlice))
            return .parameterized(name: name, parameters: parameters)
        }
    }

    private static func parseParameters(from source: String) throws -> [L10nParameterSpec] {
        if source.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return []
        }

        return try source.split(separator: ",").map { rawParameter in
            let pieces = rawParameter.split(separator: ":", maxSplits: 1).map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            guard pieces.count == 2 else {
                throw L10nCodegenError.unsupportedAssociatedValues(rawParameter.trimmingCharacters(in: .whitespacesAndNewlines))
            }

            let name = pieces[0]
            let type = pieces[1]

            switch type {
            case "Int":
                return L10nParameterSpec(name: name, swiftType: "Int", placeholder: "lld")
            case "UInt":
                return L10nParameterSpec(name: name, swiftType: "UInt", placeholder: "llu")
            case "Double":
                return L10nParameterSpec(name: name, swiftType: "Double", placeholder: "lf")
            case "String":
                return L10nParameterSpec(name: name, swiftType: "String", placeholder: "@")
            default:
                throw L10nCodegenError.invalidParameter(type)
            }
        }
    }

    private static func splitTopLevelCommaSeparated(_ source: String) -> [String] {
        var results: [String] = []
        var current = ""
        var depth = 0

        for char in source {
            switch char {
            case "(":
                depth += 1
                current.append(char)
            case ")":
                depth = max(0, depth - 1)
                current.append(char)
            case "," where depth == 0:
                results.append(current)
                current = ""
            default:
                current.append(char)
            }
        }

        if !current.isEmpty {
            results.append(current)
        }

        return results
    }

    private static func indent(_ source: String) -> String {
        source
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { line in
                line.isEmpty ? "" : "    \(line)"
            }
            .joined(separator: "\n")
    }

    private static func camelCase(_ text: String) -> String {
        let parts = text.split(separator: "_").filter { !$0.isEmpty }
        guard let first = parts.first else {
            return text
        }

        return first.lowercased() + parts.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }.joined()
    }
}
