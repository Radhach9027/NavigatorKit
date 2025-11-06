//
//  File.swift
//  NavigatorKit
//
//  Created by radha chilamkurthy on 03/11/25.
//

import SwiftUI

@MainActor
public final class RouteRegistry {
    public static let shared = RouteRegistry()

    public typealias Builder = () -> AnyView

    private var routes: [String: Builder] = [:]

    private init() {}

    /// Register a pre-erased builder (kept for backward compat).
    public func register(path: String, builder: @escaping Builder, overwrite: Bool = false) {
        if !overwrite, routes[path] != nil {
            assertionFailure("Route '\(path)' already registered. Pass overwrite: true to replace.")
            return
        }
        routes[path] = builder
    }

    /// Nice generic overload: callers return a View, we erase here.
    public func register<T: View>(
        path: String,
        overwrite: Bool = false,
        @ViewBuilder builder: @escaping () -> T
    ) {
        register(path: path, builder: { AnyView(builder()) }, overwrite: overwrite)
    }

    /// Resolve a builder and build the View.
    public func resolve(path: String) -> AnyView? {
        routes[path]?()
    }

    /// Remove one route.
    public func remove(path: String) {
        routes.removeValue(forKey: path)
    }

    /// Check if a route exists.
    public func contains(_ path: String) -> Bool {
        routes[path] != nil
    }

    /// Inspect registered paths (handy for debugging).
    public var allPaths: [String] {
        Array(routes.keys).sorted()
    }

    /// Remove everything (used in tests or hot reload flows).
    public func clear() {
        routes.removeAll()
    }
}
