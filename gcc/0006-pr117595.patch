diff --git a/gcc/config/riscv/riscv.cc b/gcc/config/riscv/riscv.cc
index 7694954c4c5..03271d893b6 100644
--- a/gcc/config/riscv/riscv.cc
+++ b/gcc/config/riscv/riscv.cc
@@ -3646,7 +3646,7 @@ riscv_legitimize_move (machine_mode mode, rtx dest, rtx src)
       rtx mask = force_reg (word_mode, gen_int_mode (-65536, word_mode));
       rtx temp = gen_reg_rtx (word_mode);
       emit_insn (gen_extend_insn (temp,
-				  simplify_gen_subreg (HImode, src, mode, 0),
+				  gen_lowpart (HImode, src),
 				  word_mode, HImode, 1));
       if (word_mode == SImode)
 	emit_insn (gen_iorsi3 (temp, mask, temp));
diff --git a/gcc/config/riscv/sync.md b/gcc/config/riscv/sync.md
index aa0c20446f4..23c0859e085 100644
--- a/gcc/config/riscv/sync.md
+++ b/gcc/config/riscv/sync.md
@@ -580,7 +580,7 @@ (define_expand "atomic_compare_and_swap<mode>"
 	 value is sign-extended.  */
       rtx tmp0 = gen_reg_rtx (word_mode);
       emit_insn (gen_extend_insn (tmp0, operands[3], word_mode, <MODE>mode, 0));
-      operands[3] = simplify_gen_subreg (<MODE>mode, tmp0, word_mode, 0);
+      operands[3] = gen_lowpart (<MODE>mode, tmp0);
     }
 
   if (TARGET_ZACAS)
diff --git a/gcc/testsuite/gcc.target/riscv/pr117595.c b/gcc/testsuite/gcc.target/riscv/pr117595.c
new file mode 100644
index 00000000000..a870df08ee4
--- /dev/null
+++ b/gcc/testsuite/gcc.target/riscv/pr117595.c
@@ -0,0 +1,5 @@
+/* { dg-do compile } */
+/* { dg-options "-mbig-endian" } */
+
+_Atomic enum { E0 } e;
+void foo() { e++; }
