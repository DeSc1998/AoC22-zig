const std = @import("std");
const util = @import("utility.zig");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
const day4 = @import("day4.zig");
const day5 = @import("day5.zig");
const day6 = @import("day6.zig");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

pub fn main() !void {
    defer arena.deinit();

    // Day 1
    const dayOneData = try util.readEntireFile("input/day1.txt", allocator);
    std.debug.print("day 1 (1): {!}\n", .{day1.solve1(dayOneData)});
    std.debug.print("day 1 (2): {!}\n", .{day1.solve2(dayOneData)});
    allocator.free(dayOneData);

    // Day 2
    const dayTwoData = try util.readEntireFile("input/day2.txt", allocator);
    std.debug.print("day 2 (1): {!}\n", .{day2.solve1(dayTwoData)});
    std.debug.print("day 2 (2): {!}\n", .{day2.solve2(dayTwoData)});
    allocator.free(dayTwoData);

    // Day 3
    const dayThreeData = try util.readEntireFile("input/day3.txt", allocator);
    std.debug.print("day 3 (1): {!}\n", .{day3.solve1(dayThreeData)});
    std.debug.print("day 3 (2): {!}\n", .{day3.solve2(dayThreeData)});
    allocator.free(dayThreeData);

    // Day 4
    const dayFourData = try util.readEntireFile("input/day4.txt", allocator);
    std.debug.print("day 4 (1): {!}\n", .{day4.solve1(dayFourData)});
    std.debug.print("day 4 (2): {!}\n", .{day4.solve2(dayFourData)});
    allocator.free(dayFourData);

    // Day 5
    const dayFiveData = try util.readEntireFile("input/day5.txt", allocator);
    const out1 = try day5.solve1(dayFiveData, allocator);
    std.debug.print("day 5 (1): {s}\n", .{out1});
    const out2 = try day5.solve2(dayFiveData, allocator);
    std.debug.print("day 5 (2): {s}\n", .{out2});
    allocator.free(out2);
    allocator.free(out1);
    allocator.free(dayFiveData);

    // Day 6
    const daySixData = try util.readEntireFile("input/day6.txt", allocator);
    const d6_1 = day6.solve1(daySixData);
    std.debug.print("day 6 (1): {}\n", .{d6_1});
    const d6_2 = day6.solve2(daySixData);
    std.debug.print("day 6 (2): {}\n", .{d6_2});

    // Day 7
}
