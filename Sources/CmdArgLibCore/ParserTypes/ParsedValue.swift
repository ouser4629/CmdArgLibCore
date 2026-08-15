//  Copyright (c) 2025-2026 Psummerland2 LLC.
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
    public var encounteredValues: [String] { values }
    public var encounteredLabels: [String] { parsedLabels }
    public var valuesArray: [String] { values }
    // FIXME: Should move to CmdArgLibCommandNodeStruct
    public var encodedRawArg: [String] {
        if values.isEmpty { return [] }
        let name = parameter.name
        var encodeds: [String] = []
        let labelslMax = parsedLabels.count - 1  // zero if variant, values.count - 1 if array
        let positionsMax = positions.count - 1 //
        let multiValue = positionsMax == 0 && values.count > 1
        for i in 0..<values.count {
            var position = Double(positions[min(i, positionsMax)])
            if multiValue {
                position += Double(i) / 100
            }
            let label = labelslMax < 0 ? "nil" : parsedLabels[min(i, labelslMax)]
            let value = values[i]
            let encoded = """
            {"position":\(position),"parameterName":"\(name)","value":"\(value)","label":"\(label)"}
            """
            encodeds.append(encoded)
        }
        return encodeds
    }

    init(parameter: Parameter) {
        self.parameter = parameter
    }
}
