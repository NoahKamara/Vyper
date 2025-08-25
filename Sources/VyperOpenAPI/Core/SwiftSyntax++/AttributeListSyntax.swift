//
//  File.swift
//  VyperOpenAPI
//
//  Created by Noah Kamara on 24.08.2025.
//

import SwiftSyntax

extension AttributeListSyntax {
    func first(named name: String) -> AttributeSyntax? {
        compactMap { $0.as(AttributeSyntax.self) }
            .first(where: { $0.attributeName.trimmedDescription == name })
    }

    func first(named names: [String]) -> AttributeSyntax? {
        compactMap { $0.as(AttributeSyntax.self) }
            .first(where: { names.contains($0.attributeName.trimmedDescription) })
    }
}
