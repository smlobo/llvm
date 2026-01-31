; C++ code
; struct Base {
;     virtual int value() const {
;         return 1;
;     }
; };
; struct Derived : Base {
;     int value() const override {
;         return 100;
;     }
; };
; int callBase(Base* b) {
;     return b->value();
; }
; int main() {
;     Base b;
;     printf("callBase(Base*) = %d\n", callBase(&b));
;     Derived d;
;     printf("callBase(Derived*) = %d\n", callBase(&d));
; }

declare i32 @printf(ptr, ...)

@fmtBase = constant [22 x i8] c"callBase(Base*) = %d\0A\00"
@fmtDerived = constant [25 x i8] c"callBase(Derived*) = %d\0A\00"

%Base = type { ptr }
%Derived = type { %Base }

; VTables
@VTableBase = constant { [1 x ptr] } {
    [1 x ptr] [
        ptr @Base-value
    ]
}
@VTableDerived = constant { [1 x ptr] } { 
    [1 x ptr] [
        ptr @Derived-value
    ]
}

define i32 @Base-value(%Base %this) {
entry:
    ret i32 1
}

define i32 @Derived-value(%Derived %this) {
entry:
    ret i32 100
}

define i32 @callBase(ptr %b) {
    ; load vtable from object
    %vtable = load ptr, ptr %b

    ; go to vtable slot 0
    %vTableSlot0 = getelementptr ptr, ptr %vtable, i64 0

    ; load the method from that vtable slot
    %mPtr = load ptr, ptr %vTableSlot0

    ; call the method
    %r = call i32 %mPtr(ptr %b)
    ret i32 %r
}

define i32 @main() {
entry:
    ; allocate struct on stack
    %b = alloca %Base

    ; get pointer to the vtable field
    %bVTablePtr = getelementptr %Base, ptr %b, i32 0, i32 0

    ; store vtable pointer in the object (done by constructor)
    store ptr getelementptr({ [1 x ptr] }, ptr @VTableBase, i32 0, i32 0, i32 0),
        ptr %bVTablePtr

    ; call callBase(%b)
    %rB = call i32 @callBase(ptr %b)

    ; print values
    %fmtBasePtr = getelementptr [22 x i8], ptr @fmtBase, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %fmtBasePtr, i32 %rB)

    ; same for Derived
    %d = alloca %Derived
    %dVTablePtr = getelementptr %Derived, ptr %d, i32 0, i32 0
    store ptr getelementptr({ [1 x ptr] }, ptr @VTableDerived, i32 0, i32 0, i32 0),
        ptr %dVTablePtr
    %rD = call i32 @callBase(ptr %d)
    %fmtDerivedPtr = getelementptr [25 x i8], ptr @fmtDerived, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %fmtDerivedPtr, i32 %rD)

    ret i32 0
}
