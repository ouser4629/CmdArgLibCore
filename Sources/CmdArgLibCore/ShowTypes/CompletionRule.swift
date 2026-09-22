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
