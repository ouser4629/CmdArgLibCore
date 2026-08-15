//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

/// What to suggest as completion for a value after a label. E.g., full on path expansion,
/// or just the names of an enum. Except for `.ignore`, option labels and flags are
/// always suggested.
///
public enum CompletionRule: Sendable {

    public typealias Glob = String

    /// Do not suggest anything - not even the label. Normally all labels are suggested.
    case ignore

    /// After the CLI label, do not suggest anything. (E.g., after "--name ", <TAB> expects a string)
    case exclusive

    /// Let the shell suggest using path expansion.
    case path

    /// Suggest a list of alphanumeric words, usually CmdArgEnum raw values
    case list([String])

    /// Suggest files in the that match the glob pattern
    case file(Glob)

    /// Suggest directory names in the current directory that match the glob pattern
    case directory(Glob)
}
