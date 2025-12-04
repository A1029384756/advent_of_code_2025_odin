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
	occupied := make([]bool, size.x * size.y)
	neighbors := make([]i8, size.x * size.y)
	defer delete(occupied)
	defer delete(neighbors)

	for x in 0 ..< size.x {
		for y in 0 ..< size.y {
			coord := [2]int{x, y}
			idx := common.coord_to_idx(coord, size)
			if input[idx] != '@' do continue

			occupied[y * size.x + x] = true
			n_adjacent := i8(0)
			for dir in DirVecs {
				target := coord + dir
				if !common.coord_valid(target, size) do continue
				idx := common.coord_to_idx(target, size)
				if input[idx] == '@' do n_adjacent += 1
			}
			neighbors[y * size.x + x] = n_adjacent
		}
	}

	for {
		removed := false
		for idx in 0 ..< len(occupied) {
			if !occupied[idx] do continue
			if neighbors[idx] < 4 {
				removed = true
				occupied[idx] = false
				res += 1
				for dir in DirVecs {
					target := [2]int{idx % size.x, idx / size.x} + dir
					if !common.coord_valid(target, size) do continue
					neighbors[target.y * size.x + target.x] -= 1
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
