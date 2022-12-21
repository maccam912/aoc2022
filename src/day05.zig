const std = @import("std");
const constants = @import("constants.zig");

const State = struct {
    stacks: std.ArrayList(std.ArrayList(u8)),
};

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day05.txt");
    } else {
        return @embedFile("real_inputs/day05.txt");
    }
}

const Point = struct {
    x: isize,
    y: isize,
};

fn charGrid(allocator: std.mem.Allocator, input: []const u8) !std.AutoHashMap(Point, u8) {
    const HM = std.AutoHashMap(Point, u8);
    var result = HM.init(allocator);
    var parts = std.mem.split(u8, input, "\n\n");
    var stacks = parts.next().?;

    var line: isize = 0;

    var stack_lines = std.mem.split(u8, stacks, "\n");
    while (stack_lines.next()) |stack_line| {
        var col: isize = 0;
        for (stack_line) |c| {
            try result.put(Point{ .x = col, .y = line }, c);
            col += 1;
        }
        line += 1;
    }

    return result;
}

fn constructState(allocator: std.mem.Allocator, char_grid: *std.AutoHashMap(Point, u8)) !State {
    const S = std.ArrayList(std.ArrayList(u8));
    var stacks = S.init(allocator);
    var i: u8 = 0;
    while (i < 9) : (i += 1) {
        try stacks.append(std.ArrayList(u8).init(allocator));
    }
    var result = State{ .stacks = stacks };

    var max_row: isize = 0;
    var key_iter = char_grid.keyIterator();
    while (key_iter.next()) |key| {
        if (key.y > max_row) {
            max_row = key.y;
        }
    }

    // starting at max_row and working backward to 0
    while (max_row >= 0) : (max_row -= 1) {
        var col: isize = 0;
        var actual_col: isize = 4 * col + 1;
        while (char_grid.get(Point{ .x = actual_col, .y = max_row })) |value| {
            if (value != 32) {
                try stacks.items[@intCast(usize, col)].append(value);
            }
            col += 1;
            actual_col = 4 * col + 1;
        }
    }

    return result;
}

fn operateA(state: *State, input: []const u8) !void {
    var initial_parts = std.mem.split(u8, input, "\n\n");
    _ = initial_parts.next();
    var instructions = initial_parts.next().?;
    var instruction_lines = std.mem.split(u8, instructions, "\n");
    while (instruction_lines.next()) |line| {
        var parts = std.mem.split(u8, line, " from ");
        var count_parts = std.mem.split(u8, parts.next().?, "move ");
        _ = count_parts.next().?;
        var count_part = count_parts.next().?;
        var count_num: usize = try std.fmt.parseInt(usize, count_part, 10);
        var x_to_y = parts.next().?;
        var x_y_parts = std.mem.split(u8, x_to_y, " to ");
        var from = try std.fmt.parseInt(usize, x_y_parts.next().?, 10) - 1;
        var to = try std.fmt.parseInt(usize, x_y_parts.next().?, 10) - 1;

        var i: usize = 0;
        while (i < count_num) : (i += 1) {
            var v = state.stacks.items[from].pop();
            try state.stacks.items[to].append(v);
        }
    }
}

fn operateB(allocator: std.mem.Allocator, state: *State, input: []const u8) !void {
    var initial_parts = std.mem.split(u8, input, "\n\n");
    _ = initial_parts.next();
    var instructions = initial_parts.next().?;
    var instruction_lines = std.mem.split(u8, instructions, "\n");
    while (instruction_lines.next()) |line| {
        var parts = std.mem.split(u8, line, " from ");
        var count_parts = std.mem.split(u8, parts.next().?, "move ");
        _ = count_parts.next().?;
        var count_part = count_parts.next().?;
        var count_num: usize = try std.fmt.parseInt(usize, count_part, 10);
        var x_to_y = parts.next().?;
        var x_y_parts = std.mem.split(u8, x_to_y, " to ");
        var from = try std.fmt.parseInt(usize, x_y_parts.next().?, 10) - 1;
        var to = try std.fmt.parseInt(usize, x_y_parts.next().?, 10) - 1;
        var tmp = std.ArrayList(u8).init(allocator);
        var count_two = count_num;

        var i: usize = 0;
        while (i < count_num) : (i += 1) {
            var v: u8 = state.stacks.items[from].pop();
            try tmp.append(v);
        }
        i = 0;
        while (i < count_two) : (i += 1) {
            var v: u8 = tmp.pop();
            try state.stacks.items[to].append(v);
        }
    }
}

pub fn partA(allocator: std.mem.Allocator) ![]const u8 {
    const input_text = comptime inputText();
    var char_grid = try charGrid(allocator, input_text);
    var state: State = try constructState(allocator, &char_grid);
    try operateA(&state, input_text);
    var s: std.ArrayList(u8) = std.ArrayList(u8).init(allocator);
    for (state.stacks.items) |stack| {
        if (stack.items.len > 0) {
            var c = stack.items[stack.items.len - 1];
            try s.append(c);
        }
    }
    return s.items;
}

pub fn partB(allocator: std.mem.Allocator) ![]const u8 {
    const input_text = comptime inputText();
    var char_grid = try charGrid(allocator, input_text);
    var state: State = try constructState(allocator, &char_grid);
    try operateB(allocator, &state, input_text);
    var s: std.ArrayList(u8) = std.ArrayList(u8).init(allocator);
    for (state.stacks.items) |stack| {
        if (stack.items.len > 0) {
            var c = stack.items[stack.items.len - 1];
            try s.append(c);
        }
    }
    return s.items;
}
