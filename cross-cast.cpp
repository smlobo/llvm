#include <cstdio>

struct BaseX {
    int a;
    virtual void makePolymorphic() {}
};

struct BaseY {
    int a;
    virtual void makePolymorphic() {}
};

struct Derived : BaseX, BaseY {
    int a;                  // Derived::a hides BaseX::a & BaseY::a
};

BaseY* baseXcrossBaseY(BaseX* bx) {
    return dynamic_cast<BaseY*>(bx);
}

int main() {
    Derived d = Derived {};
    d.a = 1000;
    d.BaseX::a = 1001;
    d.BaseY::a = 1002;

    printf("baseXcrossBaseY(Derived)->a = %d\n", baseXcrossBaseY(&d)->a);

    // BaseX bx;
    // printf("baseXcrossBaseY(BaseX) : %d\n", baseXcrossBaseY(&bx) == nullptr);
}
