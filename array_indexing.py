#!/home/ben/anaconda3/bin/python
import argparse
import operator
import functools

# I want to call it like so: array_indexing.py [-c | -f | -p] --declare <list of indexes> --access <list of indices>

parser = argparse.ArgumentParser(description = "See what array index is being accessed")

# nargs='+': put an arbitrary number of args into a list
parser.add_argument('l', choices = ['c', 'p', 'f'], help = "choose the language: C/C++, Pascal, Fortran")
parser.add_argument('-d', type=int, nargs='+', help="initial array dimensions")
parser.add_argument('-b', type=int, nargs='+', help="initial array base indices. If not supplied, then language choice will dicatate")
parser.add_argument('-a', type=int, nargs='+', help="indices of box that you want to access")

# fun with global variables :)
args = 'f -d 6 7 3 4 -a 4 9 3 2'.split()
results = parser.parse_args(args)

if results.b == None:
    if results.l == 'c':
        results.b = [0]*len(results.a)
    else:
        results.b = [1]*len(results.a)

if len(results.d) != len(results.a):
    raise ValueError("length of d and a must be the same")

def product(li):
    return functools.reduce(operator.mul, li, 1)

# pretty sure this works for all languages now
def get_offset():
    offset = 0
    if results.l == 'f':
        for i in range(len(results.d)):
            offset += (results.a[i]-results.b[i])*product(results.d[:i])
    else:
        for i in range(len(results.d)):
            offset += (results.a[i]-results.b[i])*product(results.d[i+1:])
    return offset

# more fun with the globals
offset = get_offset()

# now I need to make a function that spits out the box accessed
def get_box_accessed():
    box_accessed = []
    local_offset = offset
    if results.l == 'f':
        divisors = [product(list(reversed(declared))[i:]) for i in range(1,len(declared))]
        return divisors
    else:
        divisors = [ product(results.d[i+1:]) for i in range(len(results.d)-1)]
        for i in divisors:
            box_accessed.append(local_offset//i) #int division
            local_offset = local_offset % i
        box_accessed.append(local_offset)
        # I think I can just add the index bases right on at the end
        box_accessed = [box + base for box,base in zip(results.b, box_accessed)]
        return box_accessed
        
print(results, offset, get_box_accessed(), sep='\n')
