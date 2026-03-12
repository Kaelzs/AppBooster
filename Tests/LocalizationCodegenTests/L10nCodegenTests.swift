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
                private static func __l10nReplace(_ format: String, replacements: [(String, () -> String)]) -> String {
                    var result = format
                    for entry in replacements.sorted(by: { $0.0.count > $1.0.count }) {
                        guard result.contains(entry.0) else {
                            continue
                        }
                        result = result.replacingOccurrences(of: entry.0, with: entry.1())
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
                    return __l10nReplace(format, replacements: [
                        ("%1${limit}lld", { String(describing: limit()) })
                    ])
                }

                static func totalCount(total: @autoclosure () -> UInt) -> String {
                    let format = NSLocalizedString("total_count", bundle: Self.bundle, comment: "use %1${total}llu to represent total")
                    return __l10nReplace(format, replacements: [
                        ("%1${total}llu", { String(describing: total()) })
                    ])
                }

                static func daysAndUsedPercentage(days: @autoclosure () -> Int, percentage: @autoclosure () -> Double) -> String {
                    let format = NSLocalizedString("days_and_used_percentage", bundle: Self.bundle, comment: "use %1${days}lld to represent days, use %2${percentage}lf to represent percentage")
                    return __l10nReplace(format, replacements: [
                        ("%1${days}lld", { String(describing: days()) }),
                        ("%2${percentage}lf", { String(describing: percentage()) })
                    ])
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
}
