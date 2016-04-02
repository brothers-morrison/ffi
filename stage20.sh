#!/usr/bin/env bash

set -eu

source ctypes.sh

foo="$1"
>&2 echo "Stage 20: $foo"

dlopen ./libtcl8.6.so

dlcall Tcl_FindExecutable "string:$0"
dlcall -n interp -r pointer Tcl_CreateInterp
dlcall Tcl_Init $interp

dlcall Tcl_EvalFile $interp "stage21.tcl"


dlcall -n argbuf -r pointer malloc 16
blep="blep"
dlcall -n blepp -r pointer get_string_value blep
dlcall -n foop -r pointer get_string_value foo
args=($blepp $foop)
pack $argbuf args

dlcall -n args -r pointer Tcl_Merge 2 $argbuf
dlcall free $argbuf

dlcall Tcl_Eval $interp $args

dlcall Tcl_Free $args
dlcall -n resp -r pointer Tcl_GetStringResult $interp
bar="$(dlcall -r int puts $resp)"
dlcall Tcl_ResetResult $interp

>&2 echo "Return value [20]: $bar"
echo "$bar"

dlcall Tcl_Finalize
