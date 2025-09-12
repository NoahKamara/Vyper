//
//  VyperPlugin.swift
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct VyperPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DecoratorMacro.self,
        RouterMacro.self,
        TagMacro.self
    ]
}
