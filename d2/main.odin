package d2

import "../common"
import "core:math"
import "core:strconv"
import "core:testing"

main :: proc() {
	common.advent_of_code(p1, p2, {10, 100})
}

p1 :: proc(input: string) -> (res: int) {
	input := input
	for range in common.split_iterator_fast(&input, ',') {
		delim := common.find_fast(range, '-')
		start, _ := strconv.parse_int(range[:delim])
		end, _ := strconv.parse_int(range[delim + 1:])

		start_digits := math.count_digits_of_base(start, 10)
		end_digits := math.count_digits_of_base(end, 10)

		start_divisor := common.power(10, start_digits / 2)
		end_divisor := common.power(10, end_digits / 2)

		for id in start ..= end {
			id_digits := math.count_digits_of_base(id, 10)
			if id_digits % 2 != 0 do continue

			if id_digits == start_digits {
				first_half := id / start_divisor
				second_half := id % start_divisor
				if first_half == second_half do res += id
			} else {
				first_half := id / end_divisor
				second_half := id % end_divisor
				if first_half == second_half do res += id
			}
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
				n_divisor := common.power(10, n_digits)
				trailing_digits := id % n_divisor
				if math.count_digits_of_base(trailing_digits, 10) != n_digits do continue

				id_tmp := id / n_divisor
				for {
					id_trail := id_tmp % n_divisor
					if id_trail != trailing_digits do break

					id_tmp /= n_divisor
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
