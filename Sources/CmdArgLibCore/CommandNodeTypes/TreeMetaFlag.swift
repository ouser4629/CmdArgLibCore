//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import Foundation

extension MetaFlag {
    /// If maybeName is nil, use the name of the function that has this as a parameter,  converted to kebab-case.
    /// The synopsis is currently ignored
    public init(treeFor maybeName: String?, synopsis: String = "") {
        @Sendable
        func function(callNames: [String], values: [String], context: RunContext) -> Exception {
            // FIXME - select subnodes same as completion --
            let name = maybeName ?? context.name
            let metaTypes = context.metaTypes
            var metaType = metaTypes.first(where: { $0.isHelpMetaType && !$0.commandContexts.isEmpty })
            metaType = metaType ?? metaTypes.first(where: { $0.isManpageMetaType && !$0.commandContexts.isEmpty })
            let subnodes = metaType?.commandContexts ?? []
            let phoneyNode = CommandContext(
                name: name, synopsis: synopsis, runContextMaker: emptyRunContextMaker, subnodes: subnodes, isAssistantNode: false
            )
            let lines = treeLines(for: phoneyNode, level: 0, maxLevel: Int.max)
            return Exception.stderr(lines.joined(separator: "\n"))
        }
        self.showElements = nil
        self.isHelpMetaType = false
        self.isManpageMetaType = false
        self.isCompletionMetaType = false
        self.metaTypeFunction = function
    }
}

private func formatSynopsis(_ synopsis: String) -> String {
    var string = synopsis
    if string.hasSuffix(".") {
        string.removeLast()
    }
    var firstWord = ""
    var rest = string
    if let firstSpaceIndex = string.firstIndex(of: " ")  {
        firstWord = String(string[..<firstSpaceIndex])
        rest = String(string[string.index(after: firstSpaceIndex)...])
    }
    firstWord = firstWord.lowercased()
    return firstWord + " " + rest
}

private func treeLines(for context: CommandContext, level: Int, maxLevel: Int) -> [String] {
    if context.children.isEmpty {
        return ["\(context.name) - \(formatSynopsis(context.synopsis))"]
    }
    if level >= maxLevel {
        return []
    }

    let subnodes = context.children.filter { !$0.isAssistantNode }
    let nodeName: String
    if let assistantNode = (context.children.filter { $0.isAssistantNode }.first) {
        nodeName = "\(context.name) [\(assistantNode.name)]"
    }
    else {
        nodeName = context.name
    }
    return combine(
        nodeName,
        formattedChildren: subnodes.map { treeLines(for: $0, level: level + 1, maxLevel: maxLevel) })
}

private func combine(_ text: String, formattedChildren: [[String]]) -> [String] {
    var lines = [text]
    for child in formattedChildren.dropLast(1) {
        var firstLineProcessed = false
        for member in child {
            if firstLineProcessed {
                lines.append("│   \(member)")
            } else {
                lines.append("├── \(member)")
                firstLineProcessed = true
            }
        }
    }
    if let child = formattedChildren.last {
        var firstLineProcessed = false
        for member in child {
            if firstLineProcessed {
                lines.append("    \(member)")
            } else {
                lines.append("└── \(member)")
                firstLineProcessed = true
            }
        }
    }
    return lines
}
