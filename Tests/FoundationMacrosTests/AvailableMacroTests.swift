//
//  AvailableMacroTests.swift
//  AppBooster
//
//  Created by Kael on 9/5/25.
//

#if os(macOS)
@testable import FoundationExtensions
@testable import FoundationMacrosImpl
import MacroTesting
import Testing

@Suite(.macros([OSAvailableMacro.self]))
struct AvailableMacroTests {
    @Test
    func normalExpansion() {
        assertMacro {
            """
            #osAvailable("macOS 15.0")
            """
        } expansion: {
            """
            {
                if #available(macOS 15.0, *) {
                    return true
                } else {
                    return false
                }
            }()
            """
        }
    }
}

#endif
