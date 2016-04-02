#!/usr/bin/env tclsh8.6 

package ifneeded Ffidl 0.6 [list load /home/jaseg/ffi/Ffidl/libFfidl0.6.so]
package require Ffidl

namespace eval ::ffidl {
        namespace export *
        namespace ensemble create
}

set lua libluajit-5.1.so

set luaL_newstate_sym   [ffidl symbol $lua luaL_newstate]
set luaL_openlibs_sym   [ffidl symbol $lua luaL_openlibs]
set luaL_loadfilex_sym  [ffidl symbol $lua luaL_loadfilex]
set lua_getfield_sym    [ffidl symbol $lua lua_getfield]
set lua_pushstring_sym  [ffidl symbol $lua lua_pushstring]
set lua_pcall_sym       [ffidl symbol $lua lua_pcall]
set lua_tolstring_sym   [ffidl symbol $lua lua_tolstring]
set lua_settop_sym      [ffidl symbol $lua lua_settop]
set lua_close_sym       [ffidl symbol $lua lua_close]

ffidl callout luaL_newstate     {} pointer                                          $luaL_newstate_sym
ffidl callout luaL_openlibs     {pointer} int                                       $luaL_openlibs_sym
ffidl callout luaL_loadfilex    {pointer pointer-utf8 pointer}      int             $luaL_loadfilex_sym
ffidl callout lua_getfield      {pointer int pointer-utf8}          int             $lua_getfield_sym
ffidl callout lua_pushstring    {pointer pointer-utf8}              int             $lua_pushstring_sym
ffidl callout lua_pcall         {pointer int int int}               int             $lua_pcall_sym
ffidl callout lua_tolstring     {pointer int pointer}               pointer-utf8    $lua_tolstring_sym
ffidl callout lua_settop        {pointer int}                       int             $lua_settop_sym
ffidl callout lua_close         {pointer}                           int             $lua_close_sym

proc blep {foo} {
    puts stderr "Stage 21: $foo"

    set lst [luaL_newstate]
    luaL_openlibs   $lst
    luaL_loadfilex  $lst "/home/jaseg/ffi/stage22.lua" 0
    lua_pcall       $lst 0 -1 0

    lua_getfield    $lst -10002 "blep"
    lua_pushstring  $lst $foo
    lua_pcall       $lst 1 1 0
    set bar [lua_tolstring   $lst -1 0]
    lua_settop      $lst -2

    lua_close       $lst

    puts stderr "Return value \[21\]: $bar"
    return $bar
}

