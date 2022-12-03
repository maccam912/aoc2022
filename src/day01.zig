const std = @import("std");
const constants = @import("constants.zig");

fn input_text() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day01.txt");
    } else {
        return @embedFile("real_inputs/day01.txt");
    }
}

const Elf = struct {
    calories: u64
};

fn parse_elves(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(Elf) {
    const L = std.ArrayList(Elf);
    var list = L.init(allocator);
    var calories_sum: u64 = 0;

    var lines = std.mem.split(u8, input, "\n");
    var line: ?[]const u8 = lines.first();
    while (line != null) {
        if (line.?.len == 0) {
            var elf = Elf{.calories = calories_sum};
            try list.append(elf);
            calories_sum = 0;
        } else {
            // We have a number!
            var num: u64 = try std.fmt.parseInt(u64, line.?, 10);
            calories_sum += num;
        }
        line = lines.next();
    }
    // Add the last in progress elf
    var elf = Elf{.calories = calories_sum};
    try list.append(elf);

    return list;
}

fn max_calories(l: *std.ArrayList(Elf)) u64 {
    var max_calories_so_far: u64 = 0;
    var item = l.popOrNull();
    while (item != null) {
        if (item.?.calories > max_calories_so_far) {
            max_calories_so_far = item.?.calories;
        }
        item = l.popOrNull();
    }

    return max_calories_so_far;
}

fn sort_vals(max: *Triple) void {
    if (max.a < max.b) {
        const tmp = max.a;
        max.a = max.b;
        max.b = tmp;
    }
    if (max.b < max.c) {
        const tmp = max.b;
        max.b = max.c;
        max.c = tmp;
    }
}

const Triple = struct {
    a: u64,
    b: u64,
    c: u64,
};

fn max_calories_top_three(l: *std.ArrayList(Elf)) u64 {
    var max: Triple = Triple{.a = 0, .b = 0, .c = 0};
    var item = l.popOrNull();
    while (item != null) {
        if (item.?.calories > max.c) {
            max.c = max.b;
            max.b = max.a;
            max.a = item.?.calories;
        }

        sort_vals(&max);

        item = l.popOrNull();
    }

    return max.a+max.b+max.c;
}

pub fn part_a(allocator: std.mem.Allocator) !u64 {
    const input_str = comptime input_text();
    var elves = try parse_elves(allocator, input_str);
    var max_cals = max_calories(&elves);
    return max_cals;
}

pub fn part_b(allocator: std.mem.Allocator) !u64 {
    const input_str = comptime input_text();
    var elves = try parse_elves(allocator, input_str);
    var max_cals = max_calories_top_three(&elves);
    return max_cals;
}