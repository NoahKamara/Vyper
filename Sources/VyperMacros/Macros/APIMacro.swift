//
//  APIMacro.swift
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct APIMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
//        try [
//            API
//                .parse(declaration)
        ////                .liveImplementation(suffix: attribute.name)
        ////                .declSyntax(),
//        ]

        let api = try APIParser.parse(declaration)

        let conformanceExtension = try APIBuilder.build(api: api, extendedType: type)

        return [conformanceExtension]
    }
}


// extension API {
//    func buildImplementation(extendedType: some TypeSyntaxProtocol) throws -> ExtensionDeclSyntax
//    {
//        let bootstrapMethod = try buildBootstrapMethod()
//
//        return ExtensionDeclSyntax(
//            extendedType: extendedType,
//            memberBlock: .init(members: .init([
//                .init(decl: bootstrapMethod)
//            ]))
//        )
//
////        Declaration("struct \(name)\(suffix): \(name)") {
////
////            // 0. provider reference & init
////
////            "private let provider: Papyrus.Provider"
////
////            Declaration("init(provider: Papyrus.Provider)") {
////                "self.provider = provider"
////            }
////            .access(access)
////
////            // 1. live endpoint implementations
////
////            for endpoint in endpoints {
////                endpoint.liveFunction().access(access)
////            }
////
////            // 2. builder used by all live endpoint functions
////
////            Declaration("func builder(method: String, path: String) -> Papyrus.RequestBuilder")
/// {
////                if attributes.isEmpty {
////                    "provider.newBuilder(method: method, path: path)"
////                } else {
////                    "var req = provider.newBuilder(method: method, path: path)"
////
////                    for modifier in attributes {
////                        modifier.builderStatement()
////                    }
////
////                    "return req"
////                }
////            }
////            .private()
////        }
////        .access(access)
//    }
//
//    private func buildBootstrapMethod() throws -> FunctionDeclSyntax {
//        let routes = try buildRoutes()
//
//        return FunctionDeclSyntax(
//            name: .identifier("boot"),
//            signature: .init(
//                parameterClause: .init(
//                    parameters: [
//                        .init(
//                            firstName: "routes",
//                            type: IdentifierTypeSyntax(name: "RoutesBuilder")
//                        )
//                    ]
//                ),
//                effectSpecifiers: .init(throwsClause: .init(throwsSpecifier: .keyword(.throws)))
//            ),
//            body: .init(statements: routes)
//        )
//    }
//
//    private func buildRoutes() throws -> CodeBlockItemListSyntax {
//        return CodeBlockItemListSyntax(
//            try self.routes.map { route in
//                CodeBlockItemSyntax(
//                    item: .init(try buildRoute(route))
//                )
//            }
//        )
//    }
//
//    func buildParameterExpression(_ parameter: Route.Parameter) throws -> VariableDeclSyntax {
//        let initializerExpression: ExprSyntax = switch parameter.kind {
//        case .path:
//            switch (parameter.isOptional, parameter.type.trimmedDescription == "String") {
//            case (true, true):
//                "try request.parameters.require(\"\(raw: parameter.name)\")"
//            case (false, true):
//                "request.parameters.get(\"\(raw: parameter.name)\")"
//            case (true, false):
//                "try request.parameters.require(\"\(raw: parameter.name)\", as:
//                \(parameter.type).self)"
//            case (false, false):
//                "request.parameters.get(\"\(raw: parameter.name)\", as: \(parameter.type).self)"
//            }
//        case .header: ExprSyntax(literal: "")
//        case .query: ExprSyntax(literal: "")
//        case .field: ExprSyntax(literal: "")
//        case .body: ExprSyntax(literal: "")
//        }
//
//        return VariableDeclSyntax(
//            bindingSpecifier: .keyword(.let)
//        ) {
//            PatternBindingSyntax(
//                pattern: IdentifierPatternSyntax(identifier: .identifier(parameter.name)),
//                typeAnnotation: .init(parameter.type),
//                initializer: .init(value: initializerExpression),
//            )
//        }
//    }
//
//    private func buildRoute(_ route: Route) throws -> FunctionCallExprSyntax {
//        let parameterBuilders = route.parameters.map {  self.buildParameterExpression($0) }
//
//        let routeFunctionCall = FunctionCallExprSyntax(
//            calledExpression: MemberAccessExprSyntax(
//                base: DeclReferenceExprSyntax(baseName: .identifier("self")),
//                name: .identifier(route.name)
//            ),
//            leftParen: .leftParenToken(),
//            rightParen: .rightParenToken(),
//            argumentsBuilder: {
//                route.parameters.map { parameter in
//                    .init(
//                        label: parameter.name,
//                        expression: DeclReferenceExprSyntax(
//                            baseName: .identifier(parameter.name)
//                        )
//                    )
//                }
//            }
//        )
//
//        let closure = ClosureExprSyntax(
//            signature: .init(
//                parameterClause: .init(
//                    .init(itemsBuilder: {
//                        [.init(name: .identifier("request"))]
//                    })
//                ),
//            ),
//            statements: .init(itemsBuilder: {
//                parameterBuilders.map({ CodeBlockItemSyntax(item: .init($0) ) })
//                AwaitExprSyntax(expression: routeFunctionCall)
//            })
//        )
//
//        return FunctionCallExprSyntax(
//            calledExpression: MemberAccessExprSyntax(
//                base: DeclReferenceExprSyntax(baseName: .identifier("routes")),
//                name: .identifier("on")
//            ),
//            leftParen: .leftParenToken(),
//            rightParen: .rightParenToken(),
//            argumentsBuilder: {
//                ([route.method]+route.path).map({ .init(expression: $0) })
//            }
//        )
//        .with(\.trailingClosure, closure)
//    }
// }
