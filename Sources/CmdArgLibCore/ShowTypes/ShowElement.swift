//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

// An element to add to a help screen
public struct ShowElement: Sendable {

    public let member: ShowElementType

    public enum ShowElementType: Sendable {
        case synopsisDef(SynopsisHeader, [SynopsisLine])
        case parameterElement(ParameterShowElement)
        case commandContextElement(CommandContext)
        case textBlock(TextBlock)
        case linesBlock(LinesBlock)
    }

    init(_ member: ShowElementType) { self.member = member }

    public var parameterElementName: String? {
        guard case let .parameterElement(element) = member else {
           return nil
        }
        return element.name
    }
}

extension ShowElement {

    public static func ruleForNameDictionary(for elements: [ShowElement]) -> [String: CompletionRule] {
        var dict: [String:CompletionRule] = [:]
        for element in elements {
            if case let .parameterElement(parameterElement) = element.member {
                dict[parameterElement.name] = parameterElement.completionRule
            }
        }
        return dict
    }

    public static func descriptionForNameDictionary(for elements: [ShowElement]) -> [String: String] {
        var dict: [String:String] = [:]
        for element in elements {
            if case let .parameterElement(parameterElement) = element.member {
                dict[parameterElement.name] = parameterElement.description
            }
        }
        return dict
    }

    /// Construct a prologue for a man page
    public static func prologue(description: String, date: String = "", operatingSystem: String = "")  -> ShowElement {
        return Self(.linesBlock(LinesBlock(header: "__PROLOGUE__", lines: [description, date, operatingSystem])))
    }

    /// Construct a synopsis section with a single (wrapped) line
    /// - Parameters:
    ///   - header: Lke "\nUSAGE\n"
    ///   - line: SynopsisLine, an array of SynopsisElements
    /// - Returns: Synopsis section - header followed by the lines
    ///
    /// A   dummy parameter specification is "$<label>:<type>[=]"; If "=" is specified the dummy will have a default value. The label an type follow the usual rules
    public static func synopsis(_ header: String = "SYNOPSIS", line: SynopsisLine = []) -> ShowElement {
        Self(.synopsisDef(header, [line]))
    }

    /// Construct a synopsis section with a multiple (wrapped) lines
    /// - Parameters:
    ///   - header: Lke "\nUSAGE\n"
    ///   - lines: An array of SynopsisLines
    /// - Returns: Synopsis section - header followed by the lines
    ///
    /// Each spec is a paramter name or a dummy parameter specification
    /// A   dummy parameter specification is "$<label>:<type>[=]"; If "=" is specified the dummy will have a default value. The label an type follow the usual rules
    public static func synopsis(_ header: String = "SYNOPSIS", lines: [SynopsisLine]) -> ShowElement {
        Self(.synopsisDef(header, lines))
    }

    /// Construct a parameter description element for a help screen or manpage
    /// If description is empty, the parameter show element will not show in the help screen or manpage
    public static func parameter(
        _ name: String,
        _ description: String,
        _ completionRule: CompletionRule = .exclusive,
        defaultValueOverride: String? = nil
    ) -> ShowElement {
        let parameterShowElement = ParameterShowElement (
            name: name,
            description: description,
            defaultValueOverride: defaultValueOverride,
            completionRule: completionRule
        )
        return Self(.parameterElement(parameterShowElement))
    }

    /// Construct parameterllike description lines, but for random names and descriptions
    public static func pseudoParameter(_ name: String, _ description: String) -> ShowElement {
        let parameterShowElement = ParameterShowElement (
            name: name,
            description: description.last == "." ? description : description + ".",
            defaultValueOverride: nil,
            completionRule: .exclusive,
            isPseudo: true
        )
        return Self(.parameterElement(parameterShowElement))
    }

    /// Costruct a parameter description element for a help screen or manpage
    public static func commandContext(_ context: CommandContext)-> ShowElement {
        return Self(.commandContextElement(context))
    }
    
    /// Construct a line-wrapped text element for use in a help screen
    /// "\n\n" separates paragraphs
    public static func text(_ header: String, _ text: String? = nil) -> ShowElement {
        var lines: [String] = []
        if let text {
            lines = text
                .components(separatedBy: "\n\n")
                .map{ $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter{ !$0.isEmpty}
        }
        return Self(.textBlock(TextBlock(header: header, lines: lines)))
    }

    /// Construct text elements that is not line wrapped - for use in a man page generation
    public static func mdoc(_ header: String? = nil, _ text: String? = nil) -> ShowElement {
        let lines = text == nil ? [] : text!.components(separatedBy: .newlines)
        return Self(.linesBlock(LinesBlock(header: header, lines: lines)))
    }
}

// Gets parameterfromParameterShowElementan array of show elements
extension Array where Element == ShowElement {
    public var parameterShowElements: [ParameterShowElement] {
        var elements: [ParameterShowElement] = []
        for showElement in self {
            if case .parameterElement(let element) = showElement.member {
                elements.append(element)
            }
        }
        return elements
    }
}

// Gets command nodes from an array of show elements
extension Array where Element == ShowElement {
    public var commandContexts: [CommandContext] {
        var nodes: [CommandContext] = []
        for showElement in self {
            if case .commandContextElement(let context) = showElement.member {
                nodes.append(context)
            }
        }
        return nodes
    }
}

