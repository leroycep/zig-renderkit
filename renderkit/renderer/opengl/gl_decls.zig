const std = @import("std");
pub usingnamespace @import("gl_enums.zig");

pub const GLbyte = i8;
pub const GLclampf = f32;
pub const GLfixed = i32;
pub const GLshort = c_short;
pub const GLushort = c_ushort;
pub const GLvoid = c_void;
pub const GLsync = ?*opaque {};
pub const GLint64 = i64;
pub const GLuint64 = u64;
pub const GLenum = c_uint;
pub const GLchar = u8;
pub const GLfloat = f32;
pub const GLsizeiptr = c_long;
pub const GLintptr = c_long;
pub const GLbitfield = c_uint;
pub const GLint = c_int;
pub const GLuint = c_uint;
pub const GLboolean = u8;
pub const GLsizei = c_int;
pub const GLubyte = u8;
pub const GLint64EXT = i64;
pub const GLuint64EXT = u64;
pub const GLdouble = f64;

const Funcs = struct {
    glEnable: fn (GLenum) callconv(.C) void,
    glDisable: fn (GLenum) callconv(.C) void,
    glBlendFunc: fn (GLenum, GLenum) callconv(.C) void,
    glBlendFuncSeparate: fn (GLenum, GLenum, GLenum, GLenum) callconv(.C) void,
    glBlendEquationSeparate: fn (GLenum, GLenum) callconv(.C) void,
    glBlendColor: fn (GLfloat, GLfloat, GLfloat, GLfloat) callconv(.C) void,
    glPolygonMode: fn (GLenum, GLenum) callconv(.C) void,
    glDepthMask: fn (GLboolean) callconv(.C) void,
    glDepthFunc: fn (GLenum) callconv(.C) void,
    glStencilFunc: fn (GLenum, GLint, GLuint) callconv(.C) void,
    glStencilFuncSeparate: fn (GLenum, GLenum, GLint, GLuint) callconv(.C) void,
    glStencilMask: fn (GLuint) callconv(.C) void,
    glStencilMaskSeparate: fn (GLenum, GLuint) callconv(.C) void,
    glStencilOp: fn (GLenum, GLenum, GLenum) callconv(.C) void,
    glStencilOpSeparate: fn (GLenum, GLenum, GLenum, GLenum) callconv(.C) void,
    glColorMask: fn (GLboolean, GLboolean, GLboolean, GLboolean) callconv(.C) void,

    glViewport: fn (GLint, GLint, GLsizei, GLsizei) callconv(.C) void,
    glScissor: fn (GLint, GLint, GLsizei, GLsizei) callconv(.C) void,
    glGetString: fn (GLenum) callconv(.C) [*c]const GLubyte,
    glGetError: fn () callconv(.C) GLenum,
    glGetIntegerv: fn (GLenum, [*c]GLint) callconv(.C) void,
    glClearColor: fn (GLfloat, GLfloat, GLfloat, GLfloat) callconv(.C) void,
    glClearStencil: fn (GLint) callconv(.C) void,
    glClearDepth: fn (GLdouble) callconv(.C) void,
    glClear: fn (GLbitfield) callconv(.C) void,
    glGenBuffers: fn (n: GLsizei, buffers: [*c]GLuint) callconv(.C) void,
    glDeleteVertexArrays: fn (n: GLsizei, arrays: [*c]GLuint) callconv(.C) void,
    glDeleteBuffers: fn (n: GLsizei, buffers: [*]GLuint) callconv(.C) void,
    glGenVertexArrays: fn (n: GLsizei, arrays: [*c]GLuint) callconv(.C) void,
    glBindBuffer: fn (target: GLenum, buffer: GLuint) callconv(.C) void,
    glBufferData: fn (target: GLenum, size: GLsizeiptr, data: ?*const c_void, usage: GLenum) callconv(.C) void,
    glBufferSubData: fn (GLenum, GLintptr, GLsizeiptr, ?*const c_void) callconv(.C) void,

    glCreateShader: fn (shader: GLenum) callconv(.C) GLuint,
    glShaderSource: fn (shader: GLuint, count: GLsizei, string: *[:0]const GLchar, length: ?*c_int) callconv(.C) void,
    glCompileShader: fn (shader: GLuint) callconv(.C) void,
    glDeleteShader: fn (GLuint) callconv(.C) void,

    glCreateProgram: fn () callconv(.C) GLuint,
    glDeleteProgram: fn (GLuint) callconv(.C) void,
    glAttachShader: fn (program: GLuint, shader: GLuint) callconv(.C) void,
    glLinkProgram: fn (program: GLuint) callconv(.C) void,
    glGetProgramiv: fn (GLuint, GLenum, [*c]GLint) callconv(.C) void,
    glGetProgramInfoLog: fn (GLuint, GLsizei, [*c]GLsizei, [*c]GLchar) callconv(.C) void,
    glUseProgram: fn (program: GLuint) callconv(.C) void,
    glGetAttribLocation: fn (program: GLuint, name: [*:0]const GLchar) callconv(.C) GLint,
    glBindFragDataLocation: fn (program: GLuint, colorNumber: GLuint, name: [*:0]const GLchar) callconv(.C) void,
    glVertexAttribDivisor: fn (index: GLuint, divisor: GLuint) callconv(.C) void,
    glVertexAttribPointer: fn (index: GLuint, size: GLint, type: GLenum, normalized: GLboolean, stride: GLsizei, offset: ?*const c_void) callconv(.C) void,
    glBindVertexArray: fn (array: GLuint) callconv(.C) void,

    glGetShaderiv: fn (shader: GLuint, pname: GLenum, params: *GLint) callconv(.C) void,
    glEnableVertexAttribArray: fn (index: GLuint) callconv(.C) void,
    glGetShaderInfoLog: fn (shader: GLuint, maxLength: GLsizei, length: *GLsizei, infoLog: [*]GLchar) callconv(.C) void,

    glGetUniformLocation: fn (shader: GLuint, name: [*:0]const GLchar) callconv(.C) GLint,
    glUniform1i: fn (location: GLint, v0: GLint) callconv(.C) void,
    glUniform1iv: fn (GLint, GLsizei, [*c]const GLint) callconv(.C) void,
    glUniform1f: fn (location: GLint, v0: GLfloat) callconv(.C) void,
    glUniform1fv: fn (GLint, GLsizei, [*c]const GLfloat) callconv(.C) void,
    glUniform2fv: fn (GLint, GLsizei, [*c]const GLfloat) callconv(.C) void,
    glUniform3fv: fn (GLint, GLsizei, [*c]const GLfloat) callconv(.C) void,
    glUniform4fv: fn (GLint, GLsizei, [*c]const GLfloat) callconv(.C) void,
    glUniform3f: fn (location: GLint, v0: GLfloat, v1: GLfloat, v2: GLfloat) callconv(.C) void,
    glUniformMatrix3fv: fn (GLint, GLsizei, GLboolean, [*c]const GLfloat) callconv(.C) void,
    glUniformMatrix4fv: fn (location: GLint, count: GLsizei, transpose: GLboolean, value: *const GLfloat) callconv(.C) void,
    glUniformMatrix3x2fv: fn (GLint, GLsizei, GLboolean, [*c]const GLfloat) callconv(.C) void,

    glDrawElements: fn (GLenum, GLsizei, GLenum, ?*const c_void) callconv(.C) void,
    glDrawElementsInstanced: fn (GLenum, GLsizei, GLenum, ?*const c_void, GLsizei) callconv(.C) void,
    glDrawArrays: fn (GLenum, GLint, GLsizei) callconv(.C) void,

    glGenFramebuffers: fn (GLsizei, [*c]GLuint) callconv(.C) void,
    glDeleteFramebuffers: fn (GLsizei, [*c]const GLuint) callconv(.C) void,
    glBindFramebuffer: fn (GLenum, GLuint) callconv(.C) void,
    glFramebufferTexture: fn (GLenum, GLenum, GLuint, GLint) callconv(.C) void,
    glDrawBuffers: fn (GLsizei, [*c]const GLenum) callconv(.C) void,
    glCheckFramebufferStatus: fn (GLenum) callconv(.C) GLenum,

    glGenRenderbuffers: fn (GLsizei, [*c]GLuint) callconv(.C) void,
    glDeleteRenderbuffers: fn (GLsizei, [*c]const GLuint) callconv(.C) void,
    glBindRenderbuffer: fn (GLenum, GLuint) callconv(.C) void,
    glRenderbufferStorage: fn (GLenum, GLenum, GLsizei, GLsizei) callconv(.C) void,
    glFramebufferRenderbuffer: fn (GLenum, GLenum, GLenum, GLuint) callconv(.C) void,

    glGenTextures: fn (GLsizei, [*c]GLuint) callconv(.C) void,
    glDeleteTextures: fn (GLsizei, [*c]const GLuint) callconv(.C) void,
    glBindTexture: fn (GLenum, GLuint) callconv(.C) void,
    glTexParameteri: fn (GLenum, GLenum, GLint) callconv(.C) void,
    glTexParameteriv: fn (GLenum, GLenum, [*c]const GLint) callconv(.C) void,
    glTexImage1D: fn (GLenum, GLint, GLint, GLsizei, GLint, GLenum, GLenum, ?*const c_void) callconv(.C) void,
    glTexImage2D: fn (GLenum, GLint, GLint, GLsizei, GLsizei, GLint, GLenum, GLenum, ?*const c_void) callconv(.C) void,
    glGenerateMipmap: fn (GLenum) callconv(.C) void,
    glActiveTexture: fn (GLenum) callconv(.C) void,
};

