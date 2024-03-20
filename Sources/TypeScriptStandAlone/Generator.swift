//
// github.com/screensailor 2022
//

import Lexicon
import UniformTypeIdentifiers
import Collections

public extension UTType {
	static var typescript = UTType(filenameExtension: "ts", conformingTo: .sourceCode)!
}

public enum Generator: CodeGenerator {
	
	public static let utType = UTType.typescript
	public static let command = "ts"

	public static func generate(_ json: Lexicon.Graph.JSON) throws -> Data {
		return Data(json.ts().utf8)
	}
}

private extension Lexicon.Graph.JSON {
	
	func ts() -> String {
		return """
		export interface LemmaDetails {
		  id: string;
		}

		export interface I {
		  _: LemmaDetails;
		}

		export class L implements I {
		  _: LemmaDetails;
		  constructor(parent: string | undefined, name: string) {
		    this._ = {
		     id: parent ? `${parent}.${name}` : name,
		    };
		  }
		  toString(): string {
		    return this._.id;
		  }
		}

		\(types())

		export const \(name) = new L_\(name)(undefined, "\(name)");
		"""
	}
	
	func types() -> String {
		classes.flatMap{ o in
			o.ts(prefix: ("L", "I"), classes: classes)
		}
		.joined(separator: "\n")
	}
}

private extension Lexicon.Graph.Node.Class.JSON {
	
	func ts(
		prefix: (class: String, protocol: String),
		classes: [Lexicon.Graph.Node.Class.JSON]
	) -> [String] {
		
		guard mixin == nil, protonym == nil else {
			return []
		}
		
		var lines: [String] = []
		let T = id.idToClassSuffix
		let (L, I) = prefix
		let supertype = supertype?
			.replacingOccurrences(of: "_", with: "__")
			.replacingOccurrences(of: ".", with: "_")
			.replacingOccurrences(of: "__&__", with: ", I_")

		
		lines += "export class \(L)_\(T) extends \(L) implements \(I)_\(T) {"
		
		for (name, id) in allChildren(in: classes) {
			lines += "  get \(name)() { return new \(L)_\(id.idToClassSuffix)(this._.id, `\(name)`) }"
		}
		
		for (name, path) in allSynonyms(in: classes) {
			lines += "  get \(name)() { return this.\(path); }"
		}

		lines += "}"
		
		lines += "export interface \(I)_\(T) extends \(I)\(supertype.map{ "_\($0)" } ?? "") {"
		
		for child in children ?? [] {
			lines += "  \(child): \(I)_\("\(id).\(child)".idToClassSuffix);"
		}
		
		for (name, path) in synonyms ?? [:] {
			lines += "  \(name): \(I)_\("\(id).\(path)".idToClassSuffix);"
		}


		lines += "}"

		lines += ""

		return lines
	}
	
	func allSynonyms(in classes: [Lexicon.Graph.Node.Class.JSON]) -> Dictionary<Lemma.Name, Lemma.Protonym> {
		var o = synonyms ?? [:]
		for type in self.type?.compactMap({ id in classes.first{ $0.id == id }}) ?? [] {
			o.merge(type.allSynonyms(in: classes), uniquingKeysWith: {_, last in last})
		}
		return o
	}
	
	func allChildren(in classes: [Lexicon.Graph.Node.Class.JSON]) -> OrderedDictionary<Lemma.Name, Lemma.ID> {
		var o: OrderedDictionary<String, String> = [:]
		for name in children ?? [] {
			o[name] = "\(id).\(name)"
		}
		for type in self.type?.compactMap({ id in classes.first{ $0.id == id }}) ?? [] {
			o.merge(type.allChildren(in: classes), uniquingKeysWith: {_, last in last})
		}
		return o
	}
}

private extension String {
	
	var idToClassSuffix: String {
		replacingOccurrences(of: "_", with: "__")
			.replacingOccurrences(of: ".", with: "_")
			.replacingOccurrences(of: "_&_", with: "_")
	}
	
	func substringAfterLast(_ separator: Character) -> String {
		if let lastDotIndex = lastIndex(of: separator) {
			return String(self[index(after: lastDotIndex)...])
		}
		return self
	}
}
