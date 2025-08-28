//
//  API.swift
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftSyntax

struct API {
//        /// Attributes to be applied to this endpoint. These take precedence
//        /// over attributes at the API scope.
//        let attributes: [EndpointAttribute]
//        let pathParameters: [String]
//        /// The name of the function defining this endpoint.
//        let name: String
//        let parameters: [EndpointParameter]
//        let responseType: String?
//    /// The name of the protocol defining the API.
//    let name: String
//    /// The access level of the API (public, internal, etc).
//    let access: String?
//    /// Attributes to be applied to every endpoint of this API.
    ////    let attributes: [EndpointAttribute]
//
    var name: String
    let routes: [APIRoute]

    package init(name: String, routes: [APIRoute]) {
        self.name = name
        self.routes = routes
    }
}

struct APIRoute: CustomStringConvertible {
    struct Parameter: CustomStringConvertible {
        let name: String
        let secondName: String?
        let type: String
        let isOptional: Bool
        let kind: Kind

        var description: String {
            "\(name): \(type)\(isOptional ? "?" : "") (\(kind))"
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
            case field
            case body([ExprSyntax]?)
            case passthrough(ExprSyntax?)

            var rawLocation: String? {
                switch self {
                case .path: "path"
                case .header: "header"
                case .query: "query"
                case .field: "field"
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
          name: '\(name)'
          method: '\(method.trimmedDescription)'
          path: \(path.map({ $0.trimmedDescription }).joined(separator: ", "))
          isThrowing: '\(isThrowing)'
          isAsync: '\(isAsync)'
          parameters: 
            \(parameters.map({ "- "+$0.description }).joined(separator: "\n    "))
          returnType: '\(returnType ?? "Void")'
        )
        """
    }

    init(
        name: String,
        method: ExprSyntax,
        path: [ExprSyntax],
        isThrowing: Bool,
        isAsync: Bool,
        parameters: [APIRoute.Parameter],
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

