functor
import 
    Input
    OS
    System
export
    portPlayer:StartPlayer
define
    % Vars
    Weapons = [gun mine]
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

    %Other Functions
    RandomInRange = fun {$ Min Max} Min+({OS.rand}mod(Max-Min+1)) end 


    fun {Abs X}
        if X < 0 then ~X else X end
    end

    fun {ManathanDistance Pos1 Pos2}
        {Abs Pos2.x - Pos1.x} + {Abs Pos2.y - Pos1.y}
    end

    fun {PosToIndex P}
        (P.x - 1) * MapWidth + P.y
    end

    fun {IndexToPos Index}
        local X Y in 
            X = (Index div MapWidth) + 1
            Y = (Index-(X-1)*MapWidth)
            pt(x:X y:Y)
        end
    end

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
                    id:id(id:ID color:Color name:player001random) 
                    position:{List.nth Input.spawnPoints ID}
                    map:Input.map
                    hp:Input.startHealth
                    flag:null
                    mineReloads:0
                    gunReloads:0
                    startPosition:{List.nth Input.spawnPoints ID}
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

    fun{MatchHead Head State}
        case Head 
            of initPosition(?ID ?Position) then {InitPosition State ID Position}
            [] move(?ID ?Position ?Direction) then {Move State ID Position Direction}
            [] sayMoved(ID Position Direction) then {SayMoved State ID Position Direction}
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


    fun {InitPosition State ?ID ?Position}
        ID = State.id
        Position = State.startPosition
        State
    end

    fun {Move State ?ID ?Position ?Direction}
        local Temp TempMove in
            fun {TempMove Direction}
                local Point in
                    case Direction
                        of south then 
                            if State.position.x == Input.nColumn then {TempMove west}
                            else 
                                Point = pt(x:State.position.x+1 y:State.position.y)
                                if {List.nth State.map {PosToIndex Point}} == 0 then
                                    {SetPosition State Point}
                                else {TempMove west}
                                end
                            end
                        [] west then
                            if State.position.y == 1 then {TempMove north}
                            else 
                                Point = pt(x:State.position.x y:State.position.y-1)
                                if {List.nth State.map {PosToIndex Point}} == 0 then
                                    {SetPosition State Point}
                                else {TempMove north}
                                end
                            end
                        [] north then
                            if State.position.x == 1 then {TempMove east}
                            else 
                                Point = pt(x:State.position.x-1 y:State.position.y)
                                if {List.nth State.map {PosToIndex Point}} == 0 then
                                    {SetPosition State Point}
                                else {TempMove east}
                                end
                            end
                        [] east then
                            if State.position.y == Input.nRow then {SetPosition State Point}
                            else
                                Point = pt(x:State.position.x y:State.position.y+1)
                                if {List.nth State.map {PosToIndex Point}} == 0 then
                                    {SetPosition State Point}
                                else
                                    {SetPosition State Point}
                                end
                            end
                    
                    end
                end
            end


            ID = State.id
            Temp = {TempMove south}
            Position = Temp.pos
            Direction = Temp.dir
        end
    end

    fun {SayMoved State ID Position Direction}
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
        State
    end

    fun {SayDamageTaken State ID Damage LifeLeft}
        State
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
