#!/usr/bin/python3  

import sys  
import os  



contigs_dir = sys.argv[1] 
output_dir = sys.argv[2]    
k = int(sys.argv[3])        

def WriteSeq(Label, Seq, output_file, source_file):  
    output_file.write(">" + Label + " from " + source_file + "\n")  
    W = 80  
    SeqLength = len(Seq)  
    BlockCount = int((SeqLength + (W-1)) / W)  
    for BlockIndex in range(0, BlockCount):  
        Block = Seq[BlockIndex * W:]  
        Block = Block[:W]  
        output_file.write(Block + "\n")  

def OnSeq(Label, Seq, output_file):  
    global N, C  
    N += 1  
    if len(Seq) < 2 * k:  
        return  
    First = Seq[0:k]  
    Last = Seq[-k:]  
    if First == Last:  
        TrimmedSeq = Seq[:-k]  
        assert len(TrimmedSeq) == len(Seq) - k  
        C += 1  
        WriteSeq(Label, TrimmedSeq, output_file, current_file)  


for filename in os.listdir(contigs_dir):  
    if not filename.endswith('.fasta'):    
        continue  

    current_file = os.path.join(contigs_dir, filename)  
    output_file_path = os.path.join(output_dir, f"circular_{filename}") 

    Label = None  
    Seq = ""  
    N = 0  
    C = 0  

    with open(current_file) as File, open(output_file_path, 'w') as output_file:  
        while True:  
            Line = File.readline()  
            if len(Line) == 0:  
                if Seq != "":  
                    OnSeq(Label, Seq, output_file)  
                break  
            Line = Line.strip()  
            if len(Line) == 0:  
                continue  
            if Line[0] == ">":  
                if Seq != "":  
                    OnSeq(Label, Seq, output_file)  
                Label = Line[1:]  
                Seq = ""  
            else:  
                Seq += Line.replace(" ", "")  


    sys.stderr.write(f"Processed {filename}: {C} circular contigs found out of {N} sequences.\n")