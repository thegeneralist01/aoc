const std = @import("std");
const input = @embedFile("input");

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

fn diagonal_mas_exists(grid: [][]const u8, start_x: i64, start_y: i64, direction: Direction) bool {
    const mas1 = "MAS";
    const mas2 = "SAM";

    var bmas1 = true;
    var bmas2 = true;

    var x = start_x;
    var y = start_y;
    for (mas1) |c| {
        if (x < 0 or y < 0 or y >= grid.len or x >= grid[@intCast(y)].len or grid[@intCast(y)][@intCast(x)] != c) {
            bmas1 = false;
            break;
        }
        x += direction.x;
        y += direction.y;
    }
    x = start_x;
    y = start_y;
    for (mas2) |c| {
        if (x < 0 or y < 0 or y >= grid.len or x >= grid[@intCast(y)].len or grid[@intCast(y)][@intCast(x)] != c) {
            bmas2 = false;
            break;
        }
        x += direction.x;
        y += direction.y;
    }

    return bmas1 or bmas2;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    defer _ = gpa.deinit();

    var lines = std.mem.tokenize(u8, input, "\n");

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
            if (diagonal_mas_exists(grid.items, @as(i64, @intCast(x)) - 1, @as(i64, @intCast(y)) - 1, Direction.DownRight)
            and diagonal_mas_exists(grid.items, @as(i64, @intCast(x)) - 1, @as(i64, @intCast(y)) + 1, Direction.UpRight)) xmas += 1;
        }
    }
    std.debug.print("XMAS count: {}\n", .{xmas});
}
