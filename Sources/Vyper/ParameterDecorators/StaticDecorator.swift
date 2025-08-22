//
//  Decorated.swift
//  Vyper
//
//  Created by Noah Kamara on 23.08.2025.
//


@propertyWrapper
public struct StaticDecorator<T>: DecoratorProtocol {
    public var wrappedValue: T

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}

public typealias Path<T> = StaticDecorator<T>
public typealias Header<T> = StaticDecorator<T>
public typealias Field<T> = StaticDecorator<T>
public typealias Body<T> = StaticDecorator<T>
