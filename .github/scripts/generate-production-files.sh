#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Print error with script name, line number, and exit status
err_report() {
  local exit_code=$?
  local line_no=${BASH_LINENO[0]:-unknown}
  local script_name=$(basename "$0")
  echo "[ERROR] $script_name failed at line $line_no with exit code $exit_code" >&2
}
trap err_report ERR

# Cleanup or restore options if needed
cleanup() {
  : # Placeholder for future cleanup logic
}
trap cleanup EXIT


echo '🚀 Starting KiCad production file generation...'

# Preflight: Check required tools
missing_tools=()
for tool in kicad_export pcbdraw; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    missing_tools+=("$tool")
  fi
done
if [ ${#missing_tools[@]} -ne 0 ]; then
  echo "❌ Missing required tool(s): ${missing_tools[*]}" >&2
  echo "Please ensure all required tools are installed and in PATH before running this script." >&2
  exit 2
fi


# Check if project files exist
echo '🔍 Checking project files...'
if [ ! -f Modbus-RJ45-Breakout.kicad_pro ]; then
  echo '❌ Modbus-RJ45-Breakout.kicad_pro not found!'
  ls -la *.kicad_* || echo 'No KiCad files found'
  exit 1
fi

if [ ! -f Modbus-RJ45-Breakout.kicad_pcb ]; then
  echo '❌ Modbus-RJ45-Breakout.kicad_pcb not found!'
  exit 1
fi

if [ ! -f Modbus-RJ45-Breakout.kicad_sch ]; then
  echo '❌ Modbus-RJ45-Breakout.kicad_sch not found!'
  exit 1
fi

echo '✅ All required project files found'

# Export production data using the kicad_export script
echo '📋 Generating production files...'
kicad_export Modbus-RJ45-Breakout.kicad_pro

# Additional 3D renderings using PcbDraw for nice visualizations
echo '🎨 Creating additional 3D visualizations...'
mkdir -p production/renders

# Generate top and bottom PCB renders
pcbdraw plot Modbus-RJ45-Breakout.kicad_pcb production/renders/modbus-rj45-breakout_top.png --style set-white-enig --side front
pcbdraw plot Modbus-RJ45-Breakout.kicad_pcb production/renders/modbus-rj45-breakout_bottom.png --style set-white-enig --side back

# Generate component placement views
pcbdraw plot Modbus-RJ45-Breakout.kicad_pcb production/renders/modbus-rj45-breakout_components.png --style set-white-enig --side front --components

# Create a combined assembly drawing
pcbdraw plot Modbus-RJ45-Breakout.kicad_pcb production/renders/modbus-rj45-breakout_assembly.svg --style set-white-enig --side front --components

echo '📊 Generating production summary...'
cat > production/PRODUCTION_README.md << 'EOF'
# ModBus RJ45 Breakout Production Files

This directory contains all files needed for PCB manufacturing and assembly.

## Manufacturing Files
- **gerbers/** - Gerber files for PCB fabrication
- **drill/** - Drill files for via and hole drilling
- **modbus-rj45-breakout_manufacturing.zip** - Complete package for PCB manufacturer

## Documentation
- **pdf/modbus-rj45-breakout_schematic.pdf** - Complete schematic documentation
- **pdf/modbus-rj45-breakout_pcb.pdf** - PCB layout with all layers
- **bom/modbus-rj45-breakout_ibom.html** - Interactive HTML Bill of Materials

## 3D Models and Visualizations
- **3d/modbus-rj45-breakout.step** - 3D model for mechanical verification
- **renders/modbus-rj45-breakout_top.png** - Top view rendering
- **renders/modbus-rj45-breakout_bottom.png** - Bottom view rendering
- **renders/modbus-rj45-breakout_components.png** - Component placement view
- **renders/modbus-rj45-breakout_assembly.svg** - Assembly drawing (vector)

## Usage
1. Send **modbus-rj45-breakout_manufacturing.zip** to your PCB manufacturer
2. Use the **interactive BOM** for component placement during assembly
3. Reference **schematic PDF** for troubleshooting and modifications
4. Import **STEP file** into mechanical CAD for enclosure design

Generated automatically by GitHub Actions workflow.
EOF

echo '✅ Production file generation complete!'
echo ''
echo '📁 Generated files:'
find production -type f | sort
echo ''
echo '📊 File sizes:'
du -sh production/*