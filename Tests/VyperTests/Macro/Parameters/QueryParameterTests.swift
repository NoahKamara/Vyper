//
//  QueryParameterTests.swift
//
//  Copyright © 2024 Noah Kamara.
//

import MacroTesting
import Testing
@testable import VyperMacros

@Suite("RouterMacro: Query Parameter", .macros([RouterMacro.self]), .tags(.macro))
struct QueryParameterTests {
    @Test
    func base() {
        assertMacro {
            """
            @Router(traits: .excludeFromDocs)
            struct TestController {
                @GET(":foo", ":bar")
                func list(@Query foo: String, @Query bar baz: Int) -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                @GET(":foo", ":bar")
                func list(@Query foo: String, @Query bar baz: Int) -> Response {
                    Response(statusCode: 200)
                }
            }

            extension TestController: RouteCollection {
                func boot(routes: any RoutesBuilder) throws {
                    routes.on(.GET, ":foo", ":bar") { request in
                        let foo: String = try request.query.get(at: "foo")
                        let bar: Int = try request.query.get(at: "bar")
                        return self.list(foo: foo, bar: bar)
                    }
                }
            }
            """
        }
    }

    @Test
    func optionalParameter() {
        assertMacro {
            """
            @Router(traits: .excludeFromDocs)
            struct TestController {
                @GET(":foo", ":bar")
                func list(@Query foo: String?, @Query bar: Int?) -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                @GET(":foo", ":bar")
                func list(@Query foo: String?, @Query bar: Int?) -> Response {
                    Response(statusCode: 200)
                }
            }

            extension TestController: RouteCollection {
                func boot(routes: any RoutesBuilder) throws {
                    routes.on(.GET, ":foo", ":bar") { request in
                        let foo: String? = request.query["foo"]
                        let bar: Int? = request.query["bar"]
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
            @Router(traits: .excludeFromDocs)
            struct TestController {
                @GET(":foo", ":bar")
                func list(@Query foo: String) -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                @GET(":foo", ":bar")
                func list(@Query foo: String) -> Response {
                    Response(statusCode: 200)
                }
            }

            extension TestController: RouteCollection {
                func boot(routes: any RoutesBuilder) throws {
                    routes.on(.GET, ":foo", ":bar") { request in
                        let foo: String = try request.query.get(at: "foo")
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
            @Router(traits: .excludeFromDocs)
            struct TestController {
                @GET(":foo", ":bar")
                func list(@Query foo: Int) -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                @GET(":foo", ":bar")
                func list(@Query foo: Int) -> Response {
                    Response(statusCode: 200)
                }
            }

            extension TestController: RouteCollection {
                func boot(routes: any RoutesBuilder) throws {
                    routes.on(.GET, ":foo", ":bar") { request in
                        let foo: Int = try request.query.get(at: "foo")
                        return self.list(foo: foo)
                    }
                }
            }
            """
        }
    }
}
