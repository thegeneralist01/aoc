const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input2", .{});
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
    }

    std.mem.sort(u32, left.items, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, right.items, {}, comptime std.sort.asc(u32));

    // We have the two sorted arrays. Now, similarity score
    var occurances = std.AutoHashMap(u32, usize).init(ally);
    defer occurances.deinit();
    for (left.items) |element| {
        const needle = &[_]u32{element};
        _ = try occurances.put(element, std.mem.count(u32, right.items, needle));
    }

    var n_occurances: u64 = 0;
    for (left.items) |element| {
        n_occurances += element * occurances.get(element).?;
    }

    std.debug.print("{}\n", .{ n_occurances });
}
