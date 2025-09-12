//
//  Extensions.swift
//  Vyper
//
//  Created by Noah Kamara on 30.08.2025.
//

import VaporToOpenAPI
import Vapor

extension RouteCollection {
    public static func responseContentType(for type: Any.Type) -> MediaType {
        switch type {
        case let custom as CustomContentType.Type:
            return custom.contentType
        default:
            return .application(.json)
        }
    }
}

