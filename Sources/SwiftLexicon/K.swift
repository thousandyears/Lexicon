//
// github.com/screensailor 2022
//

public extension I where Self: L {
	
	subscript<Value>(value: Value) -> K<Self> where Value: Sendable, Value: Hashable {
		K(self, [self: value])
	}
}

@dynamicMemberLookup public struct K<A: L>: @unchecked Sendable, Hashable, KProtocol {
	
	public let __: String
	public let ___: A
	public let ____: [L: AnyHashable]
	
	public init(_ a: A) {
		self.init(a, [:])
	}
	
	internal init(_ l: A, _ d: [L: AnyHashable]) {
		self.____ = d
		self.___ = l
		self.__ = d.sorted(by: { $0.key.__.count > $1.key.__.count }).reduce(into: l.__) { (o, e) in
			assert(o.starts(with: e.key.__))
			let i = o.index(o.startIndex, offsetBy: e.key.__.count)
			o.insert(contentsOf: "[\(e.value)]", at: i) // TODO: measure performance
		}
	}
}

public extension K {
	@inlinable static var localized: String { A.localized }
}

public extension K {
	
	subscript<B: L>(dynamicMember keyPath: KeyPath<A, B>) -> K<B> {
		K<B>(___[keyPath: keyPath], ____)
	}
	
	subscript<Value>(value: Value) -> K<A> where Value: Sendable, Value: Hashable {
		K(___, ____.merging([___: value], uniquingKeysWith: { _, last in last }))
	}
}

public extension K {
	
	subscript() -> Any? { self[___] }
	
	subscript(key: L) -> Any? { ____[key]?.base }
	
	subscript<X>(as type: X.Type = X.self) -> X {
		get throws { try self[___] }
	}
	
	subscript<X>(key: L, as type: X.Type = X.self) -> X {
		get throws { try (self[key] as? X).try() }
	}
}

public protocol KProtocol: I {
	var __: String { get }
	var ____: [L: AnyHashable] { get }
	subscript() -> Any? { get }
	subscript(key: L) -> Any? { get }
	subscript<A>(as type: A.Type) -> A { get throws }
	subscript<A>(key: L, as type: A.Type) -> A { get throws }
	func callAsFunction(_: KeyPath<CallAsFunctionKExtensions, CallAsFunctionKExtensions.GetL>) -> L
}

public extension K {
	
	@inlinable func callAsFunction(_: KeyPath<CallAsFunctionKExtensions, CallAsFunctionKExtensions.GetL>) -> L {
		___
	}
}

public enum CallAsFunctionKExtensions {}

public extension CallAsFunctionKExtensions {
	var L: GetL { .init() }
	struct GetL {}
}

extension K { // TODO: ↓
	//    private static let brackets = CharacterSet(charactersIn: "[]")
	//
	//    var detail: (id: String, data: [String: String]) {
	//        let substrings = description.components(separatedBy: Self.brackets).filter(\.isEmpty.not)
	//        var id = ""
	//        var data: [String: String] = [:]
	//        for (i, (k, v)) in zip(substrings, substrings.dropFirst()).enumerated() where i.isMultiple(of: 2) {
	//            id = (i == 0) ? k : (id + k)
	//            data[id] = v
	//        }
	//        id = substrings.enumerated().filter{ $0.offset.isMultiple(of: 2) }.map(\.element).joined()
	//        return (id, data)
	//    }
}
