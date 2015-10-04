 
/*------------------------------------------------------------------------
   File        : buttongrid
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : paul
   Created     : Sun Nov 23 20:52:30 CST 2014
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.
using games.bsgit.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS games.bsgit.buttongrid:
  
  def    var      hbut      as widget-handle.
  def    var      hrec      as widget-handle.
  DEFINE VARIABLE hproc     AS HANDLE        NO-UNDO.
  
  DEFINE VARIABLE i         AS INTEGER       NO-UNDO.
  DEFINE VARIABLE j         AS INTEGER       NO-UNDO.
  DEFINE VARIABLE k         AS INTEGER       NO-UNDO.
  DEFINE VARIABLE X         AS INTEGER       NO-UNDO.
  DEFINE VARIABLE shipcount AS INTEGER       NO-UNDO.
  DEFINE VARIABLE cells2side AS INTEGER       NO-UNDO init 10.
  
  define var      hendsetup as widget-handle no-undo.

  define temp-table tship no-undo
    field tshipname   as char                 format "x(20)" label "Ship Name"
    field tshiplength as int
    field tplaced     as log /* if ship is placed on grid */
    field tsunk       as log /* if all ship's cells have been hit */
    field tshipobject as progress.lang.object
    index tshipname is unique tshipname. /* only one instance of a particular ship may be in a grid */
    
  define temp-table tcell no-undo
    field wh as widget-handle
    field cellname as char
    field tshipname as char. /* tells you which ship is occupying cell, can be blank */
  
  define frame f1 skip(21)
    with no-labels width 85 three-d.
		
  def    public property      oplayer            as player
     get.
     private set.
  
  DEFINE PUBLIC PROPERTY frameheight AS DECIMAL NO-UNDO 
    GET.
    PRIVATE SET. 

  DEFINE PUBLIC PROPERTY framewidth AS DECIMAL NO-UNDO 
    GET.
    PRIVATE SET. 

  DEFINE PUBLIC PROPERTY framehandle AS widget-handle NO-UNDO 
    GET.
    PRIVATE SET. 

  CONSTRUCTOR PUBLIC buttongrid ( input iptitle as char):
    this-object:buildgrid(input iptitle).
  END CONSTRUCTOR.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
		
	CONSTRUCTOR PUBLIC buttongrid (  input iptitle as char, ipplayer as player ):
    assign oplayer = ipplayer.
		this-object:buildgrid(input iptitle).
	END CONSTRUCTOR.

  METHOD PUBLIC VOID addship(ipshipname as char, ipshiplength as int, ipcolor as int ):
		
    def    var      wrkship    as ship.
    DEFINE VARIABLE shiphandle AS WIDGET-HANDLE NO-UNDO.
    create tship.
    assign 
      shipcount            = shipcount + 1
      tship.tshipname      = ipshipname
      tship.tshiplength    = ipshiplength
      wrkship              = new ship(tshiplength,tship.tshipname,this-object,ipcolor)
      tship.tshipobject    = wrkship
      shiphandle           = wrkship:whship
      shiphandle:frame     = framehandle
      shiphandle:row       = (cells2side * 2) + (shipcount * 2) /* initially place ship below grid in frame */
      shiphandle:col       = 1
      shiphandle:sensitive = yes
      shiphandle:movable   = yes.
      

  END METHOD.

	METHOD PUBLIC LOGICAL checkoverlap(input ipwh1 as widget-handle, input ipwh2 as widget-handle  ):
		
		/* checks to see if a ship occupies a cell */
		DEFINE VARIABLE result AS LOGICAL NO-UNDO.
    result =     ipwh1:row + ipwh1:height-chars > ipwh2:row
        and ipwh1:row < ipwh2:row + ipwh2:height-chars
        and ipwh1:col + ipwh1:width-chars > ipwh2:col
        and ipwh1:col < ipwh2:col + ipwh2:width-chars .
		RETURN result.

	END METHOD.

  METHOD PUBLIC LOGICAL checkshipoverlap
    ( input iprow as dec, input ipcol as dec, input ipwidth as dec, input ipheight as dec, input ipname as char ):
		
    DEFINE VARIABLE result AS LOGICAL       NO-UNDO.
    DEFINE VARIABLE oship  AS ship          NO-UNDO.
    DEFINE VARIABLE hship  AS WIDGET-HANDLE NO-UNDO.
    for each tship where tship.tshipname ne ipname:
      assign
        oship = cast(tship.tshipobject,"ship")
        hship = oship:whship.
      /*      message valid-object(oship) skip valid-handle(hship) skip*/
      /*      hship:name skip                                          */
      /*      ipsh:name skip                                           */
      /*      view-as alert-box.                                       */
      result =     hship:row + hship:height-chars > iprow
        and hship:row < iprow + ipheight
        and hship:col + hship:width-chars > ipcol
        and hship:col < ipcol + ipwidth .
      if result then leave.
    end.
    RETURN result.

  END METHOD.

  /* enable buttons on attack grid when it is that player's turn */
	METHOD PUBLIC VOID enablebuttons(  ):
		
		for each tcell:
		  wh:sensitive = yes.
		end.

	END METHOD.

  /* disable buttons on attack grid when it is not that player's turn */
  METHOD PUBLIC VOID disablebuttons(  ):
    def var colorsave as int.
    for each tcell:
      assign wh:sensitive = no.
    end.

  END METHOD.

	METHOD PUBLIC ship IsaHit(input ipcellname as char ):
		
		DEFINE VARIABLE result AS ship NO-UNDO.
		def var ok as log.
		
		find tcell where cellname = ipcellname no-error.
		if available tcell then do:
		  find tship of tcell no-error. /* common field is tshipname */
		  /* if found then ship is hit */
		  if available tship then do:
		    assign
		    tcell.wh:fgcolor = 15 /* color white foreground if hit */
        tcell.wh:bgcolor = 12 /* color red if hit */
        ok = tcell.wh:move-to-top() /* move cell in front of ship to show blue color */
		    result = cast(tshipobject,"ship")
		    result:hits = result:hits + 1.
		    if result:hits = result:shiplength
		    then assign result:sunk = yes
		                tship.tsunk = yes.
        oplayer:updatehits(input result).
		    if not can-find(first tship where tsunk = no)
		    then oplayer:gameover().
		  end.
		  else        tcell.wh:BGCOLOR = 15. /* color white if a miss */
    end. 
		RETURN result.

	END METHOD.

	METHOD PUBLIC VOID lockboats(  ):
		
    DEFINE VARIABLE oship  AS ship          NO-UNDO.
    DEFINE VARIABLE hship  AS WIDGET-HANDLE NO-UNDO.
    for each tship:
      assign
        oship = cast(tship.tshipobject,"ship")
        hship = oship:whship
        /* don't allow them to be moved or changed */
        hship:movable = no
        hship:read-only = yes.
        /* assign ships to cells using checkoverlap method */
        for each tcell:
          if this-object:checkoverlap(hship, tcell.wh)
          then assign tcell.tshipname = tship.tshipname.
        end.
    end.
    oplayer:boatslocked = yes.
    oplayer:endsetup().
