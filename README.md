# LINFO1131
Project for LINFO1131 : Paradigmes de programmation concurrente course made by LECHAT Jérôme (50351800) and NESTEROV Andrei (41660200).


## Introduction
For this project, we were asked to make a customized version of a popular game called Capture The Flag (or CTF). The implementation must be made to be played simultaneously (not turn by turn).


## Rules
    • Players start with 2 lives. Each team is composed of 3 players.

    • Players can move by one tile vertically or horizontally. Walls and the enemy base are impenetrable : players can’t move there. If two players want to move to a tile at the same time, the first one to ask gets to move there and the other one cannot move this turn.
    
    • If a player is dead, it has to wait RespawnDelay before it can respawn. It then respawns with startHp.

    • Players have two weapons they can use : a gun and a mine. Each item must be charged before it is used : charging the gun requires 1 action, charging the mine requires 5.

    • Mines are placed under the player that is placing it, and stepping on a mine will set it off, giving 2 damage to the player on that tile and 1 damage to the players that are 1 tile away (following Manhattan distance).

    • The gun has a range of two (Manhattan distance), and targets include players as well as mines. Shooting a player will cause 1 damage, and shooting a mine will make it explode.
    
    • In order to win the game, one of the players has to pick-up the enemy flag (the player has to be standing on the flag to grab it), bring it back to its base and drop it there. If a player dies carrying the flag, it is dropped at the player’s position. Players can’t pick-up their own flag.

    • Food will appear randomly on the map. A player can consume it by standing on it, and that will add 1 to their life.


## In this Project
This project contains :

    • GUI.oz : The graphical interface of the game

    • Input.oz : File containing all the parameters of the game

    • Main.oz : The game controller

    • Makefile 

    • PlayerBasic.oz : Model of player we have to be based of

    • PlayerManager.oz : File to make the selection of player easier

    • Players : - Player017Random.oz : Player with a random behaviour
                - Player017Smarter.oz : Player with a smart behaviour
    
    • Papers : - CaptureTheFlag.pdf : Instruction for the project
               - RapportCTF.pdf : Final rapport of the project
 


