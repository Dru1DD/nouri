// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NouriKit",
    platforms: [.iOS(.v18), .watchOS(.v11), .macOS(.v15)],
    products: [.library(name: "NouriKit", targets: ["NouriKit"])],
    targets: [
        .target(name: "NouriKit"),
        .testTarget(name: "NouriKitTests", dependencies: ["NouriKit"]),
    ]
)
