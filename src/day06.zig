const std = @import("std");
const constants = @import("constants.zig");

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day06.txt");
    } else {
        return @embedFile("real_inputs/day06.txt");
    }
}

fn findStartOfPacketIndex(input: []const u8) ?u64 {
    var i: u64 = 3;
    while (i < input.len) : (i += 1) {
        var l = input[i - 3 .. i + 1];
        if (l[0] != l[1] and
            l[0] != l[2] and
            l[0] != l[3] and
            l[1] != l[2] and
            l[1] != l[3] and
            l[2] != l[3])
        {
            return i;
        }
        std.log.debug("last four {any}", .{l});
    }
    return null;
}

pub fn partA() !u64 {
    var input = comptime inputText();
    return findStartOfPacketIndex(input).? + 1;
}

pub fn partB(allocator: std.mem.Allocator) !u64 {
    _ = allocator;
    return 1;
}
