//
//  Trait.swift
//  Vyper
//
//  Created by Noah Kamara on 28.08.2025.
//


public protocol Trait: Sendable {}

public struct ExcludeFromDocs: Trait {
    public init() {}
}

extension Trait where Self == ExcludeFromDocs {
    static var excludeFromDocs: ExcludeFromDocs { .init() }
}

