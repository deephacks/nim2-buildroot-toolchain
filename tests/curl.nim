import libcurl, os

proc curlWriteFn(buffer: cstring, size: int, count: int, outstream: pointer): int =
  let outbuf = cast[ref string](outstream)
  outbuf[] &= buffer
  result = size * count

when isMainModule:  
  let data: ref string = new string
  let curl = easy_init()
  var url = if paramCount() > 0: paramStr(1) else: ""
  discard curl.easy_setopt(OPT_USERAGENT, "Mozilla/5.0")
  discard curl.easy_setopt(OPT_VERBOSE, 1)
  discard curl.easy_setopt(OPT_HTTPGET, 1)
  discard curl.easy_setopt(OPT_WRITEDATA, data)
  discard curl.easy_setopt(OPT_WRITEFUNCTION, curlWriteFn)
  discard curl.easy_setopt(OPT_URL, url)

  let ret = curl.easy_perform()
  let str = $data[]
  if ret == E_OK:
    echo str

  else:
    if str.len != 0: stderr.writeLine(str)
    quit($ret & ": " & url, 1)
