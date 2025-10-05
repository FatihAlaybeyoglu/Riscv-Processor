    .text
    .globl main
main:
    addi   t1, zero, 0        # i = 0
    addi   s3, zero, 20       # s3 = 20 (dış döngü sınırı)
    addi   s5, zero, 80       # s5 = count_array base address (80)
    addi   s4, zero, 32       # s4 = 32 (iç döngü sınırı)

loop_outer:
    beq    t1, s3, end_outer  # if i == 20 -> çık

    slli   t3, t1, 2          # t3 = i * 4 (adres offset)
    lw     t5, 0(t3)          # t5 = datamem[i]

    addi   t6, zero, 0        # t6 = dummy (bit sayacı)
    addi   s2, zero, 0        # s2 = j = 0
    addi   t0, zero, 1        # t0 = mask = 1

loop_inner:
    and    t4, t5, t0         # t4 = array[i] & mask
    beq    s2, s4, end_inner  # if j == 32 -> çık
    add   t0, t0, t0          # mask <<= 1 burada amacımız her bitin 1 olup olmadığını kontrol edebilmek
    addi   s2, s2, 1          # j++
    beq    t4, zero, not_one  # t6 sayacı arttırılmadan döngünün başına geçiliyor.
    addi   t6, t6, 1          # t6++

not_one:
    jal    t2, loop_inner     # return addr in t2 , t6 yı arttırmadan loop_innerdan devam eder.

end_inner:
    add    s6, s5, t3         # s6 = 80 + i*4
    sw     t6, 0(s6)          # count_array[i] = bit count

    addi   t1, t1, 1          # i++
    jal    t2, loop_outer     #iç döngü bitti dış döngüye geçiliyor.

end_outer:
    jal    t2, end_outer      # <-- sonsuz döngü, zero bozulmaz