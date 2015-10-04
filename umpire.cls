 
/*------------------------------------------------------------------------
   File        : umpire
   Purpose     : To referee the game, enforce each player's turn and when the game starts and ends
   Syntax      : 
   Description : 
   Author(s)   : paul
   Created     : Sun Mar 29 16:45:48 CDT 2015
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.
using games.bsgit.*. 

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS games.bsgit.umpire: 
  def var oplayer1     as player.
  def var oplayer2     as player.
  def var oattackgrid1 as buttongrid.
  def var oattackgrid2 as buttongrid.
  
  def var umpwin       as widget-handle.
		
  def var p1ship       as int           extent 5 view-as slider size 24 by 1 min-value 0 max-value 5 tic-marks top frequency 1.
  def var p2ship       as int           extent 5 view-as slider size 24 by 1 min-value 0 max-value 5 tic-marks top frequency 1.
  
  define button bendsetup label "End      Setup".
  define button bendgame  label "End Game".
  define public event bedone signature void().
  define frame f2

    bendsetup bendgame skip(1)
    "Player 1" at 31        "Player 2" at 61 skip(1)
    "Aircraft Carrier" p1ship[1] at 30 space(6) 
    p2ship[1] skip(1)
    "Battleship" p1ship[2] view-as slider max-value 4 size 20 by 1 at 30 space(6) 
    p2ship[2] view-as slider max-value 4 size 20 by 1 at row-of p1ship[2] column-of p2ship[1] skip(1)
    "Submarine" p1ship[3] view-as slider max-value 3 size 16 by 1 at 30 space(6) 
                p2ship[3] view-as slider max-value 3 size 16 by 1 at row-of p1ship[3] column-of p2ship[2] skip(1)
    "Destroyer" p1ship[4] view-as slider max-value 3 size 16 by 1 at 30 space(6) 
                p2ship[4] view-as slider max-value 3 size 16 by 1 at row-of p1ship[4] column-of p2ship[3] skip(1)
    "Patrol Boat" p1ship[5] view-as slider max-value 2 size 12 by 1 at 30 space(6) 
                  p2ship[5] view-as slider max-value 2 size 12 by 1 at row-of p1ship[5] column-of p2ship[4] skip(1)
    with no-labels three-d width 90.
      
  on choose of bendsetup
    do:
      /* enable attackwin for player 1 */
      oattackgrid1:enablebuttons().
      bendsetup:sensitive = no.
      bendsetup:label = "Game Started".
      message "Let the game begin!" view-as alert-box information.
    end.
  on choose of bendgame
    do:
      delete object this-object.
    end.
  CONSTRUCTOR PUBLIC umpire ():

    def var playername1 as char format "x(20)" label "Player 1 Name" init "John".
    def var playername2 as char format "x(20)" label "Player 2 Name" init "Paul".
    
    form playername1 playername2 with frame f1 view-as dialog-box.
    
    assign
      default-window:width  = frame f1:width
      default-window:height = frame f1:height.

    update playername1 playername2 with frame f1.
    default-window:hidden = yes.

    oplayer1 = new player(input playername1, input 1, input this-object, output oattackgrid1).
    oplayer2 = new player(input playername2, input 2, input this-object, output oattackgrid2).

    assign
      oplayer1:theirshipgrid = oplayer2:myshipgrid
      oplayer2:theirshipgrid = oplayer1:myshipgrid.
		
    create window umpwin assign
      title = "Umpire Window" + " Lab 1"
      row = 3
      column = 180
      width = 90
      height = 15
      resize = no
      scroll-bars = no
      status-area = no
      message-area = no.

    current-window = umpwin.
    view frame f2.
    enable bendgame with frame f2.
  END CONSTRUCTOR.

  /* allow players to tell umpire that they are done setting up */
  METHOD PUBLIC VOID endsetup(  ):
		
    if oplayer1:boatslocked and oplayer2:boatslocked then
    do with frame f2:
      bendsetup:sensitive = yes.
    end.

  END METHOD.

	METHOD PUBLIC VOID gameover(ipplayer as player  ):
		
		message "Congratulations to " if ipplayer:playernumber = 1
		                              then oplayer2:playername
		                              else oplayer1:playername skip
		        "for sinking all of " if ipplayer:playernumber = 1
                                  then oplayer1:playername + "'s boats!"
                                  else oplayer2:playername + "'s boats!"
                                  view-as alert-box.
/*    this-object:destructor().*/

	END METHOD.

  /* enable attack grid on one player and disable on the other */
  METHOD PUBLIC VOID nextTurn(input ipplayer as player  ):
		
    if ipplayer:playernumber = 1 then 
    do:
      oattackgrid1:disablebuttons().
      oattackgrid2:enablebuttons().
    end.
    else 
    do:
      oattackgrid1:enablebuttons().
      oattackgrid2:disablebuttons().
    end.

  END METHOD.

  METHOD PUBLIC VOID updatehits(input ipship as ship, input ipplayer as player  ):
    def var shiplist as char init
      "Aircraft Carrier,Battleship,Submarine,Destroyer,Patrol Boat".
    do with frame f2:
      case ipplayer:playernumber:
        when 1 then 
          do:
            p1ship[lookup(ipship:shipname,shiplist)] = ipship:hits.
            case lookup(ipship:shipname,shiplist): 
              when 1 then p1ship[1]:bgcolor = if ipship:sunk then 12 else 13.
              when 2 then p1ship[2]:bgcolor = if ipship:sunk then 12 else 13. 
              when 3 then p1ship[3]:bgcolor = if ipship:sunk then 12 else 13. 
              when 4 then p1ship[4]:bgcolor = if ipship:sunk then 12 else 13. 
              when 5 then p1ship[5]:bgcolor = if ipship:sunk then 12 else 13. 
            end case.
            display p1ship. 
          end.
        when 2 then 
          do:
            p2ship[lookup(ipship:shipname,shiplist)] = ipship:hits.
            case lookup(ipship:shipname,shiplist): 
              when 1 then p2ship[1]:bgcolor = if ipship:sunk then 12 else 13. 
              when 2 then p2ship[2]:bgcolor = if ipship:sunk then 12 else 13. 
              when 3 then p2ship[3]:bgcolor = if ipship:sunk then 12 else 13. 
              when 4 then p2ship[4]:bgcolor = if ipship:sunk then 12 else 13. 
              when 5 then p2ship[5]:bgcolor = if ipship:sunk then 12 else 13. 
            end case.
            display p2ship.  
          end.
      end case.
    end.
  END METHOD.

  DESTRUCTOR PUBLIC umpire ( ):
    hide frame f2.
    bedone:Publish().
    delete object umpwin no-error.
    delete object oplayer1.
    delete object oplayer2.
    delete object this-object.
  END DESTRUCTOR.

END CLASS.
