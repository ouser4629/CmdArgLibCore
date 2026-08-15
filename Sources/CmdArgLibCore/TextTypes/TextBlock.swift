//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import Foundation

/// Stuct to render line wrapped text
public struct TextBlock: CustomStringConvertible, Sendable {
    public let header: String?
    public var lines: [String]
    let lineWrapper: LineWrapper

    /// If header ends in "\n": It has its own line. If so it is followed by chunks wrapped with indent and extra indent
    /// Otherwise, it is jiust another chunk, all wrapped witn indent 0  and extra indent = hangingIndent
    public var description: String {
        if lines.isEmpty {
            return header ?? ""
        }
        var wrappedLines: [String] = []
        var line = ""
        let chunkedLines = lines.map{ textChunks($0) }
        guard let firstLineChunks = chunkedLines.first else {
            return header ?? ""
        }
        if var header = header {
            if header.last == "\n" {
                line = header + lineWrapper.wrap(firstLineChunks)
            } else {
                if header.isEmpty { header = " " }
                line = lineWrapper.wrap([header] + firstLineChunks)
            }
        } else {
            line = lineWrapper.wrap(firstLineChunks)
        }
        wrappedLines.append(line)
        for lineChunks in chunkedLines.dropFirst() {
           wrappedLines.append(lineWrapper.wrap(lineChunks))
        }
        return wrappedLines.joined(separator: "\n\n")
    }
}

public extension TextBlock {

    init(
        header: String? = nil,
        lines: [String] = [],
        indent i: Int = 2,
        extraIndent ei: Int = 0,
        rightMargin: Int? = nil,
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
        self.lines = lines
        self.lineWrapper = LineWrapper(indent: indent, extraIndent: extraIndent, lineWidth: lineWidth)
    }

    mutating func expandShowMacros(using expander: ShowMacroExpander) {
        self.lines = lines.map { expander.expandMacros(in: $0) }
    }

    static func text(_ header: String, _ text: String) -> Self {
        Self(header: header, lines: [text])
    }
}


public func textChunks(_ text: (any StringProtocol)?) -> [String] {
    guard let text else {
        return []
    }
    return text.components(separatedBy: spacesAndNewlines).filter { !$0.isEmpty }
}

let spacesAndNewlines: CharacterSet = {
    var tab = CharacterSet()
    tab.insert(charactersIn: "\t")
    return CharacterSet.whitespacesAndNewlines.subtracting(tab)
}()


// FIXME: Do for chinese?
public func stringWidth(_ string: String) -> Int {
    var size = 0
    var escaping = false
    for c in string {
        if c == "\n" {
            continue
        }
        if c == "\u{001B}" {
            escaping = true
        } else if escaping {
            if c == "m" {
                escaping = false
            }
        } else {
            size += 1
        }
    }
    return size
}
