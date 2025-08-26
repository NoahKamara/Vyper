//
//  TaggedComponents.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import Markdown

/// The list of tags that can appear at the start of a list item to indicate
/// some meaning in the markup, taken from Swift documentation comments. These
/// are maintained for backward compatibility but their use should be
/// discouraged.
private let simpleListItemTags = [
    "attention",
    "author",
    "authors",
    "bug",
    "complexity",
    "copyright",
    "date",
    "experiment",
    "important",
    "invariant",
    "localizationkey",
    "mutatingvariant",
    "nonmutatingvariant",
    "note",
    "postcondition",
    "precondition",
    "remark",
    "remarks",
    "returns",
    "throws",
    "requires",
    "seealso",
    "since",
    "tag",
    "todo",
    "version",
    "warning",
    "keyword",
    "recommended",
    "recommendedover",
]

struct TaggedComponents: MarkupRewriter {
    var parameters = [Parameter]()
    var httpResponses = [HTTPResponse]()
    var httpParameters = [HTTPParameter]()
    var httpBody: HTTPBody?
    var returns = [Return]()
    var `throws` = [Throw]()
    var otherTags = [SimpleTag]()

    init() {}

    mutating func visitDocument(_ document: Document) -> (any Markup)? {
        // First, visit all markup to extract tags
        let processedDocument = Document(document.children
            .compactMap { visit($0) as? (any BlockMarkup) }
        )

        // Then, rewrite top level "- Note:" list elements to Note Aside elements
        var result = [any Markup]()

        for child in processedDocument.children {
            // Only rewrite top-level unordered lists. Anything else is unmodified.
            guard let unorderedList = child as? UnorderedList else {
                result.append(child)
                continue
            }

            // Separate all the "- Note:" elements from the other list items.
            let (noteItems, otherListItems) = unorderedList.listItems
                .categorize(where: { item -> [any BlockMarkup]? in
                    guard let tagName = item.extractTag()?.rawTag.lowercased(),
                          ["note"].contains(tagName) // Simplified to just check for "note"
                    else {
                        return nil
                    }
                    return Array(item.blockChildren)
                })

            // Add the unordered list with the filtered children first.
            result.append(UnorderedList(otherListItems))

            // Then, add the Note asides as siblings after the list they belonged to
            for noteDescription in noteItems {
                result.append(BlockQuote(noteDescription))
            }
        }

        return Document(result.compactMap { $0 as? (any BlockMarkup) })
    }

    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> (any Markup)? {
        var newItems = [ListItem]()
        for item in unorderedList.listItems {
            guard let newItem = visit(item) as? ListItem else {
                continue
            }
            newItems.append(newItem)
        }
        guard !newItems.isEmpty else {
            return nil
        }
        return UnorderedList(newItems)
    }

    mutating func visitListItem(_ listItem: ListItem) -> (any Markup)? {
        /*
         This rewriter only extracts list items that are at the "top level", i.e.:

         Document
         List
         ListItem <- These and no deeper

         Any further nesting is left alone and treated as a normal list item.
         */
        do {
            guard let parent = listItem.parent,
                  parent.parent == nil || parent.parent is Document
            else {
                return listItem
            }
        }

        guard let extractedTag = listItem.extractTag() else {
            return listItem
        }

        switch extractedTag.knownTag {
        case .returns:
            // - Returns: ...
            self.returns.append(.init(extractedTag))

        case .throws:
            // - Throws: ...
            self.throws.append(.init(extractedTag))

        case .parameter(let name):
            // - Parameter x: ...
            self.parameters.append(.init(extractedTag, name: name, isStandalone: true))

        case .parameters:
            // - Parameters:
            //   - x: ...
            //   - y: ...
            self.parameters.append(contentsOf: listItem.extractInnerTagOutline().map { .init(
                $0,
                name: $0.rawTag,
                isStandalone: false
            ) })

        case .httpResponse(let name):
            // - HTTPResponse x: ...
            self.httpResponses.append(.init(extractedTag, name: name))

        case .httpResponses:
            // - HTTPResponses:
            //   - x: ...
            //   - y: ...
            self.httpResponses.append(contentsOf: listItem.extractInnerTagOutline().map { .init(
                $0,
                name: $0.rawTag
            ) })

        case .httpBody:
            // - HTTPBody: ...
            if self.httpBody == nil {
                self.httpBody = HTTPBody(mediaType: nil, contents: extractedTag.contents)
            } else {
                self.httpBody?.contents = extractedTag.contents
            }

        case .httpParameter(let name):
            // - HTTPParameter x: ...
            self.httpParameters.append(.init(extractedTag, name: name))

        case .httpParameters:
            // - HTTPParameters:
            //   - x: ...
            //   - y: ...
            self.httpParameters.append(contentsOf: listItem.extractInnerTagOutline().map { .init(
                $0,
                name: $0.rawTag
            ) })

        case .httpBodyParameter(let name):
            // - HTTPBodyParameter x: ...
            let parameter = HTTPParameter(extractedTag, name: name)
            if self.httpBody == nil {
                self.httpBody = HTTPBody(
                    mediaType: nil,
                    contents: [],
                    parameters: [parameter],
                    symbol: nil
                )
            } else {
                self.httpBody?.parameters.append(parameter)
            }

        case .httpBodyParameters:
            // - HTTPBodyParameters:
            //   - x: ...
            //   - y: ...
            let parameters = listItem.extractInnerTagOutline().map { HTTPParameter(
                $0,
                name: $0.rawTag
            ) }
            if self.httpBody == nil {
                self.httpBody = HTTPBody(
                    mediaType: nil,
                    contents: [],
                    parameters: parameters,
                    symbol: nil
                )
            } else {
                self.httpBody?.parameters.append(contentsOf: parameters)
            }

        case nil where simpleListItemTags.contains(extractedTag.rawTag.lowercased()):
            self.otherTags.append(.init(extractedTag, name: extractedTag.rawTag))

        case nil:
            // No match, leave this list item alone
            return listItem
        }

        // Return `nil` to indicate that this list item was extracted as a tag.
        return nil
    }

