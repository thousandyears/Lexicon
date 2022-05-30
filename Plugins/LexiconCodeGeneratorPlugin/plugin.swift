import PackagePlugin
import Foundation

@main
struct LexiconCodeGeneratorPlugin: BuildToolPlugin {

	func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
		print("❌❌❌❌❌❌❌❌❌❌❌❌❌")
		if let enumerator = FileManager.default.enumerator(atPath: target.directory.string) {
			for case let path as String in enumerator where path.hasSuffix(".lexicon") || path.hasSuffix(".taskpaper") {
				return try [
					.prebuildCommand(
						displayName: "Generate Swift Lexicon Identifiers",
						executable: context.tool(named: "lexicon-generate").path,
						arguments: ["--type", "swift", "--quiet"],
						outputFilesDirectory: Path(path).removingLastComponent()
					)
				]
			}
		}
		return []
	}
}
