// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Powerline",

    products: [
        .library(
            name: "Powerline",
            targets: [
                "Powerline",
            ]
        )
    ],
    targets: [
        .target(name: "Powerline")
    ]
)
