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

    % Helper functions
    RandomInRange = fun {$ Min Max} Min+({OS.rand}mod(Max-Min+1)) end
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
                    % TODO You can add more elements if you need it
                )
            }
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
            startPosition:State.startPosition)
    end

    %%%% TODO Message functions

    fun {InitPosition State ?ID ?Position}
        ID = State.id
        Position = State.startPosition
        State
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
                        andthen {List.nth {List.nth Input.map X} Y} \= 3 then
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

    fun {SayMoved State ID Position}
        State
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
        ID = State.id
        Kind = null
        State
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

    fun {SayDeath State ID}
        if State.id == ID then {AdjoinList State [life#0]} else State end
    end

    fun {SayDamageTaken State ID Damage LifeLeft}
        if State.id == ID then {AdjoinList State [hp#LifeLeft]} else State end
    end

    fun {TakeFlag State ?ID ?Flag}
        ID = State.id
        Flag = null
        State
    end
            
    fun {DropFlag State ?ID ?Flag}
        ID = State.id
        Flag = null
        State
    end

    fun {SayFlagTaken State ID Flag}
        State
    end

    fun {SayFlagDropped State ID Flag}
        State
    end
end
