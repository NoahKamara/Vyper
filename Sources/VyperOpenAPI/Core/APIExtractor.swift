//
//  APIExtractor.swift
//  VyperOpenAPI
//
//  Created by Noah Kamara on 24.08.2025.
//

import SwiftParser
import SwiftSyntax
import VyperCore

package struct RouteDescriptor {
    let route: APIRoute
    let markup: DocumentationMarkup
}

/// Extracts routes from Swift source code
package struct RouteExtractor {
    private(set) var docs: [String: [String: RouteDescriptor]] = [:]

    public init() {}

    public mutating func extract(sourceCode: String) {
        let source = Parser.parse(source: sourceCode)
        let visitor = RouteCollectingVisitor(viewMode: .fixedUp)
        visitor.walk(source)

        docs.merge(visitor.docs) { old, new in
            print("Unhandled duplicate symbol \(old) \(new)")
            fatalError("Unhandled duplicate symbol")
        }
    }
}



private final class RouteCollectingVisitor: SyntaxVisitor {
    /// [API-Identifier: [method-name: documentation]]
    var docs: [String: [String: RouteDescriptor]] = [:]

    private var isParsingAPIDeclaration: Bool = false
    private var isInRouteDeclaration: Bool = false

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        processTypeDeclaration(node)
        return .visitChildren
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        processTypeDeclaration(node)
        return .visitChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        processTypeDeclaration(node)
        return .visitChildren
    }

    private func processTypeDeclaration(_ node: any DeclSyntaxProtocol) {
        // Cast to WithAttributesSyntax to access attributes
        guard let attributedNode = node as? WithAttributesSyntax else {
            return
        }

        guard attributedNode.attributes.first(named: "API") != nil else {
            return
        }

        isParsingAPIDeclaration = true

        // Get the member block based on the type
        let memberBlock: MemberBlockSyntax?
        if let structDecl = node as? StructDeclSyntax {
            memberBlock = structDecl.memberBlock
        } else if let classDecl = node as? ClassDeclSyntax {
            memberBlock = classDecl.memberBlock
        } else if let enumDecl = node as? EnumDeclSyntax {
            memberBlock = enumDecl.memberBlock
        } else {
            memberBlock = nil
        }

        guard let memberBlock else {
            return
        }

        for member in memberBlock.members {
            guard let function = member.decl.as(FunctionDeclSyntax.self) else {
                continue
            }

            let route: APIRoute?
            do {
                route = try APIParser.parseFunction(function)
            } catch {
                print("Error parsing method", error)
                return
            }

            guard let route else {
                continue
            }

            // get the qualified name of the method
            guard let namedNode = node as? (any DeclSyntaxProtocol & NamedDeclSyntax) else {
                continue
            }
            let qualifiedName: String = namedNode.buildFQDN(for: function)

            // Split qualified name into API identifier and method name
            let components = qualifiedName.split(separator: ".")
            guard components.count >= 2 else {
                continue
            }

            // API identifier is the type name (first component)
            let apiIdentifier = String(components[0])

            

            let documentationString = function.leadingTrivia.reduce(into: "") { result, piece in
                if case let .docLineComment(string) = piece {
                    if !result.isEmpty {
                        result += "\n"
                    }
                    result += string.trimmingPrefix("/// ")
                }
            }
            let markup = DocumentationMarkup(text: documentationString)

            // Initialize the method dictionary if it doesn't exist
            if docs[apiIdentifier] == nil {
                docs[apiIdentifier] = [:]
            }

            // Store the documentation for this method
            docs[apiIdentifier]?[route.name] = RouteDescriptor(route: route, markup: markup)
        }

        return
    }
}
