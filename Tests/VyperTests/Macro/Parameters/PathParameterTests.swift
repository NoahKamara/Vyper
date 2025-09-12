//
//  PathParameterTests.swift
//
//  Copyright © 2024 Noah Kamara.
//

import MacroTesting
import Testing
@testable import VyperMacros

@Suite("RouterMacro: Path Parameter", .macros([RouterMacro.self]), .tags(.macro))
struct PathParameterTests {
    @Test
    func optionalParameter() {
        assertMacro {
            """
            @Router(traits: .excludeFromDocs)
            struct TestController {
                @GET("users", ":id")
                func getUser(@Path id: String) -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                @GET("users", ":id")
                func getUser(@Path id: String) -> Response {
                    Response(statusCode: 200)
                }
            }

            extension TestController: RouteCollection {
                func boot(routes: any RoutesBuilder) throws {
                    routes.on(.GET, "users", ":id") { request in
                        let id: String = try request.parameters.require("id")
                        return self.getUser(id: id)
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
            @Router(traits: .excludeFromDocs)
            struct TestController {
                @GET("users", ":id")
                func getUser(@Path id: String) -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                @GET("users", ":id")
                func getUser(@Path id: String) -> Response {
                    Response(statusCode: 200)
                }
            }

            extension TestController: RouteCollection {
                func boot(routes: any RoutesBuilder) throws {
                    routes.on(.GET, "users", ":id") { request in
                        let id: String = try request.parameters.require("id")
                        return self.getUser(id: id)
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
            @Router(traits: .excludeFromDocs)
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
                func boot(routes: any RoutesBuilder) throws {
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
