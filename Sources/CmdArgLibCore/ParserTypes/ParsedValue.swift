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

// Holds data for one parameter. Created and returned by Parser.parse(_)
public struct ParsedValue:  Sendable {
    public let parameter: Parameter
    var isValid = true
    var positions = [Int]()
    var values = [String]()
    var parsedLabels = [String]()
    var labelsWithMissingValue = [String]()
    var shadowedBy = [String]()
    var encountered: Bool { !positions.isEmpty }

    public var wasEncountered: Bool { encountered }
    public var wasValid: Bool { isValid }
    public var encounteredPositions: [Int] { positions }
    public var encounteredValues: [String] { values }
    public var encounteredLabels: [String] { parsedLabels }
    public var valuesArray: [String] { values }

    init(parameter: Parameter) {
        self.parameter = parameter
    }
}
