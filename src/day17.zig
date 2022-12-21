const std = @import("std");
const constants = @import("constants.zig");

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day17.txt");
    } else {
        return @embedFile("real_inputs/day17.txt");
    }
}

fn blockWidth(block_type: u8) i8 {
    return switch (block_type) {
        0 => 4,
        1 => 3,
        2 => 3,
        3 => 1,
        4 => 2,
        else => unreachable,
    };
}

fn testBelow(stack: *std.ArrayList(u8), block_type: u8, x_coord: i8, y_coord: usize) bool {
    if (y_coord == 0) {
        return false;
    }
    if (block_type == 0) {
        var block_layer: u8 = 0b1111 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        if ((block_layer & stackGet(stack, y_coord - 1)) == 0) {
            // No overlap below! We can go down.
            return true;
        } else {
            return false;
        }
    } else if (block_type == 1) {
        var block_layer_2: u8 = 0b010 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        var block_layer_1: u8 = 0b111 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        var block_layer_0: u8 = 0b010 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        if ((block_layer_0 & stackGet(stack, y_coord - 1)) == 0 and (block_layer_1 & stackGet(stack, y_coord)) == 0 and (block_layer_2 & stackGet(stack, y_coord + 1)) == 0) {
            // No overlap below! We can go down.
            return true;
        } else {
            return false;
        }
    } else if (block_type == 2) {
        var block_layer_2: u8 = 0b001 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        var block_layer_1: u8 = 0b001 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        var block_layer_0: u8 = 0b111 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        if ((block_layer_0 & stackGet(stack, y_coord - 1)) == 0 and (block_layer_1 & stackGet(stack, y_coord)) == 0 and (block_layer_2 & stackGet(stack, y_coord + 1)) == 0) {
            // No overlap below! We can go down.
            return true;
        } else {
            return false;
        }
    } else if (block_type == 3) {
        var block_layer_3: u8 = 0b1 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        var block_layer_2: u8 = 0b1 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        var block_layer_1: u8 = 0b1 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        var block_layer_0: u8 = 0b1 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        if ((block_layer_0 & stackGet(stack, y_coord - 1)) == 0 and (block_layer_1 & stackGet(stack, y_coord)) == 0 and (block_layer_2 & stackGet(stack, y_coord + 1)) == 0 and (block_layer_3 & stackGet(stack, y_coord + 2)) == 0) {
            // No overlap below! We can go down.
            return true;
        } else {
            return false;
        }
    } else if (block_type == 4) {
        var block_layer_1: u8 = 0b11 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        var block_layer_0: u8 = 0b11 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        if ((block_layer_0 & stackGet(stack, y_coord - 1)) == 0 and (block_layer_1 & stackGet(stack, y_coord)) == 0) {
            // No overlap below! We can go down.
            return true;
        } else {
            return false;
        }
    } else {
        std.log.debug("Block type was {}\n", .{block_type});
    }
    unreachable;
}

