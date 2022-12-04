const std = @import("std");

pub const TESTING: bool = false;

pub fn debug(item: anytype) void {
    std.log.debug("{any}", .{item});
}