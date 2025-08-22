//
//  VyperMacrosError.swift
//
//  Copyright © 2024 Noah Kamara.
//

public struct VyperMacrosError: Error, CustomStringConvertible {
    public let message: String

    init(_ message: String) {
        self.message = message
    }

    public var description: String {
        self.message
    }
}
