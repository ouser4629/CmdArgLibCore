//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import Foundation

/// A context in a hierachical command structure
public struct CommandNode<T: Sendable>: Sendable {
    public let name: String
    public let synopsis: String
    let commandAction: CommandNodeAction<T>
    let runContextMaker: RunContextMaker
    private var children: [CommandNode]
    public var context: CommandContext {
        let subnodes = children.map { $0.context }
        let context = CommandContext(
            name: name, synopsis: synopsis, runContextMaker: runContextMaker, subnodes: subnodes)
        return context
    }

    /// Inittalize a a CommandNode
    /// Only need to set runContext ifor something like shel completion generators
    /// RecastErrorScreenToSubcommandError
    ///   Auto matically ttreated as true for it T is Void
    ///   If true and if command has childern, will recast any error throw by its action  as a bad or missing succommand
    public init(
        name: String,
        synopsis: String = "",
        action: @escaping CommandNodeAction<T>,
        runContextMaker: @escaping RunContextMaker,
        children: [CommandNode<T>] = [],
    ) {
        self.name = name
        self.synopsis = synopsis
        self.commandAction = action
        self.runContextMaker = runContextMaker
        self.children = children
    }

    mutating func setChildren(_ children: [CommandNode<T>]) {
        self.children = children
    }

    public var __children__: [CommandNode] {
        children
    }
}

/// The run method - run a command
///
/// The `run` method passes the words and state it recieves on to the node's command action.
/// The command action then  parses the words, up until it hits a "free" word, and passes the parsed
/// values and state on to the node's annoted command function.
/// The command function processes the values and state and return a pair: ([T], [String]), the new state and unconsumed words
/// If there are unconsumed words:
///  * the `run` method matches the first word to the name of a child context, throwing an error if there is no match
///  * the `run` calls the named child's `run` method with the words following the child's name and the new state.
///  * the `run` method returns the
/// If there are no remaining unconsumed words, the `run` method returns ([], the new state).
extension CommandNode {

    /// Traverse the CommandNode graph, executing commands alont the way
    /// - Parameters:
    ///   - words: Array of words (as defined by the shell)  constituting a command argumenent lsit
    ///   - state: The state passe by this command's immediate parene
    ///   - parentNodes: The list of parent commands traversed to arrive at this command.
    /// - Returns: A pair consisting of new state and unconsumed  command line arguments
    @discardableResult public func run(
        with words: [String],
        state: [T] = [],
        parentNodes: [CommandNode] = []
    ) async throws -> (newState: [T], unconsummedWords: [String]) {
        var newState: [T] = []
        var trailingWords: [String] = []
        let currentNodes = parentNodes + [self]
        let currentNames = currentNodes.map(\.name)
        let childlNodes: [CommandNode] = self.children
        let runContext = runContextMaker()
        do {
            (newState, trailingWords) = try await commandAction(words, state, currentNodes, runContext)
            if childlNodes.isEmpty {
                return (newState, trailingWords)
            }
            guard let firstWord = trailingWords.first else {
                throw Exception.error("missing subcommand")
            }
            guard let childlNode = (childlNodes.first { $0.name == firstWord }) else {
                throw Exception.error("unrecognized subcommand: \"\(firstWord)\"")
            }
            let newWords = Array(trailingWords.dropFirst())
            (newState, trailingWords) = try await childlNode.run( with: newWords,  state: newState, parentNodes: currentNodes)
            return (newState, trailingWords)
        }
        catch Exception.error(let message) {
            let errorScreen = ErrorScreen(callNames: currentNames, messages: [message], context: runContext)
            throw Exception.stderr(errorScreen.description)
        }
        catch Exception.errors(let messages) {
            let errorScreen = ErrorScreen(callNames: currentNames, messages: messages, context: runContext)
            throw Exception.stderr(errorScreen.description)
        }
    }

    /// Same as above, but parses input into "shell words"
    @discardableResult public func run(
        parsing line: String,
        state: [T] = [],
        parentNodes: [CommandNode] = []
    ) async throws -> (newState: [T], unconsummedWords: [String]) {
        return try await run(with: shellSplit(line), state: state, parentNodes: parentNodes)
    }
}

/// Ensures that the command node graph is a strict tree and that all command names are unique.
public func commandGraphCheck() {
    var encounteredNames: Set<String> = []

    func checkNameOf(_ context: CommandContext) {
        let name = context.name
        if encounteredNames.contains(name) {
            let message = "Command \(name) duplicates a name or is reachable by multiple paths."
            fatalUseOfAPI(message, file: #file, line: #line)
        }
        encounteredNames.insert(name)
        for child in context.children {
            checkNameOf(child)
        }
    }
}

/// Run a top level CommandNode using words passed in from the Terminal
public func runAsMain<T>(_ command: CommandNode<T>) async {
    do {
        commandGraphCheck()
        let (_, words) = commandLineNameAndWords()
        try await command.run(with: words)
    }
    catch {
        Exception.printAndExit(for: error)
    }
}
