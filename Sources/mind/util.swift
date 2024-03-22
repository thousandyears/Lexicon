//
// Milos <github.com/screensailor> 2024
//

import Foundation
import Collections
import ArgumentParser

extension URL: ExpressibleByArgument {

    public init?(argument: String) {
        let argument = argument.trimmingCharacters(in: .whitespacesAndNewlines)
        if argument.hasPrefix("http") {
            self.init(string: argument)
        } else {
            self.init(fileURLWithPath: argument)
        }
    }
}

extension Array: ExpressibleByArgument where Element: ExpressibleByArgument {
    // TODO: private static let pattern = /\s*,\s*/
    // let splits = argument.split(using: Self.pattern)

    public init?(argument: String) {
        self = argument.split(separator: ",").compactMap{ .init(argument: .init($0)) }
    }
}