var gl: Funcs = undefined;

pub fn loadFunctionsZig() void {
    if (std.builtin.arch == .wasm32) {
        const wasmEnv = struct {
            extern fn glEnable(GLenum) callconv(.C) void;
            extern fn glDisable(GLenum) callconv(.C) void;
            extern fn glBlendFunc(GLenum, GLenum) callconv(.C) void;
            extern fn glBlendFuncSeparate(GLenum, GLenum, GLenum, GLenum) callconv(.C) void;
            extern fn glBlendEquationSeparate(GLenum, GLenum) callconv(.C) void;
            extern fn glBlendColor(GLfloat, GLfloat, GLfloat, GLfloat) callconv(.C) void;
            extern fn glPolygonMode(GLenum, GLenum) callconv(.C) void;
            extern fn glDepthMask(GLboolean) callconv(.C) void;
            extern fn glDepthFunc(GLenum) callconv(.C) void;
            extern fn glStencilFunc(GLenum, GLint, GLuint) callconv(.C) void;
            extern fn glStencilFuncSeparate(GLenum, GLenum, GLint, GLuint) callconv(.C) void;
            extern fn glStencilMask(GLuint) callconv(.C) void;
            extern fn glStencilMaskSeparate(GLenum, GLuint) callconv(.C) void;
            extern fn glStencilOp(GLenum, GLenum, GLenum) callconv(.C) void;
            extern fn glStencilOpSeparate(GLenum, GLenum, GLenum, GLenum) callconv(.C) void;
            extern fn glColorMask(GLboolean, GLboolean, GLboolean, GLboolean) callconv(.C) void;

            extern fn glViewport(GLint, GLint, GLsizei, GLsizei) callconv(.C) void;
            extern fn glScissor(GLint, GLint, GLsizei, GLsizei) callconv(.C) void;
            extern fn glGetString(GLenum) callconv(.C) [*c]const GLubyte;
            extern fn glGetError() callconv(.C) GLenum;
            extern fn glGetIntegerv(GLenum, [*c]GLint) callconv(.C) void;
            extern fn glClearColor(GLfloat, GLfloat, GLfloat, GLfloat) callconv(.C) void;
            extern fn glClearStencil(GLint) callconv(.C) void;
            extern fn glClearDepth(GLdouble) callconv(.C) void;
            extern fn glClear(GLbitfield) callconv(.C) void;
            extern fn glGenBuffers(n: GLsizei, buffers: [*c]GLuint) callconv(.C) void;
            extern fn glDeleteVertexArrays(n: GLsizei, arrays: [*c]GLuint) callconv(.C) void;
            extern fn glDeleteBuffers(n: GLsizei, buffers: [*]GLuint) callconv(.C) void;
            extern fn glGenVertexArrays(n: GLsizei, arrays: [*c]GLuint) callconv(.C) void;
            extern fn glBindBuffer(target: GLenum, buffer: GLuint) callconv(.C) void;
            extern fn glBufferData(target: GLenum, size: GLsizeiptr, data: ?*const c_void, usage: GLenum) callconv(.C) void;
            extern fn glBufferSubData(GLenum, GLintptr, GLsizeiptr, ?*const c_void) callconv(.C) void;

            extern fn glCreateShader(shader: GLenum) callconv(.C) GLuint;
            extern fn glShaderSource(shader: GLuint, count: GLsizei, string: *[:0]const GLchar, length: ?*c_int) callconv(.C) void;
            extern fn glCompileShader(shader: GLuint) callconv(.C) void;
            extern fn glDeleteShader(GLuint) callconv(.C) void;

            extern fn glCreateProgram() callconv(.C) GLuint;
            extern fn glDeleteProgram(GLuint) callconv(.C) void;
            extern fn glAttachShader(program: GLuint, shader: GLuint) callconv(.C) void;
            extern fn glLinkProgram(program: GLuint) callconv(.C) void;
            extern fn glGetProgramiv(GLuint, GLenum, [*c]GLint) callconv(.C) void;
            extern fn glGetProgramInfoLog(GLuint, GLsizei, [*c]GLsizei, [*c]GLchar) callconv(.C) void;
            extern fn glUseProgram(program: GLuint) callconv(.C) void;
            extern fn glGetAttribLocation(program: GLuint, name: [*:0]const GLchar) callconv(.C) GLint;
            extern fn glBindFragDataLocation(program: GLuint, colorNumber: GLuint, name: [*:0]const GLchar) callconv(.C) void;
            extern fn glVertexAttribDivisor(index: GLuint, divisor: GLuint) callconv(.C) void;
            extern fn glVertexAttribPointer(index: GLuint, size: GLint, type: GLenum, normalized: GLboolean, stride: GLsizei, offset: ?*const c_void) callconv(.C) void;
            extern fn glBindVertexArray(array: GLuint) callconv(.C) void;

            extern fn glGetShaderiv(shader: GLuint, pname: GLenum, params: *GLint) callconv(.C) void;
            extern fn glEnableVertexAttribArray(index: GLuint) callconv(.C) void;
            extern fn glGetShaderInfoLog(shader: GLuint, maxLength: GLsizei, length: *GLsizei, infoLog: [*]GLchar) callconv(.C) void;

            extern fn glGetUniformLocation(shader: GLuint, name: [*:0]const GLchar) callconv(.C) GLint;
            extern fn glUniform1i(location: GLint, v0: GLint) callconv(.C) void;
            extern fn glUniform1iv(GLint, GLsizei, [*c]const GLint) callconv(.C) void;
            extern fn glUniform1f(location: GLint, v0: GLfloat) callconv(.C) void;
            extern fn glUniform1fv(GLint, GLsizei, [*c]const GLfloat) callconv(.C) void;
            extern fn glUniform2fv(GLint, GLsizei, [*c]const GLfloat) callconv(.C) void;
            extern fn glUniform3fv(GLint, GLsizei, [*c]const GLfloat) callconv(.C) void;
            extern fn glUniform4fv(GLint, GLsizei, [*c]const GLfloat) callconv(.C) void;
            extern fn glUniform3f(location: GLint, v0: GLfloat, v1: GLfloat, v2: GLfloat) callconv(.C) void;
            extern fn glUniformMatrix3fv(GLint, GLsizei, GLboolean, [*c]const GLfloat) callconv(.C) void;
            extern fn glUniformMatrix4fv(location: GLint, count: GLsizei, transpose: GLboolean, value: *const GLfloat) callconv(.C) void;
            extern fn glUniformMatrix3x2fv(GLint, GLsizei, GLboolean, [*c]const GLfloat) callconv(.C) void;

            extern fn glDrawElements(GLenum, GLsizei, GLenum, ?*const c_void) callconv(.C) void;
            extern fn glDrawElementsInstanced(GLenum, GLsizei, GLenum, ?*const c_void, GLsizei) callconv(.C) void;
            extern fn glDrawArrays(GLenum, GLint, GLsizei) callconv(.C) void;

            extern fn glGenFramebuffers(GLsizei, [*c]GLuint) callconv(.C) void;
            extern fn glDeleteFramebuffers(GLsizei, [*c]const GLuint) callconv(.C) void;
            extern fn glBindFramebuffer(GLenum, GLuint) callconv(.C) void;
            extern fn glFramebufferTexture(GLenum, GLenum, GLuint, GLint) callconv(.C) void;
            extern fn glDrawBuffers(GLsizei, [*c]const GLenum) callconv(.C) void;
            extern fn glCheckFramebufferStatus(GLenum) callconv(.C) GLenum;

            extern fn glGenRenderbuffers(GLsizei, [*c]GLuint) callconv(.C) void;
            extern fn glDeleteRenderbuffers(GLsizei, [*c]const GLuint) callconv(.C) void;
            extern fn glBindRenderbuffer(GLenum, GLuint) callconv(.C) void;
            extern fn glRenderbufferStorage(GLenum, GLenum, GLsizei, GLsizei) callconv(.C) void;
            extern fn glFramebufferRenderbuffer(GLenum, GLenum, GLenum, GLuint) callconv(.C) void;

            extern fn glGenTextures(GLsizei, [*c]GLuint) callconv(.C) void;
            extern fn glDeleteTextures(GLsizei, [*c]const GLuint) callconv(.C) void;
            extern fn glBindTexture(GLenum, GLuint) callconv(.C) void;
            extern fn glTexParameteri(GLenum, GLenum, GLint) callconv(.C) void;
            extern fn glTexParameteriv(GLenum, GLenum, [*c]const GLint) callconv(.C) void;
            extern fn glTexImage1D(GLenum, GLint, GLint, GLsizei, GLint, GLenum, GLenum, ?*const c_void) callconv(.C) void;
            extern fn glTexImage2D(GLenum, GLint, GLint, GLsizei, GLsizei, GLint, GLenum, GLenum, ?*const c_void) callconv(.C) void;
            extern fn glGenerateMipmap(GLenum) callconv(.C) void;
            extern fn glActiveTexture(GLenum) callconv(.C) void;
        };
        {
            gl.glEnable = wasmEnv.glEnable;
            gl.glDisable = wasmEnv.glDisable;
            gl.glBlendFunc = wasmEnv.glBlendFunc;
            gl.glBlendFuncSeparate = wasmEnv.glBlendFuncSeparate;
            gl.glBlendEquationSeparate = wasmEnv.glBlendEquationSeparate;
            gl.glBlendColor = wasmEnv.glBlendColor;
            gl.glPolygonMode = wasmEnv.glPolygonMode;
            gl.glDepthMask = wasmEnv.glDepthMask;
            gl.glDepthFunc = wasmEnv.glDepthFunc;
            gl.glStencilFunc = wasmEnv.glStencilFunc;
            gl.glStencilFuncSeparate = wasmEnv.glStencilFuncSeparate;
            gl.glStencilMask = wasmEnv.glStencilMask;
            gl.glStencilMaskSeparate = wasmEnv.glStencilMaskSeparate;
            gl.glStencilOp = wasmEnv.glStencilOp;
            gl.glStencilOpSeparate = wasmEnv.glStencilOpSeparate;
            gl.glColorMask = wasmEnv.glColorMask;

            gl.glViewport = wasmEnv.glViewport;
            gl.glScissor = wasmEnv.glScissor;
            gl.glGetString = wasmEnv.glGetString;
            gl.glGetError = wasmEnv.glGetError;
            gl.glGetIntegerv = wasmEnv.glGetIntegerv;
            gl.glClearColor = wasmEnv.glClearColor;
            gl.glClearStencil = wasmEnv.glClearStencil;
            gl.glClearDepth = wasmEnv.glClearDepth;
            gl.glClear = wasmEnv.glClear;
            gl.glGenBuffers = wasmEnv.glGenBuffers;
            gl.glDeleteVertexArrays = wasmEnv.glDeleteVertexArrays;
            gl.glDeleteBuffers = wasmEnv.glDeleteBuffers;
            gl.glGenVertexArrays = wasmEnv.glGenVertexArrays;
            gl.glBindBuffer = wasmEnv.glBindBuffer;
            gl.glBufferData = wasmEnv.glBufferData;
            gl.glBufferSubData = wasmEnv.glBufferSubData;

            gl.glCreateShader = wasmEnv.glCreateShader;
            gl.glShaderSource = wasmEnv.glShaderSource;
            gl.glCompileShader = wasmEnv.glCompileShader;
            gl.glDeleteShader = wasmEnv.glDeleteShader;

            gl.glCreateProgram = wasmEnv.glCreateProgram;
            gl.glDeleteProgram = wasmEnv.glDeleteProgram;
            gl.glAttachShader = wasmEnv.glAttachShader;
            gl.glLinkProgram = wasmEnv.glLinkProgram;
            gl.glGetProgramiv = wasmEnv.glGetProgramiv;
            gl.glGetProgramInfoLog = wasmEnv.glGetProgramInfoLog;
            gl.glUseProgram = wasmEnv.glUseProgram;
            gl.glGetAttribLocation = wasmEnv.glGetAttribLocation;
            gl.glBindFragDataLocation = wasmEnv.glBindFragDataLocation;
            gl.glVertexAttribDivisor = wasmEnv.glVertexAttribDivisor;
            gl.glVertexAttribPointer = wasmEnv.glVertexAttribPointer;
            gl.glBindVertexArray = wasmEnv.glBindVertexArray;

            gl.glGetShaderiv = wasmEnv.glGetShaderiv;
            gl.glEnableVertexAttribArray = wasmEnv.glEnableVertexAttribArray;
            gl.glGetShaderInfoLog = wasmEnv.glGetShaderInfoLog;

            gl.glGetUniformLocation = wasmEnv.glGetUniformLocation;
            gl.glUniform1i = wasmEnv.glUniform1i;
            gl.glUniform1iv = wasmEnv.glUniform1iv;
            gl.glUniform1f = wasmEnv.glUniform1f;
            gl.glUniform1fv = wasmEnv.glUniform1fv;
            gl.glUniform2fv = wasmEnv.glUniform2fv;
            gl.glUniform3fv = wasmEnv.glUniform3fv;
            gl.glUniform4fv = wasmEnv.glUniform4fv;
            gl.glUniform3f = wasmEnv.glUniform3f;
            gl.glUniformMatrix3fv = wasmEnv.glUniformMatrix3fv;
            gl.glUniformMatrix4fv = wasmEnv.glUniformMatrix4fv;
            gl.glUniformMatrix3x2fv = wasmEnv.glUniformMatrix3x2fv;

            gl.glDrawElements = wasmEnv.glDrawElements;
            gl.glDrawElementsInstanced = wasmEnv.glDrawElementsInstanced;
            gl.glDrawArrays = wasmEnv.glDrawArrays;

            gl.glGenFramebuffers = wasmEnv.glGenFramebuffers;
            gl.glDeleteFramebuffers = wasmEnv.glDeleteFramebuffers;
            gl.glBindFramebuffer = wasmEnv.glBindFramebuffer;
            gl.glFramebufferTexture = wasmEnv.glFramebufferTexture;
            gl.glDrawBuffers = wasmEnv.glDrawBuffers;
            gl.glCheckFramebufferStatus = wasmEnv.glCheckFramebufferStatus;

            gl.glGenRenderbuffers = wasmEnv.glGenRenderbuffers;
            gl.glDeleteRenderbuffers = wasmEnv.glDeleteRenderbuffers;
            gl.glBindRenderbuffer = wasmEnv.glBindRenderbuffer;
            gl.glRenderbufferStorage = wasmEnv.glRenderbufferStorage;
            gl.glFramebufferRenderbuffer = wasmEnv.glFramebufferRenderbuffer;

            gl.glGenTextures = wasmEnv.glGenTextures;
            gl.glDeleteTextures = wasmEnv.glDeleteTextures;
            gl.glBindTexture = wasmEnv.glBindTexture;
            gl.glTexParameteri = wasmEnv.glTexParameteri;
            gl.glTexParameteriv = wasmEnv.glTexParameteriv;
            gl.glTexImage1D = wasmEnv.glTexImage1D;
            gl.glTexImage2D = wasmEnv.glTexImage2D;
            gl.glGenerateMipmap = wasmEnv.glGenerateMipmap;
            gl.glActiveTexture = wasmEnv.glActiveTexture;
        }
        return;
    }

    const lib = switch (std.builtin.os.tag) {
        .linux, .freebsd, .openbsd => "libOpenGL.so.0",
        .windows => "OPENGL32",
        .macos, .tvos, .watchos, .ios => "/System/Library/Frameworks/OpenGL.framework/Versions/Current/OpenGL",
        else => unreachable,
    };

    var dynlib = std.DynLib.openZ(lib) catch |err| {
        std.debug.print("could not open gl dylib: {}\n", .{err});
        unreachable;
    };
    defer dynlib.close();

    inline for (@typeInfo(Funcs).Struct.fields) |field, i| {
        @field(gl, field.name) = dynlib.lookup(field.field_type, field.name ++ &[_:0]u8{0}).?;
    }
}

