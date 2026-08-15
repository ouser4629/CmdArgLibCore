//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

struct Parser {
    let parameters: [Parameter]
    let parentCommandMode: Bool
    let labelDictionary: [String: (Int, Parameter)]
    let suppressPackedShortLabelErrorReporting: Bool
    let indexesOfParsedValuesShadowedByParameterNamed: [String: Set<Int>]

    init(
        _ parameters: [Parameter],
        parentCommandMode: Bool,
        shadowGroups: [String] = []
    ) {
        self.parameters = parameters
        self.parentCommandMode = parentCommandMode
        let (lDict, labelErrorMessages, containsManyOldStyleLabels) = Self.makeLabelDict(parameters)
        let (sDict, shadowGroupErrorMessages) = Self.makeShadowDict(
            shadowGroups: shadowGroups, parameters: parameters)
        let fatalErrorMessages = labelErrorMessages + shadowGroupErrorMessages
        guard fatalErrorMessages.isEmpty else {
            for fatalErrorMessage in fatalErrorMessages {
                print(fatalErrorMessage)
            }
            fatalError()
        }
        self.suppressPackedShortLabelErrorReporting = containsManyOldStyleLabels
        self.labelDictionary = lDict
        self.indexesOfParsedValuesShadowedByParameterNamed = sDict
    }
}

extension Parser {

    /// Returns a dictionary mapping parameter name to index of each of the other parameter named in the group
    fileprivate static func makeShadowDict(shadowGroups shadowStrings: [String], parameters: [Parameter]) -> (
        [String: Set<Int>], [String]
    ) {
        var indexesOfVictimsOfParametersNamed = [String: Set<Int>]()

        var indexOfName: [String: Int] = [:]
        for (index, parameter) in parameters.enumerated() {
            indexOfName[parameter.name] = index
        }

        var unrecognizedNames: [String] = []
        let shadowGroups = shadowStrings.map { $0.components(separatedBy: .whitespaces) }
        for shadowGroup in shadowGroups {
            for name in shadowGroup {
                let newVictimNames = shadowGroup.filter { $0 != name }
                let newVictimIndexes = Set(newVictimNames.compactMap { indexOfName[$0] })
                if indexOfName[name] != nil {
                    let currentVictimIndexes = indexesOfVictimsOfParametersNamed[name] ?? []
                    indexesOfVictimsOfParametersNamed[name] = currentVictimIndexes.union(newVictimIndexes)
                } else {
                    unrecognizedNames.append(name)
                }
            }
        }
        let errorMessages = unrecognizedNames.map { "'\($0)' not a recognized parameter name" }
        return (indexesOfVictimsOfParametersNamed, errorMessages)
    }

    /// Returns (dictionary, fatal errors, containsManyOldStyleLabels). This is true if the number of old-style labels
    /// is 20% or more of the total number of long and old-style labels.
    fileprivate static func makeLabelDict(_ parameters: [Parameter]) -> ([String: (Int, Parameter)], [String], Bool) {
        var fatalErrors = [String]()
        var paramNameMap = [String: (Int, Parameter)]()
        var oldStyleLabelCount = 0.0
        var longLabelCount = 0.0

        func addLabelName(_ name: String, ndx: Int, param: Parameter) {
            if let (_, param2) = paramNameMap[name] {
                let label = name
                fatalErrors.append(
                    #""\#(label)" is a duplicate label, shared by "\#(param2.name)" and "\#(param.name)""#
                )
            } else {
                paramNameMap[name] = (ndx, param)
            }
        }

        for (i, param) in parameters.enumerated() {
            if let name = param.shortLabel {
                addLabelName(name, ndx: i, param: param)
            }
            if let name = param.oldStyleLabel {
                addLabelName(name, ndx: i, param: param)
                oldStyleLabelCount += 1
            }
            if let name = param.longLabel {
                addLabelName(name, ndx: i, param: param)
                longLabelCount += 1
            }
        }
        var containsManyOldStyleLabels = false
        if oldStyleLabelCount > 0.0 {
            containsManyOldStyleLabels = true
            if longLabelCount > 0.0 {
                containsManyOldStyleLabels = (oldStyleLabelCount / (oldStyleLabelCount + longLabelCount)) >= 0.2
            }
        }
        return (paramNameMap, fatalErrors, containsManyOldStyleLabels)
    }
}

extension Parser {

    private struct ParsedParameter {
        let paramNdx: Int
        let lastPos: Int
    }

    func resolveShadowedArgumentConflicts(in parsedValues: inout [ParsedValue], parameters: [Parameter]) {
        // This is indexes of parameters in order encountered
        var parsedArray = [ParsedParameter]()
        for (ndx, param) in parsedValues.enumerated() {
            if let lastPos = param.positions.last {
                parsedArray.append(ParsedParameter(paramNdx: ndx, lastPos: lastPos))
            }
        }
        parsedArray.sort { $0.lastPos > $1.lastPos }
        let parsedNdxArray = parsedArray.map { $0.paramNdx }
        var ndx = 0
        while ndx < parsedNdxArray.count {
            let paramNdx = parsedNdxArray[ndx]
            let paramName = parameters[paramNdx].name
            let label = parsedValues[paramNdx].parsedLabels.last ?? ""
            for victemNdx in indexesOfParsedValuesShadowedByParameterNamed[paramName] ?? [] {
                for i in (ndx + 1)..<parsedNdxArray.count {
                    if parsedNdxArray[i] == victemNdx {
                        parsedValues[victemNdx].shadowedBy.append(label)
                    }
                }
            }
            ndx += 1
        }
        for i in 0..<parsedValues.count {
            if !parsedValues[i].shadowedBy.isEmpty {
                parsedValues[i].positions = []
                parsedValues[i].values = []
            }
        }
    }
}
