# aTRAM_UCE_pipeline

This repo combines and assembles UCEs from mammal probes.

Steps:

Put all *.out.best.fasta files for the given dataset together into one folder. This is the input for step 1.

Make a list of all the taxa, put in a file called taxa_list.txt. Use the Library/tip names that were used in aTRAM. This file is needed for most scripts.

1. Get longest sequence from each best file. Must have taxa_list.txt in the same folder.  The output from here goes into a folder called "longest" SCRIPT: getlongest.pl
2. Using the files in the "longest" folder, sort out the UCEs that have single and multiple probes. Must have taxa_list.txt in the same folder. Change names for singles from "UCE" to uce-[real UCE number]. Combine single probe UCEs into fasta files by locus(UCE), goes into "singleuces" folder. Print out fasta file of all the probes for multiple probe UCEs, named "multipleuces_conMULT_PROBE" output goes into "multipleuces" folder. SCRIPT: finddupsrename.pl

3.Run R script to get consensus sequence for UCE loci that have multiple probes. SCRIPT: multiprobeAlign.R
4. Combine the multiple probe UCEs into fasta files by locus (UCE). Must have taxa_list.txt in the same folder. SCRIPT: combinemults.pl
5. Combine all the Consensus sequences together so all tax for each locus in one file. also count numtax per UCE.
6. Replace all the Ns with gaps. SCRIPT: editNstogaps.pl
7. Run alignment. No script, just run a loop with mafft.
8. Trim edges to the median length of sequence on either end. SCRIPT: trimsequences.pl
