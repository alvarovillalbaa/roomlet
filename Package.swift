// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Roomlet",
    platforms: [.macOS("15.0")],
    products: [
        .executable(name: "Roomlet", targets: ["Roomlet"]),
        .library(name: "RoomletCore", targets: ["RoomletCore"]),
    ],
    targets: [
        .target(name: "RoomletCore"),
        .executableTarget(name: "Roomlet", dependencies: ["RoomletCore"]),
        .testTarget(name: "RoomletCoreTests", dependencies: ["RoomletCore"]),
    ]
)
