//
// Milos <github.com/screensailor> 2024
//

import ArgumentParser
import Collections
import Foundation
import Lexicon
import LexiconGenerators

struct MindDictionary: AsyncParsableCommand {
    
    static var configuration = CommandConfiguration(
        commandName: "dictionary",
        abstract: "Maintain json dictionaries of lemmas filtered by --type",
        version: "1.0.0"
    )

    @Argument(help: "File path or URL to the lexicon")
    var lexicon: URL
    
    @Option(name: .shortAndLong, help: "Type(s) to return")
    var type: [String]
    
    @Flag(name: .shortAndLong)
    var quiet: Bool = false

    @Option(
        name: .shortAndLong,
        help: "Output path excluding extension, if not specified the same directory and name of the lexicon will be used"
    )
    var output: URL?

    private var isLogging: Bool { !quiet }

    @LexiconActor
    mutating func run() async throws {
        if isLogging {
            print("Reading \(lexicon.lastPathComponent)...")
        }
        let lexicon = try Lexicon.from(
            TaskPaper(Data(contentsOf: self.lexicon)).decode()
        )
        var result: [String: Any] = [:]
        let type = Set(type)
        
        for (id, lemma) in lexicon.dictionary where !type.contains(id) {
            let lemmaType = Set(lemma.type.map(\.1.id))
            guard type.isSubset(of: lemmaType) else {
                continue
            }
            result[id] = lemma.name
        }
        
        let file = output ?? self.lexicon.deletingLastPathComponent()
                .appendingPathComponent(lexicon.root.name)
                .appendingPathExtension("json")
        
        if var loaded = try? JSONSerialization.jsonObject(with: Data(contentsOf: file)) as? [String: Any] {
            for id in Set(loaded.keys).subtracting(result.keys) {
                loaded.removeValue(forKey: id)
            }
            result = loaded.merging(result, uniquingKeysWith: { loaded, _ in loaded })
        }
        
        try JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys])
            .write(to: file)
    }
}

typealias Generators = OrderedDictionary<String, CodeGenerator.Type>

extension Generators {

    var commandHelp: String { values.map { $0.command }.joined(separator: ", ") }

    func find(_ command: String) -> CodeGenerator.Type? {
        first { _, value in value.command == command }?.value
    }
}

