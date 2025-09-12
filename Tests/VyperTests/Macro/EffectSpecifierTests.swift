//
//  EffectSpecifierTests.swift
//
//  Copyright © 2024 Noah Kamara.
//

import MacroTesting
import Testing
@testable import VyperMacros

@Suite("RouterMacro: Effect Specifiers", .macros([RouterMacro.self]), .tags(.macro))
struct EffectSpecifierTests {
    @Test
    func basic() {
        assertMacro {
            """
            @Router
            struct TestController {
                @GET
                func list() -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                @GET
                func list() -> Response {
                    Response(statusCode: 200)
                }
            }

            extension TestController: RouteCollection {
                func boot(routes: any RoutesBuilder) throws {
                    routes.on(.GET) { request in
                        return self.list()
                    }
                }
            }
            """
        }
    }

    @Test
    func async() {
        assertMacro {
            """
            @Router
            struct TestController {
                @GET
                func list() async -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                @GET
                func list() async -> Response {
                    Response(statusCode: 200)
                }
            }

            extension TestController: RouteCollection {
                func boot(routes: any RoutesBuilder) throws {
                    routes.on(.GET) { request in
                        return await self.list()
                    }
                }
            }
            """
        }
    }

    @Test
    func throwing() {
        assertMacro {
            """
            @Router
            struct TestController {
                @GET
                func list() throws -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                @GET
                func list() throws -> Response {
                    Response(statusCode: 200)
                }
            }

            extension TestController: RouteCollection {
                func boot(routes: any RoutesBuilder) throws {
                    routes.on(.GET) { request in
                        return try self.list()
                    }
                }
            }
            """
        }
    }

    @Test
    func asyncThrowing() {
        assertMacro {
            """
            @Router
            struct TestController {
                @GET
                func list() async throws -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } diagnostics: {
            """

            """
        } expansion: {
            """
            struct TestController {
                @GET
                func list() async throws -> Response {
                    Response(statusCode: 200)
                }
            }

            extension TestController: RouteCollection {
                func boot(routes: any RoutesBuilder) throws {
                    routes.on(.GET) { request in
                        return try await self.list()
                    }
                }
            }
            """
        }
    }
}
