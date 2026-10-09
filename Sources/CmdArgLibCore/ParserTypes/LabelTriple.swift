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

public typealias LabelTriple = (String?, String?, String?)

// -------------------------------------------------------
//
// Note re generating labels from labelName
//
// Ii labelName is just an underscore,:
//   Lable components are all nil (positional parameter)
// else If labelName does not contain underscore:
//   if  labelName.count is one: short = labellabelName
//   else: long = lable
// else if labelName has two underscores:
//   format is [short]\_[oldStyle]\_[long]
// else:
//   long = labelName
// E.g.,
//   \_ : all components are nil
//   __ :all components are nil
//   s__sss: short is s, medilum is nil, long is sss
//   \_mm\_mmm: oldStyle is mm, long is mmm
//
// -------------------------------------------------------

/// Set Label componets from target function parameter labels
///
/// - Parameter rawLabelSpec: e.g. "h__help" or "\_help\_" for "-h" and "--help" or just "-help"
/// - Returns: short, oldStyle and long labels
///
/// Ittis assumed that labelName has only allowed characters (ascii alphanumeric). If
/// the labelName is badly formed, say "short__long", the entire thing will be treated as long
public func makeLabelTriple(_ rawLabelSpec: String, defaultLabelIsOldStyle: Bool = false) -> LabelTriple {
    if rawLabelSpec.isEmpty {
        return (nil, nil, nil)
    }
    let labelSpec = rawLabelSpec
    if labelSpec == "_" || labelSpec == "__" || labelSpec.isEmpty {
        return (nil, nil, nil)
    }
    let labelFormatter = SymbolFormatter(textCase: .lower, snakeSeparator: "-").format
    if !labelSpec.contains("_") {
        if labelSpec.count == 1 {
            return ("-\(labelSpec)", nil, nil)
        } else {
            let formatted = labelFormatter(String(labelSpec))
            return defaultLabelIsOldStyle ? (nil, "-\(formatted)", nil) : (nil, nil, "--\(formatted)")
        }
    }
    let names = labelSpec.split(separator: "_", omittingEmptySubsequences: false)
    if names.count != 3 {
        let formatted = labelFormatter(String(labelSpec))
        return defaultLabelIsOldStyle ? (nil, "-\(formatted)", nil) : (nil, nil, "--\(formatted)")
    }
    let shortLabel: String? = names[0].isEmpty ? nil : "-\(names[0])"
    let oldStyleLabel: String? = names[1].isEmpty ? nil : "-\(labelFormatter(String(names[1])))"
    let longLabel: String? = names[2].isEmpty ? nil : "--\(labelFormatter(String(names[2])))"
    return (shortLabel, oldStyleLabel, longLabel)
}

func makeLabelSpec(_ triple: LabelTriple) -> String {
    let short = triple.0?.dropFirst() ?? ""
    let oldStyle = triple.1?.dropFirst() ?? ""
    let long = triple.2?.dropFirst(2) ?? ""
    let spec = "\(short)_\(oldStyle)_\(long)"
    return spec == "__" ? "_" : spec
}
