//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

/// Protocol for "basic types" that can by the types of command function parameters
public protocol CmdArgBasicType: Sendable, Codable, CustomStringConvertible {
    static func initFromString(_ string: String) -> Self?
}

/// String is basic type
extension String: CmdArgBasicType {
    /// To conform to CmdArgBasicType
    public static func initFromString(_ string: String) -> Self? {
        string
    }
}

/// In is basic type
extension Int: CmdArgBasicType {
    /// To conform to CmdArgBasicType
    public static func initFromString(_ rawString: String) -> Self? {
        var int: Int? = nil
        let string = rawString.replacingOccurrences(of: "_", with: "")
        if string.hasPrefix("0x") || string.hasPrefix("0X") {
            int = Int(string.dropFirst(2), radix: 16)
        } else if string.hasPrefix("0o") || string.hasPrefix("0O") {
            int = Int(string.dropFirst(2), radix: 8)
        } else {
            int = Self(string)
        }
        return int
    }
}

/// Double is basic type
extension Double: CmdArgBasicType {
    /// To conform to CmdArgBasicType
    public static func initFromString(_ rawString: String) -> Self? {
        let string = rawString.replacingOccurrences(of: "_", with: "")
        return Self(string)
    }
}

/// Describes a parsed argument.
public struct RawArg: Sendable, CmdArgBasicType, Codable, CustomStringConvertible {
    public var description: String {
        "name: \(parameterName), label: \(label?.description ?? "nil"), value: \(value),  position: \(position)"
    }

    public let parameterName: String
    public internal(set) var position: Double
    public internal(set) var value: String
    public internal(set) var label: String?

    public init(parameterName: String, position: Double = -1, value: String = "", label: String? = nil) {
        self.parameterName = parameterName
        self.position = position
        self.value = value
        self.label = label
    }

    /// Compare posttion in argument list
    public static func before(_ left: RawArg, _ right: RawArg) -> Bool {
        left.position < right.position
    }
}

extension RawArg {
    /// To conform to CmdArgBasicType
    public static func initFromString(_ string: String) -> Self? {
        return Self(parameterName: "Unamed-\(string)")
    }
}
