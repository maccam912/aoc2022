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
const day14 = @import("day14.zig");
const day15 = @import("day15.zig");
const day16 = @import("day16.zig");
const day17 = @import("day17.zig");
const day18 = @import("day18.zig");
const day19 = @import("day19.zig");
const day20 = @import("day20.zig");
const day21 = @import("day21.zig");
const day22 = @import("day22.zig");
const day23 = @import("day23.zig");
const day24 = @import("day24.zig");
const day25 = @import("day25.zig");
// const trace = @import("tracy.zig").trace;

pub fn main() !void {
    // const tracy = trace(@src());
    // defer tracy.end();
    const stdout = std.io.getStdOut().writer();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();
    _ = allocator;
    arena.deinit();

    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // var allocator = arena.allocator();
    // var a1: usize = try day01.partA(allocator);
    // var b1: usize = try day01.partB(allocator);
    // try stdout.print("Day 1 Part A = {any}\n", .{a1});
    // try stdout.print("Day 1 Part B = {any}\n", .{b1});
    // arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a2: usize = try day02.partA(allocator);
    // var b2: usize = try day02.partB(allocator);
    // try stdout.print("Day 2 Part A = {any}\n", .{a2});
    // try stdout.print("Day 2 Part B = {any}\n", .{b2});
    // defer arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a3: usize = try day03.partA(allocator);
    // var b3: usize = try day03.partB();
    // try stdout.print("Day 3 Part A = {any}\n", .{a3});
    // try stdout.print("Day 3 Part B = {any}\n", .{b3});
    // defer arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a4: usize = try day04.partA(allocator);
    // var b4: usize = try day04.partB(allocator);
    // try stdout.print("Day 4 Part A = {any}\n", .{a4});
    // try stdout.print("Day 4 Part B = {any}\n", .{b4});
    // defer arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a5: []const u8 = try day05.partA(allocator);
    // var b5: []const u8 = try day05.partB(allocator);
    // try stdout.print("Day 5 Part A = {s}\n", .{a5});
    // try stdout.print("Day 5 Part B = {s}\n", .{b5});
    // defer arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a6: usize = try day06.partA();
    // var b6: usize = try day06.partB();
    // try stdout.print("Day 6 Part A = {any}\n", .{a6});
    // try stdout.print("Day 6 Part B = {any}\n", .{b6});
    // defer arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a7: usize = try day07.partA(allocator);
    // var b7: usize = try day07.partB(allocator);
    // try stdout.print("Day 7 Part A = {any}\n", .{a7});
    // try stdout.print("Day 7 Part B = {any}\n", .{b7});
    // defer arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a8: usize = try day08.partA(allocator);
    // var b8: usize = try day08.partB(allocator);
    // try stdout.print("Day 8 Part A = {any}\n", .{a8});
    // try stdout.print("Day 8 Part B = {any}\n", .{b8});
    // defer arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a9: usize = try day09.partA(allocator);
    // var b9: usize = try day09.partB(allocator);
    // try stdout.print("Day 9 Part A = {any}\n", .{a9});
    // try stdout.print("Day 9 Part B = {any}\n", .{b9});
    // defer arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a10: isize = try day10.partA();
    // try stdout.print("Day 10 Part A = {any}\n", .{a10});
    // try day10.partB();
    // defer arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a12: u32 = (try day12.partA(allocator, null)).?;
    // var b12: usize = try day12.partB(allocator);
    // try stdout.print("Day 12 Part A = {any}\n", .{a12});
    // try stdout.print("Day 12 Part B = {any}\n", .{b12});
    // defer arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a13: usize = try day13.partA(allocator);
    // var b13: usize = try day13.partB(allocator);
    // try stdout.print("Day 13 Part A = {any}\n", .{a13});
    // try stdout.print("Day 13 Part B = {any}\n", .{b13});
    // defer arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a14: usize = try day14.partA(allocator);
    // var b14: usize = try day14.partB(allocator);
    // try stdout.print("Day 14 Part A = {any}\n", .{a14});
    // try stdout.print("Day 14 Part B = {any}\n", .{b14});
    // defer arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a15: usize = try day15.partA(allocator);
    // var b15: usize = try day15.partB(allocator);
    // try stdout.print("Day 15 Part A = {any}\n", .{a15});
    // try stdout.print("Day 15 Part B = {any}\n", .{b15});
    // defer arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a16: usize = try day16.partA(allocator);
    // var b16: usize = try day16.partB(allocator);
    // try stdout.print("Day 16 Part A = {any}\n", .{a16});
    // try stdout.print("Day 16 Part B = {any}\n", .{b16});
    // defer arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a17: usize = try day17.partA(allocator);
    // var b17: usize = try day17.partB(allocator);
    // try stdout.print("Day 17 Part A = {any}\n", .{a17});
    // try stdout.print("Day 17 Part B = {any}\n", .{b17});
    // defer arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a18: usize = try day18.partA(allocator);
    // var b18: usize = try day18.partB(allocator);
    // try stdout.print("Day 18 Part A = {any}\n", .{a18});
    // try stdout.print("Day 18 Part B = {any}\n", .{b18});
    // defer arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a19: usize = try day19.partA(allocator);
    // var b19: usize = try day19.partB(allocator);
    // try stdout.print("Day 19 Part A = {any}\n", .{a19});
    // try stdout.print("Day 19 Part B = {any}\n", .{b19});
    // defer arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a20: isize = try day20.partA(allocator);
    // var b20: isize = try day20.partB(allocator);
    // try stdout.print("Day 20 Part A = {any}\n", .{a20});
    // try stdout.print("Day 20 Part B = {any}\n", .{b20});
    // defer arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a21: i64 = try day21.partA(allocator);
    // var b21: i64 = try day21.partB(allocator);
    // try stdout.print("Day 21 Part A = {any}\n", .{a21});
    // try stdout.print("Day 21 Part B = {any}\n", .{b21});
    // defer arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a22: i64 = try day22.partA(allocator);
    // var b22: i64 = try day22.partB(allocator);
    // try stdout.print("Day 22 Part A = {any}\n", .{a22});
    // try stdout.print("Day 22 Part B = {any}\n", .{b22});
    // defer arena.deinit();

    // arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // allocator = arena.allocator();
    // var a23: u64 = try day23.partA(allocator);
    // var b23: u64 = try day23.partB(allocator);
    // try stdout.print("Day 23 Part A = {any}\n", .{a23});
    // try stdout.print("Day 23 Part B = {any}\n", .{b23});
    // defer arena.deinit();

    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // allocator = gpa.allocator();
    // var a24: u64 = try day24.partA(allocator);
    // var b24: u64 = try day24.partB(allocator);
    // try stdout.print("Day 24 Part A = {any}\n", .{a24});
    // try stdout.print("Day 24 Part B = {any}\n", .{b24});
    // defer arena.deinit();

    var a25: isize = try day25.partA();
    try stdout.print("Day 25 Part A = {any}\n", .{a25});
}
