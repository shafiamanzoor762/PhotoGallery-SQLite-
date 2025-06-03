

# 📸 PhotoGallery iOS App

A smart photo gallery application built using **SwiftUI** and **SQLite**.

[![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS-blue?logo=swift)](https://developer.apple.com/xcode/swiftui/)
[![SQLite](https://img.shields.io/badge/SQLite-Integrated-lightgrey?logo=sqlite)](https://github.com/stephencelis/SQLite.swift?tab=readme-ov-file)
[![Platform](https://img.shields.io/badge/Platform-iOS-lightblue?logo=apple)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 🧠 Overview

**PhotoGallery** is a modern iOS photo management app that automatically categorizes images based on:

* 🧍 Person *(via face recognition)*
* 🎉 Event *(from metadata)*
* 📍 Location *(via geotags)*
* 📅 Date *(from image metadata)*

With smart grouping and search features, navigating your photo library becomes seamless and intuitive.

---

## 🚀 Getting Started

### ✅ Requirements

Before you begin, ensure you have the following:

* Xcode 15 or later
* macOS 13 or later
* iOS 16+ simulator or device
* CocoaPods (if using external dependencies)
* Swift 5.9+

---

## 🛠 Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/shafiamanzoor762/PhotoGallery-SQLite-.git
cd PhotoGallery-SQLite-
```

### Step 2: Open in Xcode

* Open `PhotoGallery.xcodeproj` or `PhotoGallery.xcworkspace` in Xcode.
* Select the target device (iOS Simulator or real device).

### Step 3: Build and Run

* Hit `Cmd ⌘ + R` or click ▶️ to build and launch the app in your selected simulator/device.

---

## 📂 Project Structure

```markdown
PhotoGallery-iOS/
├── CustomComponents   # Common Views
├── Helper/           # Utility extensions Api Integration and SQLite service
├── Model/            # Data models (e.g., Image, Event, Person)
├── Views/             # SwiftUI Views
      └── ViewModels/        # ObservableObjects for binding logic
```

---

## 💡 Features

* 🔍 **Smart Search** — Search images by person, event, location, or date.
* 🧠 **Face Recognition** — Group photos by detected individuals.
* 🗃 **Metadata Tagging** — Uses EXIF data for events, time, and location.
* 🧭 **SQLite Integration** — Efficient and lightweight local storage.

---

## 🧪 Modifying the App

Open any SwiftUI file (e.g., `ContentView.swift`) and make your changes.
Use the **Preview Canvas** (`Option + Cmd + P`) for real-time updates, or rebuild using `Cmd + R`.

---

## 🛠 Technologies Used

| Technology   | Description                           |
| ------------ | ------------------------------------- |
| `SwiftUI`    | Declarative UI framework for iOS apps |
| `SQLite`     | Local embedded database engine        |
| `Core Image` | Face recognition and image analysis   |
| `MapKit`     | Location-based features               |
| `EXIFParser` | For image metadata extraction         |

---

## 🐛 Troubleshooting

* ❗**App won’t build?**

  * Clean Build Folder: `Shift + Cmd + K`
  * Restart Xcode and simulator.
* 📷 **Face recognition not grouping?**

  * Ensure photos have recognizable faces.
* 📍 **No location tag?**

  * Check image metadata.

---

## 📘 Learn More

* [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
* [SQLite for iOS](https://www.sqlite.org/index.html)
* [Face Detection in Python](https://www.datacamp.com/tutorial/face-detection-python-opencv)

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.
Follow best practices for SwiftUI architecture and file naming conventions.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## ✨ Acknowledgments

* Apple Developer Resources
* SQLite.org
* Swift Forums
* Stack Overflow Community

---
