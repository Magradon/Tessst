#!/bin/sh

new_name="$1"
ods_file="$2"

if [ -z "$new_name" ] || [ "${new_name%*.bin}" = "$new_name" ]; then
    echo "Err: $0 "
    exit 1
fi


target_dir="/home/magradon/LUA_workspace/shellscript/Dest/$new_name"
mkdir -p "$target_dir"

src_file="/home/magradon/openwrt/bin/targets/ramips/mt76x8/openwrt-ramips-mt76x8-skylab_skw92a-squashfs-sysupgrade.bin"
cnfg_file="/home/magradon/openwrt/.config"

cp -v "$src_file" "$target_dir/$new_name"
cp -v "$cnfg_file" "$target_dir"

if [ -n "$ods_file" ] || [ "${ods_file%*.ods}" = "$ods_file" ]; then
    exit 0
fi

libreoffice --headless --convert-to csv --outdir "$(dirname "$ods_file")" "$ods_file"
converted_csv="$(dirname "$ods_file")/$(basename "$ods_file" .ods).csv"

if [ ! -f "$converted_csv" ]; then
    echo "Ошибка конвертации файла $ods_file"
    exit 1
fi

header_line=$(head -n 1 "$converted_csv")

header_md="|"
separator_md="|"

OLDIFS=$IFS
IFS=','
set -- $header_line
IFS=$OLDIFS

for col in "$@"
do
    col=$(echo "$col" | sed 's/^ *"//;s/" *$//')
    header_md="$header_md $col |"
    separator_md="$separator_md---|"
done

# Записываем шапку таблицы
cat > "$target_dir/readme.md" <<EOF

# Архив конфигурации

Date: $(date)
Name: $target_dir/$new_name

$header_md
$separator_md
EOF

# Добавить описание

# Таблица
tail -n +2 "$converted_csv" | while IFS=',' read -r line
do
    OLDIFS=$IFS
    IFS=','
    set -- $line
    IFS=$OLDIFS

    row_md="|"
    for field in "$@"
    do
        field=$(echo "$field" | sed 's/^ *"//;s/" *$//')
        row_md="$row_md $field |"
    done

    echo "$row_md" >> "$target_dir/readme.md"
done

rm -f "$converted_csv"
