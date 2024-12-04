const std = @import("std");
const input = @embedFile("input");

const Coord = struct {
    x: i32,
    y: i32,
};

const Direction = struct {
    x: i64,
    y: i64,

    const Left = Direction{ .x = -1, .y = 0 };
    const Right = Direction{ .x = 1, .y = 0 };
    const Up = Direction{ .x = 0, .y = -1 };
    const Down = Direction{ .x = 0, .y = 1 };
    const UpLeft = Direction{ .x = -1, .y = -1 };
    const UpRight = Direction{ .x = 1, .y = -1 };
    const DownLeft = Direction{ .x = -1, .y = 1 };
    const DownRight = Direction{ .x = 1, .y = 1 };
};

fn xmas_exists(grid: [][]const u8, start_x: i64, start_y: i64, direction: Direction) bool {
    const xmas = "XMAS";
    var x = start_x;
    var y = start_y;
    for (xmas) |c| {
        if (x < 0 or y < 0 or y >= grid.len or x >= grid[@intCast(y)].len) return false;
        if (grid[@intCast(y)][@intCast(x)] != c) return false;
        x += @intCast(direction.x);
        y += @intCast(direction.y);
    }
    return true;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    defer _ = gpa.deinit();

    var lines = std.mem.tokenize(u8, input, "\r\n");

    var grid = std.ArrayList([]const u8).init(ally);
    defer grid.deinit();

    while (lines.next()) |line| {
        if (line.len > 0) {
            try grid.append(line);
        }
    }

    var xmas: u16 = 0;
    for (grid.items, 0..) |row, y| {
        for (row, 0..) |_, x| {
            if (xmas_exists(grid.items, @intCast(x), @intCast(y), Direction.Left)) xmas += 1;
            if (xmas_exists(grid.items, @intCast(x), @intCast(y), Direction.Right)) xmas += 1;
            if (xmas_exists(grid.items, @intCast(x), @intCast(y), Direction.Up)) xmas += 1;
            if (xmas_exists(grid.items, @intCast(x), @intCast(y), Direction.Down)) xmas += 1;
            if (xmas_exists(grid.items, @intCast(x), @intCast(y), Direction.UpLeft)) xmas += 1;
            if (xmas_exists(grid.items, @intCast(x), @intCast(y), Direction.UpRight)) xmas += 1;
            if (xmas_exists(grid.items, @intCast(x), @intCast(y), Direction.DownLeft)) xmas += 1;
            if (xmas_exists(grid.items, @intCast(x), @intCast(y), Direction.DownRight)) xmas += 1;
        }
    }
    std.debug.print("XMAS count: {}\n", .{xmas});
}
