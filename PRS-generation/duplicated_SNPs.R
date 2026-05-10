data <- read.table("/your/directory/BASE.QC", header = T, sep="\t")
head(data)

duplicates <- duplicated(data$SNP)
dup_snps <- data[duplicates,] # list with duplicated snps
unique_snps <- data[!duplicates,] # list with unique snps


write.table(dup_snps,"/your/directory/BASE.QC.duplicates",row.names = F, col.names = T, quote = F,sep="\t")

write.table(unique_snps,"/your/directory/BASE.QC.new",row.names = F, col.names = T, quote = F,sep="\t")
