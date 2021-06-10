# utls.m4 - TLS offload support
#
# Copyright (C) Mellanox Technologies Ltd. 2001-2021. ALL RIGHTS RESERVED.
# See file LICENSE for terms.
#

##########################
# UTLS acceleration support
#
AC_DEFUN([UTLS_CAPABILITY_SETUP],
[
AC_ARG_ENABLE([utls],
    AS_HELP_STRING([--enable-utls],
                   [Enable UTLS acceleration support (default=auto)]),
    [],
    [enable_utls=auto]
)

vma_cv_dpcp_1_1_3=0
AS_IF([test "$vma_cv_dpcp" -ne 0],
    [
    AC_LANG_PUSH([C++])
    AC_LINK_IFELSE([AC_LANG_PROGRAM([[#include <mellanox/dpcp.h>]],
         [[dpcp::tis* _tis;
           dpcp::dek* _dek;
           dpcp::encryption_key_type_t type = dpcp::ENCRYPTION_KEY_TYPE_TLS;
           dpcp::tis_flags flag = dpcp::TIS_TLS_EN;
           (void)_tis; (void)_dek;
           (void)type; (void)flag;]])],
         [vma_cv_dpcp_1_1_3=1])
    AC_LANG_POP()
    ])

AS_IF([test "$vma_cv_dpcp_1_1_3" -eq 0],
    [
    AS_IF([test "x$enable_utls" == xauto],
        [enable_utls=no])
    AS_IF([test "x$enable_utls" == xyes],
        [
        AC_MSG_CHECKING([for utls support])
        AC_MSG_ERROR([utls requires dpcp 1.1.3 or later, see --with-dpcp])
        ])
    ])

vma_cv_utls=0
AS_IF([test "x$enable_utls" != xno],
    [
    AC_CHECK_HEADER(
        [linux/tls.h],
        [AC_LINK_IFELSE([AC_LANG_PROGRAM([[#include <linux/tls.h>]],
             [[int flag = TLS_TX;
               (void)flag;]])],
             [vma_cv_utls=1])
        ])
    ])

AC_MSG_CHECKING([for utls support])
if test "$vma_cv_utls" -ne 0; then
    AC_DEFINE_UNQUOTED([DEFINED_UTLS], [1], [Define to 1 to enable UTLS])
    AC_MSG_RESULT([yes])
else
    AS_IF([test "x$enable_utls" == xyes],
        [AC_MSG_ERROR([utls support requested but kTLS not present])],
        [AC_MSG_RESULT([no])])
fi
])