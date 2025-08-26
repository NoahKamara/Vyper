//
//  CustomTypesExample.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import Vapor
import Vyper

// Custom types that users might define
struct Todo: Content {
    let id: String
    let title: String
    let isCompleted: Bool
    let createdAt: Date
}

struct User: Content {
    let id: String
    let name: String
    let email: String
}

struct SearchFilters: Content {
    let query: String
    let category: String?
    let sortBy: String
}

// Your macro should parse these and generate appropriate OpenAPI schemas
//@API
struct CustomTypesController {
    let allTodos = [
        Todo(id: "1", title: "Procrastinate", isCompleted: true, createdAt: .distantPast),
        Todo(id: "2", title: "Build Vypre", isCompleted: false, createdAt: .now),
    ]

    @GET
    func todos() -> [Todo] {
        return self.allTodos
    }

    @GET(":todoId")
    func retrieve(@Path todoId: String) throws -> Todo {
        if let todo = allTodos.first(where: { $0.id == todoId }) {
            todo
        } else {
            throw Abort(.notFound)
        }
    }

    @GET("search")
    func search(@Query filters: SearchFilters) async throws -> [Todo] {
        allTodos.filter({ $0.title.localizedStandardContains(filters.query) })
    }
}
