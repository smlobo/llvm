; Multiple inheritence VTable with thunk methods (generated to adjust `this`
; using fixed offsets given the sub-object, before calling the intended method)
; C++ code
; #include <cstdio>
; struct BaseX {
;     virtual char value() const {
;         return 'X';
;     }
; };
; struct BaseY {
;     virtual char value() const {
;         return 'Y';
;     }
; };
; struct BaseZ {
;     virtual int nonOverloadedValue() const {
;         return 1000;
;     }
;     virtual char value() const {
;         return 'Z';
;     }
; };
; struct Derived : BaseX, BaseY, BaseZ {
;     char value() const override {
;         return 'D';
;     }
; };
; int main() {
;     Derived d;
;     BaseX* bXPtr = &d;
;     printf("bXPtr of d: %c\n", bXPtr->value());
;     BaseY* bYPtr = &d;
;     printf("bYPtr of d: %c\n", bYPtr->value());
;     BaseZ* bZPtr = &d;
;     printf("bZPtr of d: %c\n", bZPtr->value());
;     printf("bZPtr of d nonOverloadedValue: %d\n", bZPtr->nonOverloadedValue());
; }

declare i32 @printf(ptr, ...)

@.str.0 = constant [16 x i8] c"bXPtr of d: %c\0A\00"
@.str.1 = constant [16 x i8] c"bYPtr of d: %c\0A\00"
@.str.2 = constant [16 x i8] c"bZPtr of d: %c\0A\00"
@.str.3 = constant [35 x i8] c"bZPtr of d nonOverloadedValue: %d\0A\00"

%BaseX = type { ptr }
%BaseY = type { ptr }
%BaseZ = type { ptr }
%Derived = type { %BaseX, %BaseY, %BaseZ }

; VTables (without offset-to-top & RTTI)
@VTableBaseX = constant { [1 x ptr] } {
    [1 x ptr] [
        ptr @BaseX-value
    ]
}
@VTableBaseY = constant { [1 x ptr] } {
    [1 x ptr] [
        ptr @BaseY-value
    ]
}
@VTableBaseZ = constant { [2 x ptr] } {
    [2 x ptr] [
        ptr @BaseZ-nonOverloadedValue,
        ptr @BaseZ-value
    ]
}
@VTableDerived = constant { [1 x ptr], [1 x ptr], [2 x ptr] } {
    [1 x ptr] [
        ptr @Derived-value
    ],
    [1 x ptr] [
        ptr @Derived-value-thunk-8
    ],
    [2 x ptr] [
        ptr @BaseZ-nonOverloadedValue,
        ptr @Derived-value-thunk-16
    ]
}

define i8 @BaseX-value(ptr %this) {
    ret i8 88
}

define i8 @BaseY-value(ptr %this) {
    ret i8 89
}

define i32 @BaseZ-nonOverloadedValue(ptr %this) {
    ret i32 1000
}

define i8 @BaseZ-value(ptr %this) {
    ret i8 90
}

define i8 @Derived-value(ptr %this) {
    ret i8 68
}

define i8 @Derived-value-thunk-8(ptr %this) {
    ; Adjust the pointer to the start of the Derived object
    %dStart = getelementptr i8, ptr %this, i64 -8
    %r = call i8 @Derived-value(ptr %dStart)
    ret i8 %r
}

define i8 @Derived-value-thunk-16(ptr %this) {
    ; Adjust the pointer to the start of the Derived object
    %dStart = getelementptr i8, ptr %this, i64 -16
    %r = call i8 @Derived-value(ptr %dStart)
    ret i8 %r
}

define i32 @main() {
    ; allocate struct on stack
    %d = alloca %Derived

    ; BaseX sub-object + store BaseX vtable (constructor)
    %dBaseX = getelementptr %Derived, ptr %d, i32 0, i32 0
    store ptr getelementptr ({ [1 x ptr], [1 x ptr], [2 x ptr] }, 
        ptr @VTableDerived, i32 0, i32 0, i32 0), ptr %dBaseX

    ; BaseY sub-object + store BaseY vtable (constructor)
    %dBaseY = getelementptr %Derived, ptr %d, i32 0, i32 1
    store ptr getelementptr ({ [1 x ptr], [1 x ptr], [2 x ptr] }, 
        ptr @VTableDerived, i32 0, i32 1, i32 0), ptr %dBaseY

    ; BaseZ sub-object + store BaseZ vtable (constructor)
    %dBaseZ = getelementptr %Derived, ptr %d, i32 0, i32 2
    store ptr getelementptr ({ [1 x ptr], [1 x ptr], [2 x ptr] }, 
        ptr @VTableDerived, i32 0, i32 2, i32 0), ptr %dBaseZ

    ; BaseX sub-object vtable; slot 0; load method; call; zero extend; print
    %dBaseXVTable = load ptr, ptr %dBaseX
    %dBaseXVTableSlot0 = getelementptr ptr, ptr %dBaseXVTable, i64 0
    %dValueMethod = load ptr, ptr %dBaseXVTableSlot0
    %dBaseXValue = call i8 %dValueMethod(ptr %d)
    %charToIntX = zext i8 %dBaseXValue to i32
    call i32 (ptr, ...) @printf(ptr @.str.0, i32 %charToIntX)

    ; BaseY sub-object vtable; slot 0; load method; call; zero extend; print
    %dBaseYVTable = load ptr, ptr %dBaseY
    %dBaseYVTableSlot0 = getelementptr ptr, ptr %dBaseYVTable, i64 0
    %dValueThunk-8 = load ptr, ptr %dBaseYVTableSlot0
    %dBaseYValue = call i8 %dValueThunk-8(ptr %dBaseY)
    %charToIntY = zext i8 %dBaseYValue to i32
    call i32 (ptr, ...) @printf(ptr @.str.1, i32 %charToIntY)

    ; BaseZ sub-object vtable; slot 1; load method; call; zero extend; print
    %dBaseZVTable = load ptr, ptr %dBaseZ
    %dBaseZVTableSlot1 = getelementptr ptr, ptr %dBaseZVTable, i64 1
    %dValueThunk-16 = load ptr, ptr %dBaseZVTableSlot1
    %dBaseZValue = call i8 %dValueThunk-16(ptr %dBaseZ)
    %charToIntZ = zext i8 %dBaseZValue to i32
    call i32 (ptr, ...) @printf(ptr @.str.2, i32 %charToIntZ)

    ; BaseZ sub-object vtable slot 0; load method; call; print
    %dBaseZVTableSlot0 = getelementptr ptr, ptr %dBaseZVTable, i64 0
    %dNotOvrldValueMethod = load ptr, ptr %dBaseZVTableSlot0
    %dBaseZNotOvrldValue = call i32 %dNotOvrldValueMethod(ptr %dBaseZ)
    call i32 (ptr, ...) @printf(ptr @.str.3, i32 %dBaseZNotOvrldValue)

    ret i32 0
}
