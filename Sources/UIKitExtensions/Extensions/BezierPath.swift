//
//  BezierPath.swift
//  AppBooster
//
//  Created by Kael on 9/8/25.
//

#if canImport(UIKit)
import UIKit

public extension UIBezierPath {
    enum Corner {
        case topLeft, topRight, bottomLeft, bottomRight

        var signConfig: (xSign: Bool, ySign: Bool, reversedClockwise: Bool) {
            switch self {
            case .topLeft: return (true, true, false)
            case .topRight: return (false, true, true)
            case .bottomLeft: return (true, false, true)
            case .bottomRight: return (false, false, false)
            }
        }
    }

    private static let coefficients: [CGFloat] = [1.528665, 1.088492957618529, 0.868406944063002, 0.631493792830993, 0.372823826625747, 0.16905955604437, 0.074911387847016]

    static func continuousCurveEnd(at corner: Corner, cornerPoint: CGPoint, radius: CGFloat, clockwise: Bool) -> CGPoint {
        let cornerCoefficient = Self.coefficients[0]

        let signConfig = corner.signConfig
        let realClockwise = (signConfig.reversedClockwise != clockwise)

        let xValue, yValue: CGFloat
        let corner = radius * cornerCoefficient
        if realClockwise {
            (xValue, yValue) = (corner, 0)
        } else {
            (xValue, yValue) = (0, corner)
        }

        return CGPoint(x: cornerPoint.x + (signConfig.xSign ? xValue : -xValue), y: cornerPoint.y + (signConfig.ySign ? yValue : -yValue))
    }

    func addContinuousCorner(at corner: Corner, cornerPoint: CGPoint, radius: CGFloat, clockwise: Bool, lineToPathStart: Bool) {
        guard radius > 0 else {
            if lineToPathStart {
                addLine(to: cornerPoint)
            } else {
                move(to: cornerPoint)
            }
            return
        }

        let calculatingHelpers: [CGFloat] = Self.coefficients.map { $0 * radius } + [0, 0, 0]

        let signConfig = corner.signConfig

        let pointCount = 10

        let realClockwise = (signConfig.reversedClockwise != clockwise)
        let points: [CGPoint] = {
            if realClockwise {
                return (0 ..< pointCount).map { index -> CGPoint in
                    let reversedIndex = pointCount - index - 1
                    return CGPoint(x: cornerPoint.x + (signConfig.xSign ? calculatingHelpers[reversedIndex] : -calculatingHelpers[reversedIndex]), y: cornerPoint.y + (signConfig.ySign ? calculatingHelpers[index] : -calculatingHelpers[index]))
                }
            } else {
                return (0 ..< pointCount).map { index -> CGPoint in
                    let reversedIndex = pointCount - index - 1
                    return CGPoint(x: cornerPoint.x + (signConfig.xSign ? calculatingHelpers[index] : -calculatingHelpers[index]), y: cornerPoint.y + (signConfig.ySign ? calculatingHelpers[reversedIndex] : -calculatingHelpers[reversedIndex]))
                }
            }
        }()

        if lineToPathStart {
            addLine(to: points[0])
        } else {
            move(to: points[0])
        }

        let curveCount = 3
        (0 ..< curveCount).forEach { curveIndex in
            self.addCurve(to: points[3 + curveIndex * 3], controlPoint1: points[1 + curveIndex * 3], controlPoint2: points[2 + curveIndex * 3])
            if curveIndex == 0 {
                self.addLine(to: points[3 + curveIndex * 3]) // Apple add this line to path, but we don't know why :( .
            }
        }
    }

    convenience init(continuousRoundedRect roundedRect: CGRect, topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0) {
        self.init()

        addContinuousCorner(at: .topLeft, cornerPoint: CGPoint.zero, radius: topLeft, clockwise: true, lineToPathStart: false)
        addContinuousCorner(at: .topRight, cornerPoint: CGPoint(x: roundedRect.width, y: 0), radius: topRight, clockwise: true, lineToPathStart: true)
        addContinuousCorner(at: .bottomRight, cornerPoint: CGPoint(x: roundedRect.width, y: roundedRect.height), radius: bottomRight, clockwise: true, lineToPathStart: true)
        addContinuousCorner(at: .bottomLeft, cornerPoint: CGPoint(x: 0, y: roundedRect.height), radius: bottomLeft, clockwise: true, lineToPathStart: true)
        close()
    }
}

#endif