/*    for each tcell where tcell.tshipname > ""  */
/*      by tcell.tshipname by cellname:          */
/*        display tcell.tshipname tcell.cellname.*/
/*    end.                                       */

	END METHOD.

	METHOD PUBLIC VOID recordShipPlace( input ipshipname as char, input ipplace as log ):
		
		find tship where tship.tshipname = ipshipname.
		assign tplaced = ipplace.
		
		/* don't enable end setup button until all ships are placed on the grid */
		hendsetup:sensitive = not can-find(first tship where tplaced = no).

	END METHOD.

  METHOD PUBLIC VOID viewgrid(  ):
		
    frame f1:visible = yes.

  END METHOD.


	METHOD PUBLIC VOID buildgrid(input iptitle as char  ):
		
    create widget-pool "buttons" persistent no-error.
    run games/bsgit/gridproc.p persistent set hproc (input frame f1:handle).

    frame f1:movable = no. /* don't need movable */
    frame f1:TITLE   = iptitle.
    /*          message "b4 gridproc in buttongrid.cls" view-as alert-box.*/
    
    do i = 1 to cells2side:
      do j = 1 to cells2side:
        k = k + 1. /* goes up to 100 */
        /* create stationary buttons going across */
        if i = 1 then
        do x = 1 to cells2side:
          create button hrec in widget-pool "buttons"
            assign
            name = string(x)
            label = string(x)
            frame      = frame f1:handle
            row       = 1
            column    = ((x - 1) * 8) + 5
            width     = 8
            height    = 1
            visible   = no
            hidden    = no
            sensitive = no.
        end.
        /* create stationary letters on left column */
        if j = 1 then
          create button hrec in widget-pool "buttons"
            assign name = chr(64 + i)
            label = chr(64 + i)
            frame      = frame f1:handle
            row       = (2 * integer(truncate((k - 1) / cells2side,0))) + 2
            column    = 1
            width     = 4
            height    = 2
            visible   = no
            hidden    = no
            sensitive = no.
        /* create grid cells using editor widget so that colors may be used for background */
        create editor hbut in widget-pool "buttons"
          assign 
          screen-value      = "~r  " + chr(64 + i) + string(j)  /* e.g. chr(64 + 2) + 3 = B3 */
          name       = chr(64 + i) + string(j)
          frame      = frame f1:handle
          row       = (2 * integer(truncate((k - 1) / cells2side,0))) + 2 
          column    = ((j - 1) * 8) + 5       
          width     = 8  /* each button is 8 char across */
          bgcolor   = 11
          height    = 2  /* each button is 2 rows down */
          visible   = no
          hidden    = no
          sensitive = /* (iptitle matches "*attack*") */ no
          private-data   = chr(64 + i) + string(j)
          tooltip   = chr(64 + i) + string(j)
          triggers:
            on mouse-select-click
              persistent run choosebut in hproc (input hbut, input oplayer).
          end triggers:
        /* create a tcell temp-table record for each cell */
        create tcell.
        assign 
          tcell.wh = hbut
          tcell.cellname = hbut:NAME.
      end. /* do j = */
    end. /* do i - */
   
   assign
   frame f1:width-chars = tcell.wh:COLUMN + tcell.wh:width
   frame f1:height-chars = tcell.wh:row + tcell.wh:height.
   
    if iptitle matches "*ship*" then 
    do:
      frame f1:HEIGHT-CHARS = frame f1:height-chars + 10.
      create button hendsetup in widget-pool "buttons"
        assign
        label      = "End Setup"
        name       = "bendsetup"
        frame      = frame f1:handle
        width     = 16
        height    = 2
        row       = frame f1:row + frame f1:height - 3
        column    = frame f1:col + frame f1:width - 17
        visible   = no
        hidden    = no
        sensitive = no
        tooltip   = "Select when finished place boats in grid"
        triggers:
          on choose
            persistent run lockboats in hproc (input hendsetup, input this-object).
        end triggers:
      
    end.
    assign
      frameheight = frame f1:HEIGHT-CHARS
      framewidth  = frame f1:width-CHARS
      framehandle = frame f1:handle.
    
  /*    message "frameheight:" frameheight skip*/
  /*            "framewidth:" framewidth skip  */
  /*            view-as alert-box.             */


	END METHOD.

  DESTRUCTOR PUBLIC buttongrid ( ):
    delete widget-pool "buttons" no-error.
    if valid-handle(hproc) then
    delete procedure hproc.
    delete object this-object.
  END DESTRUCTOR.

   

END CLASS.
