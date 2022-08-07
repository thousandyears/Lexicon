import Lexicon
import UniformTypeIdentifiers

public enum Generator: CodeGenerator {
    
    // TODO: prefixes?
    
    public static let utType = UTType(filenameExtension: "cs", conformingTo: .sourceCode)!
    
    public static func generate(_ json: Lexicon.Graph.JSON) throws -> Data {
        return Data(json.cSharp().utf8)
    }
}

private extension Lexicon.Graph.JSON {
    
    func cSharp() -> String {
        return """
global using static \(name.capitalized)Lexicon;

public static class \(name.capitalized)Lexicon
{
    public static I\(name.capitalized) \(name) = new L\(name.capitalized)(nameof(\(name)));
}

public abstract class LexiconType
{
    protected string Identifier { get; }

    public LexiconType(string identifier)
    {
        Identifier = identifier;
    }

    public override string ToString()
    {
        return Identifier;
    }
}

// MARK: generated types

\(classes.flatMap{ $0.cSharp(prefix: ("L", "I")) }.joined(separator: "\n"))

"""
    }
}

private extension Lexicon.Graph.Node.Class.JSON {
    
    // TODO: make this more readable
    
    func cSharp(prefix: (class: String, protocol: String)) -> [String] {
        
        guard mixin == nil else {
            return []
        }
        
        var lines: [String] = []
        let T = id.split(separator: ".").map{$0.capitalized}.joined().idToClassSuffix
        let (L, I) = prefix
        
        let supertype = supertype?
            .split(separator: ".")
            .map({$0.capitalized})
            .joined()
            .replacingOccurrences(of: "_", with: "__")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "__&__", with: ", I")
        
        if let protonym = protonym?.split(separator: ".").map({$0.capitalized}).joined().idToClassSuffix {
            lines += "public sealed class \(L)\(T) : LexiconType, \(I)\(T), \(I)\(protonym)"
            
        } else {
            lines += "public sealed class \(L)\(T) : LexiconType, \(I)\(T)\(supertype.map{ ", \(I)\($0)" } ?? "")"
        }
        
        lines += "{"
        
        for child in children ?? [] {
            let id = "\(T).\(child.capitalized)"
            lines += "\tpublic \(I)\(id.idToClassSuffix) \(child) => new \(L)\(id.idToClassSuffix)($\"{Identifier}.{nameof(\(child))}\");"
        }
        
        // TODO: Generate vars for interface'd properties
        
        for (synonym, protonym) in (synonyms?.sortedByLocalizedStandard(by: \.key) ?? []) {
            let id = "\(T).\(synonym.capitalized)"
            lines += "\tpublic \(I)\(id.idToClassSuffix) \(synonym) => new \(L)\(id.idToClassSuffix)($\"{Identifier}.{nameof(\(protonym))}\");"
        }
        
        lines += "\n\tpublic \(L)\(T)(string identifier) : base(identifier) { }"
        
        lines += "}"
        
        lines += "public interface \(I)\(T)\(supertype.map{ " : \(I)\($0)" } ?? "")"
        
        lines += "{"
        
        for child in children ?? [] {
            let id = "\(T).\(child.capitalized)"
            lines += "\t\(I)\(id.idToClassSuffix) \(child) { get }"
        }
        
        for (synonym, protonym) in (synonyms?.sortedByLocalizedStandard(by: \.key) ?? []) {
            let id = "\(T).\(synonym.capitalized)"
            lines += "\t\(I)\(id.idToClassSuffix) \(synonym) { get }"
        }
        
        lines += "}"
        
        return lines
    }
}

private extension String {
    
    var idToClassSuffix: String {
        replacingOccurrences(of: "_", with: "__")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "_&_", with: "")
    }
}
