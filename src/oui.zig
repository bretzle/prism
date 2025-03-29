const std = @import("std");
const math = @import("math.zig");
const prism = @import("prism.zig");
const assert = std.debug.assert;

pub const Vec2 = math.Vec2;
pub const Rect = math.Rect;

// limits
const MAX_DATASIZE = 4096;
const MAX_DEPTH = 64;
const MAX_INPUT_EVENTS = 64;
const CLICK_THRESHOLD = 250;

pub const ItemState = enum { cold, hot, active, frozen };

// container flags to pass to uiSetBox()

// flex-direction (bit 0+1)

// left to right
const UI_ROW = 0x002;
// top to bottom
pub const UI_COLUMN: u32 = 0x003;

// model (bit 1)

// free layout
pub const UI_LAYOUT: u32 = 0x000;
// flex model
pub const UI_FLEX: u32 = 0x002;

// flex-wrap (bit 2)

// single-line
pub const UI_NOWRAP: u32 = 0x000;
// multi-line, wrap left to right
pub const UI_WRAP: u32 = 0x004;

// justify-content (start, end, center, space-between)
// at start of row/column
pub const UI_START: u32 = 0x008;
// // at center of row/column
pub const UI_MIDDLE: u32 = 0x000;
// at end of row/column
pub const UI_END: u32 = 0x010;
// insert spacing to stretch across whole row/column
pub const UI_JUSTIFY: u32 = 0x018;

// align-items
// can be implemented by putting a flex container in a layout container,
// then using TOP, DOWN, VFILL, VCENTER, etc.
// FILL is equivalent to stretch/grow

// align-content (start, end, center, stretch)
// can be implemented by putting a flex container in a layout container,
// then using TOP, DOWN, VFILL, VCENTER, etc.
// FILL is equivalent to stretch; space-between is not supported.

// child layout flags to pass to uiSetLayout()

// attachments (bit 5-8)
// fully valid when parent uses LAYOUT model
// partially valid when in FLEX model

// anchor to left item or left side of parent
pub const UI_LEFT: u32 = 0x020;
// anchor to top item or top side of parent
pub const UI_TOP: u32 = 0x040;
// anchor to right item or right side of parent
pub const UI_RIGHT: u32 = 0x080;
// anchor to bottom item or bottom side of parent
pub const UI_DOWN: u32 = 0x100;
// anchor to both left and right item or parent borders
pub const UI_HFILL: u32 = 0x0a0;
// anchor to both top and bottom item or parent borders
pub const UI_VFILL: u32 = 0x140;
// center horizontally, with left margin as offset
pub const UI_HCENTER: u32 = 0x000;
// center vertically, with top margin as offset
pub const UI_VCENTER: u32 = 0x000;
// center in both directions, with left/top margin as offset
pub const UI_CENTER: u32 = 0x000;
// anchor to all four directions
pub const UI_FILL: u32 = 0x1e0;
// when wrapping, put this element on a new line
// wrapping layout code auto-inserts BREAK flags,
// drawing routines can read them with uiGetLayout()
pub const UI_BREAK: u32 = 0x200;

// event flags

// on button 0 down
pub const UI_BUTTON0_DOWN: u32 = 0x0400;
// on button 0 up
// when this event has a handler, uiGetState() will return ACTIVE as
// long as button 0 is down.
pub const UI_BUTTON0_UP: u32 = 0x0800;
// on button 0 up while item is hovered
// when this event has a handler, uiGetState() will return ACTIVE
// when the cursor is hovering the items rectangle; this is the
// behavior expected for buttons.
pub const UI_BUTTON0_HOT_UP: u32 = 0x1000;
// item is being captured (button 0 constantly pressed);
// when this event has a handler, uiGetState() will return ACTIVE as
// long as button 0 is down.
pub const UI_BUTTON0_CAPTURE: u32 = 0x2000;
// on button 2 down (right mouse button, usually triggers context menu)
pub const UI_BUTTON2_DOWN: u32 = 0x4000;
// item has received a scrollwheel event
// the accumulated wheel offset can be queried with uiGetScroll()
pub const UI_SCROLL: u32 = 0x8000;
// item is focused and has received a key-down event
// the respective key can be queried using uiGetKey() and uiGetModifier()
pub const UI_KEY_DOWN: u32 = 0x10000;
// item is focused and has received a key-up event
// the respective key can be queried using uiGetKey() and uiGetModifier()
pub const UI_KEY_UP: u32 = 0x20000;
// item is focused and has received a character event
// the respective character can be queried using uiGetKey()
pub const UI_CHAR: u32 = 0x40000;

// these bits, starting at bit 24, can be safely assigned by the
// application, e.g. as item types, other event types, drop targets, etc.
// they can be set and queried using uiSetFlags() and uiGetFlags()
pub const UI_USERMASK: u32 = 0xFF000000;

// a special mask passed to uiFindItem()
pub const UI_ANY: u32 = 0xFFFFFFFF;

const UI_ANY_BUTTON0_INPUT: u32 = UI_BUTTON0_DOWN | UI_BUTTON0_UP | UI_BUTTON0_HOT_UP | UI_BUTTON0_CAPTURE;
const UI_ANY_BUTTON2_INPUT: u32 = UI_BUTTON2_DOWN;
const UI_ANY_MOUSE_INPUT: u32 = UI_ANY_BUTTON0_INPUT | UI_ANY_BUTTON2_INPUT;
const UI_ANY_KEY_INPUT: u32 = UI_KEY_DOWN | UI_KEY_UP | UI_CHAR;
const UI_ANY_INPUT: u32 = UI_ANY_MOUSE_INPUT | UI_ANY_KEY_INPUT;

// extra item flags

