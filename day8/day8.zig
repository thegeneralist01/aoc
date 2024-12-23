const std = @import("std");
const in = @embedFile("test");

const Point = struct {
    value: u8,
    overlaps: bool,
    x: i32,
    y: i32,
};

fn get_point(grid: *std.ArrayList(std.ArrayList(Point)), x: i32, y: i32) error{NotFound}!Point {
    for (grid.items) |line| {
        for (line.items) |point| {
            if (point.x == x and point.y == y) {
                return point;
            }
        }
    }
    return error.NotFound;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    defer _ = gpa.deinit();

    var grid = std.ArrayList(std.ArrayList(Point)).init(ally);
    defer {
        for (grid.items) |l| {
            l.deinit();
        }
        grid.deinit();
    }

    var points = std.AutoArrayHashMap(u8, std.ArrayList(*Point)).init(ally);
    defer {
        var iter = points.iterator();
        while (iter.next()) |p| {
            p.value_ptr.deinit();
        }
        points.deinit();
    }

    var in_lines = std.mem.tokenize(u8, in, "\n");
    var y: i32 = 0;
    var x: i32 = 0;
    while (in_lines.next()) |l| {
        x = @intCast(l.len);
        var line = std.ArrayList(Point).init(ally);

        for (l, 0..) |c, _x| {
            if (c == '.') {
                try line.append(Point{
                    .value = c,
                    .overlaps = false,
                    .x = @intCast(_x),
                    .y = y,
                });
            } else {
                var point = Point{
                    .value = c,
                    .overlaps = false,
                    .x = @intCast(_x),
                    .y = y,
                };
                try line.append(point);

                var entry = try points.getOrPut(c);
                if (!entry.found_existing) {
                    entry.value_ptr.* = std.ArrayList(*Point).init(ally);
                }
                try entry.value_ptr.append(&point);
            }
        }

        try grid.append(line);
        y += 1;
    }

    var points_iter = points.iterator();
    while (points_iter.next()) |p| {
        const items = p.value_ptr.*;
        for (items.items) |p1| {
            for (items.items) |p2| {
                if (p1 == p2) continue;

                const dx = p2.x - p1.x;
                const dy = p2.y - p1.y;

                const x3 = p2.x + dx;
                const y3 = p2.y + dy;

                if (y3 < 0 or y3 >= y or x3 < 0 or x3 >= x) continue;

                var point = get_point(&grid, x3, y3) catch continue;
                if (point.value == '.') {
                    point.value = '#';
                } else {
                    point.overlaps = true;
                }
            }
        }
    }


    // TODO: overlapping
    var amount: u32 = 0;
    for (grid.items) |row| {
        for (row.items) |p| {
            if (p.value == '#' or p.overlaps == true) {
                amount += 1;
            }
            // std.debug.print("{s}", .{[_]u8{p.value}});
            std.debug.print("{d}", .{@intFromBool(p.overlaps)});
        }
        std.debug.print("  -- amount: {d}\n", .{amount});
    }

    std.debug.print("{d}\n", .{2});
}
