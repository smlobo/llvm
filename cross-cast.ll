; Dynamic cross cast of base class to other base class - use VTable 
; offset-to-top.
; Simplified dynamic cross cast using offset-to-top; assumes the complete object 
; is Derived; No RTTI checking
;
; C++ code
; #include <cstdio>
;
; struct BaseX {
;     int a;
;     virtual void makePolymorphic() {}
; };
;
; struct BaseY {
;     int a;
;     virtual void makePolymorphic() {}
; };
;
; struct Derived : BaseX, BaseY {
;     int a;                  // Derived::a hides BaseX::a & BaseY::a
; };
;
; BaseY* baseXcrossBaseY(BaseX* bx) {
;     return dynamic_cast<BaseY*>(bx);
; }
;
; int main() {
;     Derived d = Derived {};
;     d.a = 1000;
;     d.BaseX::a = 1001;
;     d.BaseY::a = 1002;
;
;     printf("baseXcrossBaseY(Derived)->a = %d\n", baseXcrossBaseY(&d)->a);
;
;     // BaseX bx;
;     // printf("baseXcrossBaseY(BaseX) : %d\n", baseXcrossBaseY(&bx) == nullptr);
; }

declare i32 @printf(ptr, ...)

%BaseX = type { ptr, i32 }
%BaseY = type { ptr, i32 }
%Derived = type { %BaseX, %BaseY, i32 }

@str = private constant [34 x i8] 
    c"baseXcrossBaseY(Derived)->a = %d\0A\00"

; VTables (*with* offset-to-top & *without* RTTI)
@VTableBaseX = constant { [2 x ptr] } {
    [2 x ptr] [
        ptr null,
        ptr @BaseX-makePolymorphic
    ]
}
@VTableBaseY = constant { [2 x ptr] } {
    [2 x ptr] [
        ptr null,
        ptr @BaseY-makePolymorphic
    ]
}
@VTableDerived = constant { [2 x ptr], [2 x ptr] } {
    [2 x ptr] [
        ptr null,
        ptr @BaseX-makePolymorphic
    ],
    [2 x ptr] [
        ptr inttoptr (i64 -16 to ptr),
        ptr @BaseY-makePolymorphic
    ]
}

define void @BaseX-makePolymorphic(ptr %this) {
    ret void
}

define void @BaseY-makePolymorphic(ptr %this) {
    ret void
}

define ptr @baseXcrossBaseY(ptr %bx) {
    ; given pointer to BaseX inside Derived, get the pointer to BaseY
    ; use the offset-to-top like C++  __dynamic_cast, simplify to not use RTTI

    ; VTable pointer
    %bXVTablePtr = load ptr, ptr %bx
    ; the offset-of-top is before the 1st method (& no RTTI)
    %topOffsetPtr = getelementptr i8, ptr %bXVTablePtr, i64 -8
    %topOffset = load i64, ptr %topOffsetPtr
    ; calculate the top of the object
    %d = getelementptr i8, ptr %bx, i64 %topOffset
    ; BaseY ptr is returned
    %by = getelementptr %Derived, ptr %d, i32 0, i32 1
    ret ptr %by
}

define i32 @main() {
    ; allocate struct on stack
    %d = alloca %Derived

    ; BaseX sub-object + store BaseX vtable (1st method, not offset-to-top)
    %dBaseX = getelementptr %Derived, ptr %d, i32 0, i32 0
    store ptr getelementptr ({ [2 x ptr], [2 x ptr] }, 
        ptr @VTableDerived, i32 0, i32 0, i32 1), ptr %dBaseX

    ; BaseY sub-object + store BaseY vtable (1st method, not offset-to-top)
    %dBaseY = getelementptr %Derived, ptr %d, i32 0, i32 1
    store ptr getelementptr ({ [2 x ptr], [2 x ptr] }, 
        ptr @VTableDerived, i32 0, i32 1, i32 1), ptr %dBaseY

    ; initialize
    %dAPtr = getelementptr %Derived, ptr %d, i32 0, i32 2
    store i32 1000, ptr %dAPtr
    %bXAPtr = getelementptr %Derived, ptr %d, i32 0, i32 0, i32 1
    store i32 1001, ptr %bXAPtr
    %bYAPtr = getelementptr %Derived, ptr %d, i32 0, i32 1, i32 1
    store i32 1002, ptr %bYAPtr

    ; BaseX ptr for call
    %bXPtr = getelementptr %Derived, ptr %d, i32 0, i32 0
    %bYPtr = call ptr @baseXcrossBaseY(ptr %bXPtr)

    ; the `a` field of BaseY
    %baseYAPtr = getelementptr %BaseY, ptr %bYPtr, i32 0, i32 1
    %baseYA = load i32, ptr %baseYAPtr

    ; print values
    call i32 (ptr, ...) @printf(ptr @str, i32 %baseYA)

    ret i32 0
}