// bit 0-2
const UI_ITEM_BOX_MODEL_MASK: u32 = 0x000007;
// bit 0-4
const UI_ITEM_BOX_MASK: u32 = 0x00001F;
// bit 5-8
const UI_ITEM_LAYOUT_MASK: u32 = 0x0003E0;
// bit 9-18
const UI_ITEM_EVENT_MASK: u32 = 0x07FC00;
// item is frozen (bit 19)
const UI_ITEM_FROZEN: u32 = 0x080000;
// item handle is pointer to data (bit 20)
const UI_ITEM_DATA: u32 = 0x100000;
// item has been inserted (bit 21)
const UI_ITEM_INSERTED: u32 = 0x200000;
// horizontal size has been explicitly set (bit 22)
const UI_ITEM_HFIXED: u32 = 0x400000;
// vertical size has been explicitly set (bit 23)
const UI_ITEM_VFIXED: u32 = 0x800000;
// bit 22-23
const UI_ITEM_FIXED_MASK: u32 = 0xC00000;

// which flag bits will be compared
const UI_ITEM_COMPARE_MASK: u32 = UI_ITEM_BOX_MODEL_MASK | (UI_ITEM_LAYOUT_MASK & ~UI_BREAK) | UI_ITEM_EVENT_MASK | UI_USERMASK;

pub const Handler = ?*const fn (item: i32, event: u32) void;

var ctx: *Context = undefined;

pub const Context = struct {
    item_capacity: usize,
    buffer_capacity: usize,

    handler: Handler,

    buttons: u64,
    last_buttons: u64,

    start_cursor: Vec2,
    last_cursor: Vec2,
    cursor: Vec2,
    scroll: Vec2,

    active_item: i32,
    focus_item: i32,
    last_hot_item: i32,
    last_click_item: i32,
    hot_item: i32,

    state: State,
    stage: Stage,
    active_key: u32,
    active_modifier: u32,
    active_button_modifier: u32,
    last_timestamp: i32,
    last_click_timestamp: i32,
    clicks: u32,

    count: i32,
    last_count: i32,
    event_count: u32,
    datasize: u32,

    items: []Item,
    data: []u8,
    last_items: []Item,
    item_map: []i32,
    events: [MAX_INPUT_EVENTS]InputEvent,

    /// create a new UI context; call uiMakeCurrent() to make this context the
    /// current context. The context is managed by the client and must be released
    /// using uiDestroyContext()
    /// item_capacity is the maximum of number of items that can be declared.
    /// buffer_capacity is the maximum total size of bytes that can be allocated
    /// using uiAllocHandle(); you may pass 0 if you don't need to allocate
    /// handles.
    /// 4096 and (1<<20) are good starting values.
    pub fn create(item_capacity: usize, buffer_capacity: usize) !*Context {
        const allocator = prism.allocator;

        const self = try allocator.create(Context);
        @memset(std.mem.asBytes(self), 0);

        self.item_capacity = item_capacity;
        self.buffer_capacity = buffer_capacity;
        self.stage = .process;
        self.items = try allocator.alloc(Item, item_capacity);
        self.last_items = try allocator.alloc(Item, item_capacity);
        self.item_map = try allocator.alloc(i32, item_capacity);
        self.data = try allocator.alloc(u8, buffer_capacity);

        const old = ctx;
        self.makeCurrrent();
        clear();
        clearState();
        old.makeCurrrent();
        return self;
    }

    /// release the memory of an UI context created with uiCreateContext(); if the
    /// context is the current context, the current context will be set to NULL
    pub fn deinit(self: *Context) void {
        const allocator = prism.allocator;

        if (ctx == self) ctx = undefined;
        allocator.free(self.items);
        allocator.free(self.last_items);
        allocator.free(self.item_map);
        allocator.free(self.data);
        allocator.destroy(self);
    }

    /// select an UI context as the current context; a context must always be
    /// selected before using any of the other UI functions
    pub fn makeCurrrent(self: *Context) void {
        ctx = self;
    }

    /// returns the currently selected context or NULL
    pub fn getCurrent() ?*Context {
        return ctx;
    }
};

// Input Control
// -------------

/// sets the current cursor position (usually belonging to a mouse) to the
/// screen coordinates at (x,y)
pub fn setCursor(x: f32, y: f32) void {
    ctx.cursor = .{ .x = x, .y = y };
}

/// returns the current cursor position in screen coordinates as set by uiSetCursor()
pub fn getCursor() Vec2 {
    return ctx.cursor;
}

/// returns the offset of the cursor relative to the last call to uiProcess()
pub fn getCursorDelta() Vec2 {
    return ctx.cursor.sub(ctx.last_cursor);
}

/// returns the beginning point of a drag operation.
pub fn getCursorStart() Vec2 {
    return ctx.start_cursor;
}

/// returns the offset of the cursor relative to the beginning point of a drag operation.
pub fn getCursorStartDelta() Vec2 {
    return ctx.cursor.sub(ctx.start_cursor);
}

/// sets a mouse or gamepad button as pressed/released
/// button is in the range 0..63 and maps to an application defined input source.
/// mod is an application defined set of flags for modifier keys
/// enabled is 1 for pressed, 0 for released
pub fn setButton(button: u32, mod: u32, enabled: bool) void {
    const mask = @as(u64, 1) << @truncate(button);
    ctx.buttons = if (enabled)
        ctx.buttons | mask
    else
        ctx.buttons & ~mask;
    ctx.active_button_modifier = mod;
}

/// returns the current state of an application dependent input button
/// as set by uiSetButton().
/// the function returns 1 if the button has been set to pressed, 0 for released.
pub fn getButton(button: u32) bool {
    return ctx.buttons & (@as(u64, 1) << @truncate(button)) != 0;
}

/// returns the number of chained clicks; 1 is a single click, 2 is a double click, etc.
pub fn getClicks() u32 {
    return ctx.clicks;
}

