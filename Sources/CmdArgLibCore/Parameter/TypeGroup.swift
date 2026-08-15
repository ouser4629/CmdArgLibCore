//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.
//

/// Used work with type
public enum TypeGroup {
    case basicType,
         arrayOfCmdArgLibValue,
         variadicCmdArgLibValue,
         restCmdArgLibValue,
         optionalCmdArgLibValue,
         flag,
         metaFlag,
         metaOption

    public init(typeName: String) {
        var group = Self.basicType
        switch typeName {
        case "Flag": group = .flag
        case "MetaFlag": group = .metaFlag
        case "Rest": group = .restCmdArgLibValue
        default:
            if typeName.hasPrefix("[") && typeName.hasSuffix("]") {
                group = .arrayOfCmdArgLibValue
            } else if typeName.hasPrefix("Array<") && typeName.hasSuffix(">") {
                group = .arrayOfCmdArgLibValue
            } else if typeName.hasPrefix("Variadic<") && typeName.hasSuffix(">") {
                group = .variadicCmdArgLibValue
            } else if typeName.hasSuffix("?") {
                group = .optionalCmdArgLibValue
            }
            else if typeName.hasPrefix("MetaOption<") && typeName.hasSuffix(">") {
                group = .metaOption
            }
        }
        self = group
    }

    /// Returns the min and max of  the  number of values allowed for each occurrence
    public var numberOfValues: (Int, Int) {
        switch self {
        case .flag, .metaFlag:
            return (0, 0)
        case .variadicCmdArgLibValue, .restCmdArgLibValue:
            return (1, Int.max)
        case .metaOption:
            return (0,1)
        default:
            return (1, 1)
        }
    }

    /// Return min and max of allowed occurrences
    public func numberOfOccurances(hasDefaultValue: Bool) -> (Int, Int) {
        switch self {
        case .flag, .metaFlag:
            return (0, Int.max)
        case .basicType:
            return (hasDefaultValue ? 0 : 1, 1)
        case .optionalCmdArgLibValue:
            return (0, 1)
        case .arrayOfCmdArgLibValue:
            return (hasDefaultValue ? 0 : 1, Int.max)
        case .variadicCmdArgLibValue, .restCmdArgLibValue:
            return (hasDefaultValue ? 0 : 1, 1)
        case .metaOption:
            return (0, 1)
        }
    }
}
