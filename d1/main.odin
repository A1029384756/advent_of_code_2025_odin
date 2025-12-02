package d1

import "../common"
import "core:testing"

main :: proc() {
	common.advent_of_code(p1, p2, {100, 1000})
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
	testing.expect(t, pw == 6)
}
