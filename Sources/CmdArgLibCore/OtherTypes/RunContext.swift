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

import Foundation

public typealias RunContextMaker = @Sendable () -> RunContext

public func emptyRunContextMaker() -> RunContext { RunContext() }

public func makeRunContextMaker(thatMakes context: RunContext) -> RunContextMaker {
    @Sendable func f() -> RunContext { return context }
    return f
}

public struct RunContext: Sendable {
    private var expander: ShowMacroExpander

    var errorSecreenHelpLabel: String? = nil
    var shadowGroups: [String]

    public var showMacroExpander: ShowMacroExpander { expander  }
    public let name: String
    public private(set) var parameters: [Parameter]
    public private(set) var parameterNamed: [String:Parameter]
    public private(set) var nameMetaTypeArray: [(String, MetaType)]
    public var metaTypes: [MetaType] { nameMetaTypeArray.map{$0.1} }
    public func expandShowMacros(in string: String) -> String { expander.expandMacros(in: string) }
}

public extension RunContext {

    /// Initialize the perr function's context info
    init(_ name: String = "") {
        self.name = name
        self.expander = ShowMacroExpander()
        self.parameters = []
        self.parameterNamed = [:]
        self.nameMetaTypeArray = []
        self.shadowGroups = []
    }

    mutating func __setMetaTypes(_ pairs: [(String, MetaType)]) {
         nameMetaTypeArray = pairs
     }

    /// Add shaoow groups
    mutating func __addShadowGroups(_ shadowGroups: [String] = []) {
        self.shadowGroups = shadowGroups
    }

    mutating func resetParameterNamedDictionary() {
        self.parameterNamed = self.parameters.reduce(into: [:]) { $0[$1.name] = $1 }
    }

    /// Add parameters
    mutating func setParameters(_ parameters: [Parameter]) {
        self.expander = ShowMacroExpander(callNames: [name], parameters: parameters)
        self.parameterNamed = parameters.reduce(into: [:]) { $0[$1.name] = $1 }
        self.parameters = parameters

        // Set self.eerrorSecreenHelpLabel
        for (name, flag) in nameMetaTypeArray {
            if flag.isHelpMetaType {
                if let parameter = parameterNamed[name] {
                    if let helpLabel = parameter.longestLabel {
                        self.errorSecreenHelpLabel = helpLabel
                    }
                }
                break
            }
        }
    }
}
