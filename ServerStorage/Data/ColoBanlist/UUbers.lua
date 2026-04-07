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
Archaludon,ALL,,,
Eternatus,ALL,,,
Flutter Mane,ALL,,,
Groudon,ALL,,,
Ho-Oh,ALL,,,
Koraidon,ALL,,,
Kyogre,ALL,,,
Marshadow,ALL,,,
Miraidon,ALL,,,
Necrozma,ALL,,,
Rayquaza,ALL,,,
Xerneas,ALL,,,
Yveltal,ALL,,,
Zygarde,Bn,Base,,
Zygarde,Bn,Full,,

Arceus,Bn,Normal,,
Arceus,Bn,Base,,
Arceus,Bn,Fairy,,
Arceus,Bn,Ground,,
Arceus,Bn,Water,,
Calyrex,Bn,Ice,,
Calyrex,Bn,Shadow,,
Deoxys,Bn,Attack,,
Giratina,Bn,Origin,,
Kyurem,Bn,Black,,
Zacian,Bn,Crowned,,

Alakazam,Bn,,,alakazite
Gengar,Bn,,,gengarite
Gengar,Bn,,,gengariteh
Mewtwo,Bn,,,mewtwonitex
Mewtwo,Bn,,,mewtwonitey
Salamence,Bn,,,salamencite
]])