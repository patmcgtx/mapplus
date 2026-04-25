# Map Plus: iOS Maps With Less Noise

[Apple Maps](https://maps.apple.com) is a pretty great map app. It's beautiful, responsive, and useful.  but it's doing a lot.

Built on Apple's maps stack, Map Plus does _less_ to make things are _easier_ for you. 

## Map Plus allows you to basically do two things:

### Add your own places to the map

Build your own world with exactly the places you care about.

Each place has a name, notes, and an icon that you pick.

### Organize your places into categories to be shown or hidden on the map.

Narrow your map's focus to your favorite coffee shops, restaurants to try, dream vacation destinations, late night haunts, whataver you want.

## Everything else is just frosting on the cake

### Themes for the visual pop you want

Match the map  to your vibe.

* Cupertino to look like standard iOS app
* 8-bit for a retro arcade flair
* Flamingo for a a beachy pink vibe
* Kerby for a hometown Austin flair
* Or add your own (with an upgrade)

### Movable buttons

Many of the buttons appear on the lower-right part of the screen by default.  

Are you left-handed?  Prefer the button on the bottom of the screen?  Just move the buttons wherever you want them.

## Tech notes

This app was coded in Swift and SwiftUI _mostly_ by hand as a learning exercise on the latest and greatest way to make apps with SwiftUI and SwiftData.

AI (Copilot and Claude) were used _occasionally_ as an assistant, mostly to run some spikes, iterate on experimental ideas, fix some bugs, and review PRs.

I wanted this app to be a hands-on experience where I got to experiment with ideas personally, so I left _most_ of the coding to myself.

### Architecture

In the experimental spirit, I'm playing with a few architectural ideas in this app.

I've tried some views in classic MVVM with SwiftUI.

In places where it makes more sense, I'm fully embracing SwiftData as an app-wide, reactive, persistent state to keep things super simple and responsive. While this approach breaks with traditional MVVM, I am tyring to answer the question: is there any down side for an app like this?
