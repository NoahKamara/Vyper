//
//  Query.swift
//  Vyper
//
//  Created by Noah Kamara on 23.08.2025.
//

import Vapor

@propertyWrapper
public struct Query<T>: DecoratorProtocol {
    public var wrappedValue: T

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    /// Decides how to decode the query.
    public enum Option {
        /// decodes the entire query as an object
        case whole

        /// decodes the item at the specified keyPath from the query
        case partial

        static func partial(at keys: CodingKeyRepresentable...) -> Self {
            .partial
        }
    }

//    public init(_ mode: Option = .partial, wrappedValue: T) {
//        self.init(wrappedValue: wrappedValue)
//    }
}
