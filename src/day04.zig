const std = @import("std");
const constants = @import("constants.zig");

fn input_text() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day04.txt");
    } else {
        return @embedFile("real_inputs/day04.txt");
    }
}

const Elf = struct {
    range_start: u64,
    range_end: u64,
};

const Pair = struct {
    a: Elf,
    b: Elf,
};

fn parse_input(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(Pair) {
    const L = std.ArrayList(Pair);
    var list = L.init(allocator);
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        var elves = std.mem.tokenize(u8, line, ",");
        var a = elves.next().?;
        var b = elves.next().?;
        var a_tokens = std.mem.tokenize(u8, a, "-");
        var b_tokens = std.mem.tokenize(u8, b, "-");
        var a_start = try std.fmt.parseInt(u64, a_tokens.next().?, 10);
        var a_end = try std.fmt.parseInt(u64, a_tokens.next().?, 10);
        var b_start = try std.fmt.parseInt(u64, b_tokens.next().?, 10);
        var b_end = try std.fmt.parseInt(u64, b_tokens.next().?, 10);
        var elf_a = Elf{.range_start = a_start, .range_end = a_end};
        var elf_b = Elf{.range_start = b_start, .range_end = b_end};
        var pair = Pair{.a = elf_a, .b = elf_b};
        try list.append(pair);
    }
    return list;
}

fn pair_has_entire_overlap(p: *const Pair) bool {
    if (p.b.range_start >= p.a.range_start and p.b.range_end <= p.a.range_end) {
        // b is in a
        return true;
    } else if (p.a.range_start >= p.b.range_start and p.a.range_end <= p.b.range_end) {
        // a is in b
        return true;
    } else {
        return false;
    }
}

fn pair_has_any_overlap(p: *const Pair) bool {
    if (p.b.range_start <= p.a.range_end and p.b.range_end >= p.a.range_start) {
        return true;
    } else if (p.a.range_start <= p.b.range_end and p.a.range_end >= p.b.range_start) {
        return true;
    } else {
        return false;
    }
}

pub fn part_a(allocator: std.mem.Allocator) !u64 {
    var input_str = comptime input_text();
    var parsed_input = try parse_input(allocator, input_str);
    var sum: u64 = 0;
    for (parsed_input.toOwnedSlice()) |pair| {
        if (pair_has_entire_overlap(&pair)) {
            sum += 1;
        }
    }
    return sum;
}

pub fn part_b(allocator: std.mem.Allocator) !u64 {
    var input_str = comptime input_text();
    var parsed_input = try parse_input(allocator, input_str);
    var sum: u64 = 0;
    for (parsed_input.toOwnedSlice()) |pair| {
        if (pair_has_any_overlap(&pair)) {
            sum += 1;
        }
    }
    return sum;
}