fn checkLateral(stack: *std.ArrayList(u8), block_type: u8, x_coord: i8, y_coord: usize, instruction: i8) bool {
    var new_x_coord = x_coord + instruction;
    new_x_coord = @max(new_x_coord, 0);
    new_x_coord = @min(new_x_coord, 7 - blockWidth(block_type));
    if (block_type == 0) {
        var block_layer: u8 = 0b1111 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - new_x_coord));
        if ((block_layer & stackGet(stack, y_coord) == 0)) {
            // It can move without overlap
            return true;
        } else {
            return false;
        }
    }
    if (block_type == 1) {
        var block_layer_2: u8 = 0b010 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - new_x_coord));
        var block_layer_1: u8 = 0b111 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - new_x_coord));
        var block_layer_0: u8 = 0b010 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - new_x_coord));

        if ((block_layer_0 & stackGet(stack, y_coord)) == 0 and (block_layer_1 & stackGet(stack, y_coord + 1)) == 0 and (block_layer_2 & stackGet(stack, y_coord + 2)) == 0) {
            // It can move without overlap
            return true;
        } else {
            return false;
        }
    } else if (block_type == 2) {
        var block_layer_2: u8 = 0b001 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - new_x_coord));
        var block_layer_1: u8 = 0b001 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - new_x_coord));
        var block_layer_0: u8 = 0b111 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - new_x_coord));

        if ((block_layer_0 & stackGet(stack, y_coord)) == 0 and (block_layer_1 & stackGet(stack, y_coord + 1)) == 0 and (block_layer_2 & stackGet(stack, y_coord + 2)) == 0) {
            // It can move without overlap
            return true;
        } else {
            return false;
        }
    } else if (block_type == 3) {
        var block_layer_3: u8 = 0b1 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - new_x_coord));
        var block_layer_2: u8 = 0b1 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - new_x_coord));
        var block_layer_1: u8 = 0b1 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - new_x_coord));
        var block_layer_0: u8 = 0b1 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - new_x_coord));

        if ((block_layer_0 & stackGet(stack, y_coord)) == 0 and (block_layer_1 & stackGet(stack, y_coord + 1)) == 0 and (block_layer_2 & stackGet(stack, y_coord + 2)) == 0 and (block_layer_3 & stackGet(stack, y_coord + 3)) == 0) {
            // It can move without overlap
            return true;
        } else {
            return false;
        }
    } else if (block_type == 4) {
        var block_layer_1: u8 = 0b11 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - new_x_coord));
        var block_layer_0: u8 = 0b11 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - new_x_coord));

        if ((block_layer_0 & stackGet(stack, y_coord)) == 0 and (block_layer_1 & stackGet(stack, y_coord + 1)) == 0) {
            // It can move without overlap
            return true;
        } else {
            return false;
        }
    }
    unreachable;
}

fn stackGet(stack: *std.ArrayList(u8), index: usize) u8 {
    if (stack.items.len > index) {
        return stack.items[index];
    } else {
        return 0;
    }
}

fn stackSet(stack: *std.ArrayList(u8), index: usize, value: u8) !void {
    while (stack.*.items.len <= index) {
        try stack.*.append(0);
    }

    stack.*.items[index] = value;
}

fn stackOr(stack: *std.ArrayList(u8), index: usize, value: u8) !void {
    try stackSet(stack, index, value | stackGet(stack, index));
}

fn updateStack(stack: *std.ArrayList(u8), block_type: u8, x_coord: i8, y_coord: usize) !usize {
    if (block_type == 0) {
        var block_layer: u8 = 0b1111 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        try stackOr(stack, y_coord, block_layer);
        return y_coord;
    } else if (block_type == 1) {
        var block_layer_2: u8 = 0b010 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        var block_layer_1: u8 = 0b111 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        var block_layer_0: u8 = 0b010 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        try stackOr(stack, y_coord, block_layer_0);
        try stackOr(stack, y_coord + 1, block_layer_1);
        try stackOr(stack, y_coord + 2, block_layer_2);
        return y_coord + 2;
    } else if (block_type == 2) {
        var block_layer_2: u8 = 0b001 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        var block_layer_1: u8 = 0b001 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        var block_layer_0: u8 = 0b111 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        try stackOr(stack, y_coord, block_layer_0);
        try stackOr(stack, y_coord + 1, block_layer_1);
        try stackOr(stack, y_coord + 2, block_layer_2);
        return y_coord + 2;
    } else if (block_type == 3) {
        var block_layer_3: u8 = 0b1 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        var block_layer_2: u8 = 0b1 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        var block_layer_1: u8 = 0b1 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        var block_layer_0: u8 = 0b1 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        try stackOr(stack, y_coord, block_layer_0);
        try stackOr(stack, y_coord + 1, block_layer_1);
        try stackOr(stack, y_coord + 2, block_layer_2);
        try stackOr(stack, y_coord + 3, block_layer_3);
        return y_coord + 3;
    } else if (block_type == 4) {
        var block_layer_1: u8 = 0b11 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        var block_layer_0: u8 = 0b11 * std.math.pow(u8, 2, @intCast(u8, (7 - blockWidth(block_type)) - x_coord));
        try stackOr(stack, y_coord, block_layer_0);
        try stackOr(stack, y_coord + 1, block_layer_1);
        return y_coord + 1;
    }
    unreachable;
}

