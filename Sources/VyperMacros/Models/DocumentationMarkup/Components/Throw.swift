//
//  Throw.swift
//
//  Copyright © 2024 Noah Kamara.
//

public import Markdown

/// Documentation about a symbol's potential errors.
public struct Throw {
    /// The content that describe potential errors for a symbol.
    public var contents: [any Markup]

    /// Initialize a value to describe documentation about a symbol's potential errors.
    /// - Parameter contents: The content that describe potential errors for this symbol.
    public init(contents: [any Markup]) {
        self.contents = contents
    }
}
