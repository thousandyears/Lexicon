//
// Milos <github.com/screensailor> 2024
//

import ArgumentParser

@main
struct Mind: AsyncParsableCommand {
    
    static var configuration = CommandConfiguration(
        commandName: "mind",
        abstract: "Mind your lexicon!",
        version: "1.0.0",
        subcommands: [Memes.self]
    )
}

