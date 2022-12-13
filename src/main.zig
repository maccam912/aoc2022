const std = @import("std");
const day01 = @import("day01.zig");
const day02 = @import("day02.zig");
const day03 = @import("day03.zig");
const day04 = @import("day04.zig");
const day05 = @import("day05.zig");
const day06 = @import("day06.zig");
const day07 = @import("day07.zig");
const day08 = @import("day08.zig");
const day09 = @import("day09.zig");
const day10 = @import("day10.zig");
const day11 = @import("day11.zig");
const day12 = @import("day12.zig");
const day13 = @import("day13.zig");

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

    var a6: u64 = try day06.partA();
    var b6: u64 = try day06.partB();
    try stdout.print("Day 6 Part A = {any}\n", .{a6});
    try stdout.print("Day 6 Part B = {any}\n", .{b6});

    var a7: u64 = try day07.partA(allocator);
    var b7: u64 = try day07.partB(allocator);
    try stdout.print("Day 7 Part A = {any}\n", .{a7});
    try stdout.print("Day 7 Part B = {any}\n", .{b7});

    var a8: u64 = try day08.partA(allocator);
    var b8: u64 = try day08.partB(allocator);
    try stdout.print("Day 8 Part A = {any}\n", .{a8});
    try stdout.print("Day 8 Part B = {any}\n", .{b8});

    var a9: u64 = try day09.partA(allocator);
    var b9: u64 = try day09.partB(allocator);
    try stdout.print("Day 9 Part A = {any}\n", .{a9});
    try stdout.print("Day 9 Part B = {any}\n", .{b9});

    var a10: isize = try day10.partA();
    try stdout.print("Day 10 Part A = {any}\n", .{a10});
    try day10.partB();

    var a12: u32 = (try day12.partA(allocator, null)).?;
    var b12: usize = try day12.partB(allocator);
    try stdout.print("Day 12 Part A = {any}\n", .{a12});
    try stdout.print("Day 12 Part B = {any}\n", .{b12});

    var a13: u64 = try day13.partA(allocator);
    var b13: u64 = try day13.partB(allocator);
    try stdout.print("Day 13 Part A = {any}\n", .{a13});
    try stdout.print("Day 13 Part B = {any}\n", .{b13});
}