/// sets a key as down/up; the key can be any application defined keycode
/// mod is an application defined set of flags for modifier keys
/// enabled is 1 for key down, 0 for key up
/// all key events are being buffered until the next call to uiProcess()
pub fn setKey(key: u32, mod: u32, enabled: bool) void {
    _ = key; // autofix
    _ = mod; // autofix
    _ = enabled; // autofix
    unreachable;
}

/// sends a single character for text input; the character is usually in the
/// unicode range, but can be application defined.
/// all char events are being buffered until the next call to uiProcess()
pub fn setChar(value: u32) void {
    const event = InputEvent{ .key = value, .mod = 0, .event = UI_CHAR };
    addInputEvent(event);
}

/// accumulates scroll wheel offsets for the current frame
/// all offsets are being accumulated until the next call to uiProcess()
pub fn setScroll(x: f32, y: f32) void {
    ctx.scroll.x += x;
    ctx.scroll.y += y;
}

/// returns the currently accumulated scroll wheel offsets for this frame
pub fn getScroll() Vec2 {
    return ctx.scroll;
}

// Stages
// ------

/// clear the item buffer; uiBeginLayout() should be called before the first
/// UI declaration for this frame to avoid concatenation of the same UI multiple
/// times.
/// After the call, all previously declared item IDs are invalid, and all
/// application dependent context data has been freed.
/// uiBeginLayout() must be followed by uiEndLayout().
pub fn beginLayout() void {
    assert(ctx.stage == .process);
    clear();
    ctx.stage = .layout;
}

/// layout all added items starting from the root item 0.
/// after calling uiEndLayout(), no further modifications to the item tree should
/// be done until the next call to uiBeginLayout().
/// It is safe to immediately draw the items after a call to uiEndLayout().
/// this is an O(N) operation for N = number of declared items.
pub fn endLayout() void {
    assert(ctx.stage == .layout);

    if (ctx.count != 0) {
        computeSize(0, 0);
        arrange(0, 0);
        computeSize(0, 1);
        arrange(0, 1);

        if (ctx.last_count != 0) {
            // map old item id to new item id
            _ = mapItems(0, 0);
        }
    }

    validateStateItems();

    if (ctx.count != 0) {
        // drawing routines may require this to be set already
        updateHotItem();
    }

    ctx.stage = .post_layout;
}

/// update the current hot item; this only needs to be called if items are kept
/// for more than one frame and uiEndLayout() is not called
pub fn updateHotItem() void {
    if (ctx.count == 0) return;
    ctx.hot_item = uiFindItem(0, ctx.cursor.x, ctx.cursor.y, UI_ANY_MOUSE_INPUT, UI_ANY);
}

/// update the internal state according to the current cursor position and
/// button states, and call all registered handlers.
/// timestamp is the time in milliseconds relative to the last call to uiProcess()
/// and is used to estimate the threshold for double-clicks
/// after calling uiProcess(), no further modifications to the item tree should
/// be done until the next call to uiBeginLayout().
/// Items should be drawn before a call to uiProcess()
/// this is an O(N) operation for N = number of declared items.
pub fn process(timestamp: i32) void {
    assert(ctx.stage != .layout);

    if (ctx.stage == .process) {
        updateHotItem();
    }

    ctx.stage = .process;

    if (ctx.count == 0) {
        clearInputEvents();
        return;
    }

    var hot_item = ctx.last_hot_item;
    var active_item = ctx.active_item;
    var focus_item = ctx.focus_item;

    // send all keyboard events
    if (focus_item >= 0) {
        unreachable;
    } else {
        ctx.focus_item = -1;
    }

    if (ctx.scroll.x != 0 or ctx.scroll.y != 0) {
        unreachable;
    }

    clearInputEvents();

    var hot = ctx.hot_item;

    switch (ctx.state) {
        .idle => {
            ctx.start_cursor = ctx.cursor;
            if (getButton(0)) {
                hot_item = -1;
                active_item = hot;

                if (active_item != focus_item) {
                    focus_item = -1;
                    ctx.focus_item = -1;
                }

                if (active_item >= 0) {
                    if (((timestamp - ctx.last_click_timestamp) > CLICK_THRESHOLD) or (ctx.last_click_item != active_item)) {
                        ctx.clicks = 0;
                    }
                    ctx.clicks += 1;

                    ctx.last_click_timestamp = timestamp;
                    ctx.last_click_item = active_item;
                    ctx.active_modifier = ctx.active_button_modifier;
                    notifyItem(active_item, UI_BUTTON0_DOWN);
                }
                ctx.state = .capture;
            } else if (getButton(2) and !getLastButton(2)) {
                hot_item = -1;
                hot = uiFindItem(0, ctx.cursor.x, ctx.cursor.y, UI_BUTTON2_DOWN, UI_ANY);
                if (hot >= 0) {
                    ctx.active_modifier = ctx.active_button_modifier;
                    notifyItem(hot, UI_BUTTON2_DOWN);
                }
            } else {
                hot_item = hot;
            }
        },
        .capture => {
            if (!getButton(0)) {
                if (active_item >= 0) {
                    ctx.active_modifier = ctx.active_button_modifier;
                    notifyItem(active_item, UI_BUTTON0_UP);
                    if (active_item == hot) {
                        notifyItem(active_item, UI_BUTTON0_HOT_UP);
                    }
                }
                active_item = -1;
                ctx.state = .idle;
            } else {
                if (active_item >= 0) {
                    ctx.active_modifier = ctx.active_button_modifier;
                    notifyItem(active_item, UI_BUTTON0_CAPTURE);
                }

                hot_item = if (hot == active_item) hot else -1;
            }
        },
    }

    ctx.last_cursor = ctx.cursor;
    ctx.last_hot_item = hot_item;
    ctx.active_item = active_item;

    ctx.last_timestamp = timestamp;
    ctx.last_buttons = ctx.buttons;
}

