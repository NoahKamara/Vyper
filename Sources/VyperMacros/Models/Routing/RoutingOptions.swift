//
//  RoutingOptions.swift
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftDiagnostics
import SwiftSyntax

struct RoutingOptions {
    let path: [ExprSyntax]
    let docs: DocumentationTraits

    init(path: [ExprSyntax] = [], docs: DocumentationTraits = DocumentationTraits()) {
        self.path = path
        self.docs = docs
    }

    func inherit(from options: consuming RoutingOptions) -> RoutingOptions {
        let uniqueTags = (options.docs.tags + self.docs.tags).reduce(
            into: [DeclReferenceExprSyntax]()
        ) { partialResult, tag in
            if !partialResult.contains(tag) {
                partialResult.append(tag)
            }
        }

        return RoutingOptions(
            path: options.path + self.path,
            docs: .init(
                excludeFromDocs: self.docs.excludeFromDocs || options.docs.excludeFromDocs,
                tags: uniqueTags
            )
        )
    }
}

struct Traits {
    var documentation: DocumentationTraits
}

struct DocumentationTraits {
    var excludeFromDocs: Bool = false
    var tags: [DeclReferenceExprSyntax] = []
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

        return try parseArguments(arguments.map({ $0 }))
    }

    static func parseArguments(
        _ arguments: [LabeledExprSyntax]
    ) throws(DiagnosticsError) -> RoutingOptions {
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
            self.isParsingTraits = true
        }

        guard self.isParsingTraits else {
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
        if name == "tags" {
            self.tags = arguments
                .compactMap { $0.expression.as(MemberAccessExprSyntax.self)?.declName }
            return .handled
        }

        return .notHandled
    }
}
