const std = @import("std");
const constants = @import("constants.zig");
// const trace = @import("tracy.zig").trace;

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day25.txt");
    } else {
        return @embedFile("real_inputs/day25.txt");
    }
}

fn numToSnafu(orig: isize) void {
    std.log.debug("The right string, but reversed", .{});
    var num = orig;
    var inc: isize = 0;
    while (num != 0) {
        var digit = @rem(num, 5);

        num -= digit;

        num = @divExact(num, 5);
        // std.log.debug("digit {} inc {}, remaining {}", .{digit, inc, num});
        var c: u8 = switch (digit + inc) {
            0 => '0',
            1 => '1',
            2 => '2',
            3 => '=',
            4 => '-',
            5 => '0',
            else => unreachable,
        };
        if (digit + inc > 2) {
            inc = 1;
        } else {
            inc = 0;
        }
        std.debug.print("{c}", .{c});
    }
    if (inc > 0) {
        std.debug.print("1", .{});
    }
    std.debug.print("\n", .{});
}

pub fn partA() !isize {
    const input = comptime inputText();
    var sum: isize = 0;
    var lines = std.mem.tokenize(u8, input, "\r\n");
    while (lines.next()) |line| {
        var num: isize = 0;
        for (line) |c| {
            num *= 5;
            switch (c) {
                '2' => {
                    num += 2;
                },
                '1' => {
                    num += 1;
                },
                '0' => {
                    num += 0;
                },
                '-' => {
                    num -= 1;
                },
                '=' => {
                    num -= 2;
                },
                else => unreachable,
            }
        }
        sum += num;
    }
    numToSnafu(sum);
    return 2022;
}
