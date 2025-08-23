//
//  File.swift
//  Vyper
//
//  Created by Noah Kamara on 23.08.2025.
//


public protocol Trait : Sendable {}


//public protocol RouteModifier : Trait {
//    /// Prepare to run the test that has this trait.
//    ///
//    /// - Parameters:
//    ///   - test: The test that has this trait.
//    ///
//    /// - Throws: Any error that prevents the test from running. If an error
//    ///   is thrown from this method, the test is skipped and the error is
//    ///   recorded as an ``Issue``.
//    ///
//    /// The testing library calls this method after it discovers all tests and
//    /// their traits, and before it begins to run any tests.
//    /// Use this method to prepare necessary internal state, or to determine
//    /// whether the test should run.
//    ///
//    /// The default implementation of this method does nothing.
//    func call(_ route: APIRoute, next: @escaping (APIRoute) -> Void)
//}
//
//
//
//extension Route {
//    func modified(_ modifier: RouteModifier) -> {
//        modifier.call(<#T##APIRoute#>, next: <#T##(APIRoute) -> Void#>)
//    }
//}
