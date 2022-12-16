const std = @import("std");
const constants = @import("constants.zig");

fn inputText() []const u8 {
    if (constants.TESTING) {
        return @embedFile("test_inputs/day15.txt");
    } else {
        return @embedFile("real_inputs/day15.txt");
    }
}

const Coord = struct {
    x: isize,
    y: isize,
};

const BoundingBox = struct {
    p1: Coord,
    p2: Coord,
};

const Sensor = struct {
    loc: Coord,
    beacon: Coord,
    r: usize,

    fn boundingBox(self: *const Sensor) BoundingBox {
        return BoundingBox{
            .p1 = Coord{
                .x = self.loc.x - @intCast(isize, self.r),
                .y = self.loc.y - @intCast(isize, self.r),
            },
            .p2 = Coord{
                .x = self.loc.x + @intCast(isize, self.r),
                .y = self.loc.y + @intCast(isize, self.r),
            },
        };
    }
};

fn parseCoord(input: []const u8) !Coord {
    var parts = std.mem.split(u8, input, ", ");
    var x_parts = std.mem.split(u8, parts.next().?, "=");
    var y_parts = std.mem.split(u8, parts.next().?, "=");
    _ = x_parts.next();
    var x_coord = x_parts.next().?;
    _ = y_parts.next();
    var y_coord = y_parts.next().?;
    return Coord{ .x = try std.fmt.parseInt(isize, x_coord, 10), .y = try std.fmt.parseInt(isize, y_coord, 10) };
}

fn parseLine(input: []const u8) !Sensor {
    var parts = std.mem.split(u8, input, ": closest beacon is at ");
    var sensor_part = parts.next().?;
    var sensor_coord = try parseCoord(sensor_part);
    var beacon_part = parts.next().?;
    var beacon_coord = try parseCoord(beacon_part);
    var radius: usize = std.math.absCast(sensor_coord.x - beacon_coord.x) + std.math.absCast(sensor_coord.y - beacon_coord.y);
    var sensor = Sensor{ .loc = sensor_coord, .r = radius, .beacon = beacon_coord };
    return sensor;
}

fn parseInput(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(Sensor) {
    var result = std.ArrayList(Sensor).init(allocator);
    var lines = std.mem.tokenize(u8, input, "\r\n");
    while (lines.next()) |line| {
        const sensor = try parseLine(line);
        try result.append(sensor);
    }
    return result;
}

fn checkCoverageOnLine(allocator: std.mem.Allocator, sensors: []Sensor, line: usize) !usize {
    var covered = std.ArrayList(isize).init(allocator);
    defer covered.deinit();
    var beacons = std.ArrayList(isize).init(allocator);
    defer beacons.deinit();
    for (sensors) |s| {
        var bb = s.boundingBox();
        var low = bb.p1.y;
        var hi = bb.p2.y;

        if (low <= line and hi >= line) {
            // bounding box covers target line, save it for further examination
            var y_dist = std.math.absCast(s.loc.y - @intCast(isize, line));
            var left_right_coverage = s.r - y_dist; // if s.r == y_dist, coverage is only 1: x value
            try covered.append(s.loc.x);
            if (s.beacon.y == line) {
                try beacons.append(s.beacon.x);
            }
            while (left_right_coverage > 0) : (left_right_coverage -= 1) {
                try covered.append(s.loc.x + @intCast(isize, left_right_coverage)); // This far left and right
                try covered.append(s.loc.x - @intCast(isize, left_right_coverage));
            }
        }
    }
    // covered now contains a list (with dupes) of all points covered
    // convert to set and back
    var set = std.AutoHashMap(isize, void).init(allocator);
    defer set.deinit();

    for (covered.items) |item| {
        try set.put(item, {});
    }
    for (beacons.items) |item| {
        _ = set.remove(item);
    }

    var deduped = set.keyIterator();
    var count: usize = 0;
    while (deduped.next()) |_| {
        count += 1;
    }
    return count;
}

pub fn partA(allocator: std.mem.Allocator) !usize {
    const input = comptime inputText();
    var sensors = try parseInput(allocator, input);
    var line: usize = undefined;
    if (constants.TESTING) {
        line = 10;
    } else {
        line = 2000000;
    }
    var coverage = checkCoverageOnLine(allocator, sensors.items, line);
    return coverage;
}

fn coordDist(a: *const Coord, b: *const Coord) usize {
    return std.math.absCast(a.x - b.x) + std.math.absCast(a.y - b.y);
}

fn coordContainedBySensor(coord: *const Coord, sensor: *const Sensor) bool {
    return coordDist(&sensor.loc, coord) <= sensor.r;
}

pub fn partB(allocator: std.mem.Allocator) !usize {
    var border_val: usize = undefined;
    if (constants.TESTING) {
        border_val = 20;
    } else {
        border_val = 4_000_000;
    }
    const input = comptime inputText();
    var sensors = try parseInput(allocator, input);
    var borders = std.AutoHashMap(Coord, void).init(allocator);
    var i: usize = 0;
    for (sensors.items) |sensor| {
        i += 1;
        var iradius: isize = @intCast(isize, sensor.r);
        var x = sensor.loc.x - iradius;
        if (x >= 0 and x <= border_val) {
            try borders.put(Coord{ .x = sensor.loc.x - iradius - 1, .y = sensor.loc.y }, {});
            try borders.put(Coord{ .x = sensor.loc.x - iradius + 1, .y = sensor.loc.y }, {});
        }
        while (x < sensor.loc.x + iradius) : (x += 1) {
            // Add above and below
            if (x >= 0 and x <= border_val) {
                const vert_dist = 1 + iradius - (try std.math.absInt(sensor.loc.x - x));
                var top_y = sensor.loc.y + vert_dist;
                var bottom_y = sensor.loc.y - vert_dist;
                if (top_y >= 0 and top_y <= border_val) {
                    try borders.put(Coord{ .x = x, .y = top_y }, {});
                }
                if (bottom_y >= 0 and bottom_y <= border_val) {
                    try borders.put(Coord{ .x = x, .y = bottom_y }, {});
                }
            }
        }
    }

    var it = borders.keyIterator();
    while (it.next()) |item| {
        if (item.x >= 0 and item.x <= border_val and item.y >= 0 and item.y <= border_val) {
            var foundit: bool = true;
            for (sensors.items) |sensor| {
                if (coordContainedBySensor(item, &sensor)) {
                    foundit = false;
                    break;
                }
            }
            if (foundit) {
                // Holy cow we found it!!!
                return @intCast(usize, item.x * 4_000_000 + item.y);
            }
        }
    }

    return error.NotFoundError;
}
