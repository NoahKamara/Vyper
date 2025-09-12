//
//  RouterMacroParseTests.swift
//
//  Copyright © 2024 Noah Kamara.
//

import InlineSnapshotTesting
import SwiftParser
import SwiftSyntax
import Testing
@testable import VyperMacros

@Suite("RouterMacro: Parsing", .tags(.syntax))
struct RouterMacroParseTests {
    @Test(
        "Parameter Kind",
        arguments: [
            ("@Path", RouteDescriptor.Parameter.Kind.path),
            ("@Query", RouteDescriptor.Parameter.Kind.query),
            ("@Header", RouteDescriptor.Parameter.Kind.header),
//            ("@Body",        APIRoute.Parameter.Kind.body),
            ("@Passthrough", RouteDescriptor.Parameter.Kind.passthrough(nil)),
        ]
    )
    func parameterKind(decorator: String, kind: RouteDescriptor.Parameter.Kind) throws {
        let route = try parseRoute("""
        @GET(":foo")
        func list(\(decorator) foo: Foo) -> Response {
            Response(statusCode: 200)
        }
        """)

        let parameter = try #require(route.parameters.first)
        #expect(parameter.kind == kind)
    }

    @Test("Parameter Optional", arguments: [true, false])
    func parameterOptional(value: Bool) throws {
        let route = try parseRoute("""
        @GET
        func list(@Query foo: Foo\(value ? "?" : "")) -> Response {
            Response(statusCode: 200)
        }
        """)

        let parameter = try #require(route.parameters.first)
        #expect(parameter.isOptional == value)
    }

    @Test("Parameter Type", arguments: ["Foo", "String"])
    func parameterType(_ type: String) throws {
        let route = try parseRoute("""
        @GET
        func list(@Query foo: \(type)) -> Response {
            Response(statusCode: 200)
        }
        """)

        let parameter = try #require(route.parameters.first)
        #expect(parameter.type == type)
    }

    @Test(
        "Effect specifiers",
        arguments: [
            ("", false, false),
            ("async throws", true, true),
            ("async", true, false),
            ("throws", false, true),
        ]
    )
    func effectSpecifiers(effects: String, isAsync: Bool, isThrowing: Bool) throws {
        let route = try parseRoute("""
        @GET
        func list() \(effects) -> Response {
            Response(statusCode: 200)
        }
        """)

        #expect(route.isAsync == isAsync)
        #expect(route.isThrowing == isThrowing)
    }

    @Test("Route decorator path", arguments: [
        // MARK: HTTP Decorator

        ("@HTTP(.GET)", ".GET"),

        // MARK: Method Helper Decorators

        ("@GET", ".GET"),
        ("@DELETE", ".DELETE"),
        ("@PATCH", ".PATCH"),
        ("@POST", ".POST"),
        ("@PUT", ".PUT"),
        ("@OPTIONS", ".OPTIONS"),
        ("@HEAD", ".HEAD"),
        ("@TRACE", ".TRACE"),
        ("@CONNECT", ".CONNECT"),
    ])
    func method(decorator: String, method: String) throws {
        let route = try parseRoute("""
        \(decorator)
        func list() -> Response {
            Response(statusCode: 200)
        }
        """)

        #expect(route.method.trimmedDescription == method)
    }

    @Test("Route decorator path", arguments: [
        (
            #"@HTTP(.GET, "constant", "parameter", .catchall, "*")"#,
            #""constant", "parameter", .catchall, "*""#
        ),
        (
            #"@GET("constant", "parameter", .catchall, "*")"#,
            #""constant", "parameter", .catchall, "*""#
        ),
    ])
    func path(decorator: String, path: String) throws {
        let route = try parseRoute("""
        \(decorator)
        func list() -> Response {
            Response(statusCode: 200)
        }
        """)

        #expect(route.path.map(\.trimmedDescription).joined(separator: ", ") == path)
    }
}

fileprivate func parseRoute(_ source: String) throws -> RouteDescriptor {
    enum SetupError: Error {
        case syntaxParser
        case apiParser
    }

    let syntax = Parser.parse(source: source)

    guard let function = syntax.statements.first?.item.as(FunctionDeclSyntax.self) else {
        throw SetupError.syntaxParser
    }

    guard let route = try RouterMacro.parseFunction(function) else {
        throw SetupError.apiParser
    }

    return route
}
