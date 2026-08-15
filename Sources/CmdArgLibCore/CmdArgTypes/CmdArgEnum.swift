//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.


public protocol CmdArgEnum: CaseIterable, RawRepresentable, CustomStringConvertible, Codable, CmdArgBasicType {
    static func initFromString(_ string: String) -> Self?
    var description: String {get}
}

public extension CmdArgEnum where AllCases.Element: CustomStringConvertible, RawValue == String {

    static func initFromString(_ string: Self.RawValue) -> Self? {
        Self.init(rawValue: string)
    }

    /// Description of an instance (just self.rawvalue)
    var description: String { self.rawValue }

    /// An array of raw values
    static var cases: [String] { Self.allCases.map(\.description) }


    /// A description of all of the enum's cases
    /// - Parameters:
    ///   - conjunction: The string to separate all but the last case
    ///   - quoteChar: The quote character to surround each raw values
    ///   - separator: The string to separate all but the last case
    /// - Returns: A string like "'red', 'green' and 'yellow'"
    static func casesJoinedWith(
        _ conjunction: String, quoteChar: String? =  "\"", separator: String = ", ") -> String {
        Self.allCases.map { $0.description }.joinedWith(conjunction, quoteChar: quoteChar, separator: separator)
    }

    /// A  string consisting of all case raw values joined by "  "
    static var spacedCases:  String {
        Self.allCases.map(\.description).joined(separator: " ")
    }

    /// A prefixed, suffixed string constising of cases joind with"," and then "or"
    static func orCases(_ prefix: String = "", _ suffix: String = "") -> String {
        "\(prefix) \(Self.casesJoinedWith("or")) \(suffix)".trimmingCharacters(in: .whitespaces)
    }

    /// A prefixed, suffixed string constising of cases joind with "," and then "and"
    static func andCases(_ prefix: String = "", _ suffix: String = "") -> String {
        "\(prefix) \(Self.casesJoinedWith("and")) \(suffix)".trimmingCharacters(in: .whitespaces)
    }
}

public extension Array where Element: CmdArgEnum {
    func joinedWith(_ conjuntion: String, quoteChar: String = "\"", separator: String = ", ") -> String {
        let names = self.map{"\($0)"}
        return names.joinedBy(conjuntion, quoteChar: quoteChar, separator: separator)
    }
}
