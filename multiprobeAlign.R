#script requires the packages: ape, ips, and seqinr
require(ape);require(ips);require(seqinr)

#set the working directory
setwd("/user/desktop/uce_files")

#make sure to specify a different output folder, the output files have the same name as the input
outfolder="/user/desktop/multipleuces_consensus"
singles <- NA #to hold list of fastas w/ single sequences
#consensus <- seqinr::consensus

system.time(
for (j in list.files()) {	
	if (length(read.FASTA(j)) > 1) {
			aligned <- as.character(mafft(read.FASTA(j)))
			consensus <- con(aligned,method='majority') #con calls seqinr::consensus
			write.fasta(consensus,names=j,file.out=paste(outfolder,j,'.con',sep=''))
				} else {
		singles <- c(singles,j) 
		write.fasta(as.character(read.FASTA(j)),names=j,file.out=paste(outfolder,j,'.con',sep=''))			
	}		
}	
)
