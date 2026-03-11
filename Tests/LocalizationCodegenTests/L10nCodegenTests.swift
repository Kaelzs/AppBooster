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
                private static func __l10nReplace(_ format: String, replacements: [String: String]) -> String {
                    var result = format
                    for entry in replacements.sorted(by: { $0.key.count > $1.key.count }) {
                        result = result.replacingOccurrences(of: entry.key, with: entry.value)
                    }
                    return result
                }
            }

            public extension AppLocalizations {
                public static var settingsTitle: String {
                    NSLocalizedString("settings_title", bundle: Self.bundle, comment: "")
                }

                public static func limitFormat(limit: Int) -> String {
                    let comment = "use %1${limit}lld to represent limit; use limit count directly"
                    let format = NSLocalizedString("limit_format", bundle: Self.bundle, comment: comment)
                    return __l10nReplace(format, replacements: ["%1${limit}lld": String(describing: limit)])
                }

                public static func totalCount(total: UInt) -> String {
                    let comment = "use %1${total}llu to represent total"
                    let format = NSLocalizedString("total_count", bundle: Self.bundle, comment: comment)
                    return __l10nReplace(format, replacements: ["%1${total}llu": String(describing: total)])
                }

                public static func daysAndUsedPercentage(days: Int, percentage: Double) -> String {
                    let comment = "use %1${days}lld to represent days, use %2${percentage}lf to represent percentage"
                    let format = NSLocalizedString("days_and_used_percentage", bundle: Self.bundle, comment: comment)
                    return __l10nReplace(format, replacements: ["%1${days}lld": String(describing: days), "%2${percentage}lf": String(describing: percentage)])
                }

                public static var jobSubjobStepPrefix: String {
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
}
