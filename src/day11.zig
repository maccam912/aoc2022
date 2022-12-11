const std = @import("std");
const constants = @import("constants.zig");

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day11.txt");
    } else {
        return @embedFile("real_inputs/day11.txt");
    }
}

const Operation = enum {
    plus,
    minus,
    times,
};

const Op = struct {
    operation: Operation,
    operand: isize, // -1 here means "old"
};

fn parseOp(line: []const u8) !Op {
    var parts = std.mem.split(u8, line, "Operation: new = old");
    _ = parts.next();
    var details = parts.next().?;
    var op_parts = std.mem.split(u8, details, " ");
    _ = op_parts.next();
    var operation_line = op_parts.next().?;
    var operand_line = op_parts.next().?;

    var operand: isize = 0;
    if (constants.strEq(operand_line, "old")) {
        operand = -1;
    } else {
        operand = try std.fmt.parseInt(isize, operand_line, 10);
    }

    return switch (operation_line[0]) {
        '+' => Op{ .operation = Operation.plus, .operand = operand },
        '-' => Op{ .operation = Operation.minus, .operand = operand },
        '*' => Op{ .operation = Operation.times, .operand = operand },
        else => return error.InvalidCharacter,
    };
}

fn parseDiv(line: []const u8) !isize {
    var parts = std.mem.split(u8, line, "Test: divisible by ");
    _ = parts.next();
    var num_line = parts.next().?;
    return try std.fmt.parseInt(isize, num_line, 10);
}

fn parseMonkey(line: []const u8) !usize {
    var parts = std.mem.split(u8, line, "throw to monkey ");
    _ = parts.next();
    var monkey_num_line = parts.next().?;
    return try std.fmt.parseInt(usize, monkey_num_line, 10);
}

const Monkey = struct {
    items: std.ArrayList(isize),
    op: Op,
    div: isize,
    true_monkey: usize,
    false_monkey: usize,
    inspection_count: usize,
    allocator: std.mem.Allocator,

    fn new(allocator: std.mem.Allocator, chunk: []const u8) !Monkey {
        var parts = std.mem.split(u8, chunk, "\n");
        _ = parts.next().?;
        var starting_items_line = parts.next().?;
        var op_line = parts.next().?;
        var div_line = parts.next().?;
        var true_monkey_line = parts.next().?;
        var false_monkey_line = parts.next().?;

        return Monkey.init(allocator, starting_items_line, try parseOp(op_line), try parseDiv(div_line), try parseMonkey(true_monkey_line), try parseMonkey(false_monkey_line));
    }

    fn init(allocator: std.mem.Allocator, starting_items: []const u8, op: Op, div: isize, true_monkey: usize, false_monkey: usize) !Monkey {
        var items = std.ArrayList(isize).init(allocator);
        var items_section = std.mem.split(u8, starting_items, "Starting items: ");
        _ = items_section.next();
        var items_str = items_section.next().?;
        var items_strs = std.mem.split(u8, items_str, ", ");
        while (items_strs.next()) |individual_item_str| {
            var item_num = try std.fmt.parseInt(isize, individual_item_str, 10);
            try items.append(item_num);
        }

        return Monkey{ .items = items, .op = op, .div = div, .true_monkey = true_monkey, .false_monkey = false_monkey, .inspection_count = 0, .allocator = allocator };
    }

    fn deinit(self: *Monkey) void {
        self.items.deinit();
    }

    fn resetItems(self: Monkey) void {
        self.items.deinit();
        self.items = std.ArrayList(isize).init(self.allocator);
    }
};

fn runRound(l: []Monkey, div_worry_level: bool, modulo: isize) !void {
    var i: usize = 0;
    for (l) |monkey| {
        for (monkey.items.items) |item| {
            var operand: isize = monkey.op.operand;
            if (operand == -1) {
                operand = item;
            }
            var new_worry_level: isize = undefined;
            if (monkey.op.operation == Operation.plus) {
                new_worry_level = item + operand;
            } else if (monkey.op.operation == Operation.minus) {
                new_worry_level = item - operand;
            } else if (monkey.op.operation == Operation.times) {
                new_worry_level = item * operand;
            }

            if (div_worry_level) {
                new_worry_level = @divFloor(new_worry_level, 3);
            } else {
                // Do modulo
                new_worry_level = @mod(new_worry_level, modulo);
            }
            l[i].inspection_count += 1;

            var test_result: bool = try std.math.mod(isize, new_worry_level, monkey.div) == 0;
            if (test_result) {
                try l[monkey.true_monkey].items.append(new_worry_level);
            } else {
                try l[monkey.false_monkey].items.append(new_worry_level);
            }
        }
        l[i].items.clearAndFree();
        i += 1;
    }
}

pub fn partA(allocator: std.mem.Allocator) !u64 {
    const MonkeyList = std.ArrayList(Monkey);
    var monkey_list = MonkeyList.init(allocator);
    defer monkey_list.deinit();

    const input = comptime inputText();
    var monkeys = std.mem.split(u8, input, "\n\n");
    while (monkeys.next()) |chunk| {
        var monkey: Monkey = try Monkey.new(allocator, chunk);
        try monkey_list.append(monkey);
    }

    var i: usize = 0;
    while (i < 20) : (i += 1) {
        try runRound(monkey_list.items, true, 0);
    }

    var a: usize = 0;
    var b: usize = 0;
    for (monkey_list.items) |monkey| {
        if (monkey.inspection_count > b) {
            b = a;
            a = monkey.inspection_count;
            if (b > a) {
                var tmp = a;
                a = b;
                b = tmp;
            }
        }
    }
    return a * b;
}

pub fn partB(allocator: std.mem.Allocator) !u64 {
    const MonkeyList = std.ArrayList(Monkey);
    var monkey_list = MonkeyList.init(allocator);
    defer monkey_list.deinit();

    const input = comptime inputText();
    var divs = std.ArrayList(isize).init(allocator);
    var monkeys = std.mem.split(u8, input, "\n\n");
    while (monkeys.next()) |chunk| {
        var monkey: Monkey = try Monkey.new(allocator, chunk);
        try monkey_list.append(monkey);
        try divs.append(monkey.div);
    }

    var prod: isize = 1;
    for (divs.items) |d| {
        prod *= d;
    }

    var i: usize = 0;
    while (i < 10000) : (i += 1) {
        try runRound(monkey_list.items, false, prod);
    }

    var a: usize = 0;
    var b: usize = 0;
    for (monkey_list.items) |monkey| {
        if (monkey.inspection_count > b) {
            b = a;
            a = monkey.inspection_count;
            if (b > a) {
                var tmp = a;
                a = b;
                b = tmp;
            }
        }
    }
    return a * b;
}
