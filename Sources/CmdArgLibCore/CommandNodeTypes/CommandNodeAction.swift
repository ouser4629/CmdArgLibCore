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

/// A function the performs program logic, meant to be used by a CommandNode
///
/// The action quits parsing when it detects the first "free" word, a word
/// that is not a lablel and is not the value of an argument (label value pair).
/// E.g., in '--foo --count 2 name --bar', the parsing would stop a 2. ' name --bar`
/// would be the remaining words returned by the function.
public typealias CommandNodeAction<T: Sendable> =
    @Sendable (
        /// Words to be parsed
        [String],
        /// State
        [T],
        /// Command chain, ending with current command
        [CommandNode<T>],
        /// RunContext
        RunContext
    ) async throws -> (
        ///The new state, typically passed  back from a wrapped command function
        [T],
        /// Remaining words not consumed by this action
        [String]
    )

