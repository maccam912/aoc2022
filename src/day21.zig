const std = @import("std");
const constants = @import("constants.zig");
const trace = @import("tracy.zig").trace;

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day21.txt");
    } else {
        return @embedFile("real_inputs/day21.txt");
    }
}

const Op = enum { add, sub, mul, div };

const Node = struct {
    original_value: ?i64,
    value: ?i64,
    l: ?[]const u8,
    r: ?[]const u8,
    op: ?Op,
};

fn parseInput(allocator: std.mem.Allocator, input: []const u8) !std.StringHashMap(Node) {
    var result = std.StringHashMap(Node).init(allocator);
    var lines = std.mem.tokenize(u8, input, "\r\n");
    while (lines.next()) |line| {
        var parts = std.mem.split(u8, line, ": ");
        var name = parts.next().?;
        var value = parts.next().?;
        if (std.fmt.parseInt(isize, value, 10)) |parsed_value| {
            // We got a valid num!
            try result.put(name, Node{ .original_value = parsed_value, .value = parsed_value, .l = null, .r = null, .op = null });
        } else |_| {
            var op_parts = std.mem.tokenize(u8, value, " ");
            var l = op_parts.next().?;
            var op = op_parts.next().?;
            var r = op_parts.next().?;
            var actual_op: Op = switch (op[0]) {
                '+' => Op.add,
                '-' => Op.sub,
                '*' => Op.mul,
                '/' => Op.div,
                else => unreachable,
            };
            try result.put(name, Node{ .original_value = null, .value = null, .l = l, .r = r, .op = actual_op });
        }
    }
    return result;
}

fn reset(tree: *std.StringHashMap(Node)) void {
    var it = tree.iterator();
    while (it.next()) |item| {
        if (!constants.strEq(item.key_ptr.*, "humn")) {
            item.value_ptr.*.value = item.value_ptr.*.original_value;
        }
    }
}

fn resolve(name: []const u8, tree: *std.StringHashMap(Node)) !i64 {
    var node: *Node = tree.getPtr(name).?;
    const value = node.*.value;
    if (value != null) {
        return value.?;
    } else {
        var l = try resolve(node.l.?, tree);
        var r = try resolve(node.r.?, tree);
        switch (node.*.op.?) {
            Op.add => node.*.value = l + r,
            Op.sub => node.*.value = l - r,
            Op.mul => node.*.value = l * r,
            Op.div => {
                if (std.math.divExact(i64, l, r)) |val| {
                    node.*.value = val;
                } else |_| {
                    return try std.math.divFloor(i64, l, r);
                }
            },
        }
        return node.*.value.?;
    }
}

pub fn partA(allocator: std.mem.Allocator) !i64 {
    const tracy = trace(@src());
    defer tracy.end();
    const input = comptime inputText();
    var parsed = try parseInput(allocator, input);
    var resolved = try resolve("root", &parsed);
    std.log.debug("Resolved {}", .{resolved});
    return resolved;
}

pub fn partB(allocator: std.mem.Allocator) !i64 {
    const tracy = trace(@src());
    defer tracy.end();
    const input = comptime inputText();
    var parsed = try parseInput(allocator, input);
    var l = parsed.get("root").?.l.?;
    var r = parsed.get("root").?.r.?;
    var inc_amount: i64 = 1;
    var prev_diff: i64 = std.math.maxInt(i64);
    var count: usize = 0;
    while (try resolve(l, &parsed) != try resolve(r, &parsed)) {
        count += 1;
        if (resolve(l, &parsed)) |l_val| {
            if (resolve(r, &parsed)) |r_val| {
                var diff = l_val - r_val;
                std.log.debug("Diff: {} (l {} r {})", .{ diff, l_val, r_val });
                if (diff < 0) {
                    parsed.getPtr("humn").?.*.value.? -= inc_amount;
                    inc_amount = 1;
                }
                if (diff < prev_diff) {
                    inc_amount *= 2;
                }
                prev_diff = diff;
            } else |_| {}
        } else |_| {}
        reset(&parsed);
        parsed.getPtr("humn").?.*.value.? += inc_amount;
    }
    std.log.debug("Humn value: {} l: {} r: {}", .{ parsed.get("humn").?.value.?, try resolve(l, &parsed), try resolve(r, &parsed) });
    std.log.debug("Count: {}", .{count});
    return parsed.get("humn").?.value.?;
}
