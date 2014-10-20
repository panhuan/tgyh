
@lua -l config -e "dofile 'src/makeluac.lua' ('../base/pakutil.lua', '../client')"
@lua -l config -e "dofile 'src/makeluac.lua' ('../base/pakutil.lua', '../server')"
pause