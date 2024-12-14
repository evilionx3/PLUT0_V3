


local bootTime = os.time()
local disconnected = false

local altctrl = _G.ALTCTRL or false
local SPIN_POWER = 100
local FLOAT_HEIGHT = 9

local bot = game.Players.LocalPlayer
local HH = bot.Character.Humanoid.HipHeight

for i, plr in pairs(game.Players:GetPlayers()) do
	for i, obj in pairs(plr:GetChildren()) do
		if obj.Name == "PlutoBotBlacklist" then
			obj:Destroy()		
		end
	end
end


local whitelisted = {
	bot.Name,
}

local showbotchat = _G.showBotChat or false 
local allwhitelisted = _G.defaultAllWhitelisted or false 
local randommoveinteger = _G.defaultRandomMoveInteger or 15 
local prefix = _G.defaultPrefix or "." 

if _G.preWhitelisted and type(_G.preWhitelisted) == "table" then
	for i, v in pairs(_G.preWhitelisted) do
		table.insert(whitelisted, v)
	end
end

if prefix:len() > 1 then
	warn("Prefix cannot be more than 1 character long!")
	return
end

local lunarbotversion = "v0.1.3 Public Beta Release"
local lunarbotchangelogs = "Added a few commands!"

local gameData = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
local status = nil
local followplr = nil
local copychatplayer = nil

local TS = game:GetService("TweenService")

