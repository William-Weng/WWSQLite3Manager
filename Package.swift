// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWSQLite3Manager",
    platforms: [
        .iOS(.v13)
    ],
    products: [.library(name: "WWSQLite3Manager", targets: ["WWSQLite3Manager"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "WWSQLite3Manager", dependencies: []),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
