//
//  Trait.swift
//  Vyper
//
//  Created by Noah Kamara on 28.08.2025.
//

import Vapor

public protocol Trait: Sendable {}

public struct ExcludeFromDocs: Trait {
    public init() {}
}

public extension Trait where Self == ExcludeFromDocs {
    static var excludeFromDocs: ExcludeFromDocs { .init() }
}

public protocol RouteModifier: Trait {
    func modify(_ route: Route)
}

public extension Route {
    func modified(_ modifier: RouteModifier) -> Self {
        modifier.modify(self)
        return self
    }
}

public protocol CollectionModifier: Trait {
    associatedtype Collection: RouteCollection
    func modify(_ route: some RouteCollection) -> Collection
}

public extension RouteCollection {
    func modify<Modifier: CollectionModifier>(_ modifier: Modifier) -> Modifier.Collection {
        modifier.modify(self)
    }
}
