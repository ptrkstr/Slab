// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Slab",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Slab",
            targets: ["Slab"]),
    ],
    dependencies: [
		.package(url: "https://github.com/scinfu/SwiftSoup", .upToNextMajor(from: "2.0.0")),
		.package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Slab",
            dependencies: [
				"SwiftSoup",
				.product(name: "Collections", package: "swift-collections")
			]),
        .testTarget(
            name: "SlabTests",
            dependencies: ["Slab"]),
    ]
)
