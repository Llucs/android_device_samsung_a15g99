#!/system/bin/sh

# Define variáveis globais
OUTPUT_FILE="/storage/emulated/0/Downloads/device_info_complete_$(date +%Y%m%d_%H%M%S).txt"
SCRIPT_PATH=$(readlink -f "$0" 2>/dev/null || echo "$0")
DEBUGFS_MOUNTED=false

# Função para verificar sucesso de comando e logar erros
check_command() {
    if [ $? -ne 0 ]; then
        echo "Erro ao executar: $1" >> "$OUTPUT_FILE"
        echo "Erro ao executar: $1" >> /dev/tty
    fi
}

# Função para adicionar seção ao output
add_section() {
    local title="$1"
    echo "--------------------------------" >> "$OUTPUT_FILE"
    echo "$title:" >> "$OUTPUT_FILE"
    echo "--------------------------------" >> /dev/tty
    echo "$title:" >> /dev/tty
}

# Tenta conceder permissões de execução ao script
if [ ! -x "$SCRIPT_PATH" ]; then
    echo "Concedendo permissões de execução ao script..."
    chmod +x "$SCRIPT_PATH" 2>/dev/null
    check_command "chmod +x $SCRIPT_PATH"
    if [ ! -x "$SCRIPT_PATH" ]; then
        echo "Falha ao conceder permissões. Execute manualmente: chmod +x $SCRIPT_PATH" >> "$OUTPUT_FILE"
        echo "Falha ao conceder permissões. Execute manualmente: chmod +x $SCRIPT_PATH" >> /dev/tty
        exit 1
    fi
fi

# Verifica se o dispositivo tem root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script requer permissões de root. Por favor, execute com 'su'." >> "$OUTPUT_FILE"
    echo "Este script requer permissões de root. Por favor, execute com 'su'." >> /dev/tty
    exit 1
fi

# Monta debugfs se não estiver montado
if [ ! -d /sys/kernel/debug ]; then
    mount -t debugfs none /sys/kernel/debug 2>/dev/null
    if [ $? -eq 0 ]; then
        DEBUGFS_MOUNTED=true
        echo "Debugfs montado com sucesso." >> "$OUTPUT_FILE"
        echo "Debugfs montado com sucesso." >> /dev/tty
    else
        echo "Falha ao montar debugfs. Algumas informações podem estar ausentes." >> "$OUTPUT_FILE"
        echo "Falha ao montar debugfs. Algumas informações podem estar ausentes." >> /dev/tty
    fi
fi

# Cabeçalho
echo "=== Informações Completas do Dispositivo - Samsung Galaxy A15 (SM-A155M) ===" > "$OUTPUT_FILE"
echo "Data e Hora: $(date)" >> "$OUTPUT_FILE"
echo "--------------------------------" >> "$OUTPUT_FILE"
echo "=== Informações Completas do Dispositivo - Samsung Galaxy A15 (SM-A155M) ===" >> /dev/tty
echo "Data e Hora: $(date)" >> /dev/tty

# Informações do Sistema
add_section "Sistema"
echo " - Versão Android: $(getprop ro.build.version.release || echo 'Não disponível')" >> "$OUTPUT_FILE"
echo " - Nível API: $(getprop ro.build.version.sdk || echo 'Não disponível')" >> "$OUTPUT_FILE"
echo " - Versão Kernel: $(uname -r || echo 'Não disponível')" >> "$OUTPUT_FILE"
echo " - ID da Build: $(getprop ro.build.display.id || echo 'Não disponível')" >> "$OUTPUT_FILE"
echo " - Hostname: $(hostname || echo 'Não disponível')" >> "$OUTPUT_FILE"
echo " - Versão SoC: $(getprop ro.board.platform || echo 'Não disponível')" >> "$OUTPUT_FILE"
echo " - Versão Android Security: $(getprop ro.build.version.security_patch || echo 'Não disponível')" >> "$OUTPUT_FILE"
echo " - Android: $(getprop ro.build.version.release || echo 'Não disponível')" >> /dev/tty
echo " - API: $(getprop ro.build.version.sdk || echo 'Não disponível')" >> /dev/tty
echo " - Kernel: $(uname -r || echo 'Não disponível')" >> /dev/tty
echo " - Build: $(getprop ro.build.display.id || echo 'Não disponível')" >> /dev/tty
echo " - Hostname: $(hostname || echo 'Não disponível')" >> /dev/tty
echo " - SoC: $(getprop ro.board.platform || echo 'Não disponível')" >> /dev/tty
echo " - Security Patch: $(getprop ro.build.version.security_patch || echo 'Não disponível')" >> /dev/tty

