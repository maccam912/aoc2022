const std = @import("std");
const constants = @import("constants.zig");

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day14.txt");
    } else {
        return @embedFile("real_inputs/day14.txt");
    }
}

const Coord = struct {
    col: usize,
    row: usize,
};

const Tile = struct {
    loc: Coord,
    material: u8, // 0 is air, 1 is sand, 2 is rock
};

fn strToCoord(input: []const u8) !Coord {
    var values = std.mem.split(u8, input, ",");
    var col = values.next().?;
    var row = values.next().?;
    return Coord{ .col = try std.fmt.parseInt(usize, col, 10), .row = try std.fmt.parseInt(usize, row, 10) };
}

fn parseInput(allocator: std.mem.Allocator, input: []const u8) !std.AutoHashMap(Coord, Tile) {
    var lines = std.mem.split(u8, input, "\n");
    var grid = std.AutoHashMap(Coord, Tile).init(allocator);

    var min_row: usize = 0; //std.math.maxInt(usize);
    var max_row: usize = 1; //std.math.minInt(usize);
    var min_col: usize = 499; //std.math.maxInt(usize);
    var max_col: usize = 501; //std.math.minInt(usize);

    while (lines.next()) |line| {
        var points = std.mem.split(u8, line, " -> ");
        var last_point: Coord = try strToCoord(points.next().?);
        min_row = @min(min_row, last_point.row - 1);
        max_row = @max(max_row, last_point.row + 1);
        min_col = @min(min_col, last_point.col - (max_row - min_row + 10));
        max_col = @max(max_col, last_point.col + (max_row - min_row + 10));

        while (points.next()) |new_point_str| {
            var new_point: Coord = try strToCoord(new_point_str);
            min_row = @min(min_row, new_point.row - 1);
            max_row = @max(max_row, new_point.row + 1);
            min_col = @min(min_col, new_point.col - 1);
            max_col = @max(max_col, new_point.col + 1);

            var col1: usize = undefined;
            var col2: usize = undefined;
            if (last_point.col < new_point.col) {
                col1 = last_point.col;
                col2 = new_point.col;
            } else {
                col1 = new_point.col;
                col2 = last_point.col;
            }

            var row1: usize = undefined;
            var row2: usize = undefined;
            if (last_point.row < new_point.row) {
                row1 = last_point.row;
                row2 = new_point.row;
            } else {
                row1 = new_point.row;
                row2 = last_point.row;
            }

            var orig_row_1 = row1;
            while (col1 <= col2) : (col1 += 1) {
                row1 = orig_row_1;
                while (row1 <= row2) : (row1 += 1) {
                    try grid.put(Coord{ .row = row1, .col = col1 }, Tile{ .loc = Coord{ .row = row1, .col = col1 }, .material = 2 });
                }
            }

            last_point = new_point;
        }
    }

    var orig_min_col = min_col;
    while (min_row <= max_row) : (min_row += 1) {
        min_col = orig_min_col;
        while (min_col <= max_col) : (min_col += 1) {
            var g = grid.get(Coord{ .col = min_col, .row = min_row });
            if (g == null) {
                // Hasn't been touched, fill in air
                try grid.put(Coord{ .col = min_col, .row = min_row }, Tile{ .loc = Coord{ .col = min_col, .row = min_row }, .material = 0 });
            }
        }
    }

    return grid;
}

