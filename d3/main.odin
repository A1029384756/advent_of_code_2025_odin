package d3

import "../common"
import "core:strings"
import "core:testing"

main :: proc() {
	common.advent_of_code(p1, p2, {10, 100})
}

p1 :: proc(input: string) -> (res: int) {
	input := input
	for bank in strings.split_lines_iterator(&input) {
		res += joltage_from_n_batteries(bank, 2)
	}
	return res
}

p2 :: proc(input: string) -> (res: int) {
	input := input
	for bank in strings.split_lines_iterator(&input) {
		res += joltage_from_n_batteries(bank, 12)
	}
	return res
}

joltage_from_n_batteries :: proc(bank: string, $N: int) -> int {
	total_joltage, pos := 0, 0
	for joltage_idx in 0 ..< N {
		max_joltage, max_pos := 0, 0
		for battery, battery_idx in bank[pos:len(bank) - (N - 1 - joltage_idx)] {
			joltage := int(battery) - '0'
			if joltage > max_joltage {
				max_joltage = joltage
				max_pos = battery_idx
			}
		}
		pos += max_pos + 1
		total_joltage = total_joltage * 10 + max_joltage
	}
	return total_joltage
}

@(test)
p1_test :: proc(t: ^testing.T) {
	input := #load("./sample.txt", string)
	res := p1(input)
	testing.expectf(t, res == 357, "got %v", res)
}

@(test)
p2_test :: proc(t: ^testing.T) {
	input := #load("./sample.txt", string)
	res := p2(input)
	testing.expectf(t, res == 3121910778619, "got %v", res)
}
