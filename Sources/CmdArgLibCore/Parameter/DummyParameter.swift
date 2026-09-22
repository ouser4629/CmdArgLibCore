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

extension Parameter {

    /// Make a dummy parameter for use in synopsis lines
    /// - Parameter spec_ -  dummy parameter specification
    /// - Returns: A parameter
    ///
    /// A   dummy parameter specification is "$<label>:<type>[=]"; If "=" is specified the dummy will have a default value.
    /// The label an type follow the usual rules.E.g.,
    ///    `$name:String=`, `$n__name:String?`, `$names:Variadic<String>`
    ///
    /// If `spec_` is valid, a parameter will be returned. Otherwise `nil`.

    static func makeDummyParameter(from spec_: any StringProtocol) -> Parameter? {
        var defaultValue: String? = nil
        var spec = spec_.trimmingCharacters(in: .whitespaces)
        if spec.hasSuffix("=") {
            defaultValue = "dummyDefault"
            spec = String(spec.dropLast())
        }
        let parts = spec.split(separator: ":")
        guard parts.count == 2 else { return nil }
        let label = String(parts[0]).trimmingCharacters(in: .whitespaces)
        let typeName = String(parts[1]).trimmingCharacters(in: .whitespaces)
        guard !label.isEmpty && !typeName.isEmpty else{ return nil }
        let name = "dummy" + parts.joined(separator: "_")
        return Parameter(label, name, typeName, defaultValue, isDummySynopsisParameter: true)
   }

}

