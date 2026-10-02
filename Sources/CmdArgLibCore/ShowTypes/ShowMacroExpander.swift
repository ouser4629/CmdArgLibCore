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

// TODO: Consider escaping hot char, and } with \

import Foundation

public struct ShowMacroExpander: Sendable {
    let showMacro: ShowMacro
    public let callNames: [String]
    let parameterWithName: [String: Parameter]
}

public extension ShowMacroExpander {

    init() {
        self = Self(callNames: [], parameters: [])
    }

    init(callNames: [String], parameters: [Parameter]) {
        var dictionary = [String: Parameter]()
        for parameter in parameters {
            dictionary[parameter.name] = parameter
        }
        self.showMacro = ShowMacro(callNames: callNames)
        self.callNames = callNames
        self.parameterWithName = dictionary
    }

    func expandMacros(in string: String) -> String {
        let hotChar = ShowMacro.hotChar
        var badInsertKeys: [String] = []
        let stringParts = string.components(separatedBy: hotChar)
        var newParts = [stringParts.first!]
        for stringPart in stringParts.dropFirst() {
            guard let prefix = showMacro.getPrefixOf(stringPart) else {
                newParts.append(hotChar + stringPart)
                continue
            }
            if let indexOfClosingBracket = stringPart.firstIndex(of: "}") {
                let nameStart = stringPart.index(stringPart.startIndex, offsetBy: 2)
                let name = String(stringPart[nameStart..<indexOfClosingBracket])
                var maybeInsert: String? = nil
                if prefix == ShowMacro.callNamesMacro || prefix == ShowMacro.formattedCallNamesMacro {
                    // Here 'name' is the separator - as in $N{-}
                    let separator = name.isEmpty ? " " : name
                    maybeInsert = callNames.joined(separator: separator)
                }
                else if let parameter = parameterWithName[name] {
                    maybeInsert = showMacro.getInsert(parameter, and: prefix)
                } else {
                    badInsertKeys.append("\(prefix)\(name)}")
                    newParts.append(hotChar + stringPart)
                }
                if let insert = maybeInsert {
                    let s = stringPart.index(after: indexOfClosingBracket)
                    let tail = stringPart[s..<stringPart.endIndex]
                    newParts.append(insert + tail)
                } else {
                    newParts.append(hotChar + stringPart)
                    continue
                }
            } else {
                newParts.append(hotChar + stringPart)
                continue
            }
        }
        if !badInsertKeys.isEmpty {
            let messages = badInsertKeys.map { "  Unrecognized parameter name in: $\($0)." }
            fatalUseOfAPI(messages, file: #file, line: #line)
        }
        return newParts.joined()
    }
}
