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
				let file = output.appending(input.stem)
				return .buildCommand(
					displayName: "Generate \(input)",
					executable: lexicon.path,
					arguments: [
						input.string,
						"--output", file.string,
						"--type", "swift-standalone"
					],
					inputFiles: [input],
					outputFiles: [file]
				)
			} ?? []
	}
}
