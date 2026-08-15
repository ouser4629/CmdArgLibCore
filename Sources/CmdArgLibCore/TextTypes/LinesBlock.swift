//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

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

    /// If header ends in "\n": It has its own line. If so it is followed by chunks wrapped with indent and extra indent
    /// Otherwise, it is jiust another chunk, all wrapped witn indent 0  and extra indent = hangingIndent
    public var description: String {
        var allLines = lines
        var spaces = String(repeating: " ", count: indent)
        if let header {
            let firstLine: String
            if header.last == "\n" {
                firstLine = String(header.dropLast())
            }
            else {
                let newIndent = stringWidth(header.trimmingCharacters(in: .whitespacesAndNewlines)) + 1
                spaces = String(repeating: " ", count: newIndent)
                firstLine = "\(header) \(lines.first ?? "")"
                allLines = lines.dropLast()
            }
            allLines = [firstLine] + allLines
        }
        return allLines.joined(separator: "\n\(spaces)")
    }
}
