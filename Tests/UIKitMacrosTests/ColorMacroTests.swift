//
//  ColorMacroTests.swift
//  AppBooster
//
//  Created by Kael on 9/1/25.
//

#if os(macOS)
import MacroTesting
import Testing
@testable import UIKitExtensions
@testable import UIKitMacrosImpl

@Suite(.macros([
    UIColorMacro.self,
    ColorMacro.self,
    NSColorMacro.self,
    CGColorMacro.self,
]))
struct ColorTests {
    @Test
    func badColor() {
        assertMacro {
            """
            #nsColor("#F")
            """
        } diagnostics: {
            """
            #nsColor("#F")
                     ╰─ 🛑 argument must be a valid hex color string literal, got: '#F'
            """
        }

        assertMacro {
            """
            #nsColor(12345)
            """
        } diagnostics: {
            """
            #nsColor(12345)
                     ╰─ 🛑 hex integer literal must start with '0x', got: '12345'
            """
        }
    }

    @Test
    func nsColor() {
        assertMacro {
            """
            #nsColor(0xFFE411)
            """
        } expansion: {
            """
            AppKit.NSColor(red: 1.0, green: 0.8941176470588236, blue: 0.06666666666666667, alpha: 1.0)
            """
        }

        assertMacro {
            """
            #nsColor("#FFE411")
            """
        } expansion: {
            """
            AppKit.NSColor(red: 1.0, green: 0.8941176470588236, blue: 0.06666666666666667, alpha: 1.0)
            """
        }
    }
}
#endif