    mutating func visitDoxygenParameter(_ doxygenParam: DoxygenParameter) -> (any Markup)? {
        self.parameters.append(Parameter(doxygenParam))
        return nil
    }

    mutating func visitDoxygenReturns(_ doxygenReturns: DoxygenReturns) -> (any Markup)? {
        self.returns.append(Return(doxygenReturns))
        return nil
    }
}

// MARK: Extracting tags information

/// Information about an extracted tag
private struct ExtractedTag {
    /// The raw name of the extracted tag
    var rawTag: String
    /// A known type of tag
    var knownTag: KnownTag?
    /// The range of the raw tag text
    var tagRange: SourceRange?
    /// The complete content related to this tag
    var contents: [any Markup]
    /// The range of the tag and its content
    var range: SourceRange?

    init(rawTag: String, tagRange: SourceRange?, contents: [any Markup], range: SourceRange?) {
        self.rawTag = rawTag
        self.knownTag = .init(rawTag)
        self.tagRange = tagRange
        self.contents = contents
        self.range = range
    }

    enum KnownTag {
        case returns
        case `throws`
        case parameter(String)
        case parameters

        case httpBody
        case httpResponse(String)
        case httpResponses
        case httpParameter(String)
        case httpParameters
        case httpBodyParameter(String)
        case httpBodyParameters

        init?(_ string: String) {
            let separatorIndex = string.firstIndex(where: \.isWhitespace) ?? string.endIndex
            let secondComponent = String(string[separatorIndex...].drop(while: \.isWhitespace))

            switch string[..<separatorIndex].lowercased() {
            case "returns":
                self = .returns
            case "throws":
                self = .throws
            case "parameter" where !secondComponent.isEmpty:
                self = .parameter(secondComponent)
            case "parameters":
                self = .parameters
            case "httpbody":
                self = .httpBody
            case "httpresponse" where !secondComponent.isEmpty:
                self = .httpResponse(secondComponent)
            case "httpresponses":
                self = .httpResponses
            case "httpparameter" where !secondComponent.isEmpty:
                self = .httpParameter(secondComponent)
            case "httpparameters":
                self = .httpParameters
            case "httpbodyparameter" where !secondComponent.isEmpty:
                self = .httpBodyParameter(secondComponent)
            case "httpbodyparameters":
                self = .httpBodyParameters
            default:
                return nil
            }
        }
    }
}

private extension ListItem {
    /// Creates a single "tag" from the list item's content.
    ///
    /// For example, the list item markup:
    /// ```md
    /// - TagName someValue: Some content.
    ///
    ///   More content.
    /// ```
    /// results in a tag with ``ExtractedTag/rawTag`` "TagName someValue" and
    /// ``ExtractedTag/contents`` containing both "Some content." and "More content."
    ///
    /// If the list item doesn't start with a paragraph of text containing a colon (`:`) on the
    /// first line, this function returns `nil`.
    func extractTag() -> ExtractedTag? {
        guard childCount > 0,
              let paragraph = child(at: 0) as? Paragraph,
              let (name, nameRange, remainderOfFirstParagraph) = paragraph.inlineChildren
              .splitNameAndContent()
        else {
            return nil
        }

        return ExtractedTag(
            rawTag: name,
            tagRange: nameRange,
            contents: remainderOfFirstParagraph + children.dropFirst(),
            range: range
        )
    }

