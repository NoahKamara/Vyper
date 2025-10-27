# Vyper

Ergonomic HTTP routing macros for Vapor with first-class OpenAPI and DocC integration.

Vyper lets you declare Vapor routes with simple Swift macros and rich DocC-style documentation, then generates type-safe routing code and OpenAPI metadata automatically.

## Features

- Simple macros for routers and routes: `@Router`, `@GET`, `@POST`, `@PUT`, `@PATCH`, `@DELETE`, `@HEAD`, `@OPTIONS`, `@TRACE`, `@CONNECT`, or the general `@HTTP(_, _:)`
- Typed route parameters via property wrappers like `@Path`, `@Query`, `@Header`, `@Body`, `@Field`, `@Passthrough`
- Vapor-first: builds on `Vapor` and extends `RouteCollection`
- OpenAPI generation powered by `VaporToOpenAPI`
- Documentation-friendly: leverage standard DocC comment sections; traits to exclude or tag docs
- Works with async or sync handlers and Codable payloads

## Quick Start

Add Vyper to your Swift Package:

```swift
// In Package.swift
dependencies: [
    .package(url: "https://github.com/noahkamara/Vyper", branch: "main"),
],
targets: [
    .target(
        name: "App",
        dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Vyper", package: "Vyper"),
        ]
    ),
]
```

Then declare a router and routes:

```swift
import Vyper

@Router("todos")
struct TodosRouter {
    /// Retrieves all todos
    @GET
    func list() -> [Todo] { /* ... */ }

    /// Retrieves a todo by id
    /// - Parameter id: Path component, e.g. /todos/42
    @GET(":id")
    func get(@Path id: Int) async throws -> Todo { /* ... */ }

    /// Creates a new todo from a JSON body
    @POST
    func create(@Body body: Todo.Create, @Passthrough request: Request) throws -> Todo { /* ... */ }
}
```

Register your router in Vapor as you normally would for a `RouteCollection`.

## Parameter Decorators

- `@Path` — decode from path components
- `@Query` — decode from query items
- `@Header` — decode from header values
- `@Body` — decode request body as `Content`
- `@Field` — decode form fields or multipart fields
- `@Passthrough` — access the underlying `Request` or its properties

All parameter types should either be primitive types or conform to `Content`/`Decodable` depending on the context.

## OpenAPI Integration

Vyper integrates with `VaporToOpenAPI` to describe endpoints and schemas. Response content types default to `application/json` but can be customized via types conforming to `CustomContentType`.

## Documentation

The package ships with DocC documentation under `Sources/Vyper/Documentation.docc` including an overview and a Routing guide. You can build docs with the DocC plugin:

```bash
swift package --disable-sandbox preview-documentation --target Vyper
```

### Traits for Docs

- `Trait.excludeFromDocs` — exclude routes or routers from generated docs
- `Trait.tags(_:)` — group routes under custom tags in OpenAPI/DocC contexts

## Examples

See `Sources/VyperClient/CustomTypesExample.swift` for a complete controller using `@Router`, `@GET`, `@POST`, typed parameters, and Codable models.

## Development

Requirements:

- Swift 6 toolchain
- Platforms: macOS 15+, iOS 13+, tvOS 13+, watchOS 6+ (see `Package.swift`)

Build, run tests, and preview docs:

```bash
swift build
swift test
swift package --disable-sandbox preview-documentation --target Vyper
```

## License

Copyright © 2024 Noah Kamara. See license terms in the repository.


