#import "NSBlock+TranquilCompatibility.h"
#import <dlfcn.h>
#import <objc/runtime.h>

struct _BlockLiteral {
    void *isa;
    int flags;
    int reserved;
    id (*invoke)(id, ...);
    void *descriptor;
};

static id call0(id self, SEL _cmd)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self);
}
static id call1(id self, SEL _cmd, id a0)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0);
}
static id call2(id self, SEL _cmd, id a0, id a1)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1);
}
static id call3(id self, SEL _cmd, id a0, id a1, id a2)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2);
}
static id call4(id self, SEL _cmd, id a0, id a1, id a2, id a3)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3);
}
static id call5(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4);
}
static id call6(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5);
}
static id call7(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6);
}
static id call8(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7);
}
static id call9(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8);
}
static id call10(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9);
}
static id call11(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10);
}
static id call12(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11);
}
static id call13(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11, id a12)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12);
}
static id call14(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11, id a12, id a13)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13);
}
static id call15(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11, id a12, id a13, id a14)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14);
}
static id call16(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11, id a12, id a13, id a14, id a15)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15);
}
static id call17(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11, id a12, id a13, id a14, id a15, id a16)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16);
}
static id call18(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11, id a12, id a13, id a14, id a15, id a16, id a17)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17);
}
static id call19(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11, id a12, id a13, id a14, id a15, id a16, id a17, id a18)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18);
}
static id call20(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11, id a12, id a13, id a14, id a15, id a16, id a17, id a18, id a19)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19);
}
static id call21(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11, id a12, id a13, id a14, id a15, id a16, id a17, id a18, id a19, id a20)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20);
}
static id call22(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11, id a12, id a13, id a14, id a15, id a16, id a17, id a18, id a19, id a20, id a21)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21);
}
static id call23(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11, id a12, id a13, id a14, id a15, id a16, id a17, id a18, id a19, id a20, id a21, id a22)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22);
}
static id call24(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11, id a12, id a13, id a14, id a15, id a16, id a17, id a18, id a19, id a20, id a21, id a22, id a23)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23);
}
static id call25(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11, id a12, id a13, id a14, id a15, id a16, id a17, id a18, id a19, id a20, id a21, id a22, id a23, id a24)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24);
}
static id call26(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11, id a12, id a13, id a14, id a15, id a16, id a17, id a18, id a19, id a20, id a21, id a22, id a23, id a24, id a25)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25);
}
static id call27(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11, id a12, id a13, id a14, id a15, id a16, id a17, id a18, id a19, id a20, id a21, id a22, id a23, id a24, id a25, id a26)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26);
}
static id call28(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11, id a12, id a13, id a14, id a15, id a16, id a17, id a18, id a19, id a20, id a21, id a22, id a23, id a24, id a25, id a26, id a27)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27);
}
static id call29(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11, id a12, id a13, id a14, id a15, id a16, id a17, id a18, id a19, id a20, id a21, id a22, id a23, id a24, id a25, id a26, id a27, id a28)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27, a28);
}
static id call30(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11, id a12, id a13, id a14, id a15, id a16, id a17, id a18, id a19, id a20, id a21, id a22, id a23, id a24, id a25, id a26, id a27, id a28, id a29)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27, a28, a29);
}
static id call31(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11, id a12, id a13, id a14, id a15, id a16, id a17, id a18, id a19, id a20, id a21, id a22, id a23, id a24, id a25, id a26, id a27, id a28, id a29, id a30)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27, a28, a29, a30);
}
static id call32(id self, SEL _cmd, id a0, id a1, id a2, id a3, id a4, id a5, id a6, id a7, id a8, id a9, id a10, id a11, id a12, id a13, id a14, id a15, id a16, id a17, id a18, id a19, id a20, id a21, id a22, id a23, id a24, id a25, id a26, id a27, id a28, id a29, id a30, id a31)
{
    return ((__bridge struct _BlockLiteral *) self)->invoke(self, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27, a28, a29, a30, a31);
}
static id callWithArguments(id self, SEL _cmd, NSArray *aArguments)
{
    // We also want to work with NSPointerArray which doesn't implement -getObjects:
    unsigned long count = [aArguments count];
    __unsafe_unretained id args[count * sizeof(id)];
    NSUInteger c;
    unsigned int i = 0;
    NSFastEnumerationState enumState = {0};
    while((c = [aArguments countByEnumeratingWithState:&enumState
                                               objects:NULL
                                                 count:0]) != 0) {
        memcpy(args+ i*sizeof(id), enumState.itemsPtr, c*sizeof(id));
        i += c;
    }
    switch(count) {
        case 0:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self);
        case 1:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0]);
        case 2:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1]);
        case 3:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2]);
        case 4:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3]);
        case 5:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4]);
        case 6:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5]);
        case 7:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
        case 8:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
        case 9:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8]);
        case 10:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9]);
        case 11:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10]);
        case 12:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11]);
        case 13:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12]);
        case 14:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13]);
        case 15:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14]);
        case 16:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15]);
        case 17:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16]);
        case 18:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17]);
        case 19:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18]);
        case 20:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18], args[19]);
        case 21:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18], args[19], args[20]);
        case 22:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18], args[19], args[20], args[21]);
        case 23:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18], args[19], args[20], args[21], args[22]);
        case 24:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18], args[19], args[20], args[21], args[22], args[23]);
        case 25:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18], args[19], args[20], args[21], args[22], args[23], args[24]);
        case 26:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18], args[19], args[20], args[21], args[22], args[23], args[24], args[25]);
        case 27:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18], args[19], args[20], args[21], args[22], args[23], args[24], args[25], args[26]);
        case 28:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18], args[19], args[20], args[21], args[22], args[23], args[24], args[25], args[26], args[27]);
        case 29:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18], args[19], args[20], args[21], args[22], args[23], args[24], args[25], args[26], args[27], args[28]);
        case 30:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18], args[19], args[20], args[21], args[22], args[23], args[24], args[25], args[26], args[27], args[28], args[29]);
        case 31:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18], args[19], args[20], args[21], args[22], args[23], args[24], args[25], args[26], args[27], args[28], args[29], args[30]);
        case 32:
            return ((__bridge struct _BlockLiteral *) self)->invoke(self, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18], args[19], args[20], args[21], args[22], args[23], args[24], args[25], args[26], args[27], args[28], args[29], args[30], args[31]);
        default:
            return nil;
    }
}


