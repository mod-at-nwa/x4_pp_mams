To extract CAT/DAT files from *X4: Foundations* for modding on Arch Linux, the most straightforward and native option is a Python-based tool called **Xtract**, which is a modern, reworked CAT extractor available on GitHub. It's lightweight, cross-platform (including Linux), and specifically designed for this purpose. It unpacks files from `.cat`/`.dat` pairs in the game's data directory, with options to filter by file type (e.g., XML, Lua) to avoid dumping everything at once.

### Prerequisites on Arch Linux
- Ensure Python 3.8+ is installed (it's usually pre-installed or available via `sudo pacman -S python`).
- Install the `rich` library (used for formatted output):  
  ```
  pip install rich
  `````
  (If you prefer system-wide, use `sudo pacman -S python-rich` if available, or stick with pip.)

### Installation and Setup
1. Clone or download the Xtract repository:  
   `````
   git clone https://github.com/RPINerd/Xtract.git
   cd Xtract
   `````
   (Or download `xtract.py` directly from the repo if you don't want the full clone.)

2. Locate your *X4: Foundations* installation directory. For a Steam install, it's typically:  
   `````
   ~/.local/share/Steam/steamapps/common/X4 Foundations
   `````
   (Adjust if installed elsewhere, e.g., via Lutris or flatpak.)

### Usage
Run the script with Python, pointing it to your game's data folder (where the `.cat` and `.dat` files live) and an output directory. Basic syntax:  
`````
python xtract.py <source_directory> <destination_directory> [options]
`````

#### Examples
- Extract all default file types (XML, XSD, HTML, JS, CSS, Lua) from the main game data to a new folder called ```extracted`:  
  ```
  python xtract.py "/home/yourusername/.local/share/Steam/steamapps/common/X4 Foundations" ./extracted
  `````

- Extract only XML and Lua files, and only from specific CAT files (e.g., 01.cat and 02.cat):  
  `````
  python xtract.py "/home/yourusername/.local/share/Steam/steamapps/common/X4 Foundations" ./extracted -i 01.cat 02.cat -t xml,lua
  `````

- Enable verbose logging for debugging:  
  `````
  python xtract.py <source> <dest> -v
  `````

The tool will create subfolders in your destination directory mirroring the CAT structure (e.g., `extracted/01/` for files from 01.cat). It auto-detects expansions if present (use `-e` to force it).

### Tips for Modding
- Start with just the core CAT files (like 01.cat–05.cat) to test—full extraction can produce thousands of files.
- After extraction, edit files (e.g., XMLs) with a text editor like VS Code (`sudo pacman -S code`), then repack into a mod's ```.cat`/`.dat` using the same tool or the official X Catalog Tool (see below if needed).
- If your path has dots (common in Steam installs), this tool handles it better than older scripts.

### Alternative: Official X Catalog Tool via Proton (If You Prefer a GUI)
If you want the official Egosoft tool (XRCatTool, which has a GUI), it's Windows-only but runs fine on Linux via Steam Proton:
1. In Steam, go to **Library > Tools**, search for "X Tools" (or "X Catalog Tool"), and install it.
2. Enable Proton for it: Right-click the tool > Properties > Compatibility > Force the use of a specific Steam Play compatibility tool (e.g., Proton Experimental).
3. Launch it through Steam, point it to your game directory, and extract as needed.  
   This works reliably on Arch but requires Wine/Proton setup (`sudo pacman -S wine` if not using Steam).

### Older Fallback Script (If Xtract Doesn't Suit)
There's a simpler Python script on a GitHub Gist that's Linux-friendly but less feature-rich. Download `unpack.py` from the Gist, fix a path-handling bug for Steam installs (replace `file.split(".")[0]` with `file.rsplit(".", 1)[0]` around line 50), then run:  
```
python unpack.py "/path/to/game/dir" "/path/to/output" -f "^.*(xml|xsd|html|js|css|lua)$"
`````

For more modding resources, check the Egosoft forums or Nexus Mods X4 section. If you hit issues (e.g., with expansions or repacking), provide details for troubleshooting!````
