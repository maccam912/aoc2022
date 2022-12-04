const std = @import("std");

pub const TESTING: bool = true;

pub fn debug(item: anytype) void {
    std.log.debug("{any}", .{item});
}