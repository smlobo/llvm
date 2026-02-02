; Dynamic cast of multiple base class to derived - use VTable offset-to-top
; Note: inlined __dynamic_cast() with no RTTI checking
; C++ code
; struct BaseX {
;     int a;
;     virtual void makePolymorphic() {}
; };
; struct BaseY {
;     int a;
;     virtual void makePolymorphic() {}
; };
; struct Derived : BaseX, BaseY {
;     int a;                  // Derived::a hides BaseX::a & BaseY::a
; };
; int baseXdynamicDerived(BaseX* b) {
;     return dynamic_cast<Derived*>(b)->a;
; }
; int baseYdynamicDerived(BaseY* b) {
;     return dynamic_cast<Derived*>(b)->a;
; }
; int main() {
;     Derived d = Derived {};
;     d.a = 100;
;     d.BaseX::a = 101;
;     d.BaseY::a = 102;
;     printf("baseXdynamicDerived = %d, baseYdynamicDerived = %d\n", 
;         baseXdynamicDerived(&d), baseYdynamicDerived(&d));
; }

declare i32 @printf(ptr, ...)

%BaseX = type { ptr, i32 }
%BaseY = type { ptr, i32 }
%Derived = type { %BaseX, %BaseY, i32 }

@.str = private unnamed_addr constant [52 x i8] 
    c"baseXdynamicDerived = %d, baseYdynamicDerived = %d\0A\00"

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

define void @BaseX-makePolymorphic(%BaseX %this) {
    ret void
}

define void @BaseY-makePolymorphic(%BaseX %this) {
    ret void
}

define i32 @baseXdynamicDerived(ptr %b) {
    ; given pointer to BaseX inside Derived, get the pointer to Derived
    ; use the offset-to-top like C++  __dynamic_cast, simplify to not use RTTI

    ; VTable pointer
    %bXVTablePtr = load ptr, ptr %b
    ; the top-of-offset is before the 1st method (& no RTTI)
    %topOffsetPtr = getelementptr i8, ptr %bXVTablePtr, i64 -8
    %topOffset = load i64, ptr %topOffsetPtr
    ; calculate the top of the object
    %d = getelementptr i8, ptr %b, i64 %topOffset
    ; the `a` field of Derived
    %dAPtr = getelementptr %Derived, ptr %d, i32 0, i32 2
    %a = load i32, ptr %dAPtr
    ret i32 %a
}

define i32 @baseYdynamicDerived(ptr %b) {
    ; given pointer to BaseY inside Derived, get the pointer to Derived (-sizeof(i32))
    ; use the offset-to-top like C++  __dynamic_cast, simplify to not use RTTI

    ; VTable pointer
    %bYVTablePtr = load ptr, ptr %b
    ; the top-of-offset is before the 1st method (& no RTTI)
    %topOffsetPtr = getelementptr i8, ptr %bYVTablePtr, i64 -8
    %topOffset = load i64, ptr %topOffsetPtr
    ; calculate the top of the object
    %d = getelementptr i8, ptr %b, i64 %topOffset
    ; the `a` field of Derived
    %dAPtr = getelementptr %Derived, ptr %d, i32 0, i32 2
    %a = load i32, ptr %dAPtr
    ret i32 %a
}

; Result: 8 bytes (two i32s)
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
    store i32 100, ptr %dAPtr
    %bXAPtr = getelementptr %Derived, ptr %d, i32 0, i32 0, i32 1
    store i32 101, ptr %bXAPtr
    %bYAPtr = getelementptr %Derived, ptr %d, i32 0, i32 1, i32 1
    store i32 102, ptr %bYAPtr

    ; BaseX ptr for call
    %bXPtr = getelementptr %Derived, ptr %d, i32 0, i32 0
    %aValBaseXDynamicCast = call i32 @baseXdynamicDerived(ptr %bXPtr)

    ; BaseY ptr for call
    %bYPtr = getelementptr %Derived, ptr %d, i32 0, i32 1
    %aValBaseYDynamicCast = call i32 @baseYdynamicDerived(ptr %bYPtr)

    ; print values
    %.strPtr = getelementptr [50 x i8], ptr @.str, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %.strPtr, i32 %aValBaseXDynamicCast, 
        i32 %aValBaseYDynamicCast)

    ret i32 0
}
