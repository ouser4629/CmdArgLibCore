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
