//
// github.com/screensailor 2022
//

import Foundation

// Swift Concurrency-based cancellation system
public typealias AnyCancellable = Task<Void, Never>

public typealias Bear = TaskSetBuilder
public typealias Mind = Set<AnyCancellable>

@resultBuilder public enum TaskSetBuilder {}

public extension TaskSetBuilder {
	
	typealias Element = AnyCancellable
	typealias Component = Set<Element>
	
	static func buildBlock(_ components: Element...) -> Component {
		components.reduce(into: [], +=)
	}
	
	static func buildBlock(_ first: Component, _ rest: Component...) -> Component {
		([first] + rest).reduce(into: [], +=)
	}
	
	// TODO: ...
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
	
	func cancelAll() {
		forEach { $0.cancel() }
	}
}
