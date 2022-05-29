import ArgumentParser
import Collections
import Foundation
import Lexicon
import LexiconGenerators

@main
struct CodeGeneratorCommand: AsyncParsableCommand {

	static var configuration = CommandConfiguration(
		commandName: "lexicon-generate",
		abstract: "A utility for generating code from lexicon documents.",
		version: "1.0.0"
	)

	@Argument
	var input: URL

	@Option(name: .shortAndLong)
	var output: URL?

	@Option(name: .shortAndLong)
	var type: [String]

	@Flag(name: .shortAndLong)
	var quiet: Bool = false

	private var isLogging: Bool { !quiet }

	mutating func run() async throws {
		let name = String(input.lastPathComponent.split(separator: ".")[0])
		if isLogging {
			print("\(name) lexicon")
		}
		let output = self.output ?? input.deletingLastPathComponent()
		let lexicon = try await Lexicon.from(
			TaskPaper(Data(contentsOf: input)).decode()
		)
		let json = await lexicon.json()
		for commandName in type {
			guard
				let generator = Lexicon.Graph.JSON.generators.named(commandName),
				let `extension` = generator.utType.preferredFilenameExtension
			else { continue }
			let url = output.appendingPathComponent(name)
				.appendingPathExtension(`extension`)
			if isLogging { print(url.path) }
			try generator.generate(json)
				.write(to: url)
		}
	}
}

typealias Generators = OrderedDictionary<String, CodeGenerator.Type>

extension Generators {

	func named(_ command: String) -> CodeGenerator.Type? {
		first { _, value in value.command == command }?.value
	}
}

extension URL: ExpressibleByArgument {

	public init?(argument: String) {
		self.init(fileURLWithPath: argument)
	}
}

extension Array: ExpressibleByArgument where Element: ExpressibleByArgument {

	public init?(argument: String) {
		self = argument.split(separator: ",").compactMap { substring in
			Element(argument: String(substring))
		}
	}
}
