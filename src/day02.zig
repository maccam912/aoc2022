const std = @import("std");
const constants = @import("constants.zig");

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day02.txt");
    } else {
        return @embedFile("real_inputs/day02.txt");
    }
}

const Game = struct {
    elf: u8,
    me: u8,
};

fn parseGames(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(Game) {
    const L = std.ArrayList(Game);
    var list = L.init(allocator);

    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        var parts = std.mem.tokenize(u8, line, " ");
        var opponent = parts.next().?[0] - 64;
        var me = parts.next().?[0] - 87;
        var g = Game{ .elf = opponent, .me = me };
        try list.append(g);
    }

    return list;
}

fn scoreA(games: *std.ArrayList(Game)) u64 {
    var games_slice = games.toOwnedSlice();
    var my_score: u64 = 0;
    for (games_slice) |g| {
        var game_score = g.me;
        if (g.elf == g.me) {
            // Tie
            game_score += 3;
        } else if ((g.me == 1 and g.elf == 3) or (g.me == 2 and g.elf == 1) or (g.me == 3 and g.elf == 2)) {
            // I won!
            game_score += 6;
        } else {
            // I lost
            game_score += 0;
        }
        my_score += game_score;
    }
    return my_score;
}

fn scoreB(games: *std.ArrayList(Game)) u64 {
    var games_slice = games.toOwnedSlice();
    var my_score: u64 = 0;
    var me: u64 = 0;
    for (games_slice) |g| {
        if (g.me == 2) {
            me = g.elf;
        } else if (g.me == 1) {
            if (g.elf == 1) {
                me = 3;
            } else if (g.elf == 2) {
                me = 1;
            } else if (g.elf == 3) {
                me = 2;
            }
        } else if (g.me == 3) {
            if (g.elf == 1) {
                me = 2;
            } else if (g.elf == 2) {
                me = 3;
            } else if (g.elf == 3) {
                me = 1;
            }
        }
        var game_score = me;
        if (g.elf == me) {
            // Tie
            game_score += 3;
        } else if ((me == 1 and g.elf == 3) or (me == 2 and g.elf == 1) or (me == 3 and g.elf == 2)) {
            // I won!
            game_score += 6;
        } else {
            // I lost
            game_score += 0;
        }
        my_score += game_score;
    }
    return my_score;
}

pub fn partA(allocator: std.mem.Allocator) !u64 {
    const input = comptime inputText();
    var games_a = try parseGames(allocator, input);
    var my_score = scoreA(&games_a);
    return my_score;
}

pub fn partB(allocator: std.mem.Allocator) !u64 {
    const input = comptime inputText();
    var games_b = try parseGames(allocator, input);
    var my_score = scoreB(&games_b);
    return my_score;
}
