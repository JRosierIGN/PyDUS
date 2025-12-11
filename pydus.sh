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
  and generates a UML diagram in your chosen format for each one.
  
  Note: __init__.py files and scripts without classes are ignored.

SYNTAX
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  $0 <source_directory> <output_directory> [format]

ARGUMENTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  source_directory     Root directory containing .py files to analyze
  output_directory     Directory where generated files will be saved
  format              Output format: svg, png, dot, or pdf (default: svg)

FORMATS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  svg    Scalable Vector Graphics (default, recommended)
  png    Portable Network Graphics (raster image)
  dot    Graphviz DOT format (for further processing)
  pdf    Portable Document Format

USAGE EXAMPLES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  $0 ./my_project ./UML/class_diagrams
  $0 ./my_project ./UML/class_diagrams svg
  $0 ./my_project ./UML/class_diagrams png
  $0 ./my_project ./UML/class_diagrams pdf

  This command will:
    • Recursively scan ./my_project
    • Detect all .py files containing classes
    • Generate one diagram file per file in ./UML/class_diagrams

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
exit 0
}

# If no arguments or --help
if [ -z "$1" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    print_help
fi

# Check for at least 2 arguments
if [ -z "$2" ]; then
    echo "ERROR: At least two arguments required."
    echo "Use --help for usage information."
    exit 1
fi

SRCDIR="$1"
OUTDIR="$2"
FORMAT="${3:-svg}"

# Validate format
case "$FORMAT" in
    svg|png|dot|pdf)
        ;;
    *)
        echo "ERROR: Invalid format '$FORMAT'."
        echo "Supported formats: svg, png, dot, pdf"
        exit 1
        ;;
esac

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
echo "Output format       : $FORMAT"
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
    pyreverse -o "$FORMAT" -p "$filename" "$file" >/dev/null 2>&1
    diagram_original="classes_${filename}.${FORMAT}"
    diagram_target="$OUTDIR/${filename}.${FORMAT}"
    
    if [ -f "$diagram_original" ]; then
        mv "$diagram_original" "$diagram_target"
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
echo "║  Diagrams generated      : $GENERATED"                                    
echo "║  Files skipped           : $SKIPPED"                                      
echo "║  Output format           : $FORMAT"                                       
echo "║  Source directory        : $SRCDIR"                                       
echo "║  Output directory        : $OUTDIR"                                       
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo ""