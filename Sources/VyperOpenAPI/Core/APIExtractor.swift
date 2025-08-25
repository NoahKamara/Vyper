//
//  APIExtractor.swift
//  VyperOpenAPI
//
//  Created by Noah Kamara on 24.08.2025.
//

import SwiftParser
import SwiftSyntax

package struct Route {
    let markup: DocumentationMarkup
}

struct FunctionSignature {
    let name: String
    let parameters: [Parameter]

    struct Parameter {
        let name: String
        let type: String
        let kind: Kind

        enum Kind {
            case path
            case query
        }
    }
}

/// Extracts routes from Swift source code
package struct RouteExtractor {
    private(set) var docs: [String: [String: Route]] = [:]

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
    var docs: [String: [String: Route]] = [:]

    private var isParsingAPIDeclaration: Bool = false
    private var isInRouteDeclaration: Bool = false

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        return processTypeDeclaration(node)
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        return processTypeDeclaration(node)
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        return processTypeDeclaration(node)
    }

    private func processTypeDeclaration(_ node: any DeclSyntaxProtocol) -> SyntaxVisitorContinueKind {
        // Cast to WithAttributesSyntax to access attributes
        guard let attributedNode = node as? WithAttributesSyntax else {
            return .visitChildren
        }

        guard attributedNode.attributes.first(named: "API") != nil else {
            return .visitChildren
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
            return .visitChildren
        }

        for member in memberBlock.members {
            guard let function = member.decl.as(FunctionDeclSyntax.self) else {
                continue
            }

            guard let routeAttribute = function.attributes.first(named: [
                "HTTP", "GET", "DELETE", "PATCH", "POST", "PUT", "OPTIONS", "HEAD", "TRACE", "CONNECT",
            ]) else {
                continue
            }

            // Handle different types of route attributes
            let routePath: String
            if routeAttribute.attributeName.trimmedDescription == "HTTP" {
                // @HTTP attribute should have arguments
                guard case let .argumentList(arguments) = routeAttribute.arguments else {
                    continue
                }
                routePath = arguments.dropFirst().map(\.trimmedDescription).joined(separator: ", ")
            } else {
                // Other HTTP method attributes (@GET, @POST, etc.) don't have arguments
                // Use the attribute name as the route path
                routePath = routeAttribute.attributeName.trimmedDescription
            }

            let documentationString = function.leadingTrivia.reduce(into: "") { result, piece in
                if case let .docLineComment(string) = piece {
                    if !result.isEmpty {
                        result += "\n"
                    }
                    result += string.trimmingPrefix("/// ")
                }
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

            let markup = DocumentationMarkup(text: documentationString)

            // Initialize the method dictionary if it doesn't exist
            if docs[apiIdentifier] == nil {
                docs[apiIdentifier] = [:]
            }

            // Store the documentation for this method
            docs[apiIdentifier]?[routePath] = Route(markup: markup)
        }

        return .visitChildren
    }
}
