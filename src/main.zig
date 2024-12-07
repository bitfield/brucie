const std = @import("std");

pub fn main() !void {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();
    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();
    var last: u8 = 0;
    var number: u8 = 0;
    var message: []const u8 = "You're wrong!";
    while (true) {
        try stdout.writer().print("The last number was {d}\n", .{last});
        try stdout.writer().print("(H)igher or (L)ower? > ", .{});
        var buffer: [2]u8 = undefined;
        const guess = (try nextLine(stdin.reader(), &buffer)).?;
        message = "You're wrong! ";
        number = rand.intRangeAtMost(u8, 1, 10);
        if (guess[0] == 'h' and number > last) {
            message = "You're right, it was higher!";
        } else if (guess[0] == 'l' and number < last) {
            message = "You're right, it was lower!";
        }
        try stdout.writer().print("Your guess was '{s}'. {s}\n", .{ guess, message });
        last = number;
    }
}

fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
    const line = try reader.readUntilDelimiterOrEof(
        buffer,
        '\n',
    ) orelse return null;
    // trim annoying windows-only carriage return character
    if (@import("builtin").os.tag == .windows) {
        return std.mem.trimRight(u8, line, "\r");
    } else {
        return line;
    }
}
