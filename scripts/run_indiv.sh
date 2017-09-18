#######
# Arguments setup
#######
id=$1
id2=$2
raw_dir=/srv/gevaertlab/data/Hong/RNASeq/hb/Reads
work_dir=/srv/gevaertlab/data/Hong/RNASeq/hb/RNASeq_MM_HB/
ref_dir=$work_dir/reference

#######
# QC with trim-galore and fastqc
#######
docker run -v $raw_dir:/home zhengh42/trim-galore:0.4.4  trim_galore -q 15  --stringency 3 --gzip --length 15 --paired /home/$id/${id2}_1.fq.gz /home/$id/${id2}_2.fq.gz --fastqc --output_dir /home 1> ../logs/$id.trim_galore.log 2>&1

#######
# Get the stand-specific information of the reads
# In the log file of salmon output: Automatically detected most likely library type as ISR
#######
zcat $raw_dir/${id2}_1_val_1.fq.gz | head -n 400000 | gzip > $raw_dir/${id2}_test_1.fq.gz
zcat $raw_dir/${id2}_2_val_2.fq.gz | head -n 400000 | gzip > $raw_dir/${id2}_test_2.fq.gz
docker run -v $raw_dir:/home/seq -v $ref_dir:/home/ref -v $work_dir/results/salmon:/home/out  zhengh42/salmon:0.8.2 salmon quant -i /home/ref/M15.gencode.salmon.idx -l A -o /home/out/$id.test -1 /home/seq/${id2}_test_1.fq.gz -2 /home/seq/${id2}_test_2.fq.gz 1> ../logs/$id.salmon.log 2>&1

#######
# Get transcript level expression estimate using Kallisto
# Since the library type is ISR, --rf-stranded argument is specified
#######
docker run -v $raw_dir:/home/seq -v $ref_dir:/home/ref -v $work_dir/results/kallisto:/home/out zhengh42/kallisto:0.43.1 \
	kallisto quant -i /home/ref/M15.gencode.kallisto.idx \
	-o /home/out/$id /home/seq/${id2}_1_val_1.fq.gz /home/seq/${id2}_2_val_2.fq.gz  \
	-b 100 --rf-stranded --fusion  1> ../logs/$id.kallisto.log 2>&1 


