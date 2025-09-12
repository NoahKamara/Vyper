//
//  RouterMacro.swift
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

package struct RouterMacro: ExtensionMacro {
    package static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let api = try parseRouter(declaration)

        let options = try RoutingOptionsParser.parseArguments(of: node)

        let conformanceExtension = try buildRouteCollection(
            api: api,
            extendedType: type,
            options: options
        )

        return [conformanceExtension]
    }
}
