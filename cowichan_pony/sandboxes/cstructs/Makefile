test.a : test.o
	#gcc -shared -o test.so test.o
	ar rcs libtest.a test.o
	rm test.o 
test.o : test.c
	gcc -c -Wall -Werror -fpic test.c

all : 
	#rm cstructs libtest.a
	make test.a
	ponyc
clean : 
	rm test.o 

