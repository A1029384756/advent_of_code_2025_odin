package d7

import "../common"
import "core:testing"

main :: proc() {
	common.advent_of_code(p1, p2, {100, 1000})
}

p1 :: proc(input: string) -> (res: int) {
	size := common.grid_size(input)
	beams := make([]bool, size.x)
	defer delete(beams)
	for x in 0 ..< size.x {
		if input[x] == 'S' {
			beams[x] = true
			break
		}
	}

	for y := 2; y < size.y; y += 2 {
		for beam, x in beams {
			if !beam do continue

			if input[common.coord_to_idx({x, y}, size)] == '^' {
				beams[x - 1], beams[x + 1] = true, true
				beams[x] = false
				res += 1
			}
		}
	}
	return
}

p2 :: proc(input: string) -> (res: int) {
	size := common.grid_size(input)
	beams := make([]int, size.x)
	defer delete(beams)
	for x in 0 ..< size.x {
		if input[x] == 'S' {
			beams[x] = 1
			break
		}
	}

	for y := 2; y < size.y; y += 2 {
		for beam, x in beams {
			if beam == 0 do continue

			if input[common.coord_to_idx({x, y}, size)] == '^' {
				beams[x - 1] += beams[x]
				beams[x + 1] += beams[x]
				beams[x] = 0
			}
		}
	}

	for beam in beams {
		res += beam
	}
	return
}

@(test)
p1_test :: proc(t: ^testing.T) {
	input := #load("./sample.txt", string)
	res := p1(input)
	testing.expectf(t, res == 21, "got %v", res)
}

@(test)
p2_test :: proc(t: ^testing.T) {
	input := #load("./sample.txt", string)
	res := p2(input)
	testing.expectf(t, res == 40, "got %v", res)
}
