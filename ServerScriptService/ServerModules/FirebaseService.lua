-- TESTING DATABASE ONLY USE IN STUDIOS 
--local defaultDatabase = "https://lorfirebase-restore-default-rtdb.firebaseio.com/" --// Database URL
--local authenticationToken = "HoRUEN8K2Yco6Iz94iICBW50qZaDHrRt0TgDyVai" --// Authentication Token

local defaultDatabase = "https://legendsofrorianew-default-rtdb.firebaseio.com/" --// Database URL
local authenticationToken = "HN8okIlDAPLctm9csU8553Yj2FxNDyawuyjOvj0c" --// Authentication Token

--== Variables;
local HttpService = game:GetService("HttpService");
local DataStoreService = game:GetService("DataStoreService");

local FirebaseService = {};
local UseFirebase = true;
local _f = require(script.Parent)
local offlineMode = _f.offlineMode

function FirebaseService:SetUseFirebase(value)
	UseFirebase = value and true or false;
end

function FirebaseService:GetFirebase(name, database, auth)
	database = database or defaultDatabase;
	auth = auth or authenticationToken
	local datastore
	if not offlineMode then
		datastore = DataStoreService:GetDataStore(name);
	end

	local databaseName = database..HttpService:UrlEncode(name);
	local authentication = ".json?auth="..auth;

	local Firebase = {};

	if not offlineMode then
		function Firebase.GetDatastore()
			return datastore;
		end
	end
	
	-- Ratelimiting to prevent overloading
	local rateLimit = {'PlayerDataV1', 'PCData', 'ROPowerBackups'}
	local requestTimestamps = {} -- table of request timestamps
	local requestLimit = 80 -- # of requests in interval time
	local requestInterval = 5 -- interval time in seconds

	--// Entries Start
	function Firebase:GetAsync(directory)
		local data = nil;
		
		if table.find(rateLimit, name) then
			local now = tick()
			requestTimestamps[name] = requestTimestamps[name] or {}
			
			for i = #requestTimestamps[name], 1, -1 do
				if now - requestTimestamps[name][i] > requestInterval then
					table.remove(requestTimestamps[name], i)
				end
			end
			
			if #requestTimestamps[name] >= requestLimit then
				warn("FirebaseService>> Rate limit exceeded for: " .. name)
				_f.Logger:logError({Name = "Server-Side (No Player)", UserId = 0}, {ErrType = "Overload Attempt (GetAsync)", Errors = "Attempted overload on Firebase: " .. name .. "/" .. directory})
				return nil -- Prevent excessive requests
			end
			table.insert(requestTimestamps[name], now)
		end

		--== Firebase Get;
		local getTick = tick();
		local tries = 0; repeat until pcall(function() tries = tries +1;
			data = HttpService:GetAsync(databaseName..HttpService:UrlEncode(directory and "/"..directory or "")..authentication, true);
		end) or tries > 2;
		if type(data) == "string" then
			if data:sub(1,1) == '"' then
				return data:sub(2, data:len()-1);
			elseif data:len() <= 0 then
				return nil;
			end
		end
		return tonumber(data) or data ~= "null" and data or nil;
	end

	function Firebase:SetAsync(directory, value, header)
		if not UseFirebase then return end
		if value == "[]" then self:RemoveAsync(directory); return end;
		
		if table.find(rateLimit, name) then
			local now = tick()
			requestTimestamps[name] = requestTimestamps[name] or {}

			for i = #requestTimestamps[name], 1, -1 do
				if now - requestTimestamps[name][i] > requestInterval then
					table.remove(requestTimestamps[name], i)
				end
			end

			if #requestTimestamps[name] >= requestLimit then
				warn("FirebaseService>> Rate limit exceeded for: " .. name)
				_f.Logger:logError({Name = "Server-Side (No Player)", UserId = 0}, {ErrType = "Overload Attempt (SetAsync)", Errors = "Attempted overload on Firebase: " .. name .. "/" .. directory})
				return nil -- Prevent excessive requests
			end

			table.insert(requestTimestamps[name], now)
		end

		header = header or {["X-HTTP-Method-Override"]="PUT"};
		local replyJson = "";
		if type(value) == "string" and value:len() >= 1 and value:sub(1,1) ~= "{" and value:sub(1,1) ~= "[" then
			value = '"'..value..'"';
		end
		local success, errorMessage = pcall(function()
			replyJson = HttpService:PostAsync(databaseName..HttpService:UrlEncode(directory and "/"..directory or "")..authentication, value,
				Enum.HttpContentType.ApplicationUrlEncoded, false, header);
		end);
		if not success then
			warn("FirebaseService>> [ERROR] "..errorMessage);
			pcall(function()
				replyJson = HttpService:JSONDecode(replyJson or "[]");
			end)
		end
	end

	function Firebase:RemoveAsync(directory)
		if not UseFirebase then return end
		self:SetAsync(directory, "", {["X-HTTP-Method-Override"]="DELETE"});
	end

	function Firebase:IncrementAsync(directory, delta)
		delta = delta or 1;
		if type(delta) ~= "number" then warn("FirebaseService>> increment delta is not a number for key ("..directory.."), delta(",delta,")"); return end;
		local data = self:GetAsync(directory) or 0;
		if data and type(data) == "number" then
			data = data+delta;
			self:SetAsync(directory, data);
		else
			warn("FirebaseService>> Invalid data type to increment for key ("..directory..")");
		end
		return data;
	end

	function Firebase:UpdateAsync(directory, callback)
		local data = self:GetAsync(directory);
		local callbackData = callback(data);
		if callbackData then
			self:SetAsync(directory, callbackData);
		end
	end

	function FirebaseService:GetOrderedFirebase(name, database)
		local OrderedStore = self:GetFirebase(name, database)

		function OrderedStore:GetSortedAsync(ascending, pageSize)
			local data = HttpService:JSONDecode(self:GetAsync())
			local pages = {}

			local sortedData = {}
			local sortedPages = {}

			local maxFullPages
			local currentPage = 1 
			for id, score in pairs(data) do 
				sortedData[#sortedData+1] = {key = id, value = score}
			end

			table.sort(sortedData, function(plr, plr2)
				if ascending then return plr.value < plr2.value end
				return plr.value > plr2.value
			end)

			maxFullPages = #sortedData//pageSize

			--sort into pages

			for i = 1, maxFullPages do
				sortedPages[i] = {}

				local maxReach = i * pageSize -- minIndex required for currentPage
				local minReach = maxReach - pageSize -- maxIndex required for currentPage

				for index, data in pairs(sortedData) do
					if index >= minReach and index <= maxReach then
						table.insert(sortedPages[i], data)
						sortedData[index] = nil
					end                
				end
			end

			if next(sortedData) ~= nil then
				sortedPages[#sortedPages+1] = {}
				local latestPage = sortedPages[#sortedPages]

				for _, data in pairs(sortedData) do
					table.insert(latestPage, data)
				end
			end                    

			function pages:GetCurrentPage()
				return sortedPages[currentPage] or {}
			end

			function pages:AdvanceToNextPageAsync()
				currentPage += 1
			end

			return pages
		end

		return OrderedStore
	end

	return Firebase;
end

return FirebaseService;
