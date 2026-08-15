//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

public struct ParameterShowElement: Sendable {
    public let name: String
    public let description: String
    public let defaultValueOverride: String?
    public let isPseudo: Bool
    let completionRule: CompletionRule

    public init(
        name: String,
        description: String,
        defaultValueOverride: String? = nil,
        completionRule: CompletionRule = .exclusive,
        isPseudo: Bool = false
    ) {
        self.name = name
        self.description = description
        self.defaultValueOverride = defaultValueOverride
        self.completionRule = completionRule
        self.isPseudo = isPseudo
    }

    public init(context: CommandContext) {
        self.name = context.name
        self.description = context.synopsis
        self.defaultValueOverride = nil
        self.completionRule = .exclusive
        self.isPseudo = false
    }
}
