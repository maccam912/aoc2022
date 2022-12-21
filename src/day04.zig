const std = @import("std");
const constants = @import("constants.zig");

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day04.txt");
    } else {
        return @embedFile("real_inputs/day04.txt");
    }
}

const Elf = struct {
    range_start: usize,
    range_end: usize,
};

const Pair = struct {
    a: Elf,
    b: Elf,
};

fn parseInput(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(Pair) {
    const L = std.ArrayList(Pair);
    var list = L.init(allocator);
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        var elves = std.mem.tokenize(u8, line, ",");
        var a = elves.next().?;
        var b = elves.next().?;
        var a_tokens = std.mem.tokenize(u8, a, "-");
        var b_tokens = std.mem.tokenize(u8, b, "-");
        var a_start = try std.fmt.parseInt(usize, a_tokens.next().?, 10);
        var a_end = try std.fmt.parseInt(usize, a_tokens.next().?, 10);
        var b_start = try std.fmt.parseInt(usize, b_tokens.next().?, 10);
        var b_end = try std.fmt.parseInt(usize, b_tokens.next().?, 10);
        var elf_a = Elf{ .range_start = a_start, .range_end = a_end };
        var elf_b = Elf{ .range_start = b_start, .range_end = b_end };
        var pair = Pair{ .a = elf_a, .b = elf_b };
        try list.append(pair);
    }
    return list;
}

fn pairHasEntireOverlap(p: *const Pair) bool {
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

fn pairHasAnyOverlap(p: *const Pair) bool {
    if (p.b.range_start <= p.a.range_end and p.b.range_end >= p.a.range_start) {
        return true;
    } else if (p.a.range_start <= p.b.range_end and p.a.range_end >= p.b.range_start) {
        return true;
    } else {
        return false;
    }
}

pub fn partA(allocator: std.mem.Allocator) !usize {
    var input_str = comptime inputText();
    var parsed_input = try parseInput(allocator, input_str);
    var sum: usize = 0;
    for (parsed_input.toOwnedSlice()) |pair| {
        if (pairHasEntireOverlap(&pair)) {
            sum += 1;
        }
    }
    return sum;
}

pub fn partB(allocator: std.mem.Allocator) !usize {
    var input_str = comptime inputText();
    var parsed_input = try parseInput(allocator, input_str);
    var sum: usize = 0;
    for (parsed_input.toOwnedSlice()) |pair| {
        if (pairHasAnyOverlap(&pair)) {
            sum += 1;
        }
    }
    return sum;
}
