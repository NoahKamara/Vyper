import Foundation
import SwiftSyntax

struct APIExtractor: SyntaxVisitor {
    var docs: [String: [String: String]] = [:]

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        guard node.attributes?.contains(where: { attr in
            attr.as(AttributeSyntax.self)?.attributeName.description.trimmingCharacters(in: .whitespacesAndNewlines) == "API"
        }) == true else { return .skipChildren }

        let structName = node.identifier.text
        for member in node.members.members {
            guard let funcDecl = member.decl.as(FunctionDeclSyntax.self) else { continue }
            let funcName = funcDecl.identifier.text
            let doc = funcDecl.leadingTrivia?
                .compactMap { piece -> String? in
                    if case let .docLineComment(text) = piece { return text.replacingOccurrences(of: "///", with: "").trimmingCharacters(in: .whitespaces) }
                    else { return nil }
                }
                .joined(separator: "\n") ?? ""

            if !doc.isEmpty {
                docs[structName, default: [:]][funcName] = doc
            }
        }
        return .skipChildren
    }
}

guard CommandLine.arguments.count >= 3 else {
    fatalError("Usage: APIDocExtractor file1.swift file2.swift ... output.swift")
}

let outputPath = CommandLine.arguments.last!
let inputFiles = CommandLine.arguments.dropLast()

var extractor = APIExtractor()

for file in inputFiles {
    let url = URL(fileURLWithPath: file)
    let sourceFile = try Parser.parse(source: SourceFile(url: url))
    extractor.walk(sourceFile)
}

// Generate Swift file
var output = "// Auto-generated API docstrings\n"
output += "public let __api_docstrings: [String: [String: String]] = [\n"

for (structName, funcs) in extractor.docs {
    output += "    \"\(structName)\": [\n"
    for (funcName, doc) in funcs {
        let escaped = doc.replacingOccurrences(of: "\"", with: "\\\"")
        output += "        \"\(funcName)\": \"\(escaped)\",\n"
    }
    output += "    ],\n"
}

output += "]\n"

try output.write(toFile: outputPath, atomically: true, encoding: .utf8)
print("Generated \(outputPath)")
