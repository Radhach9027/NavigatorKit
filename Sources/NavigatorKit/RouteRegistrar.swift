//
//  File.swift
//  NavigatorKit
//
//  Created by radha chilamkurthy on 03/11/25.
//

import SwiftUI

public struct RouteRegistrar {
    public static func registerAll(features: [RoutableFeature.Type]) {
        features.forEach { feature in
            feature.routes.forEach { path, view in
                RouteRegistry.shared.register(path: path) {
                    AnyView(view)
                }
            }
        }
    }
}
