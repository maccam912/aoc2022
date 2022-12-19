const std = @import("std");
const constants = @import("constants.zig");

const debug = false;

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day19.txt");
    } else {
        return @embedFile("real_inputs/day19.txt");
    }
}

const Pair = struct {
    a: u8,
    b: u8,
};

const Blueprint = struct {
    num: u8,
    ore_robot_cost: u8,
    clay_robot_cost: u8,
    obsidian_robot_cost_ore: u8,
    obsidian_robot_cost_clay: u8,
    geode_robot_cost_ore: u8,
    geode_robot_cost_obsidian: u8,

    fn parseOreRecipe(input: []const u8) !u8 {
        // Each ore robot costs 4 ore
        var parts = std.mem.split(u8, input, "Each ore robot costs ");
        _ = parts.next().?;
        var ingredients_parts = std.mem.tokenize(u8, parts.next().?, " ");
        var num_ore = try std.fmt.parseInt(u8, ingredients_parts.next().?, 10);
        return num_ore;
    }

    fn parseClayRecipe(input: []const u8) !u8 {
        // Each ore robot costs 4 ore
        var parts = std.mem.split(u8, input, "Each clay robot costs ");
        _ = parts.next().?;
        var ingredients_parts = std.mem.tokenize(u8, parts.next().?, " ");
        var num_ore = try std.fmt.parseInt(u8, ingredients_parts.next().?, 10);
        return num_ore;
    }

    fn parseObsidianRecipe(input: []const u8) !Pair {
        // Each ore robot costs 4 ore
        var parts = std.mem.split(u8, input, "Each obsidian robot costs ");
        _ = parts.next().?;
        var ingredients_parts = std.mem.split(u8, parts.next().?, "and");
        var ore_parts = std.mem.tokenize(u8, ingredients_parts.next().?, " ");
        var clay_parts = std.mem.tokenize(u8, ingredients_parts.next().?, " ");
        var num_ore = try std.fmt.parseInt(u8, ore_parts.next().?, 10);
        var num_clay = try std.fmt.parseInt(u8, clay_parts.next().?, 10);
        return Pair{ .a = num_ore, .b = num_clay };
    }

    fn parseGeodeRecipe(input: []const u8) !Pair {
        // Each ore robot costs 4 ore
        var parts = std.mem.split(u8, input, "Each geode robot costs ");
        _ = parts.next().?;
        var ingredients_parts = std.mem.split(u8, parts.next().?, "and");
        var ore_parts = std.mem.tokenize(u8, ingredients_parts.next().?, " ");
        var obsidian_parts = std.mem.tokenize(u8, ingredients_parts.next().?, " ");
        var num_ore = try std.fmt.parseInt(u8, ore_parts.next().?, 10);
        var num_obsidian = try std.fmt.parseInt(u8, obsidian_parts.next().?, 10);
        return Pair{ .a = num_ore, .b = num_obsidian };
    }

    fn parse(input: []const u8) !Blueprint {
        var parts = std.mem.split(u8, input, ": ");
        var blueprint_num_parts = std.mem.tokenize(u8, parts.next().?, " ");
        _ = blueprint_num_parts.next();
        var num = try std.fmt.parseInt(u8, blueprint_num_parts.next().?, 10);
        var recipes = std.mem.tokenize(u8, parts.next().?, ".");
        var ore_robot_recipe = try Blueprint.parseOreRecipe(recipes.next().?);
        var clay_robot_recipe = try Blueprint.parseClayRecipe(recipes.next().?);
        var obsidian_robot_recipe = try Blueprint.parseObsidianRecipe(recipes.next().?);
        var geode_robot_recipe = try Blueprint.parseGeodeRecipe(recipes.next().?);

        return Blueprint{
            .num = num,
            .ore_robot_cost = ore_robot_recipe,
            .clay_robot_cost = clay_robot_recipe,
            .obsidian_robot_cost_ore = obsidian_robot_recipe.a,
            .obsidian_robot_cost_clay = obsidian_robot_recipe.b,
            .geode_robot_cost_ore = geode_robot_recipe.a,
            .geode_robot_cost_obsidian = geode_robot_recipe.b,
        };
    }
};

fn divCeil(num: usize, den: usize) usize {
    return @divFloor(num, den) + 1;
}

const Action = enum {
    nothing,
    build_ore_robot,
    build_clay_robot,
    build_obsidian_robot,
    build_geode_robot,
};

