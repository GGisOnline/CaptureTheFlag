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
    Abs 
    ManathanDistance
    RandomInRange = fun {$ Min Max} Min+({OS.rand}mod(Max-Min+1)) end


    fun{StartPlayer Color ID}
        Stream
        Port
    in
        {NewPort Stream Port}
        thread
            {TreatStream Stream state(
                                    id:id(id:ID color:Color name:player001random) 
                                    position:{List.nth Input.spawnPoints ID})}
                                    map:Input.map
                                    hp:Input.startHealth
                                    flag:null
                                    mineReloads:0
                                    gunReloads:0
                                    startPosition:{List.nth Input.spawnPoints ID}
        end
        Port
    end


    proc{TreatStream Strream State}
        case Stream
            of H|T then {TreatStream T {MatchHead H State}}
        end
    end

    fun{MatchHead Head State}
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

    fun {ModifyMap Map Position Value}
        local MapIndex in 
            MapIndex={PosToIndex Position}
            {List.mapInd Map fun {$ I A} if I == MapIndex then value else A end end}
        end
    end

    fun {Filter L Fun}
        fun {Inner L Fun Acc}
            case L
                of nil then if Acc == nil then nil else {List.reverse Acc} end
                [] H|T then if {Fun H} then {Inner T Fun H|Acc} else {Inner T Fun Acc} end
            end
        end
    in
        {Inner L Fun nil}
    end

in

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
                            if State.position.xx == Input.nColumn then {TempMove west}
                            else 
                                Point = pt(x:State.position.x+1 y:State.position.y)
                                if {List.nth State.map {PosToIndex Point}} == 0 then
                                    r(pos:Point dir:south)
                                else {TempMove west}
                                end
                            end
                        [] west then
                            if State.position.y == 1 then {TempMove north}
                            else 
                                Point = pt(x:State.position.x y:State.position.y-1)
                                if {List.nth State.map {PosToIndex Point}} == 0 then
                                    r(pos:Point dir:west)
                                else {TempMove north}
                                end
                            end
                        [] north then
                            if State.position.x == 1 then {TempMove east}
                            else 
                                Point = pt(x:State.position.x-1 y:State.position.y)
                                if {List.nth State.map {PosToIndex Point}} == 0 then
                                    r(pos:Point dir:north)
                                else {TempMove east}
                                end
                            end
                        [] east then
                            if State.position.y == Input.nRow then r(pos:State.position dir:surface)
                            else
                                Point = pt(x:State.position.x y:State.position.y+1)
                                if {List.nth State.map {PosToIndex Point}} == 0 then
                                    r(pos:Point dir:east)
                                else
                                    r(pos:State.position dir:surface)
                                end
                            end
                    
                    end
                end
            end


            ID = State.id
            Temp = {TempMove south}
            Position = Temp.pos
            Direction = Temp.dir
            {AdjoinList State [position#Temp.pos direction#Temp.dir map#{ModifyMap State.map Temp.pos x}]}
        end
    end
end
