//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

/// This is the same as CommandNode<T>,  except that it does not have commandAction.
/// This allows it to be non-generic, useful for meta-flags and meta-options
public struct CommandContext: Sendable {
    public var name: String
    public var synopsis: String
    public var runContextMaker: RunContextMaker
    public var children: [CommandContext]
    public var isAssistantNode: Bool

        // FIXME: Deadwood
    //    public var completionElements: [ShowElement] {
//        let runContext = runContextMaker()
//        return runContext.primaryShowElementsForCompletions
//    }

    public init(
        name: String, synopsis: String, runContextMaker: @escaping RunContextMaker,
        subnodes: [CommandContext] = [], isAssistantNode: Bool = false
    ) {
        self.name = name
        self.synopsis = synopsis
        self.runContextMaker = runContextMaker
        self.children = subnodes
        self.isAssistantNode = isAssistantNode
    }
}
