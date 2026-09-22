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
