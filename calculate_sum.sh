#!/bin/bash

# Dosya yolları
# Varsayılan input host dizininde `input_numbers.txt` olarak sağlanıyor
INPUT_FILE="/data/numbers.txt"
OUTPUT_DIR="/data"

# Çıkış dosyası adı: <date>_<time>-v<version>.txt
# date: YYYY-MM-DD, time: HHMMSS (iki nokta ':' içermeyen güvenli format),
# version: artan sayı eğer aynı zaman damgasına sahip dosya varsa
DATE_STR=$(TZ=Europe/Istanbul date +%Y-%m-%d)
TIME_STR=$(TZ=Europe/Istanbul date +%H:%M:%S)
BASE_NAME="${DATE_STR}_${TIME_STR}"

mkdir -p "$OUTPUT_DIR"

version=1
OUTPUT_FILE="$OUTPUT_DIR/${BASE_NAME}-v${version}.txt"

# Eğer input dosyası yoksa boş output oluşturup çık
if [[ ! -e "$INPUT_FILE" ]]; then
    > "$OUTPUT_FILE"
    exit 0
fi

# Satır toplamlarını topla ve diziye kaydet
sums=()
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ -n "$line" ]]; then
        line_sum=0
        for number in $line; do
            if [[ "$number" =~ ^-?[0-9]+$ ]]; then
                ((line_sum += number))
            fi
        done
        sums+=("$line_sum")
    fi
done < "$INPUT_FILE"

# Input dosyasının son karakterinin newline olup olmadığını kontrol et
ends_with_newline=0
if [[ -s "$INPUT_FILE" ]]; then
    last_char=$(tail -c1 "$INPUT_FILE" 2>/dev/null || true)
    if [[ "$last_char" == $'\n' ]]; then
        ends_with_newline=1
    fi
fi

# Result dosyasını oluştur ve dizi elemanlarını yaz (son satıra ekstra newline ekleme kontrolü)
> "$OUTPUT_FILE"
total=${#sums[@]}
for idx in "${!sums[@]}"; do
    if [[ $idx -eq $((total-1)) && $ends_with_newline -eq 0 ]]; then
        printf '%s' "${sums[$idx]}" >> "$OUTPUT_FILE"
    else
        printf '%s\n' "${sums[$idx]}" >> "$OUTPUT_FILE"
    fi
done

exit 0