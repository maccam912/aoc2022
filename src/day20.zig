const std = @import("std");
const constants = @import("constants.zig");

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day20.txt");
    } else {
        return @embedFile("real_inputs/day20.txt");
    }
}

const Node = struct {
    data: isize,
    prev: ?*Node,
    next: ?*Node,

    fn removeNode(self: *Node) !void {
        if (self.prev != null and self.next != null) {
            self.prev.?.*.next = self.next;
            self.next.?.*.prev = self.prev;
        }
    }

    fn insertAfter(self: *Node, target: *Node) !void {
        if (target.next != null) {
            var new_prev = target;
            var new_next = target.*.next.?;
            self.prev = new_prev;
            self.next = new_next;
            new_prev.*.next = self;
            new_next.*.prev = self;
        }
    }

    fn moveBackward(self: *Node) !void {
        var target = self.prev.?.*.prev.?;
        try self.removeNode();
        try self.insertAfter(target);
    }

    fn moveForward(self: *Node) !void {
        var target = self.next.?;
        try self.removeNode();
        try self.insertAfter(target);
    }
};

fn parse(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(Node) {
    var orig = std.ArrayList(Node).init(allocator);
    var lines = std.mem.tokenize(u8, input, "\r\n");
    while (lines.next()) |line| {
        var num = try std.fmt.parseInt(isize, line, 10);
        try orig.append(Node{
            .data = num,
            .prev = null,
            .next = null,
        });
    }
    orig.items[0].next = &orig.items[1];
    orig.items[0].prev = &orig.items[orig.items.len - 1];
    orig.items[orig.items.len - 1].next = &orig.items[0];
    orig.items[orig.items.len - 1].prev = &orig.items[orig.items.len - 2];

    var i: usize = 1;
    while (i < orig.items.len - 1) : (i += 1) {
        orig.items[i].next = &orig.items[i + 1];
        orig.items[i].prev = &orig.items[i - 1];
    }

    return orig;
}

fn debug(node: *Node, len: usize) void {
    var i: usize = 0;
    var curr: Node = node.*;
    while (i < len) : (i += 1) {
        std.log.debug("{}", .{curr.data});
        curr = curr.next.?.*;
    }
}

fn findZero(list: std.ArrayList(Node)) !Node {
    for (list.items) |item| {
        if (item.data == 0) {
            return item;
        }
    }
    return error.NodeNotFound;
}

pub fn partA(allocator: std.mem.Allocator) !isize {
    const input = comptime inputText();
    const list = try parse(allocator, input);
    var list_len = list.items.len;
    var idx: usize = 0;
    while (idx < list.items.len) : (idx += 1) {
        var item: *Node = &list.items[idx];
        if (item.data >= 0) {
            var i: usize = 0;
            var dist = std.math.absCast(item.data) % list_len;
            while (i < dist) : (i += 1) {
                try item.moveForward();
            }
        } else if (item.data < 0) {
            var i: usize = 0;
            var dist = std.math.absCast(@rem(item.data, @intCast(isize, list_len)));
            while (i < dist) : (i += 1) {
                try item.moveBackward();
            }
        }
    }
    var n: Node = try findZero(list);

    var a: *Node = &n;
    var idx_a: usize = 0;
    while (idx_a < 1000) : (idx_a += 1) {
        a = a.next.?;
    }
    std.log.debug("a: {}", .{a.data});

    var b: *Node = &n;
    var idx_b: usize = 0;
    while (idx_b < 2000) : (idx_b += 1) {
        b = b.next.?;
    }
    std.log.debug("b: {}", .{b.data});

    var c: *Node = &n;
    var idx_c: usize = 0;
    while (idx_c < 3000) : (idx_c += 1) {
        c = c.next.?;
    }
    std.log.debug("c: {}", .{c.data});
    return a.data + b.data + c.data;
}

pub fn partB(allocator: std.mem.Allocator) !isize {
    const input = comptime inputText();
    const list = try parse(allocator, input);
    var list_len = list.items.len;
    var idx: usize = 0;
    while (idx < list.items.len) : (idx += 1) {
        list.items[idx].data *= 811589153;
    }
    var outer_idx: usize = 0;
    while (outer_idx < 10) : (outer_idx += 1) {
        idx = 0;
        while (idx < list.items.len) : (idx += 1) {
            var item: *Node = &list.items[idx];
            if (item.data >= 0) {
                var i: usize = 0;
                var dist = std.math.absCast(item.data) % (list_len - 1);
                while (i < dist) : (i += 1) {
                    try item.moveForward();
                }
            } else if (item.data < 0) {
                var i: usize = 0;
                var dist = std.math.absCast(@rem(item.data, @intCast(isize, (list_len - 1))));
                while (i < dist) : (i += 1) {
                    try item.moveBackward();
                }
            }
        }
    }
    var n: Node = try findZero(list);

    var a: *Node = &n;
    var idx_a: usize = 0;
    while (idx_a < 1000) : (idx_a += 1) {
        a = a.next.?;
    }
    std.log.debug("a: {}", .{a.data});

    var b: *Node = &n;
    var idx_b: usize = 0;
    while (idx_b < 2000) : (idx_b += 1) {
        b = b.next.?;
    }
    std.log.debug("b: {}", .{b.data});

    var c: *Node = &n;
    var idx_c: usize = 0;
    while (idx_c < 3000) : (idx_c += 1) {
        c = c.next.?;
    }
    std.log.debug("c: {}", .{c.data});
    return a.data + b.data + c.data;
}
