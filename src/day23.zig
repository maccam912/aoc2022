const std = @import("std");
const constants = @import("constants.zig");
// const trace = @import("tracy.zig").trace;

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day23.txt");
    } else {
        return @embedFile("real_inputs/day23.txt");
    }
}

const Coord = struct {
    row: i64,
    col: i64,
};

const Elf = struct {
    loc: Coord,
    proposal: ?Coord,
    idle: bool,

    fn new(coord: Coord) Elf {
        return Elf{ .loc = coord, .proposal = null, .idle = false };
    }

    fn hasNeighborsNorth(self: *const Elf, map: *const std.AutoHashMap(Coord, void)) bool {
        const coord_a = Coord{ .row = self.loc.row - 1, .col = self.loc.col - 1 };
        const coord_b = Coord{ .row = self.loc.row - 1, .col = self.loc.col };
        const coord_c = Coord{ .row = self.loc.row - 1, .col = self.loc.col + 1 };

        if (map.get(coord_a) != null or map.get(coord_b) != null or map.get(coord_c) != null) {
            return true;
        } else {
            return false;
        }
    }
    fn hasNeighborsSouth(self: *const Elf, map: *const std.AutoHashMap(Coord, void)) bool {
        const coord_a = Coord{ .row = self.loc.row + 1, .col = self.loc.col - 1 };
        const coord_b = Coord{ .row = self.loc.row + 1, .col = self.loc.col };
        const coord_c = Coord{ .row = self.loc.row + 1, .col = self.loc.col + 1 };

        if (map.get(coord_a) != null or map.get(coord_b) != null or map.get(coord_c) != null) {
            return true;
        } else {
            return false;
        }
    }
    fn hasNeighborsWest(self: *const Elf, map: *const std.AutoHashMap(Coord, void)) bool {
        const coord_a = Coord{ .row = self.loc.row - 1, .col = self.loc.col - 1 };
        const coord_b = Coord{ .row = self.loc.row, .col = self.loc.col - 1 };
        const coord_c = Coord{ .row = self.loc.row + 1, .col = self.loc.col - 1 };

        if (map.get(coord_a) != null or map.get(coord_b) != null or map.get(coord_c) != null) {
            return true;
        } else {
            return false;
        }
    }
    fn hasNeighborsEast(self: *const Elf, map: *const std.AutoHashMap(Coord, void)) bool {
        const coord_a = Coord{ .row = self.loc.row - 1, .col = self.loc.col + 1 };
        const coord_b = Coord{ .row = self.loc.row, .col = self.loc.col + 1 };
        const coord_c = Coord{ .row = self.loc.row + 1, .col = self.loc.col + 1 };

        if (map.get(coord_a) != null or map.get(coord_b) != null or map.get(coord_c) != null) {
            return true;
        } else {
            return false;
        }
    }

    fn hasNeighbors(self: *const Elf, map: *const std.AutoHashMap(Coord, void)) bool {
        return (self.hasNeighborsNorth(map) or self.hasNeighborsSouth(map) or self.hasNeighborsEast(map) or self.hasNeighborsWest(map));
    }
};

