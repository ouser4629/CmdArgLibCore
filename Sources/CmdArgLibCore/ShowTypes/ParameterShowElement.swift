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
        isPseudo: Bool = false)
    {
        self.name = name
        self.description = description
        self.defaultValueOverride = defaultValueOverride
        self.completionRule = completionRule
        self.isPseudo = isPseudo
    }

    public init(context: CommandContext)
    {
        self.name = context.name
        self.description = context.synopsis
        self.defaultValueOverride = nil
        self.completionRule = .exclusive
        self.isPseudo = false
    }
}
