//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import Foundation

/// Get the name and words passed in from the terminal
public func commandLineNameAndWords() -> (String, [String]) {
    let nameAndWords = CommandLine.arguments
    if nameAndWords.isEmpty {
        // Unlikely - but depends ...
        return ("", [])
    }
    let name = nameAndWords[0].components(separatedBy: "/").last ?? "command"
    return (name, Array(nameAndWords.dropFirst()))
}

/// Write a message to stderr
public func writeToStandardError(_ message: String) throws {
    let m = "\(message)\n"
    let data = m.data(using: .utf8)!
    try FileHandle.standardError.write(contentsOf: data)
}

public let XCODE_TERMINALWIDTH = 40
public let DEBUG_TERMINALWIDTH = 80
public let MINIMUM_TERMINALWIDTH = 50

#if DEBUG
/// Return `DEBUG_TERMINALWIDT`, regarless
func appropriateTerminalColumnWidth() -> Int {
    return DEBUG_TERMINALWIDTH
}
#else
/// Return the max of the terminal width or`MINIMUM_TERMINALWIDTH. Howver if the terminal
/// width equals `XCODE_TERMINALWIDTH`, return `DEBUG_TERMINALWIDTH`
func appropriateTerminalColumnWidth() -> Int {
    var ws = winsize()
    let tioWinSize:UInt = TIOCGWINSZ < 0 ? 0 : UInt(TIOCGWINSZ)
    var width = ioctl(STDIN_FILENO, tioWinSize, &ws) == 0 ? Int(ws.ws_col) : 80
    if width == XCODE_TERMINALWIDTH { width = DEBUG_TERMINALWIDTH }
    return max(MINIMUM_TERMINALWIDTH, width)
}
#endif

