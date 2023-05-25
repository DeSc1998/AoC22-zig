const std = @import("std");
const util = @import("utility.zig");

const stack = std.atomic.Stack(u8);

const Move = struct {
    count: u32,
    source: usize,
    destination: usize,
};

fn parseStacks(input: [][]const u8, out: *std.ArrayList(stack)) !void {
    const stack_count = input[input.len - 1].len / 4 + 1;
    var lines = input[0 .. input.len - 1];
    try out.resize(stack_count);
    for (out.items) |*s| {
        s.* = stack.init();
    }
    std.mem.reverse([]const u8, lines);

    for (lines) |line| {
        var stack_idx: usize = 0;
        var idx: usize = 0;
        while (idx + 1 < line.len) : (idx += 4) {
            if (line[idx + 1] != ' ') {
                var node = try out.allocator.create(stack.Node);
                node.data = line[idx + 1];
                node.next = null;
                out.items[stack_idx].push(node);
            }
            stack_idx += 1;
        }
    }
}

fn parseMoves(input: [][]const u8, out: *std.ArrayList(Move)) !void {
    for (input) |line| {
        var splitter = std.mem.split(u8, line, " ");
        _ = splitter.next(); // move
        const count = try std.fmt.parseInt(u32, splitter.next().?, 10);
        _ = splitter.next(); // from
        const src = try std.fmt.parseInt(usize, splitter.next().?, 10);
        _ = splitter.next(); // to
        const dest = try std.fmt.parseInt(usize, splitter.next().?, 10);
        try out.append(.{ .count = count, .source = src, .destination = dest });
    }
}

fn simulate(stacks: *std.ArrayList(stack), moves: *std.ArrayList(Move)) void {
    for (moves.items) |move| {
        var count = move.count;
        while (count > 0) : (count -= 1) {
            if (stacks.items[move.source - 1].pop()) |node| {
                stacks.items[move.destination - 1].push(node);
            }
        }
    }
}

fn simulateStacking(stacks: *std.ArrayList(stack), moves: *std.ArrayList(Move)) void {
    var tmp = stack.init();
    for (moves.items) |move| {
        var count = move.count;
        while (count > 0) : (count -= 1) {
            if (stacks.items[move.source - 1].pop()) |node| {
                tmp.push(node);
            }
        }

        while (tmp.pop()) |node| {
            stacks.items[move.destination - 1].push(node);
        }
    }
}

fn topLetters(in: *std.ArrayList(stack), out: []u8) void {
    var idx: u32 = 0;
    for (in.items) |*s| {
        if (s.pop()) |node| {
            out[idx] = node.data;
            s.push(node);
        } else {
            out[idx] = ' ';
        }
        idx += 1;
    }
}

pub fn solve1(input: []const u8, allocator: std.mem.Allocator) ![]u8 {
    var lines = std.ArrayList([]const u8).init(std.heap.page_allocator);
    var moves = std.ArrayList(Move).init(std.heap.page_allocator);
    var stacks = std.ArrayList(stack).init(std.heap.page_allocator);
    defer lines.deinit();
    defer moves.deinit();
    defer stacks.deinit();

    try util.splitByLines(input, &lines);
    var split_idx: usize = 0;
    while (lines.items[split_idx].len > 0) : (split_idx += 1) {}
    try parseStacks(lines.items[0..split_idx], &stacks);
    try parseMoves(lines.items[split_idx + 1 ..], &moves);

    simulate(&stacks, &moves);
    var out = try allocator.alloc(u8, stacks.items.len);
    topLetters(&stacks, out);

    for (stacks.items) |*s| {
        while (s.pop()) |item| {
            stacks.allocator.destroy(item);
        }
    }
    return out;
}

pub fn solve2(input: []const u8, allocator: std.mem.Allocator) ![]u8 {
    var lines = std.ArrayList([]const u8).init(std.heap.page_allocator);
    var moves = std.ArrayList(Move).init(std.heap.page_allocator);
    var stacks = std.ArrayList(stack).init(std.heap.page_allocator);
    defer lines.deinit();
    defer moves.deinit();
    defer stacks.deinit();

    try util.splitByLines(input, &lines);
    var split_idx: usize = 0;
    while (lines.items[split_idx].len > 0) : (split_idx += 1) {}
    try parseStacks(lines.items[0..split_idx], &stacks);
    try parseMoves(lines.items[split_idx + 1 ..], &moves);

    simulateStacking(&stacks, &moves);
    var out = try allocator.alloc(u8, stacks.items.len);
    topLetters(&stacks, out);

    for (stacks.items) |*s| {
        while (s.pop()) |item| {
            stacks.allocator.destroy(item);
        }
    }
    return out;
}

test "day-5" {
    const input =
        \\    [D]    
        \\[N] [C]    
        \\[Z] [M] [P]
        \\ 1   2   3 
        \\
        \\move 1 from 2 to 1
        \\move 3 from 1 to 3
        \\move 2 from 2 to 1
        \\move 1 from 1 to 2
    ;

    const letters = try solve1(input, std.testing.allocator);
    try std.testing.expectEqualSlices(u8, "CMZ", letters);
    const out = try solve2(input, std.testing.allocator);
    try std.testing.expectEqualSlices(u8, "MCD", out);

    std.testing.allocator.free(letters);
    std.testing.allocator.free(out);
}