/// reset the currently stored hot/active etc. handles; this should be called when
/// a re-declaration of the UI changes the item indices, to avoid state
/// related glitches because item identities have changed.
pub fn clearState() void {
    ctx.last_hot_item = -1;
    ctx.active_item = -1;
    ctx.focus_item = -1;
    ctx.last_click_item = -1;
}

// UI Declaration
// --------------

/// create a new UI item and return the new items ID.
pub fn createItem() i32 {
    assert(ctx.stage == .layout);
    assert(ctx.count < ctx.item_capacity);

    const idx = ctx.count;
    ctx.count += 1;

    const item = itemPtr(idx);
    item.* = .{
        .firstkid = -1,
        .nextitem = -1,
    };
    return @bitCast(idx);
}

/// set an items state to frozen; the UI will not recurse into frozen items
/// when searching for hot or active items; subsequently, frozen items and
/// their child items will not cause mouse event notifications.
/// The frozen state is not applied recursively; uiGetState() will report
/// UI_COLD for child items. Upon encountering a frozen item, the drawing
/// routine needs to handle rendering of child items appropriately.
/// see example.cpp for a demonstration.
pub fn setFrozen(item: i32, enable: bool) void {
    const pitem = itemPtr(item);
    if (enable) pitem.flags |= UI_ITEM_FROZEN else pitem.flags &= ~UI_ITEM_FROZEN;
}

/// set the application-dependent handle of an item.
/// handle is an application defined 64-bit handle. If handle is NULL, the item
/// will not be interactive.
pub fn setHandle(item: i32, handle: *anyopaque) void {
    const pitem = itemPtr(item);
    assert(pitem.handle == null);
    pitem.handle = handle;
}

/// allocate space for application-dependent context data and assign it
/// as the handle to the item.
/// The memory of the pointer is managed by the UI context and released
/// upon the next call to uiBeginLayout()
pub fn allocHandle(item: i32, size: u32) ?*anyopaque {
    assert(size < MAX_DATASIZE);
    const pitem = itemPtr(item);
    assert(pitem.handle == null);
    assert(ctx.datasize + size <= ctx.buffer_capacity);
    pitem.handle = @ptrCast(ctx.data.ptr + ctx.datasize);
    pitem.flags |= UI_ITEM_DATA;
    ctx.datasize += size;
    return pitem.handle;
}

/// set the global handler callback for interactive items.
/// the handler will be called for each item whose event flags are set using
/// uiSetEvents.
pub fn setHandler(handler: Handler) void {
    ctx.handler = handler;
}

/// flags is a combination of UI_EVENT_* and designates for which events the
/// handler should be called.
pub fn setEvents(item: i32, flags: u32) void {
    const pitem = itemPtr(item);
    pitem.flags &= ~UI_ITEM_EVENT_MASK;
    pitem.flags |= flags & UI_ITEM_EVENT_MASK;
}

/// flags is a user-defined set of flags defined by UI_USERMASK.
pub fn setFlags(item: i32, flags: u32) void {
    const pitem = itemPtr(item);
    pitem.flags &= ~UI_USERMASK;
    pitem.flags |= flags & UI_USERMASK;
}

/// assign an item to a container.
/// an item ID of 0 refers to the root item.
/// the function returns the child item ID
/// if the container has already added items, the function searches
/// for the last item and calls uiAppend() on it, which is an
/// O(N) operation for N siblings.
/// it is usually more efficient to call uiInsert() for the first child,
/// then chain additional siblings using uiAppend().
pub fn insert(item: i32, child: i32) i32 {
    assert(child > 0);
    const pparent = itemPtr(item);
    const pchild = itemPtr(child);
    assert(pchild.flags & UI_ITEM_INSERTED == 0);
    if (pparent.firstkid < 0) {
        pparent.firstkid = child;
        pchild.flags |= UI_ITEM_INSERTED;
    } else {
        _ = append(lastChild(item), child);
    }
    return child;
}

/// assign an item to the same container as another item
/// sibling is inserted after item.
pub fn append(item: i32, sibling: i32) i32 {
    assert(sibling > 0);
    const pitem = itemPtr(item);
    const psibling = itemPtr(sibling);
    assert(psibling.flags & UI_ITEM_INSERTED == 0);
    psibling.nextitem = pitem.nextitem;
    psibling.flags |= UI_ITEM_INSERTED;
    pitem.nextitem = sibling;
    return sibling;
}

/// insert child into container item like uiInsert(), but prepend
/// it to the first child item, effectively putting it in
/// the background.
/// it is efficient to call uiInsertBack() repeatedly
/// in cases where drawing or layout order doesn't matter.
pub fn insertBack(item: i32, child: i32) i32 {
    assert(child > 0);
    const pparent = itemPtr(item);
    const pchild = itemPtr(child);
    assert(pchild.flags & UI_ITEM_INSERTED == 0);
    pchild.nextitem = pparent.firstkid;
    pparent.firstkid = child;
    pchild.flags |= UI_ITEM_INSERTED;
    return child;
}

/// same as uiInsert()
pub const insertFront = insert;

/// set the size of the item; a size of 0 indicates the dimension to be
/// dynamic; if the size is set, the item can not expand beyond that size.
pub fn setSize(item: i32, w: f32, h: f32) void {
    const pitem = itemPtr(item);
    pitem.size = .{ w, h };
    if (w == 0) pitem.flags &= ~UI_ITEM_HFIXED else pitem.flags |= UI_ITEM_HFIXED;
    if (h == 0) pitem.flags &= ~UI_ITEM_VFIXED else pitem.flags |= UI_ITEM_VFIXED;
}

