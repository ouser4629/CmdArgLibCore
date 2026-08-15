//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import Foundation

/// MetaTypeFunction
public typealias MetaTypeFunction = @Sendable (
    [String],  // call names
    [String],  // values
    RunContext  // command function context
) -> Exception


public protocol MetaType: CmdArgBasicType, Sendable, Codable, CustomStringConvertible {
    var metaTypeFunction: MetaTypeFunction? { get }
    var isHelpMetaType: Bool{ get }
    var isManpageMetaType: Bool{ get }
    var isCompletionMetaType: Bool{ get }
    var showElements: [ShowElement]? { get }
    var commandContexts: [CommandContext] { get }
}

