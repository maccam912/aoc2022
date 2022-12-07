const std = @import("std");

pub const TESTING: bool = false;

pub fn strEq(a: []const u8, b: []const u8) bool {
    if (a.len != b.len) {
        return false;
    } else {
        var i: usize = 0;
        while (i < a.len) : (i += 1) {
            if (a[i] != b[i]) {
                return false;
            }
        }
    }
    return true;
}
