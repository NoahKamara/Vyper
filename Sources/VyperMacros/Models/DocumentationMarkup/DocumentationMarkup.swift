//
//  DocumentationMarkup.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import Markdown

/// A structured documentation markup data model.
///
/// ## Discussion
/// `DocumentationMarkup` parses a given piece of structured markup and provides access to the
/// documentation content.
///
/// ### Abstract
/// The parser parses the abstract from the first leading paragraph (skipping the comments) in the
/// markup after the title. If the markup doesn't start with a paragraph after the title heading,
/// it's considered to not have an abstract.
/// ```
/// # My Document
/// An abstract shortly describing My Document.
/// ```
/// ### Discussion
/// The parser parses the discussion from the end of the abstract section until the end of the
/// document.
/// ```
/// # My Document
/// An abstract shortly describing My Document.
/// ## Discussion
/// A discussion that may contain further level-3 sub-sections, text, images, etc.
/// ```
struct DocumentationMarkup {
    /// The original markup.
    private let markup: any Markup

    /// The various sections that are expected in documentation markup.
    ///
    /// The cases in this enumeration are sorted in the order sections are expected to appear in the
    /// documentation markup.
    enum ParserSection: Int, Comparable {
        static func < (
            lhs: DocumentationMarkup.ParserSection,
            rhs: DocumentationMarkup.ParserSection
        ) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        case abstract
        case discussion
        case end
    }

    // MARK: - Parsed Data

    /// The documentation abstract, if found.
    private(set) var abstractSection: AbstractSection?

    /// The documentation Discussion section, if found.
    private(set) var discussionSection: DiscussionSection?

    /// The documentation tags, if found.
    private(set) var discussionTags: TaggedComponents?

    // MARK: - Initialize and parse the markup

    /// Initialize a documentation model with the given markup.
    /// - Parameters:
    ///   - markup: The source markup.
    ///   - parseUpToSection: Documentation past this section will be ignored.
    init(markup: any Markup, parseUpToSection: ParserSection = .end) {
        self.markup = markup

        // The current documentation section being parsed.
        var currentSection = ParserSection.abstract

        // Tracking the start index of discussion section.
        var discussionIndex: Int?

        // Index all headings as a lookup during parsing the content
        for pair in markup.children.enumerated() {
            // If we've parsed the last section we're interested in, skip through the rest
            guard currentSection <= parseUpToSection || currentSection == .end else { continue }

            let (index, child) = pair
            let isLastChild = index == (markup.childCount - 1)

            // Already parsed all expected content, return.
            guard currentSection != .end else { continue }

            // Parse an abstract, if found
            if currentSection == .abstract {
                if self.abstractSection == nil, let firstParagraph = child as? Paragraph {
                    self.abstractSection = AbstractSection(paragraph: firstParagraph)
                    continue
                } else if child is BlockDirective {
                    currentSection = .discussion
                } else if let _ = child as? HTMLBlock {
                    // Skip HTMLBlock comment.
                    continue
                } else {
                    // Only directives and a single paragraph allowed in an abstract,
                    // advance to a discussion section.
                    currentSection = .discussion
                }
            }

            // Parse content into a discussion section and assorted tags
            let parseDiscussion: ([any Markup]) -> (
                discussion: DiscussionSection,
                tags: TaggedComponents
            ) = { children in
                // Extract tags
                var extractor = TaggedComponents()
                let content: [any Markup] = if let remainder = extractor
                    .visit(markup.withUncheckedChildren(children))
                {
                    Array(remainder.children)
                } else {
                    []
                }

                return (discussion: DiscussionSection(content: content), tags: extractor)
            }

            // Parse a discussion, if found
            if currentSection == .discussion {
                // Discussion content starts at this index
                if discussionIndex == nil {
                    discussionIndex = index
                }

                guard let discussionIndex else { continue }

                // If at end of content, parse discussion
                if isLastChild {
                    let (
                        discussion,
                        tags
                    ) = parseDiscussion(markup.children(at: discussionIndex...index))
                    self.discussionSection = discussion
                    self.discussionTags = tags
                }
            }
        }
    }
}

// MARK: - Convenience Markup extensions

extension Markup {
    /// Returns a sub-sequence of the children sequence.
    /// - Parameter range: A closed range.
    /// - Returns: A children sub-sequence.
    func children(at range: ClosedRange<Int>) -> [any Markup] {
        var iterator = self.children.makeIterator()
        var counter = 0
        var result = [any Markup]()

        while let next = iterator.next() {
            defer { counter += 1 }
            guard counter <= range.upperBound else { break }
            guard counter >= range.lowerBound else { continue }
            result.append(next)
        }
        return result
    }

    /// Returns a sub-sequence of the children sequence.
    /// - Parameter range: A half-closed range.
    /// - Returns: A children sub-sequence.
    func children(at range: Range<Int>) -> [any Markup] {
        var iterator = self.children.makeIterator()
        var counter = 0
        var result = [any Markup]()

        while let next = iterator.next() {
            defer { counter += 1 }
            guard counter < range.upperBound else { break }
            guard counter >= range.lowerBound else { continue }
            result.append(next)
        }
        return result
    }
}

extension DocumentationMarkup {
    init(text: String) {
        let document = Markdown.Document(parsing: text, options: [.parseSymbolLinks])
        self.init(markup: document)
    }
}
