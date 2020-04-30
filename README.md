# ShiVaWebGLLauncher
This small tool converts ShiVa 2.0 HTML5/WebGL exports into pseudo desktop apps by using the various app and kiosk modes of modern desktop browsers.

## Compatibility
* unix-like OS (Linux, FreeBSD, etc.)
* Google Chrome with --app mode
* Chromium with --app mode
* Firefox > v.70
* WebGL enabled, 3D hardware acceleration with proper drivers

## How to package your game
0. Export an HTML5/WebGL game from ShiVa 2.0
1. Download this project and unpack
2. Copy the `dist` folder into a new location
3. Copy your ShiVa 2.0 WebGL game files into `dist/game`
4. Modify the files in `dist/launcher` to fit your game
5. Make `run.sh` executable (`chmod +x`)

## Video
Watch on youtube: https://www.youtube.com/watch?v=QhrFf9ATcsU

## Known issues and limitations
* Some effects and engine features do not work on the WebGL engine yet
* Chrome/Chromium PID detection only works if the browser is not running when launching the game.
* Firefox kiosk mode is slower than Chrome/Chromium app mode and only supports fullscreen
* certain browser hotkey combos can disrupt the experience, like Alt+left/right cursor

## Screenshots
![launcher default screen](screenshots/s1.png)
