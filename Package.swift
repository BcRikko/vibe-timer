// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VibeTimer",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "VibeTimer", targets: ["VibeTimer"])
    ],
    targets: [
        .executableTarget(
            name: "VibeTimer",
            dependencies: [],
            path: "Sources"
        )
    ]
)
