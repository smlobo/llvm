#include <cstdio>

struct Point {
    int x;
    int y;
    int sum() const {
        return x + y;
    }
};

int main() {
    Point p = Point {11, 22};
    printf("{%d, %d}.sum = %d\n", p.x, p.y, p.sum());
}

