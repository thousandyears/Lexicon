//
// github.com/screensailor 2022
//

import Foundation
import Lexicon

@MainActor public protocol EventContext:
	Hashable,
	Identifiable,
	AnyObject,
	CustomStringConvertible
{
	var events: Events { get }
}

public extension EventContext {
	
	nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
		lhs === rhs
	}
	
	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
