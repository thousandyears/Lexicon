//
// github.com/screensailor 2021
//

import Foundation

@LexiconActor public final class Lexicon: ObservableObject {
	
	@Published public private(set) var graph: Graph
	
	public internal(set) var dictionary: [Lemma.ID: Lemma] = [:]
	
	private var lemma: Lemma! // TODO: serioulsy?
	
	private init(_ graph: Graph) {
		self.graph = graph
	}
	
	deinit {
		assertionFailure("🗑 \(self)") // TODO: hard rethink
	}
}

public extension Lexicon {
	
	var root: Lemma { lemma! }
	
	subscript(id: Lemma.ID) -> Lemma? {
		dictionary[id] ?? lemma?[id.components(separatedBy: ".")]
	}
}

public extension Lexicon {
	
	static func from(_ graph: Graph) -> Lexicon {
		let o = Lexicon(graph)
		connect(lexicon: o, with: graph)
		all.append(o)
		return o
	}

	#if EDITOR
	func reset(to graph: Graph) {
		Lexicon.connect(lexicon: self, with: graph)
	}
	#endif
}

private extension Lexicon {
	
	static var all: [Lexicon] = []
	
	static func connect(lexicon: Lexicon, with new: Graph? = nil) {
		let graph = new ?? lexicon.graph
		lexicon.dictionary.removeAll(keepingCapacity: true)
		lexicon.lemma = Lemma(name: graph.root.name, node: graph.root, parent: nil, lexicon: lexicon)
		lexicon.graph = graph
	}

	func regenerateGraph(_ ƒ: ((Lemma) -> ())? = nil) -> Lexicon.Graph {
		Lexicon.Graph(
			root: root.regenerateNode(ƒ),
			date: .init()
		)
	}
}

#if EDITOR

// MARK: graph mutations

public extension Lexicon { // MARK: additive mutations
	
	func add(type: Lemma, to lemma: Lemma) -> Lemma? {
		
		guard
			lemma.isValid(newType: type),
			let path = lemma.graphPath
		else {
			return nil // TODO: throw
		}
		
		var graph = graph
		graph.date = .init()
		
		graph[path].type.insert(type.id)
		
		reset(to: graph)
		return self[lemma.id]
	}

	func make(child new: Graph, to lemma: Lemma) -> Lemma? {
		
		let name = new.root.name
		
		guard
			lemma.isValid(newChildName: name),
			let path = lemma.graphPath
		else {
			return nil // TODO: throw
		}
		
		var new = new
		
		var protonyms: [(Graph.Node, Graph.Path)] = [] // TODO: reinstate
		var inheritance: [(Graph.Node, Graph.Path)] = [] // TODO: reinstate

		for (node, path) in new.root.graphTraversalWithPaths(.breadthFirst) {
			if node.protonym != nil {
				protonyms.append((node, path))
				new[path].protonym = nil
			}
			else if !node.type.isEmpty {
				inheritance.append((node, path))
				new[path].type = []
			}
		}
		
		var graph = graph
		graph.date = .init()
		
		graph[path].children[name] = new.root

		reset(to: graph)
		return self["\(lemma.id).\(name)"]
	}
	
	func make(child name: Lemma.Name, to lemma: Lemma) -> Lemma? {
		
		guard
			lemma.isValid(newChildName: name),
			let path = lemma.graphPath
		else {
			return nil // TODO: throw
		}
		
		var graph = graph
		graph.date = .init()

		graph[path].make(child: name)

		reset(to: graph)
		return self["\(lemma.id).\(name)"]
	}
}

public extension Lexicon { // MARK: non-additive mutations
	
