@lua -l config -e "dofile 'src/makepak.lua' ('../client/src', '../client/pak/src')"
@lua -l config -e "dofile 'src/makepak.lua' ('../client/lib', '../client/pak/lib')"
@lua -l config -e "dofile 'src/makepak.lua' ('../base', '../client/pak/base')"
pause