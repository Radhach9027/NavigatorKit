//
//  File.swift
//  NavigatorKit
//
//  Created by radha chilamkurthy on 03/11/25.
//

import SwiftUI

public protocol RoutableFeature {
    static var routes: [String: any View] { get }
}
