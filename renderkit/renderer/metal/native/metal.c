#if __has_feature(objc_arc) && !__has_feature(objc_arc_fields)
    #error "Metal requires __has_feature(objc_arc_field) if ARC is enabled (use a more recent compiler version)"
#endif

#include "metal.h"

#define min(a,b) (((a)<(b))?(a):(b))
#define max(a,b) (((a)>(b))?(a):(b))

enum {
    NUM_INFLIGHT_FRAMES = 1,
};

CAMetalLayer* layer;
id<MTLCommandQueue> cmd_queue;
id<MTLCommandBuffer> cmd_buffer;
id<MTLRenderCommandEncoder> cmd_encoder;
id<CAMetalDrawable> cur_drawable;
dispatch_semaphore_t render_semaphore;

bool origin_top_left = true;
bool in_pass = false;
bool pass_valid = false;
int cur_width;
int cur_height;

/*=== COMMON BACKEND STUFF ===================================================*/

typedef struct sg_buffer   { uint32_t id; } sg_buffer;
typedef struct sg_image    { uint32_t id; } sg_image;
typedef struct sg_shader   { uint32_t id; } sg_shader;
typedef struct sg_pass     { uint32_t id; } sg_pass;

typedef enum sg_resource_state {
	SG_RESOURCESTATE_INITIAL,
	SG_RESOURCESTATE_ALLOC,
	SG_RESOURCESTATE_VALID,
	SG_RESOURCESTATE_FAILED,
	SG_RESOURCESTATE_INVALID,
	_SG_RESOURCESTATE_FORCE_U32 = 0x7FFFFFFF
} sg_resource_state;

/* resource pool slots */
typedef struct {
	uint32_t id;
	uint32_t ctx_id;
	sg_resource_state state;
} _sg_slot_t;

typedef struct sg_slot_info {
	sg_resource_state state;    /* the current state of this resource slot */
	uint32_t res_id;        /* type-neutral resource if (e.g. sg_buffer.id) */
	uint32_t ctx_id;        /* the context this resource belongs to */
} sg_slot_info;

typedef struct sg_buffer_info {
	sg_slot_info slot;              /* resource pool slot info */
	uint32_t update_frame_index;    /* frame index of last sg_update_buffer() */
	uint32_t append_frame_index;    /* frame index of last sg_append_buffer() */
	int append_pos;                 /* current position in buffer for sg_append_buffer() */
	bool append_overflow;           /* is buffer in overflow state (due to sg_append_buffer) */
	int num_slots;                  /* number of renaming-slots for dynamically updated buffers */
	int active_slot;                /* currently active write-slot for dynamically updated buffers */
} sg_buffer_info;

typedef struct sg_image_info {
	sg_slot_info slot;              /* resource pool slot info */
	uint32_t upd_frame_index;       /* frame index of last sg_update_image() */
	int num_slots;                  /* number of renaming-slots for dynamically updated images */
	int active_slot;                /* currently active write-slot for dynamically updated images */
	int width;                      /* image width */
	int height;                     /* image height */
} sg_image_info;

typedef struct sg_shader_info {
	sg_slot_info slot;              /* resoure pool slot info */
} sg_shader_info;

typedef struct sg_pass_info {
	sg_slot_info slot;              /* resource pool slot info */
} sg_pass_info;

/* constants */
enum {
	_SG_STRING_SIZE = 16,
	_SG_SLOT_SHIFT = 16,
	_SG_SLOT_MASK = (1<<_SG_SLOT_SHIFT)-1,
	_SG_MAX_POOL_SIZE = (1<<_SG_SLOT_SHIFT),
	_SG_DEFAULT_BUFFER_POOL_SIZE = 128,
	_SG_DEFAULT_IMAGE_POOL_SIZE = 128,
	_SG_DEFAULT_SHADER_POOL_SIZE = 32,
	_SG_DEFAULT_PIPELINE_POOL_SIZE = 64,
	_SG_DEFAULT_PASS_POOL_SIZE = 16,
	_SG_DEFAULT_CONTEXT_POOL_SIZE = 16,
	_SG_DEFAULT_SAMPLER_CACHE_CAPACITY = 64,
	_SG_DEFAULT_UB_SIZE = 4 * 1024 * 1024,
	_SG_DEFAULT_STAGING_SIZE = 8 * 1024 * 1024,
};

/* fixed-size string */
typedef struct {
	char buf[_SG_STRING_SIZE];
} _sg_str_t;

