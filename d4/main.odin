package d3

import "../common"
import "core:testing"

main :: proc() {
	common.advent_of_code(p1, p2, {10, 100})
}

DirVecs :: [?][2]int{{0, -1}, {0, 1}, {1, 0}, {-1, 0}, {-1, -1}, {-1, 1}, {1, -1}, {1, 1}}

p1 :: proc(input: string) -> (res: int) {
	size := common.grid_size(input)
	for x in 0 ..< size.x {
		for y in 0 ..< size.y {
			coord := [2]int{x, y}
			idx := common.coord_to_idx(coord, size)
			if input[idx] != '@' do continue

			n_adjacent := 0
			for dir in DirVecs {
				target := coord + dir
				if !common.coord_valid(target, size) do continue
				idx := common.coord_to_idx(target, size)
				if input[idx] == '@' do n_adjacent += 1
			}
			if n_adjacent < 4 do res += 1
		}
	}
	return
}

p2 :: proc(input: string) -> (res: int) {
	size := common.grid_size(input)
	Cell :: bit_field u8 {
		occupied:  bool | 1,
		neighbors: i8   | 7,
	}
	cells := make([]Cell, size.x * size.y)
	defer delete(cells)

	for x in 0 ..< size.x {
		for y in 0 ..< size.y {
			coord := [2]int{x, y}
			idx := common.coord_to_idx(coord, size)
			if input[idx] != '@' do continue

			cell := &cells[y * size.x + x]
			cell.occupied = true
			n_adjacent := i8(0)
			for dir in DirVecs {
				target := coord + dir
				if !common.coord_valid(target, size) do continue
				idx := common.coord_to_idx(target, size)
				if input[idx] == '@' do n_adjacent += 1
			}
			cell.neighbors = n_adjacent
		}
	}

	for {
		removed := false
		for idx in 0 ..< len(cells) {
			cell := &cells[idx]
			if !cell.occupied do continue
			if cell.neighbors < 4 {
				removed = true
				cell.occupied = false
				res += 1
				for dir in DirVecs {
					target := [2]int{idx % size.x, idx / size.x} + dir
					if !common.coord_valid(target, size) do continue
					cells[target.y * size.x + target.x].neighbors -= 1
				}
			}
		}
		if !removed do break
	}

	return
}

@(test)
p1_test :: proc(t: ^testing.T) {
	input := #load("./sample.txt", string)
	res := p1(input)
	testing.expectf(t, res == 13, "got %v", res)
}

@(test)
p2_test :: proc(t: ^testing.T) {
	input := #load("./sample.txt", string)
	res := p2(input)
	testing.expectf(t, res == 43, "got %v", res)
}
