# Atonements-Tracker  

A high-performance, taint-safe icon tracker for Discipline Priests in World of Warcraft: Midnight. 

**Version 1.1.3**
- **Added:** Added a slider to adjust the X & Y axis of the center text..
- **Added:** Colour to the timer text.

**Version 1.1.2**
- **Dark Overlay:** Added a slider to adjust icon darkness for better text contrast.
- **Custom Icon Support:** Enter any Spell ID from Wowhead to change the tracker icon.
- **Settings Persistence:** Fixed an issue where UI changes would reset on logout.
- **UI Alignment:** Nudged central text and added corner insets for a cleaner look.

**Version 1.1.1**
- **Code Changes:** Code and name changes to match CurseForge

**Version 1.1.0**
- **Taint-Safe Logic:** Specifically designed to avoid the "Secret Number" crash and UI errors in instances and raids using manual aura looping and pcall protection.
- **Group Aware:** Tracks Atonement across yourself, target, focus, party, and raid members.
- **Whole-Second Timer:** High-contrast white timer showing whole seconds for better readability during intense combat.
- **Performance Control:** User-adjustable scan interval to balance responsiveness with CPU usage in large raid environments.
- **Customizable UI:** Use `/at` to change icon size, opacity, and font size.

## Commands
- `/at` - Open the configuration window.

## Performance & Compatibility
- **Update Rate:** Adjustable from 0.1s to 1.0s. The default 0.2s is recommended for a smooth balance between accuracy and performance.
- **Midnight Ready:** Built to handle the specific UI changes and security constraints introduced in WoW 12.0.