/* helper macros */
#define _sg_def(val, def) (((val) == 0) ? (def) : (val))
#define _sg_def_flt(val, def) (((val) == 0.0f) ? (def) : (val))
#define _sg_min(a,b) ((a<b)?a:b)
#define _sg_max(a,b) ((a>b)?a:b)
#define _sg_clamp(v,v0,v1) ((v<v0)?(v0):((v>v1)?(v1):(v)))
#define _sg_fequal(val,cmp,delta) (((val-cmp)> -delta)&&((val-cmp)<delta))

/*=== GENERIC SAMPLER CACHE ==================================================*/

/*
	this is used by the Metal and WGPU backends to reduce the
	number of sampler state objects created through the backend API
*/
typedef struct {
	TextureFilter_t min_filter;
	TextureFilter_t mag_filter;
	TextureWrap_t wrap_u;
	TextureWrap_t wrap_v;
	uint32_t max_anisotropy;
	int min_lod;    /* orig min/max_lod is float, this is int(min/max_lod*1000.0) */
	int max_lod;
	uintptr_t sampler_handle;
} _sg_sampler_cache_item_t;

typedef struct {
	int capacity;
	int num_items;
	_sg_sampler_cache_item_t* items;
} _sg_sampler_cache_t;

void _sg_smpcache_init(_sg_sampler_cache_t* cache, int capacity) {
	RENDERKIT_ASSERT(cache && (capacity > 0));
	memset(cache, 0, sizeof(_sg_sampler_cache_t));
	cache->capacity = capacity;
	const int size = cache->capacity * sizeof(_sg_sampler_cache_item_t);
	cache->items = (_sg_sampler_cache_item_t*) malloc(size);
	memset(cache->items, 0, size);
}

void _sg_smpcache_discard(_sg_sampler_cache_t* cache) {
	RENDERKIT_ASSERT(cache && cache->items);
	free(cache->items);
	cache->items = 0;
	cache->num_items = 0;
	cache->capacity = 0;
}

int _sg_smpcache_find_item(const _sg_sampler_cache_t* cache, const ImageDesc_t* img_desc) {
	/* return matching sampler cache item index or -1 */
	RENDERKIT_ASSERT(cache && cache->items);
	RENDERKIT_ASSERT(img_desc);
	
	const int min_lod = 0;
	const int max_lod = 0;
	for (int i = 0; i < cache->num_items; i++) {
		const _sg_sampler_cache_item_t* item = &cache->items[i];
		if ((img_desc->min_filter == item->min_filter) &&
			(img_desc->mag_filter == item->mag_filter) &&
			(img_desc->wrap_u == item->wrap_u) &&
			(img_desc->wrap_v == item->wrap_v) &&
			(min_lod == item->min_lod) &&
			(max_lod == item->max_lod))
		{
			return i;
		}
	}
	/* fallthrough: no matching cache item found */
	return -1;
}

void _sg_smpcache_add_item(_sg_sampler_cache_t* cache, const ImageDesc_t* img_desc, uintptr_t sampler_handle) {
	RENDERKIT_ASSERT(cache && cache->items);
	RENDERKIT_ASSERT(img_desc);
	RENDERKIT_ASSERT(cache->num_items < cache->capacity);
	
	const int item_index = cache->num_items++;
	_sg_sampler_cache_item_t* item = &cache->items[item_index];
	item->min_filter = img_desc->min_filter;
	item->mag_filter = img_desc->mag_filter;
	item->wrap_u = img_desc->wrap_u;
	item->wrap_v = img_desc->wrap_v;
	item->sampler_handle = sampler_handle;
}

uintptr_t _sg_smpcache_sampler(_sg_sampler_cache_t* cache, int item_index) {
	RENDERKIT_ASSERT(cache && cache->items);
	RENDERKIT_ASSERT((item_index >= 0) && (item_index < cache->num_items));
	return cache->items[item_index].sampler_handle;
}

/*=== METAL BACKEND DECLARATIONS =============================================*/
#define _SG_MTL_UB_ALIGN (256)
#define _SG_MTL_INVALID_SLOT_INDEX (0)

typedef struct {
	uint32_t frame_index;   /* frame index at which it is safe to release this resource */
	uint32_t slot_index;
} _sg_mtl_release_item_t;

typedef struct {
	NSMutableArray* pool;
	uint32_t num_slots;
	uint32_t free_queue_top;
	uint32_t* free_queue;
	uint32_t release_queue_front;
	uint32_t release_queue_back;
	_sg_mtl_release_item_t* release_queue;
} _sg_mtl_idpool_t;

