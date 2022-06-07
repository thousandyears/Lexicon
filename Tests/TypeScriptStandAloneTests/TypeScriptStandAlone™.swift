@_exported import Hope
@_exported import Combine
@_exported import Lexicon
@_exported import TypeScriptStandAlone

final class TypeScriptLexicon™: Hopes {
	
	func test_generator() async throws {
		
		var json = try await "test".taskpaper().lexicon().json()
		json.date = Date(timeIntervalSinceReferenceDate: 0)
		
		let code = try Generator.generate(json).string()
        		
		try hope(code) == "test.ts".file().string()
	}
	
	func test_code() throws {
		/**
		 @Test
		 fun generator(){
			assert(test.one.more.time.one.more.time.identifier == "test.one.more.time.one.more.time")
			assert(test.two.bad == test.two.no.good)
			assert(test.two.bad.identifier == "test.two.no.good")
		 }
		 */
	}
}
