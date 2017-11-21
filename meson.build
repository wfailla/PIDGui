project('pid-gui', 'c', 'vala')

posix_dep = meson.get_compiler('vala').find_library('posix')
gdl_dep = dependency('gsl')
gio_dep = dependency('gio-2.0')
gtk_dep = dependency('gtk+-3.0')
gmodule_dep = dependency('gmodule-2.0')

src = ['src/dialog.vala' ,'src/drawing.vala' ,'src/guiHandler.vala' ,'src/main.vala' ,'src/PID.vala']

executable('pid-gui', sources: src, dependencies: [gdl_dep, gio_dep, gtk_dep, gmodule_dep, posix_dep])
