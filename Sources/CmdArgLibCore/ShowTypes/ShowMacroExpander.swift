//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

// TODO: Consider escaping hot char, and } with \

import Foundation

public struct ShowMacroExpander: Sendable {
    let showMacro: ShowMacro
    // FIXME: back this with internal callNames_
    public var callNames: [String]
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
