import PackagePlugin
import Foundation

@main
struct LexiconCodeGeneratorPlugin: BuildToolPlugin {

	func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
		let lexicon = try context.tool(named: "lexicon-generate")
		let output = context.pluginWorkDirectory.appending("GeneratedSources")
		return FileManager.default.enumerator(atPath: target.directory.string)?
			.compactMap { value in (value as? String).map(target.directory.appending) }
			.filter { path in
				["taskpaper", "lexicon"].contains(path.extension)
			}
			.map { input in
				return .buildCommand(
					displayName: "Generate Swift Lexicon Identifiers for \(input)",
					executable: lexicon.path,
					arguments: [
						input.string,
						"--output", output.string,
						"--type", "swift"
					],
					inputFiles: [input],
					outputFiles: [output.appending("\(input.stem).swift")]
				)
			} ?? []
	}
}
