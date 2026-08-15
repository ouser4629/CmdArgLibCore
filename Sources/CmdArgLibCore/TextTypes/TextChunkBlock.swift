//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import Foundation

/// Stuct to render line wrapped text
public struct TextChunks: CustomStringConvertible, Sendable {
    let header: String?
    var chunks: [String]
    let lineWrapper: LineWrapper

    /// If header ends in "\n": It has its own line. If so it is followed by chunks wrapped with indent and extra indent
    /// Otherwise, it is jiust another chunk, all wrapped witn indent 0  and extra indent = hangingIndent
    public var description: String {
        if chunks.isEmpty {
            return header ?? ""
        }
        var line = ""
        if var header = header {
            if header.last == "\n" {
                line = header + lineWrapper.wrap(chunks)
            } else {
                if header.isEmpty { header = " " }
                line = lineWrapper.wrap([header] + chunks)
            }
        } else {
            line = lineWrapper.wrap(chunks)
        }
        return line
    }
}

public extension TextChunks {

    init(
        header: String? = nil,
        chunks: [String] = [],
        indent i: Int = 2,
        extraIndent ei: Int = 0,
        lineWidth: Int? = nil
    ) {
        var indent = i
        var extraIndent = ei
        if let header {
            if header.last != "\n" {
                indent = 0
                let bump = header.isEmpty ? 2 : 1
                extraIndent += stringWidth(header.trimmingCharacters(in: .whitespacesAndNewlines)) + bump
            }
        }

        self.header = header
        self.chunks = chunks
        self.lineWrapper = LineWrapper(
            indent: indent, extraIndent: extraIndent, lineWidth: lineWidth)
    }
}
