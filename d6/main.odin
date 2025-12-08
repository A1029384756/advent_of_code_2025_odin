package d6

import "../common"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:testing"

main :: proc() {
	common.advent_of_code(p1, p2, {100, 1000})
}

Op :: enum {
	Add,
	Mul,
}

p1 :: proc(input: string) -> (res: int) {
	ops: [dynamic]Op
	defer delete(ops)
	#reverse for char in input[:len(input) - 1] {
		if char == '\n' do break
		if char == ' ' do continue
		append(&ops, Op.Add if char == '+' else Op.Mul)
	}
	slice.reverse(ops[:])

	nums: [dynamic]int
	defer delete(nums)
	first := true
	input := input
	for line in common.split_iterator_fast(&input, '\n') {
		if line[0] == '+' || line[0] == '*' do break
		line := line
		idx := 0
		for num in common.split_iterator_fast(&line, ' ') {
			if len(num) == 0 do continue
			num_parse, _ := strconv.parse_int(num)
			if first {
				append(&nums, num_parse)
			} else {
				if ops[idx] == .Add do nums[idx] += num_parse
				else do nums[idx] *= num_parse
			}
			idx += 1
		}
		first = false
	}

	for num in nums {
		res += num
	}
	return
}

p2 :: proc(input: string) -> (res: int) {
	context.allocator = context.temp_allocator
	defer free_all(context.allocator)
	lines := strings.split_lines(input)

	ops: [dynamic]Op
	#reverse for char in input[:len(input) - 1] {
		if char == '\n' do break
		if char == ' ' do continue
		append(&ops, Op.Add if char == '+' else Op.Mul)
	}
	slice.reverse(ops[:])

	transpose :: proc(m: [][]u8) -> [][]u8 {
		res := make([][]u8, len(m[0]))
		for col in 0 ..< len(m[0]) {
			res[col] = make([]u8, len(m))
			for row in 0 ..< len(m) {
				res[col][row] = m[row][col]
			}
		}
		return res
	}
	values := lines[:len(lines) - 1]
	values = transmute([]string)transpose(transmute([][]u8)values)

	vals_idx := 0
	for op in ops {
		problem := 0
		for val, idx in values[vals_idx:] {
			num_str := strings.trim_space(val)
			if len(num_str) == 0 {
				vals_idx += idx + 1
				break
			}

			num, _ := strconv.parse_int(num_str)
			if idx == 0 {
				problem = num
				continue
			}

			if op == .Add {
				problem += num
			} else {
				problem *= num
			}
		}

		res += problem
	}

	return
}

@(test)
p1_test :: proc(t: ^testing.T) {
	input := #load("./sample.txt", string)
	res := p1(input)
	testing.expectf(t, res == 4277556, "got %v", res)
}

@(test)
p2_test :: proc(t: ^testing.T) {
	input := #load("./sample.txt", string)
	res := p2(input)
	testing.expectf(t, res == 3263827, "got %v", res)
}
