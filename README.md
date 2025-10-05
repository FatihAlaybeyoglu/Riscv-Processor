# ⚙️ RISC-V Tek Döngülü İşlemci Tasarımı

## 📘 Proje Özeti
Bu proje, **RISC-V mimarisi** tabanlı bir **tek döngülü işlemci (single-cycle CPU)** tasarımını ve onunla çalışan bir **assembly programını** içermektedir.  
Tasarımın amacı, RISC-V’in temel bileşenlerini (ALU, kontrol birimi, kayıt dosyası, bellek birimleri, program sayacı vb.) kullanarak **tamamen çalışabilir bir işlemci modeli** oluşturmaktır.

Proje aynı zamanda özel bir assembly kodu (`23011009.asm`) çalıştırarak **her bir 32 bit sayının içindeki 1 bitlerinin sayısını hesaplayan** bir simülasyon yapar.

---

## 🧩 Dosya Yapısı

| Dosya | Açıklama |
|-------|-----------|
| `23011009.asm` | RISC-V assembly programı. Her sayının içindeki `1` bitlerinin sayısını hesaplar. |
| `23011009_instr.txt` | Assembly kodunun makine dili karşılığı (hex formatında). Instruction memory’ye yüklenir. |
| `23011009_riscv_core.v` | İşlemcinin ana modülü. Tüm alt modülleri birbirine bağlar. |
| `23011009_controlunit.v` | Komutlara göre kontrol sinyallerini üretir (`RegWrite`, `ALUOp`, `MemRead`, vb.). |
| `23011009_alu.v` | Aritmetik ve mantıksal işlemleri gerçekleştirir (`add`, `sub`, `and`, `or`, `slt`, vb.). |
| `23011009_regfile.v` | 32 adet register’ı (x0–x31) tutar. Yazma ve okuma işlemleri burada yapılır. |
| `23011009_instructionmemory.v` | `instr.txt` dosyasını okuyarak komut belleğini oluşturur. |
| `23011009_datamemory.v` | Bellek erişim işlemleri (`lw`, `sw`) için veri belleği modülü. |
| `23011009_pccounter.v` | Program Sayacı (PC). Her saat döngüsünde bir sonraki komutu seçer. |
| `testbench23011009_tb.v` | İşlemciyi test eden testbench dosyası. Assembly kodunu yükleyip tüm modülleri simüle eder. |

---

## 🧠 Assembly Programın Mantığı (`23011009.asm`)

Programın işlevi:  
**Bellekteki 20 adet 32 bit sayının her birindeki ‘1’ bitlerinin sayısını bulmak ve bu değerleri başka bir dizide saklamak.**

### Akış:

1. `i` dış döngü değişkeni (0 → 19)  
2. `j` iç döngü değişkeni (0 → 31)  
3. Her sayı `datamem[i]` adresinden alınır.  
4. `t0` maskesi (`1`) her iterasyonda sola kaydırılarak (`<<=1`) her bit kontrol edilir.  
5. Eğer `(array[i] & mask) ≠ 0` ise `t6` (sayacı) 1 artırılır.  
6. `count_array[i] = t6` olarak belleğe yazılır.

Sonunda `count_array` dizisi, her sayının bit sayısını içerir.

---

## 🧮 Örnek Pseudo Kod

```c
for (i = 0; i < 20; i++) {
    t5 = datamem[i];
    count = 0;
    for (j = 0; j < 32; j++) {
        if ((t5 & (1 << j)) != 0)
            count++;
    }
    count_array[i] = count;
}
```

---

## 💾 Verilog Modülleri Arasındaki İlişki

```
┌──────────────────────────┐
│      riscv_core.v        │
│ ┌──────────────────────┐ │
│ │   pccounter.v        │ │  → PC adresini tutar
│ ├──────────────────────┤ │
│ │ instructionmemory.v  │ │  → Komutu getirir
│ ├──────────────────────┤ │
│ │   controlunit.v      │ │  → Kontrol sinyallerini üretir
│ ├──────────────────────┤ │
│ │      alu.v           │ │  → Hesaplama işlemlerini yapar
│ ├──────────────────────┤ │
│ │     regfile.v        │ │  → Register dosyası
│ ├──────────────────────┤ │
│ │    datamemory.v      │ │  → Bellek erişimi
│ └──────────────────────┘ │
└──────────────────────────┘
```

Tüm bu modüller **tek bir clock döngüsü** içinde bir RISC-V komutunu tamamlar.

---

## 🧪 Örnek Test Senaryosu (Testbench)

### Komut Belleği
`23011009_instr.txt` dosyası aşağıdaki makine komutlarını içerir:
```
00000313
01400993
05000a93
02000a13
05330263
00231e13
000e2f03
00000f93
00000913
00100293
005f7eb3
01490c63
005282b3
00190913
000e8463
001f8f93
fe9ff3ef
01ca8b33
01fb2023
00130313
fc1ff3ef
000003ef
```

### Testbench Akışı (`testbench23011009_tb.v`)
- Komut belleğini (`instr.txt`) yükler.  
- Her clock döngüsünde bir komutu çalıştırır.  
- Register ve Data Memory içerikleri gözlemlenir.  
- Simülasyon sonunda `count_array` kontrol edilir.

---

## 🧰 Derleme ve Simülasyon

### Derleme
```bash
iverilog -o riscv_cpu 23011009_riscv_core.v 23011009_controlunit.v 23011009_regfile.v 23011009_pccounter.v 23011009_instructionmemory.v 23011009_datamemory.v 23011009_alu.v testbench23011009_tb.v
```

### Çalıştırma
```bash
vvp riscv_cpu
```

### Dalga (Waveform) Görüntüleme
```bash
gtkwave riscv_cpu.vcd
```

---

## 🧠 Notlar
- Bu işlemci **tek döngülüdür**: her komut bir clock çevriminde tamamlanır.  
- `jal` komutları döngü oluşturmak için kullanılmıştır.  
- `zero` register’ı (x0) her zaman 0’dır — değiştirilmez.  
- Testbench simülasyonu sonunda `count_array` belleğinde her sayının bit sayısı gözlemlenebilir.  

---

## 🏁 Sonuç
Bu proje, **RISC-V işlemci mimarisinin temelini** oluşturan bileşenlerin nasıl bir araya geldiğini göstermektedir.  
Kapsamlı bir şekilde:
- **Control path** (kontrol sinyalleri),
- **Datapath** (veri akışı),
- **Bellek işlemleri**,  
- ve **assembly komutlarının donanım karşılığı** detaylı biçimde simüle edilmiştir.  

Sonuç olarak, bu işlemci örneği **eğitim amaçlı bir tek döngü RISC-V CPU modelidir.**
