#!/bin/bash

N_THREADS=$1
BLAST_REPORT=$2
#ArdA_E.fm_Uniprot_Q3XYD3_report_ArdA_E.fm_Uniprot_Q3XYD3_ID-gtet-98_LEN-gtet-165.csv
BLAST_REPORT_OUTFILE=$3
#ArdA_E.fm_Uniprot_Q3XYD3_report_ArdA_E.fm_Uniprot_Q3XYD3_ID-gtet-98_LEN-gtet-165_CHR-PLAS.csv

# generate random prefix for all tmp files
RAND_1=`echo $((1 + RANDOM % 100))`
RAND_2=`echo $((100 + RANDOM % 200))`
RAND_3=`echo $((200 + RANDOM % 300))`
RAND=`echo "${RAND_1}${RAND_2}${RAND_3}"`

# extract the list of IDs
cut -f 2 -d ',' ${BLAST_REPORT} | tail -n +2 > ${RAND}_ID_fofn.txt

# limit the number of jobs
function wait_for_jobs() {
    while [ "$(jobs -p | wc -l)" -ge ${N_THREADS} ]; do
        sleep 1
    done
}

# loop through each TAXA
for TAXA in $(cat ${RAND}_ID_fofn.txt); do
    # run the tasks in background
    {
        CONTIG=$(grep ",${TAXA}," ${BLAST_REPORT} | cut -f 6 -d ',')
        echo "${CONTIG}"

        if [ "$CONTIG" = "NA" ]; then
            CHR_READS=NA
            P_READS=NA
        else
            echo "Running snippy for ${TAXA}"
            samtools faidx /home/buultjensa/alkrause/fastq_download/FOUND/${TAXA}/spades_${TAXA}/contigs.fa
            samtools faidx /home/buultjensa/alkrause/fastq_download/FOUND/${TAXA}/spades_${TAXA}/contigs.fa ${CONTIG} > ${RAND}_${TAXA}_${CONTIG}.fa

            snippy --cpus 5 --outdir ${RAND}_${CONTIG}_chromosome_reference.fasta --ref chromosome_reference.fasta --ctgs ${RAND}_${TAXA}_${CONTIG}.fa --force
            snippy --cpus 5 --outdir ${RAND}_${CONTIG}_plasmid_reference.fasta --ref plasmid_reference.fasta --ctgs ${RAND}_${TAXA}_${CONTIG}.fa --force

            CHR_READS=$(samtools view -c -F 4 ${RAND}_${CONTIG}_chromosome_reference.fasta/snps.bam)
            P_READS=$(samtools view -c -F 4 ${RAND}_${CONTIG}_plasmid_reference.fasta/snps.bam)
        fi

        echo "${TAXA},${CONTIG},${CHR_READS},${P_READS}" >> ${RAND}_report.csv
    } &
    
    # limit number of parallel jobs
    wait_for_jobs
done

# Wwait for all background jobs to finish
wait

echo "CHROMOSOME_READS_MAPPED,PLASMID_READS_MAPPED" > ${RAND}_ordered_report.csv
for TAXA in $(cat ${RAND}_ID_fofn.txt); do
	CHR=`grep ^"${TAXA}," ${RAND}_report.csv | cut -f 3 -d ','`
	P=`grep ^"${TAXA}," ${RAND}_report.csv | cut -f 4 -d ','`
	echo "${CHR},${P}" >> ${RAND}_ordered_report.csv
done
	
paste ${BLAST_REPORT} ${RAND}_ordered_report.csv | tr '\t' ',' > ${BLAST_REPORT_OUTFILE}	
