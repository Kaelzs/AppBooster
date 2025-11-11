//
//  TouchAreaExtended.swift
//  AppBooster
//
//  Created by Kael on 9/9/25.
//

#if canImport(UIKit)
import UIKit

extension UIControl {
    @MainActor
    private enum AssociatedKeys {
        static var touchAreaInsetsKey: UInt8 = 0
    }

    public var touchAreaEdgeInsets: UIEdgeInsets {
        get {
            (objc_getAssociatedObject(self, &AssociatedKeys.touchAreaInsetsKey) as? NSValue)?
                .uiEdgeInsetsValue ?? .zero
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.touchAreaInsetsKey,
                NSValue(uiEdgeInsets: newValue),
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if touchAreaEdgeInsets == UIEdgeInsets.zero || !isEnabled || isHidden {
            let superPointInside = super.point(inside: point, with: event)
            return superPointInside
        }

        let relativeFrame = bounds
        let hitFrame = relativeFrame.inset(by: touchAreaEdgeInsets)

        let selfPointInside = hitFrame.contains(point)
        return selfPointInside
    }
}

#endif
