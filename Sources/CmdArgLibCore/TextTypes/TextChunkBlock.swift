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