	func delete(_ lemma: Lemma) -> Lemma? {
		
		guard
			lemma.isGraphNode,
			let parent = lemma.parent
		else {
			return nil // TODO: throw
		}
		
		parent.ownChildren.removeValue(forKey: lemma.name)
		
		root.graphTraversal(.depthFirst) { o in
			for (name, type) in o.ownType where type.unwrapped.isInLineage(of: lemma) {
				o.ownType.removeValue(forKey: name)
			}
		}

		let graph = regenerateGraph { o in
			for (name, child) in o.ownChildren {
				if
					let protonym = child.node.protonym,
					parent[protonym.components(separatedBy: ".")] == nil // TODO: performance
				{
					o.ownChildren.removeValue(forKey: name)
				}
			}
		}

		reset(to: graph)
		return self[parent.id]
	}
	
	func remove(type: Lemma, from lemma: Lemma) -> Lemma? {
		
		guard
			lemma.isGraphNode,
			let type = lemma.ownType.removeValue(forKey: type.id)?.unwrapped
		else {
			return nil
		}
		
		let graph = regenerateGraph { o in
			if let protonym = o.protonym {
				// TODO: !
			}
		}
		
		reset(to: graph)
		return self[lemma.id]
	}
	
	func removeProtonym(of lemma: Lemma) -> Lemma? {
		
		guard lemma.isGraphNode else {
			return nil
		}
		
		lemma.protonym = nil
		
		let graph = regenerateGraph()
		
		reset(to: graph)
		return self[lemma.id]
	}

	func rename(_ lemma: Lemma, to name: Lemma.Name) -> Lemma? {
		
		guard lemma.isValid(newName: name) else {
			return nil // TODO: throw
		}
		
		let old = (
			id: lemma.id,
			name: lemma.name
		)
		
		let new = (
			id: String(lemma.id.dropLast(old.name.count) + name),
			name: name
		)
		
//		lemma.node.id = new.id
//		lemma.node.name = new.name
//
//		var graph = graph
//		graph.date = .init()
//
//		if let parent = lemma.parent {
//			graph[parent.node].children[old.name] = nil
//			graph[parent.node].children[new.name] = lemma.node
//		} else {
//			graph.root = lemma.node
//		}
//
//		let namePattern = try! NSRegularExpression(pattern: "\\b\(new.name)\\b", options: [])
//
//		for node in graph.root.graphTraversal(.breadthFirst) {
//			if
//				let protonym = node.protonym,
//				namePattern.firstMatch(in: protonym, options: [], range: protonym.nsRange) != nil, // TODO: performance - not necessarily our node
//				let synonym = self[node.id]
//			{
//				let count = protonym.split(separator: ".").count
//				graph[node].protonym  = sequence(first: synonym, next: \.parent)
//					.prefix(count)
//					.map(\.node.name)
//					.reversed()
//					.joined(separator: ".")
//			}
//			else {
//				//                otherNode.type = Set(otherNode.type.map{ id in
//				//                    guard id.starts(with: old.id) else { // TODO: user range(of:)
//				//                        return id
//				//                    }
//				//                    return String(new.id + id.dropFirst(old.id.count)) // TODO: preformance (use range)
//				//                }) // TODO: performance
//			}
//		}
//
//		reset(to: graph)
//		return self[new.id]
		fatalError()
	}

	func set(protonym: Lemma, of lemma: Lemma) -> Lemma? {
		
		guard lemma.isValid(protonym: protonym) else {
			return nil
		}

		lemma.protonym = Unowned(protonym)
		lemma.ownChildren.removeAll()
		lemma.ownType.removeAll()
		
		let graph = regenerateGraph { o in
			if let protonym = o.protonym {
				if protonym.unwrapped.isAncestor(of: lemma) {
					o.protonym = nil
				}
			} else {
				for (name, type) in o.type where type.unwrapped.isAncestor(of: lemma) {
					o.type.removeValue(forKey: name)
				}
			}
		}
				
		reset(to: graph)

		guard
			let id = lemma.parent?.id,
			let parent = self[id],
			let lemma = parent.children[lemma.name] // fonund the synonym rather than protonym
		else {
			return self[lemma.id]
		}
		
		return lemma
	}
}

#endif
