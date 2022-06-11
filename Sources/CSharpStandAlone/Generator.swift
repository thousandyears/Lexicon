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
public interface I_TypeLocalised
{
    string Localised { get; set; }
}

public interface I_SourceCodeIdentifiable
{
    string Identifier { get; }
}

public interface I_LexiconType : I_TypeLocalised, I_SourceCodeIdentifiable { }

public class L_LexiconType : I_LexiconType
{
    public string Identifier { get; private set; }

    public string Localised { get; set; }

    public L_LexiconType(string identifer, string localised = "")
    {
        Identifier = identifer;
        Localised = localised;
    }

    public override string ToString()
    {
        return Identifier;
    }
}

// MARK: generated types

I_\(name) \(name) = new L_\(name)(nameof(\(name)));

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
        let T = id.idToClassSuffix
        let (L, I) = prefix
        
        let supertype = supertype?
            .replacingOccurrences(of: "_", with: "__")
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "__&__", with: ", I_")
        
        if let protonym = protonym {
            lines += """
public sealed class \(L)_\(T) : \(L)_LexiconType, \(I)_\(T), \(I)_\(protonym.idToClassSuffix)
{
    public \(L)_\(T)(string identifer, string localised = "") : base(identifer, localised) { }
}
"""
        } else {
            lines += """
public sealed class \(L)_\(T) : \(L)_LexiconType, \(I)_\(T)\(supertype.map{ ", \(I)_\($0)" } ?? "")
{
    public \(L)_\(T)(string identifer, string localised = "") : base(identifer, localised) { }
}
"""
        }
        
        let line = "public interface \(I)_\(T) : \(I)\(supertype.map{ "_\($0)" } ?? "_LexiconType")"
        
        lines += line + " {"
        
        for child in children ?? [] {
            let id = "\(id).\(child)"
            lines += "\t\(I)_\(id.idToClassSuffix) \(child) => new \(L)_\(id.idToClassSuffix)($\"{Identifier}.{nameof(\(child))}\");"
        }
        
        for (synonym, protonym) in (synonyms?.sortedByLocalizedStandard(by: \.key) ?? []) {
            let id = "\(id).\(synonym)"
            lines += "\t\(I)_\(id.idToClassSuffix) \(synonym) => new \(L)_\(id.idToClassSuffix)($\"{Identifier}.{nameof(\(protonym))}\");"
        }
        
        lines += "}"
        
        return lines
    }
}

private extension String {
    
    var idToClassSuffix: String {
        replacingOccurrences(of: "_", with: "__")
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "_&_", with: "_")
    }
}
