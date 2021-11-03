#!/system/bin/sh
CONFIG_FILE="$1"
CONFIG_PARAMS="mount_options mount_source mount_target mount_max_retries mount_retry_interval"

# source user-specified config file
if [ -r "${CONFIG_FILE}" ]; then
    . "${CONFIG_FILE}" >> "${LOG_FILE}" 2>&1
    missing_count=0
    for p in ${CONFIG_PARAMS}; do
        if [[ -z $(eval "echo \"\$${p}\"") ]]; then
            echo "Config file \"${CONFIG_FILE}\" is missing param \"${p}\"." >> "${LOG_FILE}" 2>&1
            missing_count=$((missing_count+1))
        fi
    done
    if [ ${missing_count} -gt 0 ]; then
        exit
    fi
else
    echo "Unable to read config file \"${CONFIG_FILE}\"." >> "${LOG_FILE}" 2>&1
    exit
fi

# attempt to mount
mkdir -p "${mount_target}" >> "${LOG_FILE}" 2>&1
retries=0
while : ; do
    su -c "mount ${mount_options} \"${mount_source}\" \"${mount_target}\"" >> "${LOG_FILE}" 2>&1
    if grep -q "${mount_target}" /proc/mounts; then
        echo "Successfully mounted source \"${mount_source}\" at \"${mount_target}\"." >> "${LOG_FILE}" 2>&1
        break
    elif [ ${retries} -lt "${mount_max_retries}" ]; then
        sleep "${mount_retry_interval}"
        retries=$((retries+1))
    else
        echo "Failed to mount source \"${mount_source}\" at \"${mount_target}\" after $((retries+1)) attempts (${retries} retries)." >> "${LOG_FILE}" 2>&1
        exit
    fi
done
