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

const MAX_DEPTH = 10000;

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

    fn clone(self: *Valley) !Valley {
        var cloned_blizzards = std.ArrayList(Blizzard).init(self.allocator);
        for (self.blizzards.items) |item| {
            try cloned_blizzards.append(item);
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
        var debugstr: [10000]u8 = std.mem.zeroes([10000]u8);
        var i: usize = 0;
        while (i < area) : (i += 1) {
            debugstr[i] = '.';
            if (i < self.width and i != self.entrance_col) {
                // First row
                debugstr[i] = '#';
            }
            if (i >= (self.width + 1) * (self.height - 1)) {
                debugstr[i] = '#';
            }
            var exit_loc = (self.width + 1) * (self.height - 1) + self.exit_col;
            debugstr[exit_loc] = '.';
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
                3 => bliz.*.row -= 1,
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
        self.t += 1;
    }

    fn getBlizzardSquares(self: *const Valley) !std.AutoHashMap([2]usize, void) {
        var result = std.AutoHashMap([2]usize, void).init(self.allocator);
        for (self.blizzards.items) |bliz| {
            try result.put([2]usize{ bliz.row, bliz.col }, {});
        }
        return result;
    }

    fn updateVisited(visited: *std.AutoHashMap([3]usize, Node), row: usize, col: usize, t: usize, n: Node) !void {
        if (visited.get([3]usize{ row, col, t })) |existing| {
            if (n.weight < existing.weight) {
                try visited.put([3]usize{ row, col, t }, n);
                return;
            } else {
                // Better one already there
                return;
            }
        } else {
            try visited.put([3]usize{ row, col, t }, n);
            return;
        }
    }

    fn solve(self: *Valley, reverse: bool, start_step: usize) !void {
        while (self.t < start_step) {
            self.step();
        }

        var leaves = std.AutoHashMap(Node, void).init(self.allocator);
        defer leaves.deinit();
        var visited = std.AutoHashMap(Node, void).init(self.allocator);
        defer visited.deinit();
        var new_leaves = std.AutoHashMap(Node, void).init(self.allocator);
        defer new_leaves.deinit();

        if (!reverse) {
            try leaves.put(Node{ .row = 0, .col = self.entrance_col, .t = 0, .weight = 0 }, {});
        } else {
            try leaves.put(Node{ .row = self.height - 1, .col = self.exit_col, .t = start_step, .weight = 0 }, {});
        }

        var done: bool = false;
        while (!done and self.t < MAX_DEPTH) {
            _ = self.step();
            // self.debug();
            std.log.debug("Timestep {}", .{self.t});
            var next_blizzard_squares = try self.getBlizzardSquares();
            defer next_blizzard_squares.deinit();

            // var it_debug = leaves.keyIterator();
            // while (it_debug.next()) |item| {
            //     std.log.debug("leaf: {any}", .{item});
            // }

            var it = leaves.keyIterator();
            while (it.next()) |node| {
                var row = node.row;
                var col = node.col;

                if (!reverse) {
                    if (row == self.height - 1 and col == self.exit_col) {
                        return;
                    }
                } else {
                    if (row == 0 and col == self.entrance_col) {
                        return;
                    }
                }

                // Down
                if (row < self.height - 2 or (row < self.height - 1 and col == self.exit_col)) {
                    var down_square = [2]usize{ row + 1, col };
                    if (!next_blizzard_squares.contains(down_square)) {
                        try new_leaves.put(Node{ .row = row + 1, .col = col, .t = self.t, .weight = node.weight + 1 }, {});
                    }
                }

                // Right
                if (col < self.width - 2 and (row > 0 and row < self.height - 1)) {
                    var right_square = [2]usize{ row, col + 1 };
                    if (!next_blizzard_squares.contains(right_square)) {
                        try new_leaves.put(Node{ .row = row, .col = col + 1, .t = self.t, .weight = node.weight + 1 }, {});
                    }
                }

                // Left
                if (col > 1 and (row > 0 and row < self.height - 1)) {
                    var left_square = [2]usize{ row, col - 1 };
                    if (!next_blizzard_squares.contains(left_square)) {
                        try new_leaves.put(Node{ .row = row, .col = col - 1, .t = self.t, .weight = node.weight + 1 }, {});
                    }
                }

                // Up
                if (row > 1 or (row > 0 and col == self.entrance_col)) {
                    var up_square = [2]usize{ row - 1, col };
                    if (!next_blizzard_squares.contains(up_square)) {
                        try new_leaves.put(Node{ .row = row - 1, .col = col, .t = self.t, .weight = node.weight + 1 }, {});
                    }
                }

                // Same
                if (true) {
                    if (!next_blizzard_squares.contains([2]usize{ row, col })) {
                        try new_leaves.put(Node{ .row = row, .col = col, .t = self.t, .weight = node.weight + 1 }, {});
                    }
                }
                try visited.put(node.*, {});
            }
            // Went through all current ones. Empty out leaves, move new_leaves into leaves, empty new_leaves
            leaves.clearAndFree();
            var new_leaves_it = new_leaves.keyIterator();
            while (new_leaves_it.next()) |new_leaf| {
                try leaves.put(new_leaf.*, {});
            }
            new_leaves.clearAndFree();
        }
    }
};

pub fn partA(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var nodes = std.AutoHashMap(Node, void).init(allocator);
    var valley: Valley = try Valley.init(allocator, &nodes, input);
    defer valley.deinit();
    valley.debug();

    try valley.solve(false, 0);
    return valley.t - 1;
}

pub fn partB(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var nodes = std.AutoHashMap(Node, void).init(allocator);
    var valley: Valley = try Valley.init(allocator, &nodes, input);
    defer valley.deinit();
    valley.debug();

    try valley.solve(false, 0);
    try valley.solve(true, valley.t);
    try valley.solve(false, valley.t);
    return valley.t - 1;
}
