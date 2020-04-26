
local fastSand=true
local waterSpeed=3  --resolution and speed 

selector={'sand','caus','water','virus','wall','colorwall'}

elem = {
    sand={
      gtype='POW',
      update = function(t,x,y)
        local neigh=t:neighbors(x,y)
        if neigh[6] then
          if neigh[7]==grid.nul then
            t:move(x,y,x-1,y+1)
          elseif neigh[5]==grid.nul then
            t:move(x,y,x+1,y+1)
          end
        elseif neigh[6]==grid.nul then
          local neigh2=t:neighbors(x,y+1)
          local drs=1
          if fastSand and neigh2[6]==grid.nul then
            drs=2
          end
          t:move(x,y,x,y+drs)
        end
      end,
      color={1,1,0.2}
    },
    wall={
      gtype='STA',
      color={0.5,0.5,0.5}
    },
    water={
      gtype='LIQ',
      color={0.1,0.1,1},
      update = function(t,orx,ory)
        local x,y=orx,ory
        for _=1,waterSpeed do
          local ox,oy=0,0
          local neigh=t:neighbors(x,y)
          --t:move(x,y,x+ox,y)
          if neigh[6]==grid.nul then
            oy=1
          else
            if neigh[4]==grid.nul and neigh[8]==grid.nul then 
              ox=ox+rand(0,2)-1
            elseif neigh[4]==grid.nul then 
              ox=ox+1
            elseif neigh[8]==grid.nul then 
              ox=ox-1
            end
          end
          x=x+ox
          y=y+oy
        end
        t:move(orx,ory,x,y)
      end,
    },
    caus={
      gtype='GAS',
      color={1,0.5,1},
      update = function(t,x,y) 
        if rand(255)==1 then
          t:set(x,y,grid.nul)
        end
        t:move(x,y,x+math.random(-1,1),y+math.random(-1,1)) 
      end
    },
    virus={
      gtype='STA',
      color={1,0.5,1},
      update = function(t,x,y) 
        for i=-1,1 do
          for j=-1,1 do
            if not(j==0 and i==0) then
              if t:get(x+i,y+j) then
                if rand(30)==1 then
                  particle(elem.virus,x+i,y+j)
                end
              end
            end
          end
        end
      end
    },
    colorwall={
      color={1,1,1,1},
      update = function(t,x,y) 
        local me=t:get(x,y)
        local neigh=t:neighbors(x,y)
        local r,g,b=0,0,0
        local c=0
        for i,v in ipairs(neigh) do
          if v~=grid.nul then
            local colh=v.color or v.elem.color
            if colh then
              c=c+1
              r=r+colh[1]
              g=g+colh[2]
              b=b+colh[3]
            end
          end
        end
        local cc=1/c
        if c>0 then
          me.color={r*cc,g*cc,b*cc}
        end
      end
    }
  }