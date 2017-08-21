GCC=gcc
LUSTREC=/home/shizue/internship/cocosim2-stdlib/tools/verifiers/linux/bin/lustrec
LUSTREC_BASE=/home/shizue/internship/cocosim2-stdlib/tools/verifiers/linux
INC=${LUSTREC_BASE}/include/lustrec

Copy_of_safe_1_PP_Copy_of_safe_1_PP: Copy_of_safe_1_PP.c Copy_of_safe_1_PP_main.c
	${GCC} -O0 -I${INC} -I. -c Copy_of_safe_1_PP.c
	${GCC} -O0 -I${INC} -I. -c Copy_of_safe_1_PP_main.c
	${GCC} -I${INC} -c ${INC}/io_frontend.c
	${GCC} -O0 -o Copy_of_safe_1_PP_Copy_of_safe_1_PP io_frontend.o  Copy_of_safe_1_PP.o Copy_of_safe_1_PP_main.o 

clean:
	\rm -f *.o Copy_of_safe_1_PP_Copy_of_safe_1_PP

.PHONY: Copy_of_safe_1_PP_Copy_of_safe_1_PP

FRAMACEACSL=`frama-c -print-share-path`/e-acsl
Copy_of_safe_1_PP_eacsl.c: Copy_of_safe_1_PP.c Copy_of_safe_1_PP.h
	frama-c -e-acsl-full-mmodel -machdep x86_64 -e-acsl Copy_of_safe_1_PP.c -then-on e-acsl -print -ocode Copy_of_safe_1_PP_eacsl.c


Copy_of_safe_1_PP_main_eacsl.c: Copy_of_safe_1_PP.c Copy_of_safe_1_PP.h Copy_of_safe_1_PP_main.c
	frama-c -e-acsl-full-mmodel -machdep x86_64 -e-acsl Copy_of_safe_1_PP.c Copy_of_safe_1_PP_main.c -then-on e-acsl -print -ocode Copy_of_safe_1_PP_main_eacsl.i
	grep -v _fc_stdout Copy_of_safe_1_PP_main_eacsl.i > Copy_of_safe_1_PP_main_eacsl.c

Copy_of_safe_1_PP_main_eacsl: Copy_of_safe_1_PP_main_eacsl.c
	${GCC} -Wno-attributes -I${INC} -I. -c Copy_of_safe_1_PP_main_eacsl.c
	${GCC} -I${INC} -c ${INC}/io_frontend.c
	${GCC} -Wno-attributes -o Copy_of_safe_1_PP_main_eacsl io_frontend.o  ${FRAMACEACSL}/e_acsl.c ${FRAMACEACSL}/memory_model/e_acsl_bittree.c ${FRAMACEACSL}/memory_model/e_acsl_mmodel.c Copy_of_safe_1_PP_main_eacsl.o 


