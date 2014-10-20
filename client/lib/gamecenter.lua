local gamecenter = {}
local GameCenter = GameCenter
local _debug, _info, _warn, _error = require("qlog").loggers("gamecenter")
if GameCenter == nil then
	GameCenter = {
		login = function()
			_debug("GameCenter login")
		end,
		setLoginCallback = function()
		end,
		submitAchievement = function(id, progress)
			_debug("GameCenter achievement progress: " .. id .. " = " .. tostring(progress))
		end,
		getFriendsList = function()
			return {}
		end,
		isLoggedIn = function()
			return false
		end
	}
end
local _friendsList = {}
local _loggingIn = false
local _loginFailedCallback, friendsListCallback
local function friendsListReady(friends)
	_friendsList = friends
	if friendsListCallback then
		friendsListCallback(friend)
	end
end
local function loginCallback()
	MOAIGameCenter.setGetFriendsListCallback(friendsListReady)
	MOAIGameCenter.getFriendsList()
end
local function loginFailedCallback()
	if _loginFailedCallback then
		_loginFailedCallback()
	end
end
local _haveShownGCLogin = false
function gamecenter.autologin()
	if not _haveShownGCLogin and not _loggingIn then
		_haveShownGCLogin = true
		_loggingIn = true
		GameCenter.setLoginCallback(loginCallback)
		GameCenter.setLoginFailedCallback(loginFailedCallback)
		GameCenter.login()
	end
end
function gamecenter.login()
	if GameCenter.isLoggedIn() or _loggingIn then
		return
	end
	GameCenter.setLoginCallback(loginCallback)
	GameCenter.setLoginFailedCallback(loginFailedCallback)
	GameCenter.login()
end
function gamecenter.update(achievementId, percentComplete)
	GameCenter.submitAchievement(achievementId, percentComplete)
end
function gamecenter.isLoggedIn()
	return GameCenter.isLoggedIn()
end
function gamecenter.openGC()
	MOAIApp.openURL("gamecenter:/me/account")
end
function gamecenter.getFriendsList()
	return _friendsList
end
function gamecenter.getUserInfo(userList, callback)
	if not GameCenter.isLoggedIn() then
		return
	end
	_debug("Attempting to fetch user data", userList, callback)
	MOAIGameCenter.setGetUserInfoCallback(callback)
	MOAIGameCenter.getUserInfo(userList)
end
function gamecenter.clearGetUserInfoCallback()
	MOAIGameCenter.setGetUserInfoCallback(nil)
end
function gamecenter.getAlias()
	return MOAIGameCenter.getPlayerAlias()
end
function gamecenter.getID()
	return MOAIGameCenter.getPlayerID()
end
function gamecenter.setFriendsListCallback(callback)
	friendsListCallback = callback
end
function gamecenter.reportScore(score, board)
	if not GameCenter.isLoggedIn() then
		return
	end
	MOAIGameCenter.reportScore(score, board)
end
function gamecenter.setLoginFailedCallback(func)
	_loginFailedCallback = func
end
function gamecenter.onLoginFailedDismissed()
	_loggingIn = false
end
return gamecenter
