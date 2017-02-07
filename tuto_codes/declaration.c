#include <stdio.h>

int x = 3;

int f(int y){return x+y;}

int main(){
  x = 5;
  printf("%d\n",f(10));
}
