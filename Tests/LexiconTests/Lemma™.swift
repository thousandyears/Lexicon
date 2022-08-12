//
// github.com/screensailor 2022
//

final class Lemma™: Hopes {
	
	func test_Lemma_isValid_name() {
		
		hope.true(Lemma.isValid(name: "a"))
		hope.true(Lemma.isValid(name: "a_"))
		hope.true(Lemma.isValid(name: "a_t"))
		hope.true(Lemma.isValid(name: "a_2_")) // TODO: consider disallowing this!
		hope.true(Lemma.isValid(name: "a_2_z"))

		hope.false(Lemma.isValid(name: ""))
		hope.false(Lemma.isValid(name: "1"))
		hope.false(Lemma.isValid(name: "_")) // TODO: consider allowing this!
		hope.false(Lemma.isValid(name: "a__"))
	}
	
	func test_Lemma_isValid_character() {
		
		hope.true(Lemma.isValid(character: "_", appendingTo: "yet_another"))
		
		hope.false(Lemma.isValid(character: "_", appendingTo: "not_another_"))
		hope.false(Lemma.isValid(character: "_", appendingTo: "")) // TODO: consider allowing this!
	}

	func test_inherited_node_own_type() async throws {

		let root = try await Lexicon.from(
			TaskPaper(inherited_node_own_type).decode()
		).root

		let userId = try await root["user", "id"].hopefully()
		let collectionId = try await root["db", "collection", "id"].hopefully()

		let isCollectionId = await userId.is(collectionId)

		hope(isCollectionId) == true
	}

	func test_inherited_node_own_type_nested() async throws {

		let root = try await Lexicon.from(
			TaskPaper(inherited_node_own_type).decode()
		).root

		do {
			let a = try await root["user", "b", "c"].hopefully()
			let b = try await root["a", "b", "c"].hopefully()
			let matches = await a.is(b)
			hope(matches) == true
		}

		do {
			let a = try await root["a", "two", "two", "two", "three"].hopefully()
			let b = try await root["one", "two", "three"].hopefully()
			let matches = await a.is(b)
			hope(matches) == true
		}
	}
}

private let inherited_node_own_type = """
root:
	a:
	+ root.one
		b:
		+ root.two
			c:
			+ root.three
	one:
		two:
		+ root.a
			three:
			+ root.b
	db:
		collection:
			id:
	user:
	+ root.db.collection
	+ root.a
"""

