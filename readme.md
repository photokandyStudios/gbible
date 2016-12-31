# Greek Interlinear Bible for iOS v1.4

*NOTE*: App store link: http://itunes.apple.com/us/app/greek-interlinear-bible/id520000138?mt=8

Project code for the Greek Interlinear Bible for iOS. This code is COPYRIGHT (C) 2012 - 2016 photoKandy Studios LLC.
Portions of the code are under different licenses, see https://github.com/photokandyStudios/gbible/wiki/Third-Party-Components.

## Changes 

### 1.4

 * Support for 4.7" and 5.5" screens... finally!

 * Support for 12.9" iPad Pro -- finally!

 * Support for split-view multitasking

 * iOS 8 is now the minimum supported version -- sorry to any users < iOS 8.

 * Full screen removed (no real need)

 * Tint color correct

 * Theme now properly changes navigation bar without requiring restart

 * Revamped layout & settings

 * Switched to size classes instead of UI Idioms

 * Removed dependency on Parse for downloading content


#### Known Issues

 - export/import

 X strongs / search has white nav bar

 X strongs / search should layout after size class changes

 x popovers show white fringes in dark theme

 x need attributions

 x inject color into bible view web view

 x proper iOS7+ download button -- maybe move to upper right navbar instead (yes)

 x Search includes OT results if avail in book

 - help (maybe videos?)



 v Note view scrollable portion is incorrect with hardware keyboard

 ^ no keyboard shortcut control overlay nor response

 v Add simple bible to note editor?

 v Make editor rich text?

 ? HUD is not centered when viewport != screen


## FAQ

### Why are the assets and Bible Database missing?

It is unfortunate that people would take the code and re-release it on the app store while replacing the attribution required. As such, I've told Git to ignore the graphical assets, as they are not covered under the license. While easy to circumvent, hopefully it will convince such unscrupulous developers to look elswhere. Furthermore, removing the Bible Database further complicates matters -- it is trivial to reconstruct, but difficult enough to dissuade unscrupulous developers. For legitimate development information, see: https://github.com/photokandyStudios/gbible/wiki/Bible-Database and https://github.com/photokandyStudios/gbible/wiki/Missing-Assets.

## Attributions

For attributions regarding the texts utilized, see https://github.com/photokandyStudios/gbible/wiki/Data-Sources.

## License

The code that is not otherwise licensed and is owned by photoKandy Studios LLC is hereby
licensed under a CC BY-NC-SA 3.0 license. That is, you may copy the code and use it for 
non-commercial uses under the same license. For the entire license, see http://creativecommons.org/licenses/by-nc-sa/3.0/.

Furthermore, you may use the code in this app for your own personal or educational use. However you may **NOT** release a competing app on the App Store without prior authorization and significant code changes. If authorization is granted, attribution must be kept, but you must also add in your own attribution. You must also use your own API keys (TestFlight, Parse, etc.) and you much provide your own support. As the code is released for non-commercial purposes, any directly competing app based on this code must not require payment of any form (including ads).

*NOTE*: The graphical assets are not covered under the above license. They are copyright their respective owners.

The following developers are excluded from the above license, by virtue of previous infringement, and the exclusions are retroactive:

 * The developer named Wang Ting (and any other aliases) is hereby denied license to use any of this code without prior authorization. This is in response to the unauthorized release of a copy of this application on the App Store in December 2012 under the names "Bible : Greek Interlinear Bible Free" and "Bible : Greek Interlinear Bible". The first is ad-supported, which clearly goes against the non-commercial clause of the license. The second is not free, which also goes against the non-commercial license. In both cases, attribution has been changed to the developer, and so the license is again ingringed. Finally, the app uses the graphical assets as provided, again a clear infringment as these are not licensed under the code license.
 * The developer named duduBear (and any other aliases) is hereby denied license to use any of this code without prior authorization. This is in response to the unauthorized release of a copy of this application on the App Store in September 2012 under the names "bible [English and Greek]" and "bible HD [English and Greek]". Both are not free, which goes against the non-commercial license. Finally, the app uses the graphical assets as provided, again a clear infringment as these are not licensed under the code license.

