package d1

import "../common"
import "core:fmt"
import "core:math"
import "core:os/os2"
import "core:strconv"
import "core:testing"
import "core:time"

@(optimization_mode = "none")
main :: proc() {
	input_bytes, err := os2.read_entire_file(os2.args[1], context.allocator)
	assert(err == nil)
	defer delete(input_bytes)

	input := string(input_bytes)

	WARMUP_ITERATIONS :: 3
	NUM_ITERATIONS :: 10

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

p1 :: proc(input: string) -> (res: int) {
	input := input
	for range in common.split_iterator_fast(&input, ',') {
		delim := common.find_fast(range, '-')
		start, _ := strconv.parse_int(range[:delim])
		end, _ := strconv.parse_int(range[delim + 1:])

		start_digits := math.count_digits_of_base(start, 10)
		end_digits := math.count_digits_of_base(end, 10)

		for id in start ..= end {
			if math.count_digits_of_base(id, 10) % 2 != 0 do continue

			id_split_start_a := id / common.power(10, start_digits / 2)
			id_split_start_b := id % common.power(10, start_digits / 2)
			if id_split_start_a == id_split_start_b {
				res += id
				continue
			}

			id_split_end_a := id / common.power(10, end_digits / 2)
			id_split_end_b := id % common.power(10, end_digits / 2)
			if id_split_end_a == id_split_end_b do res += id
		}
	}
	return
}

p2 :: proc(input: string) -> (res: int) {
	input := input
	for range in common.split_iterator_fast(&input, ',') {
		delim := common.find_fast(range, '-')
		start, _ := strconv.parse_int(range[:delim])
		end, _ := strconv.parse_int(range[delim + 1:])

		start_digits := math.count_digits_of_base(start, 10)
		end_digits := math.count_digits_of_base(end, 10)

		check_id: for id in start ..= end {
			for n_digits in 1 ..= end_digits / 2 {
				if start_digits % n_digits != 0 && end_digits % n_digits != 0 do continue
				trailing_digits := id % common.power(10, n_digits)
				if math.count_digits_of_base(trailing_digits, 10) != n_digits do continue

				id_tmp := id / common.power(10, n_digits)

				for {
					id_trail := id_tmp % common.power(10, n_digits)
					if id_trail != trailing_digits do break

					id_tmp /= common.power(10, n_digits)
					if id_tmp == 0 {
						res += id
						continue check_id
					}
				}
			}
		}
	}
	return
}

@(test)
p1_test :: proc(t: ^testing.T) {
	input := #load("./sample.txt", string)
	ids := p1(input)
	testing.expectf(t, ids == 1227775554, "got %v", ids)
}

@(test)
p2_test :: proc(t: ^testing.T) {
	input := #load("./sample.txt", string)
	ids := p2(input)
	testing.expectf(t, ids == 4174379265, "got %v", ids)
}
