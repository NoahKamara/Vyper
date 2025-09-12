//
//  DocumentationTests.swift
//
//  Copyright © 2024 Noah Kamara.
//

import MacroTesting
import Testing
@testable import VyperMacros

@Suite("RouterMacro: Documentation", .macros([RouterMacro.self]), .tags(.macro))
struct DocumentationTests {
    @Test
    func excludedRouter() {
        assertMacro {
            """
            @Router(traits: .excludeFromDocs)
            struct TestController {
                /// Lorem ipsum dolor sit amet.
                @GET
                func list() -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                /// Lorem ipsum dolor sit amet.
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
    func excludedRoute() {
        assertMacro {
            """
            @Router
            struct TestController {
                /// Lorem ipsum dolor sit amet.
                @GET(traits: .excludeFromDocs)
                func list() -> Response {
                    Response(statusCode: 200)
                }
            
                /// Lorem ipsum dolor sit amet.
                @POST
                func create() -> Response {
                    Response(statusCode: 201)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                /// Lorem ipsum dolor sit amet.
                @GET(traits: .excludeFromDocs)
                func list() -> Response {
                    Response(statusCode: 200)
                }

                /// Lorem ipsum dolor sit amet.
                @POST
                func create() -> Response {
                    Response(statusCode: 201)
                }
            }

            extension TestController: RouteCollection {
                func boot(routes: any RoutesBuilder) throws {
                    routes.on(.GET) { request in
                        return self.list()
                    }
                    routes.on(.POST) { request in
                        return self.create()
                    }
                    .openAPI(
                        summary: "Lorem ipsum dolor sit amet.")
                }
            }
            """
        }
    }

    @Test
    func tags() {
        assertMacro {
            """
            @Router(traits: .tags(.abc, .def))
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
                    .openAPI(
                        tags: Tag.abc.tagObject,
                        Tag.def.tagObject)
                }
            }
            """
        }
    }

//    @Test
//    func inheritedTags() {
//        assertMacro {
//            """
//            @Router
//            struct TestController {
//                /// Lorem ipsum dolor sit amet.
//                @GET(traits: .excludeFromDocs)
//                func list() -> Response {
//                    Response(statusCode: 200)
//                }
//            
//                /// Lorem ipsum dolor sit amet.
//                @POST
//                func create() -> Response {
//                    Response(statusCode: 201)
//                }
//            }
//            """
//        } expansion: {
//            """
//            struct TestController {
//                /// Lorem ipsum dolor sit amet.
//                @GET(traits: .excludeFromDocs)
//                func list() -> Response {
//                    Response(statusCode: 200)
//                }
//            
//                /// Lorem ipsum dolor sit amet.
//                @POST
//                func create() -> Response {
//                    Response(statusCode: 201)
//                }
//            }
//            
//            extension TestController: RouteCollection {
//                func boot(routes: any RoutesBuilder) throws {
//                    routes.on(.GET) { request in
//                        return self.list()
//                    }
//                    routes.on(.POST) { request in
//                        return self.create()
//                    }
//                    .openAPI(
//                        summary: "Lorem ipsum dolor sit amet.")
//                }
//            }
//            """
//        }
//    }

    @Test
    func abstract() {
        assertMacro {
            """
            @Router
            struct TestController {
                /// Lorem ipsum dolor sit amet.
                @GET
                func list() -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                /// Lorem ipsum dolor sit amet.
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
                    .openAPI(
                        summary: "Lorem ipsum dolor sit amet.")
                }
            }
            """
        }
    }

    @Test
    func parameters() {
        assertMacro {
            """
            @Router
            struct TestController {
                /// - Parameters:
                ///     - path: path parameter.
                ///     - query: query parameter.
                ///     - cookie: cookie parameter.
                @GET
                func list(
                    @Path path: String,
                    @Query query: String,
                    @Cookie cookie: String?
                ) -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                /// - Parameters:
                ///     - path: path parameter.
                ///     - query: query parameter.
                ///     - cookie: cookie parameter.
                @GET
                func list(
                    @Path path: String,
                    @Query query: String,
                    @Cookie cookie: String?
                ) -> Response {
                    Response(statusCode: 200)
                }
            }

            extension TestController: RouteCollection {
                func boot(routes: any RoutesBuilder) throws {
                    routes.on(.GET) { request in
                        let path: String = try request.parameters.require("path")
                        let query: String = try request.query.get(at: "query")
                        let cookie: String? = request.cookies[name: "cookie"]
                        return self.list(path: path, query: query, cookie: cookie)
                    }
                    .openAPI(
                        query: .init(
                            .init(name: "query", in: .query, description: "query parameter.", required: true, schema: .string)),
                        path: .init(
                            .init(name: "path", in: .path, description: "path parameter.", required: true, schema: .string)),
                        cookies: .init(
                            .init(name: "cookie", in: .cookie, description: "cookie parameter.", schema: .string)))
                }
            }
            """
        }
    }

    @Test
    func body() {
        assertMacro {
            """
            @Router
            struct TestController {
                /// - Parameters foo: the foo object to create
                @POST
                func create(@Body foo: Foo) -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                /// - Parameters foo: the foo object to create
                @POST
                func create(@Body foo: Foo) -> Response {
                    Response(statusCode: 200)
                }
            }

            extension TestController: RouteCollection {
                func boot(routes: any RoutesBuilder) throws {
                    routes.on(.POST) { request in
                        let foo: Foo = try request.content.decode(Foo.self)
                        return self.create(foo: foo)
                    }
                    .openAPI(
                        body: .type(Foo.self),
                        contentType: Self
                        .responseContentType(for: Foo.self))
                }
            }
            """
        }
    }

    @Test
    func secondNameParameter() {
        assertMacro {
            """
            @Router
            struct TestController {
                /// - Parameters:
                ///     - secondName: path parameter.
                @GET
                func list(@Path path secondName: String) -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } expansion: {
            """
            struct TestController {
                /// - Parameters:
                ///     - secondName: path parameter.
                @GET
                func list(@Path path secondName: String) -> Response {
                    Response(statusCode: 200)
                }
            }

            extension TestController: RouteCollection {
                func boot(routes: any RoutesBuilder) throws {
                    routes.on(.GET) { request in
                        let path: String = try request.parameters.require("path")
                        return self.list(path: path)
                    }
                    .openAPI(
                        path: .init(
                            .init(name: "path", in: .path, description: "path parameter.", required: true, schema: .string)))
                }
            }
            """
        }
    }

//
//    @Test("Standalone Parameter")
//    func standaloneParameter() async throws {
//        let documentation = DocumentationMarkup(text: """
//        - Parameter parameterName: a parameter name
//        """)
//
//        assertInlineSnapshot(of: documentation, as: .json) {
//            """
//            {
//              "discussionSection" : [
//
//              ],
//              "discussionTags" : {
//                "parameters" : [
//                  {
//                    "contents" : [
//                      "a parameter name"
//                    ],
//                    "isStandalone" : true,
//                    "name" : "parameterName"
//                  }
//                ]
//              }
//            }
//            """
//        }
//    }
//
//    @Test("Standalone Parameter multiple")
//    func multipleStandaloneParameter() async throws {
//        let documentation = DocumentationMarkup(text: """
//        Lorem ipsum dolor sit amet.
//        - Parameter bar: describing bar parameter
//        - Parameter baz: describing baz parameter
//        """)
//
//        assertInlineSnapshot(of: documentation, as: .json) {
//            """
//            {
//              "abstractSection" : [
//                "Lorem ipsum dolor sit amet."
//              ],
//              "discussionSection" : [
//
//              ],
//              "discussionTags" : {
//                "parameters" : [
//                  {
//                    "contents" : [
//                      "describing bar parameter"
//                    ],
//                    "isStandalone" : true,
//                    "name" : "bar"
//                  },
//                  {
//                    "contents" : [
//                      "describing baz parameter"
//                    ],
//                    "isStandalone" : true,
//                    "name" : "baz"
//                  }
//                ]
//              }
//            }
//            """
//        }
//    }
//
//    @Test("Parameters Section")
//    func parameterSection() async throws {
//        let documentation = DocumentationMarkup(text: """
//        - Parameters:
//            - foo: a parameter name
//        """)
//
//        assertInlineSnapshot(of: documentation, as: .json) {
//            """
//            {
//              "discussionSection" : [
//
//              ],
//              "discussionTags" : {
//                "parameters" : [
//                  {
//                    "contents" : [
//                      "a parameter name"
//                    ],
//                    "isStandalone" : false,
//                    "name" : "foo"
//                  }
//                ]
//              }
//            }
//            """
//        }
//    }
//
//    @Test("Parameters Section multiple")
//    func multipleParameterSection() async throws {
//        let documentation = DocumentationMarkup(text: """
//        - Parameters:
//            - foo: a parameter name
//            - bar: a parameter name
//        """)
//
//        assertInlineSnapshot(of: documentation, as: .json) {
//            """
//            {
//              "discussionSection" : [
//
//              ],
//              "discussionTags" : {
//                "parameters" : [
//                  {
//                    "contents" : [
//                      "a parameter name"
//                    ],
//                    "isStandalone" : false,
//                    "name" : "foo"
//                  },
//                  {
//                    "contents" : [
//                      "a parameter name"
//                    ],
//                    "isStandalone" : false,
//                    "name" : "bar"
//                  }
//                ]
//              }
//            }
//            """
//        }
//    }
//
//    @Test("Throws")
//    func throwsDescription() async throws {
//        let documentation = DocumentationMarkup(text: """
//
//        - Throws: some error
//        """)
//
//        assertInlineSnapshot(of: documentation, as: .json) {
//            """
//            {
//              "discussionSection" : [
//
//              ],
//              "discussionTags" : {
//                "throws" : [
//                  [
//                    "some error"
//                  ]
//                ]
//              }
//            }
//            """
//        }
//    }
//
//    @Test("Throws multiple")
//    func multipleThrowsDescription() async throws {
//        let documentation = DocumentationMarkup(text: """
//
//        - Throws: some error
//        - Throws: some other error
//        """)
//
//        assertInlineSnapshot(of: documentation, as: .json) {
//            """
//            {
//              "discussionSection" : [
//
//              ],
//              "discussionTags" : {
//                "throws" : [
//                  [
//                    "some error"
//                  ],
//                  [
//                    "some other error"
//                  ]
//                ]
//              }
//            }
//            """
//        }
//    }
//
//    @Test("Returns")
//    func returnsStatement() async throws {
//        let documentation = DocumentationMarkup(text: """
//        - Returns: some return type
//        """)
//
//        assertInlineSnapshot(of: documentation, as: .json) {
//            """
//            {
//              "discussionSection" : [
//
//              ],
//              "discussionTags" : {
//                "returns" : [
//                  [
//                    "some return type"
//                  ]
//                ]
//              }
//            }
//            """
//        }
//    }
//
//    @Test("Returns multiple")
//    func multipleReturnsStatement() async throws {
//        let documentation = DocumentationMarkup(text: """
//        - Returns: some return type
//        some more text?
//        - Returns: some other return type
//        """)
//
//        assertInlineSnapshot(of: documentation, as: .json) {
//            #"""
//            {
//              "discussionSection" : [
//
//              ],
//              "discussionTags" : {
//                "returns" : [
//                  [
//                    "some return type\nsome more text?"
//                  ],
//                  [
//                    "some other return type"
//                  ]
//                ]
//              }
//            }
//            """#
//        }
//    }
}
