//
//  Discussion.swift
//
//  Copyright © 2024 Noah Kamara.
//

public import Markdown

public struct DiscussionSection {
    public var content: [any Markup]

    /// Creates a new discussion section with the given markup content.
    public init(content: [any Markup]) {
        self.content = content
    }

    public func format() -> String {
        self.content.map { $0.format() }.joined(separator: "\n\n")
    }
}
