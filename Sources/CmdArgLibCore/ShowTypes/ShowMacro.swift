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

public struct ShowMacro: Sendable {
    let callNames: [String]

    public static let hotChar = "$"
    public static let shortestLabelMacro = "S{"
    public static let longestLabelMacro = "L{"
    public static let joinedLabelsMacro = "J{"
    public static let formattedTypeNameMacro = "T{"
    public static let formattedTypeElementNameMacro = "E{"
    public static let formattedCallNamesMacro = "F{"
    public static let callNamesMacro = "N{"
    public static let typeElementDescriptionMacro: String = "D{"

    public init(callNames: [String]) {
        self.callNames = callNames
    }

    public func getPrefixOf(_ stringPart: String) -> String? {
        var prefix: String? = nil
        if stringPart.hasPrefix(Self.shortestLabelMacro) {
            prefix = Self.shortestLabelMacro
        } else if stringPart.hasPrefix(Self.longestLabelMacro) {
            prefix = Self.longestLabelMacro
        } else if stringPart.hasPrefix(Self.joinedLabelsMacro) {
            prefix = Self.joinedLabelsMacro
        } else if stringPart.hasPrefix(Self.formattedTypeNameMacro) {
            prefix = Self.formattedTypeNameMacro
        } else if stringPart.hasPrefix(Self.formattedTypeElementNameMacro) {
            prefix = Self.formattedTypeElementNameMacro
        } else if stringPart.hasPrefix(Self.formattedCallNamesMacro) {
            prefix = Self.formattedCallNamesMacro
        } else if stringPart.hasPrefix(Self.callNamesMacro) {
            prefix = Self.callNamesMacro
        } else if stringPart.hasPrefix(Self.typeElementDescriptionMacro) {
            prefix = Self.typeElementDescriptionMacro
        }
        return prefix
    }
}

public extension ShowMacro {

    func getInsert(_ parameter: Parameter, and prefix: String) -> String? {
        var insert: String? = nil
        switch prefix {
        case Self.shortestLabelMacro:
            insert = parameter.shortestLabel
        case Self.longestLabelMacro:
            insert = parameter.longestLabel
        case Self.joinedLabelsMacro:
            insert = parameter.joinedLabels.isEmpty ? nil : parameter.joinedLabels
        case Self.formattedTypeNameMacro:
            insert = ParameterFormatter.formattedTypeName(of: parameter)
        case Self.formattedTypeElementNameMacro:
            insert = ParameterFormatter.typeFormat.format(parameter.typeElementName)
        case Self.typeElementDescriptionMacro:
            insert = SymbolFormatter(textCase: .lower, snakeSeparator: " ").format(parameter.typeElementName)
        default:
            break
        }
        return insert
    }
}
