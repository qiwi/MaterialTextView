// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "MaterialTextView",
    platforms: [
        .iOS(.v9),
    ],
    products: [
        // The external product of our package is an importable
        // library that has the same name as the package itself:
        .library(
            name: "MaterialTextView",
            targets: ["MaterialTextView"]
        )
    ],
    
    dependencies: [
        .package(url: "https://github.com/qiwi/FormattableTextView.git", .branch("swift-pm"))
    ],
    targets: [
        // Our package contains two targets, one for our library
        // code, and one for our tests:
        .target(name: "MaterialTextView", dependencies: ["FormattableTextView"], path: "MaterialTextView", exclude: ["Info.plist"])
    ],
    
    swiftLanguageVersions: [
        .v5
    ]
)
