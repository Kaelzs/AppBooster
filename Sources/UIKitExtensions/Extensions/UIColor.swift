//
//  UIColor.swift
//  AppBooster
//
//  Created by Kael on 9/24/25.
//

import UIKitMacroShared

protocol ColorType {
    static func create(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> Self

    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) { get }
}

extension ColorType {
    func _applying(mask: Self) -> Self {
        let base = rgba
        let mask = mask.rgba

        let final = ColorUtil.applyMask(
            red: base.red, green: base.green, blue: base.blue, alpha: base.alpha,
            maskRed: mask.red, maskGreen: mask.green, maskBlue: mask.blue, maskAlpha: mask.alpha
        )

        return Self.create(red: final.red, green: final.green, blue: final.blue, alpha: final.alpha)
    }
}

#if canImport(UIKit)
import UIKit

public extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        guard getRed(&r, green: &g, blue: &b, alpha: &a) else { return (0, 0, 0, 0) }
        return (r, g, b, a)
    }

    func applying(mask: UIColor) -> UIColor {
        return _applying(mask: mask)
    }
}

extension UIColor: ColorType {
    static func create(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> Self {
        return Self(red: red, green: green, blue: blue, alpha: alpha)
    }
}

#endif

#if canImport(AppKit)
import AppKit

public extension NSColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let color = usingColorSpace(.deviceRGB) ?? .black
        return (color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent)
    }

    func applying(mask: NSColor) -> NSColor {
        return _applying(mask: mask)
    }
}

extension NSColor: ColorType {
    static func create(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> Self {
        return Self(red: red, green: green, blue: blue, alpha: alpha)
    }
}

#endif
