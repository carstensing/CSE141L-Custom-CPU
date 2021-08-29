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
        command = commands.get(parse[0], False)
        if (command != False):
          assembly_code.write(text)
        elif (parse[0] == "#!#" or parse[0] == "-->"):
          assembly_code.write(text)
    elif (text == "START\n" and start == False):
      start = True

  program.close()
  assembly_code.close()


def update_loop_variables(file):
  assembly_code = open(file, 'r')
  update_loops = {}
  loop_values = {}

  output_text = ""

  for instr in assembly_code:
    output_text += instr
    parse = instr.split()
    if (parse[0] == "#!#"):
      if (update_loops.get(parse[1], False) == False):
        update_loops[parse[1]] = -2
      else:
        loop_values[parse[1]] = update_loops[parse[1]]
        update_loops.pop(parse[1])

    for key in update_loops:
      update_loops[key] = update_loops[key] + 1
  
  assembly_code.close()
  assembly_code = open(file, 'w')

  for instr in output_text.split('\n'):
    parse = instr.split()
    if (len(parse) > 0):
      if (parse[0] == "-->"):
        instr = parse[1] + ' ' + str(loop_values[parse[2]])

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
      machine_instr += Bit(uint=int(parse[1]), length=6).bin
    elif (len(parse) == 3):
      machine_instr += Bit(uint=int(parse[1]), length=3).bin
      machine_instr += Bit(uint=int(parse[2]), length=3).bin

    machine_code.write(machine_instr + '\n')

  assembly_code.close()
  machine_code.close()


text_to_assembly \
 ("C:\\Users\\carst\\Desktop\\CSE 140L\\Program1\\emulator\\program1.txt", \
  "C:\\Users\\carst\\Desktop\\CSE 140L\\Program1\\emulator\\assembly_code.txt")

update_loop_variables \
  ("C:\\Users\\carst\\Desktop\\CSE 140L\\Program1\\emulator\\assembly_code.txt")

assembly_to_machine \
 ("C:\\Users\\carst\\Desktop\\CSE 140L\\Program1\\emulator\\assembly_code.txt", \
  "C:\\Users\\carst\\Desktop\\CSE 140L\\Program1\\src\\machine_code.txt")