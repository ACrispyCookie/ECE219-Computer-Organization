
#include <stdio.h>
#define BPR 16

int bytes = 0, called = 0, cur_stack_size = 0, max = 0;

int f(int n, int m);
void glbl_max (int num);

int main(int argc, char *argv[]) {
    int res = f(3, 5);
	
	
    printf("%d\n", res);
    printf("Reccursions:%d\n", bytes*BPR);
    printf("Called %d times\n", called);
    printf("Max stack size was: %d \n", max*BPR);
    
    return 0;
}

int f(int n, int m) {
	
	// print cur stack size
	// printf("Called cur: %d\n", cur_stack_size);
	
	called++;
    if(m == 0)
        return n;

    if(n == 0)
        return m;
    
	bytes++;
	cur_stack_size++;
	glbl_max(cur_stack_size);
	int res = f(n - 1, m) + f(n, m - 1);
	
	cur_stack_size--;
    
	return res;
}

void glbl_max (int num) {
	max = num > max ? num : max ;
}
