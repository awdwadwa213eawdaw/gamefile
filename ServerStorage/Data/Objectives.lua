--[[
Mark - if 1 then it will be new objective if 2 then objective updated if nil it will say Main Objective
]]

return {
	Default = {
		Texts = {
			'Get your first pokemon'
		},
		Mark = 1,
	},
	Badges = {
		{ -- Badge 1
			Texts = {
				'Exit the 1st gym'
			},
			Mark = 1,
		},
		{ -- Badge 2
			Texts = {
				'Go to Route 7'
			},
			Mark = 1,
		},
		{ -- Badge 3
			Texts = {
				'Exit the 3rd gym'
			},
			Mark = 1,
		},
		{ -- Badge 4
			Texts = {
				'Visit the Shopping District'
			},
			Mark = 1,
		},
		{ -- Badge 5
			Texts = {
				'Delve through Route 12 to visit Fluoruma City'
			},
			Mark = 1,
		},
		{ -- Badge 6
			Texts = {
				'Exit the 6th gym'
			},
			Mark = 1,
		},
		{ -- Badge 7
			Texts = {
				'Talk with Tess at the Route 16 gate'
			},
			Mark = 1,
		},
		-- Badge 8
		Texts = {
			'Congrats on beating all Gym Leaders!',
			'All thats left to do is to go to the Roria Lague, and see if you can be champion.'
		},
		Mark = 1,
	},
	Events = {
		['MeetJake'] = {
			Texts = {
				'Meet your parents at dig site'
			},
			Mark = 2
		},
		['MeetParents'] = {
			Texts = {
				'Go to the lab to get your first pokemon'
			},
			Mark = 1,
		},
		['ChooseFirstPokemon'] = {
			Texts = {
				'Get out of the lab'
			},
			Mark = 1,
		},
		['JakeBattle1'] = {
			Texts = {
				'Meet Jake in Cheshma Town'
			},
			Mark = 1,
		},
		['ParentsKidnappedScene'] = {
			Texts = {
				'Leave Mitis Town',
			},
			Mark = 2
		},
		['BronzeBrickStolen'] = {
			Text = {
				'Get out of Linda\'s house'
			}
		},
		['JakeTracksLinda'] = {
			Texts = {
				'Get your necklace back',
				'Go in to gale forest, find Linda and get your necklace back'
			},
			Mark = 1,

		},
		['BronzeBrickRecovered'] = {
			Texts = {
				'Visit Silvent City',
				'Visit Silvent City and challenge Chad to obtain your first gym badge',
			},
			Mark = 1,
		},
		--First Badge here
		['ReceivedRTD'] = {
			Texts = {
				'Talk to the lumberjack and go to Brimber City',
			},
			Mark = 1,
		},
		['JakeBattle2'] = {
			Texts = {
				'Talk to Jake and Sebastian in Brimber City',
			},
		},
		['TalkToJakeAndSebastian'] = {
			Texts = {
				'Battle team Eclipse',
				'After talking to Sebastian, the gym leader of Brimber City, you should head to Mt. Igneus and fight team Eclipse and recover the Red Orb',
			},
			Mark = 2
		},
		['GroudonScene'] = {
			Texts = {
				'Go to the Brimber City gym',
			},
			Mark = 1,
		},
		--Second Badge Here
		['DamBusted'] = {
			Texts = {
				'Meet Jake in Route 8 ',
			},
		},
		['JakeStartFollow'] = {
			Texts = {
				'Battle with Jake in Route 8',
			},
			Mark = 2
		},
		['JakeEndFollow'] = {
			Texts = {
				'Continue talking with Jake in Rosecove City',
			},
			Mark = 2
		},
		['RosecoveWelcome'] = {
			Texts = {
				'Defeat Team Eclipse at the lighthouse',
				'Team Eclipse has taken over Rosecove City you must now face them at the Lighthouse',
			},
			Mark = 1,

		},
		['LighthouseScene'] = {
			Texts = {
				'Visit the gym',
			},
			Mark = 1,
		},
		--Third Badge Here
		['ProfAfterGym3'] = {
			Texts = {
				'Talk to Jake and Tess outside the route gate',
			},
			Mark = 1,
		},
		['JakeAndTessDepart'] = {
			Texts = {
				'Continue talking to Jake and Tess in Route 9',
			},
		},
		['JTBattlesR9'] = {
			Texts = {
				'Go to Cragonos Mines',
			},
			Mark = 1,
		},
		['MeetAbsol'] = {
			Texts = {
				'Go to Cragonos Cliffs',
			},
			Mark = 2
		},
		['ReachCliffPC'] = {
			Texts = {
				'Go to Cragonos Peak'
			},
			Mark = 2
		},
		['BlimpwJT'] = {
			Texts = {
				'Explore Anthian City',
				'Something feels off in Anthian City...'
			},
			Mark = 1,
		},
		['MeetGerald'] = {
			Texts = {
				'Vist Anthians Battle District',
			},
			Mark = 2
		},
		--Forth Badge Here
		['SeeTEship'] = {
			Texts = {
				'Meet up with Jake, Tess and Gerald',
			},
			Mark = 2
		},
		['GeraldKey'] = {
			Texts = {
				'Delve into Anthians sewers',
				'Team Eclipse have struck Anthian City go into the sewers and stop them from causing any more trouble'
			},
			Mark = 1,

		},
		['TessStartFollow'] = {
			Texts = {
				'Find the exit',
				'Traverse Anthians sewers with tess to find the exit'
			},
			Mark = 1,
		},
		['TessEndFollow'] = {
			Texts = {
				'Prepare to fight Team Eclipse',
			},
			Mark = 2
		},
		--	['EnteredPast'] = {
		--	Texts = {
		--		'Stop Team Eclipse from blowing up the Core',
		--	},
		--	Mark = 2
		--	},
		['DefeatTEinAC'] = {
			Texts = {
				'Take a ride on the Sky Train',
				'Visit Aredia City by taking the Sky Train on Cragonos Peak or Route 10 and traversing Route 11',
			},
			Mark = 1,

		},
		['vAredia'] = {
			Texts = {
				'Visit Old Aredia',
			},
			Mark = 2,
		},
		['TEinCastle'] = {
			Texts = {
				'Take on the Aredia City gym',
			},
			Mark = 1,

		},
		--Fith Badge Here
		['vFluoruma'] = {
			Texts = {
				'Take on the Fluoruma City gym',
			},
			Mark = 1,

		},
		--Sixth Badge Here
		['FluoDebriefing'] = {
			Texts = {
				'Traverse through Route 14 and Route 15',
			},
			Mark = 1,
		},
		['TERt14'] = {
			Texts = {
				'Traverse through Route 15',
			},
			Mark = 1,
		},
		['vFrostveil'] = {
			Texts = {
				'Challenge the Frostveil gym',
			},
			Mark = 2,

		},
		--Seventh Badge Here
		['TessBattle'] = {
			Texts = {
				'Visit Port Decca',
				'After defeating Tess and her Dragon Pokemon you now must see how fast you can ride down Route 16 and then travel through Cosmeos Valley into Port Decca to meet up with Tess once more'
			},
			Mark = 1,
		},
		['vPortDecca'] = {
			Texts = {
				'Meet Tess on Decca Beach',
				'Continue discussing your plans with Tess on Decca Beach',
			},
			Mark = 2,
		},
		--Eighth Badge Here
		['vCrescent'] = {
			Texts = {
				'Traverse through Route 17 by Surfing to go to Crescent Town',
			},
			Mark = 1,
		},
		['EclipseBaseReveal'] = {
			Texts = {
				'Go inside the Tavern then go to the elevator to go to Team Eclipse Base.',
			},
			Mark = 1,
		},
		['DefeatEclipseBase'] = {
			Texts = {
				'After You Defeat Team Eclipse and Jake.. Go to the next Gate in Crescent Town to face Cypress and Hoopa.',
			},
			Mark = 1,
		},
		['DefeatHoopa'] = {
			Texts = {
				'Good job Trainer! Now all is left is to get that eighth gym badge.',
				'The fisherman blocking the entrance should be gone now.'
			},
			Mark = 2,
		},
		['Champ'] = {
			Texts = {
				'You are now the Champion of Roria!',
			},
			Mark = 1,
		},
	}
}
