//
//  CodableMacroTests.swift
//  AppBooster
//
//  Created by Kael on 8/27/25.
//

#if os(macOS)
@testable import FoundationExtensions
@testable import FoundationMacrosImpl
import MacroTesting
import Testing

@Suite(.macros([CodingKeysMacro.self]))
struct CodableMacroTests {
    @Test
    func patternGeneration() {
        #expect(CodingKeysMacro.apply(pattern: .camelCased, to: "camera__ViewController") == "cameraViewController")
        #expect(CodingKeysMacro.apply(pattern: .snakeCased, to: "camera__ViewController") == "camera_view_controller")
        // Not that good, but we try our best.
        #expect(CodingKeysMacro.apply(pattern: .camelCased, to: "expectAURL") == "expectAurl")
    }

    @Test
    func snakeCasedCodable() {
        assertMacro {
            """
            @CodingKeys(pattern: .snakeCased)
            struct MyStruct: Codable {
                @CodingKeyIgnored
                var name: String

                @CodingKey(custom: "age_in_years")
                var age: Int

                var isActive: Bool
            }
            """
        } expansion: {
            """
            struct MyStruct: Codable {
                @CodingKeyIgnored
                var name: String

                @CodingKey(custom: "age_in_years")
                var age: Int

                var isActive: Bool

                enum CodingKeys: String, CodingKey {
                    case age = "age_in_years"
                    case isActive = "is_active"
                }
            }
            """
        }
    }

    @Test
    func normalCodable() {
        assertMacro {
            """
            @CodingKeys()
            struct MyStruct: Codable {
                @CodingKeyIgnored
                var name: String

                @CodingKey(custom: "age_in_years")
                var age: Int

                var isActive: Bool
            }
            """
        } expansion: {
            """
            struct MyStruct: Codable {
                @CodingKeyIgnored
                var name: String

                @CodingKey(custom: "age_in_years")
                var age: Int

                var isActive: Bool

                enum CodingKeys: String, CodingKey {
                    case age = "age_in_years"
                    case isActive = "isActive"
                }
            }
            """
        }
    }
}
#endif