    /// Creates a list of "tag" elements from a tag outline (a list item of list items).
    ///
    /// For example, the list item outline markup:
    /// ```md
    /// - TagName:
    ///   - someValue: Some content.
    ///
    ///     More content.
    /// ```
    /// results in one tag with ``ExtractedTag/rawTag`` "someValue" and ``ExtractedTag/contents``
    /// containing both "Some content." and "More content."
    ///
    /// If the list item outline doesn't contain any tags—list items with leading a paragraph that
    /// text containing a colon (`:`) on the first line—this function returns an empty list.
    func extractInnerTagOutline() -> [ExtractedTag] {
        var tags: [ExtractedTag] = []
        for child in children {
            // The list `- TagName:` should have one child, a list of tags.
            guard let list = child as? UnorderedList else {
                // If it's not, that content is dropped.
                continue
            }

            // Those sublist items are assumed to be a valid `- ___: ...` tag form or else they are
            // dropped.
            for child in list.children {
                guard let listItem = child as? ListItem,
                      let extractedTag = listItem.extractTag()
                else {
                    continue
                }
                tags.append(extractedTag)
            }
        }
        return tags
    }
}

private extension Sequence<InlineMarkup> {
    func splitNameAndContent() -> (name: String, nameRange: SourceRange?, content: [any Markup])? {
        var iterator = makeIterator()
        guard let initialTextNode = iterator.next() as? Text else {
            return nil
        }

        let initialText = initialTextNode.string
        guard let colonIndex = initialText.firstIndex(of: ":") else {
            return nil
        }

        let nameStartIndex = initialText[...colonIndex]
            .firstIndex(where: { $0 != " " }) ?? initialText.startIndex
        let tagName = initialText[nameStartIndex..<colonIndex]
        guard !tagName.isEmpty else {
            return nil
        }
        let remainingInitialText = initialText.suffix(from: initialText.index(after: colonIndex))
            .drop { $0 == " " }

        var newInlineContent: [any InlineMarkup] = [Text(String(remainingInitialText))]
        while let more = iterator.next() {
            newInlineContent.append(more)
        }
        let newContent: [any Markup] = [Paragraph(newInlineContent)]

        let nameRange: SourceRange? = initialTextNode.range.map { fullRange in
            var start = fullRange.lowerBound
            start.column += initialText.utf8.distance(
                from: initialText.startIndex,
                to: nameStartIndex
            )
            var end = start
            end.column += tagName.utf8.count
            return start..<end
        }

        return (String(tagName), nameRange, newContent)
    }
}

// MARK: Creating tag types

private extension ExtractedTag {
    func nameRange(name: String) -> SourceRange? {
        if name == self.rawTag {
            self.tagRange
        } else {
            self.tagRange.map { tagRange in
                // For tags like `- TagName someName:`, the extracted tag name is "TagName someName"
                // which means that the name ("someName") is at the end
                let end = tagRange.upperBound
                var start = end
                start.column -= name.utf8.count

                return start..<end
            }
        }
    }
}

private extension Throw {
    init(_ tag: ExtractedTag) {
        self.init(contents: tag.contents)
    }
}

private extension Return {
    init(_ tag: ExtractedTag) {
        self.init(contents: tag.contents, range: tag.range)
    }
}

private extension Parameter {
    init(_ tag: ExtractedTag, name: String, isStandalone: Bool) {
        self.init(
            name: name,
            nameRange: tag.nameRange(name: name),
            contents: tag.contents,
            range: tag.range,
            isStandalone: isStandalone
        )
    }
}

private extension HTTPResponse {
    init(_ tag: ExtractedTag, name: String) {
        self.init(statusCode: UInt(name) ?? 0, reason: nil, mediaType: nil, contents: tag.contents)
    }
}

private extension HTTPParameter {
    init(_ tag: ExtractedTag, name: String) {
        self.init(name: name, source: nil, contents: tag.contents)
    }
}

private extension SimpleTag {
    init(_ tag: ExtractedTag, name: String) {
        self.init(tag: name, contents: tag.contents)
    }
}

extension Sequence {
    /// Splits a sequence into a list of matching elements and a list of non-matching elements.
    ///
    /// - Parameter matches: A closure that takes an element of the sequence as its argument and
    /// returns a `Result` value indicating whether the element should be included in the matching
    /// list.
    /// - Returns: A pair of the matching elements and the remaining elements, that didn't match.
    func categorize<Result>(where matches: (Element) -> Result?)
        -> (matching: [Result], remainder: [Element])
    {
        var matching = [Result]()
        var remainder = [Element]()
        for element in self {
            if let matchingResult = matches(element) {
                matching.append(matchingResult)
            } else {
                remainder.append(element)
            }
        }
        return (matching, remainder)
    }
}
