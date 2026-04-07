local date = {}

local RELEASE_DATE = os.time({
	month = 10,
	day   = 24,
	year  = 2015,
	hour  = 0,
})

local SECONDS_PER_MINUTE = 60
local SECONDS_PER_HOUR = 60 * SECONDS_PER_MINUTE
local SECONDS_PER_DAY = 24 * SECONDS_PER_HOUR
local DAYS_PER_WEEK = 7
local DAYS_PER_YEAR = 365
local Debug, forcedWeather, forcedForecast = false, 'spacial', {
	{'', 0, 'thunder'}, --Not Used, Not Used, weather
	{'', 0, 'spacial'},
	{'', 0, 'sandstorm'},
	{'', 0, 'smog'},
	{'', 0, 'blood'},
	--First 2 sets are't use except for testing + skipping "Clear" in forecast
}
--local getTimeRemote = game:GetService('ReplicatedStorage').Remote.GetWorldTime
local function now()
	return os.time() - 5*SECONDS_PER_HOUR -- CDT
end

local months = {
	--{name,   ndays, no-longer-used},
	{'January',   31, 6},
	{'February',  28, 2},
	{'March',     31, 2},
	{'April',     30, 5},
	{'May',       31, 0},
	{'June',      30, 3},
	{'July',      31, 5},
	{'August',    31, 1},
	{'September', 30, 4},
	{'October',   31, 6},
	{'November',  30, 2},
	{'December',  31, 4},
}

