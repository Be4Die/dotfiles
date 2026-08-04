#!/bin/bash
temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
load=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)

# Чистый вывод без иконки — она задана в format конфига
echo "{\"text\": \"${temp}°C | ${load}%\", \"tooltip\": \"GPU Temp: ${temp}°C\\nLoad: ${load}%\"}"