# Informações da CPU
add_section "CPU"
echo " - Modelo: $(cat /proc/cpuinfo | grep "model name" | head -n 1 | cut -d ":" -f 2 | sed 's/^ //') || echo 'Não disponível'" >> "$OUTPUT_FILE"
echo " - Núcleos: $(nproc || echo 'Não disponível')" >> "$OUTPUT_FILE"
echo " - Frequência Atual: $(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq 2>/dev/null || echo 'Não disponível') kHz" >> "$OUTPUT_FILE"
echo " - Frequência Máxima: $(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null || echo 'Não disponível') kHz" >> "$OUTPUT_FILE"
echo " - Interrupções: $(cat /proc/interrupts 2>/dev/null || echo 'Não disponível')" >> "$OUTPUT_FILE"
echo " - Modelo: $(cat /proc/cpuinfo | grep "model name" | head -n 1 | cut -d ":" -f 2 | sed 's/^ //') || echo 'Não disponível'" >> /dev/tty
echo " - Núcleos: $(nproc || echo 'Não disponível')" >> /dev/tty
echo " - Frequência Atual: $(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq 2>/dev/null || echo 'Não disponível') kHz" >> /dev/tty
echo " - Frequência Máxima: $(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null || echo 'Não disponível') kHz" >> /dev/tty
echo " - Interrupções: $(cat /proc/interrupts 2>/dev/null || echo 'Não disponível')" >> /dev/tty

# Informações da RAM
add_section "RAM"
TOTAL_RAM=$(free -m | grep "Mem:" | awk '{print $2}' 2>/dev/null || echo 'Não disponível')
USED_RAM=$(free -m | grep "Mem:" | awk '{print $3}' 2>/dev/null || echo 'Não disponível')
echo " - Total: ${TOTAL_RAM} MB" >> "$OUTPUT_FILE"
echo " - Usada: ${USED_RAM} MB" >> "$OUTPUT_FILE"
echo " - Disponível: $(free -m | grep "Mem:" | awk '{print $7}' 2>/dev/null || echo 'Não disponível') MB" >> "$OUTPUT_FILE"
echo " - Total: ${TOTAL_RAM} MB" >> /dev/tty
echo " - Usada: ${USED_RAM} MB" >> /dev/tty
echo " - Disponível: $(free -m | grep "Mem:" | awk '{print $7}' 2>/dev/null || echo 'Não disponível') MB" >> /dev/tty

# Informações de Armazenamento
add_section "Armazenamento"
STORAGE_DATA=$(df -h /data 2>/dev/null | tail -n 1)
echo " - Total: $(echo "$STORAGE_DATA" | awk '{print $2}' || echo 'Não disponível')" >> "$OUTPUT_FILE"
echo " - Usado: $(echo "$STORAGE_DATA" | awk '{print $3}' || echo 'Não disponível')" >> "$OUTPUT_FILE"
echo " - Livre: $(echo "$STORAGE_DATA" | awk '{print $4}' || echo 'Não disponível')" >> "$OUTPUT_FILE"
echo " - Total: $(echo "$STORAGE_DATA" | awk '{print $2}' || echo 'Não disponível')" >> /dev/tty
echo " - Usado: $(echo "$STORAGE_DATA" | awk '{print $3}' || echo 'Não disponível')" >> /dev/tty
echo " - Livre: $(echo "$STORAGE_DATA" | awk '{print $4}' || echo 'Não disponível')" >> /dev/tty

# Informações da Bateria
add_section "Bateria"
echo " - Nível: $(cat /sys/class/power_supply/battery/capacity 2>/dev/null || echo 'Não disponível')%" >> "$OUTPUT_FILE"
echo " - Status: $(cat /sys/class/power_supply/battery/status 2>/dev/null || echo 'Não disponível')" >> "$OUTPUT_FILE"
echo " - Temperatura: $(cat /sys/class/power_supply/battery/temp 2>/dev/null | awk '{print $1/10}' || echo 'Não disponível')°C" >> "$OUTPUT_FILE"
echo " - Voltagem: $(cat /sys/class/power_supply/battery/voltage_now 2>/dev/null | awk '{print $1/1000}' || echo 'Não disponível') mV" >> "$OUTPUT_FILE"
echo " - Nível: $(cat /sys/class/power_supply/battery/capacity 2>/dev/null || echo 'Não disponível')%" >> /dev/tty
echo " - Status: $(cat /sys/class/power_supply/battery/status 2>/dev/null || echo 'Não disponível')" >> /dev/tty
echo " - Temperatura: $(cat /sys/class/power_supply/battery/temp 2>/dev/null | awk '{print $1/10}' || echo 'Não disponível')°C" >> /dev/tty
echo " - Voltagem: $(cat /sys/class/power_supply/battery/voltage_now 2>/dev/null | awk '{print $1/1000}' || echo 'Não disponível') mV" >> /dev/tty

