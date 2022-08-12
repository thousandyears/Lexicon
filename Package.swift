// swift-tools-version: 5.6

import PackageDescription

let package = Package(
	name: "Lexicon",
	platforms: [
		.macOS(.v11),
		.iOS(.v14)
	],
	products: [
		.library(name: "Lexicon", targets: ["Lexicon"]),
		.library(name: "SwiftLexicon", targets: ["SwiftLexicon"]),
		.library(name: "SwiftStandAlone", targets: ["SwiftStandAlone"]),
		.library(name: "KotlinStandAlone", targets: ["KotlinStandAlone"]),
		.library(name: "TypeScriptStandAlone", targets: ["TypeScriptStandAlone"]),
		.library(name: "LexiconGenerators", targets: ["LexiconGenerators"]),
		.executable(name: "lexicon-generate", targets: ["lexicon-generate"]),
		.plugin(name: "SwiftStandAloneGeneratorPlugin", targets: ["SwiftStandAloneGeneratorPlugin"]),
		.plugin(name: "SwiftLibraryGeneratorPlugin", targets: ["SwiftLibraryGeneratorPlugin"]),
	],
	dependencies: [
		.package(url: "https://github.com/screensailor/Hope", branch: "trunk"),
		.package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
		.package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.2")
	],
	targets: [
		.target(
			name: "Lexicon",
			dependencies: [
				.product(name: "Collections", package: "swift-collections")
			],
			swiftSettings: [.define("EDITOR")] // TODO: make this opt in
		),
		.testTarget(
			name: "LexiconTests",
			dependencies: [
				"Hope",
				"Lexicon"
			],
			resources: [.copy("Resources")]
		),
		.target(
			name: "LexiconGenerators",
			dependencies: [
				"Lexicon",
				"SwiftLexicon",
				"SwiftStandAlone",
				"KotlinStandAlone",
        "TypeScriptStandAlone"
			]
		),
		.target(
			name: "SwiftLexicon",
			dependencies: [
				"Lexicon"
			]
		),
		.testTarget(
			name: "SwiftLexiconTests",
			dependencies: [
				"Hope",
				"SwiftLexicon"
			],
			resources: [.copy("Resources")]
		),
		.target(
			name: "SwiftStandAlone",
			dependencies: [
				"Lexicon",
			]
		),
		.testTarget(
			name: "SwiftStandAloneTests",
			dependencies: [
				"Hope",
				"SwiftStandAlone"
			],
			resources: [.copy("Resources")]
		),
		.target(
			name: "KotlinStandAlone",
			dependencies: [
				"Lexicon",
			]
		),
		.testTarget(
			name: "KotlinStandAloneTests",
			dependencies: [
				"Hope",
				"KotlinStandAlone"
			],
			resources: [.copy("Resources")]
		),
    .target(
			name: "TypeScriptStandAlone",
			dependencies: [
				"Lexicon",
			]
		),
		.testTarget(
			name: "TypeScriptStandAloneTests",
			dependencies: [
				"Hope",
				"TypeScriptStandAlone"
			],
			resources: [.copy("Resources")]
		),
		.executableTarget(
			name: "lexicon-generate",
			dependencies: [
				.target(name: "LexiconGenerators"),
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				.product(name: "Collections", package: "swift-collections")
			]
		),
		.plugin(
			name: "SwiftStandAloneGeneratorPlugin",
			capability: .buildTool(),
			dependencies: ["lexicon-generate"]
		),
		.plugin(
			name: "SwiftLibraryGeneratorPlugin",
			capability: .buildTool(),
			dependencies: ["lexicon-generate"]
		)
	]
)
