const std = @import("std");
const in = @embedFile("test");

fn combine_integers(a: i64, b: i64) i64 {
    const b_len = std.fmt.count("{d}", .{b});
    return a * std.math.pow(i64, 10, @intCast(b_len)) + b;
}

fn rec(row: std.ArrayList(i64), result: i64, index: usize, ok: *bool) void {
    if (index == row.items.len) {
        if (result == row.items[0]) {
            ok.* = true;
        }
        return;
    }
    rec(row, result + row.items[index], index + 1, ok);
    rec(row, result * row.items[index], index + 1, ok);
    rec(row, combine_integers(result, row.items[index]), index + 1, ok);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    defer _ = gpa.deinit();

    var numbers = std.ArrayList(std.ArrayList(i64)).init(ally);
    defer {
        for (numbers.items) |*line| {
            line.deinit();
        }
        numbers.deinit();
    }

    var in_lines = std.mem.tokenize(u8, in, "\n");
    while (in_lines.next()) |line| {
        var nums = std.ArrayList(i64).init(ally);
        var iter = std.mem.split(u8, line, " ");

        var i: u32 = 0;
        while (iter.next()) |num| {
            if (i == 0) {
                try nums.append(try std.fmt.parseInt(i64, num[0 .. num.len - 1], 10));
            } else {
                try nums.append(try std.fmt.parseInt(i64, num, 10));
            }
            i += 1;
        }
        try numbers.append(nums);
    }

    var result: i64 = 0;
    var ok = false;
    for (numbers.items) |row| {
        ok = false;
        rec(row, 0, 1, &ok);
        if (ok) result += row.items[0];
    }

    std.debug.print("{d}\n", .{result});
}
