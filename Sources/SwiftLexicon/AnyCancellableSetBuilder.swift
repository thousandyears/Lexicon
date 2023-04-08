//
// github.com/screensailor 2022
//

import Combine

public typealias Bear = AnyCancellableSetBuilder
public typealias Mind = Set<AnyCancellable>

@resultBuilder public enum AnyCancellableSetBuilder {}

public extension AnyCancellableSetBuilder {
	
	typealias Element = AnyCancellable
	typealias Component = Set<Element>
    
    static func buildPartialBlock(first: Element) -> Component {
        [first]
    }

    static func buildPartialBlock(first: Component) -> Component {
        first
    }
    
    static func buildPartialBlock(accumulated: Element, next: Element) -> Component {
        Set([accumulated, next])
    }
    
    static func buildPartialBlock(accumulated: Element, next: Component) -> Component {
        next.union([accumulated])
    }
    
    static func buildPartialBlock(accumulated: Component, next: Element) -> Component {
        accumulated.union([next])
    }
    
    static func buildPartialBlock(accumulated: Component, next: Component) -> Component {
        accumulated.union(next)
    }
}

public extension Set where Element == AnyCancellable {
	
	@inlinable static func += <A: Collection>(lhs: inout Self, rhs: A) where A.Element == AnyCancellable {
		lhs.formUnion(rhs)
	}
	
	@inlinable static func += (lhs: inout Self, rhs: AnyCancellable) {
		lhs.insert(rhs)
	}
	
	@inlinable mutating func `in`(_ mind: AnyCancellable) {
		insert(mind)
	}
	
	@inlinable mutating func `in`<A: Sequence>(_ mind: A) where A.Element == AnyCancellable {
		formUnion(mind)
	}
}