/// set the anchoring behavior of the item to one or multiple UIlayoutFlags
pub fn setLayout(item: i32, flags: u32) void {
    const pitem = itemPtr(item);
    assert(flags & UI_ITEM_LAYOUT_MASK == flags);
    pitem.flags &= ~UI_ITEM_LAYOUT_MASK;
    pitem.flags |= flags & UI_ITEM_LAYOUT_MASK;
}

/// set the box model behavior of the item to one or multiple UIboxFlags
pub fn setBox(item: i32, flags: u32) void {
    const pitem = itemPtr(item);
    assert(flags & UI_ITEM_BOX_MASK == flags);
    pitem.flags &= ~UI_ITEM_BOX_MASK;
    pitem.flags |= flags & UI_ITEM_BOX_MASK;
}

/// set the left, top, right and bottom margins of an item; when the item is
/// anchored to the parent or another item, the margin controls the distance
/// from the neighboring element.
pub fn setMargins(item: i32, l: f32, t: f32, r: f32, b: f32) void {
    const pitem = itemPtr(item);
    pitem.margins = .{ l, t, r, b };
}

/// set item as recipient of all keyboard events; if item is -1, no item will
/// be focused.
pub fn focus(item: i32) void {
    assert(item >= -1 and item < ctx.count);
    assert(ctx.stage != .layout);
    ctx.focus_item = item;
}

// Iteration
// ---------

/// returns the first child item of a container item. If the item is not
/// a container or does not contain any items, -1 is returned.
/// if item is 0, the first child item of the root item will be returned.
pub fn firstChild(item: i32) i32 {
    return itemPtr(item).firstkid;
}

/// returns an items next sibling in the list of the parent containers children.
/// if item is 0 or the item is the last child item, -1 will be returned.
pub fn nextSibling(item: i32) i32 {
    return itemPtr(item).nextitem;
}

// Querying
// --------

/// return the total number of allocated items
pub fn getItemCount() i32 {
    return ctx.count;
}

/// return the total bytes that have been allocated by uiAllocHandle()
pub fn getAllocSize() u32 {
    return ctx.datasize;
}

/// return the current state of the item. This state is only valid after
/// a call to uiProcess().
/// The returned value is one of UI_COLD, UI_HOT, UI_ACTIVE, UI_FROZEN.
pub fn getState(item: i32) ItemState {
    _ = item; // autofix
    unreachable;
}

/// return the application-dependent handle of the item as passed to uiSetHandle()
/// or uiAllocHandle().
pub fn getHandle(item: i32) ?*anyopaque {
    return itemPtr(item).handle;
}

/// return the item that is currently under the cursor or -1 for none
pub fn getHotItem() i32 {
    return ctx.hot_item;
}

/// return the item that is currently focused or -1 for none
pub fn getFocusedItem() i32 {
    return ctx.focus_item;
}

/// returns the topmost item containing absolute location (x,y), starting with
/// item as parent, using a set of flags and masks as filter:
/// if both flags and mask are UI_ANY, the first topmost item is returned.
/// if mask is UI_ANY, the first topmost item matching *any* of flags is returned.
/// otherwise the first item matching (item.flags & flags) == mask is returned.
/// you may combine box, layout, event and user flags.
/// frozen items will always be ignored.
pub fn uiFindItem(item: i32, x: f32, y: f32, flags: u32, mask: u32) i32 {
    const pitem = itemPtr(item);
    if (pitem.flags & UI_ITEM_FROZEN != 0) return -1;
    if (contains(item, x, y)) {
        var best_hit: i32 = -1;
        var kid = firstChild(item);
        while (kid >= 0) : (kid = nextSibling(kid)) {
            const hit = uiFindItem(kid, x, y, flags, mask);
            if (hit >= 0) {
                best_hit = hit;
            }
        }
        if (best_hit >= 0) return best_hit;
        if ((mask == UI_ANY and (flags == UI_ANY or pitem.flags & flags != 0)) or (pitem.flags & flags == mask)) {
            return item;
        }
    }
    return -1;
}

/// return the handler callback as passed to uiSetHandler()
pub fn getHandler() Handler {
    return ctx.handler;
}
/// return the event flags for an item as passed to uiSetEvents()
pub fn getEvents(item: i32) u32 {
    return itemPtr(item).flags & UI_ITEM_EVENT_MASK;
}
/// return the user-defined flags for an item as passed to uiSetFlags()
pub fn getFlags(item: i32) u32 {
    return itemPtr(item).flags & UI_USERMASK;
}

/// when handling a KEY_DOWN/KEY_UP event: the key that triggered this event
pub fn getKey() u32 {
    return ctx.active_key;
}
/// when handling a keyboard or mouse event: the active modifier keys
pub fn getModifier() u32 {
    return ctx.active_modifier;
}

/// returns the items layout rectangle in absolute coordinates. If
/// uiGetRect() is called before uiEndLayout(), the values of the returned
/// rectangle are undefined.
pub fn getRect(item: i32) Rect {
    const pitem = itemPtr(item);
    return .{
        .x = pitem.margins[0],
        .y = pitem.margins[1],
        .w = pitem.size[0],
        .h = pitem.size[1],
    };
}

/// returns 1 if an items absolute rectangle contains a given coordinate
/// otherwise 0
pub fn contains(item: i32, x: f32, y: f32) bool {
    const rect = getRect(item);
    const xx = x - rect.x;
    const yy = y - rect.y;
    return xx >= 0 and yy >= 0 and xx < rect.w and yy < rect.h;
}

/// return the width of the item as set by uiSetSize()
pub fn getWidth(item: i32) f32 {
    return itemPtr(item).size[0];
}
/// return the height of the item as set by uiSetSize()
pub fn getHeight(item: i32) f32 {
    return itemPtr(item).size[1];
}

/// return the anchoring behavior as set by uiSetLayout()
pub fn getLayout(item: i32) u32 {
    return itemPtr(item).flags & UI_ITEM_LAYOUT_MASK;
}
/// return the box model as set by uiSetBox()
pub fn getBox(item: i32) u32 {
    return itemPtr(item).flags & UI_ITEM_BOX_MASK;
}

