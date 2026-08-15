//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

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
/// - Parameter labelName: The labelName name, e.g., "p", "print",
/// - Returns: short, oldStyle and long labels
///
/// Ittis assumed that labelName has only allowed characters (ascii alphanumeric). If
/// the labelName is badly formed, say "short__long", the entire thing will be treated as long
public func makeLabelTriple(_ rawLabelSpec: String, defaultLabelIsOldStyle: Bool = false) -> LabelTriple {
    if rawLabelSpec.isEmpty {
        return (nil, nil, nil)
    }
    let labelSpec = rawLabelSpec
    // FIXME: Deadwood
//    var labelSpec = rawLabelSpec
//    if labelSpec.hasPrefix("`") {
//        labelSpec.removeFirst()
//        if labelSpec.hasSuffix("`") {
//          labelSpec.removeLast()
//        }
//    }

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
