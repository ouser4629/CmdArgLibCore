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
