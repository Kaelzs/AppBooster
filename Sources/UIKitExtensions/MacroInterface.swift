//
//  MacroInterface.swift
//  AppBooster
//
//  Created by Kael on 8/29/25.
//

// MARK: - UIKit

#if canImport(UIKit)
import UIKit

@freestanding(expression)
public macro uiColor(_ stringLiteral: StringLiteralType) -> UIColor = #externalMacro(module: "UIKitMacrosImpl", type: "UIColorMacro")

@freestanding(expression)
public macro uiColor(_ hexLiteral: IntegerLiteralType) -> UIColor = #externalMacro(module: "UIKitMacrosImpl", type: "UIColorMacro")

#endif

// MARK: - SwiftUI

#if canImport(SwiftUI)
import SwiftUI

@freestanding(expression)
public macro color(_ stringLiteral: StringLiteralType) -> Color = #externalMacro(module: "UIKitMacrosImpl", type: "ColorMacro")

@freestanding(expression)
public macro color(_ hexLiteral: IntegerLiteralType) -> Color = #externalMacro(module: "UIKitMacrosImpl", type: "ColorMacro")

#endif

// MARK: - AppKit

#if canImport(AppKit)
import AppKit

@freestanding(expression)
public macro nsColor(_ stringLiteral: StringLiteralType) -> NSColor = #externalMacro(module: "UIKitMacrosImpl", type: "NSColorMacro")

@freestanding(expression)
public macro nsColor(_ hexLiteral: IntegerLiteralType) -> NSColor = #externalMacro(module: "UIKitMacrosImpl", type: "NSColorMacro")

#endif

// MARK: - CoreGraphics

#if canImport(CoreGraphics)
import CoreGraphics

@freestanding(expression)
public macro cgColor(_ stringLiteral: StringLiteralType) -> CGColor = #externalMacro(module: "UIKitMacrosImpl", type: "CGColorMacro")

@freestanding(expression)
public macro cgColor(_ hexLiteral: IntegerLiteralType) -> CGColor = #externalMacro(module: "UIKitMacrosImpl", type: "CGColorMacro")

#endif