/// return the left margin of the item as set with uiSetMargins()
pub fn getMarginLeft(item: i32) f32 {
    return itemPtr(item).margins[0];
}
/// return the top margin of the item as set with uiSetMargins()
pub fn getMarginTop(item: i32) f32 {
    return itemPtr(item).margins[1];
}
/// return the right margin of the item as set with uiSetMargins()
pub fn getMarginRight(item: i32) f32 {
    return itemPtr(item).margins[2];
}
/// return the bottom margin of the item as set with uiSetMargins()
pub fn getMarginDown(item: i32) f32 {
    return itemPtr(item).margins[3];
}

/// when uiBeginLayout() is called, the most recently declared items are retained.
/// when uiEndLayout() completes, it matches the old item hierarchy to the new one
/// and attempts to map old items to new items as well as possible.
/// when passed an item Id from the previous frame, uiRecoverItem() returns the
/// items new assumed Id, or -1 if the item could not be mapped.
/// it is valid to pass -1 as item.
pub fn recoverItem(olditem: i32) i32 {
    assert(olditem >= -1 and olditem < ctx.last_count);
    if (olditem == -1) return -1;
    return ctx.item_map[@intCast(olditem)];
}

/// in cases where it is important to recover old state over changes in
/// the view, and the built-in remapping fails, the UI declaration can manually
/// remap old items to new IDs in cases where e.g. the previous item ID has been
/// temporarily saved; uiRemapItem() would then be called after creating the
/// new item using uiItem().
pub fn remapItem(olditem: i32, newitem: i32) void {
    _ = olditem; // autofix
    _ = newitem; // autofix
    unreachable;
}

/// returns the number if items that have been allocated in the last frame
pub fn getLastItemCount() i32 {
    unreachable;
}

// Implementation Helpers
// ----------------------

const Item = struct {
    /// data handle
    handle: ?*anyopaque = null,
    /// abouot 27 bits worth of flags
    flags: u32 = 0,
    /// index of first kid; if old item: index of equivalent new item
    firstkid: i32,
    /// index of next sibling with same parent
    nextitem: i32,

    margins: [4]f32 = .{ 0, 0, 0, 0 },
    size: [2]f32 = .{ 0, 0 },
};

const State = enum { idle, capture };

const Stage = enum { layout, post_layout, process };

const HandleEntry = struct {
    key: u32,
    item: i32,
};

const InputEvent = struct {
    key: u32,
    mod: u32,
    event: u32,
};

fn clear() void {
    ctx.last_count = ctx.count;
    ctx.count = 0;
    ctx.datasize = 0;
    ctx.hot_item = -1;

    // swap buffers
    std.mem.swap([]Item, &ctx.items, &ctx.last_items);
    @memset(ctx.item_map[0..@as(u32, @intCast(ctx.last_count))], -1);
}

fn itemPtr(item: i32) *Item {
    assert(item >= 0 and item < ctx.count);
    return &ctx.items[@intCast(item)];
}

fn lastItemPtr(item: i32) *Item {
    assert(item >= 0 and item < ctx.last_count);
    return &ctx.last_items[@intCast(item)];
}

inline fn compareItems(item1: *const Item, item2: *const Item) bool {
    return (item1.flags & UI_ITEM_COMPARE_MASK) == (item2.flags & UI_ITEM_COMPARE_MASK);
}

fn validateStateItems() void {
    ctx.last_hot_item = recoverItem(ctx.last_hot_item);
    ctx.active_item = recoverItem(ctx.active_item);
    ctx.focus_item = recoverItem(ctx.focus_item);
    ctx.last_click_item = recoverItem(ctx.last_click_item);
}

fn clearInputEvents() void {
    ctx.event_count = 0;
    ctx.scroll = .zero;
}

fn computeSize(item: i32, dim: u32) void {
    const pitem = itemPtr(item);

    var kid = pitem.firstkid;
    while (kid >= 0) : (kid = nextSibling(kid)) {
        computeSize(kid, dim);
    }

    if (pitem.size[dim] != 0) return;

    switch (pitem.flags & UI_ITEM_BOX_MODEL_MASK) {
        UI_COLUMN | UI_WRAP => unreachable,
        UI_ROW | UI_WRAP => unreachable,
        UI_COLUMN, UI_ROW => { // flex model
            if (pitem.flags & 1 == dim)
                computeStackedSize(pitem, dim)
            else
                computeImposedSize(pitem, dim);
        },
        else => computeImposedSize(pitem, dim), // layout model
    }
}

// compute bounding box of all items super-imposed
inline fn computeImposedSize(pitem: *Item, dim: u32) void {
    const wdim = dim + 2;

    var need_size: f32 = 0;
    var kid = pitem.firstkid;
    while (kid >= 0) : (kid = nextSibling(kid)) {
        const pkid = itemPtr(kid);

        // width = start margin + calculated width + end margin
        const kidsize = pkid.margins[dim] + pkid.size[dim] + pkid.margins[wdim];
        need_size = @max(need_size, kidsize);
    }

    pitem.size[dim] = need_size;
}

// compute bounding box of all items stacked
inline fn computeStackedSize(pitem: *Item, dim: u32) void {
    const wdim = dim + 2;

    var need_size: f32 = 0;
    var kid = pitem.firstkid;
    while (kid >= 0) : (kid = nextSibling(kid)) {
        const pkid = itemPtr(kid);

        // width += start margin + calculated width + end margin
        need_size += pkid.margins[dim] + pkid.size[dim] + pkid.margins[wdim];
    }

    pitem.size[dim] = need_size;
}

