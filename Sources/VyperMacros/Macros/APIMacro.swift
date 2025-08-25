//
//  APIMacro.swift
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftSyntax
import SwiftSyntaxMacros
import VyperCore

public struct APIMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let api = try APIParser.parse(declaration)
        let conformanceExtension = try APIBuilder.build(api: api, extendedType: type)
        return [conformanceExtension]
    }
}
