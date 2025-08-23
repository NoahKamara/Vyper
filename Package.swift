// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Vyper",
    platforms: [.macOS(.v12), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
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
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.6.3"),
    ],
    targets: [
        .target(
            name: "Vyper",
            dependencies: [
                "VyperCore",
                "VyperMacros",
                .product(name: "Vapor", package: "vapor"),
            ],
            plugins: [
                "APIDocPlugin"
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

        .plugin(
            name: "APIDocPlugin",
            capability: .buildTool(),
            path: "Plugins/APIDocPlugin"
        ),

        .executableTarget(
            name: "APIDocExtractor",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
            ]
        ),

        .testTarget(
            name: "VyperTests",
            dependencies: [
                "VyperMacros",
                "VyperCore",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]
        ),
    ]
)
