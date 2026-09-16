// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NouriKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v18), .watchOS(.v11), .macOS(.v15)],
    products: [.library(name: "NouriKit", targets: ["NouriKit"])],
    targets: [
        .target(name: "NouriKit", resources: [.process("Resources")]),
        .testTarget(name: "NouriKitTests", dependencies: ["NouriKit"]),
    ]
)