fn debugStack(stack: *[]u8) void {
    var ptr: usize = stack.len;
    while (ptr > 0) : (ptr -= 1) {
        var line: [7]u8 = [_]u8{ 0, 0, 0, 0, 0, 0, 0 };
        if (stack[ptr - 1] != 0) {
            if (stack[ptr - 1] & 0b1000000 > 0) {
                line[0] = '#';
            } else {
                line[0] = '.';
            }
            if (stack[ptr - 1] & 0b0100000 > 0) {
                line[1] = '#';
            } else {
                line[1] = '.';
            }
            if (stack[ptr - 1] & 0b0010000 > 0) {
                line[2] = '#';
            } else {
                line[2] = '.';
            }
            if (stack[ptr - 1] & 0b0001000 > 0) {
                line[3] = '#';
            } else {
                line[3] = '.';
            }
            if (stack[ptr - 1] & 0b0000100 > 0) {
                line[4] = '#';
            } else {
                line[4] = '.';
            }
            if (stack[ptr - 1] & 0b0000010 > 0) {
                line[5] = '#';
            } else {
                line[5] = '.';
            }
            if (stack[ptr - 1] & 0b0000001 > 0) {
                line[6] = '#';
            } else {
                line[6] = '.';
            }
            std.log.debug("{s}", .{line});
        }
    }
}

fn stackHeight(stack: *std.ArrayList(u8), start: usize) usize {
    var count = @max(15, start) - 15;
    while (stackGet(stack, count) != 0) : (count += 1) {}
    return count;
}

pub fn partA(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var stack = std.ArrayList(u8).init(allocator);
    var block_count: usize = 0;
    var step: usize = 0;
    var stack_top: usize = 0;
    while (block_count < 2022) {
        var block_type: u8 = @intCast(u8, @mod(block_count, 5));
        var y_coord: usize = stack_top;
        var x_coord: i8 = 2;
        var instruction: i8 = 0;

        instruction = @intCast(i8, input[@mod(step, input.len)]) - 61; // converts '<' to -1, '>' to +1
        x_coord += instruction;
        x_coord = @max(x_coord, 0);
        x_coord = @min(x_coord, 7 - blockWidth(block_type));
        step += 1;

        instruction = @intCast(i8, input[@mod(step, input.len)]) - 61;
        x_coord += instruction;
        x_coord = @max(x_coord, 0);
        x_coord = @min(x_coord, 7 - blockWidth(block_type));
        step += 1;

        instruction = @intCast(i8, input[@mod(step, input.len)]) - 61;
        x_coord += instruction;
        x_coord = @max(x_coord, 0);
        x_coord = @min(x_coord, 7 - blockWidth(block_type));
        step += 1;

        instruction = @intCast(i8, input[@mod(step, input.len)]) - 61;
        x_coord += instruction;
        x_coord = @max(x_coord, 0);
        x_coord = @min(x_coord, 7 - blockWidth(block_type));
        step += 1;

        // Now if it goes down it might hit a previous block
        while (testBelow(&stack, block_type, x_coord, y_coord)) {
            y_coord -= 1;
            // Room to move down, grab next instruction, drop y, etc.
            instruction = @intCast(i8, input[@mod(step, input.len)]) - 61;
            // Check if block can move in instruction direction
            if (checkLateral(&stack, block_type, x_coord, y_coord, instruction)) {
                x_coord += instruction;
                x_coord = @max(x_coord, 0);
                x_coord = @min(x_coord, 7 - blockWidth(block_type));
            }
            step += 1;
        }

        // Resting on floor or another block
        // update stack
        _ = try updateStack(&stack, block_type, x_coord, y_coord);
        stack_top = stackHeight(&stack, y_coord);

        block_count += 1;
    }
    // debugStack(&stack);
    return stackHeight(&stack, 0);
}

