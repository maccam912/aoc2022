const std = @import("std");
const day01 = @import("day01.zig");
const day02 = @import("day02.zig");
const day03 = @import("day03.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var a1: u64 = try day01.part_a(allocator);
    var b1: u64 = try day01.part_b(allocator);
    std.log.info("Day 1 Part A = {any}", .{a1});
    std.log.info("Day 1 Part B = {any}", .{b1});

    var a2: u64 = try day02.part_a(allocator);
    var b2: u64 = try day02.part_b(allocator);
    std.log.info("Day 2 Part A = {any}", .{a2});
    std.log.info("Day 2 Part B = {any}", .{b2});

    var a3: u64 = try day03.part_a(allocator);
    // var b2: u64 = try day03.part_b(allocator);
    std.log.info("Day 3 Part A = {any}", .{a3});
    // std.log.info("Day 3 Part B = {any}", .{b2});
}