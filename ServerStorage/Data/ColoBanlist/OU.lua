-- Credit to PBBR (SolarFlare & Dehu)
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
Arceus,ALL,,,
Archeops,ALL,,,
Annihilape,ALL,,,
Baxcalibur,ALL,,,
Calyrex,Bn,Ice,,
Calyrex,Bn,Shadow,,
Chien-Pao,ALL,,,
Chi-Yu,ALL,,,
Darkrai,ALL,,,
Deoxys,ALL,,,
Dialga,ALL,,,
Dracovish,ALL,,,
Dragapult,ALL,,,
Espathra,ALL,,,
Eternatus,ALL,,,
Flutter Mane,ALL,,,
Genesect,ALL,,,
Giratina,ALL,,,
Groudon,ALL,,,
Gouging Fire,ALL,,,
Ho-Oh,ALL,,,
Iron Bundle,ALL,,,
Kingambit,ALL,,,
Koraidon,ALL,,,
Kyogre,ALL,,,
Kyurem,ALL,,,
Landorus,Bn,Base,,
Lugia,ALL,,,
Lunala,ALL,,,
Marshadow,ALL,,,
Magearna,ALL,,,
Melmetal,ALL,,,
Meowscarada,ALL,,,
Mewtwo,ALL,,,
Miraidon,ALL,,,
Naganadel,ALL,,,
Necrozma,ALL,,,
Palafin,ALL,,,
Pheromosa,ALL,,,
Rayquaza,ALL,,,
Reshiram,ALL,,,
Sneasler,ALL,,,
Solgaleo,ALL,,,
Shaymin,Bn,sky,,
Spectrier,ALL,,,
Ursaluna,Bn,Bloodmoon,,
Urshifu,Bn,Base,,
Walking Wake,ALL,,,
Xerneas,ALL,,,
Yveltal,ALL,,,
Zacian,ALL,,,
Zamazenta,ALL,,,
Zekrom,ALL,,,
Zygarde,Bn,Base,,
Zygarde,Bn,Full,,

Darmanitan,Bn,Galar,,
Blaziken,Bn,,,blazikenite
Blastoise,Bn,,,blastoisinite
Alakazam,Bn,,,alakazite
Blaziken,Bn,,,blazikenite
Eevee,Bn,,,eeveeiumz
Gengar,Bn,,,gengarite
Gengar,Bn,,,gengariteh
Kangaskhan,Bn,,,kangaskhanite
Lucario,Bn,,,lucarionite
Metagross,Bn,,,metagrossite
Salamence,Bn,,,salamencite
Sceptile,Bn,,,sceptilite
Sceptile,Bn,,,sceptilitec
Maushold,Bn,,,kingsrock
Gallade,Bn,,,galladite
]])