//! Utility class for manipulating 2D axis aligned rectangles. 

usingnamespace @import("../sfml_import.zig");
const sf = @import("../sfml.zig");
const math = @import("std").math;

pub fn Rect(comptime T: type) type {
    return struct {
        const Self = @This();

        /// The CSFML vector type equivalent
        const CsfmlEquivalent = switch (T) {
            i32 => Sf.sfIntRect,
            f32 => Sf.sfFloatRect,
            else => void,
        };

        /// Creates a rect (just for convinience)
        pub fn init(left: T, top: T, width: T, height: T) Self {
            return Self{
                .left = left,
                .top = top,
                .width = width,
                .height = height
            };
        }

        /// Makes a CSFML rect with this rect (only if the corresponding type exists)
        /// This is mainly for the inner workings of this wrapper
        pub fn toCSFML(self: Self) CsfmlEquivalent {
            if (CsfmlEquivalent == void) @compileError("This rectangle type doesn't have a CSFML equivalent.");
            return CsfmlEquivalent{
                .left = self.left,
                .top = self.top,
                .width = self.width,
                .height = self.height
            };
        }

        /// Creates a rect from a CSFML one (only if the corresponding type exists)
        /// This is mainly for the inner workings of this wrapper
        pub fn fromCSFML(rect: CsfmlEquivalent) Self {
            if (CsfmlEquivalent == void) @compileError("This rectangle type doesn't have a CSFML equivalent.");
            return Self.init(rect.left, rect.top, rect.width, rect.width);
        }

        /// Checks if a point is inside this recangle
        pub fn contains(self: Self, vec: sf.Vector2(T)) bool {
            // Shamelessly stolen
            var min_x: T = math.min(self.left, self.left + self.width);
            var max_x: T = math.max(self.left, self.left + self.width);
            var min_y: T = math.min(self.top, self.top + self.height);
            var max_y: T = math.max(self.top, self.top + self.height);

            return (
                x >= min_x and 
                x < max_x and 
                y >= min_y and 
                y < max_y
            );
        }

        // TODO : Tests!
        /// Checks if two rectangles have a common intersection, if yes returns that zone, if not returns null
        pub fn intersects(self: Self, other: Self) ?Self {
            // Shamelessly stolen too
            var r1_min_x: T = math.min(self.left, self.left + self.width);
            var r1_max_x: T = math.max(self.left, self.left + self.width);
            var r1_min_y: T = math.min(self.top, self.top + self.height);
            var r1_max_y: T = math.max(self.top, self.top + self.height);

            var r2_min_x: T = math.min(other.left, other.left + other.width);
            var r2_max_x: T = math.max(other.left, other.left + other.width);
            var r2_min_y: T = math.min(other.top, other.top + other.height);
            var r2_max_y: T = math.max(other.top, other.top + other.height);

            var inter_left: T = math.max(r1_min_x, r2_min_x);
            var inter_top: T = math.max(r1_min_y, r2_min_y);
            var inter_right: T = math.min(r1_max_x, r2_max_x);
            var inter_bottom: T = math.min(r1_max_y, r2_max_y);

            if (inter_left < inter_right and inter_top < inter_bottom) {
                return Self.init(inter_left, inter_top, inter_right - inter_left, inter_bottom - inter_top);
            } else {
                return null;
            }
        }

        /// Gets a vector with left and top components inside
        pub fn getCorner(self: Self) sf.Vector2(T) {
            return sf.Vector2(T){.x = self.left, .y = self.top};
        }
        /// Gets a vector with width and height components inside
        pub fn getSize(self: Self) sf.Vector2(T) {
            return sf.Vector2(T){.x = self.width, .y = self.height};
        }

        /// x component of the top left corner
        left: T,
        /// x component of the top left corner
        top: T,
        /// width of the rectangle
        width: T,
        /// height of the rectangle
        height: T
    };
}

// Common rect types
pub const IntRect = Rect(i32);
pub const FloatRect = Rect(f32);