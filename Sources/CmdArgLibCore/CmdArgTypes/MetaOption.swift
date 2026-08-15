//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import Foundation

public protocol MetaOptionElement {
    var metaTypeFunction: MetaTypeFunction? { get }
    var showElements: [ShowElement] { get }
}

public struct MetaOption<T: MetaOptionElement>: MetaType, Codable {
    public var description: String { "MetaFlag" }

    public var commandContexts: [CommandContext] {
        if let showElements { return showElements.commandContexts }
        else { return [] }
    }

    public static func initFromString(_ string: String) -> MetaOption<T>? {
        fatalError()
    }

    public let metaTypeFunction: MetaTypeFunction?
    public let isHelpMetaType: Bool
    public let isManpageMetaType: Bool
    public let isCompletionMetaType: Bool
    public let showElements: [ShowElement]?

    public init(
        _ metaOptionElement: T,
        isHelpMetaType: Bool = false,
        isManpageMetaType: Bool = false,
        isCompletionMetaType: Bool = true,
    ) {
        self.metaTypeFunction = metaOptionElement.metaTypeFunction
        self.isHelpMetaType = isHelpMetaType
        self.isManpageMetaType = isManpageMetaType
        self.isCompletionMetaType = isCompletionMetaType
        self.showElements = metaOptionElement.showElements
    }

    public init(from decoder: any Decoder) throws {
        self.metaTypeFunction = nil
        self.isHelpMetaType = false
        self.isManpageMetaType = false
        self.isCompletionMetaType = true
        self.showElements = nil
    }

    public func encode(to encoder: any Encoder) throws {
        // Encode an empty object.
        _ = encoder.singleValueContainer()
    }
}

