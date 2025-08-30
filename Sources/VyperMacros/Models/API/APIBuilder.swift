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
            inheritanceClause: .init(
                inheritedTypes: [
                    .init(type: IdentifierTypeSyntax(name: .identifier("RouteCollection"))),
                ]
            ),
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

        // Combine API-level path with route-level path
        let combinedPath = options.path + route.path

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
            combinedPath.map { LabeledExprSyntax(expression: $0) }
        }.with(\.trailingClosure, closure)

        // Process traits
        for trait in options.traits {
            if let memberAccess = trait.as(MemberAccessExprSyntax.self),
               memberAccess.declName.trimmedDescription == "ExcludeFromDocs"
            {
                // Skip OpenAPI generation for this route
                return funcCall
            }
        }

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

        var queryParameters = [FunctionCallExprSyntax]()
        var headerParameters = [FunctionCallExprSyntax]()
        var pathParameters = [FunctionCallExprSyntax]()
        var cookieParameters = [FunctionCallExprSyntax]()

        var body: MemberAccessExprSyntax? = nil

        for parameter in route.parameters {
            let markup = route.markup.discussionTags?.parameters
                .first(
                    where: { $0.name == parameter.name || $0.name == parameter.secondName }
                )?
                .contents
                .map { $0.format() }
                .joined(separator: "\n")


            switch parameter.kind {
            case .query:
                queryParameters.append(
                    buildParameterObject(parameter: parameter, markup: markup)
                )
            case .header:
                headerParameters.append(
                    buildParameterObject(parameter: parameter, markup: markup)
                )
            case .path:
                pathParameters.append(
                    buildParameterObject(parameter: parameter, markup: markup)
                )
            case .cookie:
                pathParameters.append(
                    buildParameterObject(parameter: parameter, markup: markup)
                )
            case .body:
                body = MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(baseName: .identifier(parameter.type)),
                    name: .keyword(.self)
                )
            case .passthrough: break
            }
        }

        let response = route.returnType.map(MemberAccessExprSyntax.typeReference)
        let responseDescription: String? = route.markup.discussionTags?.returns.first?.format()

        let openAPICall = funcCall.call("openAPI") {
            //        customMethod: <#T##PathItemObject.Method?#>,
            //        spec: <#T##String?#>,
            //        tags: <#T##TagObject...#>,
            if let abstract {
                LabeledExprSyntax(
                    label: "summary",
                    expression: StringLiteralExprSyntax(content: abstract)
                )
            }

            if let discussion {
                LabeledExprSyntax(
                    label: "discussion",
                    expression: StringLiteralExprSyntax(content: discussion)
                )
            }

            //        operationId: <#T##String?#>,
            //        externalDocs: <#T##ExternalDocumentationObject?#>,
            //        query: <#T##OpenAPIParameters?#>,

            // Parameters .openAPI(custom: \.parameters, [...])

            if !queryParameters.isEmpty {
                LabeledExprSyntax(
                    label: "query",
                    expression: ArrayExprSyntax.multiline { queryParameters }
                )
            }

            if !headerParameters.isEmpty {
                LabeledExprSyntax(
                    label: "header",
                    expression: ArrayExprSyntax.multiline { headerParameters }
                )
            }

            if !pathParameters.isEmpty {
                LabeledExprSyntax(
                    label: "path",
                    expression: ArrayExprSyntax.multiline { pathParameters }
                )
            }

            if !cookieParameters.isEmpty {
                LabeledExprSyntax(
                    label: "cookies",
                    expression: ArrayExprSyntax.multiline { cookieParameters }
                )
            }

            if let body {
                LabeledExprSyntax(
                    label: "body",
                    expression: FunctionCallExprSyntax.dotCall("type") {
                        LabeledExprSyntax(expression: body)
                    }
                )

                LabeledExprSyntax(
                    label: "contentType",
                    expression: FunctionCallExprSyntax.call("Self", "responseContentType") {
                        LabeledExprSyntax(
                            label: "for",
                            expression: body
                        )
                    }
                )
            }

            if let response {
                LabeledExprSyntax(
                    label: "response",
                    expression: response
                )

                LabeledExprSyntax(
                    label: "responseContentType",
                    expression: FunctionCallExprSyntax.call("Self", "responseContentType") {
                        LabeledExprSyntax(label: "for", expression: response)
                    }
                )
            }

            //        responseHeaders: <#T##OpenAPIParameters?#>,

            if let responseDescription {
                LabeledExprSyntax(
                    label: "responseDescription",
                    expression: StringLiteralExprSyntax(content: responseDescription)
                )
            }

//            if let statusCode {
//                statusCode
//            }
            //        statusCode: <#T##ResponsesObject.Key#>,
            //        links: <#T##[Link : LinkKey]#>,
            //        callbacks: <#T##[String : ReferenceOr<CallbackObject>]?#>,
            //        deprecated: <#T##Bool?#>,
            //        auth: <#T##AuthSchemeObject...#>,
            //        servers: <#T##[ServerObject]?#>,
            //        extensions: <#T##SpecificationExtensions#>
        }

        guard !openAPICall.arguments.isEmpty else {
            return funcCall
        }

        return openAPICall

        // Return type .openAPI(custom: \.requestBody, .type(ResponseBodyType.self))
        let bodyParameters = route.parameters.filter({
            if case .body = $0.kind { true } else { false }
        })

        if bodyParameters.count == 1 {
            funcCall = funcCall.openAPI(
                keyPath: "requestBody",
                FunctionCallExprSyntax.dotCall("type") {
                    LabeledExprSyntax(
                        expression: MemberAccessExprSyntax(
                            base: DeclReferenceExprSyntax(baseName: .identifier(bodyParameters[0].type)),
                            name: .keyword(.self)
                        )
                    )
                }
            )
        } else if bodyParameters.count > 1 {
            fatalError("Multiple body parameters not yet supported")
        }

        // Parameters .openAPI(custom: \.parameters, [...])
        let parameterObjects: [FunctionCallExprSyntax] = route.parameters
            .compactMap { parameter in
                guard parameter.kind.isParameter else {
                    return nil
                }

                let parameterMarkup = route.markup.discussionTags?.parameters
                    .first(
                        where: { $0.name == parameter.name || $0.name == parameter.secondName }
                    )?
                    .contents
                    .map { $0.format() }
                    .joined(separator: "\n")

                return self.buildParameterObject(
                    parameter: parameter,
                    markup: parameterMarkup
                )
            }

        if !parameterObjects.isEmpty {
            funcCall = funcCall.openAPI(
                keyPath: "parameters",
                ArrayExprSyntax.multiline {
                    parameterObjects
                }
            )
        }

        // Return type .openAPI(custom: \.responses, [...])
        if let returnType = route.returnType {
            funcCall = self.callResponse(
                route: funcCall,
                returnType: returnType,
                markup: route.markup.discussionTags?.returns.first?.format()
            )
        }

        return funcCall
    }

    private static func buildParameters(_ parameters: [APIRoute.Parameter]) {
        DictionaryExprSyntax {
            parameters.map { parameter in
                DictionaryElementSyntax(
                    key: StringLiteralExprSyntax(content: parameter.name),
                    value: buildParameterObject(parameter: parameter, markup: nil)
                )
            }
        }
    }

    private static func buildParameterObject(
        parameter: APIRoute.Parameter,
        markup: String?
    ) -> FunctionCallExprSyntax {
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
                LabeledExprSyntax(
                    label: "in",
                    expression: MemberAccessExprSyntax(
                        declName: .init(baseName: .identifier(parameter.kind.rawLocation!))
                    )
                )
                if let markup {
                    LabeledExprSyntax(
                        label: "description",
                        expression: StringLiteralExprSyntax(content: markup)
                    )
                }
                if !parameter.isOptional {
                    LabeledExprSyntax(
                        label: "required",
                        expression: BooleanLiteralExprSyntax(true)
                    )
                }
                LabeledExprSyntax(
                    label: "schema",
                    expression: self.getOpenAPISchemaType(for: parameter.type)
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
                            expression: MemberAccessExprSyntax(
                                period: .periodToken(),
                                name: .identifier("json")
                            )
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

//        return FunctionCallExprSyntax.dotCall("type") {
//            LabeledExprSyntax(
//                expression: MemberAccessExprSyntax(
//                    base: DeclReferenceExprSyntax(baseName: .identifier(typeIdentifier)),
//                    declName: DeclReferenceExprSyntax(baseName: .identifier("self"))
//                )
//            )
//        }

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
                expression: FunctionCallExprSyntax.dotCall("init") {
                    LabeledExprSyntax(
                        label: "ref",
                        expression: StringLiteralExprSyntax(
                            content: "#/components/schemas/\(cleanType)"
                        )
                    )
                }
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
            case .cookie:
                if parameter.isOptional {
                    "request.cookies[name: \"\(raw: parameter.name)\"]"
                } else {
                    throw VyperMacrosError("Cookie parameters must be optional")
                }
            case .body:
                "try request.content.decode(\(raw: parameter.type).self)"
            case .passthrough(let expr):
                if let expr {
                    "request[keyPath: \(raw: expr)]"
                } else {
                    "request"
                }
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
                period: .periodToken(),
                declName: .init(baseName: .identifier(declName))
            ),
            argumentList: argumentList
        )
    }

    static func call(
        _ baseName: String,
        _ declName: String,
        @LabeledExprListBuilder argumentList: () -> LabeledExprListSyntax = { [] }
    ) -> FunctionCallExprSyntax {
        FunctionCallExprSyntax(
            callee: MemberAccessExprSyntax(
                base: DeclReferenceExprSyntax(baseName: .identifier(baseName)),
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

extension ArrayExprSyntax {
    static func multiline(
        @ExprListBuilder
        elementsBuilder: () -> ExprListSyntax
    ) -> ArrayExprSyntax {
        let childTrivia: Trivia = [.newlines(1), .spaces(4)]
        let elements = elementsBuilder()

        return ArrayExprSyntax(
            rightSquare: .rightSquareToken(leadingTrivia: elements.isEmpty ? [] : .newline),
        ) {
            elements.map { expression in
                ArrayElementSyntax(leadingTrivia: childTrivia, expression: expression)
            }
        }
    }
}

extension MemberAccessExprSyntax {
    static func typeReference(_ type: String) -> Self {
        MemberAccessExprSyntax(
            base: DeclReferenceExprSyntax(baseName: .identifier(type)),
            name: .keyword(.self)
        )
    }
}
