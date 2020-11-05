const std = @import("std");
const aya = @import("aya");
const gfx = @import("gfx");
const math = gfx.math;

pub fn main() !void {
    try aya.run(null, render);
}

fn render() !void {
    var shader = try gfx.Shader.init(@embedFile("assets/shaders/vert.vs"), @embedFile("assets/shaders/frag.fs"));
    shader.bind();
    shader.setInt("MainTex", 0);
    shader.setMat3x2("TransformMatrix", math.Mat32.initOrtho(800, 600));

    var tex = gfx.Texture.initCheckerTexture();
    var red_tex = gfx.Texture.initSingleColor(0xFF0000FF);

    var vertices = [_]gfx.Vertex{
        .{ .pos = .{ .x = 10, .y = 10 }, .uv = .{ .x = 0, .y = 1 } }, // bl
        .{ .pos = .{ .x = 100, .y = 10 }, .uv = .{ .x = 1, .y = 1 } }, // br
        .{ .pos = .{ .x = 100, .y = 100 }, .uv = .{ .x = 1, .y = 0 } }, // tr
        .{ .pos = .{ .x = 10, .y = 100 }, .uv = .{ .x = 0, .y = 0 } }, // tl
    };
    var indices = [_]u16{
        0, 1, 2, 2, 3, 0,
    };

    var mesh = gfx.Mesh.init(gfx.Vertex, vertices[0..], u16, indices[0..]);

    var dyn_mesh = try gfx.DynamicMesh(gfx.Vertex, u16).init(std.testing.allocator, vertices.len, &indices);
    for (vertices) |*vert, i| {
        vert.pos.x += 200;
        vert.pos.y += 200;
        dyn_mesh.verts[i] = vert.*;
    }
    dyn_mesh.updateAllVerts();

    gfx.viewport(0, 0, 800, 600);

    while (!aya.pollEvents()) {
        gfx.clear(.{});

        shader.bind();
        tex.bind();
        mesh.draw();

        red_tex.bind();
        dyn_mesh.drawAllVerts();

        aya.swapWindow();
    }
}
