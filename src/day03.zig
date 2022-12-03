const std = @import("std");

const testing = false;

fn input_text() []const u8 {
    if (testing) {
        return @embedFile("test_inputs/day03.txt");
    } else {
        return @embedFile("real_inputs/day03.txt");
    }
}

const Rucksack = struct {
    left: u64,
    right: u64,
};

fn char_to_priority(c: u8) u8 {
    if (c >= 'A' and c <= 'Z') {
        return c-'A'+27;
    } else {
        // It is between 'a' and 'z'
        return c-'a'+1;
    }
}

fn str_to_bits(left: []const u8) u64 {
    var agg: u64 = 0;

    for (left) |c| {
        var priority: u8 = char_to_priority(c);
        if (priority > 0) {
            var shifted: u64 = std.math.pow(u64, 2, priority-1);
            agg |= shifted;
        }
    }

    return agg;
}

fn parse_rucksack(line: []const u8) Rucksack {
    var half_len = line.len/2;
    var left = line[0..half_len];
    var right = line[half_len..line.len];
    var left_bits = str_to_bits(left);
    var right_bits = str_to_bits(right);
    return Rucksack{.left = left_bits, .right = right_bits};
}

fn find_common_priority(r: *const Rucksack) u64 {
    var common = r.left & r.right;
    var common_priority: u64 = std.math.log(u64, 2, common)+1;
    return common_priority;
}

fn parse_rucksacks_a(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(Rucksack) {
    var lines = std.mem.tokenize(u8, input, "\n");
    const L = std.ArrayList(Rucksack);
    var rucksacks = L.init(allocator);
    while (lines.next()) |line| {
        var rucksack: Rucksack = parse_rucksack(line);
        try rucksacks.append(rucksack);
    }

    return rucksacks;
}

pub fn part_a(allocator: std.mem.Allocator) !u64 {
    const input = comptime input_text();
    var parsed = try parse_rucksacks_a(allocator, input);
    var sum: u64 = 0;
    for (parsed.toOwnedSlice()) |rucksack| {
        var common_priority = find_common_priority(&rucksack);
        sum += common_priority;
    }
    return sum;
}

pub fn part_b() !u64 {
    const input = comptime input_text();
    var lines = std.mem.tokenize(u8, input, "\n");
    var sum: u64 = 0;
    while (lines.next()) |a| {
        var b = lines.next().?;
        var c = lines.next().?;
        var a_rucksack = parse_rucksack(a);
        var a_value = a_rucksack.left | a_rucksack.right;
        var b_rucksack = parse_rucksack(b);
        var b_value = b_rucksack.left | b_rucksack.right;
        var c_rucksack = parse_rucksack(c);
        var c_value = c_rucksack.left | c_rucksack.right;
        var common_element = a_value & b_value & c_value;
        var common_priority: u64 = std.math.log(u64, 2, common_element)+1;
        sum += common_priority;
    }
    return sum;
}