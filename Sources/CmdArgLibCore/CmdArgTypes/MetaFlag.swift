//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

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
