//
//  L10nMacroTests.swift
//  AppBooster
//
//  Created by Codex on 3/11/26.
//

#if os(macOS)
@testable import LocalizationMacroInterface
@testable import LocalizationMacrosImpl
import MacroTesting
import Testing

@Suite(.macros([L10nAutoMacro.self]))
struct L10nMacroTests {
    @Test
    func plainAndParameterizedCases() {
        assertMacro {
            """
            @L10nAuto(bundle: Bundle.module)
            public enum Loc {
                @L10nPlain
                case settings_title

                @L10nParameter(value: .int("limit"))
                case limit_format

                @L10nParameter(value: .uint("total"))
                case total_count

                @L10nParameter(value: .int("days"), value2: .double("percentage"))
                case days_and_used_percentage
            }
            """
        } expansion: {
            """
            public enum Loc {
                @L10nPlain
                case settings_title

                @L10nParameter(value: .int("limit"))
                case limit_format

                @L10nParameter(value: .uint("total"))
                case total_count

                @L10nParameter(value: .int("days"), value2: .double("percentage"))
                case days_and_used_percentage

                public static var settingsTitle: String {
                    NSLocalizedString("settings_title", bundle: Bundle.module, comment: "")
                }

                public static func limitFormat(limit: Int) -> String {
                    let comment = "use %1${limit}lld to represent limit"
                    let format = NSLocalizedString("limit_format", bundle: Bundle.module, comment: comment)
                    return __l10nReplace(format, replacements: ["%1${limit}lld": String(describing: limit)])
                }

                public static func totalCount(total: UInt) -> String {
                    let comment = "use %1${total}llu to represent total"
                    let format = NSLocalizedString("total_count", bundle: Bundle.module, comment: comment)
                    return __l10nReplace(format, replacements: ["%1${total}llu": String(describing: total)])
                }

                public static func daysAndUsedPercentage(days: Int, percentage: Double) -> String {
                    let comment = "use %1${days}lld to represent days, use %2${percentage}lf to represent percentage"
                    let format = NSLocalizedString("days_and_used_percentage", bundle: Bundle.module, comment: comment)
                    return __l10nReplace(format, replacements: ["%1${days}lld": String(describing: days), "%2${percentage}lf": String(describing: percentage)])
                }

                private static func __l10nReplace(_ format: String, replacements: [String: String]) -> String {
                    var result = format
                    for entry in replacements.sorted(by: { $0.key.count > $1.key.count
                        }) {
                        result = result.replacingOccurrences(of: entry.key, with: entry.value)
                    }
                    return result
                }
            }
            """
        }
    }

    @Test
    func parameterValueRequired() {
        assertMacro {
            """
            @L10nAuto(bundle: Bundle.module)
            enum Loc {
                @L10nParameter()
                case limit_format
            }
            """
        } diagnostics: {
            """
            @L10nAuto(bundle: Bundle.module)
            enum Loc {
                @L10nParameter()
                ╰─ 🛑 @L10nParameter requires at least one value argument
                case limit_format
            }
            """
        }
    }
}
#endif
