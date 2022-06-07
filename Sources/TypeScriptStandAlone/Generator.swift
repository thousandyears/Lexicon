//
// github.com/screensailor 2022
//

import Lexicon
import UniformTypeIdentifiers

public extension UTType {
	static var typescript = UTType(importedAs: "com.microsoft.ts")
}

public enum Generator: CodeGenerator {
	
	// TODO: prefixes?
	
	public static let utType = UTType.typescript
	
	public static func generate(_ json: Lexicon.Graph.JSON) throws -> Data {
		return Data(json.ts().utf8)
	}
}

private extension Lexicon.Graph.JSON {
	
	func ts() -> String {
		return """
// I
interface I extends TypeLocalized, SourceCodeIdentifiable { }
interface TypeLocalized {
	localized: string
}
interface SourceCodeIdentifiable {
	__: string
}
// L
class L implements I {
	localized: string;
	__: string;

	constructor(id: string, localized = "") {
		this.localized = localized;
		this.__ = id;
	}
}
// MARK: generated types
\(classes.flatMap{ $0.ts(prefix: ("L", "I"), classes: classes) }.joined(separator: "\n"))
const \(name) = new L_\(name)("\(name)");

"""
	}
}

private extension Lexicon.Graph.Node.Class.JSON {
	
	// TODO: make this more readable
	
	func ts(prefix: (class: String, protocol: String), classes: [Lexicon.Graph.Node.Class.JSON]) -> [String] {
		
		guard mixin == nil else {
			return []
		}
		
		var lines: [String] = []
		let T = id.idToClassSuffix
		let (L, I) = prefix
		
		if let protonym = protonym {
			lines += "type \(L)_\(T) = \(L)_\(protonym.idToClassSuffix)"
			return lines
		}
		
		lines += "class \(L)_\(T) extends \(L) implements \(I)_\(T) {"
				
		let supertype = supertype?
			.replacingOccurrences(of: "_", with: "__")
			.replacingOccurrences(of: ".", with: "_")
			.replacingOccurrences(of: "__&__", with: ", I_")
		
		if hasNoProperties {
			if supertype != nil {
				let superChildren = classes.filter {$0.id == supertype}.first?.children

				for child in superChildren ?? [] {
					lines += "  \(child)!: \(L)_\(supertype!)_\(child);"
				}
				lines += "}"

				lines += "type \(I)_\(T) = I_\(supertype!);"
			} else {
				lines += "}"
				lines += "type \(I)_\(T) = I;"
			}
		}
		
		guard hasProperties else {
			return lines
		}
		
		for t in type ?? [] {
			let subClass = classes.filter{$0.id == t}.first
			for child in subClass?.children ?? [] {
				let id = "L.\(t).\(child)"
				lines += "  \(child)!: \(id.idToClassSuffix);"
			}
			if let keys = subClass?.synonyms?.keys {
				for synonym in keys {
					let id = "L.\(t).\(synonym)"
					lines += "  \(synonym)!: \(id.idToClassSuffix);"
				}
			}
			
		}
		
		for child in children ?? [] {
			let id = "\(id).\(child)"
			lines += "  \(child) = new \(L)_\(id.idToClassSuffix)(`${this.__}.\(child)`);"
		}
		
		for (synonym, protonym) in (synonyms?.sortedByLocalizedStandard(by: \.key) ?? []) {
			lines += "  \(synonym) = this.\(protonym);"
		}
		lines += "}"
		
		lines += "interface \(I)_\(T) extends \(I)\(supertype.map{ "_\($0)" } ?? "") {"
		
		for child in children ?? [] {
			let id = "\(id).\(child)"
			lines += "  \(child): \(L)_\(id.idToClassSuffix);"
		}
		lines += "}"
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
