package ;

import haxe.unit.*;
import haxe.Int64;
import deepequal.DeepEqual.*;
using tink.CoreApi;

class RunTests extends TestCase {

	static function main() {
		var runner = new TestRunner();
		runner.add(new RunTests());
		
		travix.Logger.exit(runner.run() ? 0 : 500);
	}
	
	function testObject() {
		var a = {a:1, b:2};
		var e = {a:1, b:2};
		assertSuccess(compare(e, a));
		
		var a = {a:1, b:[2]};
		var e = {a:1, b:[2]};
		assertSuccess(compare(e, a));
		
		var a = {a:1, b:2};
		var e = {a:1, c:2};
		assertFailure(compare(e, a));
		
		var a = {a:1, b:2};
		var e = {a:1, b:3};
		assertFailure(compare(e, a));
		
		var a = {a:1, b:2};
		var e = {a:1, b:'2'};
		assertFailure(compare(e, a));
	}
	
	function testArrayOfObjects() {
		var a = [{a:1, b:2}];
		var e = [{a:1, b:2}];
		assertSuccess(compare(e, a));
		
		var a = [{a:1, b:2}];
		var e = [{a:1, c:2}];
		assertFailure(compare(e, a));
		
		var a = [{a:1, b:2}];
		var e = [{a:1, b:3}];
		assertFailure(compare(e, a));
	}
	
	function testArray() {
		var a = [0.1];
		var e = [0.1];
		assertSuccess(compare(e, a));
		
		var a = [0.1];
		var e = [1.1];
		assertFailure(compare(e, a));
		
		var a = [0.1, 0.2];
		var e = [0.1, 0.2, 0.3];
		assertFailure(compare(e, a));
	}
	
	function testFloat() {
		var a = 0.1;
		var e = 0.1;
		assertSuccess(compare(e, a));
		
		var a = 0.1;
		var e = 1.1;
		assertFailure(compare(e, a));
	}
	
	function testInt() {
		var a = 0;
		var e = 0;
		assertSuccess(compare(e, a));
		
		var a = 0;
		var e = 1;
		assertFailure(compare(e, a));
	}
	
	function testString() {
		var a = 'actual';
		var e = 'actual';
		assertSuccess(compare(e, a));
		
		var a = 'actual';
		var e = 'expected';
		assertFailure(compare(e, a));
	}
	
	function testDate() {
		var a = new Date(2016, 1, 1, 1, 1, 1);
		var e = new Date(2016, 1, 1, 1, 1, 1);
		assertSuccess(compare(e, a));
		
		var a = new Date(2016, 1, 1, 1, 1, 2);
		var e = new Date(2016, 1, 1, 1, 1, 1);
		assertFailure(compare(e, a));
	}
	
	function testInt64() {
		var a = Int64.make(1, 2);
		var e = Int64.make(1, 2);
		assertSuccess(compare(e, a));
		
		var a = Int64.make(1, 2);
		var e = Int64.make(1, 3);
		assertFailure(compare(e, a));
	}
	
	function testEnum() {
		var a:Outcome<String, String> = Success('foo');
		var e:Outcome<String, String> = Success('foo');
		assertSuccess(compare(e, a));
		
		var a:Outcome<String, String> = Success('foo');
		var e:Outcome<String, String> = Success('f');
		assertFailure(compare(e, a));
		
		var a:Outcome<String, String> = Success('foo');
		var e:Outcome<String, String> = Failure('foo');
		assertFailure(compare(e, a));
	}
	
	function testCustom() {
		var a = [1,2,3,4];
		var e = new ArrayContains([1,2,3]);
		assertSuccess(compare(e, a));
		
		var a = [1,2,3,4];
		var e = new ArrayContains([3,5]);
		assertFailure(compare(e, a));
	}
	
	function assertSuccess(outcome:Outcome<Noise, Error>, ?pos:haxe.PosInfos) {
		switch outcome {
			case Success(_): assertTrue(true, pos);
			case Failure(e): trace(e.message, e.data); assertTrue(false, pos);
		}
	}
	
	function assertFailure(outcome:Outcome<Noise, Error>, ?message:String, ?pos:haxe.PosInfos) {
		switch outcome {
			case Failure(f) if(message == null): assertTrue(true, pos);
			case Failure(f): assertEquals(message, f.message, pos);
			case Success(e): assertTrue(true, pos);
		}
	}
}

class ArrayContains implements deepequal.CustomCompare {
	var items:Array<Dynamic>;
	public function new(items) {
		this.items = items;
	}
	public function check(other:Dynamic, compare:Dynamic->Dynamic->Outcome<Noise, Error>) {
		if(!Std.is(other, Array)) return Failure(new Error('Expected array but got $other'));
		for(i in items) {
			var matched = false;
			for(o in (other:Array<Dynamic>)) switch compare(i, o) {
				case Success(_): matched = true; break;
				case Failure(_):
			}
			if(!matched) return Failure(new Error('Cannot find $i in $other'));
		}
		return Success(Noise);
	}
}