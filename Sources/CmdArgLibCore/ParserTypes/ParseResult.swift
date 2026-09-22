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

/// Structure describing result of a parsing command arguments
public struct ParseResult {
    var callNames: [String]
    public let parsedValues: [String: ParsedValue]
    public let trailingWords: [String]
    public let parsedErrors: [CmdArgLibParseError]

    /// Initialize an instance of ParseResult with values obtained by parsing command arguments
    /// - Parameters:
    ///   - callNames: Command call chain names
    ///   - words: Array of words that can be parsed into command arguments
    ///   - parentCommandMode: True if parsing for a command node with children
    ///   - context: The command function context
    ///   The parser is set up with the last three parameters.
    public init(
        callNames: [String],
        words: [String],
        parentCommandMode: Bool,
        context: RunContext ) throws
    {
        let metaParameters = context.parameters.filter{ $0.isMeta}
        let metaTypeShadowGroup = metaParameters.map { $0.name }.joined(separator: " ")
        var newShadowGroups = context.shadowGroups
        if !metaTypeShadowGroup.isEmpty {
            newShadowGroups += [metaTypeShadowGroup]
        }
        let parser = Parser( 
            context.parameters,
            parentCommandMode: parentCommandMode,
            shadowGroups: newShadowGroups)
        let (allParsedValues, parsedErrors, trailingWords) = parser.parse(words)
        let validParsedValues = allParsedValues.filter{ $0.encountered && $0.isValid }

        var parsedValueDictionary = [String: ParsedValue]()
        for parsedValue in validParsedValues {
            parsedValueDictionary[parsedValue.parameter.name] = parsedValue
        }
        // There can only be one, because all metas shadow each other
        if let parseMetaValue = validParsedValues.first(where: { $0.parameter.isMeta }) {
            let name = parseMetaValue.parameter.name
            let values = parseMetaValue.values
            guard let (_, metaType) = (context.nameMetaTypeArray.first { $0.0 == name }) else {
                fatalError("Internal error: could not find meta type for parameter \(name)")
            }
            guard let metaTypeFunction = metaType.metaTypeFunction else {
                fatalError("Internal error: meta type \(metaType) has no function")
            }
            throw metaTypeFunction(callNames, values, context)
        }
        self.callNames = callNames
        self.parsedValues = parsedValueDictionary
        self.trailingWords = trailingWords
        self.parsedErrors = parsedErrors
    }
}

