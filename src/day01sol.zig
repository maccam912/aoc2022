// https://www.reddit.com/r/adventofcode/comments/z9ezjb/2022_day_1_solutions/iyi3voe/
// run with: zig run a.zig
const std = @import("std");
const testing = std.testing;

const input = @embedFile("input.txt");

fn gt(_: void, lhs: usize, rhs: usize) bool {
    return lhs > rhs;
}

pub fn calories(data: []const u8) ![3]usize {
    var elves = std.mem.split(u8, data, "\n\n");

    var maxes = [_]usize{ 0, 0, 0 };
    while (elves.next()) |elf| {
        var foods = std.mem.tokenize(u8, elf, "\n");
        var sum: usize = 0;
        while (foods.next()) |food| {
            sum += try std.fmt.parseInt(usize, food, 10);
        }
        if (sum > maxes[2]) {
            maxes[2] = sum;
            std.sort.sort(usize, &maxes, {}, gt);
        }
    }

    return maxes;
}

pub fn main() !void {
    var maxes = try calories(input);

    std.debug.print("part 1: {}\n", .{maxes[0]});
    std.debug.print("part 2: {}\n", .{maxes[0] + maxes[1] + maxes[2]});
}