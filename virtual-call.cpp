#include <cstdio>

struct Base {
    virtual int value() const {
        return 1;
    }
};

struct Derived : Base {
    int value() const override {
        return 100;
    }
};

int callBase(Base* b) {
    return b->value();
}

int main() {
    Base b;
    printf("callBase(Base*) = %d\n", callBase(&b));
    Derived d;
    printf("callBase(Derived*) = %d\n", callBase(&d));
}
