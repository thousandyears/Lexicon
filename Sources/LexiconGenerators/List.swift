//
// github.com/screensailor 2022
//

import Lexicon
import Collections
import SwiftLexicon
import SwiftStandAlone
import KotlinStandAlone
import CSharpStandAlone
import TypeScriptStandAlone

public extension Lexicon.Graph.JSON {
	
	static let generators: OrderedDictionary<String, CodeGenerator.Type> = [
		
		"Swift": SwiftLexicon.Generator.self,
		
		"Swift Stand-Alone": SwiftStandAlone.Generator.self,
		
		"Kotlin Stand-Alone": KotlinStandAlone.Generator.self,
		
		"TypeScript Stand-Alone": TypeScriptStandAlone.Generator.self,
		
		"C# Stand-Alone": CSharpStandAlone.Generator.self,
	
		"JSON Classes & Mixins": JSONClasses.self,
	]
}
