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

import Foundation

/// Holds parameters used to format a symble
public struct SymbolFormatter: Sendable {
    
    public enum TextCase: Sendable { case upper, lower, asIs }
    
    let textCase: TextCase
    let snakeSeparator: String
    let brackets: String
    
    /// Init formatter
    /// - Parameters:
    ///   - textCase: Upper, lower case etc
    ///   - snakeSeparator: If empty do not snake. Else snake from camel-case
    ///   - brackets: If empy no brackes. Else the left and righ bracket, e.g.. "<>"
    public init(
        textCase: TextCase = .lower,
        snakeSeparator: String = "",
        brackets: String = "",
    ) {
        self.textCase = textCase
        self.snakeSeparator = snakeSeparator
        self.brackets = brackets
    }
    
    /// Format a symbo
    /// - Parameter string: The camel-cases symbol
    /// - Returns: Formatted symbol
    public func format(_ string: String) -> String {
        if string.isEmpty { return "" }
        var result = bracket(SymbolFormatter.snake(string, snakeSeparator), brackets)
        switch textCase {
        case .upper:
            result = result.uppercased()
        case .lower:
            result = result.lowercased()
        case .asIs:
            break
        }
        return result
    }
    
    private func bracket(_ string: String, _ brackets: String) -> String {
        if brackets.isEmpty {
            return string
        }
        let left = brackets.first!
        let right = brackets.last!
        return "\(left)\(string)\(right)"
    }
}

// Static members
extension SymbolFormatter {

    /// Snake a camel case String
    public static func snake(_ source: String, _ sep: String = "-") -> String {
        var result = ""
        for c in source {
            if c.isUppercase {
                let lc = c.lowercased()
                if !result.isEmpty { result.append(sep) }
                result.append(lc)
            } else {
                result.append(c)
            }
        }
        return result
    }

    // Camel case a snaked string. whitespace treated like sepatator
    public static func camelCase(_ string: String, _ separator: String = "-") -> String {
        let sepSet = CharacterSet(charactersIn: separator)
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let snakedParts = trimmed.components(separatedBy: sepSet)
        var firstPart = snakedParts[0]
        if firstPart.isEmpty {
            return firstPart
        }
        firstPart = firstPart.prefix(1).lowercased() + firstPart.dropFirst()
        var parts = [String(firstPart)]
        if snakedParts.count > 1 {
            parts.append(contentsOf: snakedParts.dropFirst(1).map(\.capitalized))
        }
        return parts.joined()
    }
}
