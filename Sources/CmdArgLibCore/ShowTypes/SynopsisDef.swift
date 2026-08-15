//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

public let synopisDummyElementPrefix = "$"
public let synopsisAllParameterNames = "$*"
public let synopsisOmitParameterNamePrefix = "!"
public typealias SynopsisElement = String
public typealias SynopsisLine = [SynopsisElement]
public typealias SynopsisHeader = String
public typealias SynopsisDef = (SynopsisHeader, [SynopsisLine])

// Returns an array of Parameter to be in the synopsis
public func synopsisLineParameters(
    in line: SynopsisLine,
    for context: RunContext,
    errorMessages: inout [String]) -> [Parameter]
{
    var errorEncountered: Bool = false
    var lineParameters: [Parameter] = []
    var lineParameterNames: Set<String> = []
    var omitNames: Set<String> = []
    if line.isEmpty {
        return context.parameters
    }

    func appendParameter(_ parameter: Parameter) {
        let name = parameter.name
        if !lineParameterNames.contains(name) {
            lineParameters.append(parameter)
            lineParameterNames.insert(name)
        }
    }

    let lineOnlyHasOmitPrefix = line.allSatisfy{ $0.hasPrefix(synopsisOmitParameterNamePrefix) }
    let elements = lineOnlyHasOmitPrefix ? [synopsisAllParameterNames] + line : line

    for element in elements {
        if element == synopsisAllParameterNames {
            for parameter in context.parameters {
                appendParameter(parameter)
            }
        }
        else if element.hasPrefix(synopsisOmitParameterNamePrefix) {
            omitNames.insert(String(element.dropFirst()))
        }
        else if element.hasPrefix(synopisDummyElementPrefix) {
            if let parameter = Parameter.makeDummyParameter(from: element.dropFirst()) {
                lineParameters.append(parameter)
            } else {
                errorEncountered = true
                errorMessages.append("badly formatted dummy parameter in synopsis line: \"\(element)\"")
            }
        }
        else {
            if let parameter = context.parameterNamed[element] {
                appendParameter(parameter)
            } else {
                errorEncountered = true
                errorMessages.append("unrecognized parameter name in synopsis line: \"\(element)\"")
            }
        }
    }
    if errorEncountered {
        return []
    }
    let remainingParameters = lineParameters.filter { !omitNames.contains($0.name) }
    return remainingParameters
}

public func getPackedShortFlagChunk(for parameters: [Parameter]) ->
    (shortFlagChunk: String?, remainingParameters: [Parameter])
{
    var remainingParameters = [Parameter]()
    var shortFlagNames = [Character]()
    for parameter in parameters {
        if ParameterFormatter.packShortLabel(of: parameter) {
            if let shortFlagName: Character = parameter.shortLabel?.last {
                shortFlagNames.append(shortFlagName)
            }
        } else {
            remainingParameters.append(parameter)
        }
    }
    if shortFlagNames.isEmpty {
        return (nil, remainingParameters)
    }
    let shortFlagString = String(shortFlagNames)
    return ("[-\(shortFlagString)]", remainingParameters)
}
