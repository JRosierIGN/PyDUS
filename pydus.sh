#!/bin/bash

print_help() {
cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║                ██████╗ ██╗   ██╗██████╗ ██╗   ██╗███████╗                 ║
║                ██╔══██╗╚██╗ ██╔╝██╔══██╗██║   ██║██╔════╝                 ║
║                ██████╔╝ ╚████╔╝ ██║  ██║██║   ██║███████╗                 ║
║                ██╔═══╝   ╚██╔╝  ██║  ██║██║   ██║╚════██║                 ║
║                ██║        ██║   ██████╔╝╚██████╔╝███████║                 ║
║                ╚═╝        ╚═╝   ╚═════╝  ╚═════╝ ╚══════╝                 ║
║                                                                           ║
║                        Python Diagram UML Specific                        ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝

DESCRIPTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Automatically generates specific UML diagrams for each Python file 
  containing one or more classes.

  Recursively scans a source directory, identifies Python files with classes,
  and generates a UML diagram (SVG format) for each one.
  
  Note: __init__.py files and scripts without classes are ignored.

SYNTAX
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  $0 <source_directory> <output_directory>

ARGUMENTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  source_directory     Root directory containing .py files to analyze
  output_directory     Directory where generated SVG files will be saved

USAGE EXAMPLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  $0 ./my_project ./UML/class_diagrams

  This command will:
    • Recursively scan ./my_project
    • Detect all .py files containing classes
    • Generate one SVG file per file in ./UML/class_diagrams

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
exit 0
}

# If no arguments or --help
if [ -z "$1" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    print_help
fi

# Check for 2 arguments
if [ -z "$2" ]; then
    echo "ERROR: Two arguments required."
    echo "Use --help for usage information."
    exit 1
fi

SRCDIR="$1"
OUTDIR="$2"

# Check if source directory exists
if [ ! -d "$SRCDIR" ]; then
    echo "ERROR: Source directory '$SRCDIR' does not exist."
    exit 1
fi

mkdir -p "$OUTDIR"

# List Python files (excluding __init__.py)
FILES=($(find "$SRCDIR" -type f -name "*.py" ! -name "__init__.py"))
TOTAL=${#FILES[@]}
COUNT=0
GENERATED=0
SKIPPED=0

# Progress bar
progress_bar() {
    local progress=$1
    local total=$2
    local width=40
    
    if [ "$total" -eq 0 ]; then
        local filled=0
        local empty=$width
    else
        local filled=$(( (progress * width + total - 1) / total ))
        if [ "$filled" -gt "$width" ]; then
            filled=$width
        fi
        local empty=$(( width - filled ))
    fi
    
    printf "\r["
    if [ "$filled" -gt 0 ]; then
        printf "%0.s█" $(seq 1 $filled)
    fi
    if [ "$empty" -gt 0 ]; then
        printf "%0.s░" $(seq 1 $empty)
    fi
    printf "] %d/%d" "$progress" "$total"
}

echo ""
echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║                  PYDUS — Python Diagram UML Specific                      ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Source directory    : $SRCDIR"
echo "Output directory    : $OUTDIR"
echo "Files to process    : $TOTAL"
echo ""
echo "Generating diagrams..."
echo ""

for file in "${FILES[@]}"; do
    COUNT=$((COUNT + 1))
    progress_bar $COUNT $TOTAL
    
    filename=$(basename "$file" .py)
    
    # Check if file contains a class
    if ! grep -Eq "^[[:space:]]*class[[:space:]]+[A-Za-z0-9_]+" "$file"; then
        SKIPPED=$((SKIPPED + 1))
        continue
    fi
    
    # Generate diagram
    pyreverse -o svg -p "$filename" "$file" >/dev/null 2>&1
    svg_original="classes_${filename}.svg"
    svg_target="$OUTDIR/${filename}.svg"
    
    if [ -f "$svg_original" ]; then
        mv "$svg_original" "$svg_target"
        GENERATED=$((GENERATED + 1))
    else
        SKIPPED=$((SKIPPED + 1))
    fi
done

echo ""
echo ""
echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║                              SUMMARY                                      ║"
echo "╠═══════════════════════════════════════════════════════════════════════════╣"
echo "║  Total Python files      : $TOTAL"                                        
echo "║  SVG generated           : $GENERATED"                                    
echo "║  Files skipped           : $SKIPPED"                                      
echo "║  Source directory        : $SRCDIR"                                       
echo "║  Output directory        : $OUTDIR"                                       
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo ""