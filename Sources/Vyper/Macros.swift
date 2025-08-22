//
//  Macros.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import Vapor

// MARK: Protocol attributes

@attached(extension, names: named(boot))
public macro API(_ typeName: String? = nil) = #externalMacro(
    module: "VyperMacros",
    type: "APIMacro"
)

// MARK: Function or Protocol attributes

// @attached(peer)
// public macro Headers(_ headers: [String: String]) = #externalMacro(module: "VyperMacros", type:
// "DecoratorMacro")
// @attached(peer)
// public macro JSON(encoder: JSONEncoder = JSONEncoder(), decoder: JSONDecoder = JSONDecoder()) =
// #externalMacro(module: "VyperMacros", type: "DecoratorMacro")
// @attached(peer)
// public macro URLForm(_ encoder: URLEncodedFormEncoder = URLEncodedFormEncoder()) =
// #externalMacro(module: "VyperMacros", type: "DecoratorMacro")
//
// @attached(peer)
// public macro Multipart(_ encoder: MultipartEncoder = MultipartEncoder()) = #externalMacro(module:
// "VyperMacros", type: "DecoratorMacro")
//
// @attached(peer)
// public macro Converter(encoder: RequestEncoder, decoder: ResponseDecoder) =
// #externalMacro(module: "VyperMacros", type: "DecoratorMacro")
//
// @attached(peer)
// public macro KeyMapping(_ mapping: KeyMapping) = #externalMacro(module: "VyperMacros", type:
// "DecoratorMacro")
//
// @attached(peer)
// public macro Authorization(_ value: RequestBuilder.AuthorizationHeader) = #externalMacro(module:
// "VyperMacros", type: "DecoratorMacro")

// MARK: HTTP Routes

@attached(peer)
public macro HTTP(
    _ method: HTTPMethod,
    _ path: PathComponent...
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

@attached(peer)
public macro DELETE(
    _ path: PathComponent...
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

@attached(peer)
public macro GET(
    _ path: PathComponent...
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

@attached(peer)
public macro PATCH(
    _ path: PathComponent...
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

@attached(peer)
public macro POST(
    _ path: PathComponent...
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

@attached(peer)
public macro PUT(
    _ path: PathComponent...
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

@attached(peer)
public macro OPTIONS(
    _ path: PathComponent...
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

@attached(peer)
public macro HEAD(
    _ path: PathComponent...
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

@attached(peer)
public macro TRACE(
    _ path: PathComponent...
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

@attached(peer)
public macro CONNECT(
    _ path: PathComponent...
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

// MARK: Parameter attributes

/*

 Macros are no longer allowed on function parameters. We'll have to use the
 typealiases below until they are again.

 https://forums.swift.org/t/accessor-macro-cannot-be-attached-to-a-parameter/66669/6

 @attached(accessor)
 public macro Header(_ key: String? = nil) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

 @attached(accessor)
 public macro Query(_ key: String? = nil) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

 @attached(accessor)
 public macro Path(_ key: String? = nil) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

 @attached(accessor)
 public macro Field(_ key: String? = nil) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

 @attached(accessor)
 public macro Body() = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

 */
