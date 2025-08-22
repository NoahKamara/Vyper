//
//  HTTPMethodDecoratorTests 2.swift
//  Vyper
//
//  Created by Noah Kamara on 23.08.2025.
//


import MacroTesting
import Testing
@testable import VyperMacros

@Suite("Effect Specifiers", .macros([APIMacro.self]))
struct EffectSpecifierTests {
    @Test
    func basic() {
        assertMacro {
            """
            @API
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

            extension TestController {
                func boot(routes: RoutesBuilder) throws {
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
            @API
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

            extension TestController {
                func boot(routes: RoutesBuilder) throws {
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
            @API
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

            extension TestController {
                func boot(routes: RoutesBuilder) throws {
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
            @API
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

            extension TestController {
                func boot(routes: RoutesBuilder) throws {
                    routes.on(.GET) { request in
                        return try await self.list()
                    }
                }
            }
            """
        }
    }
}
