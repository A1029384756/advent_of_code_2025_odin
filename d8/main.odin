package d8

import "../common"
import "core:slice"
import "core:strconv"
import "core:testing"

main :: proc() {
	common.advent_of_code(p1, p2, {2, 5})
}

Vec3 :: [3]int
parse_positions :: proc(input: string, positions: ^[dynamic]Vec3) {
	input := input
	for line in common.split_iterator_fast(&input, '\n') {
		line := line
		position: Vec3
		idx := 0
		for component_str in common.split_iterator_fast(&line, ',') {
			component, _ := strconv.parse_int(component_str)
			position[idx] = component
			idx += 1
		}
		append(positions, position)
	}
}

Dist :: struct {
	dist:   int, // not actually true dist, missing sqrt
	p1, p2: int, // index into `positions` array
}
gen_dists :: proc(positions: []Vec3, dists: ^[dynamic]Dist) {
	for pos_a, idx_a in positions {
		for pos_b, idx_b in positions[idx_a + 1:] {
			delta := pos_b - pos_a
			delta *= delta
			append(
				dists,
				Dist{dist = delta.x + delta.y + delta.z, p1 = idx_a, p2 = idx_b + idx_a + 1},
			)
		}
	}

	slice.sort_by(dists[:], proc(a, b: Dist) -> bool {
		return a.dist < b.dist
	})
}

N_CONNECTIONS :: 10 when ODIN_TEST else 1000
p1 :: proc(input: string) -> (res: int) {
	context.allocator = context.temp_allocator
	defer free_all(context.temp_allocator)

	positions: [dynamic]Vec3
	parse_positions(input, &positions)

	dists: [dynamic]Dist
	gen_dists(positions[:], &dists)

	point_circuits := make([]int, len(positions))
	for &circuit, idx in point_circuits {
		circuit = idx
	}
	circuit_sizes := make([]int, len(positions))
	for &size in circuit_sizes {
		size = 1
	}
	for &dist in dists[:N_CONNECTIONS] {
		p1_circuit := point_circuits[dist.p1]
		p2_circuit := point_circuits[dist.p2]
		if p1_circuit == p2_circuit do continue

		c1_size := &circuit_sizes[p1_circuit]
		c2_size := &circuit_sizes[p2_circuit]

		c1_size^ += c2_size^
		c2_size^ = 0
		for &circuit in point_circuits {
			if circuit == p2_circuit {
				circuit = p1_circuit
			}
		}
	}

	slice.sort_by(circuit_sizes, proc(a, b: int) -> bool {
		return a > b
	})
	res = circuit_sizes[0] * circuit_sizes[1] * circuit_sizes[2]

	return
}

p2 :: proc(input: string) -> (res: int) {
	context.allocator = context.temp_allocator
	defer free_all(context.temp_allocator)

	positions: [dynamic]Vec3
	parse_positions(input, &positions)

	dists: [dynamic]Dist
	gen_dists(positions[:], &dists)

	point_circuits := make([]int, len(positions))
	for &circuit, idx in point_circuits {
		circuit = idx
	}
	circuit_sizes := make([]int, len(positions))
	for &size in circuit_sizes {
		size = 1
	}
	for &dist in dists {
		p1_circuit := point_circuits[dist.p1]
		p2_circuit := point_circuits[dist.p2]
		if p1_circuit == p2_circuit do continue

		c1_size := &circuit_sizes[p1_circuit]
		c2_size := &circuit_sizes[p2_circuit]

		c1_size^ += c2_size^
		c2_size^ = 0
		for &circuit in point_circuits {
			if circuit == p2_circuit {
				circuit = p1_circuit
			}
		}

		if c1_size^ == len(positions) {
			return positions[dist.p1].x * positions[dist.p2].x
		}
	}

	return
}

@(test)
p1_test :: proc(t: ^testing.T) {
	input := #load("./sample.txt", string)
	res := p1(input)
	testing.expectf(t, res == 40, "got %v", res)
}

@(test)
p2_test :: proc(t: ^testing.T) {
	input := #load("./sample.txt", string)
	res := p2(input)
	testing.expectf(t, res == 25272, "got %v", res)
}
