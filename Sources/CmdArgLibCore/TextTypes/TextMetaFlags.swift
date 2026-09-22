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
// limitations under the License.lied.

import Foundation

extension MetaFlag {

    /// A MetaFlag that priints a string to stderr
    public init(string: String) {
        @Sendable func function(
            callNames: [String], values: [String],
            context: RunContext
        ) -> Exception {
            var text = context.expandShowMacros(in: string)
            text = TextBlock(lines: [text]).description
            return Exception.stderr(text)
        }
        self.showElements = []
        self.isHelpMetaType = false
        self.isManpageMetaType = false
        self.isCompletionMetaType = false
        self.metaTypeFunction = function
    }

    /// A MetaFlag that prints a line-wrapped block of text to stderr
    public init(text block: TextBlock) {
        self = Self.init(textBlocks: [block])
    }

    /// A MetaFlag that prints several line-wrapped blocks of text to stderr
    public init(textBlocks: [TextBlock]) {
        @Sendable func function(callNames: [String], values: [String], context: RunContext) -> Exception {
            var texts: [String] = []
            for var block in textBlocks {
                block.expandShowMacros(using: context.showMacroExpander)
                texts.append(block.description)
            }
            let text = texts.joined(separator: "\n")
            return Exception.stderr(text)
        }
        self.showElements = nil
        self.isHelpMetaType = false
        self.isManpageMetaType = false
        self.isCompletionMetaType = false
        self.metaTypeFunction = function
    }
}

