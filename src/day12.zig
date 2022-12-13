const std = @import("std");
const constants = @import("constants.zig");

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day12.txt");
    } else {
        return @embedFile("real_inputs/day12.txt");
    }
}

const Coord = struct {
    row: i8,
    col: i8,

    fn north(self: *Coord) Coord {
        return Coord{ .row = self.row - 1, .col = self.col };
    }
    fn south(self: *Coord) Coord {
        return Coord{ .row = self.row + 1, .col = self.col };
    }
    fn west(self: *Coord) Coord {
        return Coord{ .row = self.row, .col = self.col - 1 };
    }
    fn east(self: *Coord) Coord {
        return Coord{ .row = self.row, .col = self.col + 1 };
    }
};

const Tile = struct {
    loc: Coord,
    height: u8,
    weight: ?u32,
};

const Map = struct {
    tiles: std.AutoHashMap(Coord, Tile),
    start: Coord,
    end: Coord,
};

fn parseInput(allocator: std.mem.Allocator, input: []const u8) !Map {
    var tiles = std.AutoHashMap(Coord, Tile).init(allocator);
    var lines = std.mem.split(u8, input, "\n");
    var start: Coord = undefined;
    var end: Coord = undefined;
    var row: i8 = 0;
    while (lines.next()) |line| {
        var col: i8 = 0;
        for (line) |c| {
            if (c == 'S') {
                start = Coord{ .row = row, .col = col };
                var tile = Tile{ .loc = start, .height = 0, .weight = null };
                try tiles.put(start, tile);
            } else if (c == 'E') {
                end = Coord{ .row = row, .col = col };
                var tile = Tile{ .loc = end, .height = 'z' - 'a', .weight = null };
                try tiles.put(end, tile);
            } else {
                var loc = Coord{ .row = row, .col = col };
                var tile = Tile{ .loc = loc, .height = c - 'a', .weight = null };
                try tiles.put(loc, tile);
            }
            col += 1;
        }
        row += 1;
    }
    return Map{ .tiles = tiles, .start = start, .end = end };
}

fn getLowestWeightCoord(list: *std.ArrayList(Coord), tiles: *std.AutoHashMap(Coord, Tile)) Coord {
    var min: u32 = std.math.maxInt(u32);
    var min_idx: usize = 0;
    var i: usize = 0;
    while (i < list.items.len) : (i += 1) {
        var coord_here: Coord = list.items[i];
        var weight_here_maybe: ?u32 = tiles.get(coord_here).?.weight;
        if (weight_here_maybe) |weight_here| {
            if (weight_here < min) {
                min = weight_here;
                min_idx = i;
            }
        }
    }
    // We have min now
    return list.orderedRemove(min_idx);
}

pub fn partA(allocator: std.mem.Allocator, alt_start_coord: ?Coord) !?u32 {
    const input = comptime inputText();
    var to_process = std.ArrayList(Coord).init(allocator);
    var details = try parseInput(allocator, input);

    if (alt_start_coord) |coord| {
        details.start = coord;
    }

    details.tiles.getPtr(details.start).?.weight = 0;

    try to_process.append(details.start);
    while (to_process.items.len > 0) {
        var curr_coord: Coord = getLowestWeightCoord(&to_process, &details.tiles);
        var i: usize = to_process.items.len;
        while (i > 0) : (i -= 1) {
            if (to_process.items[i - 1].row == curr_coord.row and to_process.items[i - 1].col == curr_coord.col) {
                _ = to_process.orderedRemove(i - 1);
            }
        }
        var curr_tile: Tile = details.tiles.get(curr_coord).?;

        var north: ?*Tile = details.tiles.getPtr(curr_coord.north());
        if (north) |tile| {
            if (tile.height <= curr_tile.height + 1 and (tile.weight == null or tile.weight.? > curr_tile.weight.? + 1)) {
                tile.weight = curr_tile.weight.? + 1;
                try to_process.append(tile.loc);
            }
        }

        var south: ?*Tile = details.tiles.getPtr(curr_coord.south());
        if (south) |tile| {
            if (tile.height <= curr_tile.height + 1 and (tile.weight == null or tile.weight.? > curr_tile.weight.? + 1)) {
                tile.weight = curr_tile.weight.? + 1;
                try to_process.append(tile.loc);
            }
        }

        var west: ?*Tile = details.tiles.getPtr(curr_coord.west());
        if (west) |tile| {
            if (tile.height <= curr_tile.height + 1 and (tile.weight == null or tile.weight.? > curr_tile.weight.? + 1)) {
                tile.weight = curr_tile.weight.? + 1;
                try to_process.append(tile.loc);
            }
        }

        var east: ?*Tile = details.tiles.getPtr(curr_coord.east());
        if (east) |tile| {
            if (tile.height <= curr_tile.height + 1 and (tile.weight == null or tile.weight.? > curr_tile.weight.? + 1)) {
                tile.weight = curr_tile.weight.? + 1;
                try to_process.append(tile.loc);
            }
        }
    }
    return details.tiles.get(details.end).?.weight;
}

pub fn partB(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var level_a = std.ArrayList(Coord).init(allocator);
    var details = try parseInput(allocator, input);
    var it = details.tiles.iterator();
    while (it.next()) |item| {
        if (item.value_ptr.height == 0) {
            try level_a.append(item.value_ptr.loc);
        }
    }

    var min_steps: usize = std.math.maxInt(usize);
    var i: usize = 0;
    for (level_a.items) |item| {
        i += 1;
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const part_a_allocator = arena.allocator();
        var score_maybe: ?u32 = (try partA(part_a_allocator, item));
        if (score_maybe) |score| {
            if (score < min_steps) {
                min_steps = score;
            }
        }
    }
    return min_steps;
}
