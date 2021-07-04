// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tdLBGeometryRushtonTurbineLib",
    platforms: [
        .macOS(.v11),
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
        .package(url: "https://github.com/turbulentdynamics/tdLBSwiftApi.git", from: "0.0.5"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.1")

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.

        .executableTarget(
            name: "rt",
            dependencies: [
                .product(name: "tdLBSwiftApi", package: "tdLBSwiftApi"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "tdLBGeometryRushtonTurbineLib"
        ]),
        .target(
            name: "tdLBGeometryRushtonTurbineLib",
            dependencies: [
                .product(name: "tdLBSwiftApi", package: "tdLBSwiftApi"),
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