/// loader is a GL function loader, for example SDL_GL_GetProcAddress or glfwGetProcAddress
pub fn loadFunctions(loader: fn ([*c]const u8) callconv(.C) ?*c_void) void {
    inline for (@typeInfo(Funcs).Struct.fields) |field, i| {
        @field(gl, field.name) = @ptrCast(field.field_type, loader(field.name ++ &[_]u8{0}));
    }
}

pub fn glEnable(state: GLenum) void {
    gl.glEnable(state);
}

pub fn glDisable(state: GLenum) void {
    gl.glDisable(state);
}

pub fn glBlendFunc(src: GLenum, dst: GLenum) void {
    gl.glBlendFunc(src, dst);
}

pub fn glBlendFuncSeparate(src_rgb: GLenum, dst_rgb: GLenum, src_alpha: GLenum, dst_alpha: GLenum) void {
    gl.glBlendFuncSeparate(src_rgb, dst_rgb, src_alpha, dst_alpha);
}

pub fn glBlendEquationSeparate(mode_rgb: GLenum, mode_alpha: GLenum) void {
    gl.glBlendEquationSeparate(mode_rgb, mode_alpha);
}

pub fn glBlendColor(r: GLfloat, g: GLfloat, b: GLfloat, a: GLfloat) void {
    gl.glBlendColor(r, g, b, a);
}

