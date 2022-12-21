const std = @import("std");
const constants = @import("constants.zig");

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day07.txt");
    } else {
        return @embedFile("real_inputs/day07.txt");
    }
}

const File = struct {
    size: usize,
};

const Dir = struct {
    parent: ?*Dir,
    files: std.StringHashMap(File),
    subdirs: std.StringHashMap(Dir),
    allocator: std.mem.Allocator,

    fn init(allocator: std.mem.Allocator, name: []const u8) Dir {
        _ = name;
        const FileMap = std.StringHashMap(File);
        const DirMap = std.StringHashMap(Dir);
        return Dir{ .parent = null, .files = FileMap.init(allocator), .subdirs = DirMap.init(allocator), .allocator = allocator };
    }

    fn addFile(self: *Dir, name: []const u8, size: usize) !void {
        var file: File = File{ .size = size };
        try self.files.put(name, file);
    }

    fn addDir(self: *Dir, name: []const u8) !void {
        var dir: Dir = Dir.init(self.allocator, name);
        dir.parent = self;
        try self.subdirs.put(name, dir);
    }

    fn deinit(self: *Dir) void {
        self.files.deinit();
        var it = self.subdirs.iterator();
        while (it.next()) |subdir| {
            subdir.value_ptr.deinit();
        }
        self.subdirs.deinit();
        self.* = undefined;
    }

    fn getTotalSize(self: *Dir) usize {
        var sum: usize = 0;
        var it_files = self.files.iterator();
        while (it_files.next()) |file| {
            sum += file.value_ptr.size;
        }

        var it_dirs = self.subdirs.iterator();
        while (it_dirs.next()) |subdir| {
            sum += subdir.value_ptr.getTotalSize();
        }
        return sum;
    }

    fn createSizesList(self: *Dir, list: *std.ArrayList(usize)) !void {
        var it = self.subdirs.iterator();
        while (it.next()) |subdir| {
            try subdir.value_ptr.createSizesList(list);
        }
        try list.append(self.getTotalSize());
    }
};

const Shell = struct {
    fs: Dir,
    cwd: *Dir,

    fn init(allocator: std.mem.Allocator) Shell {
        var root = Dir.init(allocator, "root");
        return Shell{ .fs = root, .cwd = &root };
    }

    fn deinit(self: *Shell) void {
        self.fs.deinit();
    }
};

fn handleCommand(cmd: []const u8, shell: *Shell) []const u8 {
    var no_dollar = cmd[2..];
    if (constants.strEq(no_dollar[0..2], "ls")) {
        return "ls";
    } else if (constants.strEq(no_dollar[0..2], "cd")) {
        var path = no_dollar[3..];
        if (constants.strEq(path, "..")) {
            // Go up one Dir
            shell.cwd = shell.cwd.parent.?;
        } else if (constants.strEq(path, "/")) {
            // Root
            shell.cwd = &shell.fs;
        } else {
            // Relative path
            shell.cwd = shell.cwd.subdirs.getPtr(path).?;
        }
        return "cd";
    }

    return "";
}

fn handleOutputBuffer(buffer: [][]const u8, cmd: []const u8, shell: *Shell) !void {
    if (constants.strEq(cmd, "ls")) {
        var dir = shell.cwd;
        for (buffer) |line| {
            var parts = std.mem.split(u8, line, " ");
            var a = parts.next().?;
            var b = parts.next().?;
            if (constants.strEq(a, "dir")) {
                try dir.addDir(b);
            } else {
                var a_int = try std.fmt.parseInt(usize, a, 10);
                try dir.addFile(b, a_int);
            }
        }
    }
}

fn run(allocator: std.mem.Allocator, input: []const u8, shell: *Shell) !void {
    const T = std.ArrayList([]const u8);
    var lines = std.mem.split(u8, input, "\n");
    var output_buffer = T.init(allocator);
    defer output_buffer.deinit();
    var cmd: []const u8 = "";

    while (lines.next()) |line| {
        if (line[0] == '$') {
            // Command
            if (output_buffer.items.len > 0) {
                try handleOutputBuffer(output_buffer.items, cmd, shell);
            }
            output_buffer.clearAndFree();
            cmd = handleCommand(line, shell);
        } else {
            try output_buffer.append(line);
        }
    }
    if (output_buffer.items.len > 0) {
        try handleOutputBuffer(output_buffer.items, cmd, shell);
        // shell.fs.debug(0);
    }
    output_buffer.clearAndFree();
}

pub fn partA(allocator: std.mem.Allocator) !usize {
    var shell: Shell = Shell.init(allocator);
    const input = comptime inputText();
    try run(allocator, input, &shell);

    var dir = shell.fs;
    const ListSizes = std.ArrayList(usize);
    var list = ListSizes.init(allocator);
    try dir.createSizesList(&list);
    var sum: usize = 0;
    for (list.items) |item| {
        if (item <= 100000) {
            sum += item;
        }
    }
    return sum;
}

pub fn partB(allocator: std.mem.Allocator) !usize {
    var shell: Shell = Shell.init(allocator);
    const input = comptime inputText();
    try run(allocator, input, &shell);

    var dir = shell.fs;
    const ListSizes = std.ArrayList(usize);
    var list = ListSizes.init(allocator);
    try dir.createSizesList(&list);
    const current_free_space = 70000000 - dir.getTotalSize();
    const min_needed_extra = 30000000 - current_free_space;
    var candidate_size = dir.getTotalSize();
    for (list.items) |item| {
        if (item <= candidate_size and item >= min_needed_extra) {
            candidate_size = item;
        }
    }
    return candidate_size;
}
