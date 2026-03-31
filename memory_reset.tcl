# Assumes Vivado project is already open

if {[current_project -quiet] eq ""} {
    error "No project is currently open."
}

puts "Current project: [current_project]"
puts "Locating memory IPs..."

# Change this if names are changed or more blocks are added
set mem_names {blk_mem_gen_0 Instruction_Memory}
set mem_ips {}

foreach name $mem_names {
    set ip [get_ips -quiet $name]
    if {[llength $ip] == 0} {
        puts "WARNING: IP '$name' not found"
    } else {
        puts "INFO: Found IP '$name'"
        lappend mem_ips $ip
    }
}

if {[llength $mem_ips] == 0} {
    error "No memory IPs found. Aborting."
}

foreach ip $mem_ips {
    puts "INFO: reset_target all $ip"
    reset_target all $ip
}

generate_target all $mem_ips

export_ip_user_files \
    -of_objects $mem_ips \
    -no_script \
    -sync \
    -force

reset_run Instruction_Memory_synth_1
reset_run synth_1
launch_runs synth_1 -jobs 8

launch_runs impl_1 -to_step write_bitstream -jobs 8