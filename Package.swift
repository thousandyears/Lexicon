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
		.library(name: "LexiconGenerators", targets: ["LexiconGenerators"]),
		.executable(name: "lexicon-generate", targets: ["lexicon-generate"]),
		.plugin(name: "LexiconCodeGeneratorPlugin", targets: ["LexiconCodeGeneratorPlugin"])
	],
	dependencies: [
		.package(url: "https://github.com/screensailor/Hope", branch: "trunk"),
		.package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
		.package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.2")
	],
	targets: [
		
		// MARK: Lexicon
		
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
			resources: [
				.copy("Resources")
			]
		),
		
		// MARK: LexiconGenerators
		
			.target(
				name: "LexiconGenerators",
				dependencies: [
					"Lexicon",
					"SwiftLexicon",
					"SwiftStandAlone",
					"KotlinStandAlone"
				]
			),
		
		// MARK: SwiftLexicon
		
			.target(
				name: "SwiftLexicon",
				dependencies: [
					"Lexicon",
				]
			),
		.testTarget(
			name: "SwiftLexiconTests",
			dependencies: [
				"Hope",
				"SwiftLexicon"
			],
			resources: [
				.copy("Resources"),
			]
		),
		
		// MARK: SwiftStandAlone
		
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
			resources: [
				.copy("Resources"),
			]
		),
		
		// MARK: KotlinStandAlones
		
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
			resources: [
				.copy("Resources"),
			]
		),

		// MARK: Swift Package Manager Plugin

			.executableTarget(
				name: "lexicon-generate",
				dependencies: [
					.target(name: "LexiconGenerators"),
					.product(name: "ArgumentParser", package: "swift-argument-parser"),
					.product(name: "Collections", package: "swift-collections")
				]
			),
		.plugin(
			name: "LexiconCodeGeneratorPlugin",
			capability: .buildTool(),
			dependencies: ["lexicon-generate"]
		)
	]
)
