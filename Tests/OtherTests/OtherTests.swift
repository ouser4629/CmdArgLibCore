//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import Foundation
import Testing

@testable import CmdArgLibCore

struct ShellSplitTests {

    @Test func shelSplitNormal() {
        #expect(shellSplit("hello world") == ["hello", "world"])
        #expect(shellSplit("hello\tworld") == ["hello", "world"])
        #expect(shellSplit("hello\nworld") == ["hello", "world"])
        #expect(shellSplit("hell\\o world") == ["hello", "world"])
    }

    @Test func shelSplitDoulbleQuote() {
        #expect(shellSplit(#"aaa "bbb ccc" "#) == ["aaa", "bbb ccc"])
        #expect(shellSplit(#"aaa "bbb ccc" ddd"#) == ["aaa", "bbb ccc", "ddd"])
        #expect(shellSplit(#"aaa "bbb \"ccc" "#) == ["aaa", "bbb \"ccc"])
        #expect(shellSplit(#"aaa "bbb \\ccc" "#) == ["aaa", "bbb \\ccc"])
        #expect(shellSplit(#"aaa "bbb \$ccc" "#) == ["aaa", "bbb $ccc"])
        #expect(shellSplit(#"aaa "bbb \`ccc" "#) == ["aaa", "bbb `ccc"])
        #expect(shellSplit(#"aaa "bbb \x ccc" "#) == ["aaa", "bbb \\x ccc"])
    }

    @Test func shelSplitSingleQuote() {
        #expect(shellSplit(#"aaa 'bbb ccc' "#) == ["aaa", "bbb ccc"])
        #expect(shellSplit(#"aaa 'bbb " ccc' ddd"#) == ["aaa", "bbb \" ccc", "ddd"])
        #expect(shellSplit(#"aaa 'bbb \' 'ccc ddd' "#) == ["aaa", "bbb \\", "ccc ddd"])
    }
}
