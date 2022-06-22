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

	@Argument(help: "File path or URL to the lexicon")
	var input: URL

	@Option(
		name: .shortAndLong,
		help: "Output path excluding extension, if not specified the same directory and name of the lexicon will be used"
	)
	var output: URL?

	@Option(
		name: .shortAndLong,
		help:
		"""
		Types of code to generate. Comma separated.

		Generators:
			\(Lexicon.Graph.JSON.generators.commandHelp)

		Example:
			--type swift,kotlin
		"""
	)
	var type: [String]

	@Flag(name: .shortAndLong)
	var quiet: Bool = false

	private var isLogging: Bool { !quiet }

	mutating func run() async throws {
		let name = String(input.lastPathComponent.split(separator: ".")[0])
		if isLogging {
			print("\(name) lexicon")
		}
		let lexicon = try await Lexicon.from(
			TaskPaper(Data(contentsOf: input)).decode()
		)
		let json = await lexicon.json()
		let code = try type.map { command in
			guard let generator = Lexicon.Graph.JSON.generators.find(command) else {
				fatalError("Unable to find a generator for \(command)")
			}
			guard let `extension` = generator.utType.preferredFilenameExtension else {
				fatalError("\(command) does not have a valid uniform type identifier: \(generator.utType)")
			}
			return (
				file: output?.appendingPathExtension(`extension`)
					?? input.deletingLastPathComponent()
						.appendingPathComponent(name)
						.appendingPathExtension(`extension`),
				data: try generator.generate(json)
			)
		}
		for (file, data) in code {
			if isLogging { print(file.path) }
			try data.write(to: file)
		}
	}
}

typealias Generators = OrderedDictionary<String, CodeGenerator.Type>

extension Generators {

	var commandHelp: String { values.map { $0.command }.joined(separator: ", ") }

	func find(_ command: String) -> CodeGenerator.Type? {
		first { _, value in value.command == command }?.value
	}
}

extension URL: ExpressibleByArgument {

	public init?(argument: String) {
		if argument.hasPrefix("http") {
			self.init(string: argument)
		} else {
			self.init(fileURLWithPath: argument)
		}
	}
}

extension Array: ExpressibleByArgument where Element: ExpressibleByArgument {

	public init?(argument: String) {
		self = argument.split(separator: ",").compactMap { substring in
			Element(argument: String(substring))
		}
	}
}
