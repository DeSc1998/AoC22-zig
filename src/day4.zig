const std = @import("std");
const util = @import("utility.zig");

const Range = struct {
    lower: u32,
    upper: u32,
};

fn parseRange(input: ?[]const u8) !Range {
    if (input == null) {
        return error.NoInput;
    }

    var splitter = std.mem.split(u8, input.?, "-");
    var r: Range = undefined;
    if (splitter.next()) |l| {
        r.lower = try std.fmt.parseInt(u32, l, 10);
    } else {
        return error.MalformedInput;
    }

    if (splitter.next()) |u| {
        r.upper = try std.fmt.parseInt(u32, u, 10);
    } else {
        return error.MalformedInput;
    }

    return r;
}

fn containsOther(left: Range, right: Range) bool {
    return (left.lower <= right.lower and left.upper >= right.upper) or
        (right.lower <= left.lower and right.upper >= left.upper);
}

fn intersectsOther(left: Range, right: Range) bool {
    return containsOther(left, right) or
        (left.lower < right.upper and right.lower <= left.upper) or
        (right.lower < left.upper and left.lower <= right.upper);
}

pub fn solve1(input: []const u8) !u32 {
    var lines = std.ArrayList([]const u8).init(std.heap.page_allocator);
    defer lines.deinit();

    try util.splitByLines(input, &lines);

    var count: u32 = 0;
    for (lines.items) |line| {
        var ranges_splitter = std.mem.split(u8, line, ",");
        const first_range = try parseRange(ranges_splitter.next());
        const second_range = try parseRange(ranges_splitter.next());

        if (containsOther(first_range, second_range)) {
            count += 1;
        }
    }
    return count;
}

pub fn solve2(input: []const u8) !u32 {
    var lines = std.ArrayList([]const u8).init(std.heap.page_allocator);
    defer lines.deinit();

    try util.splitByLines(input, &lines);

    var count: u32 = 0;
    for (lines.items) |line| {
        var ranges_splitter = std.mem.split(u8, line, ",");
        const first_range = try parseRange(ranges_splitter.next());
        const second_range = try parseRange(ranges_splitter.next());

        if (intersectsOther(first_range, second_range)) {
            count += 1;
        }
    }
    return count;
}

test "day-4" {
    var lines = std.ArrayList([]const u8).init(std.testing.allocator);
    defer lines.deinit();

    const content =
        \\2-4,6-8
        \\2-3,4-5
        \\5-7,7-9
        \\2-8,3-7
        \\6-6,4-6
        \\2-6,4-8
    ;
    const count = try solve1(content);

    try std.testing.expectEqual(@as(u32, 2), count);
}
