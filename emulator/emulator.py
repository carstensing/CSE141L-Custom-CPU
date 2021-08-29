import random as rand
from bitstring import BitArray as Bit

INPUT_MESSAGE_INDEX = 48 # messg len 49 - 54
N_SPACES_INDEX = 61
LFSR_PATTERN_INDEX = 62 
LFSR_STATE_INDEX = 63
DATA_MEM_DELIMITER = chr(0)
data_mem = [DATA_MEM_DELIMITER]*256 # hardware inits data_mem to all one value
DELIMITER_INDEX = len(data_mem)-1
TAP_PATTERN_LIST_INDEX = 240

def init_test_bench():
    # print("Initializing test bench...")
    sentences = [
        "Mr. Watson, come here. I want to see you."
    ]
    sentence = rand.choice(sentences)

    lfsr_tap_patterns = [
        Bit(bin='0b1100000'),
        Bit(bin='0b1001000'), # use this one
        Bit(bin='0b1111000'),
        Bit(bin='0b1110010'),
        Bit(bin='0b1101010'),
        Bit(bin='0b1101001'),
        Bit(bin='0b1011100'),
        Bit(bin='0b1111110'),
        Bit(bin='0b1111011')
    ]
    data_mem[TAP_PATTERN_LIST_INDEX:len(lfsr_tap_patterns)] = lfsr_tap_patterns

    lfsr_starting_state = Bit(bin='0b0100000')

    spaces = rand.randint(8, 17)
    if (spaces < 10):
        spaces = 10
    elif (spaces > 15):
        spaces = 15

    data_mem[:len(sentence)] = sentence
    data_mem[N_SPACES_INDEX] = spaces
    # LFSR_PATTERN_INDEX = rand.randint(0, 8)
    LFSR_PATTERN_INDEX = 1
    data_mem[LFSR_STATE_INDEX] = lfsr_starting_state
    data_mem[DELIMITER_INDEX] = Bit(int=ord(DATA_MEM_DELIMITER), length=8)[1:]

def convert_to_bits():
    for i in range(len(data_mem)):
        if (type(data_mem[i]) is str):
            if (data_mem[i] == DATA_MEM_DELIMITER):
                data_mem[i] = data_mem[DELIMITER_INDEX]
            elif (len(data_mem[i]) == 1):
                # print(data_mem[i])
                ascii_value = ord(data_mem[i])
                # print(ascii_value)
                data_mem[i] = Bit(int=ascii_value, length=8)[1:]
                # print(data_mem[i].bin)
        elif (type(data_mem[i]) is int):
            data_mem[i] = Bit(int=data_mem[i], length=8)[1:]

def get_parity(num):
    carry = 0
    for bit in num.bin:
        bit = int(bit, base=2)
        carry = carry ^ bit

    # print(num.bin, Bit(int=carry, length=8)[1:].bin)
    return Bit(int=carry, length=8)[1:]

def encrypt():
    reg_curr_lfsr = data_mem[LFSR_STATE_INDEX]
    reg_space_char = Bit(int=ord(' '), length=8)[1:] # TODO store in data_mem
    reg_index = 64
    tap_pattern = data_mem[TAP_PATTERN_LIST_INDEX+int(data_mem[LFSR_PATTERN_INDEX].bin, base=2)]
    num_spaces = int(data_mem[N_SPACES_INDEX].bin, base=2)
    # print("spaces = ", num_spaces)
    # print("potential chars = ", 64-num_spaces)

    i = num_spaces + 64
    while (i != reg_index):
        # print(reg_index-64, reg_curr_lfsr.bin)
        data_mem[reg_index] = reg_space_char ^ reg_curr_lfsr
        parity = get_parity(reg_curr_lfsr & tap_pattern)
        reg_curr_lfsr = (reg_curr_lfsr<<1) | parity
        reg_index += 1

    # print()
    i = 0
    while (data_mem[i].bin != data_mem[DELIMITER_INDEX].bin):
        # print(reg_index-64, reg_curr_lfsr.bin)
        data_mem[reg_index] = data_mem[i] ^ reg_curr_lfsr
        parity = get_parity(reg_curr_lfsr & tap_pattern)
        reg_curr_lfsr = (reg_curr_lfsr<<1) | parity
        reg_index += 1
        i += 1
            

    # print()
    while (reg_index != 128):
        # print(reg_index-64, reg_curr_lfsr.bin)
        data_mem[reg_index] = reg_space_char ^ reg_curr_lfsr
        parity = get_parity(reg_curr_lfsr & tap_pattern)
        reg_curr_lfsr = (reg_curr_lfsr<<1) | parity
        reg_index += 1

# def decrypt():
#     reg_curr_lfsr = 7'b0
#     while (data_mem[64] != reg_space_char ^ reg_curr_lfsr): 

def show_message():
    i = 0
    message = ""
    while (i < 128):
        char_int = int(data_mem[i].bin, base=2)
        if (char_int < 32):
            char_int += 32
        message += chr(char_int)
        i += 1
    
    print(message)


def main():
    # print(""*80 + "\n")

    init_test_bench()
    # print(data_mem)

    convert_to_bits()
    # print(data_mem)
    show_message()

    encrypt()
    # print(data_mem)
    show_message()

    # print(""*80 + "\n")

main()
