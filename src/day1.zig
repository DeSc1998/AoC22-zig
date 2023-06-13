const std = @import("std");

fn collect(comptime T: type, splitter: *std.mem.SplitIterator(T, std.mem.DelimiterType.sequence), out: *std.ArrayList([]const T)) !void {
    while (splitter.next()) |next_val| {
        try out.append(next_val);
    }
}

pub fn parseDayOne(contents: []const u8, out: *std.ArrayList(u32), allocator: std.mem.Allocator) !void {
    var bags = std.ArrayList([]const u8).init(allocator);
    defer bags.deinit();

    var bag_splitter = std.mem.splitSequence(u8, contents, "\n\n");
    try collect(u8, &bag_splitter, &bags);

    for (bags.items) |bag| {
        var energy_bars = std.mem.split(u8, bag, "\n");
        var total: u32 = 0;
        while (energy_bars.next()) |bar| {
            if (std.fmt.parseInt(u32, bar, 10)) |val| {
                total += val;
            } else |err| {
                std.debug.print("error: {}\n", .{err});
                std.debug.print("input was: '{s}'\n", .{bar});
                std.process.exit(1);
            }
        }
        try out.append(total);
    }
}

pub fn lessThan(_: @TypeOf(.{}), l: u32, r: u32) bool {
    return l < r;
}

pub fn sumLastThree(items: []const u32) ?u32 {
    if (items.len < 3) {
        return null;
    } else {
        const subSlice = items[items.len - 3 .. items.len];
        var total: u32 = 0;
        for (subSlice) |val| {
            total += val;
        }
        return total;
    }
}

fn sum(items: []const u32) u32 {
    var total: u32 = 0;
    for (items) |item| {
        total += item;
    }
    return total;
}

pub fn solve1(input: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var list = std.ArrayList(u32).init(allocator);
    defer list.deinit();

    try parseDayOne(input, &list, allocator);
    std.mem.sort(u32, list.items, .{}, lessThan);
    return list.items[list.items.len - 1];
}

pub fn solve2(input: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var list = std.ArrayList(u32).init(allocator);
    defer list.deinit();

    try parseDayOne(input, &list, allocator);
    std.mem.sort(u32, list.items, .{}, lessThan);
    return sum(list.items[list.items.len - 3 .. list.items.len]);
}

test "day-1" {
    var int_list = std.ArrayList(u32).init(std.testing.allocator);
    defer int_list.deinit();

    const file_content =
        \\1000
        \\2000
        \\3000
        \\
        \\4000
        \\
        \\5000
        \\6000
        \\
        \\7000
        \\8000
        \\9000
        \\
        \\10000
    ;

    try parseDayOne(file_content, &int_list, std.testing.allocator);

    const item = std.mem.max(u32, int_list.items);
    try std.testing.expectEqual(@as(u32, 24000), item);
}