pub fn glPolygonMode(face: GLenum, mode: GLenum) void {
    gl.glPolygonMode(face, mode);
}

pub fn glDepthMask(enable: GLboolean) void {
    gl.glDepthMask(enable);
}

pub fn glDepthFunc(func: GLenum) void {
    gl.glDepthFunc(func);
}

pub fn glStencilFunc(func: GLenum, ref: GLint, mask: GLuint) void {
    gl.glStencilFunc(func, ref, mask);
}

pub fn glStencilFuncSeparate(face: GLenum, func: GLenum, ref: GLint, mask: GLuint) void {
    gl.glStencilFuncSeparate(face, func, ref, mask);
}

pub fn glStencilMask(mask: GLuint) void {
    gl.glStencilMask(mask);
}

pub fn glStencilMaskSeparate(face: GLenum, mask: GLuint) void {
    gl.glStencilMaskSeparate(face, mask);
}

pub fn glStencilOp(sfail: GLenum, dpfail: GLenum, dppass: GLenum) void {
    gl.glStencilOp(sfail, dpfail, dppass);
}

pub fn glStencilOpSeparate(face: GLenum, sfail: GLenum, dpfail: GLenum, dppass: GLenum) void {
    gl.glStencilOpSeparate(face, sfail, dpfail, dppass);
}

