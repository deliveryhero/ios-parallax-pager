// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ParallaxPagerView",
    platforms: [.iOS(.v9)],
    products: [
        .library(
            name: "ParallaxPagerView",
            targets: ["ParallaxPagerView"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ParallaxPagerView",
            dependencies: [],
            exclude: ["ParallaxPagerView.plist"]
        )
    ]
)
