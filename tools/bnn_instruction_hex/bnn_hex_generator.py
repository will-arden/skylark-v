from ast import literal_eval

OPCODE          = "1111111"
BNNCMS_FUNCT3   = "000"
BCNV_FUNCT3     = "001"
BNN_FUNCT3      = "010"

def decode(text):

    # Separate the input into clean fields of text
    text = text.replace(',', '')
    text = text.lower()
    fields = text.split()

    funct3 = ""             # Placeholder for funct3
    instr_bin = [None]*32   # Empty array for binary machine code
    instr_hex = []          # Empty array for hexadecimal machine code

    # Find funct3
    if(fields[0] == "bnn"):
        funct3 = "010"
    elif(fields[0] == "bcnv"):
        funct3 = "001"
    elif(fields[0] == "bnncms"):
        funct3 = "000"
    else:
        print("Invalid instruction. '"+fields[0]+"' needs rd, rs1 and rs2.")
        return
    
    # Find the operands of BNN and BCNV instructions
    if((fields[0] == "bnn") | (fields[0] == "bcnv")):
        if(len(fields) == 4):
            rd      = int(fields[1][1:])
            rs1     = int(fields[2][1:])
            rs2     = int(fields[3][1:])
            #imm     = literal_eval(fields[4])
            #print(rd, rs1, rs2)
        else:
            print("Invalid instruction. '"+fields[0]+"' needs rd, rs1 and rs2.")
            return
        
        # Convert operands to binary
        rd_bin  = (bin(rd)[2:]).zfill(5)
        rs1     = (bin(rs1)[2:]).zfill(5)
        rs2     = (bin(rs2)[2:]).zfill(5)
        #print(rd_bin, rs1_bin, rs2_bin)

        # Populate binary machine code
        instr_bin[25:32] = OPCODE
        instr_bin[20:25] = rd_bin
        instr_bin[17:20] = funct3
        instr_bin[12:17] = rs1
        instr_bin[7:12] = rs2
        instr_bin[0:7] = "0000000"
        instr_bin = ''.join(instr_bin)
        print(instr_bin)

        # Get hexadecimal
        instr_hex = hex(int(instr_bin, 2))[2:].zfill(8)
        print(instr_hex)

    elif(fields[0] == "bnncms"):
        if(len(fields) == 2):
            imm     = int(fields[1])
            imm_bin = (bin(imm)[2:]).zfill(12)

            # Populate binary machine code
            instr_bin = ['0'] * 32
            instr_bin[25:32] = OPCODE
            instr_bin[17:20] = funct3
            instr_bin[0:12] = imm_bin
            instr_bin = ''.join(instr_bin)
            print(instr_bin)

            # Get hexadecimal
            instr_hex = hex(int(instr_bin, 2))[2:].zfill(8)
            print(instr_hex)

        else:
            print("Invalid instruction. '"+fields[0]+"' needs only an immediate.")
            return

    else:
        print("This instruction is not supported. Please refer to github.com/will-arden/skylark-v for more information.")

while(True):
    print("\nType the BNN instruction for skylark-v, or press Ctrl+C to exit.")
    decode(str(input()))