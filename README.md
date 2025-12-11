# PYDUS - Python Diagram UML Specific

<p align="center">
  <img src="https://img.shields.io/badge/bash-script-green?style=for-the-badge&logo=gnu-bash" alt="Bash Script">
  <img src="https://img.shields.io/badge/python-3.x-blue?style=for-the-badge&logo=python" alt="Python 3.x">
</p>

A lightweight bash tool that automatically generates individual UML class diagrams for Python files. Perfect for documentation, code reviews, and understanding project structure at a glance.

## Requirements

### Essential
- **Python 3.x**
- **pyreverse** (included in `pylint` package)

```bash
pip install pylint
```
### Optional (for PNG and PDF formats)
- **Graphviz** - Required for PNG and PDF generation

**Ubuntu/Debian:**
```bash
sudo apt-get install graphviz
```

**macOS:**
```bash
brew install graphviz
```

**Windows:**
```bash
choco install graphviz
```
## Installation

### Cloning the repository
Before installing the tool, start by cloning the GitHub repository : 

```bash
git clone https://github.com/JRosierIGN/PyDUS.git
cd PyDUS
```

### Global installation (recommended)

```bash
# Make the script executable
chmod +x pydus.sh

# Install globally
sudo cp pydus.sh /usr/local/bin/pydus
```

Now you can use `pydus` from anywhere in your system.

### Local installation (without sudo)

```bash
# Create local bin directory if it doesn't exist
mkdir -p ~/.local/bin

# Copy and make executable
cp pydus.sh ~/.local/bin/pydus
chmod +x ~/.local/bin/pydus

# Add to PATH (add this line to ~/.bashrc or ~/.zshrc)
export PATH="$HOME/.local/bin:$PATH"

# Reload your shell configuration
source ~/.bashrc  # or source ~/.zshrc
```

## Usage

### Basic syntax

```bash
pydus <source_directory> <output_directory> [format]
```

### Arguments

- `source_directory` - Root directory containing .py files to analyze
- `output_directory` - Directory where generated diagrams will be saved
- `format` - (Optional) Output format: `svg`, `png`, `dot`, or `pdf` (default: `svg`)

### Examples

**Generate SVG diagrams (default):**
```bash
pydus ./my_project ./docs/uml
```

**Generate PNG diagrams:**
```bash
pydus ./my_project ./docs/uml png
```

**Generate PDF diagrams:**
```bash
pydus ./my_project ./docs/uml pdf
```

**Generate DOT files for custom processing:**
```bash
pydus ./my_project ./docs/uml dot
```

**Get help:**
```bash
pydus --help
```

## Output Formats

| Format | Extension | Description | Graphviz Required |
|--------|-----------|-------------|-------------------|
| **svg** | `.svg` | Scalable Vector Graphics (recommended) | No |
| **png** | `.png` | Portable Network Graphics (raster) | Yes |
| **pdf** | `.pdf` | Portable Document Format | Yes |
| **dot** | `.dot` | Graphviz DOT format for further processing | No |

## Project Structure Example

### Input structure
```
my_project/
├── models/
│   ├── user.py          # Contains User class
│   ├── product.py       # Contains Product class
│   └── __init__.py      # Automatically skipped
├── utils/
│   ├── helpers.py       # Contains Helper class
│   └── config.py        # No class - skipped
└── main.py              # No class - skipped
```

### Output after running `pydus ./my_project ./uml_output svg`
```
uml_output/
├── user.svg
├── product.svg
└── helpers.svg
```

## What Gets Processed

### Included
- Python files (`.py`) containing one or more class definitions
- Files in subdirectories (recursive scan)
- All class types (regular classes, abstract classes, dataclasses, etc.)

### Excluded
- `__init__.py` files
- Python scripts without class definitions
- Non-Python files

## Diagram Content

Each generated diagram includes:
- Class names
- Attributes with type annotations
- Methods with parameters and return types
- Inheritance relationships
- Access modifiers (public, private, protected)
- Class relationships (associations, compositions)