@implementation NSBlock (TranquilCompatibility_) // _ so that the compiler doesn't complain about unimplemented methods
+ (void)load
{
    if(dlsym(RTLD_DEFAULT, "TQDispatchBlock0"))
        return; // The app is linked against libtranquil and there's no need to patch NSBlock
    class_addMethod(self, @selector(call),                                (IMP)call0,  "@@:");
    class_addMethod(self, @selector(call:),                               (IMP)call1,  "@@:@");
    class_addMethod(self, @selector(call::),                              (IMP)call2,  "@@:@@");
    class_addMethod(self, @selector(call:::),                             (IMP)call3,  "@@:@@@");
    class_addMethod(self, @selector(call::::),                            (IMP)call4,  "@@:@@@@");
    class_addMethod(self, @selector(call:::::),                           (IMP)call5,  "@@:@@@@@");
    class_addMethod(self, @selector(call::::::),                          (IMP)call6,  "@@:@@@@@@");
    class_addMethod(self, @selector(call:::::::),                         (IMP)call7,  "@@:@@@@@@@");
    class_addMethod(self, @selector(call::::::::),                        (IMP)call8,  "@@:@@@@@@@@");
    class_addMethod(self, @selector(call:::::::::),                       (IMP)call9,  "@@:@@@@@@@@@");
    class_addMethod(self, @selector(call::::::::::),                      (IMP)call10, "@@:@@@@@@@@@@");
    class_addMethod(self, @selector(call:::::::::::),                     (IMP)call11, "@@:@@@@@@@@@@@");
    class_addMethod(self, @selector(call::::::::::::),                    (IMP)call12, "@@:@@@@@@@@@@@@");
    class_addMethod(self, @selector(call:::::::::::::),                   (IMP)call13, "@@:@@@@@@@@@@@@@");
    class_addMethod(self, @selector(call::::::::::::::),                  (IMP)call14, "@@:@@@@@@@@@@@@@@");
    class_addMethod(self, @selector(call:::::::::::::::),                 (IMP)call15, "@@:@@@@@@@@@@@@@@@");
    class_addMethod(self, @selector(call::::::::::::::::),                (IMP)call16, "@@:@@@@@@@@@@@@@@@@");
    class_addMethod(self, @selector(call:::::::::::::::::),               (IMP)call17, "@@:@@@@@@@@@@@@@@@@@");
    class_addMethod(self, @selector(call::::::::::::::::::),              (IMP)call18, "@@:@@@@@@@@@@@@@@@@@@");
    class_addMethod(self, @selector(call:::::::::::::::::::),             (IMP)call19, "@@:@@@@@@@@@@@@@@@@@@@");
    class_addMethod(self, @selector(call::::::::::::::::::::),            (IMP)call20, "@@:@@@@@@@@@@@@@@@@@@@@");
    class_addMethod(self, @selector(call:::::::::::::::::::::),           (IMP)call21, "@@:@@@@@@@@@@@@@@@@@@@@@");
    class_addMethod(self, @selector(call::::::::::::::::::::::),          (IMP)call22, "@@:@@@@@@@@@@@@@@@@@@@@@@");
    class_addMethod(self, @selector(call:::::::::::::::::::::::),         (IMP)call23, "@@:@@@@@@@@@@@@@@@@@@@@@@@");
    class_addMethod(self, @selector(call::::::::::::::::::::::::),        (IMP)call24, "@@:@@@@@@@@@@@@@@@@@@@@@@@@");
    class_addMethod(self, @selector(call:::::::::::::::::::::::::),       (IMP)call25, "@@:@@@@@@@@@@@@@@@@@@@@@@@@@");
    class_addMethod(self, @selector(call::::::::::::::::::::::::::),      (IMP)call26, "@@:@@@@@@@@@@@@@@@@@@@@@@@@@@");
    class_addMethod(self, @selector(call:::::::::::::::::::::::::::),     (IMP)call27, "@@:@@@@@@@@@@@@@@@@@@@@@@@@@@@");
    class_addMethod(self, @selector(call::::::::::::::::::::::::::::),    (IMP)call28, "@@:@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
    class_addMethod(self, @selector(call:::::::::::::::::::::::::::::),   (IMP)call29, "@@:@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
    class_addMethod(self, @selector(call::::::::::::::::::::::::::::::),  (IMP)call30, "@@:@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
    class_addMethod(self, @selector(call:::::::::::::::::::::::::::::::), (IMP)call31, "@@:@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
    class_addMethod(self, @selector(callWithArguments:), (IMP)callWithArguments, "@@:@");
}
@end
