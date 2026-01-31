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

; VTables (without -ve offset to full object & typeinfo)
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

define i8 @BaseX-value(%BaseX %this) {
entry:
    ret i8 88
}

define i8 @BaseY-value(%BaseY %this) {
entry:
    ret i8 89
}

define i32 @BaseZ-nonOverloadedValue(%BaseZ %this) {
entry:
    ret i32 1000
}

define i8 @BaseZ-value(%BaseZ %this) {
entry:
    ret i8 90
}

define i8 @Derived-value(%Derived %this) {
entry:
    ret i8 68
}

define i8 @Derived-value-thunk-8(ptr %this) {
entry:
    ; Adjust the pointer to the start of the Derived object
    %dStart = getelementptr ptr, ptr %this, i64 -8
    %r = call i8 @Derived-value(ptr %dStart)
    ret i8 %r
}

define i8 @Derived-value-thunk-16(ptr %this) {
entry:
    ; Adjust the pointer to the start of the Derived object
    %dStart = getelementptr ptr, ptr %this, i64 -16
    %r = call i8 @Derived-value(ptr %dStart)
    ret i8 %r
}

define i32 @main() {
entry:
    ; allocate struct on stack
    %d = alloca %Derived

    ; BaseX sub-object + store BaseX vtable (constructor)
    %dBaseX = getelementptr %Derived, ptr %d, i64 0
    store ptr getelementptr ({ [1 x ptr], [1 x ptr], [2 x ptr] }, 
        ptr @VTableDerived, i32 0, i32 0, i32 0), ptr %dBaseX

    ; BaseY sub-object + store BaseY vtable (constructor)
    %dBaseY = getelementptr %Derived, ptr %d, i64 8
    store ptr getelementptr ({ [1 x ptr], [1 x ptr], [2 x ptr] }, 
        ptr @VTableDerived, i32 0, i32 1, i32 0), ptr %dBaseY

    ; BaseZ sub-object + store BaseZ vtable (constructor)
    %dBaseZ = getelementptr %Derived, ptr %d, i64 16
    store ptr getelementptr ({ [1 x ptr], [1 x ptr], [2 x ptr] }, 
        ptr @VTableDerived, i32 0, i32 2, i32 0), ptr %dBaseZ

    ; BaseX sub-object vtable; slot 0; load method; call; print
    %dBaseXVTable = load ptr, ptr %dBaseX
    %dBaseXVTableSlot0 = getelementptr ptr, ptr %dBaseXVTable, i64 0
    %dValueMethod = load ptr, ptr %dBaseXVTableSlot0
    %dBaseXValue = call i8 %dValueMethod(ptr %d)
    %.str.0Ptr = getelementptr [22 x i8], ptr @.str.0, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %.str.0Ptr, i8 %dBaseXValue)

    ; BaseY sub-object vtable; slot 0; load method; call; print
    %dBaseYVTable = load ptr, ptr %dBaseY
    %dBaseYVTableSlot0 = getelementptr ptr, ptr %dBaseYVTable, i64 0
    %dValueThunk-8 = load ptr, ptr %dBaseYVTableSlot0
    %dBaseYValue = call i8 %dValueThunk-8(ptr %d)
    %.str.1Ptr = getelementptr [22 x i8], ptr @.str.1, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %.str.1Ptr, i8 %dBaseYValue)

    ; BaseZ sub-object vtable; slot 1; load method; call; print
    %dBaseZVTable = load ptr, ptr %dBaseZ
    %dBaseZVTableSlot1 = getelementptr ptr, ptr %dBaseZVTable, i64 1
    %dValueThunk-16 = load ptr, ptr %dBaseZVTableSlot1
    %dBaseZValue = call i8 %dValueThunk-16(ptr %d)
    %.str.2Ptr = getelementptr [22 x i8], ptr @.str.2, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %.str.2Ptr, i8 %dBaseZValue)

    ; BaseZ sub-object vtable slot 0; load method; call; print
    %dBaseZVTableSlot0 = getelementptr ptr, ptr %dBaseZVTable, i64 0
    %dNotOvrldValueMethod = load ptr, ptr %dBaseZVTableSlot0
    %dBaseZNotOvrldValue = call i32 %dNotOvrldValueMethod(ptr %d)
    %.str.3Ptr = getelementptr [22 x i8], ptr @.str.3, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %.str.3Ptr, i32 %dBaseZNotOvrldValue)

    ret i32 0
}
