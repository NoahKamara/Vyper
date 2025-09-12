// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Vyper",
    platforms: [.macOS(.v15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
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
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.5"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
        .package(url: "https://github.com/swiftlang/swift-markdown.git", branch: "main"),
        .package(url: "https://github.com/swiftlang/swift-docc-symbolkit.git", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.6.3"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.6"),
        .package(url: "https://github.com/dankinsoid/SwiftOpenAPI", from: "2.24.1"),
        .package(path: "../VaporToOpenAPI"),
    ],
    targets: [
        .target(
            name: "Vyper",
            dependencies: [
                "VaporToOpenAPI",
                "VyperMacros",
                .product(name: "Vapor", package: "vapor"),
            ]
        ),
        .macro(
            name: "VyperMacros",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SymbolKit", package: "swift-docc-symbolkit"),
                .product(name: "Markdown", package: "swift-markdown"),
            ]
        ),
        .executableTarget(
            name: "VyperClient",
            dependencies: [
                "Vyper",
                .product(name: "Vapor", package: "vapor"),
            ]
        ),
        .testTarget(
            name: "VyperTests",
            dependencies: [
                "VyperMacros",
                "SwiftOpenAPI",
                .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
