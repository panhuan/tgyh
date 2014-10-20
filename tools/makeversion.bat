
md "../../server/version/pak"
@lua -l config -e "dofile 'src/makepak.lua' ('../client/src', '../../server/version/pak/src')"
@lua -l config -e "dofile 'src/makepak.lua' ('../client/lib', '../../server/version/pak/lib')"
@lua -l config -e "package.path = package.path..';'..'../base/?.lua;../client/lib/?.lua;../client/src/?.lua;'" ^
-e "dofile 'src/makeversion.lua' ('src/manifest.lua', '../../server/version', 'pak/lib', 'pak/src')"
pause