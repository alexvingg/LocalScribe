// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LocalScribe",
    defaultLocalization: "en",
    platforms: [.macOS("26.4")],
    products: [.executable(name: "LocalScribe", targets: ["LocalScribe"])],
    targets: [
        .target(name: "WritingCore", resources: [.process("Resources")]),
        .executableTarget(name: "LocalScribe", dependencies: ["WritingCore"]),
        .executableTarget(name: "WritingCoreChecks", dependencies: ["WritingCore"], path: "Checks")
    ],
    swiftLanguageModes: [.v5]
)
