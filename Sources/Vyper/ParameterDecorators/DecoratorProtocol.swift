//
//  DecoratorProtocol.swift
//
//  Copyright © 2024 Noah Kamara.
//

public protocol DecoratorProtocol {
    associatedtype T
    var wrappedValue: T { get set }
}

public extension DecoratorProtocol {
    subscript<V>(dynamicMember keyPath: KeyPath<T, V>) -> V {
        self.wrappedValue[keyPath: keyPath]
    }

    subscript<V>(dynamicMember keyPath: WritableKeyPath<T, V>) -> V {
        get { self.wrappedValue[keyPath: keyPath] }
        set { self.wrappedValue[keyPath: keyPath] = newValue }
    }
}
