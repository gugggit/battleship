 
/*------------------------------------------------------------------------
   File        : player
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : paul
   Created     : Sun Dec 07 21:44:00 CST 2014
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.
using games.lab1.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS games.lab1.player: 

  def    public property      theumpire      as umpire
    get.
    private set.
  def    public property      myshipgrid      as buttongrid
    get.
    private set.
  def    public property      theirshipgrid      as buttongrid
    get.
    set.
  def    public property      playername      as character
    get.
    private set.
  def    public property      playernumber      as integer
    get.
    private set.
  def    public property      boatslocked      as logical
    get.
    set.
  def    var      oattackgrid2    as buttongrid.
  def    var      spacer         as int           init 45.
  DEFINE VARIABLE shipwin        AS WIDGET-HANDLE NO-UNDO.
  DEFINE VARIABLE attackwin      AS WIDGET-HANDLE NO-UNDO.
  DEFINE VARIABLE setupwin       AS WIDGET-HANDLE NO-UNDO.

  DEFINE VARIABLE shipnamelist   AS CHARACTER     NO-UNDO init 
    "Aircraft Carrier,Battleship,Destroyer,Submarine,Patrol Boat".
/*    "Aircraft Carrier,Battleship".*/
  DEFINE VARIABLE shiplengthlist AS CHARACTER     NO-UNDO init 
    "5,4,3,3,2".
/*    "3,2".*/
  define variable shipcolorlist as character      no-undo init
  "8,10,6,14,13".
  DEFINE VARIABLE i              AS INTEGER       NO-UNDO.
  
  CONSTRUCTOR PUBLIC player ( input ipplayername as char, input ipplayernumber as int, ipumpire as umpire,
                              output oattackgrid as buttongrid ):
    assign 
      playername   = ipplayername
      playernumber = ipplayernumber
      theumpire    = ipumpire.

    create window shipwin assign
      title = playername + " Ship Window - Player " + string(playernumber) + " Lab1"
      row = 3
      column = 1 + (playernumber - 1) * spacer * 2
      width = 200
      height = 60
      resize = yes
      scroll-bars = no
      status-area = no
      message-area = no.

    current-window = shipwin.
    
    myshipgrid = new buttongrid("Ship Grid", this-object).

    do i = 1 to num-entries(shipnamelist):
      this-object:makeship().
    end. /* i = 1 to num-entries */

    assign
      shipwin:width  = myshipgrid:framewidth
      shipwin:height = myshipgrid:frameheight.
    
    myshipgrid:viewgrid().

    oattackgrid = new buttongrid("Attack Grid", this-object).
    oattackgrid2 = oattackgrid.

    create window attackwin assign
      title = playername + " Attack Window" + " Lab 1"
      row = 3
      column = /* spacer + (playernumber - 1) * spacer * 2 */  1 + (playernumber - 1) * spacer * 2
      width = oattackgrid:framewidth
      height = oattackgrid:frameheight
      resize = no
      scroll-bars = no
      status-area = no
      message-area = no.

    current-window = attackwin.

    oattackgrid:viewgrid().
    
    shipwin:move-to-top().
    current-window = shipwin.
  END CONSTRUCTOR.


  /* enable attack grid buttons */
	METHOD PUBLIC VOID endsetup(  ):
		shipwin:window-state = 2.
		theumpire:endsetup().
		/* attackgrid and shipgrid are same height, get rid of space for ships */
		shipwin:HEIGHT = oattackgrid2:frameheight.

	END METHOD.

	METHOD PUBLIC VOID gameover(  ):
		
		theumpire:gameover(input this-object).

	END METHOD.

  METHOD PUBLIC VOID makeship(  ):
    def var j as int.
    if i <= 1 then j = i.
    else if i = 2 then j = i + 1.
      else j = i + 2.
    myshipgrid:addship(entry(i,shipnamelist), int(entry(i,shiplengthlist)), int(entry(i,shipcolorlist))).
  END METHOD.

  /* update hits on umpire */
	METHOD PUBLIC VOID updatehits(input ipship as ship  ):
		
		theumpire:updatehits(input ipship, input this-object).

	END METHOD.

	DESTRUCTOR PUBLIC player ( ):
	  delete object attackwin.
	  delete object shipwin.
	  delete object oattackgrid2.
	  delete object myshipgrid.
    delete object this-object.
	END DESTRUCTOR.

END CLASS.