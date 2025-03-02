

It fixes one of the PR108016 mis-optimization.

The patch adjusts expanding for __builtin_add/sub_overflow() on RV64 targets
to avoid unnecessary sext.w instructions.

It replaces expanded for ADD/SUB_OVERFLOW code:
  r141:SI=r139:DI#0+r140:DI#0 .. r143:DI=sign_extend(r141:SI)
to the followong kind of chain ->
  r143:DI=sign_extend(r139:DI#0+r140:DI#0) .. r141:SI=r143:DI#0
so that sign_extend(a:SI+b:SI) to be emitted as addw (or subw) instruction,
while output r141:SI register will be placed at the end of chain without
extra dependencies, and thus could be easily optimized-out by further pipeline.

gcc/ChangeLog:

	* config/riscv/riscv.md (addv<mode>4, uaddv<mode>4, subv<mode>4,
	  usubv<mode>4): Tunes for unnecessary sext.w elimination.

gcc/testsuite/ChangeLog:

	* gcc.target/riscv/pr108016.c: New test.

Signed-off-by: Alexey Merzlyakov <alexey.merzlyakov@samsung.com>
---
 gcc/config/riscv/riscv.md                 | 28 +++++++++++++------
 gcc/testsuite/gcc.target/riscv/pr108016.c | 33 +++++++++++++++++++++++
 2 files changed, 53 insertions(+), 8 deletions(-)
 create mode 100644 gcc/testsuite/gcc.target/riscv/pr108016.c

diff --git a/gcc/config/riscv/riscv.md b/gcc/config/riscv/riscv.md
index f7070766783..4271f9b6634 100644
--- a/gcc/config/riscv/riscv.md
+++ b/gcc/config/riscv/riscv.md
@@ -789,7 +789,7 @@
       rtx t5 = gen_reg_rtx (DImode);
       rtx t6 = gen_reg_rtx (DImode);
 
-      riscv_emit_binary (PLUS, operands[0], operands[1], operands[2]);
+      emit_insn (gen_addsi3_extended (t6, operands[1], operands[2]));
       if (GET_CODE (operands[1]) != CONST_INT)
 	emit_insn (gen_extend_insn (t4, operands[1], DImode, SImode, 0));
       else
@@ -799,7 +799,10 @@
       else
 	t5 = operands[2];
       emit_insn (gen_adddi3 (t3, t4, t5));
-      emit_insn (gen_extend_insn (t6, operands[0], DImode, SImode, 0));
+      rtx t7 = gen_lowpart (SImode, t6);
+      SUBREG_PROMOTED_VAR_P (t7) = 1;
+      SUBREG_PROMOTED_SET (t7, SRP_SIGNED);
+      emit_move_insn (operands[0], t7);
 
       riscv_expand_conditional_branch (operands[3], NE, t6, t3);
     }
@@ -835,8 +838,11 @@
 	emit_insn (gen_extend_insn (t3, operands[1], DImode, SImode, 0));
       else
 	t3 = operands[1];
-      riscv_emit_binary (PLUS, operands[0], operands[1], operands[2]);
-      emit_insn (gen_extend_insn (t4, operands[0], DImode, SImode, 0));
+      emit_insn (gen_addsi3_extended (t4, operands[1], operands[2]));
+      rtx t5 = gen_lowpart (SImode, t4);
+      SUBREG_PROMOTED_VAR_P (t5) = 1;
+      SUBREG_PROMOTED_SET (t5, SRP_SIGNED);
+      emit_move_insn (operands[0], t5);
 
       riscv_expand_conditional_branch (operands[3], LTU, t4, t3);
     }
@@ -966,7 +972,7 @@
       rtx t5 = gen_reg_rtx (DImode);
       rtx t6 = gen_reg_rtx (DImode);
 
-      riscv_emit_binary (MINUS, operands[0], operands[1], operands[2]);
+      emit_insn (gen_subsi3_extended (t6, operands[1], operands[2]));
       if (GET_CODE (operands[1]) != CONST_INT)
 	emit_insn (gen_extend_insn (t4, operands[1], DImode, SImode, 0));
       else
@@ -976,7 +982,10 @@
       else
 	t5 = operands[2];
       emit_insn (gen_subdi3 (t3, t4, t5));
-      emit_insn (gen_extend_insn (t6, operands[0], DImode, SImode, 0));
+      rtx t7 = gen_lowpart (SImode, t6);
+      SUBREG_PROMOTED_VAR_P (t7) = 1;
+      SUBREG_PROMOTED_SET (t7, SRP_SIGNED);
+      emit_move_insn (operands[0], t7);
 
       riscv_expand_conditional_branch (operands[3], NE, t6, t3);
     }
@@ -1015,8 +1024,11 @@
 	emit_insn (gen_extend_insn (t3, operands[1], DImode, SImode, 0));
       else
 	t3 = operands[1];
-      riscv_emit_binary (MINUS, operands[0], operands[1], operands[2]);
-      emit_insn (gen_extend_insn (t4, operands[0], DImode, SImode, 0));
+      emit_insn (gen_subsi3_extended (t4, operands[1], operands[2]));
+      rtx t5 = gen_lowpart (SImode, t4);
+      SUBREG_PROMOTED_VAR_P (t5) = 1;
+      SUBREG_PROMOTED_SET (t5, SRP_SIGNED);
+      emit_move_insn (operands[0], t5);
 
       riscv_expand_conditional_branch (operands[3], LTU, t3, t4);
     }
diff --git a/gcc/testsuite/gcc.target/riscv/pr108016.c b/gcc/testsuite/gcc.target/riscv/pr108016.c
new file mode 100644
index 00000000000..b60df42d02a
--- /dev/null
+++ b/gcc/testsuite/gcc.target/riscv/pr108016.c
@@ -0,0 +1,33 @@
+/* { dg-do compile } */
+/* { dg-options "-march=rv64gc -mabi=lp64" } */
+/* { dg-skip-if "" { *-*-* } { "-O0" } } */
+
+unsigned int addu (unsigned int a, unsigned int b)
+{
+  unsigned int out;
+  unsigned int overflow = __builtin_add_overflow (a, b, &out);
+  return overflow & out;
+}
+
+int addi (int a, int b)
+{
+  int out;
+  int overflow = __builtin_add_overflow (a, b, &out);
+  return overflow & out;
+}
+
+unsigned int subu (unsigned int a, unsigned int b)
+{
+  unsigned int out;
+  unsigned int overflow = __builtin_sub_overflow (a, b, &out);
+  return overflow & out;
+}
+
+int subi (int a, int b)
+{
+  int out;
+  int overflow = __builtin_sub_overflow (a, b, &out);
+  return overflow & out;
+}
+
+/* { dg-final { scan-assembler-not "sext\.w\t" } } */
-- 
2.34.1



