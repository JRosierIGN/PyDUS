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
