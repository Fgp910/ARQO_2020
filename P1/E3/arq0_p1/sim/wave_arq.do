onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /processor_tb/i_processor/Clk
add wave -noupdate /processor_tb/i_processor/Reset
add wave -noupdate -radix decimal /processor_tb/i_processor/PC_reg
add wave -noupdate /processor_tb/i_processor/Instruction
add wave -noupdate -divider Regs
add wave -noupdate -expand /processor_tb/i_processor/RegsMIPS/regs
add wave -noupdate -divider DataMem
add wave -noupdate /processor_tb/i_processor/DAddr
add wave -noupdate /processor_tb/i_processor/DRdEn
add wave -noupdate /processor_tb/i_processor/DWrEn
add wave -noupdate /processor_tb/i_processor/DDataOut
add wave -noupdate /processor_tb/i_processor/DDataIn
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {517 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 253
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {399 ns} {714 ns}
