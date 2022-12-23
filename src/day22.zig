const std = @import("std");
const constants = @import("constants.zig");
// const trace = @import("tracy.zig").trace;

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day22.txt");
    } else {
        return @embedFile("real_inputs/day22.txt");
    }
}

const Coord = struct {
    row: isize,
    col: isize,
};

const Tile = enum {
    void,
    open,
    wall,
};

const Grid = struct {
    tiles: std.AutoHashMap(Coord, Tile),

    fn init(alloc: std.mem.Allocator) Grid {
        // const tracy = trace(@src());
        // defer tracy.end();
        return Grid{ .tiles = std.AutoHashMap(Coord, Tile).init(alloc) };
    }

    fn deinit(self: *Grid) void {
        // const tracy = trace(@src());
        // defer tracy.end();
        self.tiles.deinit();
    }

    fn get(self: *Grid, row: isize, col: isize) Tile {
        // const tracy = trace(@src());
        // defer tracy.end();
        if (self.tiles.get(Coord{ .row = row, .col = col }) != null) {
            return self.tiles.get(Coord{ .row = row, .col = col }).?;
        }
        {
            return Tile.void;
        }
    }

    fn parse(self: *Grid, input: []const u8) ![]const u8 {
        // const tracy = trace(@src());
        // defer tracy.end();
        // Will parse the grid, and return the instructions to be parsed by agent
        var parts = std.mem.split(u8, input, "\n\n");
        var grid = parts.next().?;
        var instructions = parts.next().?;

        var row: isize = 0;
        var col: isize = 0;

        var lines = std.mem.tokenize(u8, grid, "\r\n");
        while (lines.next()) |line| {
            col = 0;
            for (line) |c| {
                const coord = Coord{ .row = row, .col = col };
                try switch (c) {
                    ' ' => self.tiles.put(coord, Tile.void),
                    '.' => self.tiles.put(coord, Tile.open),
                    '#' => self.tiles.put(coord, Tile.wall),
                    else => unreachable,
                };
                col += 1;
            }
            row += 1;
        }

        return instructions;
    }

    fn startingCoord(self: *Grid) Coord {
        // const tracy = trace(@src());
        // defer tracy.end();
        var col: isize = 0;
        while (true) {
            if (self.get(0, col) == Tile.open) {
                return Coord{ .row = 0, .col = col };
            }
            col += 1;
        }
    }
};

