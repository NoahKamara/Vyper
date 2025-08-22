//
//  DecoratorMacro.swift
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

struct DecoratorMacro: PeerMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let messageID = MessageID(domain: "decorator", id: "papyrus")
        let message = MyDiagnostic(
            message: "processed decorator",
            diagnosticID: messageID,
            severity: .note
        )
        let diagnostic = Diagnostic(node: Syntax(node), message: message)
        context.diagnose(diagnostic)
        // TODO: Add some compiler safety to ensure certain attributes can't be on certain members.
        return []
    }
}

struct MyDiagnostic: DiagnosticMessage {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity
}
