//
//  File.swift
//  Vyper
//
//  Created by Noah Kamara on 26.08.2025.
//

import Testing
import InlineSnapshotTesting
@testable import VyperCore
import SwiftParser
import SwiftSyntax

fileprivate extension APIParser {
    static func parseRoute(_ source: String) throws -> APIRoute {
        enum SetupError: Error {
            case syntaxParser
            case apiParser
        }

        let syntax = Parser.parse(source: source)

        guard let function = syntax.statements.first?.item.as(FunctionDeclSyntax.self) else {
            throw SetupError.syntaxParser
        }

        guard let route = try APIParser.parseFunction(function) else {
            throw SetupError.apiParser
        }

        return route
    }
}

@Suite(.tags(.syntax))
struct APIParserTests {
    @Test(
        "Parameter Kind",
        arguments: [
            ("@Path",   APIRoute.Parameter.Kind.path),
            ("@Query",  APIRoute.Parameter.Kind.query),
            ("@Query",  APIRoute.Parameter.Kind.query),
            ("@Header", APIRoute.Parameter.Kind.header),
            ("@Body",   APIRoute.Parameter.Kind.body),
        ]
    )
    func parameterKind(decorator: String, kind: APIRoute.Parameter.Kind) throws {
        let route = try APIParser.parseRoute("""
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
        let route = try APIParser.parseRoute("""
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
        let route = try APIParser.parseRoute("""
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
            ("",             false, false),
            ("async throws", true,  true),
            ("async",        true,  false),
            ("throws",       false, true),
        ]
    )
    func effectSpecifiers(effects: String, isAsync: Bool, isThrowing: Bool) throws{
        let route = try APIParser.parseRoute("""
        @GET
        func list() \(effects) -> Response {
            Response(statusCode: 200)
        }
        """)

        #expect(route.isAsync    == isAsync)
        #expect(route.isThrowing == isThrowing)
    }

    @Test("Route decorator path", arguments: [
        // MARK: HTTP Decorator
        ("@HTTP(.GET)", ".GET"),
        // MARK: Method Helper Decorators
        ("@GET",        ".GET"),
        ("@DELETE",     ".DELETE"),
        ("@PATCH",      ".PATCH"),
        ("@POST",       ".POST"),
        ("@PUT",        ".PUT"),
        ("@OPTIONS",    ".OPTIONS"),
        ("@HEAD",       ".HEAD"),
        ("@TRACE",      ".TRACE"),
        ("@CONNECT",    ".CONNECT"),
    ])
    func method(decorator: String, method: String) throws {
        let route = try APIParser.parseRoute("""
        \(decorator)
        func list() -> Response {
            Response(statusCode: 200)
        }
        """)

        #expect(route.method.trimmedDescription == method)
    }

    @Test("Route decorator path", arguments: [
        (#"@HTTP(.GET, "constant", "parameter", .catchall, "*")"#,
         #""constant", "parameter", .catchall, "*""#),
        (#"@GET("constant", "parameter", .catchall, "*")"#,
         #""constant", "parameter", .catchall, "*""#)
    ])
    func path(decorator: String, path: String) throws {
        let route = try APIParser.parseRoute("""
        \(decorator)
        func list() -> Response {
            Response(statusCode: 200)
        }
        """)

        #expect(route.path.map(\.trimmedDescription).joined(separator: ", ") == path)
    }
}
