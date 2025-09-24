//
//  Trait.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Vapor

public protocol Trait: Sendable {}

public protocol RouteTrait: Trait {}
public protocol RouterTrait: Trait {}

