//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.l

extension Parser {

    /// Gathers unconcumed values into freeValueList. If more than one, elements all but the last are
    /// stranded. The last freeValueList is matched againts positional parameters.
    func parse(_ argumentList: [String]) -> (
        parsedValues: [ParsedValue], errors: [CmdArgLibParseError], trailingWords: [String]
    ) {
        var parsedValues = [ParsedValue]()
        var paramPositionNdx = -1
        var words = [String]()
        var wordNdx = 0
        var endNdx = 0
        var doubleHyphenEncountered = false
        var freeValueLists = [[String]]()
        var usageErrors = [CmdArgLibParseError]()
        var trailingWords = [String]()

        // Grabs values starting at wordNdx up to but not including first. Also, stops when
        // maxNumberOfValues are collected, and of course when we reach endNdx.
        // On entry wordNdx points to the first word to be potentially grabbed
        // On exit wordNdx points to the next word or is endNdx, after the last collected word.
        // When the first "--" is encountered it is skipped, and doubleHyphenEncountered is set to true,
        // All words after the first "--" as values
        //
        // However if parameter isRest is true, then take everything, including following --,
        // except always stops at stopword
        func grabValuesUpToNextLabel(_ maxNumberOfValue: Int) -> [String] {
            var values = [String]()
            while wordNdx < endNdx && values.count < maxNumberOfValue {
                let word = words[wordNdx]
                if word == "--" && !doubleHyphenEncountered {
                    doubleHyphenEncountered = true
                } else if !doubleHyphenEncountered && isLabel(word, labelDictionary: labelDictionary) {
                    break
                } else {
                    values.append(word)
                }
                wordNdx += 1
            }
            return values
        }

        // On enter, wordNdx points at the
        // On exit, wordNdx points at word after last word consumed
        // Consumes number of words, if any, the parameter can take as values
        func collectValues(
            forParamAt paramNdx: Int,
            label: String,
            with attachedValue: String
        ) -> [String] {
            let param = parameters[paramNdx]
            if param.isRest {
                doubleHyphenEncountered = true
            }
            var values = [String]()
            var maxNumberOfValues = param.maxNumberOfValues
            if !attachedValue.isEmpty {
                values.append(attachedValue)
                maxNumberOfValues -= 1
            }
            wordNdx += 1
            let grabbedValues = grabValuesUpToNextLabel(maxNumberOfValues)
            values.append(contentsOf: grabbedValues)
            if values.count < param.minNumberOfValues {
                parsedValues[paramNdx].isValid = false
                parsedValues[paramNdx].labelsWithMissingValue.append(label)
            }
            return values
        }

        // Assumed to be like "-ab", "-vValue", "-abvValue", -vValue1 Value2 ...
        // Only get here if not recognized as a oldStyle label.

        // It is not allowed to have -p=10 for short Label. You would have
        // a mess if cases like -abp25=10.

        // Always treat each letter as a label with its own error message. The only
        // downside is e.g., if -help is a oldStyle label flag, and each of -h, -e,
        // -l, -p is a flag, then -help will shadow the flags if packed. But programmer
        // allowed this because allowed parsing of packed short Label

        // Does not advance wordNdx, does advance arg position
        // Remainder of word, after a short label that takes values will be
        // treated as that short label followed by the remainder. -ab123 -> -a -b 123

        /// If the last short flag is not recognized it could be like -aw 125 when user meant -av 125, with -v taking a value.
        /// Or more common -w 125. a. -w not recognized, so end up here, as packed, the w reported by 125 treated
        /// as positional. So have to set lastParsedLabelUnrecognized to aovid this.t
        ///
        func parsePackedShortLabeledArgumentsOrFlags(_ word: String) {
            var unrecognizedLabel = [String]()
            var recognizedLabel = [String]()
            var index = word.startIndex
            var values: [String] = []

            index = word.index(after: index)
            while index != word.endIndex {
                let shortLabel = "-\(word[index])"
                index = word.index(after: index)
                paramPositionNdx += 1
                guard let (paramNdx, param) = labelDictionary[shortLabel] else {
                    unrecognizedLabel.append(shortLabel)
                    // lastParsedLabelWasUnrecognized = true
                    continue
                }
                // lastParsedLabelWasUnrecognized = false
                recognizedLabel.append(shortLabel)
                parsedValues[paramNdx].positions.append(paramPositionNdx)
                parsedValues[paramNdx].parsedLabels.append(shortLabel)
                if param.maxNumberOfValues > 0 {
                    let attachedValue = String(word[index..<word.endIndex])
                    values = collectValues(forParamAt: paramNdx, label: shortLabel, with: attachedValue)
                    parsedValues[paramNdx].values.append(contentsOf: values)
                    wordNdx -= 1
                    break
                }
            }
            if unrecognizedLabel.count > 0 {
                if suppressPackedShortLabelErrorReporting {
                    usageErrors.append(.unrecognizedLabel(word))
                }
                //        unrecognizedLabelEncountered = true
                else if unrecognizedLabel.count == 1 && recognizedLabel.isEmpty {
                    usageErrors.append(.unrecognizedLabel(unrecognizedLabel.first!))
                } else {
                    var uniqueLabel: [String] = []
                    for label in unrecognizedLabel {
                        if !uniqueLabel.contains(label) {
                            uniqueLabel.append(label)
                        }
                    }
                    usageErrors.append(.unrecognizedPackedShortLabel(uniqueLabel, word))
                }
            }
        }

        // Captures extra words up to first label, if any, and starts at the label.
        // If could not get a label, returns extra words immediately
        // Bumps wordNdx to after param and values that it consummed
        // Resets param value to values grabbed
        // on wordNdx points at param
        // Returns unconsumed values up to the next label
        func parseLabeledArgumentOrFlag() {

            let word = words[wordNdx]
            let (label, afterEqualsSign) = splitOnEqualSign(word)
            guard let (paramNdx, param) = labelDictionary[label] else {
                if label.hasPrefix("--") {
                    usageErrors.append(.unrecognizedLabel(label))
                } else {
                    // has prefix of "-"
                    // assume is it like -fp123, or -fp 123, both are same as -f -p 123
                    parsePackedShortLabeledArgumentsOrFlags(word)
                }
                wordNdx += 1
                return
            }

            // We have a recognized long label, and possible attached label
            paramPositionNdx += 1
            parsedValues[paramNdx].positions.append(paramPositionNdx)
            parsedValues[paramNdx].parsedLabels.append(label)

            // short Label do not use label=value syntax
            // -s=10 is like -s =10
            var attachedValue = afterEqualsSign ?? ""
            if label.count < 3 && afterEqualsSign != nil {
                attachedValue = "=" + attachedValue
            }

            // Flags cannot have attached values
            var values: [String] = []
            if param.maxNumberOfValues == 0 && !attachedValue.isEmpty {
                parsedValues[paramNdx].isValid = false
                usageErrors.append(.flagWithAttachedArgument(label, attachedValue))
                wordNdx += 1
            } else {
                values = collectValues(forParamAt: paramNdx, label: label, with: attachedValue)
                parsedValues[paramNdx].values.append(contentsOf: values)
            }
        }

        func doParse() {
            parsedValues = parameters.map { ParsedValue(parameter: $0) }
            words = argumentList
            wordNdx = 0
            endNdx = words.count
            while wordNdx < endNdx {
                var startNdx = wordNdx
                if parentCommandMode && words[startNdx] == "--" {
                    startNdx += 1
                    trailingWords = Array(words[startNdx...])
                    break
                }
                let extraValues = grabValuesUpToNextLabel(Int.max)
                if !extraValues.isEmpty {
                    if parentCommandMode {
                        trailingWords = Array(words[startNdx...])
                        break
                    }
                    freeValueLists.append(extraValues)
                }
                if wordNdx < endNdx {
                    parseLabeledArgumentOrFlag()
                }
            }

            let maxLabeledPosition = assignLabeledParameterValues(
                into: &parsedValues,
                referencing: parameters,
                collecting: &usageErrors)
            assignPositionalParameterValues(
                from: freeValueLists,
                into: &parsedValues,
                referencing: parameters,
                collecting: &usageErrors,
                maxLabeledPosition: maxLabeledPosition)
            resolveShadowedArgumentConflicts(in: &parsedValues, parameters: parameters)
        }

        doParse()
        return (parsedValues, usageErrors, trailingWords)
    }
}
