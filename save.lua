local elem=elem
local grid=grid
local binser=require'lib.binser'

local function gc() collectgarbage() collectgarbage() end

function simsave(file,simu)
  file=file or 'save.bin'
  local f=io.open(file,'wb')
  f:write(binser.s(simu.grid))
  f:close()
  gc()
end

function simload(file,simo) --v2
  file=file or 'save.bin'
  local f=io.open(file,'rb')
  if f then
    local d=f:read('*a')
    local simu=grid.new(simo.w,simo.h)
    local lgr=binser.dn(d,1)
    for x=1,simu.w do --optimize
      for y=1,simu.h do
        simu.grid[x][y]=lgr[x][y]
        local v=simu.grid[x][y]
        if type(v)=='table' then
          local name=v.elem.name
          local el=elem[name]
          if el then
            v.elem=nil
            v.elem=el
          end
          if v.ctype then
            local replace=elem[v.ctype.name]
            if elem[v.cname] then
              replace=elem[v.cname]
            end
            if replace then
              v.ctype=replace
            end
          end
        end
      end
    end
    d=nil
    lgr=nil
    f:close()
    gc()
    return simu
  end
  return simo
end