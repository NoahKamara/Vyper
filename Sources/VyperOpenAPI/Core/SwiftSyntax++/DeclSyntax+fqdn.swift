//
//  DeclSyntax+fqdn.swift
//  VyperOpenAPI
//
//  Created by Noah Kamara on 24.08.2025.
//

import SwiftSyntax

extension DeclSyntaxProtocol where Self: NamedDeclSyntax {
    /// Builds a qualified name for a function declaration
    /// - Parameter function: The function declaration syntax
    /// - Returns: A qualified name like "StructName.functionName"
    func buildFQDN(for function: FunctionDeclSyntax) -> String {
        let functionName = function.name.text

        // Get the containing type name
        let typeName = name.text

        // Since all files are from the same module, just use TypeName.functionName
        return "\(typeName).\(functionName)"
    }
}
