//
// github.com/screensailor 2022
//

import Lexicon
import UniformTypeIdentifiers

public enum Generator: CodeGenerator {
	
	// TODO: prefixes?
	
	public static let utType = UTType(filenameExtension: "kt", conformingTo: .sourceCode)!
	
	public static func generate(_ json: Lexicon.Graph.JSON) throws -> Data {
		return Data(json.kotlin().utf8)
	}
}

private extension Lexicon.Graph.JSON {
	
	func kotlin() -> String {
		return """
interface I: TypeLocalized, SourceCodeIdentifiable

interface TypeLocalized {
	val localized: String
}

interface SourceCodeIdentifiable {
	val identifier: String
}

val SourceCodeIdentifiable.debugDescription get() = identifier

open class L(override val localized: String = "", override val identifier: String,) : I

// MARK: generated types

val \(name) = L_\(name)("\(name)")

\(classes.flatMap{ $0.kotlin(prefix: ("L", "I")) }.joined(separator: "\n"))

"""
	}
}

private extension Lexicon.Graph.Node.Class.JSON {
	
	// TODO: make this more readable
	
	func kotlin(prefix: (class: String, protocol: String)) -> [String] {
		
		guard mixin == nil else {
			return []
		}
		
		var lines: [String] = []
		let T = id.idToClassSuffix
		let (L, I) = prefix
		
		if let protonym = protonym {
			lines += "typealias \(L)_\(T) = \(L)_\(protonym.idToClassSuffix)"
			return lines
		}
		
		lines += "data class \(L)_\(T)(override val identifier: String): L(identifier = identifier), \(I)_\(T)"
		
		let supertype = supertype?
			.replacingOccurrences(of: "_", with: "__")
			.replacingOccurrences(of: ".", with: "_")
			.replacingOccurrences(of: "__&__", with: ", I_")
		
		lines += "interface \(I)_\(T): \(I)\(supertype.map{ "_\($0)" } ?? "")"
		
		guard hasProperties else {
			return lines
		}
		
		for child in children ?? [] {
			let id = "\(id).\(child)"
			lines += "val \(I)_\(T).`\(child)`: \(L)_\(id.idToClassSuffix) get() = \(L)_\(id.idToClassSuffix)(\"${identifier}.\(child)\")"
		}
		
		for (synonym, protonym) in (synonyms?.sortedByLocalizedStandard(by: \.key) ?? []) {
			let id = "\(id).\(synonym)"
			lines += "val \(I)_\(T).`\(synonym)`: \(L)_\(id.idToClassSuffix) get() = \(protonym)"
		}
		
		return lines
	}
	
}

private extension String {
	
	var idToClassSuffix: String {
		replacingOccurrences(of: "_", with: "__")
			.replacingOccurrences(of: ".", with: "_")
			.replacingOccurrences(of: "_&_", with: "_")
	}
}
