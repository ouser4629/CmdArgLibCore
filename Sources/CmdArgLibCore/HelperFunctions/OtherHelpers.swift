//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.
import Foundation

/// Used by code genrated by macros
public func __quotedOrNil<T: CustomStringConvertible>(_ maybeElement: T?) -> String? {
    guard let element = maybeElement else { return nil }
        if element is Int || element is Double || element is Bool { return "\(element)" }
        return "\"\(element)\""
}

/// Used by code genrated by macros
public func __quotedOrNil<T: CustomStringConvertible>(_ ee: [T]?) -> String? {
    guard let elements = ee else { return nil }
    var rendered: [String] = []
    for element in elements {
        if element is Int || element is Double || element is Bool { rendered.append( "\(element)") }
        else { rendered.append( "\"\(element)\"") }
    }
    return "[\(rendered.joined(separator: ", "))]"
}

public func quoteIfNonNumeric(_ value: String) -> String {
    if Int(value) == nil && Double(value) == nil {
        return "\"\(value)\""
    }
    return value
}

extension Sequence where Element == String {

    /// Print strings joined with a conjuction, quoting and a separattor
    public func joinedWith(
        _ conjunction: String = "", quoteChar: String? = nil, separator: String = ", "
    ) -> String {
        var elements = self.map { $0.description }
        if let q = quoteChar {
            elements = elements.map { "\(q)\($0)\(q)" }
        }
        guard let last = elements.last else {
            return ""
        }
        if conjunction.isEmpty {
            return elements.joined(separator: separator)
        }
        let front = elements.dropLast().joined(separator: separator)
        return front.isEmpty ? last : "\(front) \(conjunction) \(last)"
    }

    /// Print strings joined with a conjuction, quoting and a separattor
    public func joinedBy(
        _ conjunction: String = "", quoteChar: String? = nil, separator: String = ", "
    ) -> String {
        self.joinedWith(conjunction, quoteChar: quoteChar, separator: separator)
    }
}

extension String {

    /// Pad like prinf.
    /// if field width is negative, text is left justified (like printf)
    /// Takes into account colorize markers e.g., "\u{001B}[91m"  "\u{001B}[0m"
    public func printfPadded(_ width: Int, char: Character = " ") -> String {
        let padLen = max(abs(width) - stringWidth(self), 0)
        let pad = String(repeating: char, count: padLen)
        return width >= 0 ? pad + self : self + pad
    }
}

/// Splits a String into words like bash, without variable exapansion, etc.
public func shellSplit(_ input: String) -> [String] {
    enum State {case normal, singleQuote, doubleQuote, escape }

    var result: [String] = []
    var current = ""
    var state: State = .normal
    var iterator = input.makeIterator()

    func appendCurrentIfNeeded() {
        if !current.isEmpty {
            result.append(current)
            current = ""
        }
    }

    while let char = iterator.next() {
        switch state {
        case .escape:
            current.append(char)
            state = .normal
        case .singleQuote:
            if char == "'" {
                state = .normal
            } else {
                current.append(char)
            }
        case .doubleQuote:
            if char == "\"" {
                state = .normal
            } else if char == "\\" {
                guard let next = iterator.next() else { break }
                switch next {
                case "\"", "\\", "$", "`":
                    current.append(next)
                default:
                    current.append("\\")
                    current.append(next)
                }
            } else {
                current.append(char)
            }
        case .normal:
            switch char {
            case "\\": state = .escape
            case "'": state = .singleQuote
            case "\"": state = .doubleQuote
            case " ", "\t", "\n": appendCurrentIfNeeded()
            default: current.append(char)
            }
        }
    }
    appendCurrentIfNeeded()
    return result
}

// Make sure that local module does not define these otherwise
public func __flagCheck__(_ x: Bool.Type) { }
public func __metaTypeCheck__(_ xx: CmdArgLibCore.MetaType.Type) { }
public func __typeCheck__(_ xx: any CmdArgBasicType.Type) { }

public func killIFSynopsisInputError(_ badParameterNames: [String], _ badDummyParameterSpecs: [String])  {
    var lines: [String] = []
    if !badParameterNames.isEmpty || !badDummyParameterSpecs.isEmpty {
        if !badParameterNames.isEmpty {
            let badNames = badParameterNames.joinedWith("and", quoteChar: "\"", separator: ", ")
            lines.append("  Unrecognized name(s) passed to synopsis  constructor: \(badNames).")
        }
        if !badDummyParameterSpecs.isEmpty {
            let badSpecs = badDummyParameterSpecs.joinedWith("and", quoteChar: "\"", separator: ", ")
            lines.append("  Bad dummy parameter spec(s) in passed to synopsis constructor: \(badSpecs).")
        }
        fatalUseOfAPI(lines, file: #file, line: #line)
    }
}

extension Array where Element == String {
    var isEmptyExceptForExclusionSpecs: Bool {
        for spec in self {
            if !spec.hasPrefix("!") { return false }
        }
        return true
    }

    var withoutExclusionSpecs: [String] {
        var specs: [String] = []
        var excluded: Set<String> = []
        for spec in self {
            if spec.hasPrefix("!") {
                excluded.insert(String(spec.dropFirst()))
            }
            else {
                specs.append(spec)
            }
        }
        if excluded.isEmpty { return specs }
        return specs.filter{ !excluded.contains($0) }
    }
}

public extension String {
    var trimmingBackticks : String {
        var clean = self
        if clean.hasPrefix("`") {
            clean.removeFirst()
            if clean.hasSuffix("`") {
                clean.removeLast()
            }
        }
       return clean
    }
}
