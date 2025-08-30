//
//  HTTPMethodDecoratorTests 2.swift
//  Vyper
//
//  Created by Noah Kamara on 23.08.2025.
//



import MacroTesting
import Testing
@testable import VyperMacros

@Suite("APIMacro: Documentation", .macros([APIMacro.self], record: true), .tags(.macro))
struct DocumentationTests {
    @Test
    func abstract() {
        assertMacro {
            """
            @API
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
                func boot(routes: RoutesBuilder) throws {
                    routes.on(.GET) { request in
                        return self.list()
                    }
                    .openAPI(summary: "Lorem ipsum dolor sit amet.")
                }
            }
            """
        }
    }

    @Test
    func parameters() {
        assertMacro {
            """
            @API
            struct TestController {
                /// - Parameters:
                ///     - path: path parameter.
                ///     - query: query parameter.
                @GET
                func list(
                    @Path path: String,
                    @Query query: String,
                    @Cookie cookie: String
                ) -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } diagnostics: {
            """
            @API
            ┬───
            ╰─ 🛑 Cookie parameters must be optional
            struct TestController {
                /// - Parameters:
                ///     - path: path parameter.
                ///     - query: query parameter.
                @GET
                func list(
                    @Path path: String,
                    @Query query: String,
                    @Cookie cookie: String
                ) -> Response {
                    Response(statusCode: 200)
                }
            }
            """
        } 
    }

    @Test
    func body() {
        assertMacro {
            """
            @API
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
                func boot(routes: RoutesBuilder) throws {
                    routes.on(.POST) { request in
                        let foo: Foo = try request.content.decode(Foo.self)
                        return self.create(foo: foo)
                    }
                    .openAPI(body: .type(Foo.self), contentType: Self
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
            @API
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
                func boot(routes: RoutesBuilder) throws {
                    routes.on(.GET) { request in
                        let path: String = try request.parameters.require("path")
                        return self.list(path: path)
                    }
                    .openAPI(path: [
                        .init(name: "path", in: .path, description: "path parameter.", required: true, schema: .string)
                        ])
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
