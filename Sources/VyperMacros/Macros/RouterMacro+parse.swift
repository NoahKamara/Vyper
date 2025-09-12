//
//  RouterMacro+Parser.swift
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftDiagnostics
import SwiftSyntax

extension RouterMacro {
    struct ParsingError: Error, CustomStringConvertible {
        let message: String

        init(_ message: String) {
            self.message = message
        }

        var description: String {
            self.message
        }
    }

    static func parseRouter(_ declaration: some DeclSyntaxProtocol) throws -> RouterDescriptor {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw ParsingError("APIs must be structs for now")
        }

        return try RouterDescriptor(
            name: structDecl.name.text,
            routes: structDecl.functions.compactMap { try self.parseFunction($0) }
        )
    }

    static func parseFunction(_ function: FunctionDeclSyntax) throws -> RouteDescriptor? {
        var method: ExprSyntax? = nil
        var options = RoutingOptions()

        for attribute in function.functionAttributes {
            let name = attribute.attributeName.trimmedDescription
            switch name {
            case "GET", "DELETE", "PATCH", "POST", "PUT", "OPTIONS", "HEAD", "TRACE", "CONNECT":
                method = ExprSyntax(MemberAccessExprSyntax(name: .identifier(name)))

                if let list = attribute.arguments?.as(LabeledExprListSyntax.self) {
                    options = try RoutingOptionsParser.parseArguments(list.map({ $0 }))
                }

            case "HTTP":
                if case .argumentList(let list) = attribute.arguments {
                    method = list.first?.expression
                    options = try RoutingOptionsParser.parseArguments(list.dropFirst().map({ $0 }))
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
            path: options.path,
            isThrowing: function.isThrowing,
            isAsync: function.isAsync,
            parameters: function.parameters.map { try self.parseRouteParameter($0) },
            markup: documentationMarkup,
            returnType: self.parseReturnValue(function.signature.returnClause),
            options: options
        )
    }

    fileprivate static func parseReturnValue(_ result: ReturnClauseSyntax?) -> String? {
        guard let result else { return nil }

        let returnType = result.type.trimmedDescription

        // Handle Void return type or any Response
        if returnType == "Void" || returnType == "()" || returnType == "Response" {
            return nil
        }

        return returnType
    }

    fileprivate static func parseRouteParameter(
        _ parameter: FunctionParameterSyntax
    ) throws -> RouteDescriptor.Parameter {
        let kinds: [RouteDescriptor.Parameter.Kind] = parameter.attributes.compactMap { attr in
            let attribute = attr.as(AttributeSyntax.self)
            let arguments = attribute?.arguments?.as(LabeledExprListSyntax.self)

            switch attribute?.attributeName.trimmedDescription {
            case "Path":
                return .path
            case "Header":
                return .header
            case "Query":
                return .query
            case "Cookie":
                return .cookie
            case "Body":
                return .body
            case "Passthrough":
                guard let firstArg = arguments?.first else {
                    return .passthrough(nil)
                }
                return .passthrough(firstArg.expression)
            default:
                return nil
            }
        }

        guard kinds.count == 1 else {
            throw DiagnosticBuilder(for: parameter)
                .message("""
                Route parameters must have exactly one of @Path, @Query, @Body, @Header or @Passthrough
                """)
                .build()
        }

        let (type, isOptional): (String, Bool) = if let optionalType = parameter.type.as(
            OptionalTypeSyntax.self
        ) {
            (optionalType.wrappedType.trimmedDescription, true)
        } else {
            (parameter.type.trimmedDescription, false)
        }

        return RouteDescriptor.Parameter(
            name: parameter.firstName.text,
            secondName: parameter.secondName?.text,
            type: type,
            isOptional: isOptional,
            kind: kinds.first!
        )
    }
}


extension Trivia {
    func documentationMarkup() -> DocumentationMarkup {
        let doccComment = self.reduce(into: "") { result, piece in
            if case .docLineComment(let text) = piece {
                if !result.isEmpty {
                    result += "\n"
                }
                result += text.trimmingPrefix("/// ")
            }
        }

        return DocumentationMarkup(text: doccComment)
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
