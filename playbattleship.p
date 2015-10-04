
/*------------------------------------------------------------------------
    File        : playbattleship.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Sun Nov 16 20:39:29 CST 2014
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
using games.lab1.*.

def var oumpire as umpire.

oumpire = new umpire().

oumpire:bedone:Subscribe("done").

wait-for close of this-procedure.

procedure done:
/*  message "inside done" view-as alert-box.*/
  apply "close" to this-procedure.
end.

