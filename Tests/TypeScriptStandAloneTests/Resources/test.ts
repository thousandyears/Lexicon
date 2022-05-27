// I
interface I extends TypeLocalized, SourceCodeIdentifiable { }
interface TypeLocalized {
    localized: string
}
interface SourceCodeIdentifiable {
    identifier: string
}
// L
class L implements I {
    localized: string;
    identifier: string;

    constructor(id: string, localized = "") {
        this.localized = localized;
        this.identifier = id;
    }
}
// MARK: generated types
class L_test extends L implements I_test {
  one = new L_test_one(`${this.identifier}.one`);
  two = new L_test_two(`${this.identifier}.two`);
  type = new L_test_type(`${this.identifier}.type`);
}
interface I_test extends I {
  one: L_test_one;
  two: L_test_two;
  type: L_test_type;
}
class L_test_one extends L implements I_test_one {
  good!: L_test_type_odd_good;
  more = new L_test_one_more(`${this.identifier}.more`);
}
interface I_test_one extends I_test_type_odd {
  more: L_test_one_more;
}
class L_test_one_more extends L implements I_test_one_more {
  time = new L_test_one_more_time(`${this.identifier}.time`);
}
interface I_test_one_more extends I {
  time: L_test_one_more_time;
}
class L_test_one_more_time extends L implements I_test_one_more_time {
  one!: L_test_one;
  two!: L_test_two;
  type!: L_test_type;
}
type I_test_one_more_time = I_test;
class L_test_two extends L implements I_test_two {
  no!: L_test_type_even_no;
  bad!: L_test_type_even_bad;
  timing = new L_test_two_timing(`${this.identifier}.timing`);
}
interface I_test_two extends I_test_type_even {
  timing: L_test_two_timing;
}
class L_test_two_timing extends L implements I_test_two_timing {
}
type I_test_two_timing = I;
class L_test_type extends L implements I_test_type {
  even = new L_test_type_even(`${this.identifier}.even`);
  odd = new L_test_type_odd(`${this.identifier}.odd`);
}
interface I_test_type extends I {
  even: L_test_type_even;
  odd: L_test_type_odd;
}
class L_test_type_even extends L implements I_test_type_even {
  no = new L_test_type_even_no(`${this.identifier}.no`);
  bad = this.no.good;
}
interface I_test_type_even extends I {
  no: L_test_type_even_no;
}
type L_test_type_even_bad = L_test_type_even_no_good
class L_test_type_even_no extends L implements I_test_type_even_no {
  good = new L_test_type_even_no_good(`${this.identifier}.good`);
}
interface I_test_type_even_no extends I {
  good: L_test_type_even_no_good;
}
class L_test_type_even_no_good extends L implements I_test_type_even_no_good {
}
type I_test_type_even_no_good = I;
class L_test_type_odd extends L implements I_test_type_odd {
  good = new L_test_type_odd_good(`${this.identifier}.good`);
}
interface I_test_type_odd extends I {
  good: L_test_type_odd_good;
}
class L_test_type_odd_good extends L implements I_test_type_odd_good {
}
type I_test_type_odd_good = I;
const test = new L_test("test");
