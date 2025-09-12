////
////  OpenAPIExample.swift
////
////  Copyright © 2024 Noah Kamara.
////
//
//import Vapor
//import VaporToOpenAPI
//
//// This is how your macro should generate the OpenAPI syntax
//// The macro should parse the @OpenAPI(path: .type(String.self)) decorator
//// and generate the appropriate OpenAPI parameter specifications
//
//struct ExampleController: RouteCollection {
//    func boot(routes: any RoutesBuilder) {
//        // Your macro should generate this:
//        routes.on(.GET, "todos", ":id") { request in
//            let id = try request.parameters.require("id", as: String.self)
//            return Response()
//        }
//        .openAPI(
//            summary: "Get todo by ID",
//            description: "Retrieve a specific todo using its unique identifier"
//        )
//        .openAPI(custom: \.parameters, [
//            ParameterObject(
//                name: "id",
//                in: .path,
//                required: true,
//                schema: SchemaObject.string
//            ),
//        ])
//
//        // For the syntax you want: .openAPI(path: .type(String.self))
//        // Your macro should parse this and generate:
//        routes.on(.GET, "search", ":query") { request in
//            let query = try request.parameters.require("query", as: String.self)
//            let page = request.query["page"] ?? "1"
//            return Response()
//        }
//        .openAPI(
//            summary: "Search todos",
//            description: "Search todos with pagination"
//        )
//        .openAPI(custom: \.parameters, [
//            ParameterObject(
//                name: "query",
//                in: .path,
//                required: true,
//                schema: SchemaObject.string
//            ),
//            ParameterObject(
//                name: "page",
//                in: .query,
//                required: false,
//                schema: SchemaObject.string
//            ),
//        ])
//    }
//}
//
//// The macro should parse decorators like this:
//// @OpenAPI(path: .type(String.self))
//// @OpenAPI(query: .type(Int.self))
//// @OpenAPI(header: .type(String.self))
//
//// And generate the appropriate OpenAPI parameter specifications
//// while maintaining Swift type safety
