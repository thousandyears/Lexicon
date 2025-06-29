//
// github.com/screensailor 2022
//

import Foundation
import Synchronization

// Swift Concurrency-based event system with multi-subscriber support
public final class Events: AsyncSequence, @unchecked Sendable {
    public typealias Element = Event
    
    private let _continuations = Mutex<[UUID: AsyncStream<Event>.Continuation]>([:])
    
    public init() {}
    
    public func send(_ event: Event) {
        _continuations.withLock { continuations in
            for continuation in continuations.values {
                continuation.yield(event)
            }
        }
    }
    
    public nonisolated func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(events: self)
    }
    
    private func subscribe() -> AsyncStream<Event> {
        let id = UUID()
        let (stream, continuation) = AsyncStream.makeStream(of: Event.self)
        
        _continuations.withLock { continuations in
            continuations[id] = continuation
        }
        
        continuation.onTermination = { [weak self] _ in
            self?._continuations.withLock { continuations in
                _ = continuations.removeValue(forKey: id)
            }
        }
        
        return stream
    }
    
    public func filter(_ predicate: @escaping @Sendable (Event) -> Bool) -> AsyncFilterSequence<AsyncStream<Event>> {
        subscribe().filter(predicate)
    }
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        private var streamIterator: AsyncStream<Event>.Iterator
        
        init(events: Events) {
            self.streamIterator = events.subscribe().makeAsyncIterator()
        }
        
        public mutating func next() async -> Event? {
            return await streamIterator.next()
        }
    }
}

// MARK: send

public func >> (event: Event, events: Events) {
	events.send(event)
}

public func >> <A: L>(event: A, events: Events) {
	events.send(Event(event))
}

public func >> <A: L>(event: K<A>, events: Events) {
	events.send(Event(event))
}

// MARK: receive

public extension AsyncSequence {
	
	@inlinable func sink(receiveValue: @escaping (Element) async -> Void) -> AnyCancellable {
		Task {
			do {
				for try await element in self {
					await receiveValue(element)
				}
			} catch {
				// Silently handle errors in event streams
			}
		}
	}
}

// MARK: receive out of context

public extension AsyncSequence where Element == Event {
	
	func then(_ ƒ: @escaping (Event) async -> ()) -> (Self, (Event) async -> ()) {
		(self, ƒ)
	}
}

public func >> <A>(event: A.Type, context: (Events, (Event) async -> ())) -> AnyCancellable {
	context.0.filter{ $0.k(\.L) is A }.sink { event in
		await context.1(event)
	}
}

public func >> <A>(event: A, context: (Events, (Event) async -> ())) -> AnyCancellable
where A: I {
	context.0.filter{ $0.is(event) }.sink { event in
		await context.1(event)
	}
}

public func >> <A>(event: K<A>, context: (Events, (Event) async -> ())) -> AnyCancellable
where A: L {
	context.0.filter{ $0.is(event) }.sink { event in
		await context.1(event)
	}
}

// MARK: receive in context

public extension EventContext {
	
	func context<S: AsyncSequence>(_ s: S) -> (@escaping (Self, S.Element) async -> ()) -> (Self?, S, (Self, S.Element) async -> ()) {
		{ [unowned self] in (self, s, $0) }
	}
	
	func context(_ when: @escaping (Self, Event) -> Bool) -> (@escaping (Self, Event) async -> ()) -> (Self?, AsyncFilterSequence<AsyncStream<Event>>, (Self, Event) async -> ()) {
		let filtered = events.filter{ [unowned self] event in
			return when(self, event)
		}
		return { [unowned self] in (self, filtered, $0) }
	}
	
	func context(_ when: @escaping (Self) -> Bool) -> (@escaping (Self, Event) async -> ()) -> (Self?, AsyncFilterSequence<AsyncStream<Event>>, (Self, Event) async -> ()) {
		let filtered = events.filter{ [unowned self] event in
			return when(self)
		}
		return { [unowned self] in (self, filtered, $0) }
	}
	
	func context() -> (@escaping (Self, Event) async -> ()) -> (Self?, Events, (Self, Event) async -> ()) {
		{ [unowned self] in (self, self.events, $0) }
	}
}

public func >> <O, S, A>(event: A.Type, context: (O?, S, (O, Event) async -> ())) -> AnyCancellable
where O: AnyObject, S: AsyncSequence, S.Element == Event
{
	context.1.filter{ $0.k(\.L) is A }.sink { [weak o = context.0, ƒ = context.2] event in
		guard let o = o else { return }
		await ƒ(o, event)
	}
}

public func >> <O, S, A>(event: A, context: (O?, S, (O, Event) async -> ())) -> AnyCancellable
where A: I, O: AnyObject, S: AsyncSequence, S.Element == Event
{
	context.1.filter{ $0.is(event) }.sink { [weak o = context.0, ƒ = context.2] event in
		guard let o = o else { return }
		await ƒ(o, event)
	}
}

public func >> <O, S, A>(event: K<A>, context: (O?, S, (O, Event) async -> ())) -> AnyCancellable
where A: L, O: AnyObject, S: AsyncSequence, S.Element == Event
{
	context.1.filter{ $0.is(event) }.sink { [weak o = context.0, ƒ = context.2] event in
		guard let o = o else { return }
		await ƒ(o, event)
	}
}
