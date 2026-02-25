# ================================
# 1. Estadísticas de recuperación con HybPiper
# ================================

# Genera estadísticas de recuperación por gen y por muestra:
# - Porcentaje de longitud recuperada respecto al target
# - Genes parcialmente recuperados
# - Longitud de secuencias ensambladas
# - Identificación preliminar de posibles problemas
# - Utiliza 6 CPUs

hybpiper stats \
-t_dna ../referencias/target_file_nuevo.fasta \
gene namelist.txt \
--stats_filename hybpiper_summary_stats.tsv \
--seq_lengths_filename hybpiper_seq_lengths.tsv \
--cpu 6


# ================================
# 2. Heatmap de recuperación
# ================================

# Genera un mapa de calor a partir del archivo de longitudes
# para visualizar la eficiencia de recuperación por gen y muestra.
# (Nota: parece haber un error en la extensión duplicada .tsv.tsv)

hybpiper recovery_heatmap hybpiper_seq_lengths.tsv


# ================================
# 3. Detección y recuperación de parálogos
# ================================

# Identifica loci con posibles copias parálogas
# y extrae las secuencias correspondientes para inspección posterior.

hybpiper paralog_retriever \
namelist.txt \
-t_dna ../referencias/target_file_nuevo.fasta


# ================================
# 4. Alineamiento múltiple por locus
# ================================

# Para cada locus filtrado (reteniendo ≥25% de muestras),
# se realiza alineamiento múltiple con MAFFT usando el modo automático.

for f in ../ensamblaje/resultados/locus_filtrados_25pct/loci_finales/*_filtered.fasta; do
    base=$(basename "$f" _filtered.fasta)
    echo "Alineando $f..."
    mafft --auto "$f" > "${base}_aligned.fasta"
done


# ================================
# 5. Recorte de alineamientos
# ================================

# Se eliminan regiones ambiguas o pobremente alineadas
# usando el algoritmo automated1 de trimAl.
# Los alineamientos recortados se guardan en la carpeta "recorte".

for f in *_aligned.fasta; do
    base=$(basename "$f" _aligned.fasta)
    trimal -automated1 \
    -in "$f" \
    -out recorte/"${base}_trimmed.fasta"
done


# ================================
# 6. Concatenación de loci
# ================================

# Se concatenan todos los alineamientos recortados
# en una supermatriz final.
# También se genera un archivo de particiones
# indicando los límites de cada gen en la matriz concatenada.

AMAS.py concat \
-i ../Alineamiento/recorte/*_trimmed.fasta \
-f fasta \
-d dna \
-u fasta \
-t concatenated.fasta \
-p partitions.txt


# ================================
# 7. Inferencia filogenética
# ================================

# Construcción del árbol filogenético usando IQ-TREE:
# - Usa el archivo de particiones
# - MFP+MERGE selecciona el mejor modelo por partición
#   y permite fusionar particiones con modelos similares
# - 1000 ultrafast bootstrap
# - 1000 SH-aLRT
# - 24 hilos de CPU

iqtree3 \
-s concatenated.fasta \
-p partitions.txt \
-m MFP+MERGE \
-bb 1000 \
-alrt 1000 \
-nt 24

