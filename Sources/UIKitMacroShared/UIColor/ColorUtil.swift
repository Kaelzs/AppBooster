//
//  ColorUtil.swift
//  AppBooster
//
//  Created by Kael on 9/9/25.
//

import Foundation

public enum ColorUtil {
    private static let validHex = "0123456789abcdefABCDEF"

    public static func stringToRGBA(_ hex: String) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)

        if hex.hasPrefix("#") {
            hex.removeFirst()
        }

        guard hex.allSatisfy({ validHex.contains($0) }) else {
            return nil
        }

        let scanner = Scanner(string: hex)

        var hexValue: UInt64 = 0

        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0

        if scanner.scanHexInt64(&hexValue) {
            switch hex.count {
            case 3:
                red = CGFloat((hexValue & 0xF00) >> 8) / 15.0
                green = CGFloat((hexValue & 0x0F0) >> 4) / 15.0
                blue = CGFloat(hexValue & 0x00F) / 15.0
            case 4:
                red = CGFloat((hexValue & 0xF000) >> 12) / 15.0
                green = CGFloat((hexValue & 0x0F00) >> 8) / 15.0
                blue = CGFloat((hexValue & 0x00F0) >> 4) / 15.0
                alpha = CGFloat(hexValue & 0x000F) / 15.0
            case 6:
                red = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
                blue = CGFloat(hexValue & 0x0000FF) / 255.0
            case 8:
                red = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                blue = CGFloat((hexValue & 0x0000FF00) >> 8) / 255.0
                alpha = CGFloat(hexValue & 0x000000FF) / 255.0
            default:
                // Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8
                return nil
            }
        } else {
            return nil
        }

        return (red: red, green: green, blue: blue, alpha: alpha)
    }

    public static func applyMask(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat, maskRed: CGFloat, maskGreen: CGFloat, maskBlue: CGFloat, maskAlpha: CGFloat) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let finalAlpha = alpha + maskAlpha * (1 - alpha)
        guard finalAlpha > 0 else {
            return (red: 0, green: 0, blue: 0, alpha: 0)
        }
        let finalRed = (red * alpha * (1 - maskAlpha) + maskRed * maskAlpha) / finalAlpha
        let finalGreen = (green * alpha * (1 - maskAlpha) + maskGreen * maskAlpha) / finalAlpha
        let finalBlue = (blue * alpha * (1 - maskAlpha) + maskBlue * maskAlpha) / finalAlpha
        return (red: finalRed, green: finalGreen, blue: finalBlue, alpha: finalAlpha)
    }
}