fn arrange(item: i32, dim: u32) void {
    const pitem = itemPtr(item);

    switch (pitem.flags & UI_ITEM_BOX_MODEL_MASK) {
        UI_COLUMN | UI_WRAP => unreachable,
        UI_ROW | UI_WRAP => unreachable,
        UI_COLUMN, UI_ROW => { // flex model
            if (pitem.flags & 1 == dim)
                arrangeStacked(pitem, dim, false)
            else
                arrangeImposedSqueezed(pitem, dim);
        },
        else => arrangeImposed(pitem, dim), // layout model
    }

    var kid = firstChild(item);
    while (kid >= 0) : (kid = nextSibling(kid)) {
        arrange(kid, dim);
    }
}

inline fn arrangeImposed(pitem: *Item, dim: u32) void {
    arrangeImposedRange(pitem, dim, pitem.firstkid, -1, pitem.margins[dim], pitem.size[dim]);
}

// superimpose all items according to their alignment
inline fn arrangeImposedRange(pitem: *Item, dim: u32, start_kid: i32, end_kid: i32, offset: f32, space: f32) void {
    _ = pitem;
    const wdim = dim + 2;

    var kid = start_kid;
    while (kid != end_kid) : (kid = nextSibling(kid)) {
        const pkid = itemPtr(kid);

        const flags = (pkid.flags & UI_ITEM_LAYOUT_MASK) >> @truncate(dim);
        switch (flags & UI_HFILL) {
            UI_HCENTER => pkid.margins[dim] += (space - pkid.size[dim]) / 2 - pkid.margins[wdim],
            UI_RIGHT => pkid.margins[dim] = space - pkid.size[dim] - pkid.margins[wdim],
            UI_HFILL => pkid.size[dim] = @max(0, space - pkid.margins[dim] - pkid.margins[wdim]),
            else => {},
        }

        pkid.margins[dim] += offset;
    }
}

inline fn arrangeImposedSqueezed(pitem: *Item, dim: u32) void {
    arrangeImposedSqueezedRange(pitem, dim, pitem.firstkid, -1, pitem.margins[dim], pitem.size[dim]);
}

// superimpose all items according to their alignment,
// squeeze items that expand the available space
inline fn arrangeImposedSqueezedRange(pitem: *Item, dim: u32, start_kid: i32, end_kid: i32, offset: f32, space: f32) void {
    _ = pitem;
    const wdim = dim + 2;

    var kid = start_kid;
    while (kid != end_kid) {
        const pkid = itemPtr(kid);

        const flags = (pkid.flags & UI_ITEM_LAYOUT_MASK) >> @truncate(dim);

        const min_size = @max(0, space - pkid.margins[dim] - pkid.margins[wdim]);
        switch (flags & UI_HFILL) {
            UI_HCENTER => {
                pkid.size[dim] = @min(pkid.size[dim], min_size);
                pkid.margins[dim] += (space - pkid.size[dim]) / 2 - pkid.margins[wdim];
            },
            UI_RIGHT => {
                pkid.size[dim] = @min(pkid.size[dim], min_size);
                pkid.margins[dim] = space - pkid.size[dim] - pkid.margins[wdim];
            },
            UI_HFILL => pkid.size[dim] = min_size,
            else => pkid.size[dim] = @min(pkid.size[dim], min_size),
        }
        pkid.margins[dim] += offset;

        kid = nextSibling(kid);
    }
}

// stack all items according to their alignment
inline fn arrangeStacked(pitem: *Item, dim: u32, wrap: bool) void {
    const wdim = dim + 2;

    const space = pitem.size[dim];
    const max_x2 = pitem.margins[dim] + space;

    var start_kid = pitem.firstkid;
    while (start_kid >= 0) {
        var used: f32 = 0;

        var count: f32 = 0; // count of fillers
        var squeezed_count: f32 = 0; // count of squeezable elements
        var total: f32 = 0;
        var hardbreak = false;
        // first pass: count items that need to be expanded,
        // and the space that is used
        var kid = start_kid;
        var end_kid: i32 = -1;
        while (kid >= 0) {
            const pkid = itemPtr(kid);
            const flags = (pkid.flags & UI_ITEM_LAYOUT_MASK) >> @truncate(dim);
            const fflags = (pkid.flags & UI_ITEM_FIXED_MASK) >> @truncate(dim);
            var extend = used;
            if (flags & UI_HFILL == UI_HFILL) { // grow
                count += 1;
                extend += pkid.margins[dim] + pkid.margins[wdim];
            } else {
                if (fflags & UI_ITEM_HFIXED != UI_ITEM_HFIXED)
                    squeezed_count += 1;
                extend += pkid.margins[dim] + pkid.size[dim] + pkid.margins[wdim];
            }
            // wrap on end of line or manual flag
            if (wrap and (total and (extend > space or pkid.flags & UI_BREAK != 0))) {
                end_kid = kid;
                hardbreak = ((pkid.flags & UI_BREAK) == UI_BREAK);
                // add marker for subsequent queries
                pkid.flags |= UI_BREAK;
                break;
            } else {
                used = extend;
                kid = nextSibling(kid);
            }
            total += 1;
        }

        const extra_space: f32 = space - used;
        var filler: f32 = 0;
        var spacer: f32 = 0;
        var extra_margin: f32 = 0;
        var eater: f32 = 0;

        if (extra_space > 0) {
            if (count != 0) {
                filler = extra_space / count;
            } else if (total != 0) {
                switch (pitem.flags & UI_JUSTIFY) {
                    UI_JUSTIFY => {
                        // justify when not wrapping or not in last line,
                        // or not manually breaking
                        if (!wrap or ((end_kid != -1) and !hardbreak))
                            spacer = extra_space / (total - 1);
                    },
                    UI_START => {},

                    UI_END => extra_margin = extra_space,
                    else => extra_margin = extra_space / 2.0,
                }
            }
        } else if (!wrap and (extra_space < 0)) {
            eater = extra_space / squeezed_count;
        }

        // distribute width among items
        var x = pitem.margins[dim];
        var x1: f32 = undefined;

        // second pass: distribute and rescale
        kid = start_kid;
        while (kid != end_kid) {
            var ix0: f32 = undefined;
            var ix1: f32 = undefined;

            const pkid = itemPtr(kid);
            const flags = (pkid.flags & UI_ITEM_LAYOUT_MASK) >> @truncate(dim);
            const fflags = (pkid.flags & UI_ITEM_FIXED_MASK) >> @truncate(dim);

            x += pkid.margins[dim] + extra_margin;
            if ((flags & UI_HFILL) == UI_HFILL) { // grow
                x1 = x + filler;
            } else if ((fflags & UI_ITEM_HFIXED) == UI_ITEM_HFIXED) {
                x1 = x + pkid.size[dim];
            } else {
                // squeeze
                x1 = x + @max(0.0, pkid.size[dim] + eater);
            }
            ix0 = x;
            ix1 = if (wrap)
                @min(max_x2 - pkid.margins[wdim], x1)
            else
                x1;
            pkid.margins[dim] = ix0;
            pkid.size[dim] = ix1 - ix0;
            x = x1 + pkid.margins[wdim];

            kid = nextSibling(kid);
            extra_margin = spacer;
        }

        start_kid = end_kid;
    }
}

