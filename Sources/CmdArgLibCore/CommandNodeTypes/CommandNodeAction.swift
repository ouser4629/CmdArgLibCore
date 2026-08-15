//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

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

