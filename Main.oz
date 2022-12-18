functor
import
   GUI
   Input
   PlayerManager
   System
   OS
define
   DoListPlayer
   InitThreadForAll
   PlayersPorts
   SendToAll
   SimulatedThinking
   GetFlag
   IsDead
   ProcessCommonStream
   Main
   WindowPort
   CommonPort
   CommonStream

   proc {DrawFlags Flags Port}
      case Flags of nil then skip 
      [] Flag|T then
         {Send Port putFlag(Flag)}
         {DrawFlags T Port}
      end
   end
in
   fun {DoListPlayer Players Colors ID}
      case Players#Colors
      of nil#nil then nil
      [] (Player|NextPlayers)#(Color|NextColors) then
         player(ID {PlayerManager.playerGenerator Player Color ID})|
         {DoListPlayer NextPlayers NextColors ID+1}
      end
   end

   proc {SendToAll M}
      proc {Rec L}
         case L
         of H|T then P in H=player(_ P) {Send P M} {Rec T}
         else skip end
      end
   in
      {Rec PlayersPorts}
   end

   SimulatedThinking = proc{$} {Delay ({OS.rand} mod (Input.thinkMax - Input.thinkMin) + Input.thinkMin)} end

   fun {GetFlag Flags Position}
      case Flags
      of flag(color:C pos:P)|T then
         if P == Position then
            flag(color:C pos:P)
         else
            {GetFlag T Position}
         end
      else nil end
   end

   fun {IsDead Port ID State}
      false
   end

   proc {Main Port ID State} 
      Position
      Life
      Kind
      Flags
      F 
      Flag 
      OldFlag 
   in

      {Send Port isDead(Life)}
		{Wait Life}

		{SimulatedThinking}

		%%%% #1 : If player is dead, we remove him and make him respawn to his base %%%%
		if Life then
			{Send WindowPort removeSoldier(ID)}
			{SendToAll sayDeath(ID)}
			%{Respawn()} TODO MAKE PLAYER RESPAWN
			
		else

			%{System.show F} %%%% DEBUG

			%{SimulatedThinking}

			%%%% #2/#3 : ask where the player wants to move %%%%
                   {Send Port move(ID Position)}
                   if {Member
                       {List.nth {List.nth Input.map Position.x} Position.y}
                       [0 (ID.id+1) mod 2)+1} then
                      skip
                   else
                      {Main Port ID State} % invalid move, goto start of loop
                   end
                   {SendToAll sayMoved(ID Position)}
                   {Send WindowPort moveSoldier(ID Position)}


			%%%% #4 : TODO


			%{SimulatedThinking}

			%%%% #5 : ask the player if he wants to reload one of his weapons %%%%
			{Send Port chargeItem(ID Kind)}
			{SendToAll sayCharge(ID Kind)}


			%{SimulatedThinking}

			%%%% #6 : ask the player if he wants to use one of his weapons %%%%
			%{Send Port fireItem(ID Kind)} TODO PATCH


         %{SimulatedThinking}

         %%%% #7 : ask the player if he wants to grab or drop flag %%%%
         {Send State.commonPort getFlag(ID OldFlag)}
         if OldFlag \= null then NewFlag in % does the player have a flag
            {Send Port dropFlag(ID Flag)}
            if Flag == null then   % the player wants to drop the flag
               {Send State.commonPort unlinkFlag(ID)}
            else
               NewFlag = flag(pos:Position color:OldFlag.color)
               {Send State.commonPort moveFlag(OldFlag NewFlag)}
               {Send WindowPort removeFlag(OldFlag)}
               {Send WindowPort putFlag(NewFlag)}
            end
         else                      % the player has no flag
%            {System.show have_no_flag}
            {Send State.commonPort getFlags(Flags)}
            F = {GetFlag Flags Position}
            if F \= nil then
               if F.color == ID.color then
                  skip
               else       % is there a flag
                  {Send Port takeFlag(ID Flag)}
                  if Flag \= null then % the player wants a flag
                     {Send State.commonPort pair(ID F)}
                     {SendToAll sayFlagTaken(ID F)}
                     {Send WindowPort removeFlag(F)}
                     {Send WindowPort putFlag(F)}
                  else
                     skip
                  end
               end
            else
               skip
            end
         end
      end
      

      %{Delay 500} %%%% Delay for better performances
      
      %{System.show endOfLoop(ID)}


      {Main Port ID State}
   end

   proc {ProcessCommonStream CommonStream Flags FlagPairs}
      fun {GetFlag L K}
         case L
         of flagpair(K1 V)|T then
            if K==K1 then V
            else {GetFlag T K} end
         [] nil then null end
      end
      fun {Insert L K V}
         case L
         of H|T then
            if H==K then
               flagpair(K V)|T
            else
               H|{Insert T K V}
            end
         [] nil then
            [flagpair(K V)]
         end
      end
      fun {ReplaceFlag L Old New}
         case L
         of H|T then
            if H==Old then New|T
            else H|{ReplaceFlag T Old New} end
         [] nil then nil end
      end
      fun {ReplaceFlagPair L Old New}
         case L
         of flagpair(K V)|T then
            if V==Old then flagpair(K New)|T
            else flagpair(K V)|{ReplaceFlagPair T Old New} end
         [] nil then nil end
      end
      fun {Delete L K}
         case L
         of flagpair(K1 V)|T then
            if K==K1 then T
            else flagpair(K1 V)|{Delete T K} end
         [] nil then nil end
      end
   in
      case CommonStream.1
      of getFlags(F) then
         F=Flags
         {ProcessCommonStream CommonStream.2 Flags FlagPairs}
      [] pair(ID Flag) then
         {ProcessCommonStream CommonStream.2 Flags {Insert FlagPairs ID Flag}}
      [] unlinkFlag(ID) then
         {ProcessCommonStream CommonStream.2 Flags {Delete FlagPairs ID}}
      [] getFlag(ID Flag) then
         Flag = {GetFlag FlagPairs ID}
         {ProcessCommonStream CommonStream.2 Flags FlagPairs}
      [] moveFlag(OldFlag NewFlag) then
         {ProcessCommonStream CommonStream.2
          {ReplaceFlag Flags OldFlag NewFlag}
          {ReplaceFlagPair FlagPairs OldFlag NewFlag}}
      else
         {System.show processCommonStream#CommonStream.1}
         {ProcessCommonStream CommonStream.2 Flags FlagPairs}
      end
   end

   proc {InitThreadForAll Players}
      case Players
      of nil then
         {Send WindowPort initSoldier(null pt(x:0 y:0))}
         {DrawFlags Input.flags WindowPort}
      [] player(_ Port)|Next then ID Position in
         {Send Port initPosition(ID Position)}
         {Send WindowPort initSoldier(ID Position)}
         {Send WindowPort lifeUpdate(ID Input.startHealth)}
         thread
            {Main Port ID state(mines:nil flags:Input.flags commonPort:CommonPort)}
         end
         {InitThreadForAll Next}
      end
   end

   thread
        % Create port for window
      WindowPort = {GUI.portWindow}

        % Open window
      {Send WindowPort buildWindow}
      {System.show buildWindow}

        % Create port for players
      PlayersPorts = {DoListPlayer Input.players Input.colors 1}

      {NewPort CommonStream CommonPort}
      {InitThreadForAll PlayersPorts}
      thread
         {ProcessCommonStream CommonStream Input.flags nil}
      end
   end
end
