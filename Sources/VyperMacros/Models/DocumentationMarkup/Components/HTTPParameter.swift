//
//  HTTPParameter.swift
//
//  Copyright © 2024 Noah Kamara.
//

public import Markdown
public import SymbolKit

/// Documentation about a parameter for an HTTP request.
public struct HTTPParameter {
    /// The name of the parameter.
    public var name: String
    /// The source of the parameter, such as "query" or "path".
    ///
    /// Value might be undefined initially when first extracted from markdown.
    public var source: String?
    /// The content that describe the parameter.
    public var contents: [any Markup]
    /// The symbol graph symbol representing this parameter.
    public var symbol: SymbolGraph.Symbol?
    /// The required status of the parameter.
    public var required: Bool

    /// Initialize a value to describe documentation about a parameter for an HTTP request symbol.
    /// - Parameters:
    ///   - name: The name of this parameter.
    ///   - source: The source of this parameter, such as "query" or "path".
    ///   - contents: The content that describe this parameter.
    ///   - symbol: The symbol data extracted from the symbol graph.
    ///   - required: Flag indicating whether the parameter is required to be present in the
    /// request.
    public init(
        name: String,
        source: String?,
        contents: [any Markup],
        symbol: SymbolGraph.Symbol? = nil,
        required: Bool = false
    ) {
        self.name = name
        self.source = source
        self.contents = contents
        self.symbol = symbol
        self.required = required
    }
}
