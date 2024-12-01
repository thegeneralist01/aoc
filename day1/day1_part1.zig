const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input", .{});
    const file_reader = file.reader();
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    defer _ = gpa.deinit();

    var left = std.ArrayList(u32).init(ally);
    var right = std.ArrayList(u32).init(ally);
    defer left.deinit();
    defer right.deinit();

    var input_buf = std.ArrayListUnmanaged(u8){};
    defer input_buf.deinit(ally);
    while (true) {
        defer input_buf.clearRetainingCapacity();
        file_reader.streamUntilDelimiter(input_buf.writer(ally), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };

        var integers = std.mem.splitSequence(u8, input_buf.items, "   ");

        const first = std.fmt.parseInt(u32, integers.next().?, 10) catch |err| {
            std.debug.print("Error parsing first integer: {}\n", .{err});
            continue;
        };
        const second = std.fmt.parseInt(u32, integers.next().?, 10) catch |err| {
            std.debug.print("Error parsing second integer: {}\n", .{err});
            continue;
        };

        try left.append(first);
        try right.append(second);

        // std.debug.print("Integers are '{}' and '{}' of types {} and {}\n", .{ first, second, @TypeOf(first), @TypeOf(second) });
    }

    std.mem.sort(u32, left.items, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, right.items, {}, comptime std.sort.asc(u32));

    // We have the two sorted arrays. Now, differences
    var diff: u64 = 0;
    for (0..left.items.len) |i| {
        diff += if (left.items[i] > right.items[i]) @abs(left.items[i] - right.items[i]) else @abs(right.items[i] - left.items[i]);
    }

    std.debug.print("{}\n", .{ diff });
}
