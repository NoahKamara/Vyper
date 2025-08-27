//
//  APIMacro.swift
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftSyntax
import SwiftSyntaxMacros

struct APIMacro: ExtensionMacro {
    static func expansion(
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
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            return APIOptions()
        }

        for argument in arguments {
            let builder = DiagnosticBuilder(for: argument)
                .messageID(domain: "vyper", id: "api.invalidOption")

            guard let expression = argument.expression.as(MemberAccessExprSyntax.self) else {
                throw builder.message("invalid argument").build()
            }

            if expression.declName.trimmedDescription == "excludeFromDocs" {
                return APIOptions(excludeFromDocs: true)
            }
        }

        return APIOptions()
    }
}

struct APIOptions {
    var excludeFromDocs: Bool = false
}
