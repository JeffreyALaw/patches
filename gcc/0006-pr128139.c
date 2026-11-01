diff --git a/gcc/config/riscv/riscv.cc b/gcc/config/riscv/riscv.cc
index bed695ccae4b..395c38ac008f 100644
--- a/gcc/config/riscv/riscv.cc
+++ b/gcc/config/riscv/riscv.cc
@@ -16841,10 +16841,14 @@ synthesize_add (rtx operands[3])
 
   /* No add synthesis was found.  Synthesize the constant into
      a temporary and use that.  */
-  rtx x = force_reg (word_mode, operands[2]);
-  x = gen_rtx_PLUS (word_mode, operands[1], x);
-  emit_insn (gen_rtx_SET (operands[0], x));
-  return true;
+  if (can_create_pseudo_p ())
+    {
+      rtx x = force_reg (word_mode, operands[2]);
+      x = gen_rtx_PLUS (word_mode, operands[1], x);
+      emit_insn (gen_rtx_SET (operands[0], x));
+      return true;
+    }
+  return false;
 }
 
 /*  Synthesize OPERANDS[0] = OPERANDS[1] + OPERANDS[2].
diff --git a/gcc/testsuite/gcc.target/riscv/pr128139.c b/gcc/testsuite/gcc.target/riscv/pr128139.c
new file mode 100644
index 000000000000..b18fb539bad4
--- /dev/null
+++ b/gcc/testsuite/gcc.target/riscv/pr128139.c
@@ -0,0 +1,12 @@
+/* { dg-do compile } */
+
+void b(char *);
+
+void a(long off, void *h)
+{
+  char buf[8192];
+  b(buf);
+  __builtin_eh_return (off, h);
+}
+
+
