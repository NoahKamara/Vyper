//
//  main.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Vapor
import Vyper

actor TodoStore: GlobalActor {
    static let shared = TodoStore()

    private var todos: [Todo] = [
        Todo(title: "Procrastinate", isChecked: true),
        Todo(title: "Build Vyper", isChecked: false),
    ]

    func addTodo(_ todo: Todo) {
        self.todos.append(todo)
    }

    func allTodos() -> [TodoDto] {
        self.todos.enumerated().map { $0.element.toDto(id: $0.offset) }
    }

    func todo(id: Int) -> TodoDto? {
        guard id >= 0, id < self.todos.count else { return nil }
        return self.todos[id].toDto(id: id)
    }
}

struct Todo: Codable {
    let title: String
    let isChecked: Bool

    func toDto(id: Int) -> TodoDto {
        TodoDto(id: id, title: self.title, isChecked: self.isChecked)
    }
}

struct TodoDto: Codable, Content {
    let id: Int
    let title: String
    let isChecked: Bool
}

// struct ABCController: RouteCollection {
//    func boot(routes: RoutesBuilder) {
//        routes.on(.ACL, "abc", "def") { request in
//            let string = try request.parameters.require("string")
//            let int = try request.parameters.require("int", as: Int.self)
//            await self.list()
//        }
//    }
//
//    @Sendable
//    func list() async -> [TodoDto] {
//        let store = TodoStore()
//        return await store.allTodos()
//    }
// }

//@API
//struct TestController {
//    let store = TodoStore()
//
////    @HTTP(.GET, .anything)
////    func list() async -> [TodoDto] {
////        await self.store.allTodos()
////    }
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
////    @GET
////    func index() -> [Todo]
//}
