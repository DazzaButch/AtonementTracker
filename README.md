# Atonements-Tracker  

A high-performance, taint-safe icon tracker for Discipline Priests in World of Warcraft: Midnight.  

**Version 1.1.0**  

## Features
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
