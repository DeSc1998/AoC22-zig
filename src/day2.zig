const std = @import("std");
const util = @import("utility.zig");

const MoveType = enum(u8) {
    Rock = 0,
    Paper = 1,
    Scissors = 2,
};

const Round = struct {
    opp: MoveType,
    move: MoveType,
};

fn parseLineDayTwo(content: []const u8) ?Round {
    if (content.len < 3) {
        return null;
    }

    // zig fmt: off
    return .{
        .opp = @enumFromInt( content[0] - 'A'),
        .move = @enumFromInt( content[2] - 'X') };
    // zig fmt: on
}

fn score(opponent: MoveType, move: MoveType) u32 {
    const opp = @intFromEnum(opponent);
    const self = @intFromEnum(move);
    if (opponent == move) { // draw
        return 3 + self + 1;
    }
    if ((opp + 1) % 3 == self) { // win
        return 6 + self + 1;
    }
    return self + 1; // lose
}

fn scoreTarget(opponent: MoveType, target: MoveType) u32 {
    const opp = @intFromEnum(opponent);
    return switch (target) {
        .Rock => (opp + 2) % 3 + 1, // lose
        .Paper => 3 + opp + 1, // draw
        .Scissors => 6 + (opp + 1) % 3 + 1, // win
    };
}

fn foldMapInput(content: []const u8, folder: *const fn (MoveType, MoveType) u32, allocator: std.mem.Allocator) !u32 {
    var moves = std.ArrayList([]const u8).init(allocator);
    defer moves.deinit();

    var move_splitter = std.mem.split(u8, content, "\n");
    try util.collect(u8, &move_splitter, &moves);
    var total: u32 = 0;

    for (moves.items) |move| {
        if (parseLineDayTwo(move)) |round| {
            total += folder(round.opp, round.move);
        }
    }
    return total;
}

pub fn solve1(input: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocater = arena.allocator();
    defer arena.deinit();

    return foldMapInput(input, &score, allocater);
}

pub fn solve2(input: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocater = arena.allocator();
    defer arena.deinit();

    return foldMapInput(input, &scoreTarget, allocater);
}

test "day-2" {
    var moves = std.ArrayList([]const u8).init(std.testing.allocator);
    defer moves.deinit();

    const content =
        \\A Y
        \\B X
        \\C Z
    ;

    var total: u32 = try foldMapInput(content, &score);
    try std.testing.expectEqual(@as(u32, 15), total);

    total = try foldMapInput(content, &scoreTarget);
    try std.testing.expectEqual(@as(u32, 12), total);
}
