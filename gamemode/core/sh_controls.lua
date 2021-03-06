if CLIENT then

	local lastHand = 0
	local lastKick = 0
	local lastCelebration = 0

	function GFL:KeyPress(ply, key)
		local ball = gfl.GetBall()
		if not ball then return end
		local feetPos = LocalPlayer():GetPos() + LocalPlayer():GetAngles():Up() * 3
		if key == IN_ATTACK and CurTime() > lastKick + 1 then
			if feetPos:Distance(gfl.GetBall():GetPos()) > 42 then return end
			--local inFront = ents.FindInCone(feetPos, LocalPlayer():GetAngles():Forward(), 130, 140)
			netstream.Start("ballKick")
			lastKick = CurTime()
			return false
		elseif key == IN_RELOAD and CurTime() > lastHand + 8 then
			netstream.Start("handUp")
			lastHand = CurTime()
			return false
		elseif key == IN_USE and (LocalPlayer().ScoreTime or 0) + 10 > CurTime() and CurTime() > lastCelebration + 10 then
			netstream.Start("randomCelebration")
			lastCelebration = CurTime()
		end
	end


	netstream.Hook("ballKickAnim", function(ply)
		if ply.SetLuaAnimation then
			ply:SetLuaAnimation("gfl_normal_kick")
		end
	end)

	netstream.Hook("ballDribbleAnim", function(ply)
		if ply.SetLuaAnimation then
			ply:SetLuaAnimation("gfl_small_kick")
		end
	end)


	netstream.Hook("playGesture", function(ply, act)
		ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, act, true)
	end)
else
	netstream.Hook("handUp", function(ply)
		ply:PlayGesture(ACT_SIGNAL_HALT)
		for v,k in pairs(team.GetPlayers(ply:Team())) do
			k:Notify(0,1, ply:Nick().." is requesting attention.", 3, ply)
		end
	end)

	netstream.Hook("ballKick", function(ply)
		local trace = ply:GetEyeTrace()
		local feetPos = ply:GetPos() + ply:GetAngles():Up() * 3
		local ball = gfl.ball
		if feetPos:Distance(ball:GetPos()) > 51 then return end -- compensate for lag by allowing some slack on the distance
			for v,k in pairs(player.GetAll()) do
				netstream.Start(k, "ballKickAnim", ply)
			end
			ball:EmitSound("gfl/kick_"..math.random(1,4)..".wav", 90)
			local phys = gfl.ball:GetPhysicsObject()
			local damage = 35
			local force = ply:GetAimVector():GetNormalized() * (damage * (ply.stamina/2+45) * 5)
			phys:ApplyForceOffset(force, trace.HitPos)
			ball.lastKicker = ply
			ball.lastToucher = ply
			ply:RestoreStamina(-14)
	end)

	local celebrations = {
		ACT_GMOD_TAUNT_CHEER,
		ACT_GMOD_TAUNT_ROBOT,
		ACT_GMOD_TAUNT_SALUTE,
		ACT_GMOD_TAUNT_DISAGREE
	}

	netstream.Hook("randomCelebration", function(ply)
		local ran = celebrations[math.random(0,#celebrations)] or 1620
		ply:PlayGesture(ran)
	end)

end
