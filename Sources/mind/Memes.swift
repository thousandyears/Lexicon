//
// Milos <github.com/screensailor> 2024
//

import ArgumentParser
import Collections
import Foundation
import Lexicon
import LexiconGenerators

struct Memes: AsyncParsableCommand {
    
    static var configuration = CommandConfiguration(
        commandName: "memes",
        abstract: "Maintain json dictionaries of memes filtered by --type",
        version: "1.0.0"
    )

    @Argument(help: "File path or URL to the lexicon")
    var lexicon: URL
    
    @Option(name: .shortAndLong, help: "Type(s) to return")
    var type: [String]

    @Option(
        name: .shortAndLong,
        help: "Output path excluding extension, if not specified the same directory and name of the lexicon will be used"
    )
    var output: URL?

    @LexiconActor
    mutating func run() async throws {
        let lexicon = try Lexicon.from(
            TaskPaper(Data(contentsOf: self.lexicon)).decode()
        )
        
        let file = output ?? self.lexicon.deletingLastPathComponent()
                .appendingPathComponent(lexicon.root.name)
                .appendingPathExtension("json")
        
        let loaded = try? JSONSerialization.jsonObject(with: Data(contentsOf: file)) as? [String: Any]
        
        let result = dictionary(lexicon: lexicon, type: Set(type), loaded: loaded ?? [:])
        
        try JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys])
            .write(to: file)
    }

    @LexiconActor
    private func dictionary(
        lexicon: Lexicon,
        type: Set<String>,
        loaded: [String: Any]
    ) -> [String: Any] {
        var result: [String: Any] = [:]
        
        lexicon.root.traverse(.depthFirst) { lemma in
            guard type.isSubset(of: Set(lemma.type.map(\.1.id))) else {
                return
            }
            result[lemma.id] = lemma.name
        }
        
        result = loaded
            .filter{ id, _ in Set(result.keys).contains(id) }
            .merging(result, uniquingKeysWith: { loaded, _ in loaded })

        return result
    }
}
