const std = @import("std");
const constants = @import("constants.zig");

fn input_text() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day03.txt");
    } else {
        return @embedFile("real_inputs/day03.txt");
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

    const stdout = std.io.getStdOut().writer();

    var list = L.init(allocator);
    constants.debug(list);
    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        try stdout.print("{any}\n", .{line});
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

test "day04" {
    var input_str = comptime input_text();
    var parsed_input = try parse_input(std.testing.allocator, input_str);
    constants.debug(parsed_input);
}