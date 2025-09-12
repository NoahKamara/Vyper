//
//  DocumentationMarkup+Codable.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

// import Markdown
import SymbolKit
@testable import VyperMacros

extension DocumentationMarkup: Encodable {
    private enum CodingKeys: String, CodingKey {
        case abstractSection
        case discussionSection
        case discussionTags
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(abstractSection, forKey: .abstractSection)
        try container.encodeIfPresent(discussionSection, forKey: .discussionSection)
        try container.encodeIfPresent(discussionTags, forKey: .discussionTags)
    }
}

// MARK: - AbstractSection

extension AbstractSection: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        // Convert Markup to serializable content
        let content = content.map { $0.format() }
        try container.encode(content)
    }
}

// MARK: - DiscussionSection

extension DiscussionSection: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let content = content.map { $0.format() }
        try container.encode(content)
    }
}

// MARK: - TaggedComponents

extension TaggedComponents: Encodable {
    private enum CodingKeys: String, CodingKey {
        case parameters
        case httpResponses
        case httpParameters
        case httpBody
        case returns
        case `throws`
        case otherTags
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfNotEmpty(parameters, forKey: .parameters)
        try container.encodeIfNotEmpty(httpResponses, forKey: .httpResponses)
        try container.encodeIfNotEmpty(httpParameters, forKey: .httpParameters)
        try container.encodeIfPresent(httpBody, forKey: .httpBody)
        try container.encodeIfNotEmpty(returns, forKey: .returns)
        try container.encodeIfNotEmpty(`throws`, forKey: .throws)
        try container.encodeIfNotEmpty(otherTags, forKey: .otherTags)
    }
}

extension KeyedEncodingContainerProtocol {
    mutating func encodeIfNotEmpty(_ value: [some Encodable], forKey key: Key) throws {
        if !value.isEmpty {
            try encode(value, forKey: key)
        }
    }
}

extension Parameter: Encodable {
    private enum CodingKeys: String, CodingKey {
        case name
        case contents
        case nameRange
        case range
        case isStandalone
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)
        let contents = contents.map { $0.format() }
        try container.encode(contents, forKey: .contents)
        // Note: SourceRange is not Codable, so we skip encoding these properties
        // try container.encodeIfPresent(nameRange, forKey: .nameRange)
        // try container.encodeIfPresent(range, forKey: .range)
        try container.encode(isStandalone, forKey: .isStandalone)
    }
}

extension Return: Encodable {
    private enum CodingKeys: String, CodingKey {
        case contents
        case range
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let contents = contents.map { $0.format() }
        try container.encode(contents)
    }
}

extension Throw: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let contents = contents.map { $0.format() }
        try container.encode(contents)
    }
}

extension HTTPBody: Encodable {
    private enum CodingKeys: String, CodingKey {
        case mediaType
        case parameters
        case contents
        case symbol
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(mediaType, forKey: .mediaType)
        try container.encode(parameters, forKey: .parameters)
        let contents = contents.map { $0.format() }
        try container.encode(contents, forKey: .contents)
        // Note: SymbolGraph.Symbol is not Codable, so we skip encoding this property
        // try container.encodeIfPresent(symbol, forKey: .symbol)
    }
}

extension HTTPParameter: Encodable {
    private enum CodingKeys: String, CodingKey {
        case name
        case source
        case contents
        case symbol
        case required
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(source, forKey: .source)
        let contents = contents.map { $0.format() }
        try container.encode(contents, forKey: .contents)
        // Note: SymbolGraph.Symbol is not Codable, so we skip encoding this property
        // try container.encodeIfPresent(symbol, forKey: .symbol)
        try container.encode(required, forKey: .required)
    }
}

extension HTTPResponse: Encodable {
    private enum CodingKeys: String, CodingKey {
        case statusCode
        case reason
        case mediaType
        case contents
        case symbol
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(statusCode, forKey: .statusCode)
        try container.encodeIfPresent(reason, forKey: .reason)
        try container.encodeIfPresent(mediaType, forKey: .mediaType)
        let contents = contents.map { $0.format() }
        try container.encode(contents, forKey: .contents)
        // Note: SymbolGraph.Symbol is not Codable, so we skip encoding this property
        try container.encodeIfPresent(symbol?.kind.identifier.identifier, forKey: .symbol)
    }
}

extension SimpleTag: Encodable {
    private enum CodingKeys: String, CodingKey {
        case tag
        case contents
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(tag, forKey: .tag)
        let contents = contents.map { $0.format() }
        try container.encode(contents, forKey: .contents)
    }
}

extension ParametersSection: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(parameters)
    }
}

extension ReturnsSection: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let contents = content.map { $0.format() }
        try container.encode(contents)
    }
}
