//
//  API.swift
//  Vyper
//
//  Created by Noah Kamara on 23.08.2025.
//

import SwiftSyntax

public struct API {
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
    public var name: String
    public let routes: [APIRoute]

    package init(name: String, routes: [APIRoute]) {
        self.name = name
        self.routes = routes
    }
}


public struct APIRoute {
    public struct Parameter {
        public let name: String
        public let type: String
        public let isOptional: Bool
        public let kind: Kind

        package init(name: String, type: String, isOptional: Bool, kind: Kind) {
            self.name = name
            self.type = type
            self.isOptional = isOptional
            self.kind = kind
        }

        public enum Kind {
            case path
            case header
            case query
            case field
            case body
        }
    }

    public let name: String
    public let method: ExprSyntax
    public let path: [ExprSyntax]
    public let parameters: [Parameter]
    public let isThrowing: Bool
    public let isAsync: Bool

    package init(
        name: String,
        method: ExprSyntax,
        path: [ExprSyntax],
        parameters: [APIRoute.Parameter],
        isThrowing: Bool,
        isAsync: Bool
    ) {
        self.name = name
        self.method = method
        self.path = path
        self.parameters = parameters
        self.isThrowing = isThrowing
        self.isAsync = isAsync
    }
}
