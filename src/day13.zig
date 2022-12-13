const std = @import("std");
const constants = @import("constants.zig");

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day13.txt");
    } else {
        return @embedFile("real_inputs/day13.txt");
    }
}

const PacketItemType = usize;

const _PacketItem = enum {
    num,
    list,
};

const PacketItem = union(_PacketItem) {
    num: PacketItemType,
    list: std.ArrayList(PacketItem),
};

const Pair = struct {
    l: PacketItem,
    r: PacketItem,
};

fn parsePacketItem(input: []const u8) PacketItem {
    _ = input;
    return PacketItem{ .num = 5 };
}

fn parsePair(input: []const u8) Pair {
    var parts = std.mem.split(u8, input, "\n");
    var l = parts.next().?;
    var r = parts.next().?;

    return Pair{ .l = parsePacketItem(l), .r = parsePacketItem(r) };
}

fn parseInput(allocator: std.mem.Allocator, input: []const u8) std.ArrayList(Pair) {
    var result = std.ArrayList(Pair).init(allocator);

    var pairs = std.mem.split(u8, input, "\n\n");
    while (pairs.next()) |pair| {
        var parsed_pair: Pair = parsePair(pair);
        _ = parsed_pair;
    }

    return result;
}

pub fn partA(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var pairs = parseInput(allocator, input);
    _ = pairs;
    return 1;
}

pub fn partB(allocator: std.mem.Allocator) !usize {
    _ = allocator;
    return 1;
}
