//
//  Base64EncodeMacroTests.swift
//  AppBooster
//
//  Created by Kael on 12/3/25.
//

#if os(macOS)
@testable import FoundationExtensions
@testable import FoundationMacrosImpl
import MacroTesting
import Testing

@Suite(.macros([Base64EncodeMacro.self]))
struct Base64EncodeTests {
    @Test
    func normalURL() {
        assertMacro {
            """
            #base64Encode("https://www.example.com")
            """
        } expansion: {
            """
            "aHR0cHM6Ly93d3cuZXhhbXBsZS5jb20="
            """
        }

        assertMacro {
            """
            #base64Encode("UIViewController")
            """
        } expansion: {
            """
            "VUlWaWV3Q29udHJvbGxlcg=="
            """
        }
    }

    @Test
    func invalidArgument() {
        assertMacro {
            """
            #base64Encode("")
            """
        } diagnostics: {
            """
            #base64Encode("")
                          ╰─ 🛑 argument must be a single static string literal
            """
        }
    }
}

@Suite(.macros([Base64DecodeMacro.self]))
struct Base64DecodeTests {
    @Test
    func normalURL() {
        assertMacro {
            """
            #base64Decode("aHR0cHM6Ly93d3cuZXhhbXBsZS5jb20=")
            """
        } expansion: {
            """
            "https://www.example.com"
            """
        }

        assertMacro {
            """
            #base64Decode("VUlWaWV3Q29udHJvbGxlcg==")
            """
        } expansion: {
            """
            "UIViewController"
            """
        }
    }

    @Test
    func invalidArgument() {
        assertMacro {
            """
            #base64Decode("")
            """
        } diagnostics: {
            """
            #base64Decode("")
                          ╰─ 🛑 argument must be a single static string literal
            """
        }
    }
}

@Suite(.macros([ShiftEncodeMacro.self]))
struct ShiftEncodeTests {
    @Test
    func normalURL() {
        assertMacro {
            """
            #shiftEncode("ThisIsGood", by: 1)
            """
        } expansion: {
            """
            "UijtJtHppe"
            """
        }

        assertMacro {
            """
            #shiftEncode("SteveJobs", by: 2)
            """
        } expansion: {
            """
            "UvgxgLqdu"
            """
        }
    }

    @Test
    func invalidArgument() {
        assertMacro {
            """
            #shiftEncode("", by: 2)
            """
        } diagnostics: {
            """
            #shiftEncode("", by: 2)
                         ╰─ 🛑 first argument must be a static non-empty string literal
            """
        }
    }
}
#endif
