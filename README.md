Windows Cursor Hider
====================

Although Windows already has an option to hide the mouse cursor whilst typing, which can be found under Control Panel/Mouse, this is respected on a 'per application' basis.

Unfortunately, many applications, such as Visual Studio, do not respect this setting, and leave the mouse cursor visible whilst typing.

This can be quite annoying, as one tends to type exactly where one clicked, i.e., where the mouse cursor currently is, and especially in the case of developers, the IDE is particularly rich, meaning that the mouse cursor will normally also activate tooltips related to the item they are hovering over.

This is a small script written and compiled using AutoHotKey that hides the windows cursor when a user starts typing any alphanumeric (and certain coding-related) characters except when pressing shortcut key combination with Ctrl, Alt and Win modifier keys, and shows it again as soon as a mouse movement is detected.




Forked from https://github.com/Stefan-Z-Camilleri-zz/Windows-Cursor-Hider

Add modifier keys exception.
