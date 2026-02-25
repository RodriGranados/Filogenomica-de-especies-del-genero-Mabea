#!/bin/bash
# ============================================================
# Descripción: Limpieza de lecturas paired-end con Trimmomatic
# ============================================================

# Número de hilos
THREADS=8

# Carpeta donde están los FASTQ crudos
RAW_DIR="/home/lab_cafe/Desktop/users_ibt/elipariente/lecturas_crudas"

# Archivo de adaptadores
ADAPTERS="$RAW_DIR/TruSeq3-PE.fa"

# Carpetas de salida
OUTDIR="/home/lab_cafe/Desktop/users_ibt/elipariente/lecturas_limpias"
PAIRED_DIR="$OUTDIR/paired"
UNPAIRED_DIR="$OUTDIR/unpaired"

# Crear carpetas de salida si no existen
mkdir -p "$PAIRED_DIR" "$UNPAIRED_DIR"

# Cambiar al directorio con los FASTQ
cd "$RAW_DIR" || { echo "❌ No se pudo acceder a $RAW_DIR"; exit 1; }

# Bucle para procesar todas las muestras R1
for R1 in EMP01_L*_R1.fastq.gz
do
    # Obtener nombre base (ej: EMP01_L0001)
    BASE=$(basename "$R1" _R1.fastq.gz)

    # Archivo R2 correspondiente
    R2="${BASE}_R2.fastq.gz"

    # Verificar que exista el archivo R2
    if [[ ! -f "$R2" ]]; then
        echo "⚠️  No se encontró el archivo R2 para $BASE, se omite."
        continue
    fi

    echo "🔹 Procesando muestra: $BASE"

    # Ejecutar Trimmomatic
    trimmomatic PE -threads $THREADS -phred33 \
    "${BASE}_R1.fastq.gz" "${BASE}_R2.fastq.gz" \
    "$PAIRED_DIR/${BASE}_R1_paired.fq.gz" "$UNPAIRED_DIR/${BASE}_R1_unpaired.fq.gz" \
    "$PAIRED_DIR/${BASE}_R2_paired.fq.gz" "$UNPAIRED_DIR/${BASE}_R2_unpaired.fq.gz" \
    ILLUMINACLIP:${ADAPTERS}:2:30:10 \
    LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:50

    echo "✅ Muestra $BASE procesada."
    echo "--------------------------------------------"
done

echo "🎉 Trimming completado para todas las muestras."
echo "📂 Archivos 'paired' en:   $PAIRED_DIR"
echo "📂 Archivos 'unpaired' en: $UNPAIRED_DIR"
