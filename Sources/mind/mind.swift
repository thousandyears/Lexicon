//
// Milos <github.com/screensailor> 2024
//

import ArgumentParser
import Collections
import Foundation
import Lexicon
import LexiconGenerators

@main
struct CodeGeneratorCommand: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "mind",
        abstract: "Mind your lexicon!",
        version: "1.0.0"
    )

    @Argument(help: "Type(s) to return.")
    var type: [String] = []

    @Argument(help: "File path or URL to the lexicon")
    var input: URL

    @Option(
        name: .shortAndLong,
        help: "Output path excluding extension, if not specified the same directory and name of the lexicon will be used"
    )
    var output: URL?

    @Flag(name: .shortAndLong)
    var quiet: Bool = false

    private var isLogging: Bool { !quiet }

    @LexiconActor
    mutating func run() async throws {
        if isLogging {
            print("Reading \(input.lastPathComponent)...")
        }
        let lexicon = try Lexicon.from(
            TaskPaper(Data(contentsOf: input)).decode()
        )
        var result: [String: String] = [:]
        let type = Set(type)
        
        for (id, lemma) in lexicon.dictionary where !type.contains(id) {
            let lemmaType = Set(lemma.type.map(\.1.id))
            guard type.isSubset(of: lemmaType) else {
                continue
            }
            result[id] = lemma.name
        }
        
        let file = output?.appendingPathExtension("json") ?? input.deletingLastPathComponent()
                .appendingPathComponent(lexicon.root.name)
                .appendingPathExtension("json")
        
        if var loaded = try? JSONDecoder().decode([String:String].self, from: Data(contentsOf: file)) {
            for id in Set(loaded.keys).subtracting(result.keys) {
                loaded.removeValue(forKey: id)
            }
            result = loaded.merging(result, uniquingKeysWith: { loaded, _ in loaded })
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(result).write(to: file)
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
