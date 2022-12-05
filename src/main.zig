const std = @import("std");
const day01 = @import("day01.zig");
const day02 = @import("day02.zig");
const day03 = @import("day03.zig");
const day04 = @import("day04.zig");
const day05 = @import("day05.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stdout = std.io.getStdOut().writer();

    var a1: u64 = try day01.partA(allocator);
    var b1: u64 = try day01.partB(allocator);
    try stdout.print("Day 1 Part A = {any}\n", .{a1});
    try stdout.print("Day 1 Part B = {any}\n", .{b1});

    var a2: u64 = try day02.partA(allocator);
    var b2: u64 = try day02.partB(allocator);
    try stdout.print("Day 2 Part A = {any}\n", .{a2});
    try stdout.print("Day 2 Part B = {any}\n", .{b2});

    var a3: u64 = try day03.partA(allocator);
    var b3: u64 = try day03.partB();
    try stdout.print("Day 3 Part A = {any}\n", .{a3});
    try stdout.print("Day 3 Part B = {any}\n", .{b3});

    var a4: u64 = try day04.partA(allocator);
    var b4: u64 = try day04.partB(allocator);
    try stdout.print("Day 4 Part A = {any}\n", .{a4});
    try stdout.print("Day 4 Part B = {any}\n", .{b4});

    var a5: []const u8 = try day05.partA(allocator);
    var b5: []const u8 = try day05.partB(allocator);
    try stdout.print("Day 5 Part A = {s}\n", .{a5});
    try stdout.print("Day 5 Part B = {s}\n", .{b5});
}
