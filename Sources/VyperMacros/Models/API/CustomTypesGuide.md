# Handling Custom Types in OpenAPI Macro

## Overview

Your macro needs to handle both built-in Swift types and custom types that users define. This guide explains the different approaches and considerations.

## Built-in vs Custom Types

### Built-in Swift Types
- **String, Int, Bool, Float, Double**: Map directly to OpenAPI primitive types
- **Array<T>**: Map to OpenAPI array type
- **Optional<T>**: Handle required/optional logic

### Custom Types
- **User-defined structs/classes**: Need special handling
- **Third-party types**: May need custom schema generation
- **Generic types**: Require type parameter resolution

## Approaches for Custom Types

### Approach 1: Schema References (Recommended)

Reference custom types in the `#/components/schemas/` section:

```swift
// For a custom type like Todo
ParameterObject(
    name: "todo",
    in: .body,
    required: true,
    schema: ReferenceOr.schema(
        SchemaObject(ref: "#/components/schemas/Todo")
    )
)
```

**Benefits:**
- Clean separation of concerns
- Reusable across multiple endpoints
- Better OpenAPI documentation
- Easier to maintain

### Approach 2: Inline Schema Generation

Generate the schema inline for simple custom types:

```swift
ParameterObject(
    name: "todo",
    in: .body,
    required: true,
    schema: SchemaObject(
        type: "object",
        properties: [
            "id": SchemaObject.string,
            "title": SchemaObject.string,
            "isCompleted": SchemaObject.boolean
        ]
    )
)
```

**Benefits:**
- Self-contained
- No external references
- Good for simple types

**Drawbacks:**
- Can become verbose
- Duplication across endpoints
- Harder to maintain

## Implementation Strategy

### 1. Type Detection

```swift
private static func isCustomType(_ typeName: String) -> Bool {
    let standardTypes: Set<String> = [
        "String", "Int", "Bool", "Float", "Double", "Date", "URL", "UUID",
        "Array", "Dictionary", "Set", "Optional"
    ]
    
    let cleanType = typeName.replacingOccurrences(of: "?", with: "")
    return !standardTypes.contains(cleanType)
}
```

### 2. Schema Generation

```swift
private static func buildCustomTypeSchema(for typeName: String) -> ExprSyntax {
    let cleanType = typeName.replacingOccurrences(of: "?", with: "")
    
    // Option 1: Reference to components/schemas
    return FunctionCallExprSyntax(
        calledExpression: MemberAccessExprSyntax(
            base: DeclReferenceExprSyntax(baseName: .identifier("ReferenceOr")),
            name: .identifier("schema")
        ),
        arguments: [
            LabeledExprSyntax(
                expression: FunctionCallExprSyntax(
                    calledExpression: DeclReferenceExprSyntax(baseName: .identifier("SchemaObject")),
                    arguments: [
                        LabeledExprSyntax(
                            label: "ref",
                            expression: StringLiteralExprSyntax(content: "#/components/schemas/\(cleanType)")
                        )
                    ]
                )
            )
        ]
    )
}
```

### 3. Components Generation

You'll also need to generate the components/schemas section:

```swift
// In your main OpenAPI generation
.openAPI(custom: \.components, ComponentsObject(
    schemas: [
        "Todo": SchemaObject(
            type: "object",
            properties: [
                "id": SchemaObject.string,
                "title": SchemaObject.string,
                "isCompleted": SchemaObject.boolean
            ]
        )
    ]
))
```

## Special Cases

### 1. Generic Types

```swift
// Handle Array<T>, Optional<T>, etc.
case let type where type.hasPrefix("Array<") || type.hasPrefix("Optional<"):
    let innerType = extractInnerType(from: type)
    return buildGenericTypeSchema(wrapper: "array", innerType: innerType)
```

### 2. Nested Custom Types

```swift
struct User {
    let profile: UserProfile  // Nested custom type
    let preferences: [String: Any]  // Dictionary with custom values
}
```

### 3. Protocol Conformance

```swift
// If a custom type conforms to Codable, Identifiable, etc.
// Use that information to generate better schemas
```

## Best Practices

### 1. Always Reference Complex Types
- Use `#/components/schemas/` for structs, classes
- Keep inline schemas for simple types only

### 2. Handle Optionality Properly
- Map `T?` to `required: false`
- Map `T` to `required: true`

### 3. Generate Meaningful Descriptions
- Use property names and types
- Add documentation comments if available

### 4. Support Common Patterns
- Codable conformance
- Identifiable conformance
- Custom coding keys

## Example Implementation

```swift
// In your APIBuilder
private static func buildParameterObject(
    parameter: APIRoute.Parameter
) throws -> FunctionCallExprSyntax {
    var arguments: [LabeledExprSyntax] = [
        // Basic properties...
    ]
    
    // Handle schema based on type
    if isCustomType(parameter.type) {
        let schema = buildCustomTypeSchema(for: parameter.type)
        arguments.append(LabeledExprSyntax(
            label: "schema",
            expression: schema
        ))
    } else {
        let schema = buildPrimitiveSchema(for: parameter.type)
        arguments.append(LabeledExprSyntax(
            label: "schema",
            expression: schema
        ))
    }
    
    return FunctionCallExprSyntax(
        calledExpression: DeclReferenceExprSyntax(baseName: .identifier("ParameterObject")),
        arguments: .init(arguments)
    )
}
```

## Testing Custom Types

Test your macro with various custom type scenarios:

1. **Simple structs** with basic properties
2. **Complex types** with nested objects
3. **Generic types** like `Array<T>`, `Optional<T>`
4. **Protocol conforming types** like `Codable`, `Identifiable`
5. **Third-party types** that users might import

This approach gives you a robust foundation for handling both built-in and custom types while maintaining clean, maintainable OpenAPI documentation.
