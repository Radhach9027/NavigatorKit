# 🧭 NavigatorKit

**NavigatorKit** is a modular, type-safe navigation and deep-linking framework for SwiftUI.
It provides a generic way to handle navigation flows, parameter passing, and route registration across features — ideal for **clean, modular architectures**.

---

## ✨ Features

- ✅ **Universal navigation coordinator** — for both push and modal flows
- ✅ **Deep link handler** with automatic parameter type inference
- ✅ **Type-safe route model** (`RouteParam`, `Route`, `RouteSource`)
- ✅ **Support for dynamic parameters & Codable payloads**
- ✅ **Modular registration** for each feature via `RouteRegistrar`
- ✅ **Presentation styles:** `.push`, `.sheet`, `.fullScreen`, `.modal`
- ✅ **Works with iOS 15+** and SwiftUI’s `NavigationStack`

---

## 🧩 Architecture Overview

```
NavigatorKit/
 ├── Core/
 │    ├── Route.swift              # Route + RouteParam definitions
 │    ├── RouteRegistry.swift      # Shared registry for all routes
 │    ├── RouteRegistrar.swift     # Register feature routes
 │    ├── RoutableFeature.swift    # Protocol for feature navigation
 │    ├── NavigationCoordinator.swift
 │    ├── DeepLinkHandler.swift
 │    ├── PresentationStyle.swift
 │    └── RouteParams.swift        # Typed parameter helpers
 └── SwiftUI/
      └── NavigationHost.swift     # Entry host with sheet/fullscreen handling
```

---

## 🚀 Quick Start

### 1️⃣ Create a `NavigationCoordinator`

```swift
import NavigatorKit
import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    let navigator = NavigationCoordinator()

    func openHotelDetail() {
        navigator.navigate(
            path: "/hotel/details",
            params: ["id": .string("H001"), "rating": .double(4.9)],
            presentation: .push
        )
    }
}
```

---

### 2️⃣ Use the Coordinator with `NavigationHost`

```swift
struct RootView: View {
    @StateObject private var coordinator = NavigationCoordinator()

    var body: some View {
        NavigationHost(coordinator: coordinator) {
            VStack {
                Button("Go to Hotel Details") {
                    coordinator.navigate(
                        path: "/hotel/details",
                        params: ["id": .string("H001"), "rating": .double(4.8)],
                        presentation: .push
                    )
                }
            }
        }
    }
}
```

---

### 3️⃣ Register Routes per Feature

```swift
import NavigatorKit
import SwiftUI

struct HotelRoutes: RouteRegistrar {
    static func register() {
        RouteRegistry.shared.register(path: "/hotel/details") {
            HotelDetailView()
        }
    }
}
```

Call this in app setup:
```swift
HotelRoutes.register()
```

---

## 🔗 Deep Link Support

```swift
if let route = DeepLinkHandler.shared.handle(
    url: URL(string: "bookify://hotel/details?id=42&name=Sunrise&rating=4.9")!
) {
    coordinator.navigate(to: route)
}
```

✅ Automatically infers types:
```swift
route.int("id")       // 42
route.string("name")  // "Sunrise"
route.double("rating") // 4.9
```

---

## 💾 Route Model Example

```swift
public struct Route: Codable, Hashable, Identifiable {
    public var id: String { path }
    public let path: String
    public let params: [String: RouteParam]?
    public let source: RouteSource
    public let presentation: PresentationStyle
}
```

### `RouteParam` Supports:
- `.string(String)`
- `.int(Int)`
- `.double(Double)`
- `.bool(Bool)`
- `.object(Data)` (Codable JSON)

---

## 🧠 Type-Safe Access

```swift
if let hotelId = route.string("id") {
    print("Hotel ID: \(hotelId)")
}

if let hotel: Hotel = route.decode("hotel", as: Hotel.self) {
    print("Hotel: \(hotel.name)")
}
```

---

## 🧪 Unit Tests (Swift 5.9 `Testing` Framework)

`NavigatorKit` ships with complete unit coverage for:

| Test | Description |
|------|--------------|
| `RouteParam` | Codable roundtrip for all cases |
| `DeepLinkHandler` | Type-safe URL parsing |
| `Route` | Equality, Codable conformance |
| `Boolean edge cases` | yes/no, 1/0, true/false |
| `Invalid URLs` | Safe fallback handling |

Example:

```swift
@Test("DeepLinkHandler parses correctly")
func testDeepLink() {
    let url = URL(string: "bookify://hotel?id=101&active=yes")!
    let route = DeepLinkHandler.shared.handle(url: url)
    #expect(route?.int("id") == 101)
    #expect(route?.bool("active") == true)
}
```

---

## ⚙️ Requirements

- **iOS:** 15.0+
- **Swift:** 5.9+
- **Framework:** SwiftUI, Combine

---

## 📦 Integration (SPM)

Add this to your `Package.swift`:

```swift
.package(url: "https://github.com/Radhach9027/NavigatorKit.git", from: "1.0.0")
```

Then import:

```swift
import NavigatorKit
```

---

## 🧭 Example Project Structure

```
BookifyApp/
 ├── App/
 │    ├── BookifyApp.swift
 │    ├── RootView.swift
 │    └── AppCoordinator.swift
 ├── Features/
 │    ├── Hotels/
 │    │    ├── HotelDetailView.swift
 │    │    ├── HotelRoutes.swift
 │    │    └── HotelViewModel.swift
 │    └── Profile/
 │         ├── ProfileView.swift
 │         └── ProfileRoutes.swift
 └── Packages/
      └── NavigatorKit/
```

---

## 💡 Best Practices

- ✅ Keep feature routes isolated via their own `RouteRegistrar`
- ✅ Never reference feature code inside `NavigatorKit`
- ✅ Use `Codable` models for parameter passing
- ✅ Register all routes once during app launch
- ✅ Handle deep links via `SceneDelegate` or `onOpenURL`
- ✅ Prefer `.object(Data)` for complex payloads

---

## 🧱 License
MIT License © 2025
Crafted for modular SwiftUI architectures.

