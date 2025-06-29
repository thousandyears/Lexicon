//
// github.com/screensailor 2022
//

import Foundation
// UTType is provided by UniformTypeIdentifiers+Compat.swift

public enum JSONClasses: CodeGenerator {
	
	public static let utType: UTType = .json
	public static let command = "json"

	public static func generate(_ json: Lexicon.Graph.JSON) throws -> Data {
		let encoder = Encoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
		return try encoder.encode(json)
	}
	
	public class Encoder: JSONEncoder, @unchecked Sendable {
		public override init() {
			super.init()
			self.dateEncodingStrategy = .formatted(DateFormatter.shared)
		}
	}
	
	public class Decoder: JSONDecoder, @unchecked Sendable {
		public override init() {
			super.init()
			self.dateDecodingStrategy = .formatted(DateFormatter.shared)
		}
	}
	
	public class DateFormatter: Foundation.DateFormatter, @unchecked Sendable {
		
		public static let shared = DateFormatter()
		
		#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
		// Use ISO8601DateFormatter on Apple platforms
		public private(set) lazy var iso: ISO8601DateFormatter = {
			self.dateStyle = .long
			self.timeStyle = .short
			let o = ISO8601DateFormatter()
			o.formatOptions.insert(.withFractionalSeconds)
			o.timeZone = .none
			return o
		}()
		
		public override func date(from string: String) -> Date? {
			iso.date(from: string)
		}
		
		public override func string(from date: Date) -> String {
			iso.string(from: date)
		}
		#else
		// Use standard DateFormatter on Linux/non-Apple platforms
		public override init() {
			super.init()
			// ISO 8601 format with fractional seconds
			self.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
			self.locale = Locale(identifier: "en_US_POSIX")
			self.timeZone = TimeZone(secondsFromGMT: 0)
		}
		
		required init?(coder: NSCoder) {
			super.init(coder: coder)
		}
		#endif
	}
}
