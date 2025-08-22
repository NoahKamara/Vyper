//
//  DecoratorProtocol.swift
//  Vyper
//
//  Created by Noah Kamara on 23.08.2025.
//


public protocol DecoratorProtocol {
    associatedtype T
    var wrappedValue: T { get set }
    init(wrappedValue: T)
}

extension DecoratorProtocol {
    public subscript<V>(dynamicMember keyPath: KeyPath<T, V>) -> V {
        self.wrappedValue[keyPath: keyPath]
    }

    public subscript<V>(dynamicMember keyPath: WritableKeyPath<T, V>) -> V {
        get { self.wrappedValue[keyPath: keyPath] }
        set { self.wrappedValue[keyPath: keyPath] = newValue }
    }
}
