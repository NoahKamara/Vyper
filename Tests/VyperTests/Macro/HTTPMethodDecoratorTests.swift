//
//  HTTPDecoratorTests.swift
//
//  Copyright © 2024 Noah Kamara.
//

import MacroTesting
import Testing
@testable import VyperMacros

@Suite("APIMacro: HTTPMethod Decorator", .macros([APIMacro.self]), .tags(.macro))
struct HTTPMethodDecoratorTests {
    static let httpMethods = [
        "GET", "DELETE", "PATCH", "POST", "PUT", "OPTIONS", "HEAD", "TRACE", "CONNECT",
    ]

    static let paths = [
        #""constant""#,
        #""constant", "parameter", "*", "**""#,
    ]

    @Test(arguments: httpMethods)
    func basicHTTP(method: String) {
        assertMacro {
            """
            @API(.excludeFromDocs)
            struct TestController {
                @HTTP(.\(method))
                func list() -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                @HTTP(.\(method))
                func list() -> Response {
                    Response(statusCode: 200)
                }
            }

            extension TestController {
                func boot(routes: RoutesBuilder) throws {
                    routes.on(.\(method)) { request in
                        return self.list()
                    }
                }
            }
            """
        }
    }

    @Test(arguments: httpMethods)
    func methodHelper(method: String) {
        assertMacro {
            """
            @API(.excludeFromDocs)
            struct TestController {
                @\(method)
                func list() -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                @\(method)
                func list() -> Response {
                    Response(statusCode: 200)
                }
            }

            extension TestController {
                func boot(routes: RoutesBuilder) throws {
                    routes.on(.\(method)) { request in
                        return self.list()
                    }
                }
            }
            """
        }
    }

    @Test(arguments: paths)
    func path(path: String) {
        assertMacro {
            """
            @API(.excludeFromDocs)
            struct TestController {
                @HTTP(.GET, \(path))
                func list() -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                @HTTP(.GET, \(path))
                func list() -> Response {
                    Response(statusCode: 200)
                }
            }

            extension TestController {
                func boot(routes: RoutesBuilder) throws {
                    routes.on(.GET, \(path)) { request in
                        return self.list()
                    }
                }
            }
            """
        }
    }

    @Test(arguments: paths)
    func methodHelperPath(path: String) {
        assertMacro {
            """
            @API(.excludeFromDocs)
            struct TestController {
                @GET(\(path))
                func list() -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                @GET(\(path))
                func list() -> Response {
                    Response(statusCode: 200)
                }
            }

            extension TestController {
                func boot(routes: RoutesBuilder) throws {
                    routes.on(.GET, \(path)) { request in
                        return self.list()
                    }
                }
            }
            """
        }
    }
}
