//
//  APIDocPlugin.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import PackagePlugin

@main
struct APIDocPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        // Directory for generated Swift file
        let outputDir = context.pluginWorkDirectoryURL
        let outputFile = outputDir.appendingPathComponent("GeneratedDocs.swift")

        // Find all Swift source files in the target
        let swiftFiles = (target as? SourceModuleTarget)?.sourceFiles
            .filter { $0.url.pathExtension == "swift" } ?? []

        // Generate a command to run this plugin as a tool
        return try [
            .buildCommand(
                displayName: "Generating API docstrings",
                executable: context.tool(named: "VyperOpenAPITool").url,
                arguments: swiftFiles.map(\.url.path),
                environment: [:],
                inputFiles: swiftFiles.map(\.url),
                outputFiles: [outputFile]
            ),
        ]
    }
}
