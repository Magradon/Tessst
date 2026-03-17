#!/bin/sh

for file in *; do
    if [ -f "$file" ]; then
        case "$file" in
            *.bin)
                echo "Пропущено (уже .bin): $file"
                ;;
            *.sh)
                echo "Пропущено (скрипт .sh): $file"
                ;;    
            *)
                mv -- "$file" "$file.bin"
                echo "Переименовано: $file -> $file.bin"
                ;;
        esac
    fi
done

echo "Готово!"