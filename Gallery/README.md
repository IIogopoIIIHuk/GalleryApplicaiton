# GalleryApp

🖼 iOS image gallery app built with **UIKit**.   

---

## Project Overview

GalleryApp is an image gallery application that loads pictures from the **Unsplash API**, provides a detail view, and allows users to manage their favorite photos.  
The app is built with **MVVM** and clear separation of layers (**Domain / Data / Presentation**).  
It uses **Alamofire** for networking, **Kingfisher** for image caching and smooth transitions, and **RealmSwift** for local persistence.  

---

## Features 

### 1. Gallery Screen
- [x] Grid layout (UICollectionView) loading images from Unsplash API.  
- [x] Pagination when scrolling.  
- [x] Tap on an image → navigate to the detail screen.  
- [x] Favorites indicator on thumbnails.  

### 2. Detail Screen
- [x] Full-size image view.  
- [x] Pinch-to-zoom for closer inspection.  
- [x] Display additional data: author (name, username) and image description.  
- [x] Heart button to mark/unmark as favorite.  
- [x] Swipe navigation between images.  
- [x] Ability to leave personal notes for each image (persisted in Realm).  
- [x] Share image using the system share sheet.  

### 3. Networking
- [x] Unsplash API (`/photos`, 30 items per request).  
- [x] Alamofire for network requests.  
- [x] Asynchronous loading and error handling.  

### 4. Persistence
- [x] Favorites stored in Realm.  
- [x] Personal notes stored locally for each image.  
- [x] Favorites and notes are preserved after app restart.  

### 5. UI/UX
- [x] Clean and intuitive grid layout.  
- [x] Kingfisher for caching and smooth fade-in transitions.  
- [x] Support for different screen sizes.  
- [x] Animated splash screen.  

### 6. Architecture / Code Quality
- [x] MVVM with clear separation between Domain/Data/Presentation.  
- [x] Business logic moved into UseCases and ViewModels.  
- [x] Git history follows Conventional Commits.  

---

## Additional Features

- 🟢 **Animated Splash Screen** with custom animation.  
- 🟢 **Notes for each favorite** (persisted with Realm).  
- 🟢 **Image description** displayed on the detail screen.  
- 🟢 **Pinch-to-zoom** in detail view.  
- 🟢 **Image sharing** via system share sheet.  
- 🟢 **Enhanced UI/UX**: fade-in transitions, loading indicators.  

---
