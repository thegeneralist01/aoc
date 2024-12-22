const std = @import("std");
const in = @embedFile("in");

fn array_includes(comptime T: type, haystack: []T, needle: T) bool {
    for (haystack) |item| {
        if (item == needle) {
            return true;
        }
    }
    return false;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    defer _ = gpa.deinit();

    var lines = std.ArrayList(std.ArrayList(u32)).init(ally);
    var incorrect_line_idxs = std.ArrayList(u32).init(ally);
    defer {
        for (lines.items) |*line| {
            line.deinit();
        }
        lines.deinit();
        incorrect_line_idxs.deinit();
    }

    var dependencies = std.AutoHashMap(u32, std.ArrayList(u32)).init(ally);
    defer {
        var iter = dependencies.iterator();
        while (iter.next()) |entry| {
            entry.value_ptr.deinit();
        }
        dependencies.deinit();
    }

    var in_lines = std.mem.tokenize(u8, in, "\n");
    var parsing_dependencies = false;
    var i: u32 = 0;
    while (in_lines.next()) |line| {
        if (std.mem.indexOf(u8, line, "|")) |_| {
            parsing_dependencies = true;
        } else {
            parsing_dependencies = false;
        }

        if (line.len > 0 and parsing_dependencies) {
            var dependance = std.mem.split(u8, line, "|");
            const num1 = try std.fmt.parseInt(u32, dependance.next().?, 10);
            const num2 = try std.fmt.parseInt(u32, dependance.next().?, 10);

            var entry = try dependencies.getOrPut(num2);
            if (!entry.found_existing) {
                entry.value_ptr.* = std.ArrayList(u32).init(ally);
            }

            try entry.value_ptr.append(num1);
        } else if (line.len > 0 and !parsing_dependencies) {
            var ints = std.mem.split(u8, line, ",");
            var intLine = std.ArrayList(u32).init(ally);
            while (ints.next()) |int| {
                try intLine.append(try std.fmt.parseInt(u32, int, 10));
            }
            try lines.append(intLine);
        }
        i += 1;
    }

    // Part 1
    var middle_page_number_sum: u32 = 0;
    for (lines.items, 0..) |line, lidx| {
        var is_correct = true;
        outer: for (line.items, 0..) |num1, j| {
            for (line.items[0..j]) |num2| {
                const deps = dependencies.get(num1);

                if (deps == null) {
                    is_correct = false;
                    break :outer;
                }

                var found = false;
                for (deps.?.items) |dep| {
                    if (dep == num2) {
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    is_correct = false;
                    break :outer;
                }
            }
        }

        if (is_correct) {
            middle_page_number_sum += line.items[line.items.len / 2];
        } else {
            try incorrect_line_idxs.append(@intCast(lidx));
        }
    }
    std.debug.print("Part1: {}\n", .{middle_page_number_sum});

    // Part 2
    middle_page_number_sum = 0;
    for (incorrect_line_idxs.items) |idx| {
        const line = lines.items[idx];
        var fixed_line = std.ArrayList(u32).init(ally);
        defer fixed_line.deinit();

        for (line.items) |num| {
            const deps = dependencies.get(num);

            if (deps == null) {
                try fixed_line.insert(0, num);
                continue;
            }

            var j: usize = 0;
            for (fixed_line.items) |comparison_num| {
                if (array_includes(u32, deps.?.items, comparison_num)) {
                    j += 1;
                    continue;
                }
            }
            try fixed_line.insert(j, num);
        }

        middle_page_number_sum += fixed_line.items[fixed_line.items.len / 2];
    }

    std.debug.print("Part 2: {}\n", .{middle_page_number_sum});
}
