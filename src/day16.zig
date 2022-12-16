const std = @import("std");
const constants = @import("constants.zig");

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day16.txt");
    } else {
        return @embedFile("real_inputs/day16.txt");
    }
}

// #####
// TYPES
// #####

const Node = struct {
    name: []const u8,
    flow_rate: usize,
    edges: std.ArrayList([]const u8),
    open: bool,
    allocator: std.mem.Allocator,
    visited_distance: ?usize,

    fn init(allocator: std.mem.Allocator, name: []const u8, flow_rate: usize, edges: std.ArrayList([]const u8)) !Node {
        return Node{
            .name = name,
            .visited_distance = null,
            .flow_rate = flow_rate,
            .edges = edges,
            .open = false,
            .allocator = allocator,
        };
    }

    fn deinit(self: *Node) void {
        self.edges.deinit();
    }

    fn clone(self: *Node) !Node {
        var edges = std.ArrayList([]const u8).init(self.allocator);

        for (self.edges.items) |item| {
            try edges.append(item);
        }

        return Node{
            .name = self.name,
            .flow_rate = self.flow_rate,
            .open = self.open,
            .allocator = self.allocator,
            .visited_distance = self.visited_distance,
            .edges = edges,
        };
    }
};

fn lessThan(context: *std.StringHashMap(Node), lhs: []const u8, rhs: []const u8) bool {
    return context.get(lhs).?.visited_distance.? > context.get(rhs).?.visited_distance.?;
}

const State = struct {
    location: []const u8,
    target: []const u8,
    distance_left: usize,
    pressure_released: usize,
    pressure_released_per_step: usize,
    time_step: u8,
    nodes: std.StringHashMap(Node),
    active: bool,

    fn init(nodes: std.StringHashMap(Node)) State {
        return State{
            .location = "AA",
            .target = "AA",
            .distance_left = 0,
            .pressure_released = 0,
            .pressure_released_per_step = 0,
            .time_step = 0,
            .nodes = nodes,
            .active = false,
        };
    }

    fn deinit(self: *State) void {
        self.nodes.deinit();
    }

    fn step(self: *State) void {
        if (self.time_step <= 30) {
            self.pressure_released += self.pressure_released_per_step;
        }
        if (self.active) {
            if (self.distance_left > 0) {
                self.distance_left -= 1;
            } else {
                // We're there! Open the valve
                self.pressure_released_per_step += self.nodes.get(self.target).?.flow_rate;
                self.nodes.getPtr(self.target).?.*.open = true;
                self.location = self.target;
                self.active = false;
            }
        }
        self.time_step += 1;
    }

    fn setTarget(self: *State, target: []const u8) !void {
        self.target = target;
        var it = self.nodes.valueIterator();
        while (it.next()) |node| {
            node.*.visited_distance = null;
        }

        var to_visit = std.ArrayList([]const u8).init(self.nodes.allocator);
        defer to_visit.deinit();
        self.nodes.getPtr(self.location).?.visited_distance = 0;
        try to_visit.append(self.location);
        while (self.nodes.get(self.target).?.visited_distance == null and to_visit.items.len > 0) {
            std.sort.sort([]const u8, to_visit.items, &self.nodes, lessThan);
            var node_name = to_visit.pop();
            var neighbors = self.nodes.getPtr(node_name).?.*.edges.items;
            for (neighbors) |n| {
                var node = self.nodes.getPtr(n);
                if (node.?.*.visited_distance == null) {
                    node.?.*.visited_distance = self.nodes.get(node_name).?.visited_distance.? + 1;
                    try to_visit.append(n);
                }
            }
        }
        // Now the target node has a distance!
        self.distance_left = self.nodes.get(target).?.visited_distance.?;
        // std.log.debug("Distance to next node: {}", .{self.distance_left});
        self.active = true;
    }

    fn nodesStillClosed(self: *State) !std.ArrayList([]const u8) {
        var result = std.ArrayList([]const u8).init(self.nodes.allocator);
        var it = self.nodes.valueIterator();
        while (it.next()) |item| {
            if (!item.open and item.flow_rate > 0) {
                try result.append(item.name);
            }
        }
        return result;
    }

    fn clone(self: *State) !State {
        var cloned_nodes = std.StringHashMap(Node).init(self.nodes.allocator);

        var it = self.nodes.keyIterator();
        while (it.next()) |item| {
            try cloned_nodes.put(item.*, try self.nodes.getPtr(item.*).?.*.clone());
        }

        return State{
            .location = self.location,
            .target = self.target,
            .distance_left = self.distance_left,
            .pressure_released = self.pressure_released,
            .pressure_released_per_step = self.pressure_released_per_step,
            .time_step = self.time_step,
            .active = self.active,
            .nodes = cloned_nodes,
        };
    }
};

