// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "AppBooster",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "AppBooster",
            targets: [
                "FoundationExtensions",
                "UIKitExtensions",
            ]
        ),
        .library(
            name: "FoundationExtensions",
            targets: [
                "FoundationExtensions",
            ]
        ),
        .library(
            name: "UIKitExtensions",
            targets: [
                "UIKitExtensions",
            ]
        ),
        .plugin(
            name: "LocalizationCommandPlugin",
            targets: [
                "LocalizationCommandPlugin",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.0"),
        .package(url: "https://github.com/stackotter/swift-macro-toolkit", from: "0.6.0"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.6.3"),
    ],
    targets: [
        .target(
            name: "MacroExtensions",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "MacroToolkit", package: "swift-macro-toolkit"),
            ]
        ),

        // MARK: - Foundation Macros

        .target(
            name: "FoundationMacroShared"
        ),
        .macro(
            name: "FoundationMacrosImpl",
            dependencies: [
                "FoundationMacroShared",
                "MacroExtensions",
            ]
        ),
        .target(
            name: "FoundationExtensions",
            dependencies: [
                "FoundationMacrosImpl",
                "FoundationMacroShared",
                "MacroExtensions",
            ]
        ),
        .testTarget(
            name: "FoundationMacrosTests",
            dependencies: [
                "FoundationExtensions",
                "FoundationMacrosImpl",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]
        ),

        // MARK: - Localization Codegen

        .target(
            name: "LocalizationCodegenCore"
        ),
        .executableTarget(
            name: "LocalizationCodegenGenerator",
            dependencies: [
                "LocalizationCodegenCore",
            ]
        ),
        .plugin(
            name: "LocalizationCommandPlugin",
            capability: .command(
                intent: .custom(
                    verb: "generate-localizations",
                    description: "Generate checked-in localization source files from .l10ndef.swift templates."
                ),
                permissions: [
                    .writeToPackageDirectory(
                        reason: "This command generates .generated.swift localization source files next to their templates."
                    ),
                ]
            ),
            dependencies: [
                "LocalizationCodegenGenerator",
            ]
        ),
        .testTarget(
            name: "LocalizationCodegenTests",
            dependencies: [
                "LocalizationCodegenCore",
            ]
        ),

        // MARK: - UIKit Macros

        .target(
            name: "UIKitMacroShared"
        ),
        .macro(
            name: "UIKitMacrosImpl",
            dependencies: [
                "UIKitMacroShared",
                "MacroExtensions",
            ]
        ),
        .target(
            name: "UIKitExtensions",
            dependencies: [
                "UIKitMacrosImpl",
                "UIKitMacroShared",
                "MacroExtensions",
            ]
        ),
        .testTarget(
            name: "UIKitMacrosTests",
            dependencies: [
                "UIKitExtensions",
                "UIKitMacrosImpl",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]
        ),
    ]
)
