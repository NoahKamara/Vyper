//
//  RouterDescriptor.swift
//  Vyper
//
//  Created by Noah Kamara on 12.09.2025.
//


struct RouterDescriptor {
    var name: String
    let routes: [RouteDescriptor]

    package init(name: String, routes: [RouteDescriptor]) {
        self.name = name
        self.routes = routes
    }
}
