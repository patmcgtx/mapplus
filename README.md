# Map Plus: iOS Maps With Less Noise

[Apple Maps](https://maps.apple.com) is a pretty great map app. It's beautiful, and it's useful.  But it's doing a **lot**.

Built on Apple's maps stack, Map Plus does _less_ to make things _easier_ for you. 

## Map Plus allows you to basically do two things:

### Add your own places to the map

Build your own world with exactly the places you care about.

Each place has a name, notes, and an icon that you pick.

### Organize your places into categories to be shown or hidden on the map

Narrow your map's focus to your favorite coffee shops, restaurants to try, dream vacation destinations, late night haunts, whatever you want.

## Everything else is just frosting on the cake

### Themes for the visual pop you want

Match the map to your vibe.

* Cupertino to look like standard iOS app
* 8-bit for a retro arcade flair
* Flamingo for a beachy pink vibe
* Kerby for an Austin flair
* Or add your own (with an upgrade)

### Movable buttons

Many of the buttons appear on the lower-right part of the screen by default.  

Are you left-handed?  Prefer the button on the bottom of the screen?  Just move the buttons wherever you want them.

## Tech notes

This app was coded in Swift and SwiftUI primarily by hand as a learning exercise on the latest and greatest way to make apps with SwiftUI and SwiftData.

AI assistants (Copilot and Claude) were used occasionally for documentation, code reviews, to write tests, to iterate quickly on experimental ideas, to refactor, to fix some bugs, and for help when I get stuck.

### Architecture

In the experimental spirit, I'm playing with a few architectural ideas in this app.

* Fully embracing SwiftData and @AppStorage as an app-wide, reactive, persistent state to keep things super simple and responsive.
* Maintaining protocol-based, mockable services to support unit testing and SwiftU previews.
* Injecting live vs. mock services as needed Using @Environment.
* Using traditional MVVM when the complexity justifies it.
* Leveraging Apple's location and mapping services, CoreLocation and MapKit.
* Employing on-device Apple Foundation Models AI when it makes sense for the user experience.
  
See [ARCHITECTURE.md](https://github.com/patmcgtx/mapplus/blob/main/MapPlus/ARCHITECTURE.md) for details.