// #######
// PARSING
// #######

fn parseNode(allocator: std.mem.Allocator, input: []const u8) !Node {
    std.log.debug("Parsing {s}", .{input});
    var parts = std.mem.split(u8, input, "; ");
    var a = parts.next().?;
    var b = parts.next().?;
    var a_words = std.mem.tokenize(u8, a, " ");
    _ = a_words.next().?;
    var name = a_words.next().?;
    _ = a_words.next().?;
    _ = a_words.next().?;
    var rate = a_words.next().?;
    var rate_parts = std.mem.tokenize(u8, rate, "=");
    _ = rate_parts.next().?;
    var rate_int = try std.fmt.parseInt(usize, rate_parts.next().?, 10);
    std.log.debug("b {s}", .{b});
    var b_parts = std.mem.split(u8, b, " ");
    _ = b_parts.next(); // tunnel(s)
    _ = b_parts.next(); // lead(s)
    _ = b_parts.next(); // to
    _ = b_parts.next(); // valve(s)

    var edges = std.ArrayList([]const u8).init(allocator);
    while (b_parts.next()) |item| {
        var trimmed = item[0..2];
        try edges.append(trimmed);
    }
    return Node.init(allocator, name, rate_int, edges);
}

fn parseInput(allocator: std.mem.Allocator, input: []const u8) !State {
    var result = std.StringHashMap(Node).init(allocator);
    var lines = std.mem.tokenize(u8, input, "\r\n");
    while (lines.next()) |line| {
        var node = try parseNode(allocator, line);
        try result.put(node.name, node);
    }
    return State.init(result);
}

// #####
// DEBUG
// #####

fn nodesWithFlowRate(allocator: std.mem.Allocator, nodes: *State) !std.ArrayList([]const u8) {
    var strings = std.ArrayList([]const u8).init(allocator);
    var it = nodes.nodes.keyIterator();
    while (it.next()) |item| {
        var node = nodes.nodes.get(item.*).?;
        if (node.flow_rate > 0) {
            try strings.append(node.name);
        }
    }
    return strings;
}

// ###
// OTHER
// ###

const SolveResponse = struct {
    score: usize,
    pressure_per_step: usize,
};

fn solve(allocator: std.mem.Allocator, state: *State, top_level: bool) !SolveResponse {
    while (state.active) {
        state.step();
        if (state.time_step == 30) {
            return SolveResponse{ .score = state.pressure_released, .pressure_per_step = state.pressure_released_per_step };
        }
    }

    var unopened_nodes = (try state.nodesStillClosed()).items;
    if (unopened_nodes.len == 0) {
        while (state.time_step != 30) {
            state.step();
        }
        return SolveResponse{ .score = state.pressure_released, .pressure_per_step = state.pressure_released_per_step };
    }
    var count: usize = 1;
    var max_score: usize = 0;
    var max_pressure_per_step: usize = 0;
    for (unopened_nodes) |target| {
        // std.time.sleep(std.time.ns_per_s);
        var new_state = try state.clone();
        try new_state.setTarget(target);
        var score = try solve(allocator, &new_state, false);
        if (top_level) {
            std.log.err("({}/{}) score: {} (max score: {})", .{ count, unopened_nodes.len, score.score, max_score });
        }
        if (score.score > max_score) {
            max_pressure_per_step = score.pressure_per_step;
            max_score = score.score;
        }
        if (top_level) {
            std.log.debug("Max node: {s}", .{target});
        }
        count += 1;
    }
    return SolveResponse{ .score = max_score, .pressure_per_step = max_pressure_per_step };
}

pub fn partA(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var graph = try parseInput(allocator, input);
    std.log.debug("graph: {any}", .{graph});
    var result = try solve(allocator, &graph, true);
    std.log.debug("Pressure per step: {}", .{result.pressure_per_step});
    return result.score;
}

pub fn partB(allocator: std.mem.Allocator) !usize {
    _ = allocator;
    return 1;
}
