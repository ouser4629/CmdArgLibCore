//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

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

