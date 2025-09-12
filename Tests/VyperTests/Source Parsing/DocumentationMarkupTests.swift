//
//  DocumentationMarkupTests.swift
//
//  Copyright © 2024 Noah Kamara.
//

import InlineSnapshotTesting
import Testing
@testable import VyperMacros

@Suite(.tags(.syntax))
struct DocumentationMarkupTests {
    @Test("Abstract")
    func abstract() async throws {
        let documentation = DocumentationMarkup(text: """
        Lorem ipsum dolor sit amet.
        """)

        assertInlineSnapshot(of: documentation, as: .json) {
            """
            {
              "abstractSection" : [
                "Lorem ipsum dolor sit amet."
              ]
            }
            """
        }
    }

    @Test("Abstract Multiline")
    func multiLineAbstract() async throws {
        let documentation = DocumentationMarkup(text: """
        Lorem ipsum dolor sit amet, consetetur sadipscing elitr. 
        Sed diam nonumy eirmod tempor invidunt ut labore.
        """)

        assertInlineSnapshot(of: documentation, as: .json) {
            """
            {
              "abstractSection" : [
                "Lorem ipsum dolor sit amet, consetetur sadipscing elitr.",
                "",
                "Sed diam nonumy eirmod tempor invidunt ut labore."
              ]
            }
            """
        }
    }

    @Test("Standalone Parameter")
    func standaloneParameter() async throws {
        let documentation = DocumentationMarkup(text: """
        - Parameter parameterName: a parameter name
        """)

        assertInlineSnapshot(of: documentation, as: .json) {
            """
            {
              "discussionSection" : [

              ],
              "discussionTags" : {
                "parameters" : [
                  {
                    "contents" : [
                      "a parameter name"
                    ],
                    "isStandalone" : true,
                    "name" : "parameterName"
                  }
                ]
              }
            }
            """
        }
    }

    @Test("Standalone Parameter multiple")
    func multipleStandaloneParameter() async throws {
        let documentation = DocumentationMarkup(text: """
        Lorem ipsum dolor sit amet.
        - Parameter bar: describing bar parameter
        - Parameter baz: describing baz parameter
        """)

        assertInlineSnapshot(of: documentation, as: .json) {
            """
            {
              "abstractSection" : [
                "Lorem ipsum dolor sit amet."
              ],
              "discussionSection" : [

              ],
              "discussionTags" : {
                "parameters" : [
                  {
                    "contents" : [
                      "describing bar parameter"
                    ],
                    "isStandalone" : true,
                    "name" : "bar"
                  },
                  {
                    "contents" : [
                      "describing baz parameter"
                    ],
                    "isStandalone" : true,
                    "name" : "baz"
                  }
                ]
              }
            }
            """
        }
    }

    @Test("Parameters Section")
    func parameterSection() async throws {
        let documentation = DocumentationMarkup(text: """
        - Parameters:
            - foo: a parameter name
        """)

        assertInlineSnapshot(of: documentation, as: .json) {
            """
            {
              "discussionSection" : [

              ],
              "discussionTags" : {
                "parameters" : [
                  {
                    "contents" : [
                      "a parameter name"
                    ],
                    "isStandalone" : false,
                    "name" : "foo"
                  }
                ]
              }
            }
            """
        }
    }

    @Test("Parameters Section multiple")
    func multipleParameterSection() async throws {
        let documentation = DocumentationMarkup(text: """
        - Parameters:
            - foo: a parameter name
            - bar: a parameter name
        """)

        assertInlineSnapshot(of: documentation, as: .json) {
            """
            {
              "discussionSection" : [

              ],
              "discussionTags" : {
                "parameters" : [
                  {
                    "contents" : [
                      "a parameter name"
                    ],
                    "isStandalone" : false,
                    "name" : "foo"
                  },
                  {
                    "contents" : [
                      "a parameter name"
                    ],
                    "isStandalone" : false,
                    "name" : "bar"
                  }
                ]
              }
            }
            """
        }
    }

    @Test("Throws")
    func throwsDescription() async throws {
        let documentation = DocumentationMarkup(text: """

        - Throws: some error
        """)

        assertInlineSnapshot(of: documentation, as: .json) {
            """
            {
              "discussionSection" : [

              ],
              "discussionTags" : {
                "throws" : [
                  [
                    "some error"
                  ]
                ]
              }
            }
            """
        }
    }

    @Test("Throws multiple")
    func multipleThrowsDescription() async throws {
        let documentation = DocumentationMarkup(text: """

        - Throws: some error
        - Throws: some other error
        """)

        assertInlineSnapshot(of: documentation, as: .json) {
            """
            {
              "discussionSection" : [

              ],
              "discussionTags" : {
                "throws" : [
                  [
                    "some error"
                  ],
                  [
                    "some other error"
                  ]
                ]
              }
            }
            """
        }
    }

    @Test("Returns")
    func returnsStatement() async throws {
        let documentation = DocumentationMarkup(text: """
        - Returns: some return type
        """)

        assertInlineSnapshot(of: documentation, as: .json) {
            """
            {
              "discussionSection" : [

              ],
              "discussionTags" : {
                "returns" : [
                  [
                    "some return type"
                  ]
                ]
              }
            }
            """
        }
    }

    @Test("Returns multiple")
    func multipleReturnsStatement() async throws {
        let documentation = DocumentationMarkup(text: """
        - Returns: some return type
        some more text?
        - Returns: some other return type
        """)

        assertInlineSnapshot(of: documentation, as: .json) {
            #"""
            {
              "discussionSection" : [

              ],
              "discussionTags" : {
                "returns" : [
                  [
                    "some return type\nsome more text?"
                  ],
                  [
                    "some other return type"
                  ]
                ]
              }
            }
            """#
        }
    }
}