pub fn glColorMask(r: GLboolean, g: GLboolean, b: GLboolean, a: GLboolean) void {
    gl.glColorMask(r, g, b, a);
}

pub fn glViewport(x: GLint, y: GLint, w: GLsizei, h: GLsizei) void {
    gl.glViewport(x, y, w, h);
}

pub fn glScissor(x: GLint, y: GLint, w: GLsizei, h: GLsizei) void {
    gl.glScissor(x, y, w, h);
}

pub fn glGetString(which: GLenum) [*c]const GLubyte {
    return gl.glGetString(which);
}

pub fn glGetError() GLenum {
    return gl.glGetError();
}

pub fn glGetIntegerv(name: GLenum, data: [*c]GLint) void {
    gl.glGetIntegerv(name, data);
}

pub fn glClearColor(r: GLfloat, g: GLfloat, b: GLfloat, a: GLfloat) void {
    gl.glClearColor(r, g, b, a);
}

pub fn glClearStencil(stencil: GLint) void {
    gl.glClearStencil(stencil);
}

pub fn glClearDepth(depth: GLdouble) void {
    gl.glClearDepth(depth);
}

pub fn glClear(which: GLbitfield) void {
    gl.glClear(which);
}

pub fn glGenBuffers(n: GLsizei, buffers: [*c]GLuint) void {
    gl.glGenBuffers(n, buffers);
}

