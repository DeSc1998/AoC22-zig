const std = @import("std");
const util = @import("utility.zig");

fn mapToBits(items: []const u8) u32 {
    var bits: u32 = 0;
    for (items) |c| {
        bits |= @as(u32, 1) << @truncate(u5, c - 'a');
    }
    return bits;
}

fn countUniqueChars(chars: []const u8) u32 {
    return @popCount(mapToBits(chars));
}

fn allUnique(chars: []const u8) bool {
    const size = chars.len;
    return size == countUniqueChars(chars);
}

pub fn solve1(input: []const u8) u32 {
    var idx: u32 = 0;
    while (idx + 4 < input.len) : (idx += 1) {
        if (allUnique(input[idx .. idx + 4])) {
            break;
        }
    }

    return if (idx == @truncate(u32, input.len - 4)) @truncate(u32, input.len) else idx + 4;
}

pub fn solve2(input: []const u8) u32 {
    var idx: u32 = 0;
    while (idx + 14 <= input.len) : (idx += 1) {
        if (allUnique(input[idx .. idx + 14])) {
            break;
        }
    }

    return if (idx > @truncate(u32, input.len - 14)) @truncate(u32, input.len) else idx + 14;
}

test "day-6" {
    const input =
        \\mjqjpqmgbljsphdztnvjfqwrcgsmlb
    ;
    const index = solve1(input);
    try std.testing.expectEqual(@as(u32, 7), index);
    const index2 = solve2(input);
    try std.testing.expectEqual(@as(u32, 19), index2);
}
