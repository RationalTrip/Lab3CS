#include <stdio.h>
#include <iostream>

using namespace std;

int main(){
int i,j,z,sumA,sumB,sumPairs;

sumPairs = 0;
for (int p; p<200; p++){
for (i=1;i<10000;i++){
  sumA = 0;
  for (j=1;j<i;j++){
    if (i%j==0)
      sumA += j;
  }

  sumB = 0;
  for (z=1;z<sumA;z++){
    if (sumA%z==0)
      sumB += z;
  }

  if (sumB == i && sumB != sumA)
    sumPairs += i * p;
}
}

cout << sumPairs;
return 0;
}
