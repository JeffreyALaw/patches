diff --git a/gcc/config/riscv/riscv.cc b/gcc/config/riscv/riscv.cc
index 93702f71ec9..a25fdf89e44 100644
--- a/gcc/config/riscv/riscv.cc
+++ b/gcc/config/riscv/riscv.cc
@@ -1315,6 +1315,34 @@ riscv_build_integer (struct riscv_integer_op *codes, HOST_WIDE_INT value,
 	  cost = alt_cost;
 	}
 
+      /* If bit31 is on and the upper constant is one less than the lower
+	 constant, then we can exploit sign extending nature of the lower
+	 half to trivially generate the upper half with an ADD.
+
+	 Not appropriate for ZBKB since that won't use "add"
+	 at codegen time.  */
+      if (!TARGET_ZBKB
+	  && cost > 4
+	  && bit31
+	  && hival == loval - 1)
+	{
+	  alt_cost = 2 + riscv_build_integer_1 (alt_codes,
+						sext_hwi (loval, 32), mode);
+	  alt_codes[alt_cost - 3].save_temporary = true;
+	  alt_codes[alt_cost - 2].code = ASHIFT;
+	  alt_codes[alt_cost - 2].value = 32;
+	  alt_codes[alt_cost - 2].use_uw = false;
+	  alt_codes[alt_cost - 2].save_temporary = false;
+	  /* This will turn into an ADD.  */
+	  alt_codes[alt_cost - 1].code = CONCAT;
+	  alt_codes[alt_cost - 1].value = 32;
+	  alt_codes[alt_cost - 1].use_uw = false;
+	  alt_codes[alt_cost - 1].save_temporary = false;
+
+	  memcpy (codes, alt_codes, sizeof (alt_codes));
+	  cost = alt_cost;
+	}
+
       if (cost > 4 && !bit31 && TARGET_ZBA)
 	{
 	  int value = 0;
diff --git a/gcc/testsuite/gcc.target/riscv/synthesis-16.c b/gcc/testsuite/gcc.target/riscv/synthesis-16.c
new file mode 100644
index 00000000000..352c48ec037
--- /dev/null
+++ b/gcc/testsuite/gcc.target/riscv/synthesis-16.c
@@ -0,0 +1,17 @@
+/* { dg-do compile } */
+/* { dg-require-effective-target rv64 } */
+/* We aggressively skip as we really just need to test the basic synthesis
+   which shouldn't vary based on the optimization level.  -O1 seems to work
+   and eliminates the usual sources of extraneous dead code that would throw
+   off the counts.  */
+/* { dg-skip-if "" { *-*-* } { "-O0" "-Og" "-O2" "-O3" "-Os" "-Oz" "-flto" } } */
+/* { dg-options "-march=rv64gc" } */
+
+/* Rather than test for a specific synthesis of all these constants or
+   having thousands of tests each testing one variant, we just test the
+   total number of instructions.
+
+   This isn't expected to change much and any change is worthy of a look.  */
+/* { dg-final { scan-assembler-times "\\t(add|addi|bseti|li|pack|ret|sh1add|sh2add|sh3add|slli|srli|xori|or)" 5 } } */
+
+unsigned long foo_0xcccccccccccccccd(void) { return 0xcccccccccccccccdUL; }
