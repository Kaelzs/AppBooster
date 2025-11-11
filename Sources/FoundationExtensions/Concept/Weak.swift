//
//  Weak.swift
//  AppBooster
//
//  Created by Kael on 9/5/25.
//

import Foundation

/// A lightweight wrapper that holds a weak reference to an object of type `T`.
///
/// Use `Weak` when you need to store weak references in collections (arrays, sets, dictionaries),
/// which otherwise retain their elements strongly. This helps avoid reference cycles and keeps
/// objects from being kept alive solely by their presence in a collection.
///
/// - Important: `T` must be a class type. If you pass a value type (struct/enum),
///   it will be bridged to an `AnyObject` at init-time in a way that does not preserve identity,
///   and the weak reference will immediately become `nil`.
///
/// - Hashing & Equality:
///   Two `Weak<T>` instances are considered equal if they point to the same underlying object identity.
///   Hashing is based on the `ObjectIdentifier` of the underlying object at initialization time.
///   If the referenced object deallocates, `obj` becomes `nil` but the `Weak`'s identity/hash remains stable.
///
/// - Example:
///   ```swift
///   final class MyClass {}
///
///   let a = MyClass()
///   let b = MyClass()
///
///   // Store weak references in a Set to avoid retaining the objects
///   var set = Set<Weak<MyClass>>()
///   set.insert(Weak(a))
///   set.insert(Weak(b))
///
///   // Access the underlying objects (may be nil if deallocated)
///   for weakRef in set {
///       if let object = weakRef.obj {
///           // use object
///       }
///   }
///
///   // In an Array:
///   var list: [Weak<MyClass>] = [Weak(a), Weak(b)]
///   let liveObjects = list.compactMap { $0.obj }
///   ```
///
/// - Note: Because the reference is weak, you typically need to periodically clean up
///   collections by removing entries whose `obj` is `nil`.
public class Weak<T: AnyObject>: Hashable {
    weak var weakRef: AnyObject?

    public var obj: T? {
        weakRef as? T
    }

    let id: ObjectIdentifier

    public init(_ obj: T) {
        let object: AnyObject = obj as AnyObject
        weakRef = object
        id = ObjectIdentifier(object)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }

    public static func == (lhs: Weak<T>, rhs: Weak<T>) -> Bool {
        lhs.id == rhs.id
    }
}
