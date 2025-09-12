//
//  Models.swift
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftSyntax

struct RouteDescriptor: CustomStringConvertible {
    struct Parameter: CustomStringConvertible {
        let name: String
        let secondName: String?
        let type: String
        let isOptional: Bool
        let kind: Kind

        var description: String {
            "\(self.name): \(self.type)\(self.isOptional ? "?" : "") (\(self.kind))"
        }

        package init(
            name: String,
            secondName: String?,
            type: String,
            isOptional: Bool,
            kind: Kind
        ) {
            self.name = name
            self.secondName = secondName
            self.type = type
            self.isOptional = isOptional
            self.kind = kind
        }

        enum Kind: Sendable, Equatable {
            case path
            case header
            case query
            case cookie
            case body
            case passthrough(ExprSyntax?)

            var isParameter: Bool {
                switch self {
                case .path, .header, .query, .cookie: true
                case .body, .passthrough: false
                }
            }

            var rawLocation: String? {
                switch self {
                case .path: "path"
                case .header: "header"
                case .query: "query"
                case .cookie: "cookie"
                case .body: "body"
                case .passthrough: nil
                }
            }
        }
    }

    let name: String
    let method: ExprSyntax
    let path: [ExprSyntax]
    let isThrowing: Bool
    let isAsync: Bool
    let parameters: [Parameter]
    let markup: DocumentationMarkup
    let returnType: String?

    var description: String {
        """
        APIRoute(
          name: '\(self.name)'
          method: '\(self.method.trimmedDescription)'
          path: \(self.path.map(\.trimmedDescription).joined(separator: ", "))
          isThrowing: '\(self.isThrowing)'
          isAsync: '\(self.isAsync)'
          parameters: 
            \(self.parameters.map { "- " + $0.description }.joined(separator: "\n    "))
          returnType: '\(self.returnType ?? "Void")'
        )
        """
    }

    init(
        name: String,
        method: ExprSyntax,
        path: [ExprSyntax],
        isThrowing: Bool,
        isAsync: Bool,
        parameters: [RouteDescriptor.Parameter],
        markup: DocumentationMarkup,
        returnType: String?
    ) {
        self.name = name
        self.method = method
        self.path = path
        self.isThrowing = isThrowing
        self.isAsync = isAsync
        self.parameters = parameters
        self.markup = markup
        self.returnType = returnType
    }
}


