#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script and module is placed.
# This will make sure your module will still work if Magisk changes its mount point in the future
MODDIR=${0%/*}

export LOG_FILE="${MODDIR}/multi-mount.log"
LOG_MAX_LINES=1000

BOOTWAIT_MAX_COUNT=20
BOOTWAIT_COUNT_INTERVAL=15s

CONF_DIR="/sdcard/.multi-mount"
CONF_FILESPEC="${CONF_DIR}/*.conf"

# wait for system boot to complete
bootwait_count=0
until [[ $(getprop sys.boot_completed) || ${bootwait_count} -ge ${BOOTWAIT_MAX_COUNT} ]]; do
    sleep ${BOOTWAIT_COUNT_INTERVAL}
    bootwait_count=$((bootwait_count+1))
done
if [ ${bootwait_count} -ge ${BOOTWAIT_MAX_COUNT} ]; then
    exit 1
fi

# prevent log file from growing too large
tail -n "${LOG_MAX_LINES}" "${LOG_FILE}" > "${LOGFILE}.tmp"
mv "${LOGFILE}.tmp" "${LOG_FILE}"

echo "=== $(date) ===" >> "${LOG_FILE}" 2>&1

# process config files in parallel
config_file_count=0
for f in ${CONF_FILESPEC}; do
    config_file_count=$((config_file_count+1))
    "${MODDIR}/mount-from-config.sh" "${f}" &
done
if [ "${config_file_count}" -eq 0 ]; then
    echo "No config files found." >> "${LOG_FILE}" 2>&1
fi
wait
