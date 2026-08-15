//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.lied.

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

