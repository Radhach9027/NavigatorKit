//
//  NavigationHost.swift
//  NavigatorKit
//
//  Created by radha chilamkurthy on 03/11/25.
//

import SwiftUI

@available(iOS 15.0, *)
public struct NavigationHost<Root: View>: View {
    @ObservedObject private var coordinator: NavigationCoordinator
    private let root: Root
    
    @State private var isPushActive = false
    @State private var sheetRoute: Route?
    @State private var fullScreenRoute: Route?
    
    public init(
        coordinator: NavigationCoordinator,
        @ViewBuilder root: () -> Root
    ) {
        self.coordinator = coordinator
        self.root = root()
    }
    
    public var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                navigationStackHost
            } else {
                navigationViewHost
            }
        }
        .onOpenURL { url in
            if let route = DeepLinkHandler.shared.handle(url: url) {
                coordinator.navigate(to: route)
            }
        }
    }
    
    // MARK: - iOS 16+ NavigationStack Host
    @available(iOS 16.0, *)
    private var navigationStackHost: some View {
        NavigationStack {
            ZStack {
                root
                    .background(
                        NavigationLink(
                            destination: destinationForCurrentRoute(),
                            isActive: $isPushActive
                        ) { EmptyView() }
                            .hidden()
                    )
            }
            .sheet(item: $sheetRoute) { route in
                coordinator.destinationView(for: route)
            }
            .fullScreenCover(item: $fullScreenRoute) { route in
                coordinator.destinationView(for: route)
            }
        }
        .onReceive(coordinator.$currentRoute) { handleNavigation(for: $0) }
    }
    
    // MARK: - iOS 15 Fallback (NavigationView)
    private var navigationViewHost: some View {
        NavigationView {
            ZStack {
                root
                    .background(
                        NavigationLink(
                            destination: destinationForCurrentRoute(),
                            isActive: $isPushActive
                        ) { EmptyView() }
                            .hidden()
                    )
            }
            .sheet(item: $sheetRoute) { route in
                coordinator.destinationView(for: route)
            }
            .fullScreenCover(item: $fullScreenRoute) { route in
                coordinator.destinationView(for: route)
            }
        }
        .navigationViewStyle(.stack)
        .onReceive(coordinator.$currentRoute) { handleNavigation(for: $0) }
    }
    
    @ViewBuilder
    private func destinationForCurrentRoute() -> some View {
        if let route = coordinator.currentRoute {
            coordinator.destinationView(for: route)
        } else {
            EmptyView()
        }
    }
    
    private func handleNavigation(for route: Route?) {
        guard let route else { return }
        switch route.presentation {
        case .push:
            isPushActive = true
        case .sheet, .modal:
            sheetRoute = route
        case .fullScreen:
            fullScreenRoute = route
        }
    }
}
