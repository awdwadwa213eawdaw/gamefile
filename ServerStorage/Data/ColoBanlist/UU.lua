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
Alakazam,ALL,,,
Blaziken,ALL,,,
Clefable,ALL,,,
Espathra,ALL,,,
Ferrothorn,ALL,,,
Garchomp,ALL,,,
Gliscor,ALL,,,
Greninja,ALL,,,
Hawlucha,ALL,,,
Heatran,ALL,,,
Magearna,ALL,,,
Meowscarada,ALL,,,
Blaziken,ALL,,,
Pelipper,ALL,,,
Corviknight,ALL,,,
Clodsire,ALL,,,
Serperior,ALL,,,
Gholdengo,ALL,,,
Glimmora,ALL,,,
Kingambit,ALL,,,
Dragapult,ALL,,,
Tapu Koko,ALL,,,
Tapu Fini,ALL,,,
Tapu Lele,ALL,,,
Toxapex,ALL,,,
Tyranitar,ALL,,,
Urshifu,ALL,,,
Victini,ALL,,,
Melmetal,ALL,,,
Rillaboom,ALL,,,
Cinderace,ALL,,,
Iron Treads,ALL,,,
Walking Wake,ALL,,,
Great Tusk,ALL,,,
Iron Valiant,ALL,,,
Raging Bolt,ALL,,,
Gouging Fire,ALL,,,
Iron Crown,ALL,,,
Iron Hands,ALL,,,
Volcarona,ALL,,,
Zygarde,ALL,,,
Dragonite,ALL,,,
Latios,ALL,,,
Manaphy,ALL,,,
Garganacl,ALL,,,
Staraptor,ALL,,,
Thundurus,ALL,,,
Enamorus,ALL,,,
Weavile,ALL,,,
Landorus,ALL,,,
Typhlosion,ALL,,,
Ursaluna,ALL,,,
Delphox,ALL,,,
Zeraora,ALL,,,
Noctowl,ALL,,,
Kartana,ALL,,,
Florges,ALL,,,

Samurott,Bn,Hisuian,,
Tornadus,Bn,Therian,,
Slowking,Bn,Galar,,
Hoopa,Bn,Unbound,,
Goodra,Bn,Base,,

Charizard,Bn,,,charizarditex
Charizard,Bn,,,charizarditey
Diancie,Bn,,,diancite
Gyarados,Bn,,,gyaradosite
Lopunny,Bn,,,lopunnite
Mawile,Bn,,,mawilite
Medicham,Bn,,,medichamite
Sableye,Bn,,,sablenite
Swampert,Bn,,,swampertite
]])