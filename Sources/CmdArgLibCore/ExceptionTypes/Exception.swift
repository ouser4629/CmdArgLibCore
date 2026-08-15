//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import Foundation

/// Exceptions, including errors, screens and messages
public enum Exception: Error, CustomStringConvertible, Sendable, Equatable {
    /// Text to be printed to stdout
    case stdout(String)
    /// Text to be printedt to stderr
    case stderr(String)
    /// Error to be renedered in the  ErrorScreen
    case error(String)
    /// Errors to be renedered in the  ErrorScreen
    case errors([String])
}

public extension Exception {

    /// Show a single string rendering of the exception
    var description: String {
        switch self {
        case .stdout(let message): return message
        case .stderr(let message): return message
        case .error(let message): return message
        case .errors(let messages): return messages.joined(separator: "\n")
        }
    }
}

public extension Exception {
    /// Print a caught error and exti.
    ////    * It processes Excptions as follows:
    ///      * `.stdout(String)` - prints the string to stdout and exits with EXIT_SUCCESS.
    ///      * `.stderr(String)` - prints the string to stderr and exits with EXIT_FAILURE.
    ///    * It processes other Errors as follows
    ///      * simplify the error's message
    ///      * generates an error screen with the message and callNames
    ///      * exit with EXIT_FAILURE
    static func printAndExit(for error: Error) {
        var message = ""
        if let e = error as? Exception {
            if case let .stdout(message) = e {
                print(message)
                exit(EXIT_SUCCESS)
            }
            else {
                message = e.description
            }
        }
        else {
            message = showError(error)
        }
        try? writeToStandardError(message)
        exit(EXIT_FAILURE)
    }
}

// Print programmer error and exit program with EXIT_FAILURE
public func fatalUseOfAPI(_ messages: [String], file: String? = nil, line lineNumber: UInt? = nil) -> Never {
    var lines: [String] = []
    var line = "MISUSE OF API"
    if let file = file {
        line += " in \(file)"
        if let lineNumber {
            line += " at line \(lineNumber)"
        }
    }
    lines.append(line)
    for message in messages {
        lines.append("  \(message)")
    }
    lines.append("PLEASE CORRECT AND REBUILD")
    try? writeToStandardError(lines.joined(separator: "\n"))
    exit(EXIT_FAILURE)
}

public func fatalUseOfAPI(_ message: String, file: String? = nil, line lineNumber: UInt? = nil) -> Never {
    fatalUseOfAPI([message], file: file, line: lineNumber)
}

// DecodingError.dataCorrupted
public func showError(_ error: Error) -> String {
    if let e = error as? LocalizedError, e.errorDescription != nil {
        return e.errorDescription!
    }
    else if let e = error as? DecodingError {
        if case let .dataCorrupted(dc) = e {
            print(dc.debugDescription)
            return dc.debugDescription
        }
        return e.localizedDescription
    }
    return error.localizedDescription
}
