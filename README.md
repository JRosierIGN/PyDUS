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
