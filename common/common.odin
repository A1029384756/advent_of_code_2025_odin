package common

import "core:fmt"
import "core:os/os2"
import "core:time"


BenchmarkConfig :: struct {
	warmup:     int,
	iterations: int,
}

@(optimization_mode = "none")
advent_of_code :: proc(p1, p2: proc(input: string) -> int, bench: BenchmarkConfig) {
	input_bytes, err := os2.read_entire_file(os2.args[1], context.allocator)
	assert(err == nil)
	defer delete(input_bytes)

	input := string(input_bytes)

	{
		max_t, total_t: time.Duration
		min_t := max(time.Duration)
		res: int

		for _ in 0 ..< bench.warmup {
			res = p1(input)
		}

		for _ in 0 ..< bench.iterations {
			start := time.now()
			res = p1(input)
			time := time.since(start)
			min_t = min(time, min_t)
			max_t = max(time, max_t)
			total_t += time
		}

		fmt.println(res, min_t, max_t, total_t / time.Duration(bench.iterations))
	}

	{
		max_t, total_t: time.Duration
		min_t := max(time.Duration)
		res: int

		for _ in 0 ..< bench.warmup {
			res = p2(input)
		}

		for _ in 0 ..< bench.iterations {
			start := time.now()
			res = p2(input)
			time := time.since(start)
			min_t = min(time, min_t)
			max_t = max(time, max_t)
			total_t += time
		}

		fmt.println(res, min_t, max_t, total_t / time.Duration(bench.iterations))
	}
}

parse_int_fast :: proc(input: string) -> (res: int) {
	for i in 0 ..< len(input) {
		res = res * 10 + (int(input[i]) - '0')
	}
	return
}

split_iterator_fast :: proc(input: ^string, sep: u8) -> (res: string, ok: bool) {
	i: int
	for i = 0; i < len(input); i += 1 {
		if input[i] == sep {
			ok = true
			break
		}
	}

	if ok {
		res = input[:i]
		input^ = input[i + 1:]
	} else {
		res = input[:]
		ok = res != ""
		input^ = input[len(input):]
	}

	return
}

find_fast :: proc(input: string, char: u8) -> int {
	for i in 0 ..< len(input) {
		if input[i] == char do return i
	}
	return -1
}

coord_to_idx :: #force_inline proc(pos, grid_size: [2]int) -> int {
	return grid_size.x * pos.y + pos.x + pos.y
}

coord_valid :: #force_inline proc(pos, size: [2]int) -> bool {
	return pos.x >= 0 && pos.y >= 0 && pos.x < size.x && pos.y < size.y
}

grid_size :: proc(input: string) -> (size: [2]int) {
	for i in 0 ..< len(input) {
		if input[i] == '\n' do break
		size.x += 1
	}
	tmp := len(input) / size.x
	size.y = tmp - (tmp % size.x)
	return
}

scry :: proc(input: string, cmp: string) -> bool {
	assert(len(cmp) <= size_of(uint))
	SWAR :: #config(SWAR, true)
	when SWAR {
		shamt := 8 * uint(size_of(uint) - len(cmp))
		cmp := (transmute(^uint)raw_data(cmp))^
		cmp = (cmp << shamt) >> shamt
		input := (transmute(^uint)raw_data(input))^
		input = (input << shamt) >> shamt

		return cmp == input
	} else {
		return len(input) >= len(cmp) && input[:len(cmp)] == cmp
	}
}

power :: proc "contextless" (val, exp: int) -> int {
	res := 1
	for _ in 0 ..< exp {
		res = res * val
	}
	return res
}