local weekdays = {[0]='Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'}
local weatherNames = {
	--2 Variants for Rain
	rain = 'Heavy Rainfall',
	wind = 'Strong Gusts',
	hail = 'Pelting Hailstorm',
	fog = 'Thick Fog',
	snow = 'Blinding Snowstorm',
	meteor = 'Meteor Shower',	
	aurora = 'Northern Lights',

	[''] = 'Clear', --pretty sure this'll count all of them

	--ToDo
	spacial = 'Spacial Anomalies',
	thunder = 'Explosive Thunderstorms',
	smog = 'Toxic Smog',
	sun = 'Extreme Heat',
	blood = 'Blood Moon'
}
--[[
Old:
--Clear: 50%
--Rain: 7% 
--Wind: 8.5%
--Snow: 7%
--Hail: 6%
--Fog: 6.5%
--Meteor: 2.5%
--Aurora: 3.5%
--Thunder: 4.5%
--Smog: 4.5%
-------
CURRENT:


-------
TODO:
Blood Moon (Make appear)
Spacial
Sun
]]
local eventWeathers = {
	'', 'snow', 'fog', 'hail', 'hail', '', '', '', 'hail', '', 
	'', 'snow', '', '', '', 'snow', '', '', '', 'snow', 
	'', 'aurora', '', '', 'snow', '', '', '', '', '', 
	'sand', 'thunder', '', '', 'hail', 'smog', 'rain', 'thunder', 'snow', 'snow', 
	'fog', 'snow', 'sand', '', '', 'snow', 'hail', '', '', 'snow', 
	'snow', '', 'hail', 'rain', 'wind', '', 'snow', 'snow', 'aurora', '', 
	'', '', 'aurora', '', 'fog', 'snow', 'snow', 'thunder', '', 'snow', 
	'', '', '', 'aurora', 'thunder', 'snow', '', 'fog', 'hail', '', 
	'', '', 'snow', 'thunder', 'thunder', 'snow', 'snow', 'smog', 'hail', '', 
	'', '', '', '', 'sand', 'hail', '', 'aurora', '', '', 
	'', '', '', 'hail', 'fog', 'snow', 'snow', '', '', '', 
	'fog', '', '', 'snow', 'snow', 'hail', 'snow', 'fog', '', 'hail', 
	'snow', 'meteor', '', 'hail', 'hail', 'fog', 'snow', 'snow', 'rain', 'fog', 
	'', 'meteor', '', '', '', 'snow', 'fog', '', 'wind', '', 
	'', '', 'rain', '', 'snow', 'aurora', 'smog', 'thunder', '', '', 
	'', '', 'snow', '', 'snow', 'sand', '', 'wind', '', 'snow', 
	'', '', '', 'snow', '', 'snow', '', 'rain', 'snow', '', 
	'snow', '', '', 'snow', 'hail', 'sand', 'meteor', '', '', '', 
	'', 'wind', 'hail', 'sand', 'snow', 'snow', 'snow', '', 'snow', 'hail', 
	'thunder', 'fog', 'smog', 'meteor', '', '', '', 'hail', 'smog', 'aurora', 
	'hail', 'hail', 'hail', 'hail', '', '', '', 'thunder', 'snow', '', 
	'snow', 'snow', '', 'meteor', 'thunder', '', 'thunder', '', 'aurora', 'rain', 
	'thunder', '', 'hail', '', 'snow', 'aurora', 'meteor', 'aurora', '', '', 
	'', '', 'thunder', '', '', 'smog', '', 'fog', 'sand', '', 
	'fog', 'smog', 'hail', 'hail', '', 'hail', '', 'fog', '', '', 
	'', '', '', '', 'hail', '', 'smog', 'hail', 'wind', 'snow', 
	'', 'snow', '', 'thunder', 'snow', 'wind', 'fog', 'smog', 'meteor', 'fog', 
	'snow', 'wind', '', 'thunder', '', 'rain', '', 'aurora', 'aurora', 'fog', 
	'', '', 'fog', 'snow', '', 'wind', '', '', '', '', 
	'snow', 'meteor', '', '', 'wind', 'sand', '', '', '', '', 
	'hail', '', 'snow', 'fog', 'snow', 'sand', 'fog', '', 'aurora', 'snow', 
	'aurora', 'snow', '', '', 'sand', 'fog', 'hail', 'hail', 'hail', 'hail', 
	'', 'hail', 'meteor', 'snow', 'hail', '', '', '', 'fog', '', 
	'', 'snow', '', 'hail', 'rain', 'snow', '', '', 'sand', 'snow', 
	'meteor', 'snow', '', '', 'snow', 'snow', 'rain', 'snow', '', 'fog', 
	'fog', '', 'sand', '', '', 'snow', '', 'snow', 'snow', 'sand', 
	'', '', '', '', 'hail', '', '', 'rain', 'thunder', 'snow', 
	'smog', '', 'snow', '', '', 'hail', 'rain', 'snow', '', '', 
	'snow', '', 'hail', '', 'hail', '', 'aurora', 'aurora', 'hail', '', 
	'snow', '', '', '', '', '', 'snow', '', 'aurora', 'fog', 
	'', '', 'smog', '', 'rain', '', '', 'sand', 'aurora', 'rain', 
	'', 'sand', 'aurora', '', '', 'wind', 'snow', 'fog', 'thunder', 'snow', 
	'aurora', 'aurora', 'hail', 'sand', 'rain', 'hail', 'fog', 'aurora', 'rain', 'snow', 
	'', '', '', '', 'wind', 'hail', 'aurora', '', '', '', 
	'thunder', 'thunder', '', 'aurora', 'hail', 'snow', 'snow', '', '', '', 
	'', '', '', '', '', '', '', '', '', '', 
	'snow', 'snow', '', '', '', 'snow', 'snow', '', '', '', 
	'hail', '', 'hail', 'snow', 'thunder', 'snow', 'fog', '', 'snow', 'rain', 
	'', '', '', '', 'hail', '', 'snow', 'hail', 'snow', 'rain', 
	'thunder', 'rain', 'snow', '', '', 'snow', 'aurora', 'hail', 'rain', 'hail', 
	'', '', '', 'hail', 'meteor', '', 'sand', '', '', '', 
	'', 'snow', 'hail', 'hail', '', 'hail', '', '', '', 'thunder', 
	'', '', '', '', '', 'snow', '', 'thunder', 'hail', 'aurora', 
	'', 'hail', 'thunder', '', '', 'snow', 'snow', 'snow', '', 'snow', 
	'', 'hail', '', '', 'thunder', '', 'aurora', 'hail', 'aurora', '', 
	'', 'thunder', 'fog', 'snow', '', '', '', 'thunder', 'snow', 'snow', 
	'', '', '', '', '', '', 'fog', 'rain', '', '', 
	'', '', '', 'rain', '', 'hail', 'meteor', '', 'hail', 'fog', 
	'', '', 'snow', 'snow', '', 'wind', 'smog', '', 'fog', '', 
	'', '', '', 'snow', 'fog', '', '', '', 'hail', '', 
	'snow', '', 'snow', 'rain', '', '', '', 'meteor', 'hail', 'hail', 
	'', '', 'fog', 'sand', 'snow', '', '', 'snow', 'hail', '', 
	'hail', '', 'hail', '', '', 'hail', 'aurora', 'fog', 'sand', '', 
	'snow', '', 'snow', 'thunder', 'rain', '', '', '', 'snow', '', 
	'', '', 'hail', '', 'snow', '', '', 'wind', '', 'thunder', 
	'', 'fog', '', 'fog', '', '', 'hail', '', '', '', 
	'', '', '', '', '', '', '', 'snow', 'meteor', '', 
	'snow', 'thunder', '', '', '', 'hail', '', 'meteor', '', 'aurora', 
	'snow', '', '', '', 'hail', 'hail', '', '', '', 'snow', 
	'sand', '', 'aurora', 'hail', '', '', 'hail', 'snow', 'hail', 'thunder', 
	'fog', '', 'snow', '', 'snow', 'meteor', 'fog', 'snow', '', 'wind', 
	'', 'smog', 'snow', 'snow', 'smog', '', 'meteor', 'sand', 'aurora', 'hail', 
	'hail', '', '', '', 'snow', 'thunder', 'rain', 'thunder', '', 'fog', 
	'fog', '', 'wind', 'snow', '', 'meteor', '', '', 'rain', 'sand', 
	'aurora', 'aurora', 'snow', '', 'meteor', 'fog', 'rain', 'fog', '', 'thunder', 
	'smog', 'snow', '', '', 'rain', '', 'snow', '', '', '', 
	'fog', '', 'snow', 'smog', '', '', '', 'snow', '', '', 
	'hail', 'rain', '', '', 'snow', '', '', 'hail', '', 'fog', 
	'', 'thunder', '', '', '', '', 'snow', '', 'wind', '', 
	'snow', 'thunder', 'hail', 'snow', '', '', 'snow', 'fog', 'hail', 'snow', 
	'fog', 'snow', 'hail', 'hail', 'snow', 'snow', '', 'aurora', 'snow', 'thunder', 
	'rain', 'fog', '', 'smog', '', 'thunder', 'snow', '', 'rain', 'rain', 
	'', 'hail', 'hail', '', 'sand', '', 'wind', 'hail', '', 'meteor', 
	'hail', '', 'fog', '', 'hail', '', 'meteor', 'aurora', '', 'meteor', 
	'rain', 'hail', '', '', 'thunder', 'smog', '', '', '', 'snow', 
	'snow', 'fog', 'snow', 'snow', 'thunder', '', '', '', '', 'fog', 
	'', 'snow', '', 'hail', '', 'snow', '', 'sand', 'wind', '', 
	'', '', 'snow', '', 'snow', 'fog', 'meteor', 'thunder', 'aurora', '', 
	'', 'fog', '', '', 'wind', '', '', '', '', '', 
	'hail', '', 'snow', '', 'snow', 'fog', '', 'fog', 'smog', '', 
	'', 'fog', 'snow', 'hail', 'sand', 'meteor', '', 'fog', 'snow', 'snow', 
	'aurora', 'sand', '', 'fog', '', '', 'hail', 'fog', '', 'sand', 
	'snow', '', 'snow', 'hail', '', 'snow', 'meteor', 'meteor', '', '', 
	'wind', 'sand', 'rain', 'hail', '', 'wind', '', 'fog', 'meteor', 'thunder', 
	'', '', '', '', '', '', 'meteor', 'snow', '', '', 
	'wind', 'sand', '', 'aurora', 'fog', '', '', 'meteor', '', 'hail', 
	'smog', 'hail', '', 'thunder', 'rain', 'wind', 'snow', '', 'snow', 'fog', 
	'wind', '', 'sand', '', '', '', '', 'fog', '', '', 
	'', 'snow', '', 'hail', 'snow', 'aurora', 'thunder', 'wind', '', 'snow', 
	'rain', 'snow', '', 'hail', '', '', 'thunder', 'fog', 'fog', '', 

}
local weathers = {
	'', 'wind', 'thunder', 'fog', 'hail', '', '', '', 'fog', '', 
	'', 'rain', '', '', '', 'snow', '', '', '', 'wind', 
	'', 'smog', '', '', 'hail', '', '', '', '', '', 
	'spacial', 'sand', '', '', 'fog', 'spacial', 'rain', 'sand', 'snow', 'wind', 
	'aurora', 'wind', 'spacial', '', '', 'snow', 'hail', '', '', 'rain', 
	'snow', '', 'hail', 'rain', 'rain', '', 'hail', 'wind', 'thunder', '', 
	'', '', 'smog', '', 'meteor', 'rain', 'snow', 'sand', '', 'wind', 
	'', '', '', 'thunder', 'smog', 'rain', '', 'meteor', 'fog', '', 
	'', '', 'hail', 'smog', 'smog', 'rain', 'wind', 'sand', 'fog', '', 
	'', '', '', '', 'spacial', 'meteor', '', 'smog', '', '', 
	'', '', '', 'fog', 'meteor', 'wind', 'wind', '', '', '', 
	'meteor', '', '', 'snow', 'rain', 'fog', 'hail', 'aurora', '', 'fog', 
	'wind', 'thunder', '', 'fog', 'hail', 'meteor', 'wind', 'hail', 'rain', 'aurora', 
	'', 'thunder', '', '', '', 'hail', 'aurora', '', 'rain', '', 
	'', '', 'rain', '', 'wind', 'thunder', 'sand', 'smog', '', '', 
	'', '', 'snow', '', 'rain', 'spacial', '', 'rain', '', 'wind', 
	'', '', '', 'wind', '', 'snow', '', 'rain', 'rain', '', 
	'hail', '', '', 'hail', 'fog', 'spacial', 'thunder', '', '', '', 
	'', 'rain', 'meteor', 'spacial', 'rain', 'wind', 'wind', '', 'snow', 'fog', 
	'smog', 'aurora', 'sand', 'thunder', '', '', '', 'hail', 'sand', 'smog', 
	'fog', 'fog', 'hail', 'fog', '', '', '', 'smog', 'wind', '', 
	'rain', 'snow', '', 'thunder', 'smog', '', 'sand', '', 'thunder', 'rain', 
	'sand', '', 'meteor', '', 'snow', 'smog', 'thunder', 'thunder', '', '', 
	'', '', 'sand', '', '', 'spacial', '', 'meteor', 'spacial', '', 
	'aurora', 'sand', 'fog', 'fog', '', 'fog', '', 'aurora', '', '', 
	'', '', '', '', 'fog', '', 'spacial', 'meteor', 'rain', 'wind', 
	'', 'rain', '', 'sand', 'rain', 'rain', 'aurora', 'sand', 'thunder', 'thunder', 
	'snow', 'rain', '', 'sand', '', 'rain', '', 'thunder', 'thunder', 'aurora', 
	'', '', 'meteor', 'hail', '', 'rain', '', '', '', '', 
	'hail', 'thunder', '', '', 'rain', 'spacial', '', '', '', '', 
	'fog', '', 'wind', 'thunder', 'snow', 'spacial', 'thunder', '', 'smog', 'hail', 
	'thunder', 'wind', '', '', 'spacial', 'aurora', 'fog', 'fog', 'meteor', 'fog', 
	'', 'fog', 'thunder', 'wind', 'fog', '', '', '', 'aurora', '', 
	'', 'rain', '', 'fog', 'rain', 'wind', '', '', 'spacial', 'wind', 
	'thunder', 'snow', '', '', 'wind', 'rain', 'rain', 'rain', '', 'meteor', 
	'aurora', '', 'spacial', '', '', 'snow', '', 'wind', 'hail', 'spacial', 
	'', '', '', '', 'meteor', '', '', 'rain', 'smog', 'wind', 
	'sand', '', 'wind', '', '', 'fog', 'rain', 'rain', '', '', 
	'snow', '', 'hail', '', 'fog', '', 'thunder', 'thunder', 'hail', '', 
	'hail', '', '', '', '', '', 'hail', '', 'smog', 'aurora', 
	'', '', 'sand', '', 'rain', '', '', 'spacial', 'smog', 'rain', 
	'', 'spacial', 'thunder', '', '', 'rain', 'snow', 'aurora', 'smog', 'snow', 
	'smog', 'smog', 'meteor', 'spacial', 'rain', 'fog', 'aurora', 'thunder', 'rain', 'snow', 
	'', '', '', '', 'rain', 'fog', 'smog', '', '', '', 
	'sand', 'sand', '', 'smog', 'fog', 'hail', 'snow', '', '', '', 
	'', '', '', '', '', '', '', '', '', '', 
	'snow', 'snow', '', '', '', 'wind', 'wind', '', '', '', 
	'hail', '', 'meteor', 'wind', 'smog', 'wind', 'aurora', '', 'snow', 'rain', 
	'', '', '', '', 'fog', '', 'wind', 'fog', 'hail', 'rain', 
	'sand', 'rain', 'wind', '', '', 'wind', 'smog', 'hail', 'rain', 'hail', 
	'', '', '', 'hail', 'thunder', '', 'spacial', '', '', '', 
	'', 'hail', 'hail', 'fog', '', 'fog', '', '', '', 'smog', 
	'', '', '', '', '', 'wind', '', 'smog', 'fog', 'thunder', 
	'', 'hail', 'sand', '', '', 'snow', 'snow', 'wind', '', 'snow', 
	'', 'hail', '', '', 'sand', '', 'smog', 'fog', 'smog', '', 
	'', 'sand', 'aurora', 'snow', '', '', '', 'sand', 'wind', 'hail', 
	'', '', '', '', '', '', 'meteor', 'rain', '', '', 
	'', '', '', 'rain', '', 'fog', 'thunder', '', 'fog', 'aurora', 
	'', '', 'wind', 'snow', '', 'rain', 'sand', '', 'meteor', '', 
	'', '', '', 'rain', 'aurora', '', '', '', 'fog', '', 
	'snow', '', 'hail', 'rain', '', '', '', 'thunder', 'hail', 'fog', 
	'', '', 'aurora', 'spacial', 'wind', '', '', 'hail', 'fog', '', 
	'meteor', '', 'meteor', '', '', 'fog', 'smog', 'thunder', 'spacial', '', 
	'wind', '', 'snow', 'smog', 'rain', '', '', '', 'rain', '', 
	'', '', 'meteor', '', 'wind', '', '', 'rain', '', 'sand', 
	'', 'aurora', '', 'thunder', '', '', 'fog', '', '', '', 
	'', '', '', '', '', '', '', 'wind', 'thunder', '', 
	'snow', 'smog', '', '', '', 'fog', '', 'thunder', '', 'thunder', 
	'wind', '', '', '', 'fog', 'meteor', '', '', '', 'wind', 
	'spacial', '', 'thunder', 'fog', '', '', 'meteor', 'snow', 'meteor', 'smog', 
	'thunder', '', 'wind', '', 'snow', 'thunder', 'aurora', 'wind', '', 'rain', 
	'', 'spacial', 'wind', 'hail', 'sand', '', 'thunder', 'spacial', 'thunder', 'meteor', 
	'fog', '', '', '', 'wind', 'smog', 'rain', 'sand', '', 'thunder', 
	'aurora', '', 'rain', 'hail', '', 'thunder', '', '', 'rain', 'spacial', 
	'smog', 'thunder', 'wind', '', 'thunder', 'aurora', 'rain', 'meteor', '', 'sand', 
	'sand', 'rain', '', '', 'rain', '', 'wind', '', '', '', 
	'aurora', '', 'snow', 'sand', '', '', '', 'hail', '', '', 
	'fog', 'rain', '', '', 'wind', '', '', 'meteor', '', 'aurora', 
	'', 'sand', '', '', '', '', 'wind', '', 'rain', '', 
	'rain', 'sand', 'fog', 'hail', '', '', 'wind', 'aurora', 'fog', 'snow', 
	'meteor', 'hail', 'fog', 'fog', 'hail', 'snow', '', 'thunder', 'snow', 'sand', 
	'rain', 'aurora', '', 'spacial', '', 'sand', 'wind', '', 'rain', 'rain', 
	'', 'hail', 'meteor', '', 'spacial', '', 'rain', 'meteor', '', 'thunder', 
	'fog', '', 'thunder', '', 'fog', '', 'thunder', 'smog', '', 'thunder', 
	'rain', 'hail', '', '', 'sand', 'sand', '', '', '', 'hail', 
	'wind', 'aurora', 'wind', 'snow', 'smog', '', '', '', '', 'aurora', 
	'', 'hail', '', 'hail', '', 'snow', '', 'spacial', 'rain', '', 
	'', '', 'hail', '', 'snow', 'aurora', 'thunder', 'smog', 'smog', '', 
	'', 'aurora', '', '', 'rain', '', '', '', '', '', 
	'fog', '', 'wind', '', 'wind', 'aurora', '', 'thunder', 'sand', '', 
	'', 'aurora', 'snow', 'fog', 'spacial', 'thunder', '', 'meteor', 'snow', 'wind', 
	'thunder', 'spacial', '', 'aurora', '', '', 'meteor', 'aurora', '', 'spacial', 
	'snow', '', 'snow', 'hail', '', 'hail', 'thunder', 'thunder', '', '', 
	'rain', 'spacial', 'rain', 'fog', '', 'rain', '', 'aurora', 'thunder', 'smog', 
	'', '', '', '', '', '', 'thunder', 'snow', '', '', 
	'rain', 'spacial', '', 'thunder', 'meteor', '', '', 'thunder', '', 'fog', 
	'sand', 'fog', '', 'sand', 'rain', 'rain', 'snow', '', 'snow', 'aurora', 
	'rain', '', 'spacial', '', '', '', '', 'aurora', '', '', 
	'', 'snow', '', 'fog', 'snow', 'smog', 'sand', 'rain', '', 'snow', 
	'rain', 'wind', '', 'meteor', '', '', 'smog', 'aurora', 'meteor', '', 
}--'' = clear 100 total

