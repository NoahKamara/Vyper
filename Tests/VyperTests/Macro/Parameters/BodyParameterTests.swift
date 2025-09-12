//
//  BodyParameterTests.swift
//
//  Copyright © 2024 Noah Kamara.
//

import MacroTesting
import Testing
@testable import VyperMacros

@Suite("RouterMacro: Body Parameter", .macros([RouterMacro.self]), .tags(.macro))
struct BodyParameterTests {
    @Test
    func fullBody() {
        assertMacro {
            """
            @Router(traits: .excludeFromDocs)
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
                func boot(routes: any RoutesBuilder) throws {
                    routes.on(.GET) { request in
                        let foo: Foo = try request.content.decode(Foo.self)
                        return self.list(foo: foo)
                    }
                }
            }
            """
        }
    }
}