fn settleSandGrain(grid: *std.AutoHashMap(Coord, Tile), floor: bool) bool {
    var curr_loc = Coord{ .col = 500, .row = 0 };

    while (true) {
        var below_loc = Coord{ .col = curr_loc.col, .row = curr_loc.row + 1 };
        var below = grid.getPtr(below_loc);

        var left_loc = Coord{ .col = curr_loc.col - 1, .row = curr_loc.row + 1 };
        var left = grid.getPtr(left_loc);

        var right_loc = Coord{ .col = curr_loc.col + 1, .row = curr_loc.row + 1 };
        var right = grid.getPtr(right_loc);

        if (below == null) {
            if (!floor) {
                // This one is going off the screen. We're all done
                grid.getPtr(curr_loc).?.*.material = 0;
                return true;
            } else {
                // Pretend there is a floor down there
                grid.getPtr(curr_loc).?.*.material = 1; // curr_loc becomes sand
                return false;
            }
        }

        if (below != null and below.?.material == 0) { // Air
            grid.getPtr(curr_loc).?.*.material = 0; // curr_loc becomes air
            grid.getPtr(below_loc).?.*.material = 1; // below_loc becomes sand
            curr_loc = below_loc;
        } else if (left != null and left.?.material == 0) {
            grid.getPtr(curr_loc).?.*.material = 0; // curr_loc becomes air
            grid.getPtr(left_loc).?.*.material = 1; // below_loc becomes sand
            curr_loc = left_loc;
        } else if (right != null and right.?.material == 0) {
            grid.getPtr(curr_loc).?.*.material = 0; // curr_loc becomes air
            grid.getPtr(right_loc).?.*.material = 1; // below_loc becomes sand
            curr_loc = right_loc;
        } else {
            if (curr_loc.row == 0 and curr_loc.col == 500) {
                // We're full. Nothing more we can do
                grid.getPtr(curr_loc).?.*.material = 1;
                return true;
            }
            // Must be settled. Return
            return false;
        }
    }
}

const BoundingBox = struct {
    p1: Coord,
    p2: Coord,
};

fn getMinMax(grid: *const std.AutoHashMap(Coord, Tile)) BoundingBox {
    var min_row: usize = 0;
    var max_row: usize = 0;
    var min_col: usize = 500;
    var max_col: usize = 500;
    var it = grid.iterator();
    while (it.next()) |item| {
        var key = item.key_ptr;
        if (item.value_ptr.material != 0) {
            min_col = @min(min_col, key.col - 1);
            max_col = @max(max_col, key.col + 1);
            min_row = @min(min_row, key.row - 1);
            max_row = @max(max_row, key.row + 1);
        }
    }
    return BoundingBox{ .p1 = Coord{ .col = min_col, .row = min_row }, .p2 = Coord{ .col = max_col, .row = max_row } };
}

fn debug(grid: *std.AutoHashMap(Coord, Tile)) void {
    const bounds = getMinMax(grid);
    var row: usize = 0;
    while (row < bounds.p2.row) : (row += 1) {
        var col: usize = bounds.p1.col;
        while (col < bounds.p2.col) : (col += 1) {
            var tile = grid.get(Coord{ .col = col, .row = row });
            if (tile == null) {
                std.debug.print(".", .{});
            } else if (tile.?.material == 0) {
                std.debug.print(".", .{});
            } else if (tile.?.material == 1) {
                std.debug.print("o", .{});
            } else if (tile.?.material == 2) {
                std.debug.print("#", .{});
            }
        }
        std.debug.print("\n", .{});
    }
}

fn runSimulation(grid: *std.AutoHashMap(Coord, Tile), part_b: bool) void {
    var round: usize = 0;
    while (!settleSandGrain(grid, part_b)) {
        round += 1;
        // Loop until settleSandGrain is done
        // if (@mod(round, 50) == 0) {
        //     std.time.sleep(500*std.time.ns_per_ms);
        //     debug(grid);
        // }
    }
    return;
}

pub fn partA(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var grid: std.AutoHashMap(Coord, Tile) = try parseInput(allocator, input);
    runSimulation(&grid, false);
    // All sand is settled now. Count up the sand
    var it = grid.iterator();
    var sum: usize = 0;
    while (it.next()) |item| {
        if (item.value_ptr.material == 1) {
            // Its sand, count it
            sum += 1;
        }
    }
    return sum;
}

pub fn partB(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var grid: std.AutoHashMap(Coord, Tile) = try parseInput(allocator, input);
    runSimulation(&grid, true);
    // All sand is settled now. Count up the sand
    var it = grid.iterator();
    var sum: usize = 0;
    while (it.next()) |item| {
        if (item.value_ptr.material == 1) {
            // Its sand, count it
            sum += 1;
        }
    }
    return sum;
}
