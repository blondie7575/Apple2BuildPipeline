//
//  exampleC.c
//  Apple2BuildPipelineSample
//
//  Created by Jeremy Rand on 9/6/14.
//  Copyright (c) 2014 One Girl, One Laptop Productions. All rights reserved.
//


#include <conio.h>
#include <stdio.h>


extern void asmFunc(void);


int main(void)
{
    printf("\n\nHello, world!\n");
    cgetc();
    //asmFunc();
    return 0;
}