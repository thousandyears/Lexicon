//
// github.com/screensailor 2022
//

import Foundation
// UTType is provided by UniformTypeIdentifiers+Compat.swift

public protocol CodeGenerator {
	static var utType: UTType { get }
	static var command: String { get }
	static func generate(_ json: Lexicon.Graph.JSON) throws -> Data
}
