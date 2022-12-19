const std = @import("std");
const constants = @import("constants.zig");

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

    fn run(self: *State, global_best_score: *usize, action: Action) !usize {
        if (self.step_num == 24) {
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

        // max possible score is if you mined self.num_geode_robots each timestep for the rest of the 24, plus made one new bot each timestep
        const remaining_steps = 24 - self.step_num;
        const current_geode_rate = self.num_geode_robots * remaining_steps;
        const possible_total_no_new_bots = current_geode_rate + self.total_geode;
        // the ol 1+2+3..n => (n+1)*(n/2)
        const max_possible_extras = @floatToInt(usize, @intToFloat(f32, remaining_steps + 1) * (@intToFloat(f32, remaining_steps) / 2.0));
        const best_possible_score = possible_total_no_new_bots + max_possible_extras;
        if (best_possible_score <= global_best_score.*) {
            // Already found something better
            return 0;
        }

        var best_score: usize = 0;

        global_best_score.* = @max(global_best_score.*, best_score);

        if (best_possible_score > best_score and self.total_ore >= self.blueprint.ore_robot_cost) {
            // Can afford new ore robot
            var new_clone = self.clone();
            const new_ore_robot_score = try new_clone.run(global_best_score, Action.build_ore_robot);
            best_score = @max(best_score, new_ore_robot_score);
        }

        global_best_score.* = @max(global_best_score.*, best_score);

        if (best_possible_score == best_score) {
            return best_score;
        }

        if (best_possible_score > best_score and self.total_ore >= self.blueprint.clay_robot_cost) {
            // Can afford new clay robot
            var new_clone = self.clone();
            const new_clay_robot_score = try new_clone.run(global_best_score, Action.build_clay_robot);
            best_score = @max(best_score, new_clay_robot_score);
        }

        global_best_score.* = @max(global_best_score.*, best_score);

        if (best_possible_score == best_score) {
            return best_score;
        }

        if (best_possible_score > best_score and self.total_ore >= self.blueprint.obsidian_robot_cost_ore and self.total_clay >= self.blueprint.obsidian_robot_cost_clay) {
            // Can afford new obsidian robot
            var new_clone = self.clone();
            const new_obsidian_robot_score = try new_clone.run(global_best_score, Action.build_obsidian_robot);
            best_score = @max(best_score, new_obsidian_robot_score);
        }

        global_best_score.* = @max(global_best_score.*, best_score);

        if (best_possible_score == best_score) {
            return best_score;
        }

        if (best_possible_score > best_score and self.total_ore >= self.blueprint.geode_robot_cost_ore and self.total_obsidian >= self.blueprint.geode_robot_cost_obsidian) {
            // Can afford new geode robot
            var new_clone = self.clone();
            const new_geode_robot_score = try new_clone.run(global_best_score, Action.build_geode_robot);
            best_score = @max(best_score, new_geode_robot_score);
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

        return @max(best_score, try self.run(global_best_score, Action.nothing));
    }
};

pub fn partA(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var blueprints = std.mem.tokenize(u8, input, "\r\n");
    var states = std.ArrayList(State).init(allocator);
    while (blueprints.next()) |line| {
        try states.append(try State.new(line));
    }
    var global_best_score: usize = 0;
    std.log.debug("State 1 score: {any}", .{states.items[1].run(&global_best_score, Action.nothing)});
    return global_best_score;
}

pub fn partB(allocator: std.mem.Allocator) !usize {
    _ = allocator;
    return 1;
}
