return require(script.Parent.Parent.CSV)({
	map = {
		name = function(v)
			return string.lower(v)
		end,
	}
--[[ Tier Check (Doesn't Apply to AG)
	ALL = not  allowed at all
	Bn = Not allowed IF a certain condition is met
	]]
}, [[name,tier,forme,moves,item
hiddenpower,[Empty],[Empty],[Empty],[Empty]
Rayquaza,Bn,Mega,,
Rayquaza,Bn,,dragonascent,
Xerneas,ALL,,,

Manectric,Bn,,icebeam,
Tinkaton,Bn,,bloodmoon,
Seaking,Bn,,fishiousrend,
Manectric,Bn,,energyball,
Noctowl,Bn,,oblivionwing,
Aggron,Bn,,recover,
Delphox,Bn,,thunderbolt,
Delphox,Bn,,energyball,
Meganium,Bn,,strengthsap,
Lokix,Bn,,mortalspin,
Garchomp,Bn,,poltergeist,
Mimikyu,Bn,,dracometeor,
Greninja,Bn,,nastyplot,
Lanturn,Bn,,energyball,
Quaquaval,Bn,,doodle,
]])