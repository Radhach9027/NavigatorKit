//
//  File.swift
//  NavigatorKit
//
//  Created by radha chilamkurthy on 03/11/25.
//

import SwiftUI

public final class RouteRegistry {
    public static let shared = RouteRegistry()
    private var routes: [String: () -> AnyView] = [:]
    
    private init() {}
    
    public func register(path: String, builder: @escaping () -> AnyView) {
        routes[path] = builder
    }
    
    public func resolve(path: String) -> AnyView? {
        routes[path]?()
    }
    
    public func clear() {
        routes.removeAll()
    }
}

