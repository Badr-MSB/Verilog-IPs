## Terminogy :

co-processors : is a specialized processing unit that works alongside a main CPU to handle specific types of computations more efficiently than the general-purpose CPU (FPU ...). RISC-V allows custom co-processors via its Custom Extension (Zc) feature.

caching masters : masters that have caches.

non-caching masters : masters without caches.

Hint operations : are special NOP-like (No Operation) instructions that provide guidance to the processor but do not change the architectural state (NOP, Prefetching (pld instruction in ARM), Power Management, Branch Prediction Hints).

Multibeat messages : a message that needs more that in clock cycle to be sent.

memory consistency model : big topic to be studied later.

# ECC protection :
Error-Correcting Code protection. used to detect data errors.

# Cycle stealing : 
Cycle stealing is a technique used by a DMA controller (or other peripheral) to temporarily take control of the CPU's bus to transfer a small chunk of data without fully blocking the CPU.

📊 Analogy
Imagine the CPU is driving on a road (the bus), and the DMA is a small scooter:

Without cycle stealing: The DMA stops the CPU entirely to use the whole road (burst mode).

With cycle stealing: The DMA just sneaks in between cars for a quick turn, then gets out — so the CPU keeps mostly driving.

LSIO : low speed input output (I2C, SPI, UART ...)

# Dependency 

FuseSoc

Verilator