const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input", .{});
    const file_reader = file.reader();
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    defer _ = gpa.deinit();

    var input_buf = std.ArrayListUnmanaged(u8){};
    defer input_buf.deinit(ally);
    var integer_buf = std.ArrayListUnmanaged(u32){};
    defer integer_buf.deinit(ally);
    var integer_slice = std.ArrayList(u32).init(ally);
    defer integer_slice.deinit();

    var safe_levels: u32 = 0;
    while (true) {
        defer input_buf.clearRetainingCapacity();
        file_reader.streamUntilDelimiter(input_buf.writer(ally), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => break,
        };

        var integers = std.mem.splitSequence(u8, input_buf.items, " ");
        const integer_count: usize = integers.rest().len;
        try integer_buf.ensureTotalCapacity(ally, integer_count);

        var asc = true;
        var last_int: u32 = 0;
        var diff: u32 = 0;
        var safe: bool = true;

        integers = std.mem.splitSequence(u8, input_buf.items, " ");
        integer_slice.clearRetainingCapacity();
        while (integers.next()) |integer| {
            const int = std.fmt.parseInt(u32, integer, 10) catch |err| {
                std.debug.print("Error parsing integer: {}\n", .{err});
                continue;
            };
            try integer_slice.append(int);
        }

        for (integer_slice.items, 0..) |integer, i| {
            if (i == 0) continue;
            last_int = integer_slice.items[i - 1];

            // Check diff
            diff = if (integer > last_int) @abs(integer - last_int) else @abs(last_int - integer);
            if (diff < 1 or diff > 3) {
                safe = false;
                break;
            }

            // Establish order - asc/desc
            if (i == 1) {
                asc = integer > last_int;
                continue;
            }

            if ((integer > last_int) != asc) {
                safe = false;
                break;
            }
        }

        if (safe) {
            safe_levels += 1;
        }
    }

    std.debug.print("{}\n", .{safe_levels});
}
