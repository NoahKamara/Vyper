//
//  Trait.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Vapor

public protocol Trait: Sendable {}

public protocol RouteModifier: Trait {
    func modify(_ route: Route)
}

public extension Route {
    func modified(_ modifier: RouteModifier) -> Self {
        modifier.modify(self)
        return self
    }
}

public protocol RouteTrait: Trait {}
public protocol RouterTrait: Trait {}


//public protocol CollectionModifier: Trait {
//    associatedtype Collection: RouteCollection
//    func modify(_ route: some RouteCollection) -> Collection
//}
//
//public extension RouteCollection {
//    func modify<Modifier: CollectionModifier>(_ modifier: Modifier) -> Modifier.Collection {
//        modifier.modify(self)
//    }
//}