pub fn glDeleteVertexArrays(n: GLsizei, arrays: [*c]GLuint) void {
    gl.glDeleteVertexArrays(n, arrays);
}

pub fn glDeleteBuffers(n: GLsizei, buffers: [*c]GLuint) void {
    gl.glDeleteBuffers(n, buffers);
}

pub fn glGenVertexArrays(n: GLsizei, arrays: [*c]GLuint) void {
    gl.glGenVertexArrays(n, arrays);
}

pub fn glBindBuffer(target: GLenum, buffer: GLuint) void {
    gl.glBindBuffer(target, buffer);
}

pub fn glBufferData(target: GLenum, size: GLsizeiptr, data: ?*const c_void, usage: GLenum) void {
    gl.glBufferData(target, size, data, usage);
}

pub fn glBufferSubData(target: GLenum, offset: GLintptr, size: GLsizeiptr, data: ?*const c_void) void {
    gl.glBufferSubData(target, offset, size, data);
}

pub fn glCreateShader(shader: GLenum) GLuint {
    return gl.glCreateShader(shader);
}

pub fn glShaderSource(shader: GLuint, count: GLsizei, string: *[:0]const GLchar, length: ?*c_int) void {
    gl.glShaderSource(shader, count, string, length);
}

pub fn glCompileShader(shader: GLuint) void {
    gl.glCompileShader(shader);
}

