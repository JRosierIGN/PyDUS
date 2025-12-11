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
  $0 [options] <source_directory> <output_directory> [format]

OPTIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  -v, --verbose       Show detailed output from pyreverse
  -h, --help          Display this help message

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
  $0 -v ./my_project ./UML/class_diagrams pdf

  This command will:
    • Recursively scan ./my_project
    • Detect all .py files containing classes
    • Generate one diagram file per file in ./UML/class_diagrams

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
exit 0
}

VERBOSE=0

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -h|--help)
            print_help
            ;;
        *)
            break
            ;;
    esac
done

# If no arguments
if [ -z "$1" ]; then
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

# Check if pyreverse is installed
if ! command -v pyreverse &> /dev/null; then
    echo "ERROR: pyreverse not found. Please install pylint first:"
    echo "  pip install pylint"
    exit 1
fi

mkdir -p "$OUTDIR"

# List Python files (excluding __init__.py)
mapfile -d '' FILES < <(find "$SRCDIR" -type f -name "*.py" ! -name "__init__.py" -print0)
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
echo "Verbose mode        : $([ "$VERBOSE" -eq 1 ] && echo "ON" || echo "OFF")"
echo ""
echo "Generating diagrams..."
echo ""

for file in "${FILES[@]}"; do
    COUNT=$((COUNT + 1))
    
    if [ "$VERBOSE" -eq 0 ]; then
        progress_bar $COUNT $TOTAL
    fi
    
    filename=$(basename "$file" .py)
    
    # Check if file contains a class
    if ! grep -Eq "^[[:space:]]*class[[:space:]]+[A-Za-z0-9_]+" "$file"; then
        SKIPPED=$((SKIPPED + 1))
        [ "$VERBOSE" -eq 1 ] && echo "SKIPPED: $file (no class found)"
        continue
    fi
    
    # Generate diagram
    if [ "$VERBOSE" -eq 1 ]; then
        echo "Processing: $file"
        pyreverse -o "$FORMAT" -p "$filename" "$file"
    else
        pyreverse -o "$FORMAT" -p "$filename" "$file" >/dev/null 2>&1
    fi
    
    diagram_original="classes_${filename}.${FORMAT}"
    diagram_target="$OUTDIR/${filename}.${FORMAT}"
    
    if [ -f "$diagram_original" ]; then
        mv "$diagram_original" "$diagram_target"
        GENERATED=$((GENERATED + 1))
        [ "$VERBOSE" -eq 1 ] && echo "SUCCESS: Generated $diagram_target"
    else
        SKIPPED=$((SKIPPED + 1))
        [ "$VERBOSE" -eq 1 ] && echo "FAILED: Could not generate diagram for $file"
    fi
done

echo ""
echo ""
echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║                              SUMMARY                                      ║"
echo "╠═══════════════════════════════════════════════════════════════════════════╣"
printf "║  %-23s : %-47s║\n" "Total Python files" "$TOTAL"
printf "║  %-23s : %-47s║\n" "Diagrams generated" "$GENERATED"
printf "║  %-23s : %-47s║\n" "Files skipped" "$SKIPPED"
printf "║  %-23s : %-47s║\n" "Output format" "$FORMAT"
printf "║  %-23s : %-47s║\n" "Source directory" "$SRCDIR"
printf "║  %-23s : %-47s║\n" "Output directory" "$OUTDIR"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo ""