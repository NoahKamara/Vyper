// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Vyper",
    platforms: [.macOS(.v13), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "Vyper",
            targets: ["Vyper"]
        ),
        .executable(
            name: "VyperClient",
            targets: ["VyperClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
        .package(url: "https://github.com/swiftlang/swift-markdown.git", branch: "main"),
        .package(url: "https://github.com/swiftlang/swift-docc-symbolkit.git", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.6.3"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.6"),
    ],
    targets: [
        .target(
            name: "Vyper",
            dependencies: [
                "VyperCore",
                "VyperMacros",
                .product(name: "Vapor", package: "vapor"),
            ]
        ),
        .macro(
            name: "VyperMacros",
            dependencies: [
                "VyperCore",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "VyperCore",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
            ]
        ),
        .executableTarget(
            name: "VyperClient",
            dependencies: [
                "Vyper",
                .product(name: "Vapor", package: "vapor"),
            ]
        ),

        // MARK: OpenAPI Plugin
        .plugin(
            name: "VyperOpenAPIPlugin",
            capability: .buildTool(),
            dependencies: ["VyperOpenAPITool"],
            path: "Sources/VyperOpenAPI/Plugin"
        ),
        .executableTarget(
            name: "VyperOpenAPITool",
            dependencies: ["VyperOpenAPI"],
            path: "Sources/VyperOpenAPI/Tool"
        ),
        .target(
            name: "VyperOpenAPI",
            dependencies: [
                "VyperCore",
                .product(name: "SymbolKit", package: "swift-docc-symbolkit"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "Markdown", package: "swift-markdown"),
            ],
            path: "Sources/VyperOpenAPI/Core"
        ),

        // MARK: Testing
        .testTarget(
            name: "VyperTests",
            dependencies: [
                "VyperMacros",
                "VyperCore",
                "VyperOpenAPI",
                .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
