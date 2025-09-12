//
//  DocumentationTrait.swift
//  Vyper
//
//  Created by Noah Kamara on 12.09.2025.
//


public struct DocumentationTrait: Trait {
    public init() {}
}

public extension Trait where Self == DocumentationTrait {
    static var excludeFromDocs: Self { Self() }
}

public extension Trait where Self == DocumentationTrait {
    static func tags(_ tags: Tag...) -> Self { Self() }
}

public struct Tag {
    ///  The name of the tag
    public let name: String

    /// A description for the tag. CommonMark syntax MAY be used for rich text representation.
    public let description: String?

    public init(name: String, description: String? = nil) {
        self.name = name
        self.description = description
    }
}
