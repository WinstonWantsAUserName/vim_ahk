﻿class VimMove {
  __New(vim) {
    this.Vim := vim
    this.shift := 0
  }
  
  NoSelection() {
    if !this.ExistingSelection && (this.Vim.State.StrIsInCurrentVimMode("VisualFirst") || this.Vim.State.StrIsInCurrentVimMode("ydc") || this.Vim.State.StrIsInCurrentVimMode("SMVim_") || this.Vim.State.StrIsInCurrentVimMode("Inner")) {
      this.ExistingSelection := true  ; so it only returns true once in repeat
      Return true
    }
  }

  IsSearchKey(key) {
    if key in f,t,+f,+t,(,),s,+s,/,?,e
      return true
  }

  IsReplace() {
    return (this.Vim.State.StrIsInCurrentVimMode("ydc_c") || this.Vim.State.surround || this.Vim.State.StrIsInCurrentVimMode("SMVim_"))
  }

  MoveInitialize(key:="", RestoreClip:=true) {
    this.shift := 0
    this.ExistingSelection := this.clipped := false
  
    if (this.IsSearchKey(key)) {
      this.SearchOccurrence := this.Vim.State.n ? this.Vim.State.n : 1
      this.FtsChar := this.Vim.State.FtsChar
      if (RestoreClip) {
        global ClipSaved
        ClipSaved := ClipboardAll
        this.clipped := true
      }
    }
    
    if (this.Vim.State.StrIsInCurrentVimMode("Visual") || this.Vim.State.StrIsInCurrentVimMode("ydc") || this.Vim.State.StrIsInCurrentVimMode("SMVim_")) {
      this.shift := 1
      if (!this.IsSearchKey(key))
        send {Shift Down}
    }

    if (this.Vim.State.IsCurrentVimMode("Vim_VisualLineFirst")) and (key == "k" or key == "^u" or key == "^b" or key == "g") {
      ; send {Shift Up}{End}
      ; this.Zero()
      ; send {Shift Down}
      ; this.Up()
      send {shift up}{right}{shift down}
      this.Zero()
      this.Vim.State.SetMode("Vim_VisualLine",, -1)  ; -1 is needed for repeat to work
    }

    if (this.Vim.State.IsCurrentVimMode("Vim_VisualLineFirst")) and (key == "j" or key == "^d" or key == "^f" or key == "+g") {
      this.Vim.State.SetMode("Vim_VisualLine",, -1)  ; -1 is needed for repeat to work
    }

    if (this.Vim.State.IsCurrentVimMode("Vim_VisualParagraphFirst")) and (key == "k" or key == "^u" or key == "^b" or key == "g") {
      send {Shift Up}{right}{left}{Shift Down}
      this.Up()
      this.Vim.State.SetMode("Vim_VisualParagraph",, -1)  ; -1 is needed for repeat to work
    }

    if (this.Vim.State.IsCurrentVimMode("Vim_VisualParagraphFirst")) and (key == "j" or key == "^d" or key == "^f" or key == "+g") {
      this.Vim.State.SetMode("Vim_VisualParagraph",, -1)  ; -1 is needed for repeat to work
    }
  
    if (this.Vim.State.IsCurrentVimMode("Vim_VisualBlock") && WinActive("ahk_exe notepad++.exe")) {
      send {alt down}
    }

    if (this.Vim.State.StrIsInCurrentVimMode("Vim_ydc") || this.Vim.State.StrIsInCurrentVimMode("SMVim_")) and (key == "k" or key == "^u" or key == "^b" or key == "g") {
      this.Vim.State.LineCopy := 1
      Send,{Shift Up}
      this.Zero()
      this.Down()
      send {Shift Down}
      this.Up()
    }
  
    if (this.Vim.State.StrIsInCurrentVimMode("Vim_ydc") || this.Vim.State.StrIsInCurrentVimMode("SMVim_")) and (key == "j" or key == "^d" or key == "^f" or key == "+g") {
      this.Vim.State.LineCopy := 1
      Send,{Shift Up}
      this.Zero()
      send {Shift Down}
      this.Down()
    }
  }

  MoveFinalize() {
    Send {Shift Up}
    ydc_y := false
    this.Vim.State.FtsChar := ""
    if (this.clipped && !this.Vim.State.StrIsInCurrentVimMode("ydc_y") && !this.Vim.State.StrIsInCurrentVimMode("ydc_d") && !this.Vim.State.StrIsInCurrentVimMode("ydc_c")) {
      global ClipSaved
      Clipboard := ClipSaved
    }
    if (!this.Vim.State.surround || !this.Vim.State.StrIsInCurrentVimMode("Vim_ydc")) {
      if (this.Vim.State.StrIsInCurrentVimMode("ydc_y")) {
        Clipboard :=
        send ^c
        ClipWait 0.6
        this.YdcClipSaved := Clipboard
        this.Vim.State.SetMode("Vim_Normal")
        ydc_y := true
      } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_d")) {
        if (!this.vim.state.leader) {
          Clipboard :=
          send ^x
          ClipWait 0.6
          this.YdcClipSaved := Clipboard
        } else {
          send {bs}
        }
        this.Vim.State.SetMode("Vim_Normal")
      } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_c")) {
        if (!this.vim.state.leader) {
          Clipboard :=
          send ^x
          ClipWait 0.6
          this.YdcClipSaved := Clipboard
        } else {
          send {bs}
        }
        this.Vim.State.SetMode("Insert")
      } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_gu")) {
        Gosub ConvertToLowercase
      } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_g+u")) {
        Gosub ConvertToUppercase
      } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_g~")) {
        Gosub InvertCase
      } else if (this.Vim.State.StrIsInCurrentVimMode("ExtractStay")) {
        Gosub ExtractStay
      } else if (this.Vim.State.StrIsInCurrentVimMode("ExtractPriority")) {
        send !+x
        this.Vim.State.SetMode("Vim_Normal")
      } else if (this.Vim.State.StrIsInCurrentVimMode("Extract")) {
        send !x
        this.Vim.State.SetMode("Vim_Normal")
      } else if (this.Vim.State.StrIsInCurrentVimMode("ClozeStay")) {
        Gosub ClozeStay
      } else if (this.Vim.State.StrIsInCurrentVimMode("ClozeHinter")) {
        Gosub ClozeHinter
      } else if (this.Vim.State.StrIsInCurrentVimMode("ClozeNoBracket")) {
        Gosub ClozeNoBracket
      } else if (this.Vim.State.StrIsInCurrentVimMode("Cloze")) {
        send !z
        this.Vim.State.SetMode("Vim_Normal")
      } else if (this.Vim.State.StrIsInCurrentVimMode("AltT")) {
        Send !t
        this.Vim.State.SetMode("Vim_Normal")
      } else if (this.Vim.State.StrIsInCurrentVimMode("AltQ")) {
        Send !q
        WinWaitActive, ahk_class TChoicesDlg
        send % this.KeyAfterSMAltQ
        send {enter}
        this.Vim.State.SetMode("Vim_Normal")
      }
    }
    this.Vim.State.SetMode("", 0, 0,,, -1)
    if (ydc_y) {
      send {Left}{Right}
    }
    ; Sometimes, when using `c`, the control key would be stuck down afterwards.
    ; This forces it to be up again afterwards.
    send {Ctrl Up}
    if (!WinActive("ahk_exe iexplore.exe"))
      send {alt up}
    if (this.Vim.State.IsCurrentVimMode("Vim_VisualFirst") || this.Vim.State.StrIsInCurrentVimMode("Inner") ||  this.Vim.State.StrIsInCurrentVimMode("Outer"))
      this.vim.state.setmode("Vim_VisualChar",,,,, -1)
  }

  Zero() {
    if WinActive("ahk_group VimDoubleHomeGroup") {
      send {Home}
    } else if WinActive("ahk_exe notepad++.exe") {
      send {end}
    }
    send {Home}
  }

  Up(n:=1) {
    if this.Vim.State.StrIsInCurrentVimMode("Paragraph") && this.Vim.IsHTML()
      if (shift == 1)
        this.SelectParagraphUp(n)
      else
        this.ParagraphUp(n)
    else if WinActive("ahk_group VimCtrlUpDownGroup")
      Send ^{Up %n%}
    else
      Send {Up %n%}
  }

  Down(n:=1) {
    if this.Vim.State.StrIsInCurrentVimMode("Paragraph") && this.Vim.IsHTML()
      if (shift == 1)
        this.SelectParagraphDown(n)
      else
        this.ParagraphDown(n)
    else if WinActive("ahk_group VimCtrlUpDownGroup")
      Send ^{Down %n%}
    else
      Send {Down %n%}
  }

  ParagraphUp(n:=1) {
    if this.Vim.IsHTML()
      if this.Vim.SM.IsEditingHTML()
        send ^+{up %n%}{left}
        ; ControlSend, ControlGetFocus(), {ctrl down}{up %n%}{ctrl up}  ; doesn't work
      else
        send ^{up %n%}
    else {
      this.up(n)
      send {end}
      this.Zero()
    }
  }
  
  ParagraphDown(n:=1) {
    if this.Vim.IsHTML()
      send ^{down %n%}
    else {
      this.down(n)
      send {end}
      this.Zero()
    }
  }

  SelectParagraphUp(n:=1) {
    if this.Vim.IsHTML()
      send ^+{up %n%}
    else {
      n--
      send +{up %n%}+{home}
    }
  }

  SelectParagraphDown(n:=1) {
    if this.Vim.IsHTML()
      send ^+{down %n%}
    else {
      n--
      send +{down %n%}+{end}
    }
  }

  HandleHTMLSelection(RestoreClip:=true) {
    if (this.Vim.IsHTML()) {
      if (this.Vim.SM.IsEditingHTML()) {
        selection := clip("",, RestoreClip)
        if (InStr(selection, "`r`n"))
          send .= "+{left}"
      } else {
        send .= "+{left}"
      }
    }
    if (send) {
      send % send
    } else {
      return selection
    }
  }

  Move(key="", repeat:=false, NoInitialize:=false, NoFinalize:=false, ForceNoShift:=false, RestoreClip:=true) {
    if (!repeat && !NoInitialize)
      this.MoveInitialize(key, RestoreClip)
    if (ForceNoShift)
      this.shift := 0

    ; Left/Right
    if (not this.Vim.State.StrIsInCurrentVimMode("Line")) && !this.Vim.State.StrIsInCurrentVimMode("Paragraph") {
      ; For some cases, need '+' directly to continue to select
      ; especially for cases using shift as original keys
      ; For now, caret does not work even add + directly

      ; 1 character
      if (key == "h") {
        if WinActive("ahk_group VimQdir") {
          send {BackSpace down}{BackSpace up}
        } else if (WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()) {
          ControlGetPos, XCoord,,,, Internet Explorer_Server2, ahk_class TElWind
          if (XCoord) {
            SendMessage, 0x114, 0, 0, Internet Explorer_Server2, A ; scroll left
          } else {
            SendMessage, 0x114, 0, 0, Internet Explorer_Server1, A ; scroll left
          }
        } else {
          send {Left}
        }
      } else if (key == "l") {
        if WinActive("ahk_group VimQdir") {
          send {Enter}
        } else if (WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()) {
          ControlGetPos, XCoord,,,, Internet Explorer_Server2, ahk_class TElWind
          if (XCoord) {
            SendMessage, 0x114, 1, 0, Internet Explorer_Server2, A ; scroll right
          } else {
            SendMessage, 0x114, 1, 0, Internet Explorer_Server1, A ; scroll left
          }
        } else {
          send {Right}
        }
      ; Home/End
      } else if (key == "0") {
        this.Zero()
      } else if (key == "$") {
        if (this.shift == 1) {
          send +{End}
        } else {
          send {End}
        }
      } else if (key == "^") {
        if (this.shift == 1) {
          if WinActive("ahk_group VimCaretMove") {
            send +{Home}
            send +^{Right}
            send +^{Left}
          } else {
            send +{Home}
          }
        } else {
          if WinActive("ahk_group VimCaretMove") {
            send {home}
            send ^{Right}
            send ^{Left}
          } else {
            send {home}
            if WinActive("ahk_exe notepad++.exe")
              send {home}
          }
        }
      } else if (key == "+") {
        if (this.shift == 1) {
          send +{down}+{end}+{home}
        } else {
          send {down}{end}{home}
        }
      } else if (key == "-") {
        if (this.shift == 1) {
          send +{up}+{end}+{home}
        } else {
          send {up}{end}{home}
        }
      ; Words
      } else if (key == "w") {
        if (this.shift == 1) {
          send +^{Right}
        } else {
          send ^{Right}
        }
      } else if (key == "e") {
        if (this.Vim.State.g) {  ; ge
          if (this.shift == 1) {
            if (!this.NoSelection()) {  ; determine caret position
              StrBefore := this.Vim.ParseLineBreaks(copy(false))
              send +{left}
              StrAfter := this.Vim.ParseLineBreaks(copy(false))
              send +{right}
            }
            if (!StrBefore || StrLen(StrAfter) > StrLen(StrBefore)) {
              this.SelectParagraphUp()
              StrAfter := this.Vim.ParseLineBreaks(copy(false))
              if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at start of line
                send +{left}
                this.SelectParagraphUp()
                StrAfter := this.Vim.ParseLineBreaks(copy(false))
              }
              length := StrLen(StrAfter) - StrLen(StrBefore)
              DetectionStr := StrReverse(SubStr(StrAfter, 1, length))
              pos := this.FindWordBoundary(DetectionStr, this.SearchOccurrence, true)
              if (pos) {
                right := StrLen(DetectionStr) - pos + 1
                if (pos == 1) {
                  this.SearchOccurrence++
                  NextOccurrence := this.FindWordBoundary(DetectionStr, this.SearchOccurrence, true)
                  if (NextOccurrence)
                    right := StrLen(DetectionStr) - NextOccurrence + 1
                }
              }
              send % "+{right " . right . "}"
            } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {
              DetectionStr := StrReverse(StrBefore)
              pos := this.FindWordBoundary(DetectionStr, this.SearchOccurrence, true)
              if (pos) {
                left := pos - 1
                if (pos == 1) {
                  this.SearchOccurrence++
                  NextOccurrence := this.FindWordBoundary(DetectionStr, this.SearchOccurrence, true)
                  if (NextOccurrence)
                    left := NextOccurrence - 1
                }
                if (StrLen(StrAfter) == StrLen(StrBefore))
                  left++
                send % "+{left " . left . "}"
              }
            }
          } else {
            this.SelectParagraphUp()
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
            if (!DetectionStr) {  ; start of line
              send {left}
              this.SelectParagraphUp()
              DetectionStr := this.Vim.ParseLineBreaks(copy(false))
            }
            DetectionStr := StrReverse(DetectionStr)
            pos := this.FindWordBoundary(DetectionStr, this.SearchOccurrence, true)
            if (pos)
              pos--
            send % "{right}{left " . pos . "}"
          }
        } else if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(copy(false))
            send +{right}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            send +{left}
          }
          if (!StrBefore || StrLen(StrAfter) > StrLen(StrBefore)) {  ; searching forward
            this.SelectParagraphDown()
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at end of line
              send +{right}
              this.SelectParagraphDown()
              StrAfter := this.Vim.ParseLineBreaks(copy(false))
            }
            StartPos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
            DetectionStr := SubStr(StrAfter, StartPos)  ; what's selected after +{end}
            pos := this.FindWordBoundary(DetectionStr, this.SearchOccurrence)
            pos += StrLen(StrBefore)
            send % "{left}+{right " . pos . "}"
            ; left := StrLen(DetectionStr) - pos  ; goes back
            ; KeyWait shift  ; keys that need shift (like "(") would mess up the shift below
            ; send % "+{left " . left . "}"
          } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {
            DetectionStr := StrBefore
            pos := this.FindWordBoundary(DetectionStr, this.SearchOccurrence)
            if (pos) {
              right := pos
              if (pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindWordBoundary(DetectionStr, this.SearchOccurrence)
                if (NextOccurrence)
                  right := NextOccurrence
              }
              KeyWait shift  ; keys that need shift (like "(") would mess up the shift below
              send % "+{right " . right . "}"
            }
          }
        } else {
          this.SelectParagraphDown()
          DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          if (!DetectionStr) {
            send {right}
            this.SelectParagraphDown()
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          } else if this.Vim.IsWhitespaceOnly(DetectionStr) {
            send {right 2}
            this.SelectParagraphDown()
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          }
          pos := this.FindWordBoundary(DetectionStr, this.SearchOccurrence)
          if (pos) {
            right := pos
            if (pos == 1) {
              this.SearchOccurrence++
              NextOccurrence := this.FindWordBoundary(DetectionStr, this.SearchOccurrence)
              if (NextOccurrence)
                right := NextOccurrence
            }
          } else {
            right := 0
          }
          send % "{left}{right " . right . "}"
        }
      } else if (key == "b") {
        if (this.shift == 1) {
          send +^{Left}
        } else {
          send ^{Left}
        }
      } else if (key == "f") {  ; find forward
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(copy(false))
            send +{right}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            send +{left}
          }
          if (!StrBefore || StrLen(StrAfter) > StrLen(StrBefore)) {  ; searching forward
            send +{end}
            selection := this.HandleHTMLSelection(false)
            StrAfter := this.Vim.ParseLineBreaks(selection ? selection : copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at end of line
              send +{right}+{end}
              selection := this.HandleHTMLSelection(false)
              StrAfter := this.Vim.ParseLineBreaks(selection ? selection : copy(false))
            }
            StartPos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
            DetectionStr := SubStr(StrAfter, StartPos)  ; what's selected after +{end}
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            pos += StrLen(StrBefore)
            send % "{left}+{right " . pos . "}"
            ; left := StrLen(DetectionStr) - pos  ; goes back
            ; KeyWait shift  ; keys that need shift (like "(") would mess up the shift below
            ; send % "+{left " . left . "}"
          } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {
            DetectionStr := StrBefore
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            if (pos) {
              right := pos - 1
              if (pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
                if (NextOccurrence)
                  right := NextOccurrence - 1
              }
              KeyWait shift  ; keys that need shift (like "(") would mess up the shift below
              send % "+{right " . right . "}"
            }
          }
        } else {
          send +{end}
          DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          if !DetectionStr {  ; end of line
            send {right}+{end}  ; to the next line
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          } else if this.Vim.IsWhitespaceOnly(DetectionStr) {
            send {right 2}+{end}  ; to the next line
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          }
          pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
          if (pos) {
            right := pos - 1
            if (pos == 1) {
              this.SearchOccurrence++
              NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
              if (NextOccurrence)
                right := NextOccurrence - 1
            }
          } else {
            right := 0
          }
          send % "{left}{right " . right . "}"
        }
      } else if (key == "t") {
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(copy(false))
            send +{right}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            send +{left}
          }
          if (!StrBefore || StrLen(StrAfter) > StrLen(StrBefore)) {  ; searching forward
            send +{end}
            selection := this.HandleHTMLSelection(false)
            StrAfter := this.Vim.ParseLineBreaks(selection ? selection : copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at end of line
              send +{right}+{end}
              selection := this.HandleHTMLSelection(false)
              StrAfter := this.Vim.ParseLineBreaks(selection ? selection : copy(false))
            }
            StartPos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
            DetectionStr := SubStr(StrAfter, StartPos)  ; what's selected after +end
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            right := pos + StrLen(StrBefore) - 1
            if (pos == 1) {
              this.SearchOccurrence++
              NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
              if (NextOccurrence)
                right := NextOccurrence + StrLen(StrBefore) - 1
            }
            send % "{left}+{right " . right . "}"
            ; left := StrLen(DetectionStr) - pos
            ; if (pos) {
            ;   left++
            ;   if (pos == 1) {
            ;     this.SearchOccurrence++
            ;     NextOccurrence := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
            ;     if (NextOccurrence)
            ;       left := StrLen(DetectionStr) - NextOccurrence + 1
            ;   }
            ; }
            ; KeyWait shift  ; keys that need shift (like "(") would mess up the shift below
            ; send % "+{left " . left . "}"
          } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {
            DetectionStr := StrBefore
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            if (pos) {
              right := pos - 2
              if (pos == 2 || pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
                if (NextOccurrence > 1)
                  right := NextOccurrence - 2
                else
                  right := 0
              }
              KeyWait shift  ; keys that need shift (like "(") would mess up the shift below
              send % "+{right " . right . "}"
            }
          }
        } else {
          send +{end}
          DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          if !DetectionStr {  ; end of line
            send {right}+{end}  ; to the next line
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          } else if this.Vim.IsWhitespaceOnly(DetectionStr) {
            send {right 2}+{end}  ; to the next line
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          }
          pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
          if (pos) {
            right := pos - 2
            if (pos == 1 || pos == 2)  {
              this.SearchOccurrence++
              NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
              if (NextOccurrence)
                right := NextOccurrence - 2
            }
          } else {
            right := 0
          }
          send % "{left}{right " . right . "}"
        }
      } else if (key == "+f") {
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(copy(false))
            send +{left}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            send +{right}
          }
          if (!StrBefore || StrLen(StrAfter) > StrLen(StrBefore)) {
            send +{home}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at start of line
              send +{left}+{home}
              StrAfter := this.Vim.ParseLineBreaks(copy(false))
            }
            length := StrLen(StrAfter) - StrLen(StrBefore)
            DetectionStr := StrReverse(SubStr(StrAfter, 1, length))
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            right := StrLen(DetectionStr) - pos
            KeyWait shift  ; keys that need shift (like "(") would mess up the shift below
            send % "+{right " . right . "}"
          } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {
            DetectionStr := StrReverse(StrBefore)
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            if (pos) {
              left := pos - 1
              if (pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
                if (NextOccurrence)
                  left := NextOccurrence - 1
              }
              if (StrLen(StrAfter) == StrLen(StrBefore))
                left++
              KeyWait shift  ; keys that need shift (like "(") would mess up the shift below
              send % "+{left " . left . "}"
            }
          }
        } else {
          send +{home}
          DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          if !DetectionStr {  ; start of line
            send {left}+{home}
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          }
          DetectionStr := StrReverse(DetectionStr)
          pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
          send % "{right}{left " . pos . "}"
        }
      } else if (key == "+t") {
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(copy(false))
            send +{left}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            send +{right}
          }
          if (!StrBefore || StrLen(StrAfter) > StrLen(StrBefore)) {
            send +{home}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at start of line
              send +{left}+{home}
              StrAfter := this.Vim.ParseLineBreaks(copy(false))
            }
            length := StrLen(StrAfter) - StrLen(StrBefore)
            DetectionStr := StrReverse(SubStr(StrAfter, 1, length))
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            right := StrLen(DetectionStr) - pos
            if (pos) {
              right++
              if (pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
                if (NextOccurrence)
                  right := StrLen(DetectionStr) - NextOccurrence + 1
              }
            }
            KeyWait shift  ; keys that need shift (like "(") would mess up the shift below
            send % "+{right " . right . "}"
          } else if StrLen(StrAfter) <= StrLen(StrBefore) {
            DetectionStr := StrReverse(StrBefore)
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            if (pos) {
              left := pos - 2
              if (pos == 2 || pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
                if (pos == 1 && NextOccurrence == 2) {  ; in instance like "see"
                  this.SearchOccurrence++
                  NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
                  if (NextOccurrence)
                    left := NextOccurrence - 2
                } else if (NextOccurrence > 1) {
                  left := NextOccurrence - 2
                } else {
                  left := 0
                }
              }
              if (StrLen(StrAfter) == StrLen(StrBefore))
                left++
              KeyWait shift  ; keys that need shift (like "(") would mess up the shift below
              send % "+{left " . left . "}"
            }
          }
        } else {
          send +{home}
          DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          if (!DetectionStr) {  ; start of line
            send {left}+{home}
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          }
          DetectionStr := StrReverse(DetectionStr)
          pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
          if (pos) {
            left := pos - 1
            if (pos == 1) {
              this.SearchOccurrence++
              NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
              if (NextOccurrence)
                left := NextOccurrence - 1
            }
          } else {
            left := 0
          }
          send % "{right}{left " . left . "}"
        }
      } else if (key == ")") {  ; like "f" but search for ". "
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(copy(false))
            send +{right}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            send +{left}
          }
          if (!StrBefore || StrLen(StrAfter) > StrLen(StrBefore)) {
            this.SelectParagraphDown()
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore) + 1) {  ; at end of paragraph
              send +{right}
              this.SelectParagraphDown()
              StrAfter := this.Vim.ParseLineBreaks(copy(false))
            }
            StartPos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
            DetectionStr := SubStr(StrAfter, StartPos)  ; what's selected after +end
            pos := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence)
            pos += StrLen(StrBefore) + 1
            send % "{left}+{right " . pos . "}"
            ; left := StrLen(DetectionStr) - pos - 1
            ; Try to search if the sentence is the last sentence in the paragraph
            ; if (!pos && RegExMatch(DetectionStr, "\.$") == Strlen(DetectionStr)) {
            ;   send +{right}  ; if it is, move to start of next paragraph
            ; } else {
            ;   send % "+{left " . left . "}"
            ; }
          } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {  ; search in selected text
            pos := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence)
            right := pos
            if (pos) {
              right++
              if (pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence)
                if (NextOccurrence)
                  right := pos + 1
              }
            }
            send % "+{right " . right . "}"
          }
        } else {
          this.SelectParagraphDown()
          DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          if (!DetectionStr || this.Vim.IsWhitespaceOnly(DetectionStr)) {  ; end of paragraph
            send {right}
            this.SelectParagraphDown()  ; to the next line
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
            if (!DetectionStr) {  ; still end of paragraph
              send {right}
              this.SelectParagraphDown()  ; to the next line
              DetectionStr := this.Vim.ParseLineBreaks(copy(false))
            }
          }
          pos := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence)
          if (pos) {
            right := pos + 1
            if (StrLen(DetectionStr) == pos + 2)  ; found at end of paragraph
              right++
            send % "{left}{right " . right . "}"
          } else {
            send {right}
          }
        }
      } else if (key == "(") {  ; like "+t"
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(copy(false))
            send +{right}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            send +{left}
          }
          if (StrLen(StrAfter) > StrLen(StrBefore)) {  ; search in selected text
            DetectionStr := StrReverse(StrBefore)
            pos := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence, true)
            left := pos - 2
            if (pos) {
              left++
              if (pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence, true)
                if (NextOccurrence)
                  left := NextOccurrence - 1
              }
            }
            send % "+{left " . left . "}"
          } else if (StrLen(StrAfter) <= StrLen(StrBefore) || !StrBefore) {
            this.SelectParagraphUp()
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            if !StrAfter {  ; start of line
              send {left}
              this.SelectParagraphUp()
              StrAfter := this.Vim.ParseLineBreaks(copy(false))
            }
            length := StrLen(StrAfter) - StrLen(StrBefore)
            DetectionStr := StrReverse(SubStr(StrAfter, 1, length))
            pos := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence, true)
            right := StrLen(DetectionStr) - pos
            if (pos) {
              right++
              if (pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence, true)
                if (NextOccurrence) {
                  right := StrLen(DetectionStr) - NextOccurrence + 1
                } else {
                  ret := true
                }
              }
            } else {
              ret := true
            }
            if (!ret)
              send % "+{right " . right . "}"
          }
        } else {
          this.SelectParagraphUp()
          DetectionStr := copy(false)
          if (RegExMatch(DetectionStr, "\r\n$")) {  ; start of paragraph
            send {right}{left}
            this.SelectParagraphUp()
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          } else {
            DetectionStr := this.vim.ParseLineBreaks(DetectionStr)
          }
          DetectionStr := StrReverse(DetectionStr)
          pos := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence, true)
          if (pos) {
            left := pos - 1
            if (pos == 1) {
              this.SearchOccurrence++
              NextOccurrence := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence, true)
              if (NextOccurrence) {
                left := NextOccurrence - 1
              } else {
                ret := true
              }
            }
          } else {
            ret := true
          }
          if (ret) {
            send {left}
          } else {
            send % "{right}{left " . left . "}"
          }
        }
      } else if (key == "s") {
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(copy(false))
            send +{right}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            send +{left}
          }
          if (!StrBefore || StrLen(StrAfter) > StrLen(StrBefore)) {  ; searching forward
            this.SelectParagraphDown()
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at end of line
              send +{right}
              this.SelectParagraphDown()
              StrAfter := this.Vim.ParseLineBreaks(copy(false))
            }
            StartPos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
            DetectionStr := SubStr(StrAfter, StartPos)  ; what's selected after +end
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            right := pos + StrLen(StrBefore) - 1
            if (pos == 1) {
              this.SearchOccurrence++
              NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
              if (NextOccurrence)
                right := NextOccurrence + StrLen(StrBefore) - 1
            }
            send % "{left}+{right " . right . "}"
            ; left := StrLen(DetectionStr) - pos
            ; if (pos) {
            ;   left++
            ;   if (pos == 1) {
            ;     this.SearchOccurrence++
            ;     NextOccurrence := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
            ;     if (NextOccurrence)
            ;       left := StrLen(DetectionStr) - NextOccurrence + 1
            ;   }
            ; }
            ; KeyWait shift  ; keys that need shift (like "(") would mess up the shift below
            ; send % "+{left " . left . "}"
          } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {
            DetectionStr := StrBefore
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            if (pos) {
              right := pos - 2
              if (pos == 2 || pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
                if (NextOccurrence > 1) {
                  right := NextOccurrence - 2
                } else {
                  right := 0
                }
              }
              KeyWait shift  ; keys that need shift (like "(") would mess up the shift below
              send % "+{right " . right . "}"
            }
          }
        } else {
          this.SelectParagraphDown()
          DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          if (!DetectionStr) {
            send {right}
            this.SelectParagraphDown()
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          } else if (this.Vim.IsWhitespaceOnly(DetectionStr)) {
            send {right 2}
            this.SelectParagraphDown()
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          }
          pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
          if (pos) {
            right := pos - 1
            if (pos == 1) {
              this.SearchOccurrence++
              NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
              if (NextOccurrence)
                right := NextOccurrence - 1
            }
          } else {
            right := 0
          }
          send % "{left}{right " . right . "}"
        }
      } else if (key == "+s") {
        this.FtsChar := StrReverse(this.FtsChar)
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(copy(false))
            send +{left}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            send +{right}
          }
          if (!StrBefore || StrLen(StrAfter) > StrLen(StrBefore)) {
            this.SelectParagraphUp()
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at start of line
              send +{left}
              this.SelectParagraphUp()
              StrAfter := this.Vim.ParseLineBreaks(copy(false))
            }
            length := StrLen(StrAfter) - StrLen(StrBefore)
            DetectionStr := StrReverse(SubStr(StrAfter, 1, length))
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            right := StrLen(DetectionStr) - pos - 1
            KeyWait shift  ; keys that need shift (like "(") would mess up the shift below
            send % "+{right " . right . "}"
          } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {
            DetectionStr := StrReverse(StrBefore)
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            if (pos) {
              left := pos + 2
              if (pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
                if (NextOccurrence)
                  left := NextOccurrence + 2
              }
              KeyWait shift  ; keys that need shift (like "(") would mess up the shift below
              send % "+{left " . left . "}"
            }
          }
        } else {
          this.SelectParagraphUp()
          DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          if (!DetectionStr) {  ; start of line
            send {left}
            this.SelectParagraphUp()
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          }
          DetectionStr := StrReverse(DetectionStr)
          pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
          pos := pos ? pos + 1 : 0
          send % "{right}{left " . pos . "}"
        }
      } else if (key == "/") {
        hwnd := WinGet()
        InputBoxPrompt := " text until:`n(case sensitive)"
        InputBoxHeight := 144
        if (this.Vim.State.StrIsInCurrentVimMode("Visual")) {
          InputBoxPrompt := "Select" . InputBoxPrompt
        } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_y")) {
          InputBoxPrompt := "Copy" . InputBoxPrompt
        } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_d")) {
          InputBoxPrompt := "Delete" . InputBoxPrompt
        } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_c")) {
          InputBoxPrompt := "Delete" . InputBoxPrompt . "`n(will enter insert mode)"
          InputBoxHeight := 160
        } else if (this.Vim.State.StrIsInCurrentVimMode("Extract")) {
          InputBoxPrompt := "Extract" . InputBoxPrompt
        } else if (this.Vim.State.StrIsInCurrentVimMode("Cloze")) {
          InputBoxPrompt := "Cloze" . InputBoxPrompt
        }
        InputBox, UserInput, Visual Search, % InputBoxPrompt,, 272, % InputBoxHeight,,,,, % this.LastSearch
        if (!UserInput)
          return
        this.LastSearch := UserInput  ; register UserInput into LastSearch
        WinActivate % "ahk_id " . hwnd
        if (!this.NoSelection()) {  ; determine caret position
          StrBefore := this.Vim.ParseLineBreaks(copy(false))
          send +{right}
          StrAfter := this.Vim.ParseLineBreaks(copy(false))
          send +{left}
        }
        if (!StrBefore || StrLen(StrAfter) > StrLen(StrBefore)) {
          this.SelectParagraphDown()
          StrAfter := this.Vim.ParseLineBreaks(copy(false))
          if (StrLen(StrAfter) == StrLen(StrBefore) + 1) {  ; at end of paragraph
            send +{right}
            this.SelectParagraphDown()
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
          }
          StartPos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
          DetectionStr := SubStr(StrAfter, StartPos)
          pos := InStr(DetectionStr, UserInput, true,, this.SearchOccurrence)
          left := StrLen(DetectionStr) - pos + 1
          if (pos == 1) {
            this.SearchOccurrence++
            NextOccurrence := InStr(DetectionStr, UserInput, true,, this.SearchOccurrence)
            if (NextOccurrence)
              left := StrLen(DetectionStr) - NextOccurrence + 1
          }
          send % "+{left " . left . "}"
        } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {
          pos := InStr(StrBefore, UserInput, true)
          pos -= pos ? 1 : 0
          send % "+{right " . pos . "}"
        }
      } else if (key == "?") {
        hwnd := WinGet()
        InputBoxPrompt := " text until:`n(case sensitive)"
        InputBoxHeight := 144
        if (this.Vim.State.StrIsInCurrentVimMode("Visual")) {
          InputBoxPrompt := "Select" . InputBoxPrompt
        } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_y")) {
          InputBoxPrompt := "Copy" . InputBoxPrompt
        } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_d")) {
          InputBoxPrompt := "Delete" . InputBoxPrompt
        } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_c")) {
          InputBoxPrompt := "Delete" . InputBoxPrompt . "`n(will enter insert mode)"
          InputBoxHeight := 160
        } else if (this.Vim.State.StrIsInCurrentVimMode("Extract")) {
          InputBoxPrompt := "Extract" . InputBoxPrompt
        } else if (this.Vim.State.StrIsInCurrentVimMode("Cloze")) {
          InputBoxPrompt := "Cloze" . InputBoxPrompt
        }
        InputBox, UserInput, Visual Search, % InputBoxPrompt,, 272, % InputBoxHeight,,,,, % this.LastSearch
        if (!UserInput)
          return
        this.LastSearch := UserInput  ; register UserInput into LastSearch
        WinActivate % "ahk_id " . hwnd
        if (!this.NoSelection()) {  ; determine caret position
          StrBefore := this.Vim.ParseLineBreaks(copy(false))
          send +{right}
          StrAfter := this.Vim.ParseLineBreaks(copy(false))
          send +{left}
        }
        if (StrLen(StrAfter) > StrLen(StrBefore)) {
          pos := InStr(StrReverse(StrBefore), StrReverse(UserInput), true)
          pos += pos ? StrLen(UserInput) - 2 : 0
          send % "+{left " . pos . "}"
        } else if (StrLen(StrAfter) <= StrLen(StrBefore)) || !StrBefore {
          this.SelectParagraphUp()
          StrAfter := this.Vim.ParseLineBreaks(copy(false))
          if (!StrAfter) {  ; start of line
            send {left}
            this.SelectParagraphUp()
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
          }
          StartPos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
          DetectionStr := SubStr(StrReverse(StrAfter), StartPos)
          pos := InStr(DetectionStr, StrReverse(UserInput), true,, this.SearchOccurrence)
          right := StrLen(DetectionStr) - pos - StrLen(UserInput) + 1
          send % "+{right " . right . "}"
        }
      }
    }
    ; Up/Down 1 character
    if (key == "j") {
      if (WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()) {
        if (ControlGet("hwnd",, "Internet Explorer_Server2")) {
          SendMessage, 0x0115, 1, 0, Internet Explorer_Server2, A ; scroll down
        } else {
          SendMessage, 0x0115, 1, 0, Internet Explorer_Server1, A ; scroll down
        }
      } else {
        this.Down()
      }
    } else if (key == "^e") {
      if (WinActive("ahk_exe WINWORD.exe")) {
        send {CtrlUp}{WheelDown}
      } else {
        SendMessage, 0x0115, 1, 0, % ControlGetFocus(), A ; scroll down
      }
    } else if (key == "k") {
      if (WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()) {
        if (ControlGet("hwnd",, "Internet Explorer_Server2")) {
          SendMessage, 0x0115, 0, 0, Internet Explorer_Server2, A ; scroll up
        } else {
          SendMessage, 0x0115, 0, 0, Internet Explorer_Server1, A ; scroll up
        }
      } else {
        this.Up()
      }
    } else if (key == "^y") {
      if (WinActive("ahk_exe WINWORD.exe")) {
        send {CtrlUp}{WheelUp}
      } else {
        SendMessage, 0x0115, 0, 0, % ControlGetFocus(), A
      }
    ; Page Up/Down
    n := 10
    } else if (key == "^u") {
      if (WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()) {
        if (ControlGet("hwnd",, "Internet Explorer_Server2")) {
          SendMessage, 0x0115, 0, 0, Internet Explorer_Server2, A ; scroll up
          SendMessage, 0x0115, 0, 0, Internet Explorer_Server2, A ; scroll up
        } else {
          SendMessage, 0x0115, 0, 0, Internet Explorer_Server1, A ; scroll up
          SendMessage, 0x0115, 0, 0, Internet Explorer_Server1, A ; scroll up
        }
      } else {
        this.Up(10)
      }
    } else if (key == "^d") {
      if (WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()) {
        if (ControlGet("hwnd",, "Internet Explorer_Server2")) {
          SendMessage, 0x0115, 1, 0, Internet Explorer_Server2, A ; scroll down
          SendMessage, 0x0115, 1, 0, Internet Explorer_Server2, A ; scroll down
        } else {
          SendMessage, 0x0115, 1, 0, Internet Explorer_Server1, A ; scroll down
          SendMessage, 0x0115, 1, 0, Internet Explorer_Server1, A ; scroll down
        }
      } else {
        this.Down(10)
      }
    } else if (key == "^b") {
      send {PgUp}
    } else if (key == "^f") {
      send {PgDn}
    } else if (key == "g") {
      if (this.Vim.State.n > 0) {
        line := this.Vim.State.n - 1, this.Vim.State.n := 0
        if (WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()) {  ; browsing
          send ^t
          this.Vim.SM.WaitTextFocus()
        } else {
          this.SMClickSyncButton()
        }
        send % "^{home}{down " . line . "}"
        this.SMClickSyncButton()
      } else if (this.Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()) {
        if (ControlGet("hwnd",, "Internet Explorer_Server2")) {
          ControlSend, Internet Explorer_Server2, {home}
        } else {
          ControlSend, Internet Explorer_Server1, {home}
        }
      } else {
        send ^{Home}
      }
    } else if (key == "+g") {
        if (this.Vim.State.n > 0) {
          line := this.Vim.State.n - 1, this.Vim.State.n := 0
          KeyWait shift
          if (WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()) {  ; browsing
            this.Vim.SM.ClickTop()
            this.Vim.SM.WaitTextFocus()
          } else if (this.Vim.SM.IsEditingText()) {
            this.Vim.SM.ClickTop()
          } else {
            this.SMClickSyncButton()
            send ^{home}
          }
          send % "{down " . line . "}"
          this.SMClickSyncButton()
        } else if (this.Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()) {
          if (ControlGet("hwnd",, "Internet Explorer_Server2")) {
            ControlSend, Internet Explorer_Server2, {end}
          } else {
            ControlSend, Internet Explorer_Server1, {end}
          }
        } else {
          if (this.shift == 1) {
            send ^+{End}+{Home}
          } else {
            send ^{End}
            if (!WinActive("ahk_exe iexplore.exe") && !WinActive("ahk_class TContents"))
              send {Home}
          }
          if (this.Vim.SM.IsEditingHTML()) {
            send ^+{up}  ; if there are references this would select (or deselect in visual mode) them all
            if (this.shift == 1)
              send +{down}  ; go down one line, if there are references this would include the #SuperMemo Reference
            if (InStr(copy("",, 1), "#SuperMemo Reference:")) {
              if (this.shift == 1) {
                send +{up 4}  ; select until start of last line
              } else {
                send {up 3}  ; go to start of last line
              }
              if (this.Vim.State.StrIsInCurrentVimMode("VisualLine"))
                send +{end}
            } else {
              if (this.shift == 1) {
                send ^+{end}
                if (!this.Vim.State.StrIsInCurrentVimMode("VisualLine"))
                  send +{home}
              } else {
                send ^{end}
                if (!this.Vim.State.StrIsInCurrentVimMode("VisualLine"))
                  send {home}
              }
            }
          }
        }
    } else if (key == "{") {
      if (this.Vim.State.n > 0 && WinActive("ahk_class TElWind") && !repeat) {  ; this can only be invoked by Vim.Move.Move and not Vim.Move.Repeat
        paragraph := this.Vim.State.n - 1, this.Vim.State.n := 0
        if (!this.Vim.SM.IsEditingText()) {
          send ^t
          this.Vim.SM.WaitTextFocus()
        }
        send ^{home}
        this.ParagraphDown(paragraph)
      } else if (this.shift == 1) {
        this.SelectParagraphUp()
      } else {
        this.ParagraphUp()
      }
    } else if (key == "}") {
      if (this.Vim.State.n > 0 && WinActive("ahk_class TElWind") && !repeat) {  ; this can only be invoked by Vim.Move.Move and not Vim.Move.Repeat
        paragraph := this.Vim.State.n - 1, this.Vim.State.n := 0
        KeyWait shift
        this.Vim.SM.ClickTop()
        this.Vim.SM.WaitTextFocus()
        this.ParagraphDown(paragraph)
      } else if (this.shift == 1) {
        this.SelectParagraphDown()
      } else {
        this.ParagraphDown()
      }
    }

    if (!repeat && !NoFinalize)
      this.MoveFinalize()
  }

  Repeat(key:="") {
    this.MoveInitialize(key)
    if (this.Vim.State.n == 0)
      this.Vim.State.n := 1
    if (b := (IfIn(key, "j,k") && this.Vim.State.n > 1))
      this.SMClickSyncButton()
		loop % this.Vim.State.n
			this.Move(key, true)
    if (b)
      this.SMClickSyncButton()
    this.MoveFinalize()
  }

  YDCMove() {
    this.Vim.State.LineCopy := 1
    this.Zero()
    send {Shift Down}
    if (this.Vim.State.n == 0)
      this.Vim.State.n := 1
    this.Down(this.Vim.State.n - 1)
    if (WinActive("ahk_group VimLBSelectGroup") && this.Vim.State.n == 2)
      send {right}
    send {End}
    if (this.IsReplace())
      send {left}
    if (!WinActive("ahk_group VimLBSelectGroup")) {
      this.Move("l")
    } else {
      this.Move("")
    }
  }

  Inner(key:="") {
    global WinClip
    if (Vim.State.StrIsInCurrentVimMode("Vim_ydc"))
      RestoreClip := true
    if (key == "w") {
      send ^{right}^{left}
      this.Move("e")
    } else if (key == "s") {
      if (RestoreClip)
        ClipSaved := ClipboardAll
      send {right}  ; so if at start of a sentence, select this sentence
      this.Move("(",,, true, true, true)
      this.Move(")",,, true,, true)
      ; End of paragraph
      if (!this.v)
        this.FindSentenceEnd(this.Vim.ParseLineBreaks(copy(false)))
      n := StrLen(this.v)
      this.Vim.State.SetMode("",, n,,, -1)
      if (RestoreClip)
        Clipboard := ClipSaved
      this.Repeat("h")
    } else if (key == "p") {
      if (RestoreClip)
        ClipSaved := ClipboardAll
      this.ParagraphDown()
      this.ParagraphUp()
      this.SelectParagraphDown()
      selection := this.HandleHTMLSelection(false)
      DetectionStr := this.Vim.ParseLineBreaks(selection ? selection : copy(false))
      DetectionStr := StrReverse(DetectionStr)
      RegExMatch(DetectionStr, "^(\s+\.|\.|\s+)", match)
      n := StrLen(match)
      if (RestoreClip)
        Clipboard := ClipSaved
      if (this.Vim.IsHTML())  ; update selection
        send +{left}+{right}
      if (n) {
        this.Vim.State.SetMode("",, n,,, -1)
        this.Repeat("h")
      } else {
        this.MoveFinalize()
      }
    } else if (IfIn(key, "(,),{,},[,],<,>,"",',=")) {
      if (RestoreClip)
        ClipSaved := ClipboardAll
      send {right}
      this.SelectParagraphUp()
      KeyWait shift
      DetectionStr := this.Vim.ParseLineBreaks(copy(false))
      if (!DetectionStr) {  ; start of paragraph
        send {left}
        this.SelectParagraphUp()
        DetectionStr := this.Vim.ParseLineBreaks(copy(false))
      }
      DetectionStr := StrReverse(DetectionStr)
      key := this.RevSurrKey(key)
      if (AltKey := this.GetAltKey(key)) {
        pos := RegExMatch(DetectionStr, AltKey)
      } else {
        pos := InStr(DetectionStr, key)
      }
      left := pos ? pos - 1 : 0
      send % "{right}{left " . left . "}"
      if (!pos) {
        send {left}
        if (RestoreClip)
          Clipboard := ClipSaved
        this.MoveFinalize()
        return
      }
      this.SelectParagraphDown()
      DetectionStr := this.Vim.ParseLineBreaks(copy(false))
      if (!DetectionStr) {  ; end of paragraph
        send {right}  ; to the next paragraph
        this.SelectParagraphDown()
        DetectionStr := this.Vim.ParseLineBreaks(copy(false))
      } else if (this.Vim.IsWhitespaceOnly(DetectionStr)) {
        send {right 2}  ; to the next paragraph
        this.SelectParagraphDown()
        DetectionStr := this.Vim.ParseLineBreaks(copy(false))
      }
      key := this.RevSurrKey(key, 2)
      if (AltKey := this.GetAltKey(key)) {
        pos := RegExMatch(DetectionStr, AltKey)
      } else {
        pos := InStr(DetectionStr, key)
      }
      pos := pos ? pos - 1 : 0
      send % "{left}+{right " . pos . "}"
      if (RestoreClip)
        Clipboard := ClipSaved
      this.MoveFinalize()
    }
  }

  Outer(key:="") {
    global WinClip
    if (Vim.State.StrIsInCurrentVimMode("Vim_ydc"))
      RestoreClip := true
    if (key == "w") {
      send ^{right}^{left}
      this.Move("w")
    } else if (key == "s") {
      if (RestoreClip)
        ClipSaved := ClipboardAll
      send {right}  ; so if at start of a sentence, select this sentence
      this.Move("(",,, true, true, true)
      this.Move(")",,, true,, true)
      if (RestoreClip)
        Clipboard := ClipSaved
      if (this.IsReplace()) {
        if (this.v)
          n := StrLen(RegExReplace(this.v, "\.\K(\[.*?\])+")) - 1
        send % "+{left " . n . "}"  ; so that "dap" would delete an entire paragraph, whereas "cap" would empty the paragraph
      }
      this.MoveFinalize()
    } else if (key == "p") {
      this.ParagraphDown()
      this.ParagraphUp()
      this.SelectParagraphDown()
      if (this.IsReplace())
        send +{left}  ; so that "dap" would delete an entire paragraph, whereas "cap" would empty the paragraph
      this.MoveFinalize()
    } else if (IfIn(key, "(,),{,},[,],<,>,"",',=")) {
      if (RestoreClip)
        ClipSaved := ClipboardAll
      send {right}
      this.SelectParagraphUp()
      DetectionStr := this.Vim.ParseLineBreaks(copy(false))
      if (!DetectionStr) {  ; start of paragraph
        send {left}
        this.SelectParagraphUp()
        DetectionStr := this.Vim.ParseLineBreaks(copy(false))
      }
      DetectionStr := StrReverse(DetectionStr)
      key := this.RevSurrKey(key)
      if (AltKey := this.GetAltKey(key)) {
        pos := RegExMatch(DetectionStr, AltKey)
      } else {
        pos := InStr(DetectionStr, key)
      }
      send % "{right}{left " . pos . "}"
      if (!pos) {
        if (RestoreClip)
          Clipboard := ClipSaved
        this.MoveFinalize()
        return
      }
      this.SelectParagraphDown()
      DetectionStr := this.Vim.ParseLineBreaks(copy(false))
      if (!DetectionStr) {  ; end of paragraph
        send {right}  ; to the next paragraph
        this.SelectParagraphDown()
        DetectionStr := this.Vim.ParseLineBreaks(copy(false))
      } else if (this.Vim.IsWhitespaceOnly(DetectionStr)) {
        send {right 2}  ; to the next paragraph
        this.SelectParagraphDown()
        DetectionStr := this.Vim.ParseLineBreaks(copy(false))
      }
      key := this.RevSurrKey(key, 2)
      if (AltKey := this.GetAltKey(key)) {
        pos := RegExMatch(DetectionStr, AltKey)
      } else {
        pos := InStr(DetectionStr, key,, 2)
      }
      send % "{left}+{right " . pos . "}"
      if (RestoreClip)
        Clipboard := ClipSaved
      this.MoveFinalize()
    }
  }

  RevSurrKey(key, step:=1) {
    if (step == 1) {
      key := (key == ")") ? "(" : key
      key := (key == "）") ? "（" : key
      key := (key == "}") ? "{" : key
      key := (key == "]") ? "[" : key
      key := (key == ">") ? "<" : key
    } else if (step == 2) {
      key := (key == "(") ? ")" : key
      key := (key == "（") ? "）" : key
      key := (key == "{") ? "}" : key
      key := (key == "[") ? "]" : key
      key := (key == "<") ? ">" : key
    }
    return key
  }

  FindPos(DetectionStr, text, Occurrence:=1) {
    if (AltText := this.GetAltKey(text)) {
      pos := RegExMatch(DetectionStr, "s)((" . AltText . ").*?){" . Occurrence - 1 . "}\K(" . AltText . ")")
    } else {
      pos := InStr(DetectionStr, text, true,, Occurrence)
    }
    return pos
  }

  FindSentenceEnd(DetectionStr, Occurrence:=1, reversed:=false) {
    if (pos := InStr(DetectionStr, "。",,, Occurrence)) {  ; chinese full stop
      pos := (pos > 1) ? pos - 1 : 1
      return pos
    }
    if (!reversed) {
      pos := RegExMatch(DetectionStr, "s)(\.((\[.*?\])+\s|[^\wÀ-ÖØ-öø-ÿ,]+).*?){" . Occurrence - 1 . "}\K\.((\[.*?\])+\s|[^\wÀ-ÖØ-öø-ÿ,]+)", v)
      if (pos)
        pos += StrLen(v) - 2
      this.v := v
      this.DetectionStr := DetectionStr
    } else {
      pos := RegExMatch(DetectionStr, "s)((\s(\].*?\[)+|[^\wÀ-ÖØ-öø-ÿ,]+)\..*?){" . Occurrence - 1 . "}\K(\s(\].*?\[)+|[^\wÀ-ÖØ-öø-ÿ,]+)\.")
    }
    return pos
  }

  FindWordBoundary(DetectionStr, Occurrence:=1, reversed:=false) {
    if (!reversed) {
      pos := RegExMatch(DetectionStr, "s)(([\wÀ-ÖØ-öø-ÿ]\b).*?){" . Occurrence - 1 . "}\K[\wÀ-ÖØ-öø-ÿ]\b")
    } else {
      pos := RegExMatch(DetectionStr, "s)((\b[\wÀ-ÖØ-öø-ÿ]).*?){" . Occurrence . "}\K\b[\wÀ-ÖØ-öø-ÿ]")
    }
    return pos
  }

  SMClickSyncButton() {
    if (WinActive("ahk_class TContents")) {
      ClickDPIAdjusted(295, 50)
      ; ControlClickWinCoord(295, 50)
    } else if (WinActive("ahk_class TBrowser")) {
      ClickDPIAdjusted(638, 46)
      ; ControlClickWinCoord(638, 46)
    }
  }

  GetAltKey(key) {  ; return is regex compatible
    if (key == """") {
      key := """|“|”"
    } else if (key == "'") {
      key := "'|‘|’"
    } else if (key == "(") {
      key := "\(|（"
    } else if (key == ")") {
      key := "\)|）"
    } else if (key == ".") {
      key := "\.|。"
    } else if (key == ",") {
      key := ",|，"
    } else {
      return
    }
    return key
  }
}