
/*------------------------------------------------------------------------
    File        : gridproc.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Sun Nov 23 21:24:20 CST 2014
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.

using games.lab1.*.

define input parameter shipframe as handle.

/* **********************  Internal Procedures  *********************** */
PROCEDURE choosebut:
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  define input parameter hbut as handle.
  define input parameter oplayer as player.

  define var otheirshipgrid as buttongrid.
  define var oship          as ship.
  define var oumpire        as umpire.
  
  assign 
    otheirshipgrid = oplayer:theirshipgrid
    oumpire        = oplayer:theumpire.
  
  oship = otheirshipgrid:IsaHit(input hbut:name).
  if valid-object(oship) then 
  do:
    assign hbut:bgcolor = oship:shipcolor
           hbut:fgcolor = if oship:shipcolor = 14
                          then 0
                          else 15.
    message "The ship" oship:shipname "has just been hit." view-as alert-box. 
  end.
  else assign hbut:bgcolor = 15 hbut:fgcolor = 0.
  hbut:move-to-top().
  oumpire:nextTurn(input oplayer).
END PROCEDURE.

PROCEDURE lockboats:
  define input parameter hendsetup as widget-handle.
  define input parameter obuttongrid as buttongrid.
  def var choice as log.
  message "Are you sure you are finished placing the boats on the grid the way you want?"
    view-as alert-box question buttons yes-no update choice.
  if choice then 
  do:
    obuttongrid:lockboats().
    hendsetup:hidden = yes.
  end.
END PROCEDURE.

