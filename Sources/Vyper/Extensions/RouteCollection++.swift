//
//  RouteCollection++.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Vapor
import VaporToOpenAPI

public extension RouteCollection {
    static func responseContentType(for type: Any.Type) -> MediaType {
        switch type {
        case let custom as CustomContentType.Type:
            custom.contentType
        default:
            .application(.json)
        }
    }
}