local WeatherTypes = #weathers
function getWeather(hour, day, dayOfWeek, Month)
	local weather = ''
	local maxUnit = 999999999 --as High as roblox allows you
	if dayOfWeek == 0 then dayOfWeek = 1 end
	local in1 = (((hour*day)/dayOfWeek)+hour)
	local in2 = (((day*dayOfWeek)/hour)+Month^2)
	local in3 = ((((in1*in2)/day))*hour)
	local seed = Random.new((math.round(in3)%WeatherTypes)+in1-(hour+dayOfWeek))--Better randomness
	in3 = (seed:NextInteger(1, maxUnit))%WeatherTypes
	if (day == 19 and Month == 9) and (hour >= 15 and hour <= 17) then 
		if hour == 15 then
			weather = 'smog'
		elseif hour == 16 then
			weather = 'aurora'
		else
			weather = 'thunder'
		end
	elseif day >= 5 and Month == 12 then
		weather = eventWeathers[in3]
	else
		weather = weathers[in3]
	end
	return weather--weathers[in3]--[((math.round(in3)%WeatherTypes)+1)]
end
--warn(getWeather(12, 16, 7, 1))
function isLeapYear(yr)
	if yr % 400 == 0 then
		return true
	elseif yr % 100 == 0 then
		return false
	elseif yr % 4 == 0 then
		return true
	end
	return false