typedef struct {
	int size;
	int append_pos;
	bool append_overflow;
	BufferType_t type;
	Usage_t usage;
	uint32_t update_frame_index;
	uint32_t append_frame_index;
	int num_slots;
	int active_slot;
} _sg_buffer_common_t;

typedef struct {
	_sg_slot_t slot;
	_sg_buffer_common_t cmn;
	struct {
		uint32_t buf[NUM_INFLIGHT_FRAMES];  /* index into _sg_mtl_pool */
	} mtl;
} _sg_mtl_buffer_t;
typedef _sg_mtl_buffer_t _sg_buffer_t;

typedef struct {
	bool render_target;
	int width;
	int height;
	int depth;
	int num_mipmaps;
	Usage_t usage;
	int sample_count;
	TextureFilter_t min_filter;
	TextureFilter_t mag_filter;
	TextureWrap_t wrap_u;
	TextureWrap_t wrap_v;
	uint32_t upd_frame_index;
	int num_slots;
	int active_slot;
} _sg_image_common_t;

typedef struct {
	_sg_slot_t slot;
	_sg_image_common_t cmn;
	struct {
		uint32_t tex[NUM_INFLIGHT_FRAMES];
		uint32_t depth_tex;
		uint32_t msaa_tex;
		uint32_t sampler_state;
	} mtl;
} _sg_mtl_image_t;
typedef _sg_mtl_image_t _sg_image_t;

typedef struct {
	uint32_t mtl_lib;
	uint32_t mtl_func;
} _sg_mtl_shader_stage_t;

typedef struct {
	int num_uniform_blocks;
	int num_images;
//	_sg_uniform_block_t uniform_blocks[SG_MAX_SHADERSTAGE_UBS];
//	_sg_shader_image_t images[SG_MAX_SHADERSTAGE_IMAGES];
} _sg_shader_stage_t;

typedef struct {
	_sg_shader_stage_t stage[2];
} _sg_shader_common_t;

typedef struct {
	_sg_slot_t slot;
	_sg_shader_common_t cmn;
	struct {
		_sg_mtl_shader_stage_t stage[2];
	} mtl;
} _sg_mtl_shader_t;
typedef _sg_mtl_shader_t _sg_shader_t;

typedef struct {
	_sg_image_t* image;
} _sg_mtl_attachment_t;

typedef struct {
	sg_image image_id;
	int mip_level;
	int slice;
} _sg_attachment_common_t;

typedef struct {
	int num_color_atts;
	_sg_attachment_common_t color_atts[4];
	_sg_attachment_common_t ds_att;
} _sg_pass_common_t;

typedef struct {
	_sg_slot_t slot;
	_sg_pass_common_t cmn;
	struct {
		_sg_mtl_attachment_t color_atts[4];
		_sg_mtl_attachment_t ds_att;
	} mtl;
} _sg_mtl_pass_t;
typedef _sg_mtl_pass_t _sg_pass_t;
typedef _sg_attachment_common_t _sg_attachment_t;

typedef struct {
	_sg_slot_t slot;
} _sg_mtl_context_t;
typedef _sg_mtl_context_t _sg_context_t;

/* resouce binding state cache */
typedef struct {
	const _sg_buffer_t* cur_indexbuffer;
	int cur_indexbuffer_offset;
	sg_buffer cur_indexbuffer_id;
	const _sg_buffer_t* cur_vertexbuffers[8];
	int cur_vertexbuffer_offsets[8];
	sg_buffer cur_vertexbuffer_ids[8];
	const _sg_image_t* cur_vs_images[12];
	sg_image cur_vs_image_ids[12];
	const _sg_image_t* cur_fs_images[12];
	sg_image cur_fs_image_ids[12];
} _sg_mtl_state_cache_t;

typedef struct {
	bool valid;
	uint32_t frame_index;
	uint32_t cur_frame_rotate_index;
	bool in_pass;
	bool pass_valid;
	int cur_width;
	int cur_height;
	_sg_mtl_state_cache_t state_cache;
	_sg_sampler_cache_t sampler_cache;
	_sg_mtl_idpool_t idpool;
	dispatch_semaphore_t sem;
	id<MTLDevice> device;
	id<MTLCommandQueue> cmd_queue;
	id<MTLCommandBuffer> cmd_buffer;
	id<MTLRenderCommandEncoder> cmd_encoder;
	id<MTLBuffer> uniform_buffers[NUM_INFLIGHT_FRAMES];
} _mtl_backend_t;
static _mtl_backend_t _mtl;

