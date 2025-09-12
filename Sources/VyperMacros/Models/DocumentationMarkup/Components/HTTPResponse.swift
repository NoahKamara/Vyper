//
//  HTTPResponse.swift
//
//  Copyright © 2024 Noah Kamara.
//

public import Markdown
public import SymbolKit

/// Documentation about the response for an HTTP request symbol.
public struct HTTPResponse {
    /// The HTTP status code of the response.
    public var statusCode: UInt
    /// The HTTP code description string.
    public var reason: String?
    /// The media type of the response.
    ///
    /// Value might be undefined initially when first extracted from markdown.
    public var mediaType: String?
    /// The content that describe the response.
    public var contents: [any Markup]
    /// The symbol graph symbol representing this response.
    public var symbol: SymbolGraph.Symbol?

    /// Initialize a value to describe documentation about a dictionary key for a symbol.
    /// - Parameters:
    ///   - statusCode: The status code of the response.
    ///   - reason: The status reason message of the response.
    ///   - mediaType: The media type of the response.
    ///   - contents: The content that describe this response.
    ///   - symbol: The symbol data extracted from the symbol graph.
    public init(
        statusCode: UInt,
        reason: String?,
        mediaType: String?,
        contents: [any Markup],
        symbol: SymbolGraph.Symbol? = nil
    ) {
        self.statusCode = statusCode
        self.reason = reason
        self.mediaType = mediaType
        self.contents = contents
        self.symbol = symbol
    }
}
