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

I_test test = new L_test(nameof(test));

public sealed class L_test : L_LexiconType, I_test
{
    public L_test(string identifer, string localised = "") : base(identifer, localised) { }
}
public interface I_test : I_LexiconType {
	I_test_one one => new L_test_one($"{Identifier}.{nameof(one)}");
	I_test_two two => new L_test_two($"{Identifier}.{nameof(two)}");
	I_test_type type => new L_test_type($"{Identifier}.{nameof(type)}");
}
public sealed class L_test_one : L_LexiconType, I_test_one, I_test_type_odd
{
    public L_test_one(string identifer, string localised = "") : base(identifer, localised) { }
}
public interface I_test_one : I_test_type_odd {
	I_test_one_more more => new L_test_one_more($"{Identifier}.{nameof(more)}");
}
public sealed class L_test_one_more : L_LexiconType, I_test_one_more
{
    public L_test_one_more(string identifer, string localised = "") : base(identifer, localised) { }
}
public interface I_test_one_more : I_LexiconType {
	I_test_one_more_time time => new L_test_one_more_time($"{Identifier}.{nameof(time)}");
}
public sealed class L_test_one_more_time : L_LexiconType, I_test_one_more_time, I_test
{
    public L_test_one_more_time(string identifer, string localised = "") : base(identifer, localised) { }
}
public interface I_test_one_more_time : I_test {
}
public sealed class L_test_two : L_LexiconType, I_test_two, I_test_type_even
{
    public L_test_two(string identifer, string localised = "") : base(identifer, localised) { }
}
public interface I_test_two : I_test_type_even {
	I_test_two_timing timing => new L_test_two_timing($"{Identifier}.{nameof(timing)}");
}
public sealed class L_test_two_timing : L_LexiconType, I_test_two_timing
{
    public L_test_two_timing(string identifer, string localised = "") : base(identifer, localised) { }
}
public interface I_test_two_timing : I_LexiconType {
}
public sealed class L_test_type : L_LexiconType, I_test_type
{
    public L_test_type(string identifer, string localised = "") : base(identifer, localised) { }
}
public interface I_test_type : I_LexiconType {
	I_test_type_even even => new L_test_type_even($"{Identifier}.{nameof(even)}");
	I_test_type_odd odd => new L_test_type_odd($"{Identifier}.{nameof(odd)}");
}
public sealed class L_test_type_even : L_LexiconType, I_test_type_even
{
    public L_test_type_even(string identifer, string localised = "") : base(identifer, localised) { }
}
public interface I_test_type_even : I_LexiconType {
	I_test_type_even_no no => new L_test_type_even_no($"{Identifier}.{nameof(no)}");
	I_test_type_even_bad bad => new L_test_type_even_bad($"{Identifier}.{nameof(no.good)}");
}
public sealed class L_test_type_even_bad : L_LexiconType, I_test_type_even_bad, I_test_type_even_no_good
{
    public L_test_type_even_bad(string identifer, string localised = "") : base(identifer, localised) { }
}
public interface I_test_type_even_bad : I_LexiconType {
}
public sealed class L_test_type_even_no : L_LexiconType, I_test_type_even_no
{
    public L_test_type_even_no(string identifer, string localised = "") : base(identifer, localised) { }
}
public interface I_test_type_even_no : I_LexiconType {
	I_test_type_even_no_good good => new L_test_type_even_no_good($"{Identifier}.{nameof(good)}");
}
public sealed class L_test_type_even_no_good : L_LexiconType, I_test_type_even_no_good
{
    public L_test_type_even_no_good(string identifer, string localised = "") : base(identifer, localised) { }
}
public interface I_test_type_even_no_good : I_LexiconType {
}
public sealed class L_test_type_odd : L_LexiconType, I_test_type_odd
{
    public L_test_type_odd(string identifer, string localised = "") : base(identifer, localised) { }
}
public interface I_test_type_odd : I_LexiconType {
	I_test_type_odd_good good => new L_test_type_odd_good($"{Identifier}.{nameof(good)}");
}
public sealed class L_test_type_odd_good : L_LexiconType, I_test_type_odd_good
{
    public L_test_type_odd_good(string identifer, string localised = "") : base(identifer, localised) { }
}
public interface I_test_type_odd_good : I_LexiconType {
}
