//
//  RoutingOptionTests.swift
//
//  Copyright © 2024 Noah Kamara.
//

import MacroTesting
import Testing
@testable import VyperMacros

@Suite("RouterMacro: Options", .macros([RouterMacro.self]), .tags(.macro))
struct RoutingOptionTests {
//    @Test
//    func routeTags() {
//        assertMacro(record: true) {
//            """
//            @Router(traits: .excludeFromDocs)
//            struct TestController {
//                /// Lorem ipsum dolor sit amet.
//                @GET
//                func list() -> Response {}
//            }
//            """
//        } expansion: {
//            """
//            struct TestController {
//                /// Lorem ipsum dolor sit amet.
//                @GET
//                func list() -> Response {}
//            }
//            
//            extension TestController: RouteCollection {
//                func boot(routes: any RoutesBuilder) throws {
//                    routes.on(.GET) { request in
//                        return self.list()
//                    }
//                }
//            }
//            """
//        }
//
//        assertMacro {
//            """
//            @Router
//            struct TestController {
//                /// Lorem ipsum dolor sit amet.
//                @GET
//                func list() {}
//            }
//            """
//        } expansion: {
//            """
//            struct TestController {
//                /// Lorem ipsum dolor sit amet.
//                @GET
//                func list() {}
//            }
//            
//            extension TestController: RouteCollection {
//                func boot(routes: any RoutesBuilder) throws {
//                    routes.on(.GET) { request in
//                        return self.list()
//                    }
//                    .openAPI(
//                        summary: "Lorem ipsum dolor sit amet.")
//                }
//            }
//            """
//        }
//    }
//
//    @Test
//    func routerTags() {
//        assertMacro(record: true) {
//            """
//            @Router(traits: .excludeFromDocs)
//            struct TestController {
//                /// Lorem ipsum dolor sit amet.
//                @GET
//                func list() -> Response {}
//            }
//            """
//        } expansion: {
//            """
//            struct TestController {
//                /// Lorem ipsum dolor sit amet.
//                @GET
//                func list() -> Response {}
//            }
//            
//            extension TestController: RouteCollection {
//                func boot(routes: any RoutesBuilder) throws {
//                    routes.on(.GET) { request in
//                        return self.list()
//                    }
//                }
//            }
//            """
//        }
//
//        assertMacro {
//            """
//            @Router
//            struct TestController {
//                /// Lorem ipsum dolor sit amet.
//                @GET
//                func list() {}
//            }
//            """
//        } expansion: {
//            """
//            struct TestController {
//                /// Lorem ipsum dolor sit amet.
//                @GET
//                func list() {}
//            }
//            
//            extension TestController: RouteCollection {
//                func boot(routes: any RoutesBuilder) throws {
//                    routes.on(.GET) { request in
//                        return self.list()
//                    }
//                    .openAPI(
//                        summary: "Lorem ipsum dolor sit amet.")
//                }
//            }
//            """
//        }
//    }

    @Test
    func prefixPath() {
        assertMacro {
            """
            @Router("prefix")
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
                func boot(routes: any RoutesBuilder) throws {
                    routes.on(.GET, "prefix", "route") { request in
                        return self.list()
                    }
                }
            }
            """
        }
    }
}
