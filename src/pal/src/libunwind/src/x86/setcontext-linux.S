/* libunwind - a platform-independent unwind library
   Copyright (C) 2007 Google, Inc
	Contributed by Arun Sharma <arun.sharma@google.com>
   Copyright (C) 2010 Konstantin Belousov <kib@freebsd.org>

This file is part of libunwind.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  */

#include "offsets.h"

/*  int _Ux86_setcontext (const ucontext_t *ucp)

  Restores the machine context provided.
  Unlike the libc implementation, doesn't clobber %rax

*/

	.global _Ux86_setcontext
	.type _Ux86_setcontext, @function
_Ux86_setcontext:
	.cfi_startproc
	movl	4(%esp),%eax	/* ucontext_t* */

	/* restore FP state */
	movl	LINUX_UC_FPREGS_MEM_OFF(%eax), %ecx
	fldenv	(%ecx)
	
	/* restore FS */
	movl	(LINUX_UC_MCONTEXT_OFF+LINUX_SC_FS_OFF)(%eax), %ecx

	movl	%ecx, %fs
	
	/* new stack */
	movl	(LINUX_UC_MCONTEXT_OFF+LINUX_SC_ESP_OFF)(%eax), %esp

	/* push the return address on the stack */
	movl	(LINUX_UC_MCONTEXT_OFF+LINUX_SC_EIP_OFF)(%eax), %ecx
	pushl	%ecx

	/* restore GPRs */
	movl	(LINUX_UC_MCONTEXT_OFF+LINUX_SC_EDI_OFF)(%eax), %edi
	movl	(LINUX_UC_MCONTEXT_OFF+LINUX_SC_ESI_OFF)(%eax), %esi
	movl	(LINUX_UC_MCONTEXT_OFF+LINUX_SC_EBP_OFF)(%eax), %ebp
	movl	(LINUX_UC_MCONTEXT_OFF+LINUX_SC_EBX_OFF)(%eax), %ebx
	movl	(LINUX_UC_MCONTEXT_OFF+LINUX_SC_EDX_OFF)(%eax), %edx
	movl	(LINUX_UC_MCONTEXT_OFF+LINUX_SC_ECX_OFF)(%eax), %ecx
	movl	(LINUX_UC_MCONTEXT_OFF+LINUX_SC_EAX_OFF)(%eax), %eax /* should be 0 */

	ret
	
	.cfi_endproc
	.size _Ux86_setcontext, . - _Ux86_setcontext
	
	/* We do not need executable stack.  */
	.section        .note.GNU-stack,"",@progbits
