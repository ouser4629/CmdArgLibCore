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

public struct MetaFlag: MetaType, Codable {
    public var description: String { "MetaFlag" }

    public var commandContexts: [CommandContext] {
        if let showElements { return showElements.commandContexts }
        else { return [] }
    }

    public let metaTypeFunction: MetaTypeFunction?
    public let isHelpMetaType: Bool
    public let isManpageMetaType: Bool
    public let isCompletionMetaType: Bool
    public let showElements: [ShowElement]?

    public init(
        metaTypeFunction: MetaTypeFunction? = nil,
        isHelpMetaType: Bool = false,
        isManpageMetaType: Bool = false,
        isCompletionMetaType: Bool = false,
        showElements: [ShowElement]? = nil
    ) {
        self.metaTypeFunction = metaTypeFunction
        self.isHelpMetaType = isHelpMetaType
        self.isManpageMetaType = isManpageMetaType
        self.isCompletionMetaType = isCompletionMetaType
        self.showElements = showElements
    }

    public init(from decoder: any Decoder) throws {
        self.metaTypeFunction = nil
        self.isHelpMetaType = false
        self.isManpageMetaType = false
        self.isCompletionMetaType = false
        self.showElements = nil
    }

    public func encode(to encoder: any Encoder) throws {
        // Encode an empty object.
        _ = encoder.singleValueContainer()
    }

    public static func initFromString(_ string: String) -> MetaFlag? {
        fatalError()
    }
}
