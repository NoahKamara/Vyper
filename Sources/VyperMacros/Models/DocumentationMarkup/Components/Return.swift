//
//  Return.swift
//
//  Copyright © 2024 Noah Kamara.
//

public import Markdown

/// Documentation about a symbol's return value.
public struct Return {
    /// The content that describe the return value for a symbol.
    public var contents: [any Markup]
    /// The text range where this return value was parsed.
    var range: SourceRange?

    /// Initialize a value to describe documentation about a symbol's return value.
    /// - Parameters:
    ///   - contents: The content that describe the return value for this symbol.
    ///   - range: The text range where this return value was parsed.
    public init(contents: [any Markup], range: SourceRange? = nil) {
        self.contents = contents
        self.range = range
    }

    /// Initialize a value to describe documentation about a symbol's return value.
    ///
    /// - Parameter doxygenReturns: A parsed Doxygen `\returns` command.
    public init(_ doxygenReturns: DoxygenReturns) {
        self.contents = Array(doxygenReturns.children)
        self.range = doxygenReturns.range
    }

    public func format() -> String {
        self.contents.reduce(into: "") { partialResult, content in
            partialResult += content.format()
        }
    }
}
