# Elaborato AdE 2023-2024

## SIS

Run testbench:

```bash
sis -f testbench.script -x | grep Outputs: > output_sis.txt
```

{ printf "\n\n"; sis -f testbench.script -x | grep Outputs:; } > output_sis.txt
