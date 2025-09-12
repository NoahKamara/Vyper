//
//  Abstract.swift
//
//  Copyright © 2024 Noah Kamara.
//

public import Markdown

/// A one-paragraph section that represents a symbol's abstract description.
public struct AbstractSection {
    public var content: [any Markup] {
        self.paragraph.children.compactMap(\.detachedFromParent)
    }

    /// The section content as a paragraph.
    public var paragraph: Paragraph

    /// Creates a new section with the given paragraph.
    public init(paragraph: Paragraph) {
        self.paragraph = paragraph
    }
}