end

function twodigit(num)
	num = math.floor(num)
	if num < 10 then
		return '0'..tostring(num)
	end
	return tostring(num)
end

function date:getWeekdayName(currenttime)
	if not currenttime then currenttime = now() end
	return weekdays[(math.floor(currenttime/SECONDS_PER_DAY)+4)%7]
end

function date:getWeekId(currenttime) -- 12b
	if not currenttime then currenttime = now() end
	return math.floor(((currenttime - RELEASE_DATE) / SECONDS_PER_DAY + 6) / DAYS_PER_WEEK)
end

function date:getDayId(currenttime) -- 15b
	if not currenttime then currenttime = now() end
	return math.floor((currenttime - RELEASE_DATE) / SECONDS_PER_DAY)
end

function date:getDate(currenttime)
	if not currenttime then currenttime = now() end
	local monthS, monthN, weekday, day, hour, minute, sec, year = '', 0, '', 0, 0, 0, 0, 1970

	local days = math.ceil(currenttime/SECONDS_PER_DAY)
	local dpy = DAYS_PER_YEAR + (isLeapYear(year) and 1 or 0)
	while days > dpy do
		days = days - dpy
		year = year + 1
		dpy = DAYS_PER_YEAR + (isLeapYear(year) and 1 or 0)
	end

	if isLeapYear(year) then
		months[2][2] = 29
	end
	for i, j in ipairs(months) do
		if days > j[2] then
			days = days - j[2]
		else
			monthS = j[1]
			monthN = i
			day = days
			break
		end
	end
	months[2][2] = 28
	local t = currenttime % SECONDS_PER_DAY
	hour = math.floor(t/SECONDS_PER_HOUR)
	minute = math.floor((t%SECONDS_PER_HOUR)/SECONDS_PER_MINUTE)
	sec = t % SECONDS_PER_MINUTE

	--	local dayFig = year%100
	--	dayFig = dayFig + math.floor(dayFig/4)
	--	dayFig = dayFig + day + months[monthN][3]
	--	dayFig = dayFig % 7
	local dayFig = (math.floor(currenttime/SECONDS_PER_DAY)+4)%7

	weekday = weekdays[dayFig]
	--warn(weathers[((day*hour)%(hour+day)%WeatherTypes)+1])
	local stringed = weekday..', '..monthS..' '..twodigit(day)..', '..tostring(year)..'; '..twodigit(hour)..':'..twodigit(minute)..':'..twodigit(sec)
	--	print(stringed)
	local predictedWeather = {}
	local hr, dy, mnth, dyf = hour, day, monthN, dayFig
	for i=1, 5 do -- change if I wanna display more than the upcoming 4 weather + current
		if Debug then
			predictedWeather = forcedForecast	
		else
			if hr >= 24 then
				hr = 0
				dy += 1
				if dyf >= 7 then
					dyf = 1
				end
			end
			local wb = getWeather(hr, dy, dyf, mnth)
			predictedWeather[i] = {
				(weatherNames[wb]) or '',
				hr%24,
				wb or ''
			} --{weather, hour}
			hr += 1
		end
	end
	return {
		MonthName = monthS,
		MonthNum = monthN,
		DayOfMonth = day,
		Year = year,
		WeekdayName = weekday,
		WeekdayNum = dayFig,
		Hour = hour,
		Minute = minute,
		Second = sec,
		TimeString = stringed,
		Weather = (Debug and forcedWeather or getWeather(hour, day, dayFig, monthN)),
		predictedWeather = predictedWeather
	}
end



return date