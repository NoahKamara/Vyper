//
//  ExampleTest.swift
//
//  Copyright © 2024 Noah Kamara.
//

import MacroTesting
import Testing
@testable import VyperMacros

@Test("Example Test", .macros([RouterMacro.self]), .tags(.macro))
func exampleTest() async throws {
    assertMacro {
        """
        /// Example controller demonstrating Vyper's custom types and API annotations
        @Router
        struct ExampleRoutes {
            /// Retrieves all todos
            /// - Returns: An array of all todo items
            @GET
            func todos() -> [Todo] {
                [
                    Todo(id: 0, title: "Procrastinate", isCompleted: true, createdAt: .distantPast),
                    Todo(id: 1, title: "Build Vypre", isCompleted: false, createdAt: .now),
                ]
            }

            /// Retrieves a specific todo by its ID
            /// - Parameter id: The unique identifier of the todo to retrieve
            /// - Returns: The todo item with the specified ID
            /// - Throws: An error if the todo is not found
            @GET(":todoId")
            func retrieve(@Path todoId id: Int) throws -> Todo {
                Todo(id: id, title: "Procrastinate", isCompleted: true, createdAt: .distantPast)
            }

            /// Searches for todos based on provided filters
            /// - Parameter filters: Search criteria including query, category, and sort options
            /// - Returns: An array of todos matching the search criteria
            /// - Throws: An error if the search operation fails
            @GET("search")
            func search(@Query filters: SearchFilters) async throws -> [Todo] {
                [
                    Todo(id: 0, title: "Procrastinate", isCompleted: true, createdAt: .distantPast),
                    Todo(id: 1, title: "Build Vypre", isCompleted: false, createdAt: .now),
                ]
            }

            /// Creates a new todo item
            /// - Parameter body: The data for creating the new todo
            /// - Returns: The newly created todo item
            /// - Throws: An error if creation fails
            @POST
            func create(@Body body: Todo.Create) throws -> Todo {
                Todo(id: 0, title: body.title, isCompleted: body.isCompleted, createdAt: body.createdAt)
            }

            /// Updates an existing todo item
            /// - Parameters:
            ///     - id: The unique identifier of the todo to update
            ///     - body: The updated data for the todo
            /// - Returns: The updated todo item
            /// - Throws: An error if the update operation fails
            @PATCH(":todoId")
            func create(@Path todoId id: Int, @Body body: Todo.Create) throws -> Todo {
                Todo(
                    id: todoId,
                    title: body.title,
                    isCompleted: body.isCompleted,
                    createdAt: body.createdAt
                )
            }
        }
        """
    } expansion: {
        """
        /// Example controller demonstrating Vyper's custom types and API annotations
        struct ExampleRoutes {
            /// Retrieves all todos
            /// - Returns: An array of all todo items
            @GET
            func todos() -> [Todo] {
                [
                    Todo(id: 0, title: "Procrastinate", isCompleted: true, createdAt: .distantPast),
                    Todo(id: 1, title: "Build Vypre", isCompleted: false, createdAt: .now),
                ]
            }

            /// Retrieves a specific todo by its ID
            /// - Parameter id: The unique identifier of the todo to retrieve
            /// - Returns: The todo item with the specified ID
            /// - Throws: An error if the todo is not found
            @GET(":todoId")
            func retrieve(@Path todoId id: Int) throws -> Todo {
                Todo(id: id, title: "Procrastinate", isCompleted: true, createdAt: .distantPast)
            }

            /// Searches for todos based on provided filters
            /// - Parameter filters: Search criteria including query, category, and sort options
            /// - Returns: An array of todos matching the search criteria
            /// - Throws: An error if the search operation fails
            @GET("search")
            func search(@Query filters: SearchFilters) async throws -> [Todo] {
                [
                    Todo(id: 0, title: "Procrastinate", isCompleted: true, createdAt: .distantPast),
                    Todo(id: 1, title: "Build Vypre", isCompleted: false, createdAt: .now),
                ]
            }

            /// Creates a new todo item
            /// - Parameter body: The data for creating the new todo
            /// - Returns: The newly created todo item
            /// - Throws: An error if creation fails
            @POST
            func create(@Body body: Todo.Create) throws -> Todo {
                Todo(id: 0, title: body.title, isCompleted: body.isCompleted, createdAt: body.createdAt)
            }

            /// Updates an existing todo item
            /// - Parameters:
            ///     - id: The unique identifier of the todo to update
            ///     - body: The updated data for the todo
            /// - Returns: The updated todo item
            /// - Throws: An error if the update operation fails
            @PATCH(":todoId")
            func create(@Path todoId id: Int, @Body body: Todo.Create) throws -> Todo {
                Todo(
                    id: todoId,
                    title: body.title,
                    isCompleted: body.isCompleted,
                    createdAt: body.createdAt
                )
            }
        }

        extension ExampleRoutes: RouteCollection {
            func boot(routes: any RoutesBuilder) throws {
                routes.on(.GET) { request in
                    return self.todos()
                }
                .openAPI(
                    summary: "Retrieves all todos",
                    response: .type([Todo].self),
                    responseContentType: Self
                    .responseContentType(for: [Todo].self),
                    responseDescription: "An array of all todo items")
                routes.on(.GET, ":todoId") { request in
                    let todoId: Int = try request.parameters.require("todoId")
                    return try self.retrieve(todoId: todoId)
                }
                .openAPI(
                    summary: "Retrieves a specific todo by its ID",
                    path: .init(
                        .init(name: "todoId", in: .path, description: "The unique identifier of the todo to retrieve", required: true, schema: .integer)),
                    response: .type(Todo.self),
                    responseContentType: Self
                    .responseContentType(for: Todo.self),
                    responseDescription: "The todo item with the specified ID")
                routes.on(.GET, "search") { request in
                    let filters: SearchFilters = try request.query.get(at: "filters")
                    return try await self.search(filters: filters)
                }
                .openAPI(
                    summary: "Searches for todos based on provided filters",
                    query: .init(
                        .init(name: "filters", in: .query, description: "Search criteria including query, category, and sort options", required: true, schema: .ref("#/components/schemas/SearchFilters"))),
                    response: .type([Todo].self),
                    responseContentType: Self
                    .responseContentType(for: [Todo].self),
                    responseDescription: "An array of todos matching the search criteria")
                routes.on(.POST) { request in
                    let body: Todo.Create = try request.content.decode(Todo.Create.self)
                    return try self.create(body: body)
                }
                .openAPI(
                    summary: "Creates a new todo item",
                    body: .type(Todo.Create.self),
                    contentType: Self
                    .responseContentType(for: Todo.Create.self),
                    response: .type(Todo.self),
                    responseContentType: Self
                    .responseContentType(for: Todo.self),
                    responseDescription: "The newly created todo item")
                routes.on(.PATCH, ":todoId") { request in
                    let todoId: Int = try request.parameters.require("todoId")
                    let body: Todo.Create = try request.content.decode(Todo.Create.self)
                    return try self.create(todoId: todoId, body: body)
                }
                .openAPI(
                    summary: "Updates an existing todo item",
                    path: .init(
                        .init(name: "todoId", in: .path, description: "The unique identifier of the todo to update", required: true, schema: .integer)),
                    body: .type(Todo.Create.self),
                    contentType: Self
                    .responseContentType(for: Todo.Create.self),
                    response: .type(Todo.self),
                    responseContentType: Self
                    .responseContentType(for: Todo.self),
                    responseDescription: "The updated todo item")
            }
        }
        """
    }
}
