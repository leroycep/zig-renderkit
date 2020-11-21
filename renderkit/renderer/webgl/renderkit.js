export default function getWasmImports(canvas, getWasmInstance) {
  const gl = canvas.getContext("webgl2");

  let next_vertexArray_id = 1;
  let vertexArray_storage = {};

  return {
    glEnable: (cap) => gl.enable(cap),
    glDisable: () => {
      console.log("glDisable");
    },
    glBlendFunc: () => {
      console.log("glBlendFunc");
    },
    glBlendFuncSeparate: (srcRGB, dstRGB, srcAlpha, dstAlpha) => gl.blendFuncSeparate(srcRGB, dstRGB, srcAlpha, dstAlpha),
    glBlendEquationSeparate: () => {
      console.log("glBlendEquationSeparate");
    },
    glBlendColor: (red, green, blue, alpha) => gl.blendColor(red, green, blue, alpha),
    glPolygonMode: () => {
      console.log("glPolygonMode");
    },
    glDepthMask: () => {
      console.log("glDepthMask");
    },
    glDepthFunc: (func) => gl.depthFunc(func),
    glStencilFunc: () => {
      console.log("glStencilFunc");
    },
    glStencilFuncSeparate: (face, func, ref, mask) =>
      gl.stencilFuncSeparate(face, func, ref, mask),
    glStencilMask: () => {
      console.log("glStencilMask");
    },
    glStencilMaskSeparate: () => {
      console.log("glStencilMaskSeparate");
    },
    glStencilOp: () => {
      console.log("glStencilOp");
    },
    glStencilOpSeparate: () => {
      console.log("glStencilOpSeparate");
    },
    glColorMask: (red, green, blue, alpha) => gl.colorMask(red, green, blue, alpha),

    glViewport: (x, y, width, height) => gl.viewport(x, y, width, height),
    glScissor: () => {
      console.log("glScissor");
    },
    glGetString: () => {
      console.log("glGetString");
    },
    glGetError: () => {
      console.log("glGetError");
    },
    glGetIntegerv: () => {
      console.log("glGetIntegerv");
    },
    glClearColor: (red, green, blue, alpha) => gl.clearColor(red, green, blue, alpha),
    glClearStencil: () => {
      console.log("glClearStencil");
    },
    glClearDepth: () => {
      console.log("glClearDepth");
    },
    glClear: (mask) => gl.clear(mask),
    glGenBuffers: () => {
      console.log("glGenBuffers");
    },
    glDeleteVertexArrays: () => {
      console.log("glDeleteVertexArrays");
    },
    glDeleteBuffers: () => {
      console.log("glDeleteBuffers");
    },
    glGenVertexArrays: (number, arraysPtr) => {
      let memory = getWasmInstance().exports.memory;
      let arrays = new Uint32Array(memory.buffer, arraysPtr, number)
      for (let i = 0; i < number; i += 1) {
          let id = next_vertexArray_id;
          next_vertexArray_id += 1;

          vertexArray_storage[id] = gl.createVertexArray();

          arrays[i] = id;
      }
    },
    glBindBuffer: () => {
      console.log("glBindBuffer");
    },
    glBufferData: () => {
      console.log("glBufferData");
    },
    glBufferSubData: () => {
      console.log("glBufferSubData");
    },

    glCreateShader: () => {
      console.log("glCreateShader");
    },
    glShaderSource: () => {
      console.log("glShaderSource");
    },
    glCompileShader: () => {
      console.log("glCompileShader");
    },
    glDeleteShader: () => {
      console.log("glDeleteShader");
    },

    glCreateProgram: () => {
      console.log("glCreateProgram");
    },
    glDeleteProgram: () => {
      console.log("glDeleteProgram");
    },
    glAttachShader: () => {
      console.log("glAttachShader");
    },
    glLinkProgram: () => {
      console.log("glLinkProgram");
    },
    glGetProgramiv: () => {
      console.log("glGetProgramiv");
    },
    glGetProgramInfoLog: () => {
      console.log("glGetProgramInfoLog");
    },
    glUseProgram: () => {
      console.log("glUseProgram");
    },
    glGetAttribLocation: () => {
      console.log("glGetAttribLocation");
    },
    glBindFragDataLocation: () => {
      console.log("glBindFragDataLocation");
    },
    glVertexAttribDivisor: () => {
      console.log("glVertexAttribDivisor");
    },
    glVertexAttribPointer: () => {
      console.log("glVertexAttribPointer");
    },
    glBindVertexArray: (id) => gl.bindVertexArray(vertexArray_storage[id]),

    glGetShaderiv: () => {
      console.log("glGetShaderiv");
    },
    glEnableVertexAttribArray: () => {
      console.log("glEnableVertexAttribArray");
    },
    glGetShaderInfoLog: () => {
      console.log("glGetShaderInfoLog");
    },

    glGetUniformLocation: () => {
      console.log("glGetUniformLocation");
    },
    glUniform1i: () => {
      console.log("glUniform1i");
    },
    glUniform1iv: () => {
      console.log("glUniform1iv");
    },
    glUniform1f: () => {
      console.log("glUniform1f");
    },
    glUniform1fv: () => {
      console.log("glUniform1fv");
    },
    glUniform2fv: () => {
      console.log("glUniform2fv");
    },
    glUniform3fv: () => {
      console.log("glUniform3fv");
    },
    glUniform4fv: () => {
      console.log("glUniform4fv");
    },
    glUniform3f: () => {
      console.log("glUniform3f");
    },
    glUniformMatrix3fv: () => {
      console.log("glUniformMatrix3fv");
    },
    glUniformMatrix4fv: () => {
      console.log("glUniformMatrix4fv");
    },
    glUniformMatrix3x2fv: () => {
      console.log("glUniformMatrix3x2fv");
    },

    glDrawElements: () => {
      console.log("glDrawElements");
    },
    glDrawElementsInstanced: () => {
      console.log("glDrawElementsInstanced");
    },
    glDrawArrays: () => {
      console.log("glDrawArrays");
    },

    glGenFramebuffers: () => {
      console.log("glGenFramebuffers");
    },
    glDeleteFramebuffers: () => {
      console.log("glDeleteFramebuffers");
    },
    glBindFramebuffer: () => {
      console.log("glBindFramebuffer");
    },
    glFramebufferTexture: () => {
      console.log("glFramebufferTexture");
    },
    glDrawBuffers: () => {
      console.log("glDrawBuffers");
    },
    glCheckFramebufferStatus: () => {
      console.log("glCheckFramebufferStatus");
    },

    glGenRenderbuffers: () => {
      console.log("glGenRenderbuffers");
    },
    glDeleteRenderbuffers: () => {
      console.log("glDeleteRenderbuffers");
    },
    glBindRenderbuffer: () => {
      console.log("glBindRenderbuffer");
    },
    glRenderbufferStorage: () => {
      console.log("glRenderbufferStorage");
    },
    glFramebufferRenderbuffer: () => {
      console.log("glFramebufferRenderbuffer");
    },

    glGenTextures: () => {
      console.log("glGenTextures");
    },
    glDeleteTextures: () => {
      console.log("glDeleteTextures");
    },
    glBindTexture: () => {
      console.log("glBindTexture");
    },
    glTexParameteri: () => {
      console.log("glTexParameteri");
    },
    glTexParameteriv: () => {
      console.log("glTexParameteriv");
    },
    glTexImage1D: () => {
      console.log("glTexImage1D");
    },
    glTexImage2D: () => {
      console.log("glTexImage2D");
    },
    glGenerateMipmap: () => {
      console.log("glGenerateMipmap");
    },
    glActiveTexture: () => {
      console.log("glActiveTexture");
    },
  };
}
