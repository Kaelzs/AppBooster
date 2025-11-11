//
//  URLMacroTests.swift
//  AppBooster
//
//  Created by Kael on 8/27/25.
//

#if os(macOS)
@testable import FoundationExtensions
@testable import FoundationMacrosImpl
import MacroTesting
import Testing

@Suite(.macros([URLMacro.self]))
struct URLTests {
    @Test
    func normalURL() {
        assertMacro {
            """
            #url("https://www.example.com")
            """
        } expansion: {
            """
            URL(string: "https://www.example.com")!
            """
        }

        assertMacro {
            """
            #url("https://www.kaelzs.com")
            """
        } expansion: {
            """
            URL(string: "https://www.kaelzs.com")!
            """
        }
    }

    @Test
    func invalidArgument() {
        assertMacro {
            """
            #url("")
            """
        } diagnostics: {
            """
            #url("")
                 ╰─ 🛑 argument must be a single static string literal
            """
        }
    }

    @Test
    func invalidURL() {
        assertMacro {
            """
            #url("ht!tp://invalid.url")
            """
        } diagnostics: {
            """
            #url("ht!tp://invalid.url")
                 ╰─ 🛑 not a valid URL: 'ht!tp://invalid.url'
            """
        }
    }
}
#endif
