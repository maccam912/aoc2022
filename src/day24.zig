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

const MAX_DEPTH=100;

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
        var debugstr: [1000]u8 = std.mem.zeroes([1000]u8);
        var i: usize = 0;
        while (i < area) : (i += 1) {
            debugstr[i] = '.';
            if (i < self.width and i != self.entrance_col) {
                // First row
                debugstr[i] = '#';
            }
            if (i >= (self.width+1)*(self.height-1)) {
                debugstr[i] = '#';
            }
            var exit_loc = (self.width+1)*(self.height-1)+self.exit_col;
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
        self.t += 1;
    }
    
    fn getBlizzardSquares(self: *const Valley) !std.AutoHashMap([2]usize, void) {
        var result = std.AutoHashMap([2]usize, void).init(self.allocator);
        for (self.blizzards.items) |bliz| {
            try result.put([2]usize{bliz.row, bliz.col}, {});
        }
        return result;
    }

    fn updateVisited(visited: *std.AutoHashMap([3]usize, Node), row: usize, col: usize, t: usize, n: Node) !void {
        if (visited.get([3]usize{row, col, t})) |existing| {
            if (n.weight < existing.weight) {
                try visited.put([3]usize{row, col, t}, n);
                return;
            } else {
                // Better one already there
                return;
            }
        } else {
            try visited.put([3]usize{row, col, t}, n);
            return;
        }
    }

    fn solve(self: *Valley, row: usize, col: usize, curr_weight: usize, global_best: *usize, visited: *std.AutoHashMap([3]usize, Node)) !Node {
        std.log.debug("Calling solve. row {} col {} Timestep is {}, weight is {}, global best is {}", .{row, col, self.t, curr_weight, global_best.*});

        var already_seen = visited.get([3]usize{row, col, self.t});
        if (already_seen != null) {
            return already_seen.?;
        }

        if (row == self.height-1 and col == self.exit_col) {
            std.log.debug("At an exit! curr_weight {}", .{curr_weight});
            if (curr_weight < global_best.*) {
                global_best.* = curr_weight;
            }
            var retval = Node{.row = row, .col = col, .t = self.t, .weight = curr_weight};
            std.log.debug("Returning {any}", .{retval});
            std.process.exit(0);
            try visited.put([3]usize{row, col, self.t}, retval);
            return retval;
        }

        _ = self.step();
        var next_blizzard_squares = try self.getBlizzardSquares();

        var best_node = Node{.row = row, .col = col, .t = self.t, .weight = std.math.maxInt(usize)-2};
        var best_possible_score = curr_weight+((self.height-1)-row)+std.math.absCast(@intCast(isize, self.exit_col)-@intCast(isize, col));

        if (row < self.height-2 or (row < self.height-1 and col == self.exit_col)) {
            // Sometimes open space below, check down one
            var down_square = [2]usize{row+1, col};
            if (!next_blizzard_squares.contains(down_square)) {
                // Square is open next step! 
                var this_clone: Valley = try self.clone();
                var best_down_path = try this_clone.solve(row+1, col, curr_weight+1, global_best, visited);
                this_clone.deinit();
                if (best_down_path.weight < best_node.weight) {
                    best_node = best_down_path;
                }
            }
        }

        if (best_node.weight+1 > best_possible_score and col < self.width-2) {
            var right_square = [2]usize{row, col+1};
            if (!next_blizzard_squares.contains(right_square)) {
                // Square is open next step! 
                var this_clone: Valley = try self.clone();
                var best_right_path = try this_clone.solve(row, col+1, curr_weight+1, global_best, visited);
                this_clone.deinit();
                if (best_right_path.weight < best_node.weight) {
                    best_node = best_right_path;
                }
            }
        }

        if (best_node.weight+1 > best_possible_score and col > 1) {
            var left_square = [2]usize{row, col-1};
            if (!next_blizzard_squares.contains(left_square)) {
                // Square is open next step! 
                var this_clone: Valley = try self.clone();
                var best_left_path = try this_clone.solve(row, col-1, curr_weight+1, global_best, visited);
                this_clone.deinit();
                if (best_left_path.weight < best_node.weight) {
                    best_node = best_left_path;
                }
            }
        }

        if (best_node.weight+1 > best_possible_score and row > 1 or (row > 0 and col == self.entrance_col)) {
            var up_square = [2]usize{row-1, col};
            if (!next_blizzard_squares.contains(up_square)) {
                // Square is open next step! 
                var this_clone: Valley = try self.clone();
                var best_up_path = try this_clone.solve(row-1, col, curr_weight+1, global_best, visited);
                this_clone.deinit();
                if (best_up_path.weight < best_node.weight) {
                    best_node = best_up_path;
                }
            }
        }

        if (best_node.weight+2 > best_possible_score and true) { // Check current square
            if (!next_blizzard_squares.contains([2]usize{row, col})) {
                // Square is open next step! 
                var this_clone: Valley = try self.clone();
                var best_curr_path = try this_clone.solve(row, col, curr_weight+1, global_best, visited);
                this_clone.deinit();
                if (best_curr_path.weight < best_node.weight) {
                    best_node = best_curr_path;
                }
            }
        }

        try visited.put([3]usize{row, col, self.t}, best_node);
        return best_node;
    }
};

pub fn partA(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var nodes = std.AutoHashMap(Node, void).init(allocator);
    var valley: Valley = try Valley.init(allocator, &nodes, input);
    defer valley.deinit();
    valley.debug();

    var already_visited = std.AutoHashMap([3]usize, Node).init(allocator);
    defer already_visited.deinit();

    var global_best: usize = MAX_DEPTH;
    var solved = try valley.solve(0, valley.entrance_col, 0, &global_best, &already_visited);
    std.log.debug("Solved: {any}", .{solved});

    return solved.weight;
}

pub fn partB(allocator: std.mem.Allocator) !usize {
    _ = allocator;
    return 1;
}
