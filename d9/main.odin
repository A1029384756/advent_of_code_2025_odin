package d9

import "../common"
import "core:strconv"
import "core:testing"

main :: proc() {
	common.advent_of_code(p1, p2, {2, 5})
}

parse_tiles :: proc(input: string, tiles: ^[dynamic][2]int) {
	input := input
	for line in common.split_iterator_fast(&input, '\n') {
		line := line
		x_str, _ := common.split_iterator_fast(&line, ',')
		y_str, _ := common.split_iterator_fast(&line, ',')

		x, _ := strconv.parse_int(x_str)
		y, _ := strconv.parse_int(y_str)
		append(tiles, [2]int{x, y})
	}
}

p1 :: proc(input: string) -> (res: int) {
	tiles: [dynamic][2]int
	defer delete(tiles)
	parse_tiles(input, &tiles)

	for a, a_idx in tiles[:len(tiles) - 1] {
		for b in tiles[a_idx + 1:] {
			delta := a - b
			res = max(res, (abs(b.y - a.y) + 1) * (abs(b.x - a.x) + 1))
		}
	}

	return
}

Range :: struct {
	a, b: int,
	mode: enum {
		Inc,
		Exc,
	},
}
in_range :: proc(val: int, range: Range) -> bool {
	if range.mode == .Inc {
		return val >= range.a && val <= range.b
	} else {
		return val >= range.a && val < range.b
	}
}

Rect :: struct {
	p1, p2: [2]int,
	area:   int,
}

p2 :: proc(input: string) -> (res: int) {
	tiles: [dynamic][2]int
	defer delete(tiles)
	parse_tiles(input, &tiles)

	for a, a_idx in tiles[:len(tiles) - 1] {
		for b in tiles[a_idx + 1:] {
			valid := true
			x1 := min(a.x, b.x)
			y1 := min(a.y, b.y)
			x2 := max(a.x, b.x)
			y2 := max(a.y, b.y)
			for tile, tile_idx in tiles {
				x_contains := in_range(tile.x, {x1 + 1, x2, .Exc})
				y_contains := in_range(tile.y, {y1 + 1, y2, .Exc})

				if x_contains && y_contains {
					valid = false
					break
				} else if x_contains {
					next := tiles[(tile_idx + 1) % len(tiles)]
					if tile.x == next.x {
						range := Range{min(tile.y, next.y), max(tile.y, next.y), .Inc}
						horz_crossed := (y1 != y2 && in_range(y1, range) && in_range(y2, range))
						if horz_crossed {
							valid = false
							break
						}
					}
				} else if y_contains {
					next := tiles[(tile_idx + 1) % len(tiles)]
					if tile.y == next.y {
						range := Range{min(tile.x, next.x), max(tile.x, next.x), .Inc}
						vert_crossed := (x1 != x2 && in_range(x1, range) && in_range(x2, range))
						if vert_crossed {
							valid = false
							break
						}
					}
				}
			}

			if valid {
				res = max(res, (y2 - y1 + 1) * (x2 - x1 + 1))
			}
		}
	}

	return
}

@(test)
p1_test :: proc(t: ^testing.T) {
	input := #load("./sample.txt", string)
	res := p1(input)
	testing.expectf(t, res == 50, "got %v", res)
}

@(test)
p2_test :: proc(t: ^testing.T) {
	input := #load("./sample.txt", string)
	res := p2(input)
	testing.expectf(t, res == 24, "got %v", res)
}
