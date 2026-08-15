//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

public typealias Flag = Bool

public struct Rest: ExpressibleByArrayLiteral, Codable, Sendable, CustomStringConvertible {
    public let elements: [String]
    public var description: String { "\(elements)" }

    public init(arrayLiteral elements: String...) {
        self.elements = elements
    }
    public init(_ elements: [String]) {
        self.elements = elements
    }
    public var isEmpty: Bool { elements.isEmpty }
}

public typealias Variadic<T> = Array<T>
