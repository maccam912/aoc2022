const std = @import("std");
const constants = @import("constants.zig");

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day18.txt");
    } else {
        return @embedFile("real_inputs/day18.txt");
    }
}

const T = i8;

const Coord = struct {
    x: T,
    y: T,
    z: T,
};

fn buildGrid(allocator: std.mem.Allocator, input: []const u8) !std.AutoHashMap(Coord, void) {
    var grid = std.AutoHashMap(Coord, void).init(allocator);
    var lines = std.mem.tokenize(u8, input, "\r\n");
    while (lines.next()) |line| {
        var coords = std.mem.tokenize(u8, line, ",");
        var coord = Coord{ .x = try std.fmt.parseInt(i8, coords.next().?, 10), .y = try std.fmt.parseInt(i8, coords.next().?, 10), .z = try std.fmt.parseInt(i8, coords.next().?, 10) };
        try grid.put(coord, {});
    }
    return grid;
}

fn getNeighbors(coord: *Coord, result: *[6]Coord) void {
    result[0] = Coord{ .x = coord.x - 1, .y = coord.y, .z = coord.z };
    result[1] = Coord{ .x = coord.x + 1, .y = coord.y, .z = coord.z };
    result[2] = Coord{ .x = coord.x, .y = coord.y - 1, .z = coord.z };
    result[3] = Coord{ .x = coord.x, .y = coord.y + 1, .z = coord.z };
    result[4] = Coord{ .x = coord.x, .y = coord.y, .z = coord.z - 1 };
    result[5] = Coord{ .x = coord.x, .y = coord.y, .z = coord.z + 1 };
}

pub fn partA(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var grid = try buildGrid(allocator, input);
    var exposed_faces: usize = 0;

    var it = grid.keyIterator();
    var neighbors_buffer: [6]Coord = std.mem.zeroes([6]Coord);
    while (it.next()) |item| {
        getNeighbors(item, &neighbors_buffer);
        for (neighbors_buffer) |n| {
            if (grid.get(n) == null) {
                exposed_faces += 1;
            }
        }
    }

    return exposed_faces;
}

const max_coord = 30;

fn floodExternal(allocator: std.mem.Allocator, lava: *std.AutoHashMap(Coord, void)) !std.AutoHashMap(Coord, void) {
    var external = std.AutoHashMap(Coord, void).init(allocator);
    var to_visit = std.ArrayList(Coord).init(allocator);
    try external.put(Coord{ .x = -1, .y = -1, .z = -1 }, {});
    try to_visit.append(Coord{ .x = -1, .y = -1, .z = -1 });
    var neighbors_buffer: [6]Coord = std.mem.zeroes([6]Coord);
    while (to_visit.items.len > 0) {
        var check = to_visit.pop();
        getNeighbors(&check, &neighbors_buffer);
        for (neighbors_buffer) |n| {
            if (n.x >= -1 and n.x <= max_coord and n.y >= -1 and n.y <= max_coord and n.z >= -1 and n.z <= max_coord) {
                // In bounds
                if (lava.get(n) == null and external.get(n) == null) {
                    // untracked empty space! add it to to_visit and external
                    try external.put(n, {});
                    try to_visit.append(n);
                }
            }
        }
    }
    return external;
}

pub fn partB(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var grid = try buildGrid(allocator, input);
    var exposed_faces: usize = 0;
    var external = try floodExternal(allocator, &grid);

    var it = grid.keyIterator();
    while (it.next()) |item| {
        var neighbors_buffer: [6]Coord = std.mem.zeroes([6]Coord);
        getNeighbors(item, &neighbors_buffer);
        for (neighbors_buffer) |n| {
            if (external.get(n) != null) {
                exposed_faces += 1;
            }
        }
    }

    return exposed_faces;
}