const Agent = struct {
    loc: Coord,
    dir: u2, // 0 for right, 1 for down, 2 for left, 3 for right
    instructions: []const u8,

    fn init(grid: *Grid, instructions: []const u8) Agent {
        // const tracy = trace(@src());
        // defer tracy.end();
        return Agent{
            .loc = grid.startingCoord(),
            .dir = 0,
            .instructions = instructions,
        };
    }

    fn getNextInt(self: *Agent) !usize {
        // const tracy = trace(@src());
        // defer tracy.end();
        var i: usize = 0;
        while (i < self.instructions.len and self.instructions[i] != 'L' and self.instructions[i] != 'R') : (i += 1) {}
        var int_part = self.instructions[0..i];
        var int = try std.fmt.parseInt(usize, int_part, 10);
        self.instructions = self.instructions[i..];
        return int;
    }

    fn getNextTurn(self: *Agent) u8 {
        // const tracy = trace(@src());
        // defer tracy.end();
        const c = self.instructions[0];
        self.instructions = self.instructions[1..];
        return c;
    }

    fn followInstructions(self: *Agent, grid: *Grid, part_b: bool) !void {
        // const tracy = trace(@src());
        // defer tracy.end();
        while (self.instructions.len > 0) {
            var step_count = try self.getNextInt();
            // std.log.debug("Moving {} steps forward", .{step_count});
            var i: usize = 0;
            while (i < step_count) : (i += 1) {
                self.moveForward(grid, part_b);
            }
            if (self.instructions.len > 0) {
                var turn = self.getNextTurn();
                // std.log.debug("Turning {c}", .{turn});
                if (turn == 'R') {
                    _ = @addWithOverflow(u2, self.dir, 1, &self.dir);
                } else if (turn == 'L') {
                    _ = @subWithOverflow(u2, self.dir, 1, &self.dir);
                }
            }
        }
    }

    fn moveForward(self: *Agent, grid: *Grid, part_b: bool) void {
        // const tracy = trace(@src());
        // defer tracy.end();
        var next_coord: Coord = switch (self.dir) {
            0 => Coord{ .row = self.loc.row, .col = self.loc.col + 1 },
            1 => Coord{ .row = self.loc.row + 1, .col = self.loc.col },
            2 => Coord{ .row = self.loc.row, .col = self.loc.col - 1 },
            3 => Coord{ .row = self.loc.row - 1, .col = self.loc.col },
        };

        switch (grid.get(next_coord.row, next_coord.col)) {
            Tile.open => self.loc = next_coord,
            Tile.wall => {},
            Tile.void => if (!part_b) self.wrapAround(grid) else {
                if (constants.TESTING) {
                    self.crossCornerTest(grid);
                } else {
                    self.crossCorner(grid);
                }
            },
        }
    }

    fn onEdge(self: *Agent, row_low: isize, row_high: isize, col_low: isize, col_high: isize, dir: u2) bool {
        // const tracy = trace(@src());
        // defer tracy.end();
        if (self.loc.row >= row_low and self.loc.row <= row_high and self.loc.col >= col_low and self.loc.col <= col_high and self.dir == dir) {
            return true;
        } else {
            return false;
        }
    }

    fn dest(self: *Agent, new_row: isize, new_col: isize, new_dir: u2, grid: *Grid) void {
        // const tracy = trace(@src());
        // defer tracy.end();
        if (grid.get(new_row, new_col) == Tile.open) {
            self.dir = new_dir;
            self.loc.row = new_row;
            self.loc.col = new_col;
        }
    }

    fn crossCornerTest(self: *Agent, grid: *Grid) void {
        // const tracy = trace(@src());
        // defer tracy.end();
        // std.log.debug("Crossing corner!: {any} {}", .{ self.loc, self.dir });
        // 1 north
        if (self.onEdge(0, 0, 8, 11, 3)) {
            // going to 2 north
            self.dest(11 - self.loc.col, 4, 1, grid);
        }
        // 1 west
        else if (self.onEdge(0, 3, 8, 8, 2)) {
            // going to 3 north
            self.dest(4, self.loc.row + 4, 3, grid);
        }
        // 3 north
        else if (self.onEdge(4, 4, 4, 7, 3)) {
            // going to 1 west
            self.dest(self.loc.col - 4, 8, 0, grid);
        }
        // 2 north
        else if (self.onEdge(4, 4, 0, 3, 3)) {
            // going to 1 north
            self.dest(0, 3 - self.loc.col + 8, 1, grid);
        }
        // 2 west
        else if (self.onEdge(4, 7, 0, 0, 2)) {
            // going to 6 south
            self.dest(11, 7 - self.loc.row + 12, 3, grid);
        }
        // 2 south
        else if (self.onEdge(7, 7, 0, 3, 1)) {
            // going to 5 south
            self.dest(11, 3 - self.loc.col + 8, 3, grid);
        }
        // 3 south
        else if (self.onEdge(7, 7, 4, 7, 1)) {
            // going to 5 west
            self.dest(7 - self.loc.col + 8, 8, 0, grid);
        }
        // 5 west
        else if (self.onEdge(8, 11, 8, 8, 2)) {
            // going to 3 south
            self.dest(7, 11 - self.loc.row + 4, 3, grid);
        }
        // 5 south
        else if (self.onEdge(11, 11, 8, 11, 1)) {
            // going to 2 south
            self.dest(7, 11 - self.loc.col, 3, grid);
        }
        // 6 south
        else if (self.onEdge(11, 11, 12, 15, 1)) {
            // going to 2 west
            self.dest(15 - self.loc.col + 4, 0, 0, grid);
        }
        // 6 east
        else if (self.onEdge(8, 11, 15, 15, 0)) {
            // going to 1 east
            self.dest(11 - self.loc.row, 11, 2, grid);
        }
        // 6 north
        else if (self.onEdge(8, 8, 12, 15, 3)) {
            // going to 4 east
            self.dest(15 - self.loc.col + 4, 11, 2, grid);
        }
        // 4 east
        else if (self.onEdge(4, 7, 11, 11, 0)) {
            // going to 6 north
            self.dest(8, 7 - self.loc.row + 12, 1, grid);
        }
        // 1 east
        else if (self.onEdge(0, 3, 11, 11, 0)) {
            // going to 6 east
            self.dest(3 - self.loc.row + 8, 15, 2, grid);
        } else {
            std.log.err("Unreachable!", .{});
            unreachable;
        }
        // std.log.debug("Crossed corner!: {any}, {}", .{ self.loc, self.dir });
    }

    fn crossCorner(self: *Agent, grid: *Grid) void {
        // const tracy = trace(@src());
        // defer tracy.end();
        // std.log.debug("Crossing corner!: {any} {}", .{ self.loc, self.dir });
        // 1 north
        if (self.onEdge(0, 0, 50, 99, 3)) {
            // going to 6 west
            self.dest(self.loc.col + 100, 0, 0, grid);
        }
        // 1 west
        else if (self.onEdge(0, 49, 50, 50, 2)) {
            // going to 4 west
            self.dest(49 - self.loc.row + 100, 0, 0, grid);
        }
        // 3 west
        else if (self.onEdge(50, 99, 50, 50, 2)) {
            // going to 4 north
            self.dest(100, self.loc.row - 50, 1, grid);
        }
        // 4 north
        else if (self.onEdge(100, 100, 0, 49, 3)) {
            // going to 3 west
            self.dest(self.loc.col + 50, 50, 0, grid);
        }
        // 4 west
        else if (self.onEdge(100, 149, 0, 0, 2)) {
            // going to 1 west
            self.dest(149 - self.loc.row, 50, 0, grid);
        }
        // 6 west
        else if (self.onEdge(150, 199, 0, 0, 2)) {
            // going to 1 north
            self.dest(0, self.loc.row - 100, 1, grid);
        }
        // 6 south
        else if (self.onEdge(199, 199, 0, 49, 1)) {
            // going to 2 north
            self.dest(0, self.loc.col + 100, 1, grid);
        }
        // 6 east
        else if (self.onEdge(150, 199, 49, 49, 0)) {
            // going to 5 south
            self.dest(149, self.loc.row - 100, 3, grid);
        }
        // 5 south
        else if (self.onEdge(149, 149, 50, 99, 1)) {
            // going to 6 east
            self.dest(self.loc.col + 100, 49, 2, grid);
        }
        // 5 east
        else if (self.onEdge(100, 149, 99, 99, 0)) {
            // going to 2 east
            self.dest(149 - self.loc.row, 149, 2, grid);
        }
        // 3 east
        else if (self.onEdge(50, 99, 99, 99, 0)) {
            // going to 2 south
            self.dest(49, self.loc.row + 50, 3, grid);
        }
        // 2 south
        else if (self.onEdge(49, 49, 100, 149, 1)) {
            // going to 3 east
            self.dest(self.loc.col - 50, 99, 2, grid);
        }
        // 2 east
        else if (self.onEdge(0, 49, 149, 149, 0)) {
            // going to 5 east
            self.dest(49 - self.loc.row + 100, 99, 2, grid);
        }
        // 2 north
        else if (self.onEdge(0, 0, 100, 149, 3)) {
            // going to 6 south
            self.dest(199, self.loc.col - 100, 3, grid);
        } else {
            std.log.err("Unreachhable!", .{});
            unreachable;
        }
    }

    fn wrapAround(self: *Agent, grid: *Grid) void {
        // const tracy = trace(@src());
        // defer tracy.end();
        while (grid.get(self.loc.row, self.loc.col) != Tile.void) {
            switch (self.dir) {
                0 => self.loc.col -= 1,
                1 => self.loc.row -= 1,
                2 => self.loc.col += 1,
                3 => self.loc.row += 1,
            }
        }
        // We've moved into the void. Go back a step
        switch (self.dir) {
            0 => self.loc.col += 1,
            1 => self.loc.row += 1,
            2 => self.loc.col -= 1,
            3 => self.loc.row -= 1,
        }
    }
};

pub fn partA(allocator: std.mem.Allocator) !i64 {
    // const tracy = trace(@src());
    // defer tracy.end();
    const input = comptime inputText();
    var grid = Grid.init(allocator);
    defer grid.deinit();
    var instructions = try grid.parse(input);
    var agent = Agent.init(&grid, instructions);
    try agent.followInstructions(&grid, false);
    std.log.debug("location: {any}", .{agent.loc});
    return (agent.loc.row + 1) * 1000 + (agent.loc.col + 1) * 4 + agent.dir;
}

pub fn partB(allocator: std.mem.Allocator) !i64 {
    // const tracy = trace(@src());
    // defer tracy.end();
    const input = comptime inputText();
    var grid = Grid.init(allocator);
    defer grid.deinit();
    var instructions = try grid.parse(input);
    var agent = Agent.init(&grid, instructions);
    try agent.followInstructions(&grid, true);
    std.log.debug("location: {any}", .{agent.loc});
    return (agent.loc.row + 1) * 1000 + (agent.loc.col + 1) * 4 + agent.dir;
}
