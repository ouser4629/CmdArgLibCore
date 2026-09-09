//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

// Holds data for one parameter. Created and returned by Parser.parse(_)
public struct ParsedValue:  Sendable {
    public let parameter: Parameter
    var isValid = true
    var positions = [Int]()
    var values = [String]()
    var parsedLabels = [String]()
    var labelsWithMissingValue = [String]()
    var shadowedBy = [String]()
    var encountered: Bool { !positions.isEmpty }

    public var wasEncountered: Bool { encountered }
    public var wasValid: Bool { isValid }
    public var encounteredPositions: [Int] { positions }
    public var encounteredValues: [String] { values }
    public var encounteredLabels: [String] { parsedLabels }
    public var valuesArray: [String] { values }

    init(parameter: Parameter) {
        self.parameter = parameter
    }
}
