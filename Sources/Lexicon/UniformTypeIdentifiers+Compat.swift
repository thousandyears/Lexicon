//
// UniformTypeIdentifiers Compatibility Layer
// Provides UTType support on both Apple platforms and Linux
//

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers

// On Apple platforms, we can use the real UniformTypeIdentifiers
// Re-export what we need
public typealias UTType = UniformTypeIdentifiers.UTType

#else
// Linux fallback implementation
import Foundation

public struct UTType: Hashable, Sendable {
    public let identifier: String
    private let _preferredFilenameExtension: String?
    private let _conformsTo: [UTType]
    
    private init(identifier: String, preferredFilenameExtension: String? = nil, conformsTo: [UTType] = []) {
        self.identifier = identifier
        self._preferredFilenameExtension = preferredFilenameExtension
        self._conformsTo = conformsTo
    }
    
    public var preferredFilenameExtension: String? {
        return _preferredFilenameExtension
    }
    
    public func conforms(to type: UTType) -> Bool {
        return _conformsTo.contains(type) || _conformsTo.contains { $0.conforms(to: type) }
    }
    
    // Factory methods
    public init?(filenameExtension: String, conformingTo supertype: UTType? = nil) {
        let conformsTo = supertype.map { [$0] } ?? []
        self.init(identifier: "dyn.\(filenameExtension)", preferredFilenameExtension: filenameExtension, conformsTo: conformsTo)
    }
    
    public init(importedAs identifier: String) {
        self.init(identifier: identifier)
    }
    
    // Predefined types
    public static let sourceCode = UTType(identifier: "public.source-code", preferredFilenameExtension: "txt")
    public static let swiftSource = UTType(identifier: "public.swift-source", preferredFilenameExtension: "swift", conformsTo: [.sourceCode])
    public static let json = UTType(identifier: "public.json", preferredFilenameExtension: "json")
    public static let plainText = UTType(identifier: "public.plain-text", preferredFilenameExtension: "txt")
    public static let typescript = UTType(identifier: "public.typescript", preferredFilenameExtension: "ts", conformsTo: [.sourceCode])
}

#endif

// Extensions for custom UTTypes (available on all platforms)
public extension UTType {
    static var lexicon: UTType {
        UTType(importedAs: "com.github.screensailor.lexicon")
    }
    
    static var taskpaper: UTType {
        UTType(importedAs: "com.taskpaper.text")
    }
} 