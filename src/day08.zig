const std = @import("std");
const constants = @import("constants.zig");

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day08.txt");
    } else {
        return @embedFile("real_inputs/day08.txt");
    }
}

const Tree = struct {
    height: u8,
    visible: bool,
};

const Coord = struct {
    row: usize,
    col: usize,
};

fn parseInput(allocator: std.mem.Allocator, input: []const u8) !std.AutoHashMap(Coord, Tree) {
    var i: usize = 0;
    const T = std.AutoHashMap(Coord, Tree);
    var grid = T.init(allocator);
    var it = std.mem.split(u8, input, "\n");
    while (it.next()) |line| {
        var j: usize = 0;
        for (line) |c| {
            var num = c - '0';
            try grid.put(Coord{ .row = i, .col = j }, Tree{ .height = num, .visible = false });
            j += 1;
        }
        i += 1;
    }
    return grid;
}

fn isTreeVisible(coord: Coord, grid: *std.AutoHashMap(Coord, Tree), max_row: usize, max_col: usize) bool {
    var visible_north = true;
    var visible_south = true;
    var visible_east = true;
    var visible_west = true;

    // Check north first
    var height = grid.get(coord).?.height;
    var row: usize = coord.row;
    while (row > 0) : (row -= 1) {
        if (grid.get(Coord{ .row = row - 1, .col = coord.col }).?.height >= height) {
            visible_north = false;
            break;
        }
    }
    // Check south
    row = coord.row;
    while (row < max_row) : (row += 1) {
        if (grid.get(Coord{ .row = row + 1, .col = coord.col }).?.height >= height) {
            visible_south = false;
            break;
        }
    }
    // Check west
    var col = coord.col;
    while (col > 0) : (col -= 1) {
        if (grid.get(Coord{ .row = coord.row, .col = col - 1 }).?.height >= height) {
            visible_west = false;
            break;
        }
    }
    // Check east
    col = coord.col;
    while (col < max_col) : (col += 1) {
        if (grid.get(Coord{ .row = coord.row, .col = col + 1 }).?.height >= height) {
            visible_east = false;
        }
    }
    var visible: bool = visible_north or visible_south or visible_east or visible_west;
    grid.getPtr(coord).?.visible = visible;
    return visible;
}

fn getGridMax(grid: *std.AutoHashMap(Coord, Tree)) Coord {
    // Get grid size
    var max_col: usize = 0;
    var max_row: usize = 0;
    var it = grid.keyIterator();
    while (it.next()) |key| {
        if (key.col > max_col) {
            max_col = key.col;
        }
        if (key.row > max_row) {
            max_row = key.row;
        }
    }
    return Coord{ .row = max_row, .col = max_col };
}

fn getScenicScore(coord: Coord, grid: *std.AutoHashMap(Coord, Tree), max_row: usize, max_col: usize) usize {
    var height = grid.get(coord).?.height;
    // North
    var row = coord.row;
    var view_north: usize = 0;
    while (row > 0) : (row -= 1) {
        if (grid.get(Coord{ .row = row - 1, .col = coord.col }).?.height < height) {
            // Visible!
            view_north += 1;
        } else {
            view_north += 1;
            break;
        }
    }
    // South
    row = coord.row;
    var view_south: usize = 0;
    while (row < max_row) : (row += 1) {
        if (grid.get(Coord{ .row = row + 1, .col = coord.col }).?.height < height) {
            // Visible!
            view_south += 1;
        } else {
            view_south += 1;
            break;
        }
    }
    // West
    var col = coord.col;
    var view_west: usize = 0;
    while (col > 0) : (col -= 1) {
        if (grid.get(Coord{ .row = coord.row, .col = col - 1 }).?.height < height) {
            // Visible!
            view_west += 1;
        } else {
            view_west += 1;
            break;
        }
    }
    // East
    col = coord.col;
    var view_east: usize = 0;
    while (col < max_col) : (col += 1) {
        if (grid.get(Coord{ .row = coord.row, .col = col + 1 }).?.height < height) {
            // Visible!
            view_east += 1;
        } else {
            view_east += 1;
            break;
        }
    }

    return view_north * view_south * view_east * view_west;
}

pub fn partA(allocator: std.mem.Allocator) !u64 {
    const input = comptime inputText();
    var grid = try parseInput(allocator, input);
    var max = getGridMax(&grid);
    var max_row = max.row;
    var max_col = max.col;
    var sum: usize = 0;

    var row: usize = 0;
    while (row <= max_row) : (row += 1) {
        var col: usize = 0;
        while (col <= max_col) : (col += 1) {
            var visible = isTreeVisible(Coord{ .row = row, .col = col }, &grid, max_row, max_col);
            if (visible) {
                sum += 1;
            }
        }
    }
    return sum;
}

pub fn partB(allocator: std.mem.Allocator) !u64 {
    const input = comptime inputText();
    var grid = try parseInput(allocator, input);
    var max = getGridMax(&grid);
    var max_row = max.row;
    var max_col = max.col;
    var max_score: usize = 0;
    var row: usize = 0;
    while (row <= max_row) : (row += 1) {
        var col: usize = 0;
        while (col <= max_col) : (col += 1) {
            var score = getScenicScore(Coord{ .row = row, .col = col }, &grid, max_row, max_col);
            if (score > max_score) {
                max_score = score;
            }
        }
    }
    return max_score;
}
