functor
import
   Input
   OS
   System
export
   portPlayer:StartPlayer
define
    % Vars
   MapWidth = {List.length Input.map}
   MapHeight = {List.length Input.map.1}

    % Functions
   StartPlayer
   TreatStream
   MatchHead

    % Message functions
   InitPosition
   NewTurn
   Move
   IsDead
   AskHealth
   SayMoved
   SayMineExplode
   SayDeath
   SayDamageTaken
   SayFoodAppeared
   SayFoodEaten
   SayFlagTaken
   SayFlagDropped
   ChargeItem
   SayCharge
   FireItem
   SayMinePlaced
   SayShoot
   TakeFlag
   DropFlag

   SetPosition
   SetPlayers

    % Helper functions
   RandomInRange = fun {$ Min Max} Min+({OS.rand}mod(Max-Min+1)) end
   MovePlayer
   HasNoPlayers
in
   fun {StartPlayer Color ID}
      Stream
      Port
   in
      {NewPort Stream Port}
      thread
         {TreatStream
          Stream
          state(
             id:id(name:basic color:Color id:ID)
             position:{List.nth Input.spawnPoints ID}
             map:Input.map
             hp:Input.startHealth
             flag:null
             mineReloads:0
             gunReloads:0
             startPosition:{List.nth Input.spawnPoints ID}
             players:nil)}
      end
      Port
   end

   proc{TreatStream Stream State}
      case Stream
      of H|T then {TreatStream T {MatchHead H State}}
      end
   end

   fun {MatchHead Head State}
      case Head 
      of initPosition(?ID ?Position) then {InitPosition State ID Position}
      [] move(?ID ?Position) then {Move State ID Position}
      [] sayMoved(ID Position) then {SayMoved State ID Position}
      [] sayMineExplode(Mine) then {SayMineExplode State Mine}
      [] sayFoodAppeared(Food) then {SayFoodAppeared State Food}
      [] sayFoodEaten(ID Food) then {SayFoodEaten State ID Food}
      [] chargeItem(?ID ?Kind) then {ChargeItem State ID Kind}
      [] sayCharge(ID Kind) then {SayCharge State ID Kind}
      [] fireItem(?ID ?Kind) then {FireItem State ID Kind}
      [] sayMinePlaced(ID Mine) then {SayMinePlaced State ID Mine}
      [] sayShoot(ID Position) then {SayShoot State ID Position}
      [] isDead(?Answer) then {IsDead State Answer}
      [] sayDeath(ID) then {SayDeath State ID}
      [] sayDamageTaken(ID Damage LifeLeft) then {SayDamageTaken State ID Damage LifeLeft}
      [] takeFlag(?ID ?Flag) then {TakeFlag State ID Flag}
      [] dropFlag(?ID ?Flag) then {DropFlag State ID Flag}
      [] sayFlagTaken(ID Flag) then {SayFlagTaken State ID Flag}
      [] sayFlagDropped(ID Flag) then {SayFlagDropped State ID flag}
      end
   end

   %% State Setters
   fun {SetPosition State Position}
      state(id:State.id position:Position
            map:State.map hp:State.hp flag:State.flag
            mineReloads:State.mineReloads gunReloads:State.gunReloads
            startPosition:State.startPosition players:State.players)
   end

   fun {SetPlayers State Players}
      state(id:State.id position:State.position
            map:State.map hp:State.hp flag:State.flag
            mineReloads:State.mineReloads gunReloads:State.gunReloads
            startPosition:State.startPosition players:Players)
   end

%%%% TODO Message functions

   fun {InitPosition State ?ID ?Position}
      ID = State.id
      Position = State.startPosition
      State
   end

   fun {HasNoPlayers Players X Y}
      case Players
      of player(id:_ position:pt(x:X1 y:Y1))|T then
         if X==X1 andthen Y==Y1 then
            false
         else
            {HasNoPlayers T X Y}
         end
      [] nil then true end
   end

   fun {Move State ?ID ?Position}
      proc {ChooseDirection XDiff YDiff} V in
         V = {OS.rand} mod 4
         if V > 1 then
            XDiff = 0
            YDiff = (V mod 2) * 2 - 1
         else
            XDiff = (V mod 2) * 2 - 1
            YDiff = 0
         end
      end
      fun {IsValidPosition X Y}
         if X >= 1 andthen Y >= 1 andthen Y =< MapHeight andthen X =< MapWidth
            andthen {List.nth {List.nth Input.map X} Y} \= 3
            andthen {HasNoPlayers State.players X Y} then
            true
         else
            false
         end
      end
      X Y XDiff YDiff
   in
      {ChooseDirection XDiff YDiff}
      State.position = pt(x:X y:Y)
      if {IsValidPosition X+XDiff Y+YDiff} then
         Position = pt(x:X+XDiff y:Y+YDiff)
      else
         Position = pt(x:X y:Y)
      end
      {SetPosition State Position}
   end

   fun {MovePlayer Players ID NewPosition}
      case Players
      of player(id:PlayerID position:PlayerPosition)|T then
         if ID==PlayerID then
            player(id:ID position:NewPosition)|T
         else
            player(id:PlayerID position:PlayerPosition)|{MovePlayer T ID NewPosition}
         end
      [] nil then
         [player(id:ID position:NewPosition)]
      end
   end

   fun {SayMoved State ID Position}
      {SetPlayers State {MovePlayer State.players ID Position}}
   end

   fun {SayMineExplode State Mine}
      State
   end

   fun {SayFoodAppeared State Food}
      State
   end

   fun {SayFoodEaten State ID Food}
      State
   end

   fun {ChargeItem State ?ID ?Kind} 
      R
    
	in

		%%%% Check if all weapons are full %%%%
        if State.mineReloads == Input.mineCharge andthen State.gunReloads == Input.gunCharge then
		    ID = State.id
		    Kind = null
		    State
        
		else
			if State.mineReloads == Input.mineCharge then
				Kind = gunReloads
                ID = State.id
                R = State.Kind + 1 
				State
			else
				Kind = mineReloads
				ID = State.id
				R = State.Kind + 1
				State
			end
		end
	end

   fun {SayCharge State ID Kind}
      State
   end

   fun {FireItem State ?ID ?Kind}
      ID = State.id
      Kind = null
      State
   end

   fun {SayMinePlaced State ID Mine}
      State
   end

   fun {SayShoot State ID Position}
      State
   end

   fun {IsDead State ?Answer}
      Answer = State.hp < 1
      State
  end

   fun {SayDeath State ID}
      State
   end

   fun {SayDamageTaken State ID Damage LifeLeft}
      State
   end

   fun {TakeFlag State ?ID ?Flag}
      ID = State.id
      Flag = flag(pos:_ color:_)
      State
   end

   fun {DropFlag State ?ID ?Flag}
      ID = State.id
      if {OS.rand} mod 10 < 2 then
         Flag = null
      else
         Flag = flag(pos:_ color:_)
      end
      State
   end

   fun {SayFlagTaken State ID Flag}
      State
   end

   fun {SayFlagDropped State ID Flag}
      State
   end
end