const State = struct {
    blueprint: Blueprint,
    num_ore_robots: usize,
    num_clay_robots: usize,
    num_obsidian_robots: usize,
    num_geode_robots: usize,
    total_ore: usize,
    total_clay: usize,
    total_obsidian: usize,
    total_geode: usize,
    step_num: usize,

    fn new(blueprint: []const u8) !State {
        return State{
            .blueprint = try Blueprint.parse(blueprint),
            .num_ore_robots = 1,
            .num_clay_robots = 0,
            .num_obsidian_robots = 0,
            .num_geode_robots = 0,
            .total_ore = 0,
            .total_clay = 0,
            .total_obsidian = 0,
            .total_geode = 0,
            .step_num = 0,
        };
    }

    fn clone(self: State) State {
        return State{
            .blueprint = self.blueprint,
            .num_ore_robots = self.num_ore_robots,
            .num_clay_robots = self.num_clay_robots,
            .num_obsidian_robots = self.num_obsidian_robots,
            .num_geode_robots = self.num_geode_robots,
            .total_ore = self.total_ore,
            .total_clay = self.total_clay,
            .total_obsidian = self.total_obsidian,
            .total_geode = self.total_geode,
            .step_num = self.step_num,
        };
    }

    fn run(self: *State, global_best_score: *usize, action: Action, max_step: usize) !usize {
        if (self.step_num == max_step) {
            // We've run all our steps, return num geodes
            return self.total_geode;
        }
        switch (action) {
            Action.build_ore_robot => {
                if (self.blueprint.ore_robot_cost <= self.total_ore) {
                    self.total_ore -= self.blueprint.ore_robot_cost;
                } else {
                    return error.NotEnoughMaterialsError;
                }
            },
            Action.build_clay_robot => {
                if (self.blueprint.clay_robot_cost <= self.total_ore) {
                    self.total_ore -= self.blueprint.clay_robot_cost;
                } else {
                    return error.NotEnoughMaterialsError;
                }
            },
            Action.build_obsidian_robot => {
                if (self.blueprint.obsidian_robot_cost_ore <= self.total_ore and self.blueprint.obsidian_robot_cost_clay <= self.total_clay) {
                    self.total_ore -= self.blueprint.obsidian_robot_cost_ore;
                    self.total_clay -= self.blueprint.obsidian_robot_cost_clay;
                } else {
                    return error.NotEnoughMaterialsError;
                }
            },
            Action.build_geode_robot => {
                if (self.blueprint.geode_robot_cost_ore <= self.total_ore and self.blueprint.geode_robot_cost_obsidian <= self.total_obsidian) {
                    self.total_ore -= self.blueprint.geode_robot_cost_ore;
                    self.total_obsidian -= self.blueprint.geode_robot_cost_obsidian;
                } else {
                    return error.NotEnoughMaterialsError;
                }
            },
            Action.nothing => {},
        }

        // We have deducted the required materials. Building robot but it won't be ready until end of this step
        self.total_ore += self.num_ore_robots;
        self.total_clay += self.num_clay_robots;
        self.total_obsidian += self.num_obsidian_robots;
        self.total_geode += self.num_geode_robots;

        switch (action) {
            Action.build_ore_robot => self.num_ore_robots += 1,
            Action.build_clay_robot => self.num_clay_robots += 1,
            Action.build_obsidian_robot => self.num_obsidian_robots += 1,
            Action.build_geode_robot => self.num_geode_robots += 1,
            Action.nothing => {},
        }

        self.step_num += 1;

        // max possible score is if you mined self.num_geode_robots each timestep for the rest of the max_step, plus made one new bot each timestep
        const remaining_steps = max_step - self.step_num;
        const extrapolated = self.total_geode + self.num_geode_robots * remaining_steps;
        _ = extrapolated;

        var i: usize = 1;
        var best_possible_score: usize = self.total_geode;
        var clay_sum: usize = self.total_clay;
        var obsidian_sum: usize = self.total_obsidian;
        while (i <= remaining_steps) : (i += 1) {
            clay_sum += i;
            var max_possible_obsidian_bots = self.num_obsidian_robots + @divFloor(clay_sum, self.blueprint.obsidian_robot_cost_clay);
            obsidian_sum += max_possible_obsidian_bots;
            var max_possible_geode_bots = self.num_geode_robots + @divFloor(obsidian_sum, self.blueprint.geode_robot_cost_obsidian);
            best_possible_score += max_possible_geode_bots;
        }

        // var best_possible_score_2 = @floatToInt(usize, @intToFloat(f32, remaining_steps+1)*(@intToFloat(f32, remaining_steps)/2.0));
        // best_possible_score = @min(best_possible_score, best_possible_score_2);

        // Now just throw it all out and calculate best possible score estimate. Maybe wrong but fast
        if (best_possible_score <= global_best_score.*) {
            // Already found something better
            return 0;
        }

        var best_score: usize = 0;

        global_best_score.* = @max(global_best_score.*, best_score);

        if (debug) {
            std.log.debug("==============", .{});
            std.log.debug("State: {any}", .{self});
            std.log.debug("global best so far: {}", .{global_best_score.*});
            std.log.debug("best possible {}", .{best_possible_score});
            var buf: [10]u8 = undefined;
            const stdin = std.io.getStdIn().reader();
            _ = try stdin.readUntilDelimiterOrEof(buf[0..], '\n');
            if (buf[0] == 'o') {
                return self.run(global_best_score, Action.build_ore_robot);
            } else if (buf[0] == 'c') {
                return self.run(global_best_score, Action.build_clay_robot);
            } else if (buf[0] == 'b') {
                return self.run(global_best_score, Action.build_obsidian_robot);
            } else if (buf[0] == 'g') {
                return self.run(global_best_score, Action.build_geode_robot);
            } else if (buf[0] == 'n') {
                return self.run(global_best_score, Action.nothing);
            }
        }

        global_best_score.* = @max(global_best_score.*, best_score);

        if (best_possible_score == best_score) {
            return best_score;
        }

        if (best_possible_score > best_score and self.total_ore >= self.blueprint.geode_robot_cost_ore and self.total_obsidian >= self.blueprint.geode_robot_cost_obsidian) {
            // Can afford new geode robot
            var new_clone = self.clone();
            const new_geode_robot_score = try new_clone.run(global_best_score, Action.build_geode_robot, max_step);
            best_score = @max(best_score, new_geode_robot_score);
        }

        global_best_score.* = @max(global_best_score.*, best_score);

        if (best_possible_score == best_score) {
            return best_score;
        }

        if (best_possible_score > best_score and self.total_ore >= self.blueprint.obsidian_robot_cost_ore and self.total_clay >= self.blueprint.obsidian_robot_cost_clay) {
            // Can afford new obsidian robot
            var new_clone = self.clone();
            const new_obsidian_robot_score = try new_clone.run(global_best_score, Action.build_obsidian_robot, max_step);
            best_score = @max(best_score, new_obsidian_robot_score);
        }

        global_best_score.* = @max(global_best_score.*, best_score);

        if (best_possible_score == best_score) {
            return best_score;
        }

        if (best_possible_score > best_score and self.total_ore >= self.blueprint.clay_robot_cost) {
            // Can afford new clay robot
            var new_clone = self.clone();
            const new_clay_robot_score = try new_clone.run(global_best_score, Action.build_clay_robot, max_step);
            best_score = @max(best_score, new_clay_robot_score);
        }

        global_best_score.* = @max(global_best_score.*, best_score);

        if (best_possible_score == best_score) {
            return best_score;
        }

        if (best_possible_score > best_score and self.total_ore >= self.blueprint.ore_robot_cost) {
            // Can afford new ore robot
            var new_clone = self.clone();
            const new_ore_robot_score = try new_clone.run(global_best_score, Action.build_ore_robot, max_step);
            best_score = @max(best_score, new_ore_robot_score);
        }

        global_best_score.* = @max(global_best_score.*, best_score);

        if (best_possible_score == best_score) {
            return best_score;
        }

        if (self.total_clay > 20 and self.total_obsidian > 20 and self.total_ore > 4) {
            // std.log.debug("Cutting off useless path", .{});
            // SOMETHING could be built, if you haven't built something you're wasting time
            return best_score;
        }

        global_best_score.* = @max(global_best_score.*, best_score);

        return @max(best_score, try self.run(global_best_score, Action.nothing, max_step));
    }
};

pub fn partA(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var blueprints = std.mem.tokenize(u8, input, "\r\n");
    var states = std.ArrayList(State).init(allocator);
    while (blueprints.next()) |line| {
        try states.append(try State.new(line));
    }

    var num: usize = 0;
    var total_quality: usize = 0;
    while (num < states.items.len) : (num += 1) {
        var global_best_score: usize = 0;
        const bpnum = num + 1;
        const score = try states.items[num].run(&global_best_score, Action.nothing, 24);
        const quality_level = score * bpnum;
        std.log.err("Done running state {}, score {}", .{ num, score });
        total_quality += quality_level;
    }

    return total_quality;
}

pub fn partB(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var blueprints = std.mem.tokenize(u8, input, "\r\n");
    var states = std.ArrayList(State).init(allocator);
    while (blueprints.next()) |line| {
        try states.append(try State.new(line));
    }

    var num: usize = 0;
    var quality_prod: usize = 1;
    while (num < states.items.len and num < 3) : (num += 1) {
        var global_best_score: usize = 0;
        const score = try states.items[num].run(&global_best_score, Action.nothing, 32);
        std.log.err("Done running state {}, score {}", .{ num, score });
        quality_prod *= score;
    }

    return quality_prod;
}