fn debug(elves: *std.ArrayList(Elf)) !void {
    var min_row: isize = std.math.maxInt(isize);
    var min_col: isize = std.math.maxInt(isize);
    var max_row: isize = std.math.minInt(isize);
    var max_col: isize = std.math.minInt(isize);
    var elf_coords = try elfCoords(elves.allocator, elves);
    var it = elf_coords.keyIterator();
    var num_coords: usize = 0;
    while (it.next()) |item| {
        min_row = @min(item.row, min_row);
        min_col = @min(item.col, min_col);
        max_row = @max(item.row, max_row);
        max_col = @max(item.col, max_col);
        num_coords += 1;
    }

    var map: std.AutoHashMap(Coord, void) = try elfCoords(elves.allocator, elves);
    defer map.deinit();
    var row: isize = min_row;
    while (row <= max_row) : (row += 1) {
        var col: isize = min_col;
        while (col <= max_col) : (col += 1) {
            var val = map.get(Coord{ .row = row, .col = col });
            if (val != null) {
                std.debug.print("#", .{});
            } else {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("==============\n", .{});
}

fn elfCoords(allocator: std.mem.Allocator, elves: *const std.ArrayList(Elf)) !std.AutoHashMap(Coord, void) {
    var result = std.AutoHashMap(Coord, void).init(allocator);
    for (elves.items) |elf| {
        try result.put(elf.loc, {});
    }
    return result;
}

fn emptyTiles(elf_coords: *const std.AutoHashMap(Coord, void)) usize {
    var min_row: isize = std.math.maxInt(isize);
    var min_col: isize = std.math.maxInt(isize);
    var max_row: isize = std.math.minInt(isize);
    var max_col: isize = std.math.minInt(isize);
    var it = elf_coords.keyIterator();
    var num_coords: usize = 0;
    while (it.next()) |item| {
        min_row = @min(item.row, min_row);
        min_col = @min(item.col, min_col);
        max_row = @max(item.row, max_row);
        max_col = @max(item.col, max_col);
        num_coords += 1;
    }

    std.log.debug("{} {} {} {}", .{ min_row, max_row, min_col, max_col });
    var area = (max_row - min_row + 1) * (max_col - min_col + 1);

    var sum: usize = 0;
    var orig_min_col = min_col;
    while (min_row <= max_row) : (min_row += 1) {
        min_col = orig_min_col;
        while (min_col <= max_col) : (min_col += 1) {
            if (elf_coords.contains(Coord{ .row = min_row, .col = min_col })) {
                // dont add
            } else {
                sum += 1;
            }
        }
    }

    if (sum != area - @intCast(isize, num_coords)) {
        unreachable;
    }
    return sum;
}

fn run(allocator: std.mem.Allocator, elves: *std.ArrayList(Elf)) !void {
    var step: usize = 0;
    while (step < 11) : (step += 1) {
        var elf_coords: std.AutoHashMap(Coord, void) = try elfCoords(allocator, elves);
        defer elf_coords.deinit();
        std.log.debug("Step {}", .{step});
        var count: usize = 0;
        while (count < elves.items.len) : (count += 1) {
            var elf: *Elf = &elves.items[count];
            if (elf.hasNeighbors(&elf_coords)) {
                // Will propose new location
                var n = elf.hasNeighborsNorth(&elf_coords);
                var s = elf.hasNeighborsSouth(&elf_coords);
                var w = elf.hasNeighborsWest(&elf_coords);
                var e = elf.hasNeighborsEast(&elf_coords);
                var directions: [4]bool = [4]bool{ n, s, w, e };
                var i: usize = 0;
                while (i < 4) : (i += 1) {
                    var step_mod: usize = (i + step) % 4;
                    if (!directions[step_mod]) {
                        //propose direction that way
                        elf.*.proposal = switch (step_mod) {
                            0 => Coord{ .row = elf.*.loc.row - 1, .col = elf.*.loc.col },
                            1 => Coord{ .row = elf.*.loc.row + 1, .col = elf.*.loc.col },
                            2 => Coord{ .row = elf.*.loc.row, .col = elf.*.loc.col - 1 },
                            3 => Coord{ .row = elf.*.loc.row, .col = elf.*.loc.col + 1 },
                            else => unreachable,
                        };
                        break;
                    }
                }
            }
        }
        var count2: usize = 0;
        while (count2 < elves.items.len) : (count2 += 1) {
            var elf: *Elf = &elves.items[count2];
            // std.log.debug("At {any}, propsal: {any}", .{elf.loc, elf.proposal});
            var sum: usize = 0;
            if (elf.proposal != null) {
                for (elves.items) |elf2| {
                    if (elf2.proposal != null and elf2.proposal.?.row == elf.proposal.?.row and elf2.proposal.?.col == elf.proposal.?.col) {
                        sum += 1;
                    }
                }
            }
            if (sum == 1) {
                // Singular propsal. Moving
                // std.log.debug("Only proposal here, moving...", .{});
                elf.*.loc = elf.*.proposal.?;
            }
        }
        try debug(elves);
        var elf_coords_2: std.AutoHashMap(Coord, void) = try elfCoords(allocator, elves);
        defer elf_coords_2.deinit();
        std.log.debug("Empty tiles: {}", .{emptyTiles(&elf_coords_2)});
    }
}

fn runB(allocator: std.mem.Allocator, elves: *std.ArrayList(Elf)) !usize {
    var step: usize = 0;
    var prev_num_moved: usize = 1;
    while (prev_num_moved != 0) : (step += 1) {
        prev_num_moved = 0;
        var elf_coords: std.AutoHashMap(Coord, void) = try elfCoords(allocator, elves);
        defer elf_coords.deinit();
        std.log.err("Step {}", .{step});
        var count: usize = 0;
        while (count < elves.items.len) : (count += 1) {
            var elf: *Elf = &elves.items[count];
            elf.*.proposal = null;
            if (elf.hasNeighbors(&elf_coords)) {
                // Will propose new location
                var n = elf.hasNeighborsNorth(&elf_coords);
                var s = elf.hasNeighborsSouth(&elf_coords);
                var w = elf.hasNeighborsWest(&elf_coords);
                var e = elf.hasNeighborsEast(&elf_coords);
                var directions: [4]bool = [4]bool{ n, s, w, e };
                var i: usize = 0;
                while (i < 4) : (i += 1) {
                    var step_mod: usize = (i + step) % 4;
                    if (!directions[step_mod]) {
                        //propose direction that way
                        elf.*.proposal = switch (step_mod) {
                            0 => Coord{ .row = elf.*.loc.row - 1, .col = elf.*.loc.col },
                            1 => Coord{ .row = elf.*.loc.row + 1, .col = elf.*.loc.col },
                            2 => Coord{ .row = elf.*.loc.row, .col = elf.*.loc.col - 1 },
                            3 => Coord{ .row = elf.*.loc.row, .col = elf.*.loc.col + 1 },
                            else => unreachable,
                        };
                        break;
                    }
                }
            }
        }
        var count2: usize = 0;
        while (count2 < elves.items.len) : (count2 += 1) {
            var elf: *Elf = &elves.items[count2];
            // std.log.debug("At {any}, propsal: {any}", .{elf.loc, elf.proposal});
            var sum: usize = 0;
            if (elf.proposal != null) {
                for (elves.items) |elf2| {
                    if (elf2.proposal != null and elf2.proposal.?.row == elf.proposal.?.row and elf2.proposal.?.col == elf.proposal.?.col) {
                        sum += 1;
                    }
                }
            }
            if (sum == 1) {
                // Singular propsal. Moving
                // std.log.debug("Only proposal here, moving...", .{});
                elf.*.loc = elf.*.proposal.?;
                prev_num_moved += 1;
            }
        }
        try debug(elves);
        var elf_coords_2: std.AutoHashMap(Coord, void) = try elfCoords(allocator, elves);
        defer elf_coords_2.deinit();
        std.log.debug("Empty tiles: {}", .{emptyTiles(&elf_coords_2)});
        std.log.debug("Prev num moved: {}", .{prev_num_moved});
    }
    try debug(elves);
    return step;
}

fn parseInput(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(Elf) {
    var result = std.ArrayList(Elf).init(allocator);
    var row: isize = 0;
    var lines = std.mem.tokenize(u8, input, "\r\n");
    while (lines.next()) |line| {
        var col: isize = 0;
        for (line) |c| {
            if (c == '#') {
                var coord = Coord{ .row = row, .col = col };
                var elf = Elf.new(coord);
                try result.append(elf);
            }
            col += 1;
        }
        row += 1;
    }
    return result;
}

pub fn partA(allocator: std.mem.Allocator) !u64 {
    const input = comptime inputText();
    var elves: std.ArrayList(Elf) = try parseInput(allocator, input);
    try run(allocator, &elves);
    var elf_coords = try elfCoords(allocator, &elves);
    var result = emptyTiles(&elf_coords);
    return result;
}

pub fn partB(allocator: std.mem.Allocator) !u64 {
    const input = comptime inputText();
    var elves: std.ArrayList(Elf) = try parseInput(allocator, input);
    var num_steps = try runB(allocator, &elves);
    return num_steps;
}
