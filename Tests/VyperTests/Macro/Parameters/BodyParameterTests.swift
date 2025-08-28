//
//  QueryParameterTests.swift
//
//  Copyright © 2024 Noah Kamara.
//

import MacroTesting
import Testing
@testable import VyperMacros

@Suite("APIMacro: Body Parameter", .macros([APIMacro.self]), .tags(.macro))
struct BodyParameterTests {
    @Test
    func fullBody() {
        assertMacro {
            """
            @API(traits: .excludeFromDocs)
            struct TestController {
                @GET
                func list(@Body foo: Foo) {}
            }
            """
        } expansion: {
            """
            struct TestController {
                @GET
                func list(@Body foo: Foo) {}
            }

            extension TestController: RouteCollection {
                func boot(routes: RoutesBuilder) throws {
                    routes.on(.GET) { request in
                        let foo: Foo = request.content.decode(Foo.self)
                        return self.list(foo: foo)
                    }
                }
            }
            """
        }
    }

    @Test
    func bodyKeyPath() {
        assertMacro {
            """
            @API(traits: .excludeFromDocs)
            struct TestController {
                @GET
                func list(@Body("foo") foo: Foo, @Body("bar") bar: String) {}
            }
            """
        } expansion: {
            """
            struct TestController {
                @GET
                func list(@Body("foo") foo: Foo, @Body("bar") bar: String) {}
            }

            extension TestController: RouteCollection {
                func boot(routes: RoutesBuilder) throws {
                    routes.on(.GET) { request in
                        let foo: Foo = request.content.get(at: "foo")
                        let bar: String = request.content.get(at: "bar")
                        return self.list(foo: foo, bar: bar)
                    }
                }
            }
            """
        }
    }
}
