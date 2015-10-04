 
/*------------------------------------------------------------------------
   File        : ship 
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : paul
   Created     : Tue Nov 25 21:46:20 CST 2014
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.
using games.lab1.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS games.lab1.ship: 

	DEFINE PUBLIC PROPERTY orientation AS CHARACTER NO-UNDO 
	GET.
	protected SET. 

  DEFINE PUBLIC PROPERTY shiplength AS INTEGER NO-UNDO 
    GET.
    PROTECTED SET. 

  DEFINE PUBLIC PROPERTY shipname AS CHARACTER NO-UNDO 
    GET.
    SET. 

  DEFINE PUBLIC PROPERTY shipcolor AS integer NO-UNDO 
    GET.
    SET. 

  DEFINE PUBLIC PROPERTY whship AS WIDGET-HANDLE NO-UNDO 
    GET.
    private set.

  DEFINE PUBLIC PROPERTY hits AS integer NO-UNDO 
    GET.
    SET. 

  DEFINE PUBLIC PROPERTY sunk AS logical NO-UNDO 
    GET.
    SET. 

  def var vertshipname as char no-undo.
  def var htxt as widget-handle.
  def var hproc as handle.
  def var obuttongrid as buttongrid.
	def menu shipmenu
	  menu-item misetorient label "Change Orientation". 

on choose of menu-item misetorient
do:
/*  message "inside misetorient" view-as alert-box.*/
  this-object:changeOrientation().
end.

  CONSTRUCTOR PUBLIC ship (input iplength as int, input ipname as char, input ibuttongrid as buttongrid, input ipbgcolor as int):
    def var i as int.
    def var j as int.
    def var namelength as int.
    def var crlf as char init "\013\010".
    assign 
      obuttongrid = ibuttongrid
      shiplength = iplength
      shipname   = ipname
      shipcolor  = ipbgcolor
      namelength = length(shipname)
      i          = 1.
    /* make vertical ship name */
    do i = 1 to namelength by 6:
      vertshipname = vertshipname 
                   + (if i = 1 
                     then "~r"
                     else "~r~r") 
                   + substr(shipname,i,6).
    end. 
/*    message vertshipname view-as alert-box.*/
/*      message "b4 shipproc in ship.cls" view-as alert-box.*/
    run games/lab1/shipproc.p  persistent set hproc (input ibuttongrid).
    create widget-pool "ships" persistent no-error.
    create editor htxt in widget-pool "ships"
      assign 
      name = shipname
      tooltip = shipname
      width     = shiplength * 8
      height    = 2
      bgcolor   = ipbgcolor
      read-only = yes
      popup-menu = menu shipmenu:handle
      menu-key = "F5"
      triggers:
        on end-move persistent run setship in hproc (input htxt, input this-object).
        on start-move persistent run startship in hproc (input htxt).
      end triggers:
      
      assign whship = htxt
             whship:SCREEN-VALUE = whship:NAME
             orientation = "horizontal".	  
		
  END CONSTRUCTOR.


	METHOD PUBLIC VOID changeOrientation(  ):
	  def var toorientation as char.
	  def var result as log.
	  def var newheight as dec.
	  def var newwidth as dec.
	  
	  /* check if changing orientation causes ship to go off grid */
	  toorientation = if orientation = "horizontal"
	                  then "vertical"
	                  else "horizontal".
		run validateorientation in hproc
		  (input shipname, input shiplength, input toorientation, output result).
		if not result then do:
		  message "Orientation cannot be changed" skip "because a portion of ship" skip "will be off the grid."
		  view-as alert-box.
		  return.
		end.
		
		/* check if changing orientation causes ship to overlap another ship */
		if toorientation = "horizontal"
		then assign newheight = 2
		            newwidth = shiplength * 8.
		       
    else assign newheight = shiplength * 2
                newwidth = 8.
           
		if obuttongrid:checkshipoverlap(htxt:row, htxt:col, newwidth, newheight, htxt:NAME) then do:
      message "Orientation cannot be changed" skip "because a portion of ship" skip "will overlap another ship."
      view-as alert-box.
      return.
		end.
		
		if orientation = "horizontal" then do:
		  assign 
		  orientation = "vertical"
		  htxt:width = 8
		  htxt:height = shiplength * 2
		  htxt:screen-value = vertshipname.
		end. /* horizontal */
		else do:
		  assign
		  orientation = "horizontal"
      htxt:width = shiplength * 8
      htxt:height = 2
      htxt:screen-value = htxt:name.
		end. /* vertical */

	END METHOD.

	DESTRUCTOR PUBLIC ship ( ):
	  delete widget-pool "ships" no-error.
	  if valid-handle(hproc) then
	  delete procedure hproc.
    delete object this-object.
	END DESTRUCTOR.

END CLASS.