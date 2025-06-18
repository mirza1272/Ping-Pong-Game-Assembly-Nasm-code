# Ping-Pong-Game-Assembly-Nasm-code

### **📌 Description**  
A classic **Ping Pong (Pong)** game built in **x86 Assembly Language** for **DOS**. This project features two-player paddle controls, realistic ball physics, and a retro text-mode interface.  

---

## **🎮 Features**  
✔ **Two-Player Mode** – Compete against a friend  
✔ **Custom Player Names** – Enter names before starting  
✔ **Score Tracking** – First to **6 points** wins  
✔ **Pause/Resume** – Press **'9'** to toggle game state  
✔ **Realistic Physics** – Ball bounces at different angles  
✔ **Keyboard Controls** – Intuitive paddle movements  

---

## **🛠️ Technical Details**  
- **Written in:** x86 Assembly  
- **Platform:** DOS (Compatible with **DOSBox**)  
- **Graphics:** Text-mode display with colored characters  
- **Input Handling:** BIOS keyboard interrupts  
- **Collision Detection:** Paddles, walls, and scoring  

---

## **🎯 How to Play**  
1. **Run** the game in **DOSBox** or a DOS environment.  
2. **Enter Player Names** when prompted.  
3. **Controls:**  
   - **Player 1 (Left Paddle):**  
     - **↑ (Up Arrow)** – Move up  
     - **↓ (Down Arrow)** – Move down  
   - **Player 2 (Right Paddle):**  
     - **W** – Move up  
     - **S** – Move down  
4. **Game Controls:**  
   - **9** – Pause/Resume  
   - **ESC** – Exit Game  

---

## **⚙️ Installation**  
1. **Assemble** the code using **NASM**:  
   ```sh
   nasm pingpong.asm -o pingpong.com
   ```
2. **Run** in DOS/DOSBox:  
   ```sh
   pingpong.com
   ```

---

## **📜 Game Mechanics**  
- Ball **speeds up slightly** after each hit.  
- **Angle changes** based on where the ball hits the paddle.  
- **First to 6 points wins.**  
- **Wall & paddle collisions** with visual feedback.  

---

## **🚀 Future Improvements**  
🔹 **Single-Player Mode** (AI Opponent)  
🔹 **Difficulty Levels** (Easy, Medium, Hard)  
🔹 **Sound Effects** (Ball hits, scoring)  
🔹 **High Score System**  

---

## **👨‍💻 Developer**  
- **Haseeb ur Rahman** (23F-0566)  

---

## **📜 License**  
This project is licensed under the **MIT License**.  

---

### **🎉 Enjoy the Game!**  
Relive the classic **Ping Pong** experience in pure **Assembly**! Perfect for retro gaming fans and low-level programming enthusiasts.  

🚀 **Play now and challenge your friends!** 🚀
