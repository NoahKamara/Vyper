//
//  API.swift
//  Vyper
//
//  Created by Noah Kamara on 23.08.2025.
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
    let routes: [Route]
}

extension API {
    struct Route {
        init(
            name: String,
            method: ExprSyntax,
            path: [ExprSyntax],
            parameters: [API.Route.Parameter],
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

        struct Parameter {
            let name: String
            let type: String
            let isOptional: Bool
            let kind: Kind

            enum Kind {
                case path
                case header
                case query
                case field
                case body
            }
        }

        let name: String
        let method: ExprSyntax
        let path: [ExprSyntax]
        let parameters: [Parameter]
        let isThrowing: Bool
        let isAsync: Bool
    }
}

extension API {
    static func parse(_ declaration: some DeclSyntaxProtocol) throws -> API {
        try APIParser.parse(declaration)
    }
}