uint32_t _sg_mtl_add_resource(id res);

uint32_t _sg_mtl_create_sampler(id<MTLDevice> mtl_device, const ImageDesc_t img_desc) {
	int index = _sg_smpcache_find_item(&_mtl.sampler_cache, &img_desc);
	if (index >= 0) {
		/* reuse existing sampler */
		return (uint32_t) _sg_smpcache_sampler(&_mtl.sampler_cache, index);
	}
	else {
		/* create a new Metal sampler state object and add to sampler cache */
		MTLSamplerDescriptor* mtl_desc = [[MTLSamplerDescriptor alloc] init];
		mtl_desc.sAddressMode = _mtl_address_mode(img_desc.wrap_u);
		mtl_desc.tAddressMode = _mtl_address_mode(img_desc.wrap_v);
		mtl_desc.minFilter = _mtl_minmag_filter(img_desc.min_filter);
		mtl_desc.magFilter = _mtl_minmag_filter(img_desc.mag_filter);
		mtl_desc.normalizedCoordinates = YES;
		id<MTLSamplerState> mtl_sampler = [mtl_device newSamplerStateWithDescriptor:mtl_desc];
		uint32_t sampler_handle = _sg_mtl_add_resource(mtl_sampler);
		_sg_smpcache_add_item(&_mtl.sampler_cache, &img_desc, sampler_handle);
		return sampler_handle;
	}
}

#define _SG_CLEAR(type, item) { item = (type) { 0 }; }

/*-- a pool for all Metal resource objects, with deferred release queue -------*/
void _sg_mtl_init_pool(const RendererDesc_t desc) {
	_mtl.idpool.num_slots = 2 *
		(
			2 * desc.pool_sizes.buffers +
			5 * desc.pool_sizes.texture +
			4 * desc.pool_sizes.shaders +
			desc.pool_sizes.offscreen_pass
		);
	_mtl.idpool.pool = [NSMutableArray arrayWithCapacity:_mtl.idpool.num_slots];
	NSNull* null = [NSNull null];
	for (uint32_t i = 0; i < _mtl.idpool.num_slots; i++) {
		[_mtl.idpool.pool addObject:null];
	}
	RENDERKIT_ASSERT([_mtl.idpool.pool count] == _mtl.idpool.num_slots);
	/* a queue of currently free slot indices */
	_mtl.idpool.free_queue_top = 0;
	_mtl.idpool.free_queue = (uint32_t*)malloc(_mtl.idpool.num_slots * sizeof(uint32_t));
	/* pool slot 0 is reserved! */
	for (int i = _mtl.idpool.num_slots-1; i >= 1; i--) {
		_mtl.idpool.free_queue[_mtl.idpool.free_queue_top++] = (uint32_t)i;
	}
	/* a circular queue which holds release items (frame index
	   when a resource is to be released, and the resource's
	   pool index
	*/
	_mtl.idpool.release_queue_front = 0;
	_mtl.idpool.release_queue_back = 0;
	_mtl.idpool.release_queue = (_sg_mtl_release_item_t*)malloc(_mtl.idpool.num_slots * sizeof(_sg_mtl_release_item_t));
	for (uint32_t i = 0; i < _mtl.idpool.num_slots; i++) {
		_mtl.idpool.release_queue[i].frame_index = 0;
		_mtl.idpool.release_queue[i].slot_index = _SG_MTL_INVALID_SLOT_INDEX;
	}
}

/* get a new free resource pool slot */
uint32_t _sg_mtl_alloc_pool_slot(void) {
	RENDERKIT_ASSERT(_mtl.idpool.free_queue_top > 0);
	const uint32_t slot_index = _mtl.idpool.free_queue[--_mtl.idpool.free_queue_top];
	RENDERKIT_ASSERT((slot_index > 0) && (slot_index < _mtl.idpool.num_slots));
	return slot_index;
}

/*  add an MTLResource to the pool, return pool index or 0 if input was 'nil' */
uint32_t _sg_mtl_add_resource(id res) {
	if (nil == res) {
		return 0;
	}
	const uint32_t slot_index = _sg_mtl_alloc_pool_slot();
	RENDERKIT_ASSERT([NSNull null] == _mtl.idpool.pool[slot_index]);
	_mtl.idpool.pool[slot_index] = res;
	return slot_index;
}

