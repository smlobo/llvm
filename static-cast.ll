; Static cast of multiple base class to derived - pointer offset from sub-object 
; to object known, no need for VTable offset-to-top
; C++ code
; struct BaseX {
;     int a;
; };
; struct BaseY {
;     int a;
; };
; struct Derived : BaseX, BaseY {
;     int a;                  // Derived::a hides BaseX::a & BaseY::a
; };
; int baseXstaticDerived(BaseX* b) {
;     return static_cast<Derived*>(b)->a;
; }
; int baseYstaticDerived(BaseY* b) {
;     return static_cast<Derived*>(b)->a;
; }
; int main() {
;     Derived d = Derived {};
;     d.a = 100;
;     d.BaseX::a = 101;
;     d.BaseY::a = 102;
;     printf("baseXstaticDerived = %d, baseYstaticDerived = %d\n", 
;         baseXstaticDerived(&d), baseYstaticDerived(&d));
; }

declare i32 @printf(ptr, ...)

%BaseX = type { i32 }
%BaseY = type { i32 }
%Derived = type { %BaseX, %BaseY, i32 }

@.str = private unnamed_addr constant [50 x i8] 
    c"baseXstaticDerived = %d, baseYstaticDerived = %d\0A\00"

define i32 @baseXstaticDerived(ptr %b) {
    ; given pointer to BaseX inside Derived, get the pointer to Derived (nop)
    %d = getelementptr i8, ptr %b, i64 0
    ; the `a` field of Derived
    %dAPtr = getelementptr %Derived, ptr %d, i32 0, i32 2
    %a = load i32, ptr %dAPtr
    ret i32 %a
}

define i32 @baseYstaticDerived(ptr %b) {
    ; given pointer to BaseY inside Derived, get the pointer to Derived (-sizeof(i32))
    %d = getelementptr i8, ptr %b, i64 -4
    ; the `a` field of Derived
    %dAPtr = getelementptr %Derived, ptr %d, i32 0, i32 2
    %a = load i32, ptr %dAPtr
    ret i32 %a
}

define i32 @main() {
    ; allocate struct on stack
    %d = alloca %Derived

    ; initialize
    %dAPtr = getelementptr %Derived, ptr %d, i32 0, i32 2
    store i32 100, ptr %dAPtr
    %bXAPtr = getelementptr %Derived, ptr %d, i32 0, i32 0, i32 0
    store i32 101, ptr %bXAPtr
    %bYAPtr = getelementptr %Derived, ptr %d, i32 0, i32 1, i32 0
    store i32 102, ptr %bYAPtr

    ; BaseX ptr for call
    %bXPtr = getelementptr %Derived, ptr %d, i32 0, i32 0
    %aValBaseXStaticCast = call i32 @baseXstaticDerived(ptr %bXPtr)

    ; BaseY ptr for call
    %bYPtr = getelementptr %Derived, ptr %d, i32 0, i32 1
    %aValBaseYStaticCast = call i32 @baseYstaticDerived(ptr %bYPtr)

    ; print values
    %.strPtr = getelementptr [50 x i8], ptr @.str, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %.strPtr, i32 %aValBaseXStaticCast, 
        i32 %aValBaseYStaticCast)

    ret i32 0
}
