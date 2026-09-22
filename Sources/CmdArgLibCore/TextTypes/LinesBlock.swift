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

/// A struct used to render lines with header, and indented, but not line-wrapped
public struct LinesBlock: CustomStringConvertible, Sendable {
    private let header_: String?
    private var lines_: [String]
    let indent: Int

    public var header: String? { header_ }
    public var lines: [String] { lines_ }

    init(header: String? = nil, lines: [String] = [], indent: Int = 2) {
        self.header_ = header
        self.lines_ = lines
        self.indent = indent
    }

    public mutating func expandShowMacros(using expander: ShowMacroExpander) {
        self.lines_ = lines.map { expander.expandMacros(in: $0) }
    }

    /// If header is nil or empty, all the lines are indented, unwrapped.
    /// If header ends in "\n": It has its own line. If so it is followed by  indented, unwrapped lines.
    /// Otherwise, header is prefixed to the first line. Remainging lines are hanging indented
    public var description: String {
        var spaces = String(repeating: " ", count: indent)
        if let header, !header.isEmpty {
            var allLines = lines
            let firstLine: String
            if header.last == "\n" {
                firstLine = String(header.dropLast())
            }
            else {
                let newIndent = stringWidth(header.trimmingCharacters(in: .whitespacesAndNewlines)) + 1
                spaces = String(repeating: " ", count: newIndent)
                firstLine = "\(header) \(lines.first ?? "")"
                allLines = Array(lines.dropFirst())
            }
            allLines = [firstLine] + allLines
            return allLines.joined(separator: "\n\(spaces)")
        }
        return lines.map{ "\(spaces)\($0)" }.joined(separator: "\n")
    }
}
