Windows Cursor Hider
====================

*Hide Mouse Cursor on Idle.ahk*
*Hide mouse cursor when typing, and show it back when moving mouse.*
*Forked from https://github.com/Stefan-Z-Camilleri-zz/Windows-Cursor-Hider*
hzhbest -- Add modifier keys exception, .

====================

【重构版】 打字隐藏鼠标指针.ahk
====================

重构版，（以原版脚本为基础？）结合微软资料（winuser.h相关）和AI（Hunyuan & Gemini）重新编写的脚本，使用句柄取代简单图像提取，实现功能：
- 打字时隐藏鼠标指针（cursor）（原版功能）
- 忽略修饰键如 Ctrl 、 Alt 、Win 键（修改版功能）
- 鼠标指针隐藏和恢复时显示小提示
- 可恢复原动画指针（修复原版bug）
- 可通过托盘菜单禁用
