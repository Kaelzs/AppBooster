//
//  Array.swift
//  AppBooster
//
//  Created by Kael on 9/5/25.
//

import Foundation

public extension Array {
    /// A safe subscript that returns or sets an element only when the index is valid.
    ///
    /// - Getting:
    ///   - Returns the element at `index` if it is within `indices`; otherwise returns `nil`.
    ///
    /// - Setting:
    ///   - If `index` is within bounds and `newValue` is non-nil, replaces the element at `index`.
    ///   - If `index` equals `endIndex` and `newValue` is non-nil, appends the new element to the end of the array.
    ///   - Any attempt to set `nil`, set out of bounds (other than exactly `endIndex`), or otherwise invalid operations will `fatalError()`.
    ///
    /// This subscript helps avoid out-of-bounds crashes on reads while keeping writes explicit and strict.
    subscript(safe index: Index) -> Element? {
        get {
            return indices.contains(index) ? self[index] : nil
        }
        set {
            if indices.contains(index) {
                if let newValue {
                    self[index] = newValue
                } else {
                    fatalError()
                }
            } else if self.endIndex == index {
                if let newValue {
                    self.append(newValue)
                }
            } else {
                fatalError()
            }
        }
    }
}

public extension Array {
    /// Reuses, updates, and trims/extends the receiver to match the given value array.
    ///
    /// This method is useful when you maintain an array of reusable items (e.g. view models, views, or
    /// expensive objects) and want to:
    /// - Update existing elements for the new data
    /// - Remove extra elements when the new data is shorter
    /// - Create and initialize additional elements when the new data is longer
    ///
    /// - Parameters:
    ///   - value: The source array whose count and items drive the desired final state.
    ///   - generator: Creates a brand-new `Element` for indices that don't yet exist (i.e., `self.count ..< value.count`).
    ///                This generator does not receive the corresponding `Value` and should not depend on input data;
    ///                it is only responsible for producing an empty/initial `Element` (e.g., a view or view model shell).
    ///                After the `Element` is generated, `updator` will be called to populate/configure it with the
    ///                appropriate `Value` for that index.
    ///   - updator: Called for every index that should exist in the final array (`0 ..< value.count`) to update an element
    ///              with the corresponding `Value`. Receives the index, the `Value` at that index, and the `Element` to mutate.
    ///   - remover: Called for each element that will be removed when the new `value` array is shorter than the current array.
    ///
    /// - Behavior:
    ///   - If `self.count >= value.count`:
    ///       - Calls `remover` for trailing elements beyond `value.count`.
    ///       - Truncates `self` to `value.count`.
    ///       - Calls `updator` for each remaining element.
    ///   - If `self.count < value.count`:
    ///       - Uses `generator` to create new elements for indices `self.count ..< value.count`,
    ///         and then calls `updator` on each generated element before appending.
    ///       - Calls `updator` for each existing element (`0 ..< self.count`).
    ///
    /// The operation mutates `self` to exactly match `value.count`, with all elements updated accordingly.
    mutating func reuse<Value>(value: [Value], using generator: (Int) -> Element, updator: (Int, Value, Element) -> Void, remover: (Element) -> Void) {
        if self.count >= value.count {
            if self.count > value.count {
                self[value.count...].forEach { remover($0) }
            }
            self = Array(self[0 ..< value.count])
            self.enumerated().forEach { index, element in
                updator(index, value[index], element)
            }
        } else {
            let new = (self.count ..< value.count).map { index -> Element in
                let generated = generator(index)
                updator(index, value[index], generated)
                return generated
            }
            self.enumerated().forEach { index, element in
                updator(index, value[index], element)
            }

            self = self + new
        }
    }
}
