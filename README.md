![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![Platforms](https://img.shields.io/badge/Platforms-iOS-blue)
![SPM](https://img.shields.io/badge/SPM-Compatible-brightgreen)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

# PrettyLogs 🧾⚡️

**PrettyLogs** is a lightweight, production-ready logging SDK for iOS that helps you **capture, inspect, and debug HTTP and realtime events** (SignalR, Socket.IO, WebSockets) with **zero app-level wiring**.

Designed for:
- iOS developers
- SDKs & enterprise apps
- Debugging production issues safely

---

## ✨ Features

- 📡 Automatic HTTP network logging (URLSession)
- ⚡️ Realtime event logging (SignalR, Socket.IO, WebSockets)
- 🔐 API-key based authentication
- 🧠 App & environment metadata
- 🚫 Zero URL exposure in client apps
- 📦 Swift Package Manager ready
- 🛡️ Thread-safe & Swift Concurrency safe

---

## 🚀 Quick Start

```swift
import PrettyLogs

PrettyLogs.start(
    apiKey: "YOUR_API_KEY",
    environment: "debug"
)
```
## 🚀 Logger Types

- You can override the default logger type:
 ```swift
PrettyLogs.start(
    apiKey: "YOUR_API_KEY",
    environment: "production",
    loggerType: .realtime
)
```
  Available Logger Types:
 - http       // default – HTTP network logs
 - realtime   // realtime events only
 - none       // logging disabled
   
## 📦 Installation (Swift Package Manager)
  ### Using Xcode
1. Open **Xcode**
2. Go to **File → Add Packages**
3. Enter the repository URL:
   ```swift
    https://github.com/your-org/PrettyLogs
   ```
4. Select the latest version and add the package to your project

### Using `Package.swift`

```swift
.package(
 url: "https://github.com/your-org/PrettyLogs",
 from: "1.0.0"
)
```

## 🧪 Usage Examples
1️⃣ HTTP Logging (Automatic)

Nothing to implement.
Once PrettyLogs.start() is called, all URLSession requests are logged automatically.
```swift
URLSession.shared.dataTask(with: request).resume()
```

2️⃣ Realtime Logging (SignalR / WebSockets)
Use this inside your realtime layer (SignalR service, socket manager, etc).
 ```swift
PrettyLogs.realtime.log(
    transport: .signalR,
    direction: .outgoing,
    event: "SendMessage",
    payload: [
        "messageId": id,
        "receiverId": receiverId,
        "content": content
    ]
)
```
Incoming event example
``` swift
PrettyLogs.realtime.log(
    transport: .signalR,
    direction: .incoming,
    event: "ReceiveMessage",
    payload: [
        "senderId": senderId,
        "messageId": messageId
    ]
)
```
