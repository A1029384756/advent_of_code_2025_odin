package d3

import "../common"
import "core:slice"
import "core:strconv"
import "core:testing"

main :: proc() {
	common.advent_of_code(p1, p2, {100, 1000})
}

Range :: struct {
	hi, lo: int,
}

p1 :: proc(input: string) -> (res: int) {
	input := input

	ranges: [dynamic]Range
	defer delete(ranges)
	for line in common.split_iterator_fast(&input, '\n') {
		if len(line) == 0 do break
		delim := common.find_fast(line, '-')
		lo_str := line[:delim]
		hi_str := line[delim + 1:]

		lo, _ := strconv.parse_int(lo_str)
		hi, _ := strconv.parse_int(hi_str)
		append(&ranges, Range{hi, lo})
	}

	for line in common.split_iterator_fast(&input, '\n') {
		id, _ := strconv.parse_int(line)
		found := false
		for range in ranges {
			if id >= range.lo && id <= range.hi {
				res += 1
				break
			}
		}
	}

	return
}

p2 :: proc(input: string) -> (res: int) {
	input := input

	ranges: [dynamic]Range
	defer delete(ranges)
	for line in common.split_iterator_fast(&input, '\n') {
		if len(line) == 0 do break
		delim := common.find_fast(line, '-')
		lo_str := line[:delim]
		hi_str := line[delim + 1:]

		lo, _ := strconv.parse_int(lo_str)
		hi, _ := strconv.parse_int(hi_str)
		append(&ranges, Range{hi, lo})
	}
	slice.sort_by(ranges[:], proc(a, b: Range) -> bool {return a.lo < b.lo})

	merged_ranges: [dynamic]Range
	defer delete(merged_ranges)
	range := ranges[0]
	for range_cmp in ranges[1:] {
		if range.hi >= range_cmp.lo {
			range.hi = max(range_cmp.hi, range.hi)
		} else {
			append(&merged_ranges, range)
			range = range_cmp
		}
	}
	append(&merged_ranges, range)

	for range in merged_ranges {
		res += range.hi - range.lo + 1
	}
	return
}

@(test)
p1_test :: proc(t: ^testing.T) {
	input := #load("./sample.txt", string)
	res := p1(input)
	testing.expectf(t, res == 3, "got %v", res)
}

@(test)
p2_test :: proc(t: ^testing.T) {
	input := #load("./sample.txt", string)
	res := p2(input)
	testing.expectf(t, res == 14, "got %v", res)
}
