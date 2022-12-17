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
   Main
   WindowPort

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

   proc {Main Port ID State} Position F Flag in

      if {IsDead Port ID State} then
         % do things for dead players
         skip
      else
         skip % do nothing
      end

      {SimulatedThinking}
      %{System.show State.flags}
      {Send Port move(ID Position)}
      {SendToAll sayMoved(ID Position)}
      {Send WindowPort moveSoldier(ID Position)}

      % Flags
      F = {GetFlag State.flags Position}
      {Send Port takeFlag(ID Flag)}
      if Flag \= null andthen F \= nil then
         {SendToAll sayFlagTaken(ID F)}
         {Send WindowPort removeFlag(F)}
      else
         skip
      end

      {Delay 500}
        %{System.show endOfLoop(ID)}
      {Main Port ID State}
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
            {Main Port ID state(mines:nil flags:Input.flags)}
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

      {InitThreadForAll PlayersPorts}
   end
end