local TI = TweenInfo.new(
	2.5,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

local function chat(msg)
	if showbotchat == true then
		game.TextChatService.TextChannels.RBXGeneral:SendAsync("" .. msg)
	else
		game.TextChatService.TextChannels.RBXGeneral:SendAsync(msg)
	end
end

local funfacts = {
	"eeeeeeeee",
}

local messageReceived = game.TextChatService.TextChannels.RBXGeneral.MessageReceived

local commandsMessage = {
	"cmds, reset, say <message>, dance, whitelist <player>, coinflip, bring, follow, unfollow,",
	"setprefix <newPrefix>, funfact, speed, blacklist <player>, walkto <player>",
	"announce <announcement>,jobid, aliases <command>, math <operation> <nums>, playercount",
	"lua <lua>, spin <speed>, float <height>, orbit <speed> <radius>, jump,",
}

local orbitcon

local function orbit(target, speed, radius)
	local r = tonumber(radius) or 10
	local rps = tonumber(speed) or math.pi
	local orbiter = bot.Character.HumanoidRootPart
	local angle = 0
	orbitcon = game:GetService("RunService").Heartbeat:Connect(function(dt)
		if not target.Character then return end
		origin = target.Character.HumanoidRootPart.CFrame
		angle = (angle + dt * rps) % (2 * math.pi)
		orbiter.CFrame = origin * CFrame.new(math.cos(angle) * r, 0, math.sin(angle) * r)
	end)
end

local function unorbit()
	orbitcon:Disconnect()
end

local commands 

local function checkCommands(cmd)
	for i, cmds in pairs(commands) do
		if cmds == cmd or table.find(cmds.Aliases, cmd) or cmds.Name == cmd then
			return cmds	
		end
	end
	
	return nil
end


local function searchPlayers(query)
	query = string.lower(query)
	
	for i, player in pairs(game.Players:GetPlayers()) do
		if string.find(string.lower(player.DisplayName), query) or string.find(string.lower(player.Name), query) then
			return player
		end
	end
	
	return nil
end

commands = {
	cmds = {
		Name = "cmds",
		Aliases = {"commands"},
		Use = "Lists all commands!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			task.spawn(function()
				for i, cmd in pairs(commandsMessage) do
					chat(cmd)
					wait(0.5)
				end
			end)
		end,
	},
	aliases = {
		Name = "aliases",
		Aliases = {},
		Use = "Lists the aliases for the given command!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			task.spawn(function()
				if not args[2] then return end
				
				local cmd = checkCommands(args[2])
				
				local function getAliases(c)
					local str = ""
					
					if #c.Aliases == 0 then return "None" end
					
					for i, a in pairs(c.Aliases) do
						str = str .. a .. ", "
					end
					
					return str
				end
				
				if cmd then
					chat(cmd.Name .. " - " .. getAliases(cmd))
				else
					chat("Invalid command!")
				end
			end)
		end,
	},
	help = {
		Name = "help",
		Aliases = {"help"},
		Use = "Tells you the use of <command>!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			task.spawn(function()
				if not args[2] then
					return
				end
				
				if string.sub(args[2], 1, 1) == prefix then
					args[2] = string.sub(args[2], 2)
				end
			
				local cmd = checkCommands(args[2])
				
				if cmd then
					chat(cmd.Name .. " - " .. cmd.Use)
				else
					chat("Invalid command!")
				end
			end)
		end,
	},
	reset = {
		Name = "reset",
		Aliases = {"re"},
		Use = "Respawns LunarBot!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			local hum = bot.Character:FindFirstChildWhichIsA("Humanoid")
			
			if hum then
				hum.Health = 0
			end
		end,
	},

    math = {
		Name = "math",
		Aliases = {},
		Use = "Does <operation> on arguments.",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				if not args[2] then return end
				if not args[3] then return end
				if not args[4] then return end
				
				local operations = {
					"add",
					"subtract",
					"multiply",
					"divide"
				}
				
				local operation = args[2]
				
				if not table.find(operations, operation) then
					chat("Invalid operation!")
					return
				end
				
				local result
				
				local nums = {}
				
				for i, arg in pairs(args) do
					if i > 2 then
						if tonumber(arg) then
							table.insert(nums, tonumber(arg))
						else
							chat("Attempt to do math on unknown characters!")
							return	
						end
					end
				end
				
				for i, num in pairs(nums) do
					if i == 1 then
						result = num
					else
						if operation == "add" then
							result = result + num
						elseif operation == "subtract" then
							result = result - num
						elseif operation == "divide" then
							result = result / num
						elseif operation == "multiply" then
							result = result * num
						end
					end
				end
				
				chat("Result: " .. tostring(result))
			end)
		end,
	},

	lua = {
		Name = "lua",
		Aliases = {"runlua", "run", "luau"},
		Use = "Gives you the executor that is running pluto",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			if speaker ~= bot.Name then
				chat("You do not have permission to run LuaU from pluto")
				return
			end
			
			local torun = string.sub(msg, 5)
			
			local success, errMsg = pcall(function()
				loadstring(torun)()
			end)
			
			if success then
				chat("Successfully ran LuaU with no errors.")
			elseif not success and errMsg then
				chat("Failed to run LuaU with error in Developer Console [F9]!")
			end
		end,
	},


	playercount = {
		Name = "playercount",
		Aliases = {"plrcount"},
		Use = "Chats the current amount of players!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			chat(tostring(#game.Players:GetPlayers()))
		end,
	},

	unfollow = {
		Name = "unfollow",
		Aliases = {"unfollowplr"},
		Use = "Respawns pluto",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				task.spawn(function()
					followplr = nil
					wait()
					bot.Character.Humanoid:MoveTo(bot.Character.HumanoidRootPart.Position)
				end)
			end)
		end,
	},
	follow = {
		Name = "follow",
		Aliases = {"followplr"},
		Use = "Makes pluto follow you or the given player!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			local plr
			
			if args[2] then
				if args[2] == "random" then
					local players = game.Players:GetPlayers()
					
					plr = players[math.random(1, #players)]
				else
					local searched = searchPlayers(args[2])
				
					if searched ~= nil then
						plr = searched
					else
						chat("Invalid player!")
						return
					end
				end
			else
				plr = game.Players:FindFirstChild(speaker)
			end
			
			followplr = plr
		end,
	},

	jobid = {
		Name = "jobid",
		Aliases = {"serverid"},
		Use = "Returns the current server's Server ID, or Job ID.",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			chat(game.JobId)
		end,
	},
	say = {
		Name = "say",
		Aliases = {"chat"},
		Use = "Says the <message> in chat!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			local tosay
			
			if args[1] == "say" then
				tosay = string.sub(msg, 6)
			else
				tosay = string.sub(msg, 8)
			end
			
			local speakerplayer = game.Players:FindFirstChild(speaker)
			
			if not speakerplayer then return end
			
			if altctrl then chat(tosay) else chat(speakerplayer.DisplayName .. ": " .. tosay) end
		end,
	},
	
	dance = {
		Name = "dance",
		Aliases = {},
		Use = "Makes pluo dance!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			game:GetService("Players"):Chat("/e dance")
		end,
	},

	jump = {
		Name = "jump",
		Aliases = {},
		Use = "Makes LunarBot jump!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			bot.Character.Humanoid.Jump = true
		end,
	},
	announce = {
		Name = "announce",
		Aliases = {},
		Use = "Makes an announcement via chat, a owner-only command!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			if speaker ~= bot.Name then return end
		
			chat("-- ANNOUNCEMENT -- ")
			wait()
			chat(string.sub(msg, 10))
			wait()
			chat("-- ANNOUNCEMENT --")
		end,
	},
	whitelist = {
		Name = "whitelist",
		Aliases = {"wl"},
		Use = "Whitelists a player, meaning they can use LunarBot. An owner-only command!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			local towhitelist = args[2]
			
			if speaker ~= bot.Name then return end
			
			if towhitelist then
				if towhitelist == "all" then
					for i, player in pairs(game.Players:GetPlayers()) do
						table.insert(whitelisted, player.Name)
						local bl = player:FindFirstChild("PlutoBotBlacklist")
						if bl then bl:Destroy() else warn(player.DisplayName .. " was not blacklisted!") end
					end
					
					allwhitelisted = true
					
					chat("Whitelisted all players that are currently in the game! Type .cmds to view commands.")
				else
					local plr = searchPlayers(towhitelist)
					
					if plr then
						table.insert(whitelisted, plr.Name)
						local bl = plr:FindFirstChild("PlutoBotBlacklist")
						if bl then bl:Destroy() else warn(player.DisplayName .. " was not blacklisted!") end
						chat("Whitelisted " .. plr.DisplayName .. "! Type .cmds to view commands.")
					else
						chat("Failed to whitelist player - User not found!")
					end
				end
			end
		end,
	},

	blacklist = {
		Name = "blacklist",
		Aliases = {"bl"},
		Use = "Blacklists a player meaning they cannot use pluto. Owner-only command!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			local toblacklist = args[2]
			
			if speaker ~= bot.Name then return end
			
			if toblacklist then
				if toblacklist == "all" then
					for i, p in pairs(game.Players:GetPlayers()) do
						local alrbl = p:FindFirstChild("PlutoBotBlacklist")
						
						if alrbl then alrbl:Destroy() end
					
						local new = Instance.new("BoolValue")
						new.Parent = p
						new.Name = "PlutoBotBlacklist"
						new.Value = true
					end
					
					allwhitelisted = false
					
					chat("Blacklisted all players that are currently in the game! They can no longer run commands.")
				else
					local plr = searchPlayers(toblacklist)
					
					if plr then
						local alrbl = plr:FindFirstChild("PlutoBotBlacklist")
						
						if alrbl then alrbl:Destroy() end
					
						local new = Instance.new("BoolValue")
						new.Parent = plr
						new.Name = "PlutoBotBlacklist"
						new.Value = true
						alwhitelisted = false
						chat("Blacklisted " .. plr.DisplayName .. "! They can no longer run commands.")
					else
						chat("Failed to blacklist player - User not found!")
					end
				end
			end
		end,
	},
	coinflip = {
		Name = "coinflip",
		Aliases = {"flip", "coin"},
		Use = "Flips a coin using a randomly generated number from 1 to 2.",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			local flipped = math.random(1, 2)
			
			if flipped == 1 then
				chat("HEADS!")
			elseif flipped == 2 then
				chat("TAILS!")
			else
				chat("Whoops! An unknown error occured while flipping the coin. That's a bit embarrasing.")
			end
		end,
	},
	bring = {
		Name = "bring",
		Aliases = {},
		Use = "Brings pluto to the player that chatted the command.",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				local plr = game.Players:FindFirstChild(speaker)
			
				if plr then
					bot.Character:SetPrimaryPartCFrame(plr.Character.HumanoidRootPart.CFrame)
				end
			end)
		end,
	},
	
	to = {
		Name = "to",
		Aliases = {},
		Use = "Teleports pluto to the <player> given.",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				if not args[2] then return end
			
				local plr = nil
				
				if args[2] == "random" then
					local players = game.Players:GetPlayers()
					
					plr = players[math.random(1, #players)]
				else
					plr = searchPlayers(args[2])
				end
			
				if plr then
					bot.Character:SetPrimaryPartCFrame(plr.Character.HumanoidRootPart.CFrame)
				else
					chat("Invalid player!")
				end
			end)
		end,
	},
	walkto = {
		Name = "walkto",
		Aliases = {"come"},
		Use = "Makes pluto walk to you or the given player!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				local plr
				
				if not args[2] then plr = game.Players:FindFirstChild(speaker) end
				
				if args[2] and args[2] == "random" then
					plr = game.Players:GetPlayers()[math.random(1,#game.Players:GetPlayers())]
				elseif args[2] then
					plr = searchPlayers(args[2])
				end
			
				if plr and plr:IsA("Player") then
					bot.Character.Humanoid:MoveTo(plr.Character.HumanoidRootPart.Position)
				else
					chat("Could not find player!")
				end
			end)
		end,
	},

	setprefix = {
		Name = "setprefix",
		Aliases = {"prefix"},
		Use = "Sets the prefix of pluto Owner-only command!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				if not args[2] then return end
			
				if speaker == bot.Name then
					if args[2] == "#" then return end
					if string.len(args[2]) >= 2 then chat("Maximum prefix length is 1 character!") return end
				
					prefix = args[2]
					chat("Successfully set prefix to '" .. prefix .. "'!")
				else
					chat("You do not have the permissions to run .setprefix!")
				end
			end)
		end,
	},
	
	funfact = {
		Name = "funfact",
		Aliases = {"fact", "randomfact"},
		Use = "Gives you a random fun fact!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				local rnd = funfacts[math.random(1, #funfacts)]
				
				chat("Fun Fact: " .. rnd)
			end)
		end,
	},

	walkspeed = {
		Name = "walkspeed",
		Aliases = {"speed"},
		Use = "Sets plutos walkspeed to <speed>!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				if not args[2] then return end
				if not tonumber(args[2]) then return end
				
				if tonumber(args[2]) > 1000 then
					chat("Whoops! That speed is over the speed limit of 1000.")
					return
				end
			
				bot.Character.Humanoid.WalkSpeed = tonumber(args[2])
				
				chat("Changed walkspeed to " .. args[2] .. "!")
			end)
		end,
	},
	
	math = {
		Name = "math",
		Aliases = {},
		Use = "Does <operation> on arguments.",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				if not args[2] then return end
				if not args[3] then return end
				if not args[4] then return end
				
				local operations = {
					"add",
					"subtract",
					"multiply",
					"divide"
				}
				
				local operation = args[2]
				
				if not table.find(operations, operation) then
					chat("Invalid operation!")
					return
				end
				
				local result
				
				local nums = {}
				
				for i, arg in pairs(args) do
					if i > 2 then
						if tonumber(arg) then
							table.insert(nums, tonumber(arg))
						else
							chat("Attempt to do math on unknown characters!")
							return	
						end
					end
				end
				
				for i, num in pairs(nums) do
					if i == 1 then
						result = num
					else
						if operation == "add" then
							result = result + num
						elseif operation == "subtract" then
							result = result - num
						elseif operation == "divide" then
							result = result / num
						elseif operation == "multiply" then
							result = result * num
						end
					end
				end
				
				chat("Result: " .. tostring(result))
			end)
		end,
	},
	disablecommand = {
		Name = "disablecommand",
		Aliases = {"disablecmd", "cmddisable"},
		Use = "Disables the specified command. Owner-only command!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				if not speaker == bot.Name then chat("You do not have permission to disable this command.") return end
			
				if not args[2] then return end
			
				local cmd = checkCommands(args[2])
			
				if not cmd then
					chat("Invalid command!")
					return
				end
				
				cmd.Enabled = false
				chat("Disabled command: " .. cmd.Name .. "!")
			end)
		end,
	},
	enablecommand = {
		Name = "enablecommand",
		Aliases = {"enablecmd", "cmdenable"},
		Use = "Enables the specified command! Owner-only command!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				if not speaker == bot.Name then chat("You do not have permission to disable this command.") return end
			
				if not args[2] then return end
			
				local cmd = checkCommands(args[2])
			
				if not cmd then
					chat("Invalid command!")
					return
				end
				
				cmd.Enabled = true
				chat("Enabled command: " .. cmd.Name .. "!")
			end)
		end,
	},
	
	altcontrol = {
		Name = "altcontrol",
		Aliases = {"altctrl"},
		Use = "Removes the name from the .say command.",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				altctrl = true
				chat("Enabled alt control mode!")
			end)
		end,
	},
	spin = {
		Name = "spin",
		Aliases = {"rotate"},
		Use = "Makes the bot spin!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				local pwr = 100
				
				if args[2] and tonumber(args[2]) then pwr = tonumber(args[2]) end
			
				local already = bot.Character.HumanoidRootPart:FindFirstChild("Spinner")
				
				if already then already:Destroy() end
			
				local spinner = Instance.new("BodyAngularVelocity")
				spinner.Name = "Spinner"
				spinner.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
				spinner.MaxTorque = Vector3.new(0,math.huge,0)
				spinner.AngularVelocity = Vector3.new(0,pwr,0)
			end)
		end,
	},
	unspin = {
		Name = "unspin",
		Aliases = {"unrotate"},
		Use = "Stops the spinning bot!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				local spinner = game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("Spinner")
				if spinner then spinner:Destroy() end
			end)
		end,
	},
	float = {
		Name = "float",
		Aliases = {"levitate"},
		Use = "Floats the bot!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				local f = 9
				if args[2] and tonumber(args[2]) then f = tonumber(args[2]) end
				bot.Character.Humanoid.HipHeight = f
			end)
		end,
	},
	unfloat = {
		Name = "unfloat",
		Aliases = {"unlevitate"},
		Use = "Unfloats the bot!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				bot.Character.Humanoid.HipHeight = HH
			end)
		end,
	},
	orbit = {
		Name = "orbit",
		Aliases = {"orbit"},
		Use = "Orbits the bot around you!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				local player = game.Players:FindFirstChild(speaker)
				
				if not player then return end
			
				orbit(player, args[2], args[3])
			end)
		end,
	},
	unorbit = {
		Name = "unorbit",
		Aliases = {"unorbit"},
		Use = "Halts the orbit!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				unorbit()
			end)
		end,
	},
}


