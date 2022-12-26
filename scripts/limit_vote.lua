local _G = GLOBAL
local TheNet = _G.TheNet
local FOODGROUP = _G.FOODGROUP
local require = _G.require
------------------------------------------------------------------------------
local UserCommands = _G.require("usercommands")
local no_rollback = GetModConfigData("no_rollback")
local no_regenerate = GetModConfigData("no_regenerate")
function showstarter(src, data)
    local cmd = UserCommands.GetCommandFromHash(data.commandhash)
    if cmd ~= nil then
        print("[NoVote]Vote Start by:", data.starteruserid, cmd.name, data.commandhash, data.targetuserid)
    end
end
function WaitActivated(inst)
    if TheNet and TheNet:GetIsServer() then
        print("[NoVote]init...")
        print("[NoVote]AddUserCommand", AddUserCommand)
        print("[NoVote]_G.AddUserCommand", _G.AddUserCommand)
        print("[NoVote]AddModUserCommand", AddModUserCommand)
        print("[NoVote]_G.AddModUserCommand", _G.AddModUserCommand)
        print("[NoVote]AddVoteCommand", AddVoteCommand)
        print("[NoVote]_G.smallhash", _G.smallhash)
        print("[NoVote]UserCommands.GetCommandFromName", UserCommands.GetCommandFromName)
        if no_rollback then
            print("[NoVote]no_rollback", no_rollback)
            print("[NoVote]rollback Cmd", UserCommands.GetCommandFromName("rollback"))
            local rollbackCmd = UserCommands.GetCommandFromName("rollback")
            if rollbackCmd ~= nil then
                rollbackCmd.votetimeout = 60
                rollbackCmd.serverfn = function(params, caller)
                    if caller ~= nil then
                        print("[NoVote][rollback]serverfn", caller, caller.name, caller.userid)
                    else
                        print("[NoVote][rollback]serverfn", caller)
                    end
                end
            else
                print("[NoVote][rollback]Patch Cmd Faild!!")
            end
            print("[NoVote]rollback2", UserCommands.GetCommandFromName("rollback"))
        end
        if no_regenerate then
            print("[NoVote]no_regenerate", no_regenerate)
            print("[NoVote]regenerate", UserCommands.GetCommandFromName("regenerate"))
            local regenerateCmd = UserCommands.GetCommandFromName("regenerate")
            if regenerateCmd ~= nil then
                regenerateCmd.votetimeout = 60
                regenerateCmd.serverfn = function(params, caller)
                    if caller ~= nil then
                        print("[NoVote][regenerate]serverfn", caller, caller.name, caller.userid)
                    else
                        print("[NoVote][regenerate]serverfn", caller)
                    end
                end
            else
                print("[NoVote][regenerate]Patch Cmd Faild!!")
            end
            print("[NoVote]regenerate2", UserCommands.GetCommandFromName("regenerate"))
        end
        print("[NoVote]kick", UserCommands.GetCommandFromName("kick"))

        local kickCmd = UserCommands.GetCommandFromName("kick")
        if kickCmd ~= nil then
            kickCmd.votetimeout = 90
            kickCmd.localfn = function(params, caller)
                if caller ~= nil then
                    print("[NoVote][kick]serverfn", caller, caller.name, caller.userid)
                else
                    print("[NoVote][kick]serverfn", caller)
                end
                local clientid = _G.UserToClientID(params.user)
                if clientid ~= nil then
                end
            end
        else
            print("[NoVote][kick]Patch Cmd Faild!!")
        end
        print("[NoVote]kick2", UserCommands.GetCommandFromName("kick"))
    end
end
AddPrefabPostInit("world", WaitActivated)
------------------------------------------------------------------------------
