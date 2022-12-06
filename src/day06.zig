const std = @import("std");
const constants = @import("constants.zig");

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day06.txt");
    } else {
        return @embedFile("real_inputs/day06.txt");
    }
}

fn allUnique(input: []const u8) bool {
    var i: u64 = 0;
    while (i < input.len - 1) : (i += 1) {
        var j: u64 = i + 1;
        while (j < input.len) : (j += 1) {
            if (input[i] == input[j]) {
                return false;
            }
        }
    }
    return true;
}

fn findStartOfPacketIndex(input: []const u8, length: u64) ?u64 {
    var i: u64 = length - 1;
    while (i < input.len) : (i += 1) {
        var l = input[i - (length - 1) .. i + 1];
        if (allUnique(l)) {
            return i;
        }
    }
    return null;
}

pub fn partA() !u64 {
    var input = comptime inputText();
    return findStartOfPacketIndex(input, 4).? + 1;
}

pub fn partB() !u64 {
    var input = comptime inputText();
    return findStartOfPacketIndex(input, 14).? + 1;
}
