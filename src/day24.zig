const std = @import("std");
const constants = @import("constants.zig");
// const trace = @import("tracy.zig").trace;

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day24.txt");
    } else {
        return @embedFile("real_inputs/day24.txt");
    }
}

const Blizzard = struct {
    row: usize,
    col: usize,
    dir: u2,
};

const Node = struct {
    row: usize,
    col: usize,
    t: usize,
    weight: usize,
};

const Valley = struct {
    width: usize,
    height: usize,
    t: usize,
    entrance_col: usize,
    exit_col: usize,
    blizzards: std.ArrayList(Blizzard),
    nodes: *std.AutoHashMap(Node, void),
    allocator: std.mem.Allocator,

    fn deinit(self: *Valley) void {
        self.blizzards.deinit();
    }

    fn clone(self: *Valley) Valley {
        var cloned_blizzards = std.ArrayList(Blizzard).init(self.allocator);
        for (self.blizzards.items) |item| {
            cloned_blizzards.append(item);
        }
        return Valley{
            .width = self.width,
            .t = self.t,
            .height = self.height,
            .entrance_col = self.entrance_col,
            .exit_col = self.exit_col,
            .blizzards = cloned_blizzards,
            .nodes = self.nodes,
            .allocator = self.allocator,
        };
    }

    fn init(allocator: std.mem.Allocator, nodes: *std.AutoHashMap(Node, void), input: []const u8) !Valley {
        var lines = std.mem.tokenize(u8, input, "\r\n");
        var width: usize = 0;
        var height: usize = 0;
        var last_line: []const u8 = "";
        var entrance_col: usize = 0;
        var exit_col: usize = 0;
        var blizzards = std.ArrayList(Blizzard).init(allocator);

        while (lines.next()) |line| {
            last_line = line;
            width = line.len;

            if (height == 0) {
                var col: usize = 0;
                for (line) |c| {
                    if (c == '.') {
                        entrance_col = col;
                        break;
                    }
                    col += 1;
                }
            }

            var col: usize = 0;
            for (line) |c| {
                switch (c) {
                    '>' => {
                        var bliz = Blizzard{ .row = height, .col = col, .dir = 0 };
                        try blizzards.append(bliz);
                    },
                    'v' => {
                        var bliz = Blizzard{ .row = height, .col = col, .dir = 1 };
                        try blizzards.append(bliz);
                    },
                    '<' => {
                        var bliz = Blizzard{ .row = height, .col = col, .dir = 2 };
                        try blizzards.append(bliz);
                    },
                    '^' => {
                        var bliz = Blizzard{ .row = height, .col = col, .dir = 3 };
                        try blizzards.append(bliz);
                    },
                    else => {},
                }
                col += 1;
            }

            height += 1;
        }
        var col: usize = 0;
        for (last_line) |c| {
            if (c == '.') {
                exit_col = col;
                break;
            }
            col += 1;
        }

        return Valley{
            .width = width,
            .height = height,
            .t = 0,
            .entrance_col = entrance_col,
            .exit_col = exit_col,
            .blizzards = blizzards,
            .nodes = nodes,
            .allocator = allocator,
        };
    }

    fn debug(self: *const Valley) void {
        var area: usize = (self.width + 1) * self.height;
        var debugstr: [1000]u8 = std.mem.zeroes([1000]u8);
        var i: usize = 0;
        while (i < area) : (i += 1) {
            debugstr[i] = '.';
            if (i < self.width and i != self.entrance_col) {
                // First row
                debugstr[i] = '#';
            } else if (i > (self.width + 1) * (self.height - 1) - 1 and (i % self.width + 1) != self.exit_col) {
                debugstr[i] = '#';
            }
            if (i % (self.width + 1) == 0 or i % (self.width + 1) == self.width - 1) {
                debugstr[i] = '#';
            }
            if (i % (self.width + 1) == self.width) {
                debugstr[i] = '\n';
            }
        }
        for (self.blizzards.items) |b| {
            var coord = b.row * (self.width + 1) + b.col;
            switch (b.dir) {
                0 => debugstr[coord] = '>',
                1 => debugstr[coord] = 'v',
                2 => debugstr[coord] = '<',
                3 => debugstr[coord] = '^',
            }
        }
        std.debug.print("{s}", .{debugstr[0..area]});
    }

    fn step(self: *Valley) void {
        var c: usize = 0;
        while (c < self.blizzards.items.len) : (c += 1) {
            var bliz: *Blizzard = &self.blizzards.items[c];
            switch (bliz.dir) {
                0 => bliz.*.col += 1,
                1 => bliz.*.row += 1,
                2 => bliz.*.col -= 1,
                3 => bliz.*.col -= 1,
            }

            if (bliz.col == self.width - 1) {
                bliz.*.col = 1;
            } else if (bliz.col == 0) {
                bliz.*.col = self.width - 2;
            } else if (bliz.row == self.height - 1) {
                bliz.*.row = 1;
            } else if (bliz.row == 0) {
                bliz.*.row = self.height - 2;
            }
        }
    }

    fn solve(self: *Valley, row: usize, col: usize) usize {
        _ = col;
        _ = row;
        _ = self;
        return 1;
    }
};

pub fn partA(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var nodes = std.AutoHashMap(Node, void).init(allocator);
    var valley: Valley = try Valley.init(allocator, &nodes, input);
    defer valley.deinit();

    valley.debug();
    std.log.debug("==============", .{});
    valley.step();
    valley.debug();
    std.log.debug("==============", .{});
    valley.step();
    valley.debug();
    std.log.debug("==============", .{});
    valley.step();
    valley.debug();
    std.log.debug("==============", .{});
    valley.step();
    valley.debug();
    std.log.debug("==============", .{});
    valley.step();
    valley.debug();
    return 1;
}

pub fn partB(allocator: std.mem.Allocator) !usize {
    _ = allocator;
    return 1;
}