local cmdcon = messageReceived:Connect(function(data)
	local message = data.Text
	
	local speakerplayer = game.Players:GetPlayerByUserId(data.TextSource.UserId)
    local speaker = speakerplayer.Name
	
	if not speakerplayer then return end

	local msg = string.lower(message)
	
	if string.sub(msg, 1, 1) == prefix then
		if speakerplayer:FindFirstChild("LunarBotBlacklist") then
			return
		end

		if not table.find(whitelisted, speaker) and allwhitelisted == false then
			return
		end
		
		if rickrolling == true then return end
	
		msg = string.sub(msg, 2)
		
		local args = string.split(msg, " ")
		
		local cmd = checkCommands(args[1])
		
		if status ~= nil and speaker ~= bot.Name then
			chat("pluo status // " .. status .. " // Commands are disabled.")
			return
		end
		
		if cmd ~= nil then
			if cmd.Enabled == false then
				chat("The command " .. cmd.Name .. " is currently disabled. Please request it to be re-enabled by " .. bot.DisplayName .. ".")
				print("Logs // " .. speaker .. " attempted to run command: " .. cmd.Name .. " with arguments: " .. tts(args) .. "while the command was disabled.")
				return
			else
				cmd.CommandFunction(message, args, speaker)
				
				local function tts(t)
					local r = ""
					
					for i, v in pairs(t) do
						r = r .. v .. ", "
					end
					
					return r
				end
				
				print("Logs // " .. speaker .. " ran command: " .. cmd.Name .. " with arguments: " .. tts(args))
			end
		else
			warn("Could not find command: " .. args[1] .. "!")
		end
	elseif speakerplayer == copychatplayer then
		if altctrl then chat(message) else chat(speakerplayer.DisplayName .. ": " .. message) end
	end
end)

bot.Chatted:Connect(function(msg)
	if (string.lower(msg) == "lunar.disable()" or string.lower(msg) == "lunar.disconnect()") and disconnected == false then
		cmdcon:Disconnect()
		disconnected = true
		wait()
		chat("Successfully disconnected LunarBot.")
	end
end)


task.spawn(function()
	while wait(randommoveinteger) do
		if randommove == true and disconnected == false then
			local rndnum = math.random(1,4)
			local add = Vector3.new(0,0,0)
			
			if rndnum == 1 then
				add = Vector3.new(15,0,0)
			elseif rndnum == 2 then
				add = Vector3.new(-15,0,0)
			elseif rndnum == 3 then
				add = Vector3.new(0,0,15)
			else
				add = Vector3.new(0,0,-15)
			end
			
			bot.Character.Humanoid:MoveTo(bot.Character.HumanoidRootPart.Position + add)
		end
	end
end)

task.spawn(function()
	while wait() do
		if followplr and disconnected == false then
			local hum = bot.Character.Humanoid
			
			if hum then
				hum:MoveTo(followplr.Character.HumanoidRootPart.Position)		
			end
		end
	end
end)

