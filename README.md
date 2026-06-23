# Map Plus: iOS Maps With Less Noise

[Apple Maps](https://maps.apple.com) is a pretty great map app. It's beautiful, and it's useful. But it's doing a lot.

Built on Apple's native MapKit, Map Plus is a lighter, more personalized map companion with some fun twists.

## Map Plus allows you to do two things:

### Add your own places to the map

Build your own world with exactly the places you care about.

Each place has a name, notes, and an icon that you pick.

### Organize your places into categories to be shown or hidden on the map

Narrow your map's focus to your favorite coffee shops, restaurants to try, dream vacation destinations, late night haunts, whatever you want.

## Polish & personalization

Frosting on the cake.

### Themes for the visual pop you want

Match the map to your vibe.

* Cupertino to look like standard iOS app
* 8-bit for a retro arcade flair
* Flamingo for a beachy pink vibe
* Kerby for an Austin flair
* Or add your own (with an upgrade)

### On-device AI assistance

On-device AI (Apple Foundation Models) helps provide meaningful defaults for a new location, namely its emoji and (if requested) its descriptive notes. Your favorite coffee shop will likelt get a "☕️" for its emoji.

### Movable buttons

Many of the buttons appear on the lower-right part of the screen by default.  

Prefer the buttons on the bottom or left-hand side of the screen? Just drag and drop the buttons wherever you want them.

### Fun animations

When you change your category selection, newly visible landmarks magically blink into place, and removed landmarks disappear with a poof.

## Tech notes

This app was coded in Swift and SwiftUI primarily by hand as a learning exercise on making modern iOS apps with SwiftUI and SwiftData.

AI tools helped accelerate spikes, refactors, code reviews, documentation, and test creation, all while letting me focus on hands-on learning.

### Architecture

In the experimental spirit, I'm playing with a few architectural ideas in this app.

* Fully embracing SwiftData and @AppStorage as an app-wide, reactive, persistent state to keep things super simple and responsive.
* Maintaining protocol-based, mockable services to support unit testing and SwiftUI previews.
* Injecting live vs. mock services using @Environment.
* Using traditional MVVM when the complexity justifies it.
* Leveraging Apple's location and mapping services, CoreLocation and MapKit.
* Employing on-device Apple Foundation Models AI when it makes sense for the user experience.

See [ARCHITECTURE.md](https://github.com/patmcgtx/mapplus/blob/main/MapPlus/ARCHITECTURE.md) for details.

## Status

The app is in development and not yet on the App Store.

### Demo

Here's [a video walkthrough of this app](https://youtu.be/AARBKyTHfYg) in development showing basic functionality, themes, dark mode vs. light mode, and on-device AI.

### Screenshots

Here's a preview showing the 8-bit and Flamingo themes in light mode vs. dark mode and landscape vs. portrait.

<img width="148" height="320" alt="IMG_7113" src="https://github.com/user-attachments/assets/206b0d1c-930d-467b-879a-6d2b0344eda3" />
<img width="148" height="320" alt="IMG_7110" src="https://github.com/user-attachments/assets/26e7ae98-f7d7-4d21-8938-6fb004475c73" />
<img width="148" height="320" alt="IMG_7108" src="https://github.com/user-attachments/assets/6801964a-b889-4d05-9a9d-92ec8c1c323b" />
<img width="148" height="320" alt="IMG_7106" src="https://github.com/user-attachments/assets/4a53ad19-c46d-4739-a0f8-1c1185dfea9a" />
<img width="148" height="320" alt="IMG_7100" src="https://github.com/user-attachments/assets/ef709562-7f76-4105-ba13-cd0208a837f8" />
<img width="148" height="320" alt="IMG_7099" src="https://github.com/user-attachments/assets/0dea62f7-5a06-4189-8446-7740c428b413" />
<img width="320" height="148" alt="IMG_7122" src="https://github.com/user-attachments/assets/6abfa62a-269c-4173-b4c4-89829f3e39fe" />
<img width="320" height="148" alt="IMG_7120" src="https://github.com/user-attachments/assets/1facc5ee-87ed-47f0-a513-03dfc5576ad4" />

