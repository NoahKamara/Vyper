//
//  APIMacro.swift
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

package struct APIMacro: ExtensionMacro {
    package static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let api = try APIParser.parse(declaration)

        let routingOptions = try RoutingOptionsParser.parseArguments(of: node)

        let options = try parseOptions(from: node)

        let conformanceExtension = try APIBuilder.build(
            api: api,
            extendedType: type,
            options: routingOptions
        )
        return [conformanceExtension]
    }

    static func parseOptions(from node: AttributeSyntax) throws -> APIOptions {
        var options = APIOptions()

        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            return APIOptions()
        }

        var isParsingTraits = false
        var pathComponents: [ExprSyntax] = []

        for argument in arguments {
            let builder = DiagnosticBuilder(for: argument)
                .messageID(domain: "vyper", id: "api.invalidOption")

            if argument.label?.text == "traits" {
                isParsingTraits = true
            }

            guard isParsingTraits else {
                pathComponents.append(argument.expression)
                continue
            }

            guard let expression = argument.expression.as(MemberAccessExprSyntax.self) else {
                continue
            }

            if expression.declName.trimmedDescription == "excludeFromDocs" {
                options.documentation.excludeFromDocs = true
                continue
            }

            throw
                builder
                .message("Unknown trait option: \(expression.declName.trimmedDescription).")
                .build()
        }

        options.path = pathComponents

        return options
    }
}


struct APIOptions {
    var excludeFromDocs: Bool { documentation.excludeFromDocs }
    var path: [ExprSyntax] = []
    var documentation: DocumentationTraits = .init()
}

struct RoutingOptions {
    let path: [ExprSyntax]
    let docs: DocumentationTraits

    init(path: [ExprSyntax] = [], docs: DocumentationTraits = DocumentationTraits()) {
        self.path = path
        self.docs = docs
    }
}

class RoutingOptionsParser {
    private var isParsingTraits: Bool = false

    var path: [ExprSyntax] = []

    var excludeFromDocs: Bool = false
    var tags: [DeclReferenceExprSyntax] = []

    static func parseArguments(
        of node: AttributeSyntax
    ) throws(DiagnosticsError) -> RoutingOptions {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            return RoutingOptions()
        }

        let parser = RoutingOptionsParser()

        var diagnostics = [Diagnostic]()
        for argument in arguments {
            let result = parser.parseArgument(argument)

            if result == .notHandled {
                diagnostics.append(
                    DiagnosticBuilder(for: argument.expression)
                        .message("Invalid trait")
                        .build()
                )
            }
        }

        guard diagnostics.isEmpty else { throw DiagnosticsError(diagnostics: diagnostics) }

        return RoutingOptions(
            path: parser.path,
            docs: .init(
                excludeFromDocs: parser.excludeFromDocs,
                tags: parser.tags
            )
        )
    }

    private enum ParseResultKind {
        case notHandled
        case handled
    }

    private func parseArgument(_ argument: LabeledExprListSyntax.Element) -> ParseResultKind {
        if argument.label?.text == "traits" {
            isParsingTraits = true
        }

        guard isParsingTraits else {
            self.path.append(argument.expression)
            return .handled
        }

        var result: ParseResultKind = .notHandled

        if let expression = argument.expression.as(MemberAccessExprSyntax.self) {
            result = self.parseFlag(name: expression.declName.trimmedDescription)
        }

        guard result == .notHandled else { return .handled }

        if let funcCall = argument.expression.as(FunctionCallExprSyntax.self) {
            let name = funcCall.calledExpression.as(MemberAccessExprSyntax.self)!
                .declName
                .trimmedDescription

            result = self.parseOptions(name: name, arguments: funcCall.arguments)
        }

        return result
    }

    private func parseFlag(name: String) -> ParseResultKind {
        switch name {
        case "excludeFromDocs":
            self.excludeFromDocs = true
            return .handled
        default:
            return .notHandled
        }
    }

    private func parseOptions(name: String, arguments: LabeledExprListSyntax) -> ParseResultKind {
        if name == "tag" {
            tags = arguments
                .compactMap({ $0.expression.as(MemberAccessExprSyntax.self)?.declName })
            return .handled
        }

        return .notHandled
    }
}

struct Traits {
    var documentation: DocumentationTraits
}

struct DocumentationTraits {
    var excludeFromDocs: Bool = false
    var tags: [DeclReferenceExprSyntax]? = nil
}
