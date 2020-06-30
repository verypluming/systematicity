#!/usr/bin/python
# -*- coding: utf-8 -*-

# import sys
# args = sys.argv

def cal(k,d,n,i,t):
    output = d*n*i*((3*d*n*t)**(k-1))*(i+3*d*n*t)
    return(output)

d = 10 
n = 1
i = 1
t = 1
#n = 10
#i = 10
#t = 10

print('#det = {0}'.format(d))
print('#noun = {0}'.format(n))
print('#iv = {0}'.format(i))
print('#tv = {0}'.format(t))
print('Number of sentences:')
print('depth0: {0:,}'.format(d*n*i))
print('depth1: {0:,}'.format(cal(1,d,n,i,t)))
print('depth2: {0:,}'.format(cal(2,d,n,i,t)))
print('depth3: {0:,}'.format(cal(3,d,n,i,t)))
print('depth4: {0:,}'.format(cal(4,d,n,i,t)))
print('depth5: {0:,}'.format(cal(5,d,n,i,t)))

