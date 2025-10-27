//
//  TagMacro.swift
//  Vyper
//
//  Created by Noah Kamara on 12.09.2025.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

package struct TagMacro: AccessorMacro {
    private static var _fallbackAccessorDecls: [AccessorDeclSyntax] {
        [#"get { fatalError() }"#]
    }

    package static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        let variableDecl = declaration.cast(VariableDeclSyntax.self)

        let variableName = variableDecl.bindings.first!.pattern.cast(IdentifierPatternSyntax.self).identifier

        guard variableDecl.modifiers.map(\.name.tokenKind).contains(.keyword(.static)) else {
            context.diagnose(
                DiagnosticBuilder(for: variableDecl)
                    .severity(.warning)
                    .message("@Tag can only be applied to static declarations")
                    .build()
            )

            return _fallbackAccessorDecls
        }

        let markup = variableDecl.leadingTrivia.documentationMarkup()

        let summary = markup.abstractSection?.format()
        let description = summary?.isEmpty == false ? #""\#(summary!)""# : "nil"

        return [
            #"""
            get {
            Vyper.Tag(name: "\#(raw: variableName)", description: \#(raw: description))
            }
            """#
        ]
    }
}
