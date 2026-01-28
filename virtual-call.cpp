#include <cstdio>

struct Base {
    virtual int value() const {
        return 1;
    }
    virtual char XXXX() const {
        return 'b';
    }
};

struct Derived : Base {
    int value() const override {
        return 100;
    }
    char XXXX() const override {
        return 'd';
    }
};

int callBase(Base* b) {
    return b->value();
}

char callXXXX(Base* b) {
    return b->XXXX();
}

int main() {
    Base b;
    printf("callBase(Base*) = %d\n", callBase(&b));
    Derived d;
    printf("callBase(Derived*) = %d\n", callBase(&d));
}
