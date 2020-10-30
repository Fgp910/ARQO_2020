# Prog de prueba para Práctica 2. Ej 2

.data 0
num0:  .word 1  # posic 0
num1:  .word 2  # posic 4
num2:  .word 4  # posic 8 
num3:  .word 8  # posic 12 

.text 0
main:
  lw $t1, 0($zero)  # lw $r9,  0($r0)  -> r9  = 1
  lw $t2, 4($zero)  # lw $r10, 4($r0)  -> r10 = 2
  lw $t3, 8($zero)  # lw $r11, 8($r0)  -> r11 = 4 
  lw $t4, 12($zero) # lw $r12, 12($r0) -> r12 = 8 
  nop
  nop
  nop
  nop

  # R-type antes de branch
  add $s0, $zero, $zero  
  beq $s0, $t1, salto1   # No salta
  add $s1, $zero, $zero
  beq $s1, $s1, salto1   # Salta
  add $t4, $t4, $t4      # No se debe ejecutar
  add $t4, $t4, $t4      # No se debe ejecutar
  add $t4, $t4, $t4      # No se debe ejecutar
  nop
  nop
  nop
  nop
  nop

  # Load antes de branch
  salto1:
  lw $s0, 0($zero)
  beq $s0, $zero, salto2 # No salta
  lw $s1, 4($zero)
  beq $s1, $s1, salto23  # Salta
  add $t4, $t4, $t4      # No se debe ejecutar
  add $t4, $t4, $t4      # No se debe ejecutar
  add $t4, $t4, $t4      # No se debe ejecutar 
  nop
  nop
  nop
  nop
  nop 

  # Cancelación del stall después de un branch efectivo
  salto2:
  beq $zero, $zero, final
  lw $s0, 8($zero)
  add $s1, $s0, $s0
  nop
  nop
  nop

  final: j final
