//
//  SimpleTag.swift
//
//  Copyright © 2024 Noah Kamara.
//

public import Markdown

/// A generic documentation tag.
///
/// Write a documentation tag by prepending a line of prose with something like a "- seeAlso:" or "-
/// todo:".
public struct SimpleTag {
    /// The name of the tag.
    public var tag: String

    /// The tagged content.
    public var contents: [any Markup]

    /// Creates a new tagged piece of documentation from the given name and content.
    ///
    /// - Parameters:
    ///   - tag: The name of the tag.
    ///   - contents: The tagged content.
    public init(tag: String, contents: [any Markup]) {
        self.tag = tag
        self.contents = contents
    }
}
