#######
# download from Gencode release M15
#######
wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_mouse/release_M15/GRCm38.primary_assembly.genome.fa.gz
wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_mouse/release_M15/gencode.vM15.annotation.gtf.gz
wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_mouse/release_M15/gencode.vM15.transcripts.fa.gz
gzip -d *.gz

#######
# stats of Gencode release M15
#######
# Number of genes: 52550
less gencode.vM15.annotation.gtf | awk '$3=="gene"' | wc -l
# Number of transcript: 131100
less gencode.vM15.annotation.gtf | awk '$3=="transcript"' | wc -l
less gencode.vM15.transcripts.fa | grep '^>' | wc -l
# Get gene name and type
less gencode.vM15.annotation.gtf  | awk '$3=="gene"' | cut -f9 | awk '{print $2,$4,$6}' | sed 's/[";]//g;s/\s\+/\t/g' | sed '1i geneid\tgenetype\tgenename' > gene.info

#######
# generate transcript to gene mapping file
#######
less gencode.vM15.transcripts.fa | egrep '^>' | sed 's/^>//' | awk 'OFS="\t"{print $0,$0}' | sed 's/|/\t/;s/|/\t/' | awk 'OFS="\t"{print $4,$2}' > tx2gene.txt

transcripts_fasta=gencode.vM15.transcripts.fa
#######
# Kallisto index
#######
docker run -v $PWD:/mnt zhengh42/kallisto:0.43.1 kallisto index -i /mnt/M15.gencode.kallisto.idx /mnt/$transcripts_fasta

#######
# salmon index
#######
docker run -v $PWD:/mnt zhengh42/salmon:0.8.2 salmon index -i /mnt/M15.gencode.salmon.idx -t /mnt/$transcripts_fasta
