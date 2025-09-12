//
//  Macros.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import Vapor

// MARK: Protocol attributes

@attached(extension, conformances: RouteCollection, names: named(boot))
public macro Router(_ path: PathComponent..., traits: Trait...) = #externalMacro(
    module: "VyperMacros",
    type: "RouterMacro"
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
public macro Schema(
    exclude: Bool? = nil
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

@attached(peer)
public macro HTTP(
    _ method: HTTPMethod,
    _ path: PathComponent...
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

@attached(peer)
public macro DELETE<each T: RouteTrait>(
    _ path: PathComponent...,
    traits: repeat each T
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

@attached(peer)
public macro GET<each T: RouteTrait>(
    _ path: PathComponent...,
    traits: repeat each T
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

@attached(peer)
public macro PATCH<each T: RouteTrait>(
    _ path: PathComponent...,
    traits: repeat each T
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

@attached(peer)
public macro POST<each T: RouteTrait>(
    _ path: PathComponent...,
    traits: repeat each T
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

@attached(peer)
public macro PUT<each T: RouteTrait>(
    _ path: PathComponent...,
    traits: repeat each T
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

@attached(peer)
public macro OPTIONS<each T: RouteTrait>(
    _ path: PathComponent...,
    traits: repeat each T
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

@attached(peer)
public macro HEAD<each T: RouteTrait>(
    _ path: PathComponent...,
    traits: repeat each T
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

@attached(peer)
public macro TRACE<each T: RouteTrait>(
    _ path: PathComponent...,
    traits: repeat each T
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")

@attached(peer)
public macro CONNECT<each T: RouteTrait>(
    _ path: PathComponent...,
    traits: repeat each T
) = #externalMacro(module: "VyperMacros", type: "DecoratorMacro")


// MARK: Parameter attributes

@attached(accessor)
public macro Tag() = #externalMacro(module: "VyperMacros", type: "TagMacro")
