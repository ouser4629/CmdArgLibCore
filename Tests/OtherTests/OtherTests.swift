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
