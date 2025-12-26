; ==================================================
; 系统光标隐藏与恢复脚本（无外部文件，内存创建透明光标）
; + 托盘菜单开关（启用/禁用功能）
; 触发：主键盘字符键按下（字母、数字、符号键，允许Shift，不含Ctrl/Alt/Win）
; 恢复：鼠标移动超过阈值（10像素）
; 仅针对系统光标，忽略其他程序自定义光标
; ==================================================

#NoEnv
#SingleInstance Force
SetBatchLines, -1

; --- 配置 ---
threshold := 10          ; 鼠标移动恢复阈值（像素）
enabled := true          ; 初始启用光标隐藏功能

; --- 系统光标槽 OCR 常量（十进制）---
global CursorIDs := "32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650"
global OriginalHandles := {}

cursor_hidden := false
hiddenX := hiddenY := 0

; 创建透明光标（32x32 单色全透明）
blankCursorHandle := CreateBlankCursor()
if !blankCursorHandle {
    MsgBox, 创建透明光标失败！
    ExitApp
}

; 注册字符键热键（字母、数字、主键盘符号键）
charKeys := "abcdefghijklmnopqrstuvwxyz0123456789"
loop, parse, charKeys
{
    hotkey := "~" A_LoopField
    Hotkey, %hotkey%, TriggerHide, On
}
symbolKeys := "-=[]\\;',./"
loop, parse, symbolKeys
{
    hotkey := "~" A_LoopField
    Hotkey, %hotkey%, TriggerHide, On
}

; 启动鼠标位置监控
SetTimer, CheckMouseMove, 50

; === 托盘菜单 ===
Menu, Tray, NoStandard
Menu, Tray, Add, 切换光标隐藏, ToggleEnabled
Menu, Tray, Add, 退出, ExitScript

; 初始化托盘提示文字
UpdateTrayTip()

Menu, Tray, Icon
return

UpdateTrayTip() {
    statusText := enabled ? "启用" : "禁用"
    Menu, Tray, Tip, 系统光标隐藏脚本`n状态: %statusText%
}

ToggleEnabled:
enabled := !enabled
UpdateTrayTip()
; 先准备 ToolTip 文本
newStatus := enabled ? "启用" : "禁用"
ToolTip, 光标隐藏功能已%newStatus%
SetTimer, RemoveToolTip, 1500
return

RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
return

ExitScript:
ExitApp

; --------------------------------------------------
TriggerHide:
if !enabled
    return
if (cursor_hidden)
    return

mods := GetModifiersState()
if (mods.Ctrl || mods.Alt || mods.Win)
    return

; 执行隐藏
HideCursors()
cursor_hidden := true
MouseGetPos, hiddenX, hiddenY
ToolTip, 光标已隐藏
SetTimer, RemoveToolTip, 1000
return

; --------------------------------------------------
CheckMouseMove:
if !enabled
    return
if (!cursor_hidden)
    return

MouseGetPos, curX, curY
dx := curX - hiddenX
dy := curY - hiddenY
if (Abs(dx) > threshold || Abs(dy) > threshold) {
    RestoreCursors()
    cursor_hidden := false
    ToolTip, 光标已恢复
    SetTimer, RemoveToolTip, 1000
}
return

; --------------------------------------------------
CreateBlankCursor() {
    width := 32
    height := 32
    rowSize := (width + 7) // 8
    totalBytes := rowSize * height

    VarSetCapacity(andMask, totalBytes, 0xFF)
    VarSetCapacity(xorMask, totalBytes, 0)

    andPtr := &andMask
    xorPtr := &xorMask

    hCursor := DllCall("CreateCursor"
        , "uint", 0
        , "int", 0
        , "int", 0
        , "int", width
        , "int", height
        , "uint", andPtr
        , "uint", xorPtr
        , "uint")
    return hCursor
}

HideCursors() {
    ; 创建透明光标
    hInvisibleCursor := CreateBlankCursor()

    Loop, Parse, CursorIDs, `,
    {
        ID := A_LoopField
        ; 复制当前光标句柄（包含动画状态）并保存
        hCurrent := DllCall("CopyIcon", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", ID), "Ptr")
        OriginalHandles[ID] := hCurrent
        
        ; 替换为透明
        DllCall("SetSystemCursor", "Ptr", DllCall("CopyIcon", "Ptr", hInvisibleCursor), "Int", ID)
    }
}

RestoreCursors() {
    Loop, Parse, CursorIDs, `,
    {
        ID := A_LoopField
        hSaved := OriginalHandles[ID]
        
        if (hSaved) {
            ; 还原保存的句柄
            DllCall("SetSystemCursor", "Ptr", DllCall("CopyIcon", "Ptr", hSaved), "Int", ID)
            ; 清理保存的句柄副本
            DllCall("DestroyIcon", "Ptr", hSaved)
            OriginalHandles[ID] := 0
        }
    }
    
    ; 刷新系统光标设置
    DllCall("SystemParametersInfo", "UInt", 0x57, "UInt", 0, "Ptr", 0, "UInt", 0)
}

; --------------------------------------------------
GetModifiersState() {
    state := Object()
    state.Ctrl  := GetKeyState("Ctrl")  ? true : false
    state.Alt   := GetKeyState("Alt")   ? true : false
    state.Shift := GetKeyState("Shift") ? true : false
    state.Win   := GetKeyState("LWin") || GetKeyState("RWin") ? true : false
    return state
}

; --------------------------------------------------
; 退出时恢复光标并销毁透明光标句柄
OnExit, Cleanup
Cleanup:
    RestoreCursors()
    if (blankCursorHandle) {
        DllCall("DestroyCursor", "uint", blankCursorHandle)
    }
ExitApp