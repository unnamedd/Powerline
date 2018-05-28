// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Powerline",

    products: [
        .library(
            name: "Powerline",
            targets: [
                "Powerline"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/formbound/Futures.git", from: "1.0.1")
    ],
    targets: [
        .target(name: "Powerline", dependencies: ["Futures"]),
        .testTarget(name: "PowerlineTests", dependencies: ["Powerline"])
    ]
)
