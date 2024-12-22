const std = @import("std");
const in = @embedFile("in");

const Direction = struct {
    x: i32,
    y: i32,

    const Left = Direction{ .x = -1, .y = 0 };
    const Right = Direction{ .x = 1, .y = 0 };
    const Up = Direction{ .x = 0, .y = -1 };
    const Down = Direction{ .x = 0, .y = 1 };

    pub fn eql(self: Direction, other: Direction) bool {
        return self.x == other.x and self.y == other.y;
    }
};

fn array_includes(comptime T: type, haystack: []T, needle: T) bool {
    for (haystack) |item| {
        if (item == needle) {
            return true;
        }
    }
    return false;
}

fn turn_right(direction: Direction) Direction {
    if (direction.eql(Direction.Up)) {
        return Direction.Right;
    } else if (direction.eql(Direction.Right)) {
        return Direction.Down;
    } else if (direction.eql(Direction.Down)) {
        return Direction.Left;
    } else if (direction.eql(Direction.Left)) {
        return Direction.Up;
    }
    unreachable;
}

fn find_guard(lines: std.ArrayList(std.ArrayList(i8))) [2]i32 {
    for (lines.items, 0..) |line, y| {
        for (line.items, 0..) |item, x| {
            if (item == 1) {
                return .{ @intCast(x), @intCast(y) };
            }
        }
    }
    unreachable;
}

fn print_lines(lines: std.ArrayList(std.ArrayList(i8))) void {
    for (lines.items) |line| {
        for (line.items) |item| {
            switch (item) {
                -1 => std.debug.print("#", .{}),
                0 => std.debug.print(".", .{}),
                1 => std.debug.print("^", .{}),
                2 => std.debug.print("V", .{}),
                else => std.debug.print(" ", .{}),
            }
        }
        std.debug.print("\n", .{});
    }
}

fn count_visited(lines: std.ArrayList(std.ArrayList(i8))) u32 {
    var count: u32 = 0;
    for (lines.items) |line| {
        for (line.items) |e| {
            if (e == 2 or e == 1) count += 1;
        }
    }
    return count;
}

fn move(lines: std.ArrayList(std.ArrayList(i8)), direction: Direction) void {
    // print_lines(lines);
    // std.debug.print("\n", .{});

    const pos = find_guard(lines);
    var x = pos[0];
    var y = pos[1];
    lines.items[@intCast(y)].items[@intCast(x)] = 2; // 2 for already visited
    x += direction.x;
    y += direction.y;

    if (y < 0 or y >= lines.items.len or x < 0 or x >= lines.items[@intCast(y)].items.len) {
        return;
    }

    if (lines.items[@intCast(y)].items[@intCast(x)] == -1) {
        x -= direction.x;
        y -= direction.y;
        lines.items[@intCast(y)].items[@intCast(x)] = 1;
        return move(lines, turn_right(direction));
    }

    lines.items[@intCast(y)].items[@intCast(x)] = 1;
    return move(lines, direction);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    defer _ = gpa.deinit();

    var lines = std.ArrayList(std.ArrayList(i8)).init(ally);
    defer {
        for (lines.items) |*line| {
            line.deinit();
        }
        lines.deinit();
    }

    var in_lines = std.mem.tokenize(u8, in, "\n");
    while (in_lines.next()) |linestr| {
        var line = std.ArrayList(i8).init(ally);
        for (linestr) |c| {
            const value: i8 = switch (c) {
                '#' => -1,
                '.' => 0,
                '^' => 1,
                else => -2,
            };
            try line.append(value);
        }
        try lines.append(line);
    }

    move(lines, Direction.Up);
    const moves = count_visited(lines);

    std.debug.print("{d}\n", .{moves});
}
