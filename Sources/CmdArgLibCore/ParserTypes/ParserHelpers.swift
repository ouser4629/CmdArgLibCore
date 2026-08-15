//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

/// If no "=", return (label, nil)
/// Else returns label and word after "=", which can be empty.
func splitOnEqualSign(_ word: String) -> (String, String?) {
    var lhs = word
    var rhs: String?
    if let equalIndex = word.firstIndex(of: "=") {
        let valIndex = word.index(after: equalIndex)
        let n = word.prefix(upTo: equalIndex)
        lhs = String(n)
        let v = word.suffix(from: valIndex)
        rhs = String(v)
    }
    return (lhs, rhs)
}

func labelDescription(_ param: Parameter) -> String {
    var ds = [String]()
    if let s = param.shortLabel { ds.append(s) }
    if let s = param.oldStyleLabel { ds.append(s) }
    if let s = param.longLabel { ds.append(s) }
    return ds.joined(separator: "/")
}

// A word is a label if it has label syntax. However if the word
// can be parsed as an Int, UInt or Double it is not treated as,
// as a label unless it is in the label dictionary.
func isLabel(_ word: String, labelDictionary: [String: (Int, Parameter)]) -> Bool {
    if word.count < 2 {
        return false
    }
    var i = word.startIndex
    if word[i] != "-" {
        return false
    }
    if (word.contains { $0.isWhitespace }) {
        return false
    }
    i = word.index(after: i)
    let c = word[i]
    if c == "-" {
        // has prefix "--", is label unless is "--"
        return word.count != 2
    }
    if labelDictionary[word] != nil {
        // is in dictinionary, must be label
        return true
    }
    // starts with "-", not "--", not in dictionary - is label unless is number
    let number = word.replacingOccurrences(of: "_", with: "")
    return Int(number) == nil && Double(number) == nil && UInt(number) == nil  // not a number
}

/// Returns the max postion encountered amoun the labeled
func assignLabeledParameterValues(
    into parsedValues: inout [ParsedValue],
    referencing parameters: [Parameter],
    collecting usageErrors: inout [CmdArgLibParseError]
) -> Int {
    var maxPosition = -1
    for (i, param) in parameters.enumerated() {
        if !param.isPositional {
            let parsedValue = parsedValues[i]
            for position in parsedValue.positions {
                if position > maxPosition {
                    maxPosition = position
                }
            }
            for label in parsedValue.labelsWithMissingValue {
                parsedValues[i].isValid = false
                usageErrors.append(.missingValueAfter(label))
            }
            let occurrenceCount = parsedValue.positions.count
            if occurrenceCount < param.minNumberOfOccurances {
                parsedValues[i].isValid = false
                usageErrors.append(.missingOccuranceFor(labelDescription(param)))
            } else if occurrenceCount > param.maxNumberOfOccurances /*&& !allowExtraOccurances*/ {
                parsedValues[i].isValid = false
                usageErrors.append(.extraOccuranceFor(parsedValue.parsedLabels))
            }
        }
    }
    return maxPosition
}

func assignPositionalParameterValues(
    from freeValueLists: [[String]],
    into parsedValues: inout [ParsedValue],
    referencing parameters: [Parameter],
    collecting usageErrors: inout [CmdArgLibParseError],
    maxLabeledPosition: Int
) {

    var position = maxLabeledPosition

    // Parameter takes all it can, and  returning what is left over
    // No parameter crosses a chunk of values
    func collectValues(values: [String], ndx: Int) -> [String] {
        let valuesEnd = values.count
        let parameter = parameters[ndx]
        if !parameter.isPositional { return values }
        var occurrencesCount = 0
        var tailNdx = 0
        while tailNdx < valuesEnd && occurrencesCount < parameter.maxNumberOfOccurances {
            var valCountForOccurance = 0
            while tailNdx < valuesEnd && valCountForOccurance < parameter.maxNumberOfValues {
                tailNdx += 1
                valCountForOccurance += 1
            }
            position += 1
            parsedValues[ndx].positions.append(position)
            occurrencesCount += 1
        }
        parsedValues[ndx].values = Array(values[0..<tailNdx])
        let tail = Array(values[tailNdx..<valuesEnd])
        return tail
    }

    let valueLists = freeValueLists
    let valueListsEnd = freeValueLists.count
    var valueListsNdx = 0
    var valueList: [String] = []
    var parameterNdx = 0
    let parametersEnd = parameters.count
    while parameterNdx < parametersEnd {
        if valueList.isEmpty {
            if valueListsNdx < valueListsEnd {
                valueList = valueLists[valueListsNdx]
                valueListsNdx += 1
            } else {
                break
            }
        }
        valueList = collectValues(values: valueList, ndx: parameterNdx)
        parameterNdx += 1
    }

    while parameterNdx < parametersEnd {
        let parameter = parameters[parameterNdx]
        if parameter.isPositional && parameter.isRequired {
            usageErrors.append(.missingPositionalValue("$E{\(parameter.name)}"))
        }
        parameterNdx += 1
    }

    let unassignedValues = valueList + valueLists[valueListsNdx..<valueListsEnd].joined()
    if !unassignedValues.isEmpty {
        usageErrors.append(.unassignedPositionalValues(Array(unassignedValues)))
    }
}
