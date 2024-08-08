"""
compiler.py takes the user-level assembly code, trims it of everything but
code, calculates the correct JUMP distances, and converts the assembly code
into machine code.

The output of compiler.py is put into the src folder. However, to run a
specific program on the CPU, the desired file needs to be renamed to
"machine_code.txt". 

EX: machine_code1.txt --> machine_code.txt
"""

from bitstring import BitArray as Bit

commands = {
    "lsw"    : "000",
    "errflg" : "001",
    "set"    : "010",
    "bne"    : "011",
    "par"    : "100",
    "add"    : "101",
    "xor"    : "110",
    "lsor"   : "111"
}


def text_to_assembly(in_file, out_file):
    program = open(in_file, 'r')
    assembly_code = open(out_file, 'w')
    start = False

    for text in program:
        # print(text, end='')
        if (start):
            parse = text.split()
            if (len(parse) > 0):
                is_command = commands.get(parse[0], False)
                if (is_command):
                    assembly_code.write(text)
                elif (parse[0] == "#!#" or parse[0] == "-->"):
                    assembly_code.write(text)
                elif (parse[0] == "<--"):
                    text = text + "add 63\nadd 63\nadd 2\n"
                    assembly_code.write(text)
        elif (text == "START\n" and start == False):
            start = True

    program.close()
    assembly_code.close()


# Calculates the number of instructions the Program Counter needs to jump back
# to repeat loops
def update_loop_variables(file):
    assembly_code = open(file, 'r')
    update_loops = {}
    loop_values = {}

    output_text = ""

    # counts the number of instructions for each LOOP
    for instr in assembly_code:
        output_text += instr
        parse = instr.split()
        if (parse[0] == "#!#"):
            if (update_loops.get(parse[1], False) == False):
                update_loops[parse[1]] = -1
            else:
                loop_values[parse[1]] = update_loops[parse[1]]
                update_loops.pop(parse[1])
        else:
            for key in update_loops:
                update_loops[key] = update_loops[key] + 1

    print(update_loops)
    print(loop_values)
    
    assembly_code.close()
    assembly_code = open(file, 'w')

    for instr in output_text.split('\n'):
        parse = instr.split()
        if (len(parse) > 0):
            if (parse[0] == "<--"):
                instr = parse[1] + ' ' + str(loop_values[parse[2]])
            elif (parse[0] == "-->"):
                instr = parse[1] + ' ' + str(loop_values[parse[2]]+1)

            if (parse[0] != "#!#"):
                assembly_code.write(instr+"\n")
    
    assembly_code.close()


def assembly_to_machine(in_file, out_file):
    assembly_code = open(in_file, 'r')
    machine_code = open(out_file, 'w')

    for assembly_instr in assembly_code:
        parse = assembly_instr.split()
        machine_instr = ""

        machine_instr += commands[parse[0]]

        if (len(parse) == 2):
            if (parse[0] == "add"):
                machine_instr += Bit(uint=int(parse[1]), length=6).bin
            elif (parse[0] == "errflg"):
                machine_instr += Bit(uint=int(parse[1]), length=3).bin
                machine_instr += "000"
        elif (len(parse) == 3):
            machine_instr += Bit(uint=int(parse[1]), length=3).bin
            machine_instr += Bit(uint=int(parse[2]), length=3).bin

        machine_code.write(machine_instr + '\n')

    assembly_code.close()
    machine_code.close()


for i in range(1, 4):
    text_to_assembly \
     ("./compiler/program" + str(i) + ".txt", \
         "./compiler/assembly_code" + str(i) + ".txt")

    update_loop_variables \
        ("./compiler/assembly_code" + str(i) + ".txt")

    assembly_to_machine \
    ("./compiler/assembly_code" + str(i) + ".txt", \
        "./src/machine_code" + str(i) + ".txt")