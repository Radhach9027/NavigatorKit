//
//  File.swift
//  NavigatorKit
//
//  Created by radha chilamkurthy on 03/11/25.
//

import Foundation

public final class DeepLinkHandler {
    public static let shared = DeepLinkHandler()
    private init() {}

    public func handle(url: URL) -> Route? {
        guard let host = url.host else { return nil }

        var path = "/\(host)"
        let extraPath = url.path
        if !extraPath.isEmpty, extraPath != "/" {
            path += extraPath
        }

        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        let params: [String: RouteParam]? = queryItems?.reduce(into: [String: RouteParam]()) { dict, item in
            guard let rawValue = item.value?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !rawValue.isEmpty else { return }

            let value = rawValue.lowercased()
            if let intVal = Int(value) {
                dict[item.name] = .int(intVal)
            } else if let doubleVal = Double(value) {
                dict[item.name] = .double(doubleVal)
            } else if ["true", "false", "yes", "no", "1", "0"].contains(value) {
                dict[item.name] = .bool(["true", "yes", "1"].contains(value))
            } else {
                dict[item.name] = .string(rawValue)
            }
        }

        return Route(path: path, params: params, source: .deeplink)
    }
}

