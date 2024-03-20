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
}
