//
//  APIBuilder.swift
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum APIBuilder {
    static func build(
        api: API,
        extendedType: some TypeSyntaxProtocol
    ) throws -> ExtensionDeclSyntax {
        let routeBuilderStatements = try CodeBlockItemListSyntax(
            api.routes.map { route in
                try CodeBlockItemSyntax(
                    item: .init(self.buildRoute(route))
                )
            }
        )

        let bootstrapFunction = FunctionDeclSyntax(
            name: .identifier("boot"),
            signature: .init(
                parameterClause: .init(
                    parameters: [
                        .init(
                            firstName: "routes",
                            type: IdentifierTypeSyntax(name: "RoutesBuilder")
                        ),
                    ]
                ),
                effectSpecifiers: .init(throwsClause: .init(throwsSpecifier: .keyword(.throws)))
            ),
            body: .init(statements: routeBuilderStatements)
        )

        return ExtensionDeclSyntax(
            extendedType: extendedType,
            memberBlock: .init(members: .init([.init(decl: bootstrapFunction)]))
        )
    }
}

fileprivate extension APIBuilder {
    private static func buildRoute(_ route: APIRoute) throws -> FunctionCallExprSyntax {
        let parameterBuilders = try route.parameters.map { try self.buildRouteParameterDecoder($0) }

        var routeFunctionCall: any ExprSyntaxProtocol = FunctionCallExprSyntax(
            calledExpression: MemberAccessExprSyntax(
                base: DeclReferenceExprSyntax(baseName: .identifier("self")),
                name: .identifier(route.name)
            ),
            leftParen: .leftParenToken(),
            rightParen: .rightParenToken(),
            argumentsBuilder: {
                route.parameters.map { parameter in
                        .init(
                            label: parameter.name,
                            expression: DeclReferenceExprSyntax(
                                baseName: .identifier(parameter.name)
                            )
                        )
                }
            }
        )

        if route.isAsync {
            routeFunctionCall = AwaitExprSyntax(expression: routeFunctionCall)
        }

        if route.isThrowing {
            routeFunctionCall = TryExprSyntax(expression: routeFunctionCall)
        }

        let closure = ClosureExprSyntax(
            signature: .init(
                parameterClause: .init(
                    .init(itemsBuilder: {
                        [.init(name: .identifier("request"))]
                    })
                ),
            ),
            statements: .init(itemsBuilder: {
                parameterBuilders.map { CodeBlockItemSyntax(item: .init($0)) }
                ReturnStmtSyntax(expression: routeFunctionCall)
            })
        )

        return FunctionCallExprSyntax(
            calledExpression: MemberAccessExprSyntax(
                base: DeclReferenceExprSyntax(baseName: .identifier("routes")),
                name: .identifier("on")
            ),
            leftParen: .leftParenToken(),
            rightParen: .rightParenToken(),
            argumentsBuilder: {
                ([route.method] + route.path).map { .init(expression: $0) }
            }
        )
        .with(\.trailingClosure, closure)
    }

    private static func buildRouteParameterDecoder(
        _ parameter: APIRoute.Parameter
    ) throws -> VariableDeclSyntax {
        let initializerExpression: ExprSyntax = switch parameter.kind {
        case .path:
            if parameter.isOptional {
                "request.parameters.get(\"\(raw: parameter.name)\")"
            } else {
                "try request.parameters.require(\"\(raw: parameter.name)\")"
            }
        case .query:
            if parameter.isOptional {
                "request.query[\"\(raw: parameter.name)\"]"
            } else {
                "try request.query.get(at: \"\(raw: parameter.name)\")"
            }
        case .header:
            if parameter.isOptional {
                "request.headers[\"\(raw: parameter.name)\"]"
            } else {
                throw VyperMacrosError("Header parameters must be optional")
            }
        case .field: ExprSyntax(literal: "")
        case .body: ExprSyntax(literal: "")
        }

        let typeAnnotation = if parameter.isOptional {
            TypeAnnotationSyntax(
                type: OptionalTypeSyntax(
                    wrappedType: IdentifierTypeSyntax(
                        name: .identifier(parameter.type)
                    )
                )
            )
        } else {
            TypeAnnotationSyntax(type: IdentifierTypeSyntax(name: .identifier(parameter.type)))
        }

        return VariableDeclSyntax(
            bindingSpecifier: .keyword(.let)
        ) {
            PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(identifier: .identifier(parameter.name)),
                typeAnnotation: typeAnnotation,
                initializer: .init(value: initializerExpression),
            )
        }
    }
}
