#IfWinActive ahk_class CabinetWClass
    MButton::
        For each, file in getSelected()
            Run, explorer.exe "%file%"
    Return
#IfWinActive

getSelected() { ; https://www.autohotkey.com/boards/viewtopic.php?style=17&t=60403#p255256 by teadrinker
    hwnd := WinExist("A"), selection := []
    WinGetClass, class
    If (class ~= "(Cabinet|Explore)WClass")
        For window in ComObjCreate("Shell.Application").Windows
        If (window.hwnd = hwnd)
        For item in window.document.SelectedItems
        selection.Push(item.Path)
    Return selection
}