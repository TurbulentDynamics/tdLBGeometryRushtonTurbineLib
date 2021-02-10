// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tdLBGeometryRushtonTurbineLib",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "tdLBGeometryRushtonTurbineLib",
            targets: ["tdLBGeometryRushtonTurbineLib"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/turbulentdynamics/tdLBApi.git", from: "0.0.3"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.2")

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.

        .target(
            name: "rt",
            dependencies: [
                .product(name: "tdLBApi", package: "tdLBApi"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "tdLBGeometryRushtonTurbineLib"
        ]),
        .target(
            name: "tdLBGeometryRushtonTurbineLib",
            dependencies: [
                .product(name: "tdLBApi", package: "tdLBApi"),
                "tdLBGeometryRushtonTurbineLibObjC"
        ]),
        .target(
            name: "tdLBGeometryRushtonTurbineLibObjC",
            path: "Sources/tdLBGeometryRushtonTurbineLibObjC"
        ),
        .testTarget(
            name: "tdLBGeometryRushtonTurbineLibTests",
            dependencies: [
                "tdLBGeometryRushtonTurbineLib"
        ])
    ],
    cxxLanguageStandard: .cxx11
)
