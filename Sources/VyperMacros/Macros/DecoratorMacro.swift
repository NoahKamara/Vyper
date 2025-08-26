//
//  DecoratorMacro.swift
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftSyntax
import SwiftSyntaxMacros

struct DecoratorMacro: PeerMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let decoratorName = node.attributeName.trimmedDescription
        let diagnostics = DiagnosticBuilder(for: node).messageID(id: decoratorName)

        guard declaration.is(FunctionDeclSyntax.self) else {
            let diagnostic = diagnostics
                .severity(.warning)
                .message("@\(decoratorName) can only be applied to functions")
                .build()

            context.diagnose(diagnostic)
            return []
        }

        let diagnostic = diagnostics
            .severity(.note)
            .message("@\(decoratorName) found")
            .build()

        context.diagnose(diagnostic)
        return []
    }
}
