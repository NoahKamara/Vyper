//
//  APIParser.swift
//  Vyper
//
//  Created by Noah Kamara on 23.08.2025.
//

import SwiftSyntax
import VyperCore

enum APIParser {
    static func parse(_ declaration: some DeclSyntaxProtocol) throws -> API {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw VyperMacrosError("APIs must be structs for now")
        }

        return try API(
            name: structDecl.name.text,
            routes: structDecl.functions.compactMap { try parseFunction($0) }
            //            access: proto.access,
            //            attributes: proto.protocolAttributes.compactMap { EndpointAttribute($0) },
            //            endpoints: try proto.functions.map( { try parse($0) })
        )
    }

    private static func parseFunction(_ function: FunctionDeclSyntax) throws -> APIRoute? {
        var method: ExprSyntax? = nil
        var path: [ExprSyntax] = []
        


        for attribute in function.functionAttributes {
            let name = attribute.attributeName.trimmedDescription
            switch name {
            case "GET", "DELETE", "PATCH", "POST", "PUT", "OPTIONS", "HEAD", "TRACE", "CONNECT":
                method = ".\(raw: name)"
                if case .argumentList(let list) = attribute.arguments {
                    path = list.map(\.expression)
                }

            case "HTTP":
                if case .argumentList(let list) = attribute.arguments {
                    method = list.first?.expression
                    path = list.dropFirst().map(\.expression)
                } else {
                    throw VyperMacrosError("Missing method argument for @HTTP")
                }

            default:
                continue
            }
        }

        guard let method else {
            return nil
        }

        return .init(
            name: function.name.text,
            method: method,
            path: path,
            parameters: try function.parameters.map({ try parseRouteParameter($0) }),
            isThrowing: function.isThrowing,
            isAsync: function.isAsync
        )
    }

    private static func parseRouteParameter(
        _ parameter: FunctionParameterSyntax
    ) throws -> APIRoute.Parameter {
        let kinds: [APIRoute.Parameter.Kind] = parameter.attributes.compactMap { attr in
            switch attr.as(AttributeSyntax.self)?.attributeName.trimmedDescription {
            case "Path": .path
            case "Header": .header
            case "Query": .query
            case "Field": .field
            case "Body": .body
            default: nil
            }
        }

        guard kinds.count == 1 else {
            throw VyperMacrosError(
                "Route parameters must have exactly one of @Path, @Header, @Query, @Field, or @Body"
            )
        }

        let (type, isOptional): (String, Bool) = if let optionalType = parameter.type.as(
            OptionalTypeSyntax.self
        ) {
            (optionalType.wrappedType.trimmedDescription, true)
        } else {
            (parameter.type.trimmedDescription, false)
        }

        return APIRoute.Parameter(
            name: parameter.firstName.text,
            type: type,
            isOptional: isOptional,
            kind: kinds.first!
        )
    }
}

fileprivate extension FunctionDeclSyntax {
    var isThrowing: Bool {
        signature.effectSpecifiers?.throwsClause?.throwsSpecifier != nil
    }

    var isAsync: Bool {
        signature.effectSpecifiers?.asyncSpecifier != nil
    }

    var parameters: [FunctionParameterSyntax] {
        signature
            .parameterClause
            .parameters
            .compactMap { FunctionParameterSyntax($0) }
    }

    var functionAttributes: [AttributeSyntax] {
        attributes.compactMap { $0.as(AttributeSyntax.self) }
    }
}


fileprivate extension StructDeclSyntax {
    var functions: [FunctionDeclSyntax] {
        memberBlock
            .members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
    }
}

