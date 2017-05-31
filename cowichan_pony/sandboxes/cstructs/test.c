#include<stdio.h>
typedef struct {
	float y;
   int x;
   
} structure;

void setEvent(structure e) {
        printf("%i \n %f \n", e.x,e.y);
}

void printhello() {
    printf("hello \n");
}

structure returnstruct(structure s) {
    s.x = 100;
    s.y = 200.0;
    return s;
}