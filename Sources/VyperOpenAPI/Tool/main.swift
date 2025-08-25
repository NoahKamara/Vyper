////
////  main.swift
////
////  Copyright © 2024 Noah Kamara.
////
//
//import Foundation
//import VyperOpenAPI
//
//guard CommandLine.arguments.count >= 3 else {
//    fatalError("Usage: APIDocExtractor file1.swift file2.swift ... output.swift")
//}
//
//let outputPath = CommandLine.arguments.last!
//let inputFiles = CommandLine.arguments.dropLast()
//
//var extractor = RouteExtractor()
//
//for file in inputFiles {
//    let sourceCode = try String(contentsOfFile: file, encoding: .utf8)
//    extractor.extractDocs(fromSource: sourceCode)
//}
//
//// Generate Swift file
//var output = "// Auto-generated API documentation\n"
//output += "public let __api_docstrings: [String: [String: String]] = [\n"
//
//for (apiIdentifier, methods) in extractor.docs {
//    output += "    \"\(apiIdentifier)\": [\n"
//    for (methodName, documentation) in methods {
//        // Convert documentation to string representation
//        let docString = documentationToString(documentation)
//        let escaped = docString.replacingOccurrences(of: "\"", with: "\\\"")
//        output += "        \"\(methodName)\": \"\(escaped)\",\n"
//    }
//    output += "    ],\n"
//}
//
//output += "]\n"
//
//func documentationToString(_ doc: Documentation) -> String {
//    var result = ""
//
//    if let summary = doc.summary {
//        result += summary + "\n\n"
//    }
//
//    if !doc.parameters.isEmpty {
//        result += "Parameters:\n"
//        for (name, description) in doc.parameters {
//            result += "- \(name): \(description)\n"
//        }
//        result += "\n"
//    }
//
//    if let returns = doc.returns {
//        result += "Returns: \(returns)\n\n"
//    }
//
//    if let throwsDoc = doc.throws {
//        result += "Throws: \(throwsDoc)\n\n"
//    }
//
//    if !doc.discussionParts.isEmpty {
//        result += "Discussion:\n"
//        for part in doc.discussionParts {
//            result += part + "\n"
//        }
//    }
//
//    return result.trimmingCharacters(in: .whitespacesAndNewlines)
//}
//
//try output.write(toFile: outputPath, atomically: true, encoding: .utf8)
//print("Generated \(outputPath)")
