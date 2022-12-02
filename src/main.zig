const std = @import("std");
const day01 = @import("day01.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var a1: u64 = try day01.part_a(allocator);
    var b1: u64 = try day01.part_b(allocator);
    std.log.info("Day 1 Part A = {any}", .{a1});
    std.log.info("Day 1 Part B = {any}", .{b1});
}