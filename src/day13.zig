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

fn parsePacketItem(allocator: std.mem.Allocator, input: []const u8) !PacketItem {
    if (input[0] != '[' or input[input.len - 1] != ']') {
        return error.BracketsMissing;
    }

    // OK its a list. Check first for just "[]"
    if (constants.strEq("[]", input)) {
        // Empty list
        return PacketItem{ .list = std.ArrayList(PacketItem).init(allocator) };
    }

    // If we're here it is a list with actual stuff in it
    var strings = std.ArrayList([]const u8).init(allocator);
    var inner_string = input[1 .. input.len - 1]; // without brackets
    var start: usize = 0;
    var curr: usize = 0;
    var depth: usize = 0;

    while (curr < inner_string.len) : (curr += 1) {
        if ((inner_string[curr] == ',' or inner_string[curr] == ']') and depth == 0) {
            try strings.append(inner_string[start..curr]);
            start = curr + 1;
        } else if (inner_string[curr] == '[') {
            depth += 1;
        } else if (inner_string[curr] == ']') {
            depth -= 1;
        }
    }

    try strings.append(inner_string[start..]);

    var result = std.ArrayList(PacketItem).init(allocator);
    for (strings.items) |item| {
        if (item[0] == '[') {
            var list: PacketItem = try parsePacketItem(allocator, item);
            try result.append(list);
        } else {
            try result.append(PacketItem{ .num = try std.fmt.parseInt(PacketItemType, item, 10) });
        }
    }
    return PacketItem{ .list = result };
}

fn parsePair(allocator: std.mem.Allocator, input: []const u8) !Pair {
    var parts = std.mem.split(u8, input, "\n");
    var l = parts.next().?;
    var r = parts.next().?;

    return Pair{ .l = try parsePacketItem(allocator, l), .r = try parsePacketItem(allocator, r) };
}

fn parseInput(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(Pair) {
    var result = std.ArrayList(Pair).init(allocator);

    var pairs = std.mem.split(u8, input, "\n\n");
    while (pairs.next()) |pair| {
        var parsed_pair: Pair = try parsePair(allocator, pair);
        try result.append(parsed_pair);
    }

    return result;
}

fn prettyPrint(item: PacketItem) void {
    std.debug.print("[", .{});
    switch (item) {
        .num => |num| std.debug.print("{}", .{num}),
        .list => |list| {
            for (list.items) |inner_item| {
                prettyPrint(inner_item);
            }
        },
    }
    std.debug.print("]", .{});
}

fn checkPairOrder(allocator: std.mem.Allocator, l: PacketItem, r: PacketItem) !i8 {
    // 1 means "r" is greater, they're in correct order
    // 0 means they are equal
    // -1 means they are backward i.e. "r" is less than "l"
    return switch (l) {
        .num => |l_num| {
            return switch (r) {
                .num => |r_num| {
                    // Num and num, left should be less than right
                    if (l_num < r_num) {
                        return 1;
                    } else if (l_num == r_num) {
                        return 0;
                    } else {
                        return -1;
                    }
                },
                .list => |_| {
                    // Convert l to list, compare
                    var l_list = PacketItem{ .list = std.ArrayList(PacketItem).init(allocator) };
                    try l_list.list.append(PacketItem{ .num = l_num });
                    return checkPairOrder(allocator, l_list, r);
                },
            };
        },
        .list => |l_list| {
            return switch (r) {
                .num => |r_num| {
                    // Convert l to list, compare
                    var r_list = PacketItem{ .list = std.ArrayList(PacketItem).init(allocator) };
                    try r_list.list.append(PacketItem{ .num = r_num });
                    return checkPairOrder(allocator, l, r_list);
                },
                .list => |r_list| {
                    var idx: usize = 0;

                    while (idx < l_list.items.len and idx < r_list.items.len and try checkPairOrder(allocator, l_list.items[idx], r_list.items[idx]) == 0) : (idx += 1) {}
                    if (l_list.items.len == idx and r_list.items.len == idx) {
                        return 0;
                    } else if (l_list.items.len == idx and r_list.items.len > idx) {
                        // l_list ran out first
                        return 1;
                    } else if (l_list.items.len > idx and r_list.items.len == idx) {
                        // r_list ran out first
                        return -1;
                    }
                    return try checkPairOrder(allocator, l_list.items[idx], r_list.items[idx]);
                },
            };
        },
    };
}

pub fn partA(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var pairs = try parseInput(allocator, input);
    var sum: usize = 0;
    var idx: usize = 0;
    for (pairs.items) |pair| {
        idx += 1;
        if (try checkPairOrder(allocator, pair.l, pair.r) == 1) {
            sum += idx;
        }
    }
    return sum;
}

fn lessThan(context: std.mem.Allocator, lhs: PacketItem, rhs: PacketItem) bool {
    return (checkPairOrder(context, lhs, rhs) catch unreachable) == 1;
}

pub fn partB(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var packets = std.ArrayList(PacketItem).init(allocator);
    var pairs = try parseInput(allocator, input);
    for (pairs.items) |pair| {
        try packets.append(pair.l);
        try packets.append(pair.r);
    }

    var two = std.ArrayList(PacketItem).init(allocator);
    try two.append(PacketItem{ .num = 2 });
    var six = std.ArrayList(PacketItem).init(allocator);
    try six.append(PacketItem{ .num = 6 });

    try packets.append(PacketItem{ .list = two });
    try packets.append(PacketItem{ .list = six });

    var packet_slice: []PacketItem = packets.items;
    std.sort.sort(PacketItem, packet_slice, allocator, lessThan);

    var idx: usize = 0;
    var two_idx: usize = 0;
    var six_idx: usize = 0;

    for (packets.items) |item| {
        idx += 1;

        switch (item) {
            .list => |l| {
                if (l.items.len > 0) {
                    switch (l.items[0]) {
                        .num => |n| {
                            if (n == 2) {
                                two_idx = idx;
                            } else if (n == 6) {
                                six_idx = idx;
                            }
                        },
                        else => continue,
                    }
                }
            },
            else => continue,
        }
    }

    return two_idx * six_idx;
}
