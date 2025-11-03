//
//  File.swift
//  NavigatorKit
//
//  Created by radha chilamkurthy on 03/11/25.
//

import Foundation

public struct Route: Codable, Hashable, Identifiable {
    public var id: String { path }
    public let path: String
    public let params: [String: RouteParam]?
    public let source: RouteSource
    public let presentation: PresentationStyle
    
    public init(
        path: String,
        params: [String: RouteParam]? = nil,
        source: RouteSource = .inApp,
        presentation: PresentationStyle = .push
    ) {
        self.path = path
        self.params = params
        self.source = source
        self.presentation = presentation
    }
}

public extension Route {
    func value<T: Decodable>(_ key: String, as type: T.Type = T.self) -> T? {
        guard let param = params?[key] else { return nil }
        switch (param, type) {
        case (.string(let s), is String.Type): return s as? T
        case (.int(let i), is Int.Type): return i as? T
        case (.double(let d), is Double.Type): return d as? T
        case (.bool(let b), is Bool.Type): return b as? T
        case (.object(let data), _):
            return try? JSONDecoder().decode(type, from: data)
        default:
            return nil
        }
    }
    
    func string(_ key: String) -> String? { value(key, as: String.self) }
    func int(_ key: String) -> Int? { value(key, as: Int.self) }
    func double(_ key: String) -> Double? { value(key, as: Double.self) }
    func bool(_ key: String) -> Bool? { value(key, as: Bool.self) }
    
    func decode<T: Decodable>(_ key: String, as type: T.Type) -> T? {
        value(key, as: type)
    }
}
