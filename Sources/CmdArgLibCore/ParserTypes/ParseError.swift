//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import Foundation


/// For use by the parser package and CmdArgLibCore package
public enum CmdArgLibParseError: Error, Equatable {

    case unrecognizedPackedShortLabel([String], String)
    case unrecognizedLabel(String)
    case flagWithAttachedArgument(String, String)

    case missingOccuranceFor(String)
    case extraOccuranceFor([String])
    case missingValueAfter(String)

    case missingPositionalValue(String)
    case unassignedPositionalValues([String])

    case missingElementsFor(String)
    case extraElementsFor(String)
}

extension CmdArgLibParseError: CustomStringConvertible {

    /// Renders a description of the error
    public var description: String {
        messages.joined(separator: "\n")
    }

    private var messages: [String] {
        switch self {
        case .unrecognizedPackedShortLabel(let labels, let word):
            let s = labels.count > 1 ? "s" : ""
            let labelString = labels.joinedWith("and", quoteChar: "\"")
            return ["unrecognized option\(s): \(labelString), in \"\(word)\""]
        case .unrecognizedLabel(let name):
            return ["unrecognized option: \"\(name)\""]
        case .flagWithAttachedArgument(let label, _):
            return ["\"\(label)\" is a flag, but an argument was attached"]
        case .missingOccuranceFor(let label):
            return ["missing an occurrence of the \"\(label)\" option"]
        case .extraOccuranceFor(let labels):
            // Could be -c 10 and --count t or just -c 10 -c 5
            let option = Set(labels).sorted(by: >).joined(separator: "/")
            return ["duplicate occurrences of the \"\(option)\" option"]
        case .missingValueAfter(let labelName):
            return ["missing expected value after \"\(labelName)\""]
        case .missingPositionalValue(let name):
            return ["missing value: \"\(name)\""]
        case .unassignedPositionalValues(let values):
            let s = values.count > 1 ? "s" : ""
            let string = values.joinedWith("and", quoteChar: "\"")
            return ["unassigned argument\(s): \(string)"]
        case .missingElementsFor(let label):
            return ["missing values for \"\(label)\""]
        case .extraElementsFor(let label):
            return ["too many values for \"\(label)\""]
        }
    }
}

private let vowelSet: Set<Character> = ["a", "e", "i", "o", "u"]
