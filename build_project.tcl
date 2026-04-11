# scripts/create_project.tcl
# Usage:
#   vivado -mode batch -source build_project.tcl -tclargs <Name>

proc normpath {p} { return [file normalize $p] }
proc rglob {dir pattern} {
  set out {}
  foreach f [glob -nocomplain -directory $dir -types f $pattern] {
    lappend out $f
  }
  foreach d [glob -nocomplain -directory $dir -types d *] {
    set out [concat $out [rglob $d $pattern]]
  }
  return $out
}

set repo_root [file normalize [file dirname [info script]]]
set proj_name [lindex $argv 0]
if {$proj_name eq ""} { set proj_name "Risc-V-Wearable" }

# BASYS 3 FPGA
set part_name "xc7a35tcpg236-1" 

set build_dir [normpath [file join $repo_root build $proj_name]]
file mkdir $build_dir

puts "INFO: info script  = [info script]"
puts "INFO: cwd          = [pwd]"
puts "INFO: argv         = $argv"
puts "INFO: proj_name    = $proj_name"
puts "INFO: repo_root    = $repo_root"
puts "INFO: build_dir    = $build_dir"

create_project $proj_name $build_dir -part $part_name
set_property board_part digilentinc.com:basys3:part0:1.2 [current_project]

set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]
set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]

# ---- Add RTL sources ----
set rtl_dir [file join $repo_root RTL]
set rtl_files [glob -nocomplain -directory $rtl_dir -types f \
  *.v *.sv *.vhd *.vh *.svh]
if {[llength $rtl_files] == 0} {
  puts "WARNING: No RTL files found in $rtl_dir"
} else {
  add_files -norecurse $rtl_files
}

# ---- Add constraints ----
set xdc_dir [file join $repo_root Constraints]
set xdc_files [glob -nocomplain -directory $xdc_dir -types f *.xdc]
if {[llength $xdc_files] != 0} {
  add_files -fileset constrs_1 -norecurse $xdc_files
}

# ---- Add SIM sources ----
set sim_dir [file join $repo_root Simulation]
set sim_files [glob -nocomplain -directory $sim_dir -types f \
  *.v *.sv *.vhd *.vh *.svh]
if {[llength $sim_files] == 0} {
  puts "WARNING: No SIM files found in $sim_dir"
} else {
  add_files -fileset sim_1 -norecurse $sim_files
}

# ---- Add IP (.xci) instantiated in RTL ----
set ip_dir   [file join $repo_root IPs]
set ip_stage [file join $build_dir imported_ips]
file mkdir $ip_stage

set xci_files [rglob $ip_dir *.xci]

if {[llength $xci_files] != 0} {
  # Copy XCI into build tree so Vivado can write/upgrade/generate products freely
  set staged_xci {}
  foreach xci $xci_files {

    # Preserve relative path under IPs/ to avoid name collisions (fifo.xci, ila.xci, etc.)
    if {[catch {set rel [file relativize $ip_dir $xci]}]} {
      # Fallback if 'file relativize' isn't supported in your Vivado Tcl
      set rel [string range $xci [expr {[string length $ip_dir] + 1}] end]
    }

    set dst [file join $ip_stage $rel]
    file mkdir [file dirname $dst]
    file copy -force $xci $dst
    lappend staged_xci $dst
  }

  add_files -norecurse $staged_xci

  # Only operate on the staged XCI objects we just added
  set xci_objs [get_files -quiet $staged_xci]

  # Bring IPs up to date for this Vivado version and generate products
  upgrade_ip -quiet [get_ips]
  generate_target all $xci_objs

  # Optional but helpful for CI / clean checkouts
  export_ip_user_files -of_objects $xci_objs -no_script -sync -force

  # Debug helper: tells you exactly why something is locked, if it still happens
  report_ip_status -name ip_status.rpt

  # If you use Out-of-Context IP runs, uncomment:
  # create_ip_run $xci_objs
} else {
  puts "WARNING: No .xci files found under $ip_dir (including subdirs)"
}

# ---- Recreate Block Designs ----
set bd_tcl_dir [file join $repo_root BD]
set bd_tcl_files [glob -nocomplain -directory $bd_tcl_dir -types f *.tcl]

if {[llength $bd_tcl_files] == 0} {
  puts "WARNING: No BD Tcl files found under $bd_tcl_dir"
} else {
  foreach bd_tcl $bd_tcl_files {
    puts "INFO: Sourcing BD Tcl: $bd_tcl"
    source $bd_tcl
  }

  # Collect only top-level BDs, not scoped/generated nested BDs
  set bd_files {}
  foreach bd [get_files *.bd] {
    set bd_norm [file normalize $bd]

    if {[string match "*/.gen/*" $bd_norm]} {
      continue
    }
    if {[regexp {[/\\]ip[/\\].*[/\\]bd_[^/\\]+\.bd$} $bd_norm]} {
      continue
    }

    lappend bd_files $bd
  }

  foreach bd $bd_files {
    puts "INFO: Finalizing Block Design $bd"
    open_bd_design $bd
    validate_bd_design
    save_bd_design
    generate_target all [get_files $bd]
    make_wrapper -files [get_files $bd] -top

    set bd_dirname [file dirname $bd]
    set wrappers [concat \
      [glob -nocomplain [file join $bd_dirname hdl *_wrapper.v]] \
      [glob -nocomplain [file join $bd_dirname hdl *_wrapper.vhd]]]

    if {[llength $wrappers] != 0} {
      add_files -norecurse $wrappers
    } else {
      puts "WARNING: No wrapper generated for $bd"
    }

    set cur_bd [current_bd_design -quiet]
    if {$cur_bd ne ""} {
      close_bd_design $cur_bd
    }
  }
}

set_property top top [current_fileset]
set_property top PipelineTester [get_filesets sim_1]

update_compile_order -fileset sim_1
update_compile_order -fileset sources_1

puts "Project created at: $build_dir/$proj_name.xpr"