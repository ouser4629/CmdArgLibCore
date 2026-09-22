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

let minimumLineWidth = 10

struct LineWrapper {

    let indent: Int
    let extraIndent: Int
    let lineWidth: Int?

    func wrap(_ chunks: [String], indentOverride: Int? = nil) -> String {
        if chunks.isEmpty {
            return ""
        }
        var width = lineWidth ?? appropriateTerminalColumnWidth()
        width = max(width, minimumLineWidth)
        var firstLineFiller = String(repeating: " ", count: max(0, indent))
        var filler = String(repeating: " ", count: max(0, indent + extraIndent))
        if let indentOverride {
            firstLineFiller = String(repeating: " ", count: max(0, indentOverride))
            filler = String(repeating: " ", count: max(0, indentOverride))
        }
        var lines = [String]()
        var lineSize = 0
        var lineChunks = [String]()
        var isFirstLine = true
        for var chunk in chunks {
            if isFirstLine {
                isFirstLine = false
                chunk = "\(firstLineFiller)\(chunk)"
            }
            let newChunksSize = lineSize + stringWidth(chunk) + 1
            if newChunksSize <= width {
                lineChunks.append(chunk)
                lineSize = newChunksSize
                continue
            }
            if !lineChunks.isEmpty {
                lines.append(lineChunks.joined(separator: " "))
            }
            let firstChunk = filler + chunk
            lineSize = firstChunk.count + 1
            lineChunks = [firstChunk]
        }
        if !lineChunks.isEmpty {
            lines.append(lineChunks.joined(separator: " "))
        }
        return lines.joined(separator: "\n")
    }
}
