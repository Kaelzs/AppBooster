//
//  HumanUsableGradientLayer.swift
//  AppBooster
//
//  Created by Kael on 12/12/25.
//

#if canImport(UIKit)
import UIKit

open class HumanUsableGradientLayer: CAGradientLayer {
    open var huStartPoint: CGPoint = .init(x: 0.5, y: 0) { didSet { updatePoints() } }
    open var huEndPoint: CGPoint = .init(x: 0.5, y: 1) { didSet { updatePoints() } }

#if DEBUG
    private var internalSet = false

    override open var startPoint: CGPoint {
        didSet { assert(internalSet, "Use huStartPoint instead") }
    }

    override open var endPoint: CGPoint {
        didSet { assert(internalSet, "Use huEndPoint instead") }
    }
#endif

    private func startAndEndPoint() -> (CGPoint, CGPoint) {
        guard bounds.size.width != bounds.size.height else {
            return (huStartPoint, huEndPoint)
        }
        guard huStartPoint.x != huEndPoint.x || huStartPoint.y != huEndPoint.y else {
            return (huStartPoint, huEndPoint)
        }
        // In current square, we assume the height is 1, then calculate the width ratio
        let nowRatio = bounds.size.width / bounds.size.height
        let centerPoint = CGPoint(x: (huStartPoint.x + huEndPoint.x) / 2, y: (huStartPoint.y + huEndPoint.y) / 2)

        let nowAngle = atan2(huEndPoint.y - huStartPoint.y, (huEndPoint.x - huStartPoint.x) * nowRatio)
        let perpendicularAngle = nowAngle + .pi / 2
        let perpendicularAngleInSquare = atan2(sin(perpendicularAngle), cos(perpendicularAngle) / nowRatio)
        let angleInSquare = perpendicularAngleInSquare - .pi / 2

        // Find the point new start
        // the line from new start to center is perpendicular to the line from new start to huStart
        let startEndAngleInSquare = atan2(huEndPoint.y - huStartPoint.y, huEndPoint.x - huStartPoint.x)
        let halfLength = hypot(huEndPoint.x - huStartPoint.x, huEndPoint.y - huStartPoint.y) / 2
        let perpendicularLength = cos(startEndAngleInSquare - angleInSquare) * halfLength
        let dx = cos(angleInSquare) * perpendicularLength
        let dy = sin(angleInSquare) * perpendicularLength

        let newStartPoint = CGPoint(x: centerPoint.x - dx, y: centerPoint.y - dy)
        let newEndPoint = CGPoint(x: centerPoint.x + dx, y: centerPoint.y + dy)

        return (newStartPoint, newEndPoint)
    }

    override open func layoutSublayers() {
        super.layoutSublayers()

        updatePoints()
    }

    private func updatePoints() {
        guard bounds.size.width != 0, bounds.size.height != 0 else {
            return
        }
#if DEBUG
        internalSet = true
#endif
        let (newStart, newEnd) = startAndEndPoint()
        startPoint = newStart
        endPoint = newEnd
#if DEBUG
        internalSet = false
#endif
    }
}
#endif