pub fn partB(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var stack = std.ArrayList(u8).init(allocator);
    var block_count: usize = 0;
    var step: usize = 0;
    var stack_top: usize = 0;
    // const piece = 79263 * @divFloor(1000000000000, 50455);
    // 158526 158536 = 78273
    // 237799
    while (block_count < 3160) {
        var y_coord: usize = stack_top;
        var block_type: u8 = @intCast(u8, @mod(block_count, 5));
        var x_coord: i8 = 2;
        var instruction: i8 = 0;

        instruction = @intCast(i8, input[@mod(step, input.len)]) - 61; // converts '<' to -1, '>' to +1
        x_coord += instruction;
        x_coord = @max(x_coord, 0);
        x_coord = @min(x_coord, 7 - blockWidth(block_type));
        step += 1;

        instruction = @intCast(i8, input[@mod(step, input.len)]) - 61;
        x_coord += instruction;
        x_coord = @max(x_coord, 0);
        x_coord = @min(x_coord, 7 - blockWidth(block_type));
        step += 1;

        instruction = @intCast(i8, input[@mod(step, input.len)]) - 61;
        x_coord += instruction;
        x_coord = @max(x_coord, 0);
        x_coord = @min(x_coord, 7 - blockWidth(block_type));
        step += 1;

        instruction = @intCast(i8, input[@mod(step, input.len)]) - 61;
        x_coord += instruction;
        x_coord = @max(x_coord, 0);
        x_coord = @min(x_coord, 7 - blockWidth(block_type));
        step += 1;

        // Now if it goes down it might hit a previous block
        while (testBelow(&stack, block_type, x_coord, y_coord)) {
            y_coord -= 1;
            // Room to move down, grab next instruction, drop y, etc.
            instruction = @intCast(i8, input[@mod(step, input.len)]) - 61;
            // Check if block can move in instruction direction
            if (checkLateral(&stack, block_type, x_coord, y_coord, instruction)) {
                x_coord += instruction;
                x_coord = @max(x_coord, 0);
                x_coord = @min(x_coord, 7 - blockWidth(block_type));
            }
            step += 1;
        }

        // Resting on floor or another block
        // update stack
        _ = try updateStack(&stack, block_type, x_coord, y_coord);
        stack_top = stackHeight(&stack, y_coord);

        block_count += 1;
        if (stack_top == 133) {
            std.log.err("{} {}", .{ block_count, stack_top });
        }
        if (stack_top == 2702 + 133) {
            std.log.err("{} {}", .{ block_count, stack_top });
        }
        if (stack_top == 2702 * 2 + 133) {
            std.log.err("{} {}", .{ block_count, stack_top });
        }
        if (stack_top == 2702 * 3 + 133) {
            std.log.err("{} {}", .{ block_count, stack_top });
        }
        if (stack_top == 2702 * 4 + 133) {
            std.log.err("{} {}", .{ block_count, stack_top });
        }
        if (block_count > input.len * 15) {
            var offset: usize = 0;
            while (offset < input.len * 5 * 4) : (offset += 1) {
                // var block_length = input.len*5;
                var block_length: usize = 10;
                while (block_length < input.len * 5 * 4) : (block_length += 1) {
                    var lower = stack.items[offset .. offset + block_length];
                    var upper = stack.items[offset + block_length .. offset + block_length * 2];
                    if (constants.strEq(lower, upper)) {
                        std.log.err("Found duplcate, offset {} num_rows {}", .{ offset, block_length });
                        std.process.exit(0);
                    }
                }
            }
        }
    }

    // 581395348 cycles
    // 86 + (581395348*1720) + 1354 = 1 trillion pieces
    // 86+1720+1354 = 3160 pieces
    // 133+2702+(2153) = 4988
    // 133+(581395348*2702)+2153 = 1570930232582
    return 581395347 * 2702 + stackHeight(&stack, 0);
}
