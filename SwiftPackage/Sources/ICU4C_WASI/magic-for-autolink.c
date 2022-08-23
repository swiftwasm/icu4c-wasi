__asm__(
  ".section .custom_section..swift1_autolink_entries,\"\",@\n"
  ".asciz   \""
    PACKAGE_DIR"/build/lib/libicudata.a\000"
    PACKAGE_DIR"/build/lib/libicui18n.a\000"
    PACKAGE_DIR"/build/lib/libicuio.a\000"
    PACKAGE_DIR"/build/lib/libicuuc.a"
  "\""
);
