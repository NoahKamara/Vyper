import PackagePlugin
import Foundation

@main
struct APIDocPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        // Directory for generated Swift file
        let outputDir = context.pluginWorkDirectory
        let outputFile = outputDir.appending("GeneratedDocs.swift")

        // Find all Swift source files in the target
        let swiftFiles = target.sourceFiles(withSuffix: ".swift")

        // Generate a command to run this plugin as a tool
        return [
            .buildCommand(
                displayName: "Generating API docstrings",
                executable: try context.tool(named: "APIDocExtractor").path,
                arguments: swiftFiles.map { $0.path.string } + [outputFile.string],
                environment: [:],
                outputFilesDirectory: outputDir
            )
        ]
    }
}
