// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "TvOSPinKeyboard",
    platforms: [
        .tvOS(.v10)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TvOSPinKeyboard",
            targets: ["TvOSPinKeyboard"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/robb/Cartography.git", from: "4.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TvOSPinKeyboard",
            dependencies: ["Cartography"],
            path: "Sources"
        )
    ]
)
