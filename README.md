# 🎡 PrizeWheel — Built with Claude Code + Xcode

A fully custom SwiftUI prize wheel built from scratch using Claude Code and Xcode's built-in Claude agent. Custom items, colours, spin animation, SwiftData persistence, win history, and haptics.

Built on the [NoahDoesCoding YouTube channel](https://www.youtube.com/@NoahDoesCoding97) as a prompting strategy demonstration — every prompt is documented below.

---

## 📺 Watch the Build

[![Watch on YouTube](https://img.shields.io/badge/YouTube-Watch%20the%20Build-red?style=for-the-badge&logo=youtube)](https://www.youtube.com/@NoahDoesCoding97)

**Prerequisites — watch these first:**
- [CLAUDE.md Masterclass](https://youtu.be/0UaqjKb3QHM)
- [Xcode Agentic Coding](https://youtu.be/t8UXKifcLXQ)
- [Claude Skills in Xcode — Paul Hudson](https://youtu.be/nKVZBKoB6P4?si=5PWyYrmLDe37g5uC)

---

## ✨ Features

- Custom prize wheel drawn with SwiftUI Canvas
- Add, edit, and delete wheel items with custom names and colours
- Realistic deceleration spin animation with haptic feedback
- Winner calculation with live wedge highlight
- SwiftData persistence — wins tracked across launches
- Win history grouped by item with total counts
- Live wheel preview while editing items

---

## 🚀 Getting Started

### 1. Clone the Repo

```bash
git clone https://github.com/NDCSwift/REPO-NAME.git
cd REPO-NAME
```

Or select **Clone Git Repository…** when Xcode launches.

### 2. Open in Xcode

Double-click the `.xcodeproj` file.

### 3. Set Your Development Team

Navigate to **Target → Signing & Capabilities → Team** and select your personal or organisation team.

### 4. Update the Bundle Identifier

Change `com.example.PrizeWheel` to a unique identifier — e.g. `com.yourname.PrizeWheel`.

### 5. Run

Select a simulator or connected device and hit **Run**. iOS 17+ required.

---

## 🧠 The Prompting Strategy

This project was built using three rules applied across 8 sequential prompts:

**Rule 1 — Context before code.** Brief the agent on the full scope before any output is generated.

**Rule 2 — One job per prompt.** UI separate from logic. Models separate from views. Mistakes stay small and fixes stay surgical.

**Rule 3 — Generate, review, redirect.** Read the output. Test it. Tell the agent specifically what's wrong — not just "fix it."

---

## 📋 All 10 Prompts

[→ View the full Gist with all prompts](https://gist.github.com/NDCSwift/3dd5b6397fc165dd3aa817d003188bf5)

---

## 🗂 Project Structure

```
PrizeWheel/
├── Models/
│   ├── WheelItem.swift
│   ├── WheelItem+Defaults.swift
│   └── WinRecord.swift
├── ViewModel/
│   └── WheelViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── PrizeWheelView.swift
│   ├── WheelItemsView.swift
│   ├── AddEditItemView.swift
│   └── WinHistoryView.swift
├── Extensions/
│   └── Color+Hex.swift
└── PrizeWheelApp.swift
```
---

## 📦 Requirements

- Xcode 15+
- iOS 17+
- No third-party dependencies
