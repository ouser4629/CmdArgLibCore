//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

public struct ErrorScreen: Error, Sendable, CustomStringConvertible, Equatable {
    let helpLabel: String?
    let callNames: [String]
    let messages: [String]
    let lineWidth: Int

    public init(callNames: [String], messages: [String], context: RunContext? = nil) {
        var interpolatedMessages: [String] = messages
        if let context {
            interpolatedMessages = messages.map { context.expandShowMacros(in: $0) }
        }
        self.helpLabel = context?.errorSecreenHelpLabel
        self.callNames = callNames
        self.messages = interpolatedMessages
        self.lineWidth = appropriateTerminalColumnWidth()
    }

    /// Error messages are not line wrapped. Doing so would make it hard to test for error messages,
    /// especially in Xcode where terminal width can vary.
    public var description: String {
        let s = messages.count == 1 ? "" : "s"
        var lines: [String] = ["Error\(s):"]
        for message in messages {
            lines.append("  \(message)")
            // We do not line wrap, imitating Xcode. Also better fot testOuput funcionts
            // lines.append(TextBlock(lines: [message], extraIndent: 2).description)
        }
        if let helpLabel, !callNames.isEmpty {
            let names = callNames.joined(separator: " ")
            let message = "See \"\(names) \(helpLabel)\" for more information."
            lines.append(message)
        }
        return lines.joined(separator: "\n")
    }
}
