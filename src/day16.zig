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

    fn clone(self: *Node, new_allocator: std.mem.Allocator) !Node {
        var edges = std.ArrayList([]const u8).init(new_allocator);

        for (self.edges.items) |item| {
            try edges.append(item);
        }

        return Node{
            .name = self.name,
            .flow_rate = self.flow_rate,
            .open = self.open,
            .allocator = new_allocator,
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

    fn step(self: *State, comptime part_b: bool) void {
        comptime var steps = 30;
        if (part_b) {
            steps = 26;
        }
        if (self.time_step <= steps) {
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

    fn clone(self: *State, new_allocator: std.mem.Allocator) !State {
        var cloned_nodes = std.StringHashMap(Node).init(new_allocator);

        var it = self.nodes.keyIterator();
        while (it.next()) |item| {
            try cloned_nodes.put(item.*, try self.nodes.getPtr(item.*).?.*.clone(new_allocator));
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

fn solve(allocator: std.mem.Allocator, state: *State, top_level: bool, comptime part_b: bool) !SolveResponse {
    comptime var steps = 30;
    if (part_b) {
        steps = 26;
    }

    while (state.active) {
        state.step(part_b);
        if (state.time_step == steps) {
            return SolveResponse{ .score = state.pressure_released, .pressure_per_step = state.pressure_released_per_step };
        }
    }

    var unopened_nodes = (try state.nodesStillClosed()).items;
    if (unopened_nodes.len == 0) {
        while (state.time_step != steps) {
            state.step(part_b);
        }
        return SolveResponse{ .score = state.pressure_released, .pressure_per_step = state.pressure_released_per_step };
    }
    var count: usize = 1;
    var max_score: usize = 0;
    var max_pressure_per_step: usize = 0;
    for (unopened_nodes) |target| {
        // std.time.sleep(std.time.ns_per_s);
        var new_state = try state.clone(allocator);
        try new_state.setTarget(target);
        var score = try solve(allocator, &new_state, false, part_b);
        if (top_level) {
            // std.log.err("({}/{}) score: {} (max score: {})", .{ count, unopened_nodes.len, score.score, max_score });
        }
        if (score.score > max_score) {
            max_pressure_per_step = score.pressure_per_step;
            max_score = score.score;
        }
        if (top_level) {
            // std.log.debug("Max node: {s}", .{target});
        }
        count += 1;
    }
    return SolveResponse{ .score = max_score, .pressure_per_step = max_pressure_per_step };
}

pub fn partA(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var graph = try parseInput(allocator, input);
    std.log.debug("graph: {any}", .{graph});
    var result = try solve(allocator, &graph, true, false);
    std.log.debug("Pressure per step: {}", .{result.pressure_per_step});
    return result.score;
}

pub fn partB(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var graph = try parseInput(allocator, input);
    var unopened_nodes = (try graph.nodesStillClosed()).items;
    var curr_max: usize = 0;
    var count: usize = 0;
    var buffer: []u8 = try allocator.alloc(u8, std.math.pow(usize, 2, 30));
    var fba = std.heap.FixedBufferAllocator.init(buffer);
    while (count < 32768) : (count += 1) {
        if (@mod(count, 100) == 0) {
            std.log.err("Count: {}", .{count});
        }
        // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        // defer arena.deinit();
        // const new_allocator = arena.allocator();
        var count_clone_a = count;
        var idx_a: usize = 0;
        var high_bits: usize = 0;
        while (idx_a < unopened_nodes.len) : (idx_a += 1) {
            high_bits += @mod(count_clone_a, 2);
            count_clone_a = count_clone_a >> 1;
        }
        if (high_bits == 7) {
            fba.reset();
            const new_allocator = fba.allocator();
            var graph_a = try graph.clone(new_allocator);
            var graph_b = try graph.clone(new_allocator);
            var idx: usize = 0;
            var count_clone = count;
            while (idx < unopened_nodes.len) : (idx += 1) {
                var node_name = unopened_nodes[idx];
                if (idx < unopened_nodes.len and @mod(count_clone, 2) == 0) {
                    graph_b.nodes.getPtr(node_name).?.*.flow_rate = 0;
                } else {
                    graph_a.nodes.getPtr(node_name).?.*.flow_rate = 0;
                }
                count_clone = count_clone >> 1;
            }
            var best_graph_a_score = try solve(new_allocator, &graph_a, true, true);
            var best_graph_b_score = try solve(new_allocator, &graph_b, true, true);
            std.log.debug("graph_a score was {} and graph_b score was {}", .{ best_graph_a_score.score, best_graph_b_score.score });
            if (best_graph_a_score.score + best_graph_b_score.score > curr_max) {
                curr_max = best_graph_a_score.score + best_graph_b_score.score;
            }
        }
    }
    return curr_max;
}
