const std = @import("std");
const constants = @import("constants.zig");

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day09.txt");
    } else {
        return @embedFile("real_inputs/day09.txt");
    }
}

const Coord = struct { x: isize, y: isize };

fn step(coords: *[]Coord) Coord {
    var i: usize = 0;
    while (i < coords.len - 1) : (i += 1) {
        var h: *Coord = &coords.*[i];
        var t: *Coord = &coords.*[i + 1];

        if (h.x - t.x > 1) {
            // move T right one
            t.x += 1;
            if (h.y > t.y) {
                t.y += 1;
            } else if (h.y < t.y) {
                t.y -= 1;
            }
        } else if (t.x - h.x > 1) {
            // Move T left one
            t.x -= 1;
            if (h.y > t.y) {
                t.y += 1;
            } else if (h.y < t.y) {
                t.y -= 1;
            }
        } else if (h.y - t.y > 1) {
            // Move T up one
            t.y += 1;
            if (h.x > t.x) {
                t.x += 1;
            } else if (h.x < t.x) {
                t.x -= 1;
            }
        } else if (t.y - h.y > 1) {
            // Move T down one
            t.y -= 1;
            if (h.x > t.x) {
                t.x += 1;
            } else if (h.x < t.x) {
                t.x -= 1;
            }
        }
    }

    return Coord{ .x = coords.*[i].x, .y = coords.*[i].y };
}

pub fn simulateRope(allocator: std.mem.Allocator, count: usize) !usize {
    const V = std.AutoHashMap(Coord, void);
    var visited = V.init(allocator);

    const input = comptime inputText();
    var lines = std.mem.split(u8, input, "\n");

    const CL = std.ArrayList(Coord);
    var coords_list = CL.init(allocator);
    defer coords_list.deinit();

    var i: usize = 0;
    while (i < count) : (i += 1) {
        try coords_list.append(Coord{ .x = 0, .y = 0 });
    }

    var turn_num: usize = 0;
    while (lines.next()) |line| {
        var parts = std.mem.split(u8, line, " ");
        var dir = parts.next().?[0];
        var amount = try std.fmt.parseInt(usize, parts.next().?, 10);
        i = 0;
        while (i < amount) : (i += 1) {
            if (dir == 'U') {
                coords_list.items[0].y += 1;
            } else if (dir == 'D') {
                coords_list.items[0].y -= 1;
            } else if (dir == 'R') {
                coords_list.items[0].x += 1;
            } else if (dir == 'L') {
                coords_list.items[0].x -= 1;
            }
            var new_point = step(&coords_list.items);
            try visited.put(new_point, {});
            turn_num += 1;
        }
    }

    var it = visited.keyIterator();
    var unique_points: usize = 0;
    while (it.next()) |_| {
        unique_points += 1;
    }

    return unique_points;
}

pub fn partA(allocator: std.mem.Allocator) !usize {
    return simulateRope(allocator, 2);
}

pub fn partB(allocator: std.mem.Allocator) !usize {
    return simulateRope(allocator, 10);
}
