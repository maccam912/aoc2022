const std = @import("std");
const constants = @import("constants.zig");

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day10.txt");
    } else {
        return @embedFile("real_inputs/day10.txt");
    }
}

const Cpu = struct {
    x: isize,
    clock: usize,
    history: [241]isize,

    fn run(self: *Cpu, input: []const u8) !void {
        self.history[0] = 1;
        var instructions = std.mem.split(u8, input, "\n");
        while (instructions.next()) |ins| {
            var parts = std.mem.split(u8, ins, " ");
            var op = parts.next().?;
            if (constants.strEq(op, "noop")) {
                // One clock cycle
                self.clock += 1;
                self.history[self.clock] = self.x;
            } else if (constants.strEq(op, "addx")) {
                // Two clock cycles, then update x
                self.clock += 1;
                self.history[self.clock] = self.x;
                self.clock += 1;
                var value = try std.fmt.parseInt(isize, parts.next().?, 10);
                self.x += value;
                self.history[self.clock] = self.x;
            }
        }
    }
};

pub fn partA() !isize {
    const input = comptime inputText();
    var cpu = Cpu{ .x = 1, .clock = 0, .history = undefined };
    try cpu.run(input);
    const h = cpu.history;
    return 20 * h[19] + 60 * h[59] + 100 * h[99] + 140 * h[139] + 180 * h[179] + 220 * h[219];
}

pub fn partB() !void {
    const input = comptime inputText();
    var cpu = Cpu{ .x = 1, .clock = 0, .history = undefined };
    try cpu.run(input);
    var i: u8 = 0;
    var screen: [240]u8 = undefined;
    while (i < 240) : (i += 1) {
        var x = try std.math.mod(isize, i, 40);
        var diff = cpu.history[i] - x;
        if (diff < 2 and diff > -2) {
            screen[i] = '#';
        } else {
            screen[i] = '.';
        }
    }
    std.log.err("{s}", .{screen[0..40]});
    std.log.err("{s}", .{screen[40..80]});
    std.log.err("{s}", .{screen[80..120]});
    std.log.err("{s}", .{screen[120..160]});
    std.log.err("{s}", .{screen[160..200]});
    std.log.err("{s}", .{screen[200..240]});
}
