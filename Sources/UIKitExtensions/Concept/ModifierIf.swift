//
//  ModifierIf.swift
//  AppBooster
//
//  Created by Kael on 9/5/25.
//

#if canImport(SwiftUI)
import SwiftUI

public extension View {
    @ViewBuilder
    func modifierIf<T: View>(condition: @autoclosure () -> Bool, @ViewBuilder modifier: (Self) -> T) -> some View {
        if condition() {
            modifier(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func modifierIf<T: View, U: View>(condition: @autoclosure () -> Bool, @ViewBuilder modifier: (Self) -> T, @ViewBuilder elseModifier: (Self) -> U) -> some View {
        if condition() {
            modifier(self)
        } else {
            elseModifier(self)
        }
    }

    @ViewBuilder
    func modifierIfLet<Value, T: View>(optional: Value?, @ViewBuilder modifier: (Self, Value) -> T) -> some View {
        if let value = optional {
            modifier(self, value)
        } else {
            self
        }
    }

    @ViewBuilder
    func modifierIfLet<Value, T: View, U: View>(optional: Value?, @ViewBuilder modifier: (Self, Value) -> T, @ViewBuilder elseModifier: (Self) -> U) -> some View {
        if let value = optional {
            modifier(self, value)
        } else {
            elseModifier(self)
        }
    }
}

#endif
