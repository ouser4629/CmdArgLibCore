//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

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
