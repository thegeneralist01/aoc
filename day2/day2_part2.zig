const std = @import("std");

fn is_safe(integer_slice: std.ArrayList(u32)) bool {
    var asc = true;
    var diff: u32 = 0;
    var safe: bool = true;

    var last_int: u32 = 0;
    var error_ind: i32 = -1;

    for (integer_slice.items, 0..) |integer, i| {
        if (i == 0) continue;
        last_int = integer_slice.items[i - 1];

        // Check diff
        diff = if (integer > last_int) @abs(integer - last_int) else @abs(last_int - integer);
        if (diff < 1 or diff > 3) {
            safe = false;
            error_ind = @intCast(i);
            break;
        }

        // Establish order - asc/desc
        if (i == 1) {
            asc = integer > last_int;
            continue;
        }

        if ((integer > last_int) != asc) {
            safe = false;
            error_ind = @intCast(i);
            break;
        }
    }

    return safe;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input2", .{});
    const file_reader = file.reader();
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    defer _ = gpa.deinit();

    var input_buf = std.ArrayListUnmanaged(u8){};
    defer input_buf.deinit(ally);

    var integer_slice = std.ArrayList(u32).init(ally);
    defer integer_slice.deinit();

    var integer_slice_dup = std.ArrayList(u32).init(ally);
    defer integer_slice_dup.deinit();

    var safe_levels: u32 = 0;
    while (true) {
        defer input_buf.clearRetainingCapacity();
        try file_reader.streamUntilDelimiter(input_buf.writer(ally), '\n', null);

        var integers = std.mem.splitSequence(u8, input_buf.items, " ");
        integer_slice.clearRetainingCapacity();
        while (integers.next()) |integer| {
            const int = try std.fmt.parseInt(u32, integer, 10);
            try integer_slice.append(int);
        }

        var safe = is_safe(integer_slice);

        if (!safe) {
            for (integer_slice.items, 0..) |_, i| {
                integer_slice_dup.clearRetainingCapacity();
                try integer_slice_dup.ensureTotalCapacity(integer_slice.items.len);
                for (integer_slice.items, 0..) |integer, j| {
                    if (i == j) continue;
                    try integer_slice_dup.append(integer);
                }
                safe = is_safe(integer_slice_dup);
                if (safe) break;
            }
        }

        if (safe) {
            safe_levels += 1;
        }
    }

    std.debug.print("{}\n", .{safe_levels});
}
