//
//  APIMacro.swift
//
//  Copyright © 2024 Noah Kamara.
//

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
        let options = try parseOptions(from: node)
        let conformanceExtension = try APIBuilder.build(
            api: api,
            extendedType: type,
            options: options
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
                options.excludeFromDocs = true
                options.traits.append(ExprSyntax(expression))
                continue
            }

            throw builder
                .message("Unknown trait option: \(expression.declName.trimmedDescription).")
                .build()
        }

        options.path = pathComponents

        return options
    }
}

struct APIOptions {
    var excludeFromDocs: Bool = false
    var path: [ExprSyntax] = []
    var traits: [ExprSyntax] = []
}
