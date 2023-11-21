#include <stdio.h>
int bytes = 0, called = 0;

int f(int n, int m);

int main(int argc, char *argv[]) {
    int res = f(3, 5);

    printf("%d\n", res);
    printf("Reccursions:%d\n", bytes);
    printf("Called %d times\n", called);
}

int f(int n, int m) {
	
	called++;
    if(m == 0)
        return n;

    if(n == 0)
        return m;
    bytes++;

    return f(n - 1, m) + f(n, m - 1);
}

