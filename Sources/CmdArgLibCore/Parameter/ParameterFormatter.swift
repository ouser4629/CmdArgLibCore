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

public struct ParameterFormatter: Sendable {

    static var typeFormat:SymbolFormatter { SymbolFormatter(textCase: .lower, snakeSeparator: "-", brackets: "<>") }

    // Note: MetaOption is a special case. We have formatted type name be formatted element name
    // so that it shows up nicely in parameter lines and synopsis lines.
    static func formattedTypeName(of parameter: Parameter) -> String {
        let formatedElementName = typeFormat.format(parameter.typeElementName)
        let typeName = parameter.standardTypeName
        var formatedTypeName = formatedElementName
        if typeName.hasPrefix("[") {
            formatedTypeName = "[\(formatedElementName)]"
        } else if typeName.hasSuffix("?") {
            formatedTypeName = "\(formatedElementName)?"
        } else if typeName.hasSuffix("...") {
            formatedTypeName = "\(formatedElementName)..."
        }
        return formatedTypeName
    }


    public static func elementTypeName(of parameter: Parameter) -> String {
        let elementName = parameter.typeElementName
        if parameter.isVariadic || parameter.isRest {
            return typeFormat.format(elementName) + "..."
        }
        return typeFormat.format(elementName)
    }

    public static func labelAndTypeChunk(of parameter: Parameter) -> String {
        let label = parameter.definedLabels.joined(separator: "/")
        if label.isEmpty {
            return elementTypeName(of: parameter)
        }
        return label + " " + elementTypeName(of: parameter)
    }

    public static func synopsisChunk(of parameter: Parameter) -> [String] {
        if packShortLabel(of: parameter) {
            return []  // will group short flag names as a pack
        }
        var chunk: String
        if parameter.isFlagOrMetaFlag {
            chunk = parameter.shortestLabel ?? ""
        } else if parameter.isPositional {
            chunk = "\(elementTypeName(of: parameter))"
        } else {
            let label = parameter.shortestLabel ?? ""
            chunk = "\(label) \(elementTypeName(of: parameter))"
        }
        if !parameter.isRequired {
            chunk = "[\(chunk)]"
        }
        return [chunk]
    }

    public static func packShortLabel(of parameter: Parameter) -> Bool {
        parameter.shortLabel != nil && parameter.isFlagOrMetaFlag
    }
}
