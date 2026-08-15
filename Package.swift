//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CmdArgLibCore",
    platforms: [.macOS(.v12)],
    products: [
        .library(name: "CmdArgLibCore", targets: ["CmdArgLibCore"]),
    ],
    dependencies: [ ],
    targets: [
        .target(
            name: "CmdArgLibCore",
        ),
        .testTarget(
            name: "OtherTests",
            dependencies: [ "CmdArgLibCore" ]
        ),
    ]
)
