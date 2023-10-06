const std = @import("std");
const util = @import("utility.zig");

fn mapToBits(items: []const u8) u64 {
    var bits: u64 = 0;
    for (items) |c| {
        if (std.ascii.isUpper(c)) {
            bits |= @as(u64, 1) << @truncate( c - 'A' + 26);
        } else {
            bits |= @as(u64, 1) << @truncate( c - 'a');
        }
    }
    return bits;
}

fn bitIndex(x: u64) u32 {
    return @ctz(x);
}

pub fn commonItemOfBag(bag: []const u8) u32 {
    const middle = bag.len / 2;
    var left_bits = mapToBits(bag[0..middle]);
    var right_bits = mapToBits(bag[middle..bag.len]);
    var common_bits = left_bits & right_bits;
    return bitIndex(common_bits) + 1; // idxs 0 .. 51 -> 1 .. 52
}

pub fn commonItemOfBags(bag_bits: []const u64) u32 {
    if (bag_bits.len != 3) {
        return 0;
    }
    return bitIndex(bag_bits[0] & bag_bits[1] & bag_bits[2]) + 1;
}

pub fn solve1(input: []const u8) !u32 {
    var bags = std.ArrayList([]const u8).init(std.heap.page_allocator);
    defer bags.deinit();

    try util.splitByLines(input, &bags);
    var total: u32 = 0;
    for (bags.items) |bag| {
        total += commonItemOfBag(bag);
    }
    return total;
}

pub fn solve2(input: []const u8) !u32 {
    var bags = std.ArrayList([]const u8).init(std.heap.page_allocator);
    var bag_bits = std.ArrayList(u64).init(std.heap.page_allocator);
    defer bags.deinit();
    defer bag_bits.deinit();

    try util.splitByLines(input, &bags);
    for (bags.items) |bag| {
        try bag_bits.append(mapToBits(bag));
    }

    var total: u32 = 0;
    var idx: usize = 0;
    while (idx < bag_bits.items.len) : (idx += 3) {
        total += commonItemOfBags(bag_bits.items[idx .. idx + 3]);
    }
    return total;
}

test "day-3" {
    var bags = std.ArrayList([]const u8).init(std.testing.allocator);
    defer bags.deinit();

    const content =
        \\vJrwpWtwJgWrhcsFMMfFFhFp
        \\jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
        \\PmmdzqPrVvPwwTWBwg
        \\wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
        \\ttgJtRGJQctTZtZT
        \\CrZsJsPPZsGzwwsLwLmpwMDw
    ;

    var bag_splitter = std.mem.split(u8, content, "\n");
    try util.collect(u8, &bag_splitter, &bags);

    var total: u32 = 0;
    for (bags.items) |bag| {
        const middle = bag.len / 2;
        var left_bits = mapToBits(bag[0..middle]);
        var right_bits = mapToBits(bag[middle..bag.len]);
        var common_bits = left_bits & right_bits;
        total += bitIndex(common_bits) + 1;
    }

    try std.testing.expectEqual(@as(u32, 157), total);
}
