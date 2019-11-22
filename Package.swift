// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "firebase-ios-sdk",
    platforms: [.iOS(.v9)],
    // platforms: [.iOS("9.0"), .macOS("10.10"), tvOS("9.0"), .watchOS("2.0")],
    products: [
        .library(name: "firebase-ios-sdk", targets: ["firebase-ios-sdk"])
    ],
    targets: [
        .target(
            name: "firebase-ios-sdk",
            path: "Firebase"
        )
    ]
)
