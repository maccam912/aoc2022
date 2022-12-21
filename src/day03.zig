const std = @import("std");
const constants = @import("constants.zig");

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day03.txt");
    } else {
        return @embedFile("real_inputs/day03.txt");
    }
}

const Rucksack = struct {
    left: usize,
    right: usize,
};

fn charToPriority(c: u8) u8 {
    if (c >= 'A' and c <= 'Z') {
        return c - 'A' + 27;
    } else {
        // It is between 'a' and 'z'
        return c - 'a' + 1;
    }
}

fn strToBits(left: []const u8) usize {
    var agg: usize = 0;

    for (left) |c| {
        var priority: u8 = charToPriority(c);
        if (priority > 0) {
            var shifted: usize = std.math.pow(usize, 2, priority - 1);
            agg |= shifted;
        }
    }

    return agg;
}

fn parseRucksack(line: []const u8) Rucksack {
    var half_len = line.len / 2;
    var left = line[0..half_len];
    var right = line[half_len..line.len];
    var left_bits = strToBits(left);
    var right_bits = strToBits(right);
    return Rucksack{ .left = left_bits, .right = right_bits };
}

fn findCommonPriority(r: *const Rucksack) usize {
    var common = r.left & r.right;
    var common_priority: usize = std.math.log(usize, 2, common) + 1;
    return common_priority;
}

fn parseRucksacksA(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(Rucksack) {
    var lines = std.mem.tokenize(u8, input, "\n");
    const L = std.ArrayList(Rucksack);
    var rucksacks = L.init(allocator);
    while (lines.next()) |line| {
        var rucksack: Rucksack = parseRucksack(line);
        try rucksacks.append(rucksack);
    }

    return rucksacks;
}

pub fn partA(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var parsed = try parseRucksacksA(allocator, input);
    var sum: usize = 0;
    for (parsed.toOwnedSlice()) |rucksack| {
        var common_priority = findCommonPriority(&rucksack);
        sum += common_priority;
    }
    return sum;
}

pub fn partB() !usize {
    const input = comptime inputText();
    var lines = std.mem.tokenize(u8, input, "\n");
    var sum: usize = 0;
    while (lines.next()) |a| {
        var b = lines.next().?;
        var c = lines.next().?;
        var a_rucksack = parseRucksack(a);
        var a_value = a_rucksack.left | a_rucksack.right;
        var b_rucksack = parseRucksack(b);
        var b_value = b_rucksack.left | b_rucksack.right;
        var c_rucksack = parseRucksack(c);
        var c_value = c_rucksack.left | c_rucksack.right;
        var common_element = a_value & b_value & c_value;
        var common_priority: usize = std.math.log(usize, 2, common_element) + 1;
        sum += common_priority;
    }
    return sum;
}
