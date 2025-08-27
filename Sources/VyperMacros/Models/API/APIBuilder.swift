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
        extendedType: some TypeSyntaxProtocol,
        options: APIOptions
    ) throws -> ExtensionDeclSyntax {
        let routeBuilderStatements = try CodeBlockItemListSyntax(
            api.routes.map { route in
                try CodeBlockItemSyntax(
                    item: .init(self.buildRoute(route, options: options))
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

    private static func buildRoute(
        _ route: APIRoute,
        options: APIOptions
    ) throws -> FunctionCallExprSyntax {
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

        // routes.on(.GET) {} call

        var funcCall = FunctionCallExprSyntax(
            calledExpression: MemberAccessExprSyntax(
                base: DeclReferenceExprSyntax(baseName: .identifier("routes")),
                period: .periodToken(),
                name: .identifier("on")
            ),
            leftParen: .leftParenToken(),
            rightParen: .rightParenToken()
        ) {
            LabeledExprSyntax(expression: route.method)
            route.path.map { LabeledExprSyntax(expression: $0) }
        }.with(\.trailingClosure, closure)

        let abstract: String? = route.markup.abstractSection?.paragraph.format()
        let discussion: String? = if let discussion = route.markup.discussionSection {
            discussion.content.isEmpty ? nil : discussion.format()
        } else {
            nil
        }

        // dont generate openapi calls when docs disabled
        guard !options.excludeFromDocs else {
            return funcCall
        }

        // Build base spec .openAPI()
        if abstract != nil || discussion != nil {
            // Add OpenAPI modifier
            funcCall = FunctionCallExprSyntax(
                callee: MemberAccessExprSyntax(
                    base: funcCall,
                    period: .periodToken(leadingTrivia: .newline),
                    declName: .init(baseName: .identifier("openAPI")),
                ),
                argumentList: {
                    if let abstract {
                        LabeledExprSyntax(
                            label: .identifier("summary"),
                            colon: .colonToken(),
                            expression: StringLiteralExprSyntax(content: abstract)
                        )
                    }

                    if let discussion {
                        LabeledExprSyntax(
                            label: .identifier("discussion"),
                            colon: .colonToken(),
                            expression: StringLiteralExprSyntax(content: discussion)
                        )
                    }
                }
            )
        }

        // Parameters .openAPI(custom: \.parameters, [...])
        if !route.parameters.isEmpty {
            let parameterObjects = route.parameters.map { parameter in
                let parameterMarkup = route.markup.discussionTags?.parameters
                    .first(where: { $0.name == parameter.name })?
                    .contents
                    .map { $0.format() }
                    .joined(separator: "\n")

                return self.buildParameterObject(
                    parameter: parameter,
                    markup: parameterMarkup
                )
            }

            funcCall = funcCall.openAPI(
                keyPath: "parameters",
                ArrayExprSyntax(
                    elementsBuilder: {
                        parameterObjects
                            .map { parameterObject in
                                ArrayElementSyntax(
                                    expression: FunctionCallExprSyntax.dotCall(
                                        "value",
                                        argumentList: { .init(expression: parameterObject) }
                                    )
                                )
                            }
                    })
            )
        }

        // Return type .openAPI(custom: \.responses, [...])
        if let returnType = route.returnType {
            funcCall = callResponse(
                route: funcCall,
                returnType: returnType,
                markup: route.markup.discussionTags?.returns.first?.format()
            )
        }

        return funcCall
    }

    private static func buildParameterObject(
        parameter: APIRoute.Parameter,
        markup: String?
    ) -> FunctionCallExprSyntax {
        let schemaType = self.getOpenAPISchemaType(for: parameter.type)

        return FunctionCallExprSyntax(
            callee: MemberAccessExprSyntax(
                period: .periodToken(),
                declName: DeclReferenceExprSyntax(baseName: .identifier("init"))
            ),
            argumentList: {
                LabeledExprSyntax(
                    label: "name",
                    expression: StringLiteralExprSyntax(content: parameter.name)
                )
                if let markup {
                    LabeledExprSyntax(
                        label: "description",
                        expression: StringLiteralExprSyntax(content: markup)
                    )
                }
                LabeledExprSyntax(
                    label: "in",
                    expression: MemberAccessExprSyntax(
                        declName: .init(baseName: .identifier(parameter.kind.rawValue))
                    )
                )
                if !parameter.isOptional {
                    LabeledExprSyntax(
                        label: "required",
                        expression: BooleanLiteralExprSyntax(true)
                    )
                }
                LabeledExprSyntax(
                    label: "schema",
                    expression: schemaType
                )
            }
        )
    }

    private static func callResponse(
        route: FunctionCallExprSyntax,
        returnType: String,
        markup: String?
    ) -> FunctionCallExprSyntax {
        let schemaType = self.getOpenAPISchemaType(for: returnType)

        return route.call("response") {
            LabeledExprSyntax(
                label: "body",
                expression: FunctionCallExprSyntax(
                    callee: MemberAccessExprSyntax(
                        period: .periodToken(),
                        name: .identifier("type")
                    ),
                    argumentList: {
                        LabeledExprSyntax(expression: MemberAccessExprSyntax(
                            base: DeclReferenceExprSyntax(baseName: .identifier(returnType)),
                            period: .periodToken(),
                            name: .keyword(.self)
                        ))
                    }
                )
            )

            LabeledExprSyntax(
                label: "contentType",
                expression: FunctionCallExprSyntax(
                    callee: MemberAccessExprSyntax(
                        period: .periodToken(),
                        name: .identifier("application")
                    ),
                    argumentList: {
                        LabeledExprSyntax(
                            expression: MemberAccessExprSyntax(period: .periodToken(), name: .identifier("json"))
                        )
                    }
                )
            )
//            .response(
//                statusCode: <#T##ResponsesObject.Key#>,
//                body: <#T##OpenAPIBody?#>,
//                contentType: <#T##MediaType...##MediaType#>,
//                headers: <#T##OpenAPIParameters?#>,
//                description: <#T##String?#>
//            )
        }
    }

    private static func getOpenAPISchemaType(for kind: APIRoute.Parameter.Kind)
        -> FunctionCallExprSyntax
    {
        // For now, return a basic string schema
        // You can enhance this to map Swift types to OpenAPI schemas
        FunctionCallExprSyntax(
            callee: MemberAccessExprSyntax(
                period: .periodToken(),
                name: .identifier("string")
            ),
            argumentList: {}
        )
    }

    private static func getOpenAPISchemaType(
        for typeIdentifier: String
    ) -> FunctionCallExprSyntax {
        // Map Swift types to OpenAPI schema types
        let schemaType = switch typeIdentifier {
            case "String", "String?":
                "string"
            case "Int", "Int8", "Int16", "Int32", "Int64", "Int?", "Int8?", "Int16?", "Int32?",
                 "Int64?":
                "integer"
            case "Float", "Double", "Float?", "Double?":
                "number"
            case "Bool", "Bool?":
                "boolean"
            case let type where type.hasSuffix("?") && type.dropLast().hasSuffix("Array"):
                "array"
            case let type where type.hasSuffix("Array"):
                "array"
            case let type where self.isCustomType(type):
                // For custom types, reference them in the components/schemas section
                "object" // or reference the custom schema
            default:
                "object"
            }

        // For custom types, we need to handle them differently
        if self.isCustomType(typeIdentifier) {
            return self.buildCustomTypeSchema(for: typeIdentifier)
        }

        return FunctionCallExprSyntax(
            calledExpression: MemberAccessExprSyntax(
                period: .periodToken(),
                name: .identifier(schemaType)
            ),
            argumentsBuilder: {}
        )
    }

    private static func isCustomType(_ typeName: String) -> Bool {
        // List of known Swift standard library types
        let standardTypes: Set<String> = [
            "String", "Int", "Int8", "Int16", "Int32", "Int64", "UInt", "UInt8", "UInt16", "UInt32",
            "UInt64",
            "Float", "Double", "Bool", "Character", "Data", "Date", "URL", "UUID",
            "Array", "Dictionary", "Set", "Optional",
        ]

        // Remove optional wrapper for comparison
        let cleanType = typeName.replacingOccurrences(of: "?", with: "")

        // Check if it's a standard type
        return !standardTypes.contains(cleanType)
    }

    private static func buildCustomTypeSchema(for typeName: String) -> FunctionCallExprSyntax {
        // Remove optional wrapper for the schema name
        let cleanType = typeName.replacingOccurrences(of: "?", with: "")

        // For custom types, we can either:
        // 1. Reference them in the components/schemas section (recommended)
        // 2. Generate inline schema (for simple cases)

        // Option 1: Reference to components/schemas (recommended for complex types)
        return FunctionCallExprSyntax.dotCall("schema") {
            LabeledExprSyntax(
                expression: FunctionCallExprSyntax.dotCall(<#T##declName: String##String#>, argumentList: <#T##() -> LabeledExprListSyntax#>)(
                    calledExpression: DeclReferenceExprSyntax(
                        baseName: .identifier("SchemaObject")
                    ),
                    arguments: [
                        LabeledExprSyntax(
                            label: "ref",
                            expression: StringLiteralExprSyntax(
                                content: "#/components/schemas/\(cleanType)"
                            )
                        ),
                    ]
                )
            )
        }

        // Option 2: Inline schema (uncomment if you want to generate inline schemas)
        /*
         return FunctionCallExprSyntax(
             calledExpression: DeclReferenceExprSyntax(baseName: .identifier("SchemaObject")),
             arguments: [
                 LabeledExprSyntax(
                     label: "type",
                     expression: StringLiteralExprSyntax(content: "object")
                 ),
                 LabeledExprSyntax(
                     label: "title",
                     expression: StringLiteralExprSyntax(content: cleanType)
                 )
             ]
         )
         */
    }

    private static func buildRouteParameterDecoder(
        _ parameter: APIRoute.Parameter
    ) throws -> VariableDeclSyntax {
        let initializerExpression: ExprSyntax =
            switch parameter.kind {
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

        let typeAnnotation =
            if parameter.isOptional {
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

extension FunctionCallExprSyntax {
    static func dotCall(
        _ declName: String,
        @LabeledExprListBuilder argumentList: () -> LabeledExprListSyntax = { [] }
    ) -> FunctionCallExprSyntax {
        FunctionCallExprSyntax(
            callee: MemberAccessExprSyntax(
                period: .periodToken(leadingTrivia: .newline),
                declName: .init(baseName: .identifier(declName))
            ),
            argumentList: argumentList
        )
    }

    func call(
        _ declName: String,
        @LabeledExprListBuilder argumentList: () -> LabeledExprListSyntax = { [] }
    ) -> FunctionCallExprSyntax {
        FunctionCallExprSyntax(
            callee: MemberAccessExprSyntax(
                base: self,
                period: .periodToken(leadingTrivia: .newline),
                declName: .init(baseName: .identifier(declName))
            ),
            argumentList: argumentList
        )
    }

    func openAPI(keyPath: String, _ value: some ExprSyntaxProtocol) -> FunctionCallExprSyntax {
        let keyPathExpr = KeyPathExprSyntax(components: [
            .init(
                period: .periodToken(),
                component: .property(.init(declName: .init(baseName: .identifier(keyPath))))
            ),
        ])

        return self.call("openAPI") {
            LabeledExprSyntax(label: "custom", colon: .colonToken(), expression: keyPathExpr)
            LabeledExprSyntax(expression: value)
        }
    }
}

//
// struct OpenAPIProxy {
//    struct PathParameter {
//        let name: String
//        let description: String?
//    }
//
//    var summary: String?
//    var description: String?
//    var pathParameters: [String: PathParameter] = [:]
//    var parameters: [String: Parameter]
//
//    init(summary: String? = nil, description: String? = nil, parameters: [String : Parameter] = [:]) {
//        self.summary = summary
//        self.description = description
//        self.parameters = parameters
//    }
//
//
//    init(_ route: APIRoute) {
//        self.init(
//            summary: route.markup.abstractSection?.paragraph.format(),
//            description: route.markup.discussionSection?.format()
//        )
//
//        route.markup.discussionTags?.httpParameters
//
//        for parameter in route.parameters {
//            self.parameters[parameter.name] = Parameter(
//                description: parameter.description
//            )
//        }
//
//        if let tags = route.markup.discussionTags {
//            route.parameters
//            if tags.parameters.contains { $0.name == .path } {
//                .init(
//                    label: "path",
//                    expression: DictionaryExprSyntax(
//                        content: .init(
//                            elements: route.parameters
//                                .filter { $0.kind == .path }
//                                .map { param in
//                                        .init(
//                                            key: .init(
//                                                expression: ExprSyntax(literal: "\"\(param.name)\"")
//                                            ),
//                                            value: .init(
//                                                expression: MemberAccessExprSyntax(
//                                                    base: MemberAccessExprSyntax(
//                                                        base: MemberAccessExprSyntax(
//                                                            base: IdentifierTypeSyntax(
//                                                                name: "OpenAPIParameters"
//                                                            ),
//                                                            name: "Value"
//                                                        ),
//                                                        name: "value"
//                                                    ),
//                                                    name: .identifier(param
//                                                        .type == "Int" ? "int" : "string"
//                                                    )
//                                                )
//                                            )
//                                        )
//                                }
//                        )
//                    )
//                ),
//            }
//        }
//    }
// }
