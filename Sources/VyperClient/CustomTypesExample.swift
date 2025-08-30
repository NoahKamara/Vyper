//
//  CustomTypesExample.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import Vapor
import Vyper

/// A todo item with basic properties for task management
struct Todo: Content {
    /// Unique identifier for the todo item
    let id: Int
    /// The title or description of the todo task
    let title: String
    /// Whether the todo task has been completed
    let isCompleted: Bool
    /// When the todo item was created
    let createdAt: Date

    /// Data structure for creating new todo items
    struct Create: Content {
        /// The title or description of the todo task
        let title: String
        /// Whether the todo task has been completed
        let isCompleted: Bool
        /// When the todo item was created
        let createdAt: Date
    }
}

/// A user in the system
struct User: Content {
    /// Unique identifier for the user
    let id: String
    /// Display name of the user
    let name: String
    /// Email address of the user
    let email: String
}

/// Search filters for querying todos
struct SearchFilters: Content {
    /// Text query to search for in todo titles
    let query: String
    /// Optional category filter for todos
    let category: String?
    /// Field to sort results by
    let sortBy: String
}

import VaporToOpenAPI

// Your macro should parse these and generate appropriate OpenAPI schemas

/// Example controller demonstrating Vyper's custom types and API annotations
@API
struct CustomTypesController {
    /// In-memory storage for todos (for demonstration purposes)
    @MainActor
    var allTodos = [
        Todo(id: 0, title: "Procrastinate", isCompleted: true, createdAt: .distantPast),
        Todo(id: 1, title: "Build Vypre", isCompleted: false, createdAt: .now),
    ]

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
    /// - Parameter id: The unique identifier of the todo to update
    /// - Parameter body: The updated data for the todo
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
