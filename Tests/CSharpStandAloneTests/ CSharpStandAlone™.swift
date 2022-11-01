@_exported import Hope
@_exported import Combine
@_exported import Lexicon
@_exported import CSharpStandAlone

final class CSharpLexicon™: Hopes {
	
	func test_generator() async throws {
		
		var json = try await "test".taskpaper().lexicon().json()
		json.date = Date(timeIntervalSinceReferenceDate: 0)
		
		let code = try Generator.generate(json).string()
		
		try hope(code) == "test.cs".file().string()
	}
	
	func test_code() throws {
	}
}
