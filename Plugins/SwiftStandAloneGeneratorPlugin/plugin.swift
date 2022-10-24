import PackagePlugin
import Foundation

@main
struct SwiftStandAloneGeneratorPlugin: BuildToolPlugin {

	func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
		let lexicon = try context.tool(named: "lexicon-generate")
		let output = context.pluginWorkDirectory.appending("GeneratedSources")
		return FileManager.default.enumerator(atPath: target.directory.string)?
			.compactMap { value in (value as? String).map(target.directory.appending) }
			.filter { path in (path.extension ?? "").hasSuffix("lexicon") }
			.map { input in
				return .buildCommand(
					displayName: "Generate \(input)",
					executable: lexicon.path,
					arguments: [
						input.string,
						"--output", output.appending(input.stem).string,
						"--type", "swift-standalone"
					],
					inputFiles: [input],
					outputFiles: [output.appending(input.stem + ".swift")]
				)
			} ?? []
	}
}
