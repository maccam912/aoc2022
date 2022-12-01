const std = @import("std");

const testing: bool = true;

fn input_text() []const u8 {
    if (testing) {
        return @embedFile("test_inputs/day01.txt");
    } else {
        return @embedFile("real_inputs/day01.txt");
    }
}

const Elf = struct {
    calories: u64
};

fn parse_elves(input: []const u8) std.SinglyLinkedList(Elf) {
    const list = std.SinglyLinkedList(Elf){};
    
}

pub fn main() !void {
    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena.deinit();
    // const allocator = arena.allocator();

    const input_str = comptime input_text();
    const elves = parse_elves(input_str);
    std.log.debug("{s}", .{elves});
}