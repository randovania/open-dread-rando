// prologue
stp     x29, x30, [sp, -128]!
mov     x29, sp
str     x19, [sp, 16]

// put lua_State in x19
mov     x19, x0

// first getNpadState - wired?
mov     w0, 32
add     x1, sp, 40
str     wzr, [sp, 40]
str     w0, [sp, 44]
add     x0, sp, 48
bl      {getNpadState1}
// second getNpadState - wireless?
add     x1, sp, 44
add     x0, sp, 88
bl      {getNpadState2}

// put the bitwise OR of the two getNpadState bitfields in x1 (arg 2)
ldr     x1, [sp, 56]
ldr     x0, [sp, 96]
orr     x1, x1, x0

// put lua_State in x0 (arg 1) and call lua_pushinteger
mov     x0, x19
bl      {lua_pushinteger}

// set return value to 1, since 1 value was pushed to the stack
mov     x0, #0x1

// epilogue
ldr     x19, [sp, 16]
ldp     x29, x30, [sp], 128
ret
