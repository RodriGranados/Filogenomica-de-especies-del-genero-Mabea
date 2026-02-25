#!/bin/bash
# ============================================================
# Descripción: Ensambla lecturas limpias con HybPiper usando BWA
# para múltiples muestras listadas en namelist.txt
# ============================================================

# ==== 1. Configuración de rutas ====
READS_DIR="/home/lab_cafe/Desktop/users_ibt/elipariente/lecturas_limpias/paired"
TARGETS="/home/lab_cafe/Desktop/users_ibt/elipariente/ensamblaje/referencias/target_file_nuevo.fasta"
OUTDIR="/home/lab_cafe/Desktop/users_ibt/elipariente/ensamblaje/resultados"
THREADS=32
NAMELIST="${READS_DIR}/namelist.txt"

# ==== 2. Crear carpeta de salida e indexar target ====
mkdir -p "$OUTDIR"
cd "$OUTDIR"

if [[ ! -f "${TARGETS}.bwt" ]]; then
    echo "🔹 No se encontró el índice BWA del target. Creándolo..."
    bwa index "$TARGETS"
    samtools faidx "$TARGETS"
fi

# ==== 3. Ejecutar HybPiper por cada muestra ====
echo "===== INICIO DEL ENSAMBLAJE HYBPIPER ====="
echo "Fecha: $(date)"
echo "=========================================="

while read SAMPLE; do
    echo "🔹 Procesando muestra: $SAMPLE"
    
    R1="${READS_DIR}/${SAMPLE}_R1_paired.fq.gz"
    R2="${READS_DIR}/${SAMPLE}_R2_paired.fq.gz"
    
    if [[ -f "$R1" && -f "$R2" ]]; then
        hybpiper assemble \
            -t_dna "$TARGETS" \
            -r "$R1" "$R2" \
            --prefix "$SAMPLE" \
            --bwa \
            --cpu "$THREADS"
        
        echo "✅ Ensamblaje completado para $SAMPLE"
    else
        echo "⚠️  No se encontraron los archivos para $SAMPLE, se omite."
    fi
    echo "----------------------------------"
done < "$NAMELIST"

echo "===== ENSAMBLAJE FINALIZADO ====="
echo "Fecha: $(date)"