pub fn glDeleteShader(shader: GLuint) void {
    gl.glDeleteShader(shader);
}

pub fn glCreateProgram() GLuint {
    return gl.glCreateProgram();
}

pub fn glDeleteProgram(program: GLuint) void {
    gl.glDeleteProgram(program);
}

pub fn glAttachShader(program: GLuint, shader: GLuint) void {
    gl.glAttachShader(program, shader);
}

pub fn glLinkProgram(program: GLuint) void {
    gl.glLinkProgram(program);
}

pub fn glGetProgramiv(program: GLuint, pname: GLenum, params: [*c]GLint) void {
    gl.glGetProgramiv(program, pname, params);
}

pub fn glGetProgramInfoLog(program: GLuint, max_length: GLsizei, length: [*c]GLsizei, info_log: [*c]GLchar) void {
    gl.glGetProgramInfoLog(program, max_length, length, info_log);
}

pub fn glUseProgram(program: GLuint) void {
    gl.glUseProgram(program);
}

pub fn glGetAttribLocation(program: GLuint, name: [*:0]const GLchar) GLint {
    return gl.glGetAttribLocation(program, name);
}

pub fn glBindFragDataLocation(program: GLuint, colorNumber: GLuint, name: [*:0]const GLchar) void {
    gl.glBindFragDataLocation(program, colorNumber, name);
}

pub fn glVertexAttribPointer(index: GLuint, size: GLint, kind: GLenum, normalized: GLboolean, stride: GLsizei, offset: ?usize) void {
    const off = if (offset) |o| @intToPtr(*c_void, o) else null;
    gl.glVertexAttribPointer(index, size, kind, normalized, stride, off);
}

pub fn glVertexAttribDivisor(index: GLuint, divisor: GLuint) void {
    gl.glVertexAttribDivisor(index, divisor);
}

pub fn glBindVertexArray(array: GLuint) void {
    gl.glBindVertexArray(array);
}

pub fn glGetShaderiv(shader: GLuint, pname: GLenum, params: *GLint) void {
    gl.glGetShaderiv(shader, pname, params);
}

pub fn glEnableVertexAttribArray(index: GLuint) void {
    gl.glEnableVertexAttribArray(index);
}

pub fn glGetShaderInfoLog(shader: GLuint, maxLength: GLsizei, length: *GLsizei, infoLog: [*]GLchar) void {
    gl.glGetShaderInfoLog(shader, maxLength, length, infoLog);
}

pub fn glGetUniformLocation(shader: GLuint, name: [*:0]const GLchar) GLint {
    return gl.glGetUniformLocation(shader, name);
}

pub fn glUniform1i(location: GLint, value: GLint) void {
    gl.glUniform1i(location, value);
}

pub fn glUniform1iv(location: GLint, count: GLsizei, value: [*c]const GLint) void {
    gl.glUniform1iv(location, count, value);
}

pub fn glUniform1f(location: GLint, v0: GLfloat) void {
    gl.glUniform1f(location, v0);
}

pub fn glUniform1fv(location: GLint, count: GLsizei, value: [*c]const GLfloat) void {
    gl.glUniform1fv(location, count, value);
}

pub fn glUniform2fv(location: GLint, count: GLsizei, value: [*c]const GLfloat) void {
    gl.glUniform2fv(location, count, value);
}

