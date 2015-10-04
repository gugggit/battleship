
/*------------------------------------------------------------------------
    File        : shipproc.p
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

define input parameter ibuttongrid as buttongrid.

/* **********************  Internal Procedures  *********************** */
define temp-table tbut no-undo
  field th    as handle
  field tname as char
  index tname is unique tname.

define temp-table tovl no-undo
  field th    as handle
  field tname as char
  field tmin  as dec
  field tmax  as dec
  index tname is unique tname.

/* populate temp-table with grid cells */
def var shipframe  as handle.
def var hchild     as handle.
def var hframe     as handle.
def var i          as int.
def var wrkname    as char.
def var rowlist    as char   init "F,G,H,I,J".
def var lenlist    as char   init "5,4,3,2,1".
def var collist    as char   init "6,7,8,9,10".
def var highletter as char.
def var highnumber as int.
def var startrow   as dec.
def var startcol   as dec.

shipframe = ibuttongrid:framehandle.

hframe = shipframe.
hchild = hframe:FIRST-CHILD.
hchild = hchild:first-child.

do while valid-handle(hchild):
  if length(hchild:name) >= 2
    and length(hchild:name) <= 3
    and hchild:name ne "10"
    then 
  do:
    /*  message hchild:name view-as alert-box.*/
    /*  i = i + 1.*/
    create tbut.
    assign 
      tbut.th    = hchild
      tbut.tname = hchild:name.
  end.
  hchild = hchild:next-sibling. 
end. /* valid-handle(hchild) */


PROCEDURE setship:
  define input parameter hship as handle.
  define input parameter oship as ship.
  
  /* check which cell is the closest fit, then check if it overlaps another ship */
  empty temp-table tovl.
  for each tbut:
    if hship:row + hship:height-chars > tbut.th:row
      and hship:row < tbut.th:row + tbut.th:height-chars 
      and hship:col + hship:width-chars > tbut.th:col
      and hship:col < tbut.th:col + tbut.th:width-chars 
      then 
    do:
      find tovl 
        where tovl.tname = tbut.tname 
        no-error.
      if not available tovl then 
      do:
        create tovl.
        assign 
          tovl.tname = tbut.tname.
      end.
      assign
        tovl.th   = tbut.th
        tovl.tmin = min((hship:row + hship:height-chars - tbut.th:row),
                     (tbut.th:row + tbut.th:height-chars - hship:row),
                    (hship:col + hship:width-chars - tbut.th:col),
                    (tbut.th:col + tbut.th:width-chars - hship:col)) 
        tovl.tmax = max((hship:row + hship:height-chars - tbut.th:row),
                     (tbut.th:row + tbut.th:height-chars - hship:row),
                    (hship:col + hship:width-chars - tbut.th:col),
                    (tbut.th:col + tbut.th:width-chars - hship:col)) .
    end.
  end. /* for each tbut */
  /*  message "b4 snap to grid" skip valid-object(ibuttongrid) view-as alert-box.*/
  /* snap to grid */
  if not can-find(first tovl) then ibuttongrid:recordShipPlace(oship:shipname, no).
  
  if oship:orientation = "horizontal"
    then 
  do:
    for each tovl break by tmin desc by tovl.tname:
      if first(tmin) then
        assign wrkname = tovl.tname.
      leave.
    /*      message tmin tovl.tname view-as alert-box.*/
    end. /* for each tovl */
    /*    message "wrkname:" wrkname view-as alert-box.*/
    find first tovl where tovl.tname begins substr(wrkname,1,1)
      and length(tovl.tname) = 2 /* B10 sorts higher than B6, want B6 */
      no-error.
    /*    message "substr(wrkname,1,1):" substr(wrkname,1,1) skip*/
    /*            "available tovl:" available tovl               */
    /*            view-as alert-box.*/
    if available tovl then 
    do:
      /*      message hship:name skip tovl.th:row tovl.th:col skip       */
      /*      ibuttongrid:checkshipoverlap(tovl.th:row,tovl.th:col,hship)*/
      /*      view-as alert-box.                                         */
      /* check if ship overlaps another ship, if not record that it is placed in grid */
      if not ibuttongrid:checkshipoverlap(tovl.th:row,tovl.th:col, hship:WIDTH-CHARS, hship:height-chars, hship:name) then
      do:
        assign hship:row = tovl.th:row
          hship:col = tovl.th:col.
          ibuttongrid:recordShipPlace(oship:shipname, yes).
/*          message "row:" hship:row skip "col:" hship:col skip tovl.th:name view-as alert-box.*/
      end.
      else
        /* return ship to original place */
        assign hship:row = startrow
          hship:col = startcol.
    end.
  end.
  else 
  do:
    for each tovl break by tmax by tovl.tname:
      if first(tmax) then
        assign wrkname = tovl.tname.
      leave.
          message tmin tovl.tname view-as alert-box.
    end. /* for each tovl */
    find first tovl where substr(tovl.tname,2,1) = substr(wrkname,2,1) no-error.
    if available tovl then 
    do:
      /* get lowest lettered starting point for ship */
      highletter = entry(lookup(string(oship:shiplength),lenlist),rowlist).
/*      message "inside setship vertical" skip "highletter:" highletter skip*/
/*      "tovl.tname:" tovl.tname skip*/
/*      view-as alert-box.*/
      if substr(tovl.tname,1,1) > highletter then 
      do:
          assign hship:row = startrow
            hship:col = startcol.
      end.
      else 
      do: 
        /* check if ship overlaps another ship, if not record that it is placed in grid */
        if not ibuttongrid:checkshipoverlap(tovl.th:row,tovl.th:col, hship:WIDTH-CHARS, hship:height-chars, hship:name) then
        do:
          assign 
            hship:row = tovl.th:row
            hship:col = tovl.th:col.
            ibuttongrid:recordShipPlace(oship:shipname, yes).
        end.
        else
          assign hship:row = startrow
            hship:col = startcol.
      end.
    end.
  end.
END PROCEDURE.

PROCEDURE startship:
  /* record starting position of ship in case you have to return ship to starting place */
  define input parameter hship as handle.
  assign 
    startrow = hship:ROW
    startcol = hship:col.

END PROCEDURE.

PROCEDURE validateorientation:
  define input parameter ipshipname as char.
  define input parameter ipshiplength as int.
  define input parameter iporientation as char.
  define output parameter result as log.
  
  if available tovl then 
  do:
    if iporientation = "horizontal" then 
    do:
      /* get lowest numbered starting point for ship */
      highnumber = int(entry(lookup(string(ipshiplength),lenlist),collist)).
      find tbut where tbut.tname = ipshipname no-error.
      result = (int(substr(tovl.tname,2)) <= highnumber).    
    end.
    else 
    do:
      /* get lowest lettered starting point for ship */
      highletter = entry(lookup(string(ipshiplength),lenlist),rowlist).
      find tbut where tbut.tname = ipshipname no-error.
/*      message "inside validate orientation" skip*/
/*      "highletter:" highletter skip             */
/*      "tovl.tname:" tovl.tname skip             */
/*      view-as alert-box.                        */
      result = (substr(tovl.tname,1,1) <= highletter).    
    end.
  end. /* available tovl */
  else result = yes.
  
END PROCEDURE.
