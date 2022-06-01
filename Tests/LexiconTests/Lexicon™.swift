//
// github.com/screensailor 2021
//

@_exported import Hope
@_exported import Lexicon

final class Lexicon™: Hopes {
	
	func test() async throws {
		
		let lexicon = try await Lexicon.from(TaskPaper(taskpaper).decode())
		let root = await lexicon.root
		var cli = await CLI(root)
		
		hope(cli.suggestions.map(\.name)) == ["idea", "purpose", "type", "ui", "ux"]
		
		await cli.replace(input: "idea")
		await cli.enter()
		
		hope(cli.suggestions.map(\.name)) == ["knowledge"]
		
		let mindMap = try await lexicon["root.idea.knowledge.mind_map"].hopefully()
		let tree = try await lexicon["root.idea.knowledge.tree"].hopefully()
		
		await hope(that: mindMap.source) == tree
		await hope(that: mindMap.source === tree) == true
		
		// TODO: ...
	}

	func test_example() async throws {

		let root = try await Lexicon.from(
			TaskPaper(example).decode()
		).root

		let userId = try await root["user", "id"].hopefully()
		let collectionId = try await root["db", "collection", "id"].hopefully()

		let isCollectionId = await userId.is(collectionId)

		hope(isCollectionId) == true
	}
}

private let taskpaper = """
root:
	idea:
		knowledge:
			directory:
			= tree
			mind_map:
			= tree
			outline:
			= tree
			tree:
				branch:
				+ root.idea.knowledge.tree
				leaf:
	purpose:
		lexicon:
			lemma:
		vocabulary:
		= lexicon
	type:
		ux:
			journey:
				entry:
				+ root.ui.view.control
	ui:
		placeable:
			placed:
				above:
				+ root.ux
				below:
				+ root.ux
		view:
			control:
				button:
				+ root.ui.placeable
			label:
			+ root.ui.placeable
	ux:
		menu:
			File:
				New:
				+ root.type.ux.journey
				Open:
				+ root.type.ux.journey
					json:
					taskpaper:
"""

private let example = """
root:
	db:
		collection:
			id:
	user:
	+ root.db.collection
"""
