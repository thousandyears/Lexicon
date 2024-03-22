//
// github.com/screensailor 2022
//

import Collections

public extension Lemma {
    
    func traverse(_ traversal: Lexicon.Graph.Traversal, _ ƒ: (Lemma) -> ()) {
        
        let next: @LexiconActor () -> Lemma?
        
        switch traversal {
            
        case .depthFirst:
            
            var buffer: [Lemma] = [self]
            
            next = {
                guard let last = buffer.popLast() else {
                    return nil
                }
                for child in last.children.values.sortedByLocalizedStandard(by: \.id).reversed() {
                    if child.isGraphNode || !Self.isRecursive(lemma: last, child: child) {
                        buffer.append(child)
                    }
                }
                return last
            }
            
        case .breadthFirst:
            
            var buffer: Deque<Lemma> = [self]
            
            next = {
                guard let first = buffer.popFirst() else {
                    return nil
                }
                for child in first.children.values.sortedByLocalizedStandard(by: \.id) {
                    if child.isGraphNode || !Self.isRecursive(lemma: first, child: child) {
                        buffer.append(child)
                    }
                }
                return first
            }
        }
        
        while let descendant = next() {
            ƒ(descendant)
        }
    }
    
    private static func isRecursive(lemma: Lemma, child: Lemma) -> Bool {
        let types = lemma.type.values.filter({ $0.children.keys.contains(child.name) }).map(\.unwrapped)
        guard let type = types.min(by: { a, b in a.isAncestor(of: b) }) else {
            return false
        }
        return lemma.lineage.dropFirst().contains { ancestor in
            ancestor.children.keys.contains(child.name) && ancestor.is(type)
        }
    }
}

public extension Lemma {
	
	func graphTraversal(_ traversal: Lexicon.Graph.Traversal, _ ƒ: (Lemma) -> ()) {
		
		guard isGraphNode else {
			return
		}
		
		let next: @LexiconActor () -> Lemma?
		
		switch traversal {
			
			case .depthFirst:
				
				var buffer: [Lemma] = [self]
				
				next = {
					guard let last = buffer.popLast() else {
						return nil
					}
					buffer.append(contentsOf: last.ownChildren.values.sortedByLocalizedStandard(by: \.id).reversed())
					return last
				}

			case .breadthFirst:
				
				var buffer: Deque<Lemma> = [self]

				next = {
					guard let first = buffer.popFirst() else {
						return nil
					}
					buffer.append(contentsOf: first.ownChildren.values.sortedByLocalizedStandard(by: \.id))
					return first
				}
		}
		
		while let descendant = next() {
			ƒ(descendant)
		}
	}
}
