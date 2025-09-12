//
//  main.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Vapor
import VaporToOpenAPI
import Vyper

//
// actor TodoStore: GlobalActor {
//    static let shared = TodoStore()
//
//    private var todos: [Todo] = [
//        Todo(title: "Procrastinate", isChecked: true),
//        Todo(title: "Build Vyper", isChecked: false),
//    ]
//
//    func addTodo(_ todo: Todo) {
//        self.todos.append(todo)
//    }
//
//    func allTodos() -> [TodoDto] {
//        self.todos.enumerated().map { $0.element.toDto(id: $0.offset) }
//    }
//
//    func todo(id: Int) -> TodoDto? {
//        guard id >= 0, id < self.todos.count else { return nil }
//        return self.todos[id].toDto(id: id)
//    }
// }
//
// struct Todo: Codable {
//    let title: String
//    let isChecked: Bool
//
//    func toDto(id: Int) -> TodoDto {
//        TodoDto(id: id, title: self.title, isChecked: self.isChecked)
//    }
// }
//
// struct TodoDto: Codable, Content {
//    let id: Int
//    let title: String
//    let isChecked: Bool
// }
//
// struct ABCController: RouteCollection {
//    func boot(routes: any RoutesBuilder) {
//        routes.on(.ACL, "abc", "def") { request in
//            let string = try request.parameters.require("string")
//            let int = try request.parameters.require("int", as: Int.self)
//            return Response()
//        }
////        .openAPI(path: .type(String.self))
////        .openAPI(custom: \.) {
////            <#code#>
////        }
////        ParameterObject(
////            name: "",
////            in: .path,
////            description: <#T##String?#>,
////            required: <#T##Bool?#>,
////            deprecated: <#T##Bool?#>,
////            allowEmptyValue: <#T##Bool?#>,
////            style: <#T##ParameterObject.Style?#>,
////            explode: <#T##Bool?#>,
////            allowReserved: <#T##Bool?#>,
////            schema: ReferenceOr<SchemaObject>.decodeSchema(<#T##type: any Decodable.Type##any
/// Decodable.Type#>, into: &<#T##ComponentsMap<SchemaObject>#>),
////            example: <#T##AnyValue?#>,
////            examples: <#T##ComponentsMap<ExampleObject>?#>,
////            content: <#T##ContentObject?#>
////        )
////        .openAPI(custom: \.parameters, [])
//        //        .openAPI(
////            custom: \.parameters,
////            [
////                ParameterObject(
////                    name: <#T##String#>,
////                    in: .path,
////                    description: <#T##String?#>,
////                    required: <#T##Bool?#>,
////                    deprecated: <#T##Bool?#>,
////                    allowEmptyValue: <#T##Bool?#>,
////                    style: <#T##ParameterObject.Style?#>,
////                    explode: <#T##Bool?#>,
////                    allowReserved: <#T##Bool?#>,
////                    schema: .value(.init(schemaObject: .t)),
////                    example: .ty,
////                    examples: <#T##ComponentsMap<ExampleObject>?#>,
////                    content: .some(.)
////                )
////            ]
////        )
////        .openAPI(
////            summary: <#T##String?#>,
////            description: <#T##String#>,
////            query: <#T##OpenAPIParameters?#>,
////            path: [
////                "name": OpenAPIParameters.Value.value(.string),
////            ]
////        )
//    }
//
//    @Sendable
//    func list() async -> [TodoDto] {
//        let store = TodoStore()
//        return await store.allTodos()
//    }
// }
// Route().openAPI(custom: \.responses, [
//    .default: ReferenceOr<ResponseObject>.value(.init(
//        description: <#T##String#>,
//        headers: <#T##ComponentsMap<HeaderObject>?#>,
//        content: <#T##ContentObject?#>,
//        links: <#T##ComponentsMap<LinkObject>?#>
//    ))
// ])
//
// Route().response(body: <#T##OpenAPIBody?#>, contentType: <#T##MediaType...##MediaType#>)
//    .openAPI(
//        customMethod: <#T##PathItemObject.Method?#>,
//        spec: <#T##String?#>,
//        tags: <#T##TagObject...##TagObject#>,
//        summary: <#T##String?#>,
//        description: <#T##String#>,
//        operationId: <#T##String?#>,
//        externalDocs: <#T##ExternalDocumentationObject?#>,
//        query: <#T##OpenAPIParameters?#>,
//        headers: <#T##OpenAPIParameters?#>,
//        path: <#T##OpenAPIParameters?#>,
//        cookies: <#T##OpenAPIParameters?#>,
//        body: <#T##OpenAPIBody?#>,
//        contentType: <#T##MediaType...##MediaType#>,
//        response: <#T##OpenAPIBody?#>,
//        responseContentType: <#T##MediaType...##MediaType#>,
//        responseHeaders: <#T##OpenAPIParameters?#>,
//        responseDescription: <#T##String?#>,
//        statusCode: <#T##ResponsesObject.Key#>,
//        links: <#T##[Link : any LinkKey.Type]#>,
//        callbacks: <#T##[String : ReferenceOr<CallbackObject>]?#>,
//        deprecated: <#T##Bool?#>,
//        auth: <#T##AuthSchemeObject...##AuthSchemeObject#>,
//        servers: <#T##[ServerObject]?#>,
//        extensions: <#T##SpecificationExtensions#>
//    )

// @Router
// struct TestController {
////    let store = TodoStore()
//
//    //    @HTTP(.GET, .anything)
//    //    func list() async -> [TodoDto] {
//    //        await self.store.allTodos()
//    //    }
//
//    @GET(":todoID")
//    func retrieve(@Path todoID id: Int) async throws -> TodoDto {
//        if let todo = await self.store.todo(id: id) {
//            return todo
//        } else {
//            throw Abort(.notFound)
//        }
//    }
//
//    //    @GET
//    //    func index() -> [Todo]
// }
