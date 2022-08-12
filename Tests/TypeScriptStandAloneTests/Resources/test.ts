interface I { }

// L
class L implements I {
	protected id: string;
	constructor(id: string) {
		this.id = id;
	}
	get ['__']() {
		return this.id;
	}
}

// MARK: generated types
class L_test extends L implements I_test {
  one = new L_test_one(`${this.__}.one`);
  two = new L_test_two(`${this.__}.two`);
  type = new L_test_type(`${this.__}.type`);
}
interface I_test extends I {
  one: I_test_one;
  two: I_test_two;
  type: I_test_type;
}
class L_test_one extends L implements I_test_one {
  good!: L_test_type_odd_good;
  more = new L_test_one_more(`${this.__}.more`);
}
interface I_test_one extends I_test_type_odd {
  more: I_test_one_more;
}
class L_test_one_more extends L implements I_test_one_more {
  time = new L_test_one_more_time(`${this.__}.time`);
}
interface I_test_one_more extends I {
  time: I_test_one_more_time;
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
  timing = new L_test_two_timing(`${this.__}.timing`);
}
interface I_test_two extends I_test_type_even {
  timing: I_test_two_timing;
}
class L_test_two_timing extends L implements I_test_two_timing {
}
type I_test_two_timing = I;
class L_test_type extends L implements I_test_type {
  even = new L_test_type_even(`${this.__}.even`);
  odd = new L_test_type_odd(`${this.__}.odd`);
}
interface I_test_type extends I {
  even: I_test_type_even;
  odd: I_test_type_odd;
}
class L_test_type_even extends L implements I_test_type_even {
  no = new L_test_type_even_no(`${this.__}.no`);
  bad = this.no.good;
}
interface I_test_type_even extends I {
  no: I_test_type_even_no;
}
type L_test_type_even_bad = L_test_type_even_no_good
class L_test_type_even_no extends L implements I_test_type_even_no {
  good = new L_test_type_even_no_good(`${this.__}.good`);
}
interface I_test_type_even_no extends I {
  good: I_test_type_even_no_good;
}
class L_test_type_even_no_good extends L implements I_test_type_even_no_good {
}
type I_test_type_even_no_good = I;
class L_test_type_odd extends L implements I_test_type_odd {
  good = new L_test_type_odd_good(`${this.__}.good`);
}
interface I_test_type_odd extends I {
  good: I_test_type_odd_good;
}
class L_test_type_odd_good extends L implements I_test_type_odd_good {
}
type I_test_type_odd_good = I;
const test = new L_test("test");
