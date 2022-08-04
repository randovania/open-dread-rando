stp     x29, x30, [sp, -128]!
mov     x29, sp
str     x19, [sp, 16]
mov     x19, x0
mov     w0, 32
add     x1, sp, 40
str     wzr, [sp, 40]
str     w0, [sp, 44]
add     x0, sp, 48
bl      {getNpadState1}
add     x1, sp, 44
add     x0, sp, 88
bl      {getNpadState2}
ldr     x1, [sp, 56]
ldr     x0, [sp, 96]
orr     x1, x1, x0
mov     x0, x19
bl      {lua_pushinteger}
mov     x0, #0x1
ldr     x19, [sp, 16]
ldp     x29, x30, [sp], 128
ret