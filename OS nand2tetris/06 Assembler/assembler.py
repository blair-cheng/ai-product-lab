"""
step1, Parser
    read a file .asm
    break the input into understanding components
    A_command = 0
    C_command = 1
    L_command = 2
"""
#read

f = open("Max.asm","r")
i = 0
for x in f:
    print(i, x)
    i = i + 1

#step1, Parser
class commandType:
    A_command = 0
    C_command = 1
    L_command = 2

    def __init__(self, command_str):
        self.symbol = None
        self.dest = None
        self.jump = None
        self.commandtype = self.classify(command_str)

    def classify(self, command_str):
        if command_str.startswith("(") and command_str.endswith(")"):
            self.symbol = command_str[1:-1].strip()
            return self.L_command
        if command_str.startswith("@"):
            follow_code = command_str[1:]
            command_str.symbol = follow_code
            if command_str[1:] == self.symbol:
                return commandType.L_command
            return commandType.A_command
        else:
            semicollon = ';'
            equal = '='
            if semicollon in command_str: #dest = comp;jump, comp;jump
                command_parts = command_str.split(semicollon)
                self.jump = command_parts[-1]
                dest_comp = "".joincommand_pars[:-1]
            else:
                dest_comp = command_str
            if equal in dest_comp:
                dest, comp = dest_comp.split(equal)
                self.dest = dest.strip()
                self.comp = comp.strip()
            else:
                self.comp = dest_comp.strip()
                return self.C_command
            
    def get_jump_code(self, jump):
        jump_code = {
            "null": "000",
            "JGT": "001",
            "JEQ": "010",
            "JGE": "011",
            "JLT": "100",
            "JNE": "101",
            "JLE": "110",
            "JMP": "111"
        }
        return jump_code.get(jump, "Invalid jump instruction")
    
    def get_dest_code(self, dest):
        dest_code = {
            "null": "000",
            "M": "001",
            "D": "010",
            "MD": "011",
            "DM": "011",
            "A": "100",
            "AM": "101",
            "AD": "110",
            "AMD": "111",
            "ADM": "111"
        }
    
    def get_binary_code(self,comp):
        comp_code = {
            "0": "0101010",
            "1": "0111111",
            "-1": "0111010",
            "D": "0001100",
            "A": "0110000",
            "M": "0110000",
            "!D": "0001101",
            "!A": "0110001",
            "!M": "1110001",
            "-D": "0001111",
            "-A": "0110011",
            "-M": "1110011",
            "D+1": "0011111",
            "A+1": "0110111",
            "M+1": "1110111",
            "D-1": "0001110",
            "A-1": "0110010",
            "M-1": "1110010",
            "D+A": "0000010",
            "D+M": "1000010",
            "D-A": "0010011",
            "D-M": "1010011",
            "A-D": "0000111",
            "M-D": "1000111",
            "D&A": "0000000",
            "D&M": "1000000",
            "D|A": "0010101",
            "D|M": "1010101"
        }
        return comp_code.get(comp, "Invalid comp instruction")

    symbol_table = {
        "R0": "0",
        "SP": "0",
        "R1": "1",
        "LCL": "1",
        "R2": "2",
        "ARG": "2",        
        "R3": "3",
        "THIS": "3",        
        "R4": "4",
        "THAT": "4",        
        "R5": "5",
        "R6": "6",
        "R7": "7",
        "R8": "8",
        "R9": "9",
        "R10": "10",
        "R11": "11",
        "R12": "12",
        "R13": "13",
        "R14": "14",
        "R15": "15",
        "SCREEN": "16384",
        "KBD": "24576"
    }
    for x in command_str:
        if commandType == 2:
            if symbol.isupper():
                symbol_table['x'] = i + 1
            if symbol.islower():
                i = 0
                symbol_table['x'] = 16 + i
                i = i + 1   
        if commandType ==0:
            Acommand_bi = command_str.binary()

    preDefinedSymbols={
        "R0": "0",
        "SP": "0",
        "R1": "1",
        "LCL": "1",
        "R2": "2",
        "ARG": "2",        
        "R3": "3",
        "THIS": "3",        
        "R4": "4",
        "THAT": "4",        
        "R5": "5",
        "R6": "6",
        "R7": "7",
        "R8": "8",
        "R9": "9",
        "R10": "10",
        "R11": "11",
        "R12": "12",
        "R13": "13",
        "R14": "14",
        "R15": "15",
        "SCREEN": "16384",
        "KBD": "24576"
    }










"""
step2, Code
    output binary code
    2.1 translate that contain no symbolic references
    White Space => ignore
    Comments => ignore
    A-command
        begins with @, => 0 + binary(15)
        @x: constants,non-negative
    C-command
        begins without @, =>111+binary(13)
        dest = comp;jump
        x xxxxxx => for computation
            dest = comp;jump
            comp;jump
            dest = comp
            comp
        xxx => destination
            A   100
            AD  110
            ADM 111
        xxx => jump
            null000
            JGT 001
            JEQ 010
            JGE 011
            JLT 100
            JNE 101
            JLE 110
            JMP 111

step3, Symbol
    process symbol, output a file with .hack
    3.1 Predefined Symbols
        SP => 0
        LCL => 1
        ARG => 2
        THIS => 3
        THAT => 4
        R0-R15 => 0-15
        SCREEN => 16384
        KBD => 24576

    3.2 labels 
        @X_1.$:XX paired with (X_1.$:XX) 

    3.3 variables    
        xx_1.$:x variable names  
            not begin with a digit.
step4. main
"""

#step3: write
f = open("Max.hack","a")
f.write()
f.close