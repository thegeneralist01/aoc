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
            comma_ind = 5 + i;
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

fn parse_do(s: []const u8) !i8 {
    if (s.len == 4) {
        // do()
        if (s[0] != 'd') return 0;
        if (s[1] != 'o') return 0;
        if (s[2] != '(') return 0;
        if (s[3] != ')') return 0;
        return 1;
    } else if (s.len == 7) {
        // don't()
        if (s[0] != 'd') return 0;
        if (s[1] != 'o') return 0;
        if (s[2] != 'n') return 0;
        if (s[3] != '\'') return 0;
        if (s[4] != 't') return 0;
        if (s[5] != '(') return 0;
        if (s[6] != ')') return 0;
        return -1;
    }
    return 0;
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

    var match_mul_str = std.ArrayListUnmanaged(u8){};
    try match_mul_str.ensureTotalCapacity(ally, 15);
    defer match_mul_str.deinit(ally);
    var matching_mul = false;
    var matching_mul_ind: u32 = 0;
    var mul_lock = false;

    var match_do_str = std.ArrayListUnmanaged(u8){};
    try match_do_str.ensureTotalCapacity(ally, 15);
    defer match_do_str.deinit(ally);
    var matching_do = false;
    var matching_do_ind: u32 = 0;

    var sum: u32 = 0;
    while (true) {
        defer input_buf.clearRetainingCapacity();
        file_reader.streamUntilDelimiter(input_buf.writer(ally), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => break,
        };

        for (input_buf.items, 0..) |c, i| {
            if (matching_mul and !mul_lock) {
                if (c != 'm' and c != 'u' and c != 'l' and c != '(' and c != ')' and c != ',' and !is_digit(c)) {
                    matching_mul = false;
                    match_mul_str.clearRetainingCapacity();
                    continue;
                }

                try match_mul_str.append(ally, c);
                if (c == ')') {
                    const mul_parsed = parse_mul(match_mul_str.items) catch |err| {
                        return err;
                    };
                    sum += if (mul_parsed < 0) 0 else @intCast(mul_parsed);

                    matching_mul = false;
                    match_mul_str.clearRetainingCapacity();
                }
            } else if (c == 'm' and !mul_lock) {
                try match_mul_str.append(ally, c);
                matching_mul = true;
                matching_mul_ind = @intCast(i);
            }

            if (matching_do) {
                if (c != 'd' and c != 'o' and c != 'n' and c != '\'' and c != 't' and c != '(' and c != ')') {
                    matching_do = false;
                    match_do_str.clearRetainingCapacity();
                    continue;
                }

                try match_do_str.append(ally, c);
                if (c == ')') {
                    const do_parsed = parse_do(match_do_str.items) catch |err| {
                        return err;
                    };
                    mul_lock = if (do_parsed == 1) false else if (do_parsed == -1) true else mul_lock;

                    matching_do = false;
                    match_do_str.clearRetainingCapacity();
                }
            } else if (c == 'd') {
                try match_do_str.append(ally, c);
                matching_do = true;
                matching_do_ind = @intCast(i);
            }
        }
    }
    std.debug.print("{}\n", .{sum});
}
