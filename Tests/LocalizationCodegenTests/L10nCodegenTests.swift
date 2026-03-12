import LocalizationCodegenCore
import Testing

@Suite
struct L10nCodegenTests {
    @Test
    func generatesExtensionsFromDefinitionsEnum() throws {
        let input = """
        public enum AppLocalizations {
            static let bundle = Bundle.module

            enum L10NDefinitions {
                case settings_title
                case limit_format(limit: Int) // use limit count directly
                case total_count(total: UInt)
                case days_and_used_percentage(days: Int, percentage: Double)
                case job_subJob_step_prefix // use space in western language for better readability
            }
        }
        """

        let output = try L10nCodegen.renderFile(from: input)

        #expect(
            output == """
            import Foundation

            private extension AppLocalizations {
                private static func __l10nReplace(
                    _ format: String,
                    token1: String? = nil, value1: @autoclosure () -> String = "",
                    token2: String? = nil, value2: @autoclosure () -> String = "",
                    token3: String? = nil, value3: @autoclosure () -> String = "",
                    token4: String? = nil, value4: @autoclosure () -> String = "",
                    token5: String? = nil, value5: @autoclosure () -> String = ""
                ) -> String {
                    var result = format
                    if let token1, result.contains(token1) {
                        result = result.replacingOccurrences(of: token1, with: value1())
                    }
                    if let token2, result.contains(token2) {
                        result = result.replacingOccurrences(of: token2, with: value2())
                    }
                    if let token3, result.contains(token3) {
                        result = result.replacingOccurrences(of: token3, with: value3())
                    }
                    if let token4, result.contains(token4) {
                        result = result.replacingOccurrences(of: token4, with: value4())
                    }
                    if let token5, result.contains(token5) {
                        result = result.replacingOccurrences(of: token5, with: value5())
                    }
                    return result
                }
            }

            public extension AppLocalizations {
                static var settingsTitle: String {
                    NSLocalizedString("settings_title", bundle: Self.bundle, comment: "")
                }

                static func limitFormat(limit: @autoclosure () -> Int) -> String {
                    let format = NSLocalizedString("limit_format", bundle: Self.bundle, comment: "use %1${limit}lld to represent limit; use limit count directly")
                    return __l10nReplace(format, token1: "%1${limit}lld", value1: String(describing: limit()))
                }

                static func totalCount(total: @autoclosure () -> UInt) -> String {
                    let format = NSLocalizedString("total_count", bundle: Self.bundle, comment: "use %1${total}llu to represent total")
                    return __l10nReplace(format, token1: "%1${total}llu", value1: String(describing: total()))
                }

                static func daysAndUsedPercentage(days: @autoclosure () -> Int, percentage: @autoclosure () -> Double) -> String {
                    let format = NSLocalizedString("days_and_used_percentage", bundle: Self.bundle, comment: "use %1${days}lld to represent days, use %2${percentage}lf to represent percentage")
                    return __l10nReplace(
                        format,
                        token1: "%1${days}lld", value1: String(describing: days()),
                        token2: "%2${percentage}lf", value2: String(describing: percentage())
                    )
                }

                static var jobSubjobStepPrefix: String {
                    NSLocalizedString("job_subJob_step_prefix", bundle: Self.bundle, comment: "use space in western language for better readability")
                }
            }
            """
        )
    }

    @Test
    func rejectsUnsupportedParameterType() throws {
        let input = """
        enum AppLocalizations {
            static let bundle = Bundle.main

            enum L10NDefinitions {
                case title(flag: Bool)
            }
        }
        """

        #expect(throws: L10nCodegenError.invalidParameter("Bool")) {
            try L10nCodegen.renderFile(from: input)
        }
    }

    @Test
    func rejectsMoreThanFiveParameters() throws {
        let input = """
        enum AppLocalizations {
            static let bundle = Bundle.main

            enum L10NDefinitions {
                case title(a: Int, b: Int, c: Int, d: Int, e: Int, f: Int)
            }
        }
        """

        #expect(throws: L10nCodegenError.tooManyParameters("title", 6)) {
            try L10nCodegen.renderFile(from: input)
        }
    }
}