# Informações de Rede
add_section "Rede"
WIFI_STATUS=$(dumpsys connectivity | grep -i "Wi-Fi" | grep -i "state" | head -n 1 | cut -d "=" -f 2 2>/dev/null || echo 'Não disponível')
WIFI_IP=$(ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d "/" -f 1 2>/dev/null || echo 'Não disponível')
MOBILE_STATUS=$(dumpsys telephony.registry | grep "mSignalStrength" | head -n 1 2>/dev/null || echo 'Não disponível')
echo " - Wi-Fi Status: ${WIFI_STATUS}" >> "$OUTPUT_FILE"
echo " - IP Wi-Fi: ${WIFI_IP}" >> "$OUTPUT_FILE"
echo " - Status Móvel: ${MOBILE_STATUS}" >> "$OUTPUT_FILE"
echo " - Wi-Fi Status: ${WIFI_STATUS}" >> /dev/tty
echo " - IP Wi-Fi: ${WIFI_IP}" >> /dev/tty
echo " - Status Móvel: ${MOBILE_STATUS}" >> /dev/tty

# Dispositivos I2C
add_section "Dispositivos I2C"
for i in /sys/bus/i2c/devices/*; do
    if [ -d "$i" ]; then
        NAME=$(cat "$i/name" 2>/dev/null || echo "Desconhecido")
        ADDR=$(basename "$i" | cut -d "-" -f 2)
        echo " - $NAME @ $ADDR" >> "$OUTPUT_FILE"
        echo " - $NAME @ $ADDR" >> /dev/tty
    fi
done

# Dispositivos SPI
add_section "Dispositivos SPI"
for i in /sys/bus/spi/devices/*; do
    if [ -d "$i" ]; then
        NAME=$(cat "$i/name" 2>/dev/null || echo "Desconhecido")
        echo " - $NAME" >> "$OUTPUT_FILE"
        echo " - $NAME" >> /dev/tty
    fi
done

# Informações de Clocks
add_section "Clocks Disponíveis"
echo "$(cat /sys/kernel/debug/clk/clk_summary 2>/dev/null || echo 'Debugfs não habilitado ou indisponível')" >> "$OUTPUT_FILE"
echo "$(cat /sys/kernel/debug/clk/clk_summary 2>/dev/null || echo 'Debugfs não habilitado ou indisponível')" >> /dev/tty

# Informações de Interrupções
add_section "Interrupções"
echo "$(cat /proc/interrupts 2>/dev/null || echo 'Não disponível')" >> "$OUTPUT_FILE"
echo "$(cat /proc/interrupts 2>/dev/null || echo 'Não disponível')" >> /dev/tty

# Informações de MMIO
add_section "Regiões de Memória (MMIO)"
echo "$(cat /proc/iomem 2>/dev/null || echo 'Não disponível')" >> "$OUTPUT_FILE"
echo "$(cat /proc/iomem 2>/dev/null || echo 'Não disponível')" >> /dev/tty

# Informações de GPIOs
add_section "GPIOs Usados"
echo "$(cat /sys/kernel/debug/gpio 2>/dev/null || echo 'Debugfs não habilitado ou indisponível')" >> "$OUTPUT_FILE"
echo "$(cat /sys/kernel/debug/gpio 2>/dev/null || echo 'Debugfs não habilitado ou indisponível')" >> /dev/tty

# Logs de Boot (dmesg)
add_section "Logs de Boot (dmesg - Últimas 200 Linhas)"
echo "$(dmesg | tail -n 200 2>/dev/null || echo 'Não disponível')" >> "$OUTPUT_FILE"
echo "$(dmesg | tail -n 200 2>/dev/null || echo 'Não disponível')" >> /dev/tty

# Informações do Device Tree
add_section "Device Tree (/proc/device-tree)"
echo "$(ls -l /proc/device-tree/ 2>/dev/null || echo 'Não disponível')" >> "$OUTPUT_FILE"
for dir in /proc/device-tree/*; do
    if [ -d "$dir" ]; then
        NAME=$(basename "$dir")
        VALUE=$(cat "$dir/name" 2>/dev/null || echo 'Sem nome')
        echo " - $NAME: $VALUE" >> "$OUTPUT_FILE"
        echo " - $NAME: $VALUE" >> /dev/tty
    fi
done

# Finaliza e notifica
add_section "Conclusão"
echo "Informações salvas em: $OUTPUT_FILE" >> "$OUTPUT_FILE"
echo "Informações salvas em: $OUTPUT_FILE" >> /dev/tty
echo "Processo concluído! Verifique o arquivo na pasta Downloads." >> /dev/tty

# Desmonta debugfs se foi montado
if [ "$DEBUGFS_MOUNTED" = true ]; then
    umount /sys/kernel/debug 2>/dev/null
    check_command "umount /sys/kernel/debug"
fi

# Permissões do arquivo de saída
chmod 644 "$OUTPUT_FILE" 2>/dev/null
check_command "chmod 644 $OUTPUT_FILE"