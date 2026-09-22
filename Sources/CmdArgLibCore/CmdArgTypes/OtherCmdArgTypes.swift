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

public typealias Flag = Bool

public struct Rest: ExpressibleByArrayLiteral, Codable, Sendable, CustomStringConvertible {
    public let elements: [String]
    public var description: String { "\(elements)" }

    public init(arrayLiteral elements: String...) {
        self.elements = elements
    }
    public init(_ elements: [String]) {
        self.elements = elements
    }
    public var isEmpty: Bool { elements.isEmpty }
}

public typealias Variadic<T> = Array<T>
