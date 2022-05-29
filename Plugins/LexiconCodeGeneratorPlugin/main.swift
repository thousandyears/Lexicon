import PackagePlugin
import Foundation

@main
struct LexiconCodeGeneratorPlugin: CommandPlugin {

	func performCommand(context: PluginContext, arguments: [String]) throws {
		let tool = try context.tool(named: "lexicon-generate")
		if let enumerator = FileManager.default.enumerator(atPath: context.package.directory.string) {
			for case let path as String in enumerator where path.hasSuffix(".lexicon") || path.hasSuffix(".taskpaper") {
				let name = path.replacingOccurrences(of: context.package.directory.string, with: "")
				print("\(name)", terminator: " ... ")
				let process = Process()
				process.executableURL = URL(fileURLWithPath: tool.path.string)
				process.arguments = [path, "--type", "swift", "--quiet"]
				try process.run()
				process.waitUntilExit()
				print("✅")
			}
		}
	}
}
