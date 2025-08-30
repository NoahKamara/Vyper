//
//  APIOptionTests.swift
//
//  Copyright © 2024 Noah Kamara.
//

import MacroTesting
import Testing
@testable import VyperMacros

@Suite("APIMacro: Options", .macros([APIMacro.self]), .tags(.macro))
struct APIOptionTests {
    @Test
    func excludeFromDocs() {
        assertMacro {
            """
            @API(traits: .excludeFromDocs)
            struct TestController {
                /// Lorem ipsum dolor sit amet.
                @GET
                func list() -> Response {}
            }
            """
        } expansion: {
            """
            struct TestController {
                /// Lorem ipsum dolor sit amet.
                @GET
                func list() -> Response {}
            }

            extension TestController: RouteCollection {
                func boot(routes: RoutesBuilder) throws {
                    routes.on(.GET) { request in
                        return self.list()
                    }
                }
            }
            """
        }

        assertMacro {
            """
            @API
            struct TestController {
                /// Lorem ipsum dolor sit amet.
                @GET
                func list() {}
            }
            """
        } expansion: {
            """
            struct TestController {
                /// Lorem ipsum dolor sit amet.
                @GET
                func list() {}
            }

            extension TestController: RouteCollection {
                func boot(routes: RoutesBuilder) throws {
                    routes.on(.GET) { request in
                        return self.list()
                    }
                    .openAPI(
                        summary: "Lorem ipsum dolor sit amet.")
                }
            }
            """
        }
    }

    @Test
    func prefixPath() {
        assertMacro {
            """
            @API("prefix")
            struct TestController {
                @GET("route")
                func list() -> Response {}
            }
            """
        } expansion: {
            """
            struct TestController {
                @GET("route")
                func list() -> Response {}
            }

            extension TestController: RouteCollection {
                func boot(routes: RoutesBuilder) throws {
                    routes.on(.GET, "prefix", "route") { request in
                        return self.list()
                    }
                }
            }
            """
        }
    }
}