fn mapItems(item1: i32, item2: i32) bool {
    const pitem1 = lastItemPtr(item1);
    if (item2 == -1) return false;

    const pitem2 = itemPtr(item2);
    if (!compareItems(pitem1, pitem2)) return false;

    var count: u32 = 0;
    var failed: u32 = 0;
    var kid1 = pitem1.firstkid;
    var kid2 = pitem2.firstkid;

    while (kid1 != -1) {
        const pkid1 = lastItemPtr(kid1);
        count += 1;

        if (!mapItems(kid1, kid2)) {
            failed = count;
            break;
        }

        kid1 = pkid1.nextitem;
        if (kid2 != -1) {
            kid2 = itemPtr(kid2).nextitem;
        }
    }

    if (count != 0 and failed == 1) return false;

    ctx.item_map[@intCast(item1)] = item2;
    return true;
}

fn addInputEvent(event: InputEvent) void {
    if (ctx.event_count == MAX_INPUT_EVENTS) return;
    ctx.events[ctx.event_count] = event;
    ctx.event_count += 1;
}

fn lastChild(item: i32) i32 {
    var iter = firstChild(item);
    if (iter < 0) return -1;

    while (true) {
        const nextitem = nextSibling(iter);
        if (nextitem < 0) return iter;
        iter = nextitem;
    }
}

fn notifyItem(item: i32, event: u32) void {
    if (ctx.handler) |handler| {
        assert(event & UI_ITEM_EVENT_MASK == event);
        const pitem = itemPtr(item);
        if (pitem.flags & event != 0) {
            (handler)(item, event);
        }
    }
}

fn getLastButton(button: u32) bool {
    _ = button; // autofix
    unreachable;
}

fn buttonPressed(button: u32) bool {
    return !getLastButton(button) and getButton(button);
}

fn buttonReleased(button: u32) bool {
    return getLastButton(button) and !getButton(button);
}

test "simple" {
    const tests = struct {
        var check = false;

        const Header = struct {
            type: u32,
            handler: Handler,
        };

        const CheckBox = struct {
            head: Header,
            label: []const u8,
            checked: *bool,

            fn handler(item: i32, event: u32) void {
                const data: *CheckBox = @alignCast(@ptrCast(getHandle(item)));

                switch (event) {
                    UI_BUTTON0_DOWN => data.checked.* = !data.checked.*,
                    else => {},
                }
            }
        };

        fn checkbox(label: []const u8, checked: *bool) i32 {
            const item = createItem();
            setSize(item, 50, 50);

            const data: *CheckBox = @alignCast(@ptrCast(allocHandle(item, @sizeOf(CheckBox))));
            data.* = .{
                .head = .{ .type = 1, .handler = CheckBox.handler },
                .label = label,
                .checked = checked,
            };

            setEvents(item, UI_BUTTON0_DOWN);

            return item;
        }

        fn handler(item: i32, event: u32) void {
            const data: ?*Header = @alignCast(@ptrCast(getHandle(item)));
            if (data) |head| {
                if (head.handler) |cb| {
                    (cb)(item, event);
                }
            }
        }

        fn window(w: f32, h: f32) void {
            // create root item; the first item always has index 0
            var parent = createItem();
            // assign fixed size
            setSize(parent, w, h);

            // create column box and use as new parent
            parent = insert(parent, createItem());
            // configure as column
            setBox(parent, UI_COLUMN);
            // span horizontally, attach to top
            setLayout(parent, UI_HFILL | UI_TOP);

            // // add a label - we're assuming custom control functions to exist
            // var item = insert(parent, label("Hello World"));
            // // set a fixed height for the label
            // setSize(item, 0, 50);
            // // span the label horizontally
            // setLayout(item, UI_HFILL);

            // add a checkbox to the same parent as item; this is faster than
            // calling uiInsert on the same parent repeatedly.
            const item = checkbox("Checked:", &check);
            // set a fixed height for the checkbox
            setSize(item, 0, 50);
            // span the checkbox in the same way as the label
            setLayout(item, UI_HFILL);
        }
    };

    const ui = try Context.create(4096, 1 << 20);
    defer ui.deinit();

    ui.makeCurrrent();
    setHandler(tests.handler);

    for (0..10) |frame| {
        // update input state
        setCursor(1, 1);
        setButton(0, 0, true);

        beginLayout();
        // _ = tests.checkbox("hello", &checked);
        tests.window(100, 100);
        endLayout();

        // draw ui

        process(@intCast(frame));
    }
}