// setup
void metal_setup(RendererDesc_t desc) {
	_SG_CLEAR(_mtl_backend_t, _mtl);
	_sg_mtl_init_pool(desc);
	
    render_semaphore = dispatch_semaphore_create(NUM_INFLIGHT_FRAMES);
    layer = (__bridge CAMetalLayer*)desc.metal.ca_layer;
    layer.device = MTLCreateSystemDefaultDevice();
    layer.pixelFormat = MTLPixelFormatBGRA8Unorm;

    cmd_queue = [layer.device newCommandQueue];
}

void metal_shutdown() {
    printf("----- shutdown\n");

    // wait for the last frame to finish
    for (int i = 0; i < NUM_INFLIGHT_FRAMES; i++)
        dispatch_semaphore_wait(render_semaphore, DISPATCH_TIME_FOREVER);

    // semaphore must be "relinquished" before destruction
    for (int i = 0; i < NUM_INFLIGHT_FRAMES; i++)
        dispatch_semaphore_signal(render_semaphore);

    cmd_buffer = nil;
    cmd_encoder = nil;
}

// render state
void metal_set_render_state(RenderState_t state) {
    printf("metal_set_render_state\n");
    assert(!in_pass);
    if (!pass_valid) return;
    assert(cmd_encoder != nil);

    [cmd_encoder setBlendColorRed:state.blend.color[0] green: state.blend.color[1] blue: state.blend.color[2] alpha: state.blend.color[3]];
    [cmd_encoder setStencilReferenceValue:state.stencil.ref];
    // [cmd_encoder setRenderPipelineState:_sg_mtl_id(pip->mtl.rps)];
    // [cmd_encoder setDepthStencilState:_sg_mtl_id(pip->mtl.dss)];
}

void metal_viewport(int x, int y, int w, int h) {
    printf("metal_viewport\n");
    assert(in_pass);
    if (!pass_valid) return;
    assert(cmd_encoder != nil);

    MTLViewport vp;
    vp.originX = (double) x;
    vp.originY = (double) (origin_top_left ? y : (cur_height - (y + h)));
    vp.width   = (double) w;
    vp.height  = (double) h;
    vp.znear   = 0.0;
    vp.zfar    = 1.0;
    [cmd_encoder setViewport:vp];
}

void metal_scissor(int x, int y, int w, int h) {
    printf("metal_scissor\n");
    assert(in_pass);
    if (!pass_valid) return;
    assert(cmd_encoder != nil);

    // clip against framebuffer rect
    x = min(max(0, x), cur_width - 1);
    y = min(max(0, y), cur_height - 1);
    if ((x + w) > cur_width) {
        w = cur_width - x;
    }
    if ((y + h) > cur_height) {
        h = cur_height - y;
    }
    w = max(w, 1);
    h = max(h, 1);

    MTLScissorRect r;
    r.x = x;
    r.y = origin_top_left ? y : (cur_height - (y + h));
    r.width = w;
    r.height = h;
    [cmd_encoder setScissorRect:r];
}


// images
/* initialize MTLTextureDescritor with rendertarget attributes */
void _mtl_init_texdesc_rt(MTLTextureDescriptor *mtl_desc) {
	/* reset the cpuCacheMode to 'default' */
	mtl_desc.cpuCacheMode = MTLCPUCacheModeDefaultCache;
	/* render targets are only visible to the GPU */
	mtl_desc.resourceOptions = MTLResourceStorageModePrivate;
	mtl_desc.storageMode = MTLStorageModePrivate;
	/* non-MSAA render targets are shader-readable */
	mtl_desc.usage = MTLTextureUsageShaderRead | MTLTextureUsageRenderTarget;
}

