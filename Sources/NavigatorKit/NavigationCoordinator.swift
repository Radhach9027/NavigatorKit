//
//  File.swift
//  NavigatorKit
//
//  Created by radha chilamkurthy on 03/11/25.
//

import SwiftUI

@MainActor
public final class NavigationCoordinator: ObservableObject {
    @Published public var currentRoute: Route?
    
    public init() {}
    
    public func navigate(to route: Route) {
        currentRoute = route
    }
    
    public func navigate(
        path: String,
        params: [String: RouteParam]? = nil,
        presentation: PresentationStyle = .push
    ) {
        currentRoute = Route(path: path, params: params, presentation: presentation)
    }
    
    @ViewBuilder
    public func destinationView(for route: Route) -> some View {
        if let resolved = RouteRegistry.shared.resolve(path: route.path) {
            resolved
        } else {
            Text("⚠️ Route not found: \(route.path)")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}
