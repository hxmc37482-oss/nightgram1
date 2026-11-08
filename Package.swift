// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NightGram",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "NightGramGiftEngine", targets: ["NightGramGiftEngine"]),
        .library(name: "NightGramGiftUI", targets: ["NightGramGiftUI"])
    ],
    targets: [
        .systemLibrary(
            name: "CSQLite",
            pkgConfig: "sqlite3",
            providers: [.brew(["sqlite3"])]
        ),
        .target(
            name: "NightGramGiftEngine",
            dependencies: ["CSQLite"],
            path: "Sources/NightGramGiftEngine"
        ),
        .target(
            name: "NightGramGiftUI",
            dependencies: ["NightGramGiftEngine"],
            path: "Sources/NightGramGiftUI"
        ),
        .testTarget(
            name: "NightGramGiftEngineTests",
            dependencies: ["NightGramGiftEngine"],
            path: "Tests/NightGramGiftEngineTests"
        )
    ]
)
