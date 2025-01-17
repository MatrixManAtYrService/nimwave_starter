when not defined(emscripten):
  {.error: "You must set -d:emscripten to build for the web".}

from nimwave/web import nil
from nimwave/web/emscripten import nil
from web/core import nil
import tables, unicode

proc onKeyDown(eventType: cint, keyEvent: ptr emscripten.EmscriptenKeyboardEvent, userData: pointer) {.cdecl.} =
  let
    key = $cast[cstring](keyEvent.key.addr)
    keys = key.toRunes
  if keys.len == 1:
    if keyEvent.ctrlKey == 0 and keyEvent.altKey == 0 and keyEvent.metaKey == 0:
      core.onChar(uint32(keys[0]))
    elif keyEvent.ctrlKey == 1 and key in web.nameToIllwaveCtrlKey:
      core.onKeyPress(web.nameToIllwaveCtrlKey[key])
  elif keys.len > 1:
    if key in web.nameToIllwaveKey:
      core.onKeyPress(web.nameToIllwaveKey[key])

proc mainLoop() {.cdecl.} =
  try:
    core.tick()
  except Exception as ex:
    stderr.writeLine(ex.msg)
    stderr.writeLine(getStackTrace(ex))

proc main() =
  core.init()
  discard emscripten.emscripten_set_keydown_callback("body", nil, true, onKeyDown)
  emscripten.emscripten_set_main_loop(mainLoop, 0, true)

when isMainModule:
  main()

