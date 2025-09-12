//
//  DocumentationTrait.swift
//
//  Copyright © 2024 Noah Kamara.
//

import VaporToOpenAPI

public struct DocumentationTrait: Trait, RouteTrait, RouterTrait {
    public init() {}
}

public extension Trait where Self == DocumentationTrait {
    static var excludeFromDocs: Self { Self() }
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

    public var tagObject: TagObject {
        TagObject(name: name, description: description)
    }
}
