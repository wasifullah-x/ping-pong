# 🏓 16-bit Ping Pong Game in Assembly

This is a simple **Ping Pong game** built using **16-bit x86 Assembly language**. It demonstrates low-level graphics manipulation, keyboard input handling, and real-time game logic using Assembly—designed for educational and nostalgic purposes.

---

## 📜 Table of Contents

- [Features](#features)  
- [Screenshots](#screenshots)  
- [Requirements](#requirements)  
- [How to Run](#how-to-run)  
  - [Option 1: Using Visual Studio Code (MASM/TASM Extension)](#option-1-using-visual-studio-code-masmtasm-extension)  
  - [Option 2: Using DOSBox](#option-2-using-dosbox)  
- [Controls](#controls)  

---

## 🧩 Features

- Real-time two-player paddle control  
- Ball movement and collision logic  
- Score tracking  
- Classic 16-bit DOS graphics (text/character-based or pixel-based depending on version)  
- Runs on real-mode x86 emulation

---

## 🖼️ Screenshots



---

## 🛠️ Requirements

### For VS Code (MASM/TASM extension):

- [Visual Studio Code](https://code.visualstudio.com/)  
- [MASM/TASM Extension](https://marketplace.visualstudio.com/items?itemName=maziac.masm-tasm)  
- MASM or TASM assembler (locally installed)  
- DOSBox or 8086 emulator (optional, for running binaries)

### For DOSBox:

- [DOSBox Emulator](https://www.dosbox.com/download.php?main=1)  
- TASM/MASM tools and your `.asm` and `.exe`/`.com` files  

---

## 🚀 How to Run

### Option 1: Using Visual Studio Code (MASM/TASM Extension)

1. **Install the Extension:**  
   Search for `MASM/TASM` in the VS Code Extensions Marketplace and install it.

2. **Configure the Assembler:**  
   Set up the path to MASM or TASM in your VS Code settings or in `tasks.json`.

3. **Open the Project Folder** and the `.asm` file.

4. **Assemble & Link:**  
   Use the extension commands (or custom build tasks) to assemble and link your code into a `.com` or `.exe`.

5. **Run the Binary:**  
   - Optionally, launch the output file in **DOSBox** from within VS Code.  
   - Or use a compatible emulator like `EMU8086`.

### Option 2: Using DOSBox

1. **Install DOSBox** if you haven’t already.

2. **Prepare Your Files:**  
   - Ensure you have the `.asm` source, assembler (TASM or MASM), and batch/script to build it (or a prebuilt `.com/.exe` file).

3. **Mount Your Project Folder in DOSBox:**  
   ```
   mount c c:\path\to\your\project
   c:
   ```

4. **Assemble & Link (if needed):**
   ```
   tasm pingpong.asm
   tlink pingpong.obj
   ```

5. **Run the Game:**
   ```
   pingpong.exe
   ```

---

## 🎮 Controls

- **Player 1:** `W` (up), `S` (down)  
- **Player 2:** `I` (up), `K` (down)  
- Press `ESC` to quit (if implemented)

---

