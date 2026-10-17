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
// limitations under the License

import Foundation

public protocol MainFunctionDef: CommandDef, Codable {
    func run() async throws
}

public extension MainFunctionDef {
    typealias StateElement = Void
    
    static func run(with words: [String] = []) async throws {
        let commandNode = Self().commandNode
        try await commandNode.run(with: words)
    }
    
    var commandNode: CommandNode<Void> {
        
        let typeName = String(describing: type(of:self))
        let commandName = SymbolFormatter.snake(typeName, "-")
        
        
        @Sendable func action(
            words: [String], state: [StateElement] = [],
            nodePath: [CommandNode<StateElement>],
            runContext: RunContext) async throws -> ([StateElement], [String])
        {
            let (encoded, trailingWords) = try await encodeNode(words: words, state: state, nodePath: nodePath, runContext: runContext)
            let decoder = JSONDecoder()
            let data = encoded.data(using: .utf8)!
            let newInstance = try decoder.decode(Self.self, from: data)
            try await newInstance.run()
            return ([], trailingWords)
        }
        
        let commandNode = CommandNode(
            name: commandName,
            synopsis: "",
            action: action,
            runContextMaker: runContextMaker,
            children: []
        )
        return commandNode
    }
}