uint16_t metal_create_image(ImageDesc_t desc) {
    MTLTextureDescriptor* mtl_desc = [[MTLTextureDescriptor alloc] init];
    mtl_desc.textureType = MTLTextureType2D;
    mtl_desc.pixelFormat = MTLPixelFormatRGBA8Unorm;
    mtl_desc.width = desc.width;
    mtl_desc.height = desc.height;
    mtl_desc.depth = 1;
    // mtl_desc.mipmapLevelCount = img->cmn.num_mipmaps;
    mtl_desc.arrayLength = 1;
    mtl_desc.usage = MTLTextureUsageShaderRead;
    if (desc.usage != usage_immutable)
        mtl_desc.cpuCacheMode = MTLCPUCacheModeWriteCombined;
    mtl_desc.resourceOptions = MTLResourceStorageModeManaged;
    mtl_desc.storageMode = MTLStorageModeManaged;

    if (desc.render_target)
		_mtl_init_texdesc_rt(mtl_desc);

    // special case depth-stencil-buffer
    if (desc.pixel_format == pixel_format_depth_stencil || desc.pixel_format == pixel_format_stencil) {
        assert(desc.render_target);

        id<MTLTexture> tex = [layer.device newTextureWithDescriptor:mtl_desc];
		RENDERKIT_ASSERT(tex != nil);
//		img->mtl.depth_tex = _sg_mtl_add_resource(tex);
		RENDERKIT_UNREACHABLE;
    } else {
        id<MTLTexture> tex = [layer.device newTextureWithDescriptor:mtl_desc];
		if (desc.usage == usage_immutable && !desc.render_target) {
			MTLRegion region = MTLRegionMake2D(0, 0, desc.width, desc.height);
			[tex replaceRegion:region
				   mipmapLevel:0
						 slice:0
					 withBytes:desc.content
				   bytesPerRow:desc.width * 4
				 bytesPerImage:desc.height * desc.width * 4];
		}
		
        // create (possibly shared) sampler state
        // img->mtl.sampler_state = _sg_mtl_create_sampler(layer.device, desc);
    }
	
	return 0;
}

void metal_destroy_image(uint16_t img_index) {}

void metal_update_image(uint16_t img_index, void* arg1) {}

void metal_bind_image(uint16_t img_index, uint32_t arg1) {}


void metal_begin_pass(uint16_t pass_index, ClearCommand_t clear, int w, int h) {
    in_pass = true;
    cur_width = w;
    cur_height = h;

    // if this is the first pass in the frame, create a command buffer
    if (cmd_buffer == nil) {
        // block until the oldest frame in flight has finished
        dispatch_semaphore_wait(render_semaphore, DISPATCH_TIME_FOREVER);
        cmd_buffer = [cmd_queue commandBufferWithUnretainedReferences];
    }

    // initialize a render pass descriptor
    MTLRenderPassDescriptor *pass_desc = nil;
    if (pass_index > 0) { // offscreen render pass
        pass_desc = [MTLRenderPassDescriptor renderPassDescriptor];
    } else {
        pass_desc = [MTLRenderPassDescriptor renderPassDescriptor];
        // only do this once per frame. a pass to the framebuffer can be done multiple times in a frame.
        if (cur_drawable == nil)
            cur_drawable = [layer nextDrawable];
        pass_desc.colorAttachments[0].texture = cur_drawable.texture;
    }

    // default pass descriptor will not be valid if window is minimized
    if (pass_desc == nil) {
        pass_valid = false;
        return;
    }
    pass_valid = true;

    // setup pass descriptor for backbuffer or offscreen rendering
    if (pass_index > 0) {
    } else {
        pass_desc.colorAttachments[0].clearColor = MTLClearColorMake(clear.color[0], clear.color[1], clear.color[2], clear.color[3]);
        pass_desc.colorAttachments[0].loadAction  = _mtl_load_action(clear.color_action);
        pass_desc.depthAttachment.loadAction = _mtl_load_action(clear.depth_action);
        pass_desc.depthAttachment.clearDepth = clear.depth;
        pass_desc.stencilAttachment.loadAction = _mtl_load_action(clear.stencil_action);
        pass_desc.stencilAttachment.clearStencil = clear.stencil;
    }

    // create a render command encoder, this might return nil if window is minimized
    cmd_encoder = [cmd_buffer renderCommandEncoderWithDescriptor:pass_desc];
    if (cmd_encoder == nil) {
        pass_valid = false;
        return;
    }
}

void metal_end_pass() {
    in_pass = false;
    pass_valid = false;
    if (cmd_encoder != nil) {
        [cmd_encoder endEncoding];
        cmd_encoder = nil;
    }
}

void metal_commit_frame() {
    assert(!pass_valid);
    assert(cmd_encoder == nil);
    assert(cmd_buffer != nil);

    // present, commit and signal semaphore when done
    // id<CAMetalDrawable> drawable = [layer nextDrawable];
    [cmd_buffer presentDrawable:cur_drawable];
    [cmd_buffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
        dispatch_semaphore_signal(render_semaphore);
    }];
    [cmd_buffer commit];
    cmd_buffer = nil;
    cur_drawable = nil;
}
