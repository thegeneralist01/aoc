const std = @import("std");

fn is_digit(c: u8) bool {
    return switch (c) {
        '0'...'9' => true,
        else => false,
    };
}

fn parse_mul(s: []const u8) !i32 {
    if (s.len < 8) return -1;
    if (s[0] != 'm') return -1;
    if (s[1] != 'u') return -1;
    if (s[2] != 'l') return -1;
    if (s[3] != '(') return -1;
    var int1: u32 = 0;
    var int2: u32 = 0;
    var comma_ind: usize = 0;
    for (s[4..], 0..) |c, i| {
        if (c == ',') {
            comma_ind = 5+i;
            break;
        } else if (!is_digit(c)) {
            std.debug.print("{c}\n", .{c});
            return -1;
        }
        int1 = int1 * 10 + try std.fmt.parseInt(u16, &[_]u8{c}, 10);
    }
    for (s[comma_ind..]) |c| {
        if (c == ')') {
            break;
        }
        int2 = int2 * 10 + try std.fmt.parseInt(u16, &[_]u8{c}, 10);
    }
    return @intCast(int1 * int2);
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input", .{});
    defer file.close();
    const file_reader = file.reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    defer _ = gpa.deinit();

    var input_buf = std.ArrayListUnmanaged(u8){};
    defer input_buf.deinit(ally);

    var sum: u32 = 0;

    var match_str = std.ArrayListUnmanaged(u8){};
    try match_str.ensureTotalCapacity(ally, 15);
    defer match_str.deinit(ally);
    var matching_mul = false;
    var matching_ind: u32 = 0;

    while (true) {
        defer input_buf.clearRetainingCapacity();
        file_reader.streamUntilDelimiter(input_buf.writer(ally), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => break,
        };

        for (input_buf.items, 0..) |c, i| {
            if (matching_mul) {
                if (c != 'm' and c != 'u' and c != 'l' and c != '(' and c != ')' and c != ',' and !is_digit(c)) {
                    matching_mul = false;
                    match_str.clearRetainingCapacity();
                    continue;
                }

                try match_str.append(ally, c);
                if (c == ')') {
                    const mul_parsed = parse_mul(match_str.items) catch |err| {
                        return err;
                    };
                    sum += if (mul_parsed < 0) 0 else @intCast(mul_parsed);

                    matching_mul = false;
                    match_str.clearRetainingCapacity();
                }
            } else if (c == 'm') {
                try match_str.append(ally, c);
                matching_mul = true;
                matching_ind = @intCast(i);
            }
        }
    }
    std.debug.print("{}\n", .{sum});
}