pub fn glUniform3fv(location: GLint, count: GLsizei, value: [*c]const GLfloat) void {
    gl.glUniform3fv(location, count, value);
}

pub fn glUniform4fv(location: GLint, count: GLsizei, value: [*c]const GLfloat) void {
    gl.glUniform4fv(location, count, value);
}

pub fn glUniform3f(location: GLint, v0: GLfloat, v1: GLfloat, v2: GLfloat) void {
    gl.glUniform3f(location, v0, v1, v2);
}

pub fn glUniformMatrix3fv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) void {
    gl.glUniformMatrix3fv(location, count, transpose, value);
}

pub fn glUniformMatrix4fv(location: GLint, count: GLsizei, transpose: GLboolean, value: *const GLfloat) void {
    gl.glUniformMatrix4fv(location, count, transpose, value);
}

pub fn glUniformMatrix3x2fv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) void {
    gl.glUniformMatrix3x2fv(location, count, transpose, value);
}

pub fn glDrawElements(mode: GLenum, count: GLsizei, kind: GLenum, indices: ?*const c_void) void {
    gl.glDrawElements(mode, count, kind, indices);
}

pub fn glDrawElementsInstanced(mode: GLenum, count: GLsizei, kind: GLenum, indices: ?*const c_void, instance_count: GLsizei) void {
    gl.glDrawElementsInstanced(mode, count, kind, indices, instance_count);
}

pub fn glDrawArrays(mode: GLenum, first: GLint, count: GLsizei) void {
    gl.glDrawArrays(mode, first, count);
}

pub fn glGenFramebuffers(n: GLsizei, framebuffers: [*c]GLuint) void {
    gl.glGenFramebuffers(n, framebuffers);
}

pub fn glDeleteFramebuffers(n: GLsizei, framebuffers: [*c]GLuint) void {
    gl.glDeleteFramebuffers(n, framebuffers);
}

pub fn glBindFramebuffer(target: GLenum, framebuffer: GLuint) void {
    gl.glBindFramebuffer(target, framebuffer);
}

pub fn glCheckFramebufferStatus(target: GLenum) GLenum {
    return gl.glCheckFramebufferStatus(target);
}

pub fn glGenRenderbuffers(n: GLsizei, buffers: [*c]GLuint) void {
    gl.glGenRenderbuffers(n, buffers);
}

pub fn glDeleteRenderbuffers(n: GLsizei, buffers: [*c]const GLuint) void {
    gl.glDeleteRenderbuffers(n, buffers);
}

pub fn glBindRenderbuffer(target: GLenum, buffer: GLuint) void {
    gl.glBindRenderbuffer(target, buffer);
}

pub fn glRenderbufferStorage(target: GLenum, format: GLenum, width: GLsizei, height: GLsizei) void {
    gl.glRenderbufferStorage(target, format, width, height);
}

pub fn glFramebufferRenderbuffer(target: GLenum, attachment: GLenum, render_buffer_target: GLenum, buffer: GLuint) void {
    gl.glFramebufferRenderbuffer(target, attachment, render_buffer_target, buffer);
}

pub fn glFramebufferTexture(target: GLenum, attachment: GLenum, texture: GLuint, level: GLint) void {
    gl.glFramebufferTexture(target, attachment, texture, level);
}

pub fn glDrawBuffers(n: GLsizei, bufs: [*c]const GLenum) void {
    gl.glDrawBuffers(n, bufs);
}

pub fn glGenTextures(n: GLsizei, textures: [*c]GLuint) void {
    gl.glGenTextures(n, textures);
}

pub fn glDeleteTextures(n: GLsizei, textures: [*c]const GLuint) void {
    gl.glDeleteTextures(n, textures);
}

pub fn glBindTexture(target: GLenum, texture: GLuint) void {
    gl.glBindTexture(target, texture);
}

pub fn glTexParameteri(target: GLenum, pname: GLenum, param: GLint) void {
    gl.glTexParameteri(target, pname, param);
}

pub fn glTexParameteriv(target: GLenum, pname: GLenum, param: [*c]const GLint) void {
    gl.glTexParameteriv(target, pname, param);
}

pub fn glTexImage1D(target: GLenum, level: GLint, internal_format: GLint, width: GLsizei, border: GLint, format: GLenum, kind: GLenum, data: ?*const c_void) void {
    gl.glTexImage1D(target, level, internal_format, width, border, format, kind, data);
}

pub fn glTexImage2D(target: GLenum, level: GLint, internal_format: GLint, width: GLsizei, height: GLsizei, border: GLint, format: GLenum, kind: GLenum, data: ?*const c_void) void {
    gl.glTexImage2D(target, level, internal_format, width, height, border, format, kind, data);
}

pub fn glGenerateMipmap(target: GLenum) void {
    gl.glGenerateMipmap(target);
}

pub fn glActiveTexture(target: GLenum) void {
    gl.glActiveTexture(target);
}

comptime {
    @import("std").testing.refAllDecls(@This());
}
