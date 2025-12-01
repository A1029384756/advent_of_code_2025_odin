package d1

import "../common"
import "core:fmt"
import "core:os/os2"
import "core:testing"
import "core:time"

@(optimization_mode = "none")
main :: proc() {
	input_bytes, err := os2.read_entire_file(os2.args[1], context.allocator)
	assert(err == nil)
	defer delete(input_bytes)

	input := string(input_bytes)

	WARMUP_ITERATIONS :: 10
	NUM_ITERATIONS :: 100

	{
		max_t, total_t: time.Duration
		min_t := max(time.Duration)
		res: int

		for _ in 0 ..< WARMUP_ITERATIONS {
			res = p1(input)
		}

		for _ in 0 ..< NUM_ITERATIONS {
			start := time.now()
			res = p1(input)
			time := time.since(start)
			min_t = min(time, min_t)
			max_t = max(time, max_t)
			total_t += time
		}

		fmt.println(res, min_t, max_t, total_t / NUM_ITERATIONS)
	}

	{
		max_t, total_t: time.Duration
		min_t := max(time.Duration)
		res: int

		for _ in 0 ..< WARMUP_ITERATIONS {
			res = p2(input)
		}

		for _ in 0 ..< NUM_ITERATIONS {
			start := time.now()
			res = p2(input)
			time := time.since(start)
			min_t = min(time, min_t)
			max_t = max(time, max_t)
			total_t += time
		}

		fmt.println(res, min_t, max_t, total_t / NUM_ITERATIONS)
	}
}

p1 :: proc(input: string) -> int {
	password := 0
	dial := 50

	input := input
	for line in common.split_iterator_fast(&input, '\n') {
		val := common.parse_int_fast(line[1:])
		dial += line[0] == 'L' ? -val : val
		if dial %% 100 == 0 do password += 1
	}

	return password
}

p2 :: proc(input: string) -> int {
	password := 0
	dial := 50

	input := input
	for line in common.split_iterator_fast(&input, '\n') {
		val := common.parse_int_fast(line[1:])
		password += val / 100
		val %%= 100

		prev := dial
		dial += line[0] == 'L' ? -val : val

		if prev != 0 && (dial > 99 || dial < 1) {
			password += 1
		}

		if dial < 0 do dial += 100
		dial %%= 100
	}

	return password
}

@(test)
p1_test :: proc(t: ^testing.T) {
	input := #load("./sample.txt", string)
	pw := p1(input)
	testing.expect(t, pw == 3)
}

@(test)
p2_test :: proc(t: ^testing.T) {
	input := #load("./sample.txt", string)
	pw := p2(input)
	testing.expectf(t, pw == 6, "got %v", pw)
}
