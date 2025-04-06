import numpy as np
import os

asmFile = "Interpolation"
inFile = '/home/umi/Documents/jumana_computer_architecture_1_2025/imgIn.img'
outFile = '/home/umi/Documents/jumana_computer_architecture_1_2025/imgOut.img'

# calls assembly code to interpolate the image
def assemble():
    cmd = 'cd /home/umi/Documents/jumana_computer_architecture_1_2025/Algorithm && ' \
          'nasm -felf64 -o {0}.o {0}.asm && ld -o {0} {0}.o && ./{0}'.format(
           asmFile)
    os.system(cmd)

# main function
def interpolate(matrix, n):
    size = (3*n)-2
    write_file(matrix)
    assemble()
    lst = read_file(outFile)
    image = np.reshape(lst, (size, size))
    return image

# write the input 
def write_file(matrix):
    try:
        with open(inFile, 'w') as f:
            for row in matrix[:-1]:
                f.write(write_file_aux(row))
                f.write('\n')
            f.write(write_file_aux(matrix[-1])+'F')
    except Exception as e:
        print(f"Failed writing {inFile}: {e}")

def write_file_aux(row):
    s = ''
    for col in range(0, len(row)):
        n = str(row[col])
        if (len(n) == 3):
            s += n + " "
        elif (len(n) == 2):
            s += '0' + n + " "
        else:
            s += '0' + n + "0 "
    return s[:-1]  

# read the output 
def read_file(filename):
    f = open(filename, "r")
    tmp = f.read()
    tmp = tmp[:-2].split('\n')
    arr = []
    for n in tmp:
        arr += (n.split(' '))
    return [int(i) for i in arr]
