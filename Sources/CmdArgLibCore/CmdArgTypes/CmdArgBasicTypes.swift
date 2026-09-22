// Copyright (c) 2025-2026 Peter Summerland LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
