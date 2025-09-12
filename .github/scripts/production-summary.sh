#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Determine safe summary file
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]] && [[ -w "$(dirname "${GITHUB_STEP_SUMMARY}")" ]]; then
  SUMMARY_FILE="${GITHUB_STEP_SUMMARY}"
elif [[ -w /tmp ]]; then
  SUMMARY_FILE="$(mktemp)"
  echo "Warning: GITHUB_STEP_SUMMARY not available, using temporary file: ${SUMMARY_FILE}" >&2
else
  SUMMARY_FILE="/dev/null"
  echo "Warning: No writable location for summary, output discarded" >&2
fi

echo "## 🎉 Production Files Generated Successfully!" >> "${SUMMARY_FILE}"
echo "" >> "${SUMMARY_FILE}"
echo "### 📦 Available Artifacts:" >> "${SUMMARY_FILE}"
echo "- **modbus-breakout-production-files** - Complete production package" >> "${SUMMARY_FILE}"
echo "- **modbus-breakout-manufacturing-package** - ZIP for PCB manufacturer" >> "${SUMMARY_FILE}"
echo "- **modbus-breakout-documentation** - PDFs and interactive BOM" >> "${SUMMARY_FILE}"
echo "- **modbus-breakout-3d-and-renders** - 3D models and visualizations" >> "${SUMMARY_FILE}"
echo "" >> "${SUMMARY_FILE}"
echo "### 📋 Next Steps:" >> "${SUMMARY_FILE}"
echo "1. Download the manufacturing package and send to PCB fab" >> "${SUMMARY_FILE}"
echo "2. Use the interactive BOM for component sourcing and assembly" >> "${SUMMARY_FILE}"
echo "3. Reference the schematic PDF for testing and troubleshooting" >> "${SUMMARY_FILE}"
echo "4. Import the STEP file for mechanical design verification" >> "${SUMMARY_FILE}"