//
//  PathParameterTests.swift
//
//  Copyright © 2024 Noah Kamara.
//

import MacroTesting
import Testing
@testable import VyperMacros

@Suite("APIMacro: Path Parameter", .macros([APIMacro.self]), .tags(.macro))
struct PathParameterTests {
    @Test
    func optionalParameter() {
        assertMacro {
            """
            @API(.excludeFromDocs)
            struct TestController {
                @GET(":foo", ":bar")
                func list(@Path foo: String?, @Path bar: Int?) -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                @GET(":foo", ":bar")
                func list(@Path foo: String?, @Path bar: Int?) -> Response {
                    Response(statusCode: 200)
                }
            }

            extension TestController: RouteCollection {
                func boot(routes: RoutesBuilder) throws {
                    routes.on(.GET, ":foo", ":bar") { request in
                        let foo: String? = request.parameters.get("foo")
                        let bar: Int? = request.parameters.get("bar")
                        return self.list(foo: foo, bar: bar)
                    }
                }
            }
            """
        }
    }

    @Test
    func requiredParameter() {
        assertMacro {
            """
            @API(.excludeFromDocs)
            struct TestController {
                @GET(":foo", ":bar")
                func list(@Path foo: String) -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                @GET(":foo", ":bar")
                func list(@Path foo: String) -> Response {
                    Response(statusCode: 200)
                }
            }

            extension TestController: RouteCollection {
                func boot(routes: RoutesBuilder) throws {
                    routes.on(.GET, ":foo", ":bar") { request in
                        let foo: String = try request.parameters.require("foo")
                        return self.list(foo: foo)
                    }
                }
            }
            """
        }
    }

    @Test
    func convertibleParameter() {
        assertMacro {
            """
            @API(.excludeFromDocs)
            struct TestController {
                @GET(":foo", ":bar")
                func list(@Path foo: Int) -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                @GET(":foo", ":bar")
                func list(@Path foo: Int) -> Response {
                    Response(statusCode: 200)
                }
            }

            extension TestController: RouteCollection {
                func boot(routes: RoutesBuilder) throws {
                    routes.on(.GET, ":foo", ":bar") { request in
                        let foo: Int = try request.parameters.require("foo")
                        return self.list(foo: foo)
                    }
                }
            }
            """
        }
    }
}
