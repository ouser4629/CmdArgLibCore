//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import Foundation

public let PARAMETER_MAX = Int.max
public typealias ParameterName = String
public typealias LabelSpec = String

/// Holds data need by parser
public final class Parameter: Sendable {

    public let name: ParameterName
    public let shortLabel: String?
    public let oldStyleLabel: String?
    public let longLabel: String?
    public let defaultValue: String?
    public let isDummySynopsisParameter: Bool
    let typeName: String
    let minNumberOfValues: Int  // After a label
    let maxNumberOfValues: Int
    let minNumberOfOccurances: Int  // label and value (or values
    let maxNumberOfOccurances: Int
    public let isMeta: Bool
    let isRest: Bool

    public init(_ label: LabelSpec,
                _ name: String,
                _ typeName: String,
                _ defaultValue: String?, isDummySynopsisParameter: Bool = false)
    {
        let typeGroup = TypeGroup(typeName: typeName)
        let minMaxNumberOfOccurances = typeGroup.numberOfOccurances(hasDefaultValue: defaultValue != nil)
        let minMaxNumberOfValues = typeGroup.numberOfValues
        let labelTriple = makeLabelTriple(label)
        let isMeta = typeGroup == .metaFlag || typeGroup == .metaOption
        let isRest = typeGroup == .restCmdArgLibValue
        self.name = name
        self.typeName = typeName
        self.defaultValue = defaultValue
        self.isDummySynopsisParameter = isDummySynopsisParameter
        self.shortLabel = labelTriple.0
        self.oldStyleLabel = labelTriple.1
        self.longLabel = labelTriple.2
        self.minNumberOfValues = minMaxNumberOfValues.0
        self.maxNumberOfValues = minMaxNumberOfValues.1
        self.minNumberOfOccurances = minMaxNumberOfOccurances.0
        self.maxNumberOfOccurances = minMaxNumberOfOccurances.1
        self.isMeta = isMeta
        self.isRest = isRest
    }
}

extension Parameter {
    public var isFlagOrMetaFlag: Bool { maxNumberOfValues == 0 && maxNumberOfOccurances == PARAMETER_MAX }
    public var isVariadic: Bool { minNumberOfValues == 1 && maxNumberOfValues > 1 }
    public var isPositional: Bool { shortLabel ?? oldStyleLabel ?? longLabel == nil }
    public var isArray: Bool { minNumberOfValues == 1 && maxNumberOfValues == 1 && maxNumberOfOccurances > 1 }
    public var isRequired: Bool { minNumberOfOccurances > 0 && defaultValue == nil }
    public var isRepeatable: Bool { maxNumberOfOccurances > 1 }

    public var shortLabelName: String? { shortLabel == nil ? nil : String(shortLabel!.dropFirst()) }
    public var oldStyleLabelName: String? { oldStyleLabel == nil ? nil : String(oldStyleLabel!.dropFirst()) }
    public var longLabelName: String? { longLabel == nil ? nil : String(longLabel!.dropFirst(2)) }
    public var allLabels: [String] { [shortLabel, oldStyleLabel, longLabel].map{ $0 ?? ""} }
    public var definedLabels: [String] { [shortLabel, oldStyleLabel, longLabel].compactMap { $0 } }
    public var joinedLabels: String { definedLabels.joined(separator: "/") }
    public var shortestLabel: String? { definedLabels.first }
    public var longestLabel: String? { definedLabels.last }
    public var shortestLabelName: String? { labelName(of: shortestLabel) }
    public var longestLabelName: String? { labelName(of: longestLabel) }
    public var labelSpec: String { makeLabelSpec((shortLabel, oldStyleLabel, longLabel)) }

    public var typeElementName: String {
        var name = self.typeName
        if self.isFlagOrMetaFlag {
            return ""
        } else if name.hasPrefix("Array<") && name.last == ">" {
            name = String(name.dropFirst(6).dropLast(1))
        } else if name.last == "?" {
            name = String(name.dropLast())
        } else if name.hasPrefix("Optional<") && name.last == ">" {
            name = String(name.dropFirst(9).dropLast(1))
        } else if name.hasPrefix("Variadic<") && name.last == ">" {
            name = String(name.dropFirst(9).dropLast(1))
        } else if name == "Rest" {
            name = "String"
        } else if name.hasPrefix("MetaOption<") && name.last == ">" {
            name = String(name.dropFirst(11).dropLast(1))
        }
        return name
    }

    public var standardTypeName: String {
        var name = self.typeName
        if self.isFlagOrMetaFlag {
            return ""
        } else if name.hasPrefix("Array<") && name.last == ">" {
            name = "[\(name.dropFirst(6).dropLast(1))]"
        } else if name.hasPrefix("Variadic<") && name.last == ">" {
            name = "\(name.dropFirst(9).dropLast(1))..."
        } else if name.hasPrefix("Optional<") && name.last == ">" {
            name = "\(name.dropFirst(9).dropLast(1))?"
        }
        return name
    }
}

private func labelName(of label: String?) -> String? {
    if let label {
        let k = label.hasPrefix("--") ? 2 : 1
        return String(label.dropFirst(k))
    }
    return nil
}
