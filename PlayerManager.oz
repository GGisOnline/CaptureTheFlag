functor
import
	Player1
	Player2
	Player001Random
export
	playerGenerator:PlayerGenerator
define
	PlayerGenerator
in
	fun{PlayerGenerator Kind Color ID}
		case Kind
		of player2 then {Player2.portPlayer Color ID}
		[] player1 then {Player1.portPlayer Color ID}
		[] player001random then {Player001Random.portPlayer Color ID}
		end
	end
end
