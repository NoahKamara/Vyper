//
//  APIParser.swift
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftDiagnostics
import SwiftSyntax

enum APIParser {
    struct ParsingError: Error, CustomStringConvertible {
        let message: String

        init(_ message: String) {
            self.message = message
        }

        var description: String {
            self.message
        }
    }

    static func parse(_ declaration: some DeclSyntaxProtocol) throws -> API {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw ParsingError("APIs must be structs for now")
        }

        return try API(
            name: structDecl.name.text,
            routes: structDecl.functions.compactMap { try self.parseFunction($0) }
        )
    }

    static func parseFunction(_ function: FunctionDeclSyntax) throws -> APIRoute? {
        var method: ExprSyntax? = nil
        var path: [ExprSyntax] = []

        for attribute in function.functionAttributes {
            let name = attribute.attributeName.trimmedDescription
            switch name {
            case "GET", "DELETE", "PATCH", "POST", "PUT", "OPTIONS", "HEAD", "TRACE", "CONNECT":
                method = ExprSyntax(MemberAccessExprSyntax(name: .identifier(name)))
                if case .argumentList(let list) = attribute.arguments {
                    path = list.map(\.expression)
                }

            case "HTTP":
                if case .argumentList(let list) = attribute.arguments {
                    method = list.first?.expression
                    path = list.dropFirst().map(\.expression)
                } else {
                    throw DiagnosticBuilder(for: attribute)
                        .severity(.error)
                        .message("Missing HTTPMethod")
                        .build()
                }

            default:
                continue
            }
        }

        guard let method else {
            return nil
        }

        let documentationString = function.leadingTrivia.reduce(into: "") { result, piece in
            if case .docLineComment(let string) = piece {
                if !result.isEmpty {
                    result += "\n"
                }
                result += string.trimmingPrefix("/// ")
            }
        }

        let documentationMarkup = DocumentationMarkup(text: documentationString)

        return try .init(
            name: function.name.text,
            method: method,
            path: path,
            isThrowing: function.isThrowing,
            isAsync: function.isAsync,
            parameters: function.parameters.map { try self.parseRouteParameter($0) },
            markup: documentationMarkup,
            returnType: self.parseReturnValue(function.signature.returnClause)
        )
    }

    private static func parseReturnValue(_ result: ReturnClauseSyntax?) -> String? {
        guard let result else { return nil }

        let returnType = result.type.trimmedDescription

        // Handle Void return type or any Response
        if returnType == "Void" || returnType == "()" || returnType == "Response" {
            return nil
        }

        return returnType
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
            throw DiagnosticBuilder(for: parameter)
                .message(
                    "Route parameters must have exactly one of @Path, @Header, @Query, @Field, or @Body"
                )
                .build()
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

private extension FunctionDeclSyntax {
    var isThrowing: Bool {
        signature.effectSpecifiers?.throwsClause?.throwsSpecifier.tokenKind == .keyword(.throws)
    }

    var isAsync: Bool {
        signature.effectSpecifiers?.asyncSpecifier?.tokenKind == .keyword(.async)
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

private extension StructDeclSyntax {
    var functions: [FunctionDeclSyntax] {
        memberBlock
            .members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
    }
}
