//
//  Passthrough.swift
//  Vyper
//
//  Created by Noah Kamara on 28.08.2025.
//

import Vapor

/// Path decorator that passes the request object or a keypath accessible property
@propertyWrapper
public struct Passthrough<T>: DecoratorProtocol {
    public var wrappedValue: T

    public init(wrappedValue: T) where T == Vapor.Request {
        self.wrappedValue = wrappedValue
    }

    public init(wrappedValue: T, _ keyPath: KeyPath<Request, T>) {
        self.wrappedValue = wrappedValue
    }
}
