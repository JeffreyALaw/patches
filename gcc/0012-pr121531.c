diff --git a/gcc/config/riscv/sifive-p400.md b/gcc/config/riscv/sifive-p400.md
index d6f6e2a3b6c0..0acdbdab31e5 100644
--- a/gcc/config/riscv/sifive-p400.md
+++ b/gcc/config/riscv/sifive-p400.md
@@ -181,3 +181,18 @@ (define_bypass 1 "sifive_p400_i2f"
 (define_bypass 1 "sifive_p400_f2i"
   "sifive_p400_branch,sifive_p400_sfb_alu,sifive_p400_mul,
    sifive_p400_div,sifive_p400_alu,sifive_p400_cpop")
+
+
+;; Someone familiar with the p400 uarch needs to put
+;; these into the right reservations.  This is just a placeholder
+;; for everything I found that had no mapping to a reservation.
+;;
+;; Note that even if the processor does not implementat a particular
+;; instruction it should still have suitable reservations, even if
+;; they are just dummies like this one.
+(define_insn_reservation "sifive_p400_unknown" 1
+  (and (eq_attr "tune" "sifive_p400")
+       (eq_attr "type" "ghost,vfrecp,vclmul,vldm,vmffs,vclmulh,vlsegde,vfcvtitof,vsm4k,vfcvtftoi,vfdiv,vsm3c,vsm4r,viwmuladd,vfwredu,vcpop,vfwmuladd,vstux,vsshift,vfwcvtftof,vfncvtftof,vfwmaccbf16,vext,vssegte,rdvl,vaeskf1,vfslide1up,vmov,vimovvx,vaesef,vfsqrt,viminmax,vfwcvtftoi,vssegtox,vfclass,viwmul,vector,vgmul,vsm3me,vfcmp,vstm,vfredo,vfwmul,vaeskf2,vstox,vfncvtbf16,vislide1up,vgather,vldox,viwred,vctz,vghsh,vsts,vslidedown,vfmerge,vicmp,vsmul,vlsegdff,vfalu,vfmov,vislide1down,vfminmax,vcompress,vldr,vldff,vlsegdux,vimuladd,vsalu,vidiv,sf_vqmacc,vfslide1down,vaesem,vimerge,vfncvtftoi,vfwcvtitof,vicalu,vaesz,sf_vc_se,vsha2cl,vmsfs,vldux,vmidx,vslideup,vired,vlde,vfwredo,vfmovfv,vbrev,vfncvtitof,rdfrm,vsetvl,vssegts,vimul,vialu,vbrev8,vfwalu,rdvlenb,sf_vfnrclip,vclz,vnclip,sf_vc,vimov,vste,vfmuladd,vfmovvf,vwsll,vsetvl_pre,vlds,vlsegds,vmiota,vmalu,wrvxrm,wrfrm,viwalu,vaesdm,vssegtux,vaesdf,vimovxv,vror,vnshift,vstr,vaalu,vsha2ms,crypto,vfwcvtbf16,vlsegdox,vrol,vandn,vfsgnj,vmpop,vfredu,vsha2ch,vshift,vrev8,vfmul"))
+  "p400_int_pipe+sifive_p400_ialu")
+
+
diff --git a/gcc/config/riscv/sifive-p600.md b/gcc/config/riscv/sifive-p600.md
index ff51149f9b70..ccd006d16ed7 100644
--- a/gcc/config/riscv/sifive-p600.md
+++ b/gcc/config/riscv/sifive-p600.md
@@ -185,3 +185,15 @@ (define_bypass 1 "sifive_p600_i2f"
 (define_bypass 1 "sifive_p600_f2i"
   "sifive_p600_branch,sifive_p600_sfb_alu,sifive_p600_mul,
    sifive_p600_div,sifive_p600_alu,sifive_p600_cpop")
+
+;; Someone familiar with the p600 uarch needs to put
+;; these into the right reservations.  This is just a placeholder
+;; for everything I found that had no mapping to a reservation.
+;;
+;; Note that even if the processor does not implementat a particular
+;; instruction it should still have suitable reservations, even if
+;; they are just dummies like this one.
+(define_insn_reservation "sifive_p600_unknown" 1
+  (and (eq_attr "tune" "sifive_p600")
+       (eq_attr "type" "vicmp,vssegte,vbrev8,vfwalu,vimov,vmpop,vaesdf,vislide1up,vror,vsha2cl,vrol,vslideup,vimuladd,vclmul,vaesef,vext,vlsegdff,vfmuladd,vfclass,vmsfs,vfcmp,vsmul,vsm3me,vmalu,vshift,viwmuladd,vfslide1up,vlsegde,vsm4k,wrvxrm,vislide1down,vsm3c,vfwmuladd,vaesdm,vclmulh,vfwcvtftof,vfwredu,vfredo,sf_vfnrclip,vaesz,vwsll,vmiota,vctz,vsetvl_pre,vstm,vidiv,vssegtux,vfwmul,vcompress,vste,vired,vlsegds,vaesem,vfminmax,ghost,vandn,crypto,vfmul,vialu,vfmovvf,rdfrm,vldff,vfmerge,vsshift,vnclip,sf_vqmacc,vnshift,vfdiv,vfslide1down,vfncvtitof,vfsqrt,vimovxv,vstr,vfwcvtbf16,vfwcvtitof,vbrev,vssegtox,vssegts,vcpop,vmffs,viwmul,vldr,vmidx,rdvlenb,vfalu,vslidedown,vlde,vfsgnj,vfmov,viwalu,vsha2ch,vfncvtbf16,vfcvtitof,rdvl,vsetvl,vsha2ms,vector,vstux,vimerge,vclz,sf_vc,vfcvtftoi,viminmax,vsm4r,sf_vc_se,wrfrm,vstox,vfmovfv,vfncvtftoi,vimul,vsalu,vmov,vgmul,vgather,vldux,vlsegdox,vfncvtftof,vimovvx,vghsh,vldm,vldox,vfwcvtftoi,vlds,vfrecp,vaeskf2,vsts,vfredu,vicalu,vaalu,vfwmaccbf16,vrev8,vfwredo,vlsegdux,viwred,vaeskf1"))
+  "int_pipe+sifive_p600_ialu")
diff --git a/gcc/testsuite/gcc.target/riscv/pr121531.c b/gcc/testsuite/gcc.target/riscv/pr121531.c
new file mode 100644
index 000000000000..32c695706d8b
--- /dev/null
+++ b/gcc/testsuite/gcc.target/riscv/pr121531.c
@@ -0,0 +1,5 @@
+/* { dg-do compile } */
+/* { dg-additional-options "-mcpu=sifive-p670" } */
+
+__attribute__((__vector_size__(sizeof(int)))) int v;
+void foo() { v &= 1; }
