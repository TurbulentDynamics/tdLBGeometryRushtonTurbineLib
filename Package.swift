// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tdGeometryRushtonTurbineLib",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "tdGeometryRushtonTurbineLib",
            targets: ["tdGeometryRushtonTurbineLib"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/turbulentdynamics/tdLBApi.git", from: "0.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "tdGeometryRushtonTurbineLib",
            dependencies: [
                .product(name: "tdLBApi", package: "tdLBApi")
        ]),
        .testTarget(
            name: "tdGeometryRushtonTurbineLibTests",
            dependencies: [
                "tdGeometryRushtonTurbineLib"
        ]),
    ]
)
