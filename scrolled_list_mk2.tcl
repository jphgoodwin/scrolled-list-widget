namespace eval ::scrolledList_mk2 {
   namespace ensemble create
   namespace export *

   variable count 0
   variable flists

   # Creates a new scrolledList which it stores a reference to in the flists dictionary.
   # The args provided are applied to the canvas containing the scrolledList.
   # A unique id for the scrolledList is returned, which can be used to access the
   # scrolledList in future.
   proc new {path args} {
      variable flists
      variable count
      
      eval {scrolledFrame new $path} $args
      set lframe [scrolledFrame content $path]
      
      # if {[dict exists $flists]} {
      #    set size [dict size $flists]
      # } else {
      #    set size 0
      #}
      set id fl$count
      incr count

      dict set flists $id path $path
      return $id
   }

   # Adds an element with the specified elid to the list given by listid.
   # The script argument is the name of a procedure to call to handle the layout
   # of the element frame. The procedure must accept the element frames path as the
   # last argument.
   #
   #### Example ####
   # proc handleLayout {heading subheading cmd path} {
   #    ttk::label $path.headingl -text $heading -background white -font defaultRoman_10
   #    ttk::label $path.subheadingl -text $subheading -background white -font defaultRoman_8
   #    ttk::button $path.butn -text ">" -width 5 -command $cmd

   #    grid $path.headingl -row 0 -column 0 -sticky nw
   #    grid $path.subheadingl -row 1 -column 0 -sticky nw
   #    grid $path.butn -row 0 -column 1 -rowspan 2 -sticky nse -pady 3
   #    grid columnconfigure $path 1 -weight 1
   #    return
   # }
   #################
   proc add {listid elid script} {
      global defaultRoman_10
      global defaultRoman_8
      variable flists
      
      if {[dict exists $flists $listid path]} {
         set lframe [scrolledFrame content [dict get $flists $listid path]]
      } else {
         puts stdout "Invalid listid: $listid"
         return
      }
      if {[dict exists $flists $listid flist]} {
         set size [dict size [dict get $flists $listid flist]]
      } else {
         set size 0
      }
      set f [frame $lframe.f$size -width 20 -height 30 -background white]
      dict set flists $listid flist $elid $f
      eval $script $f
      grid $f -row $size -column 0 -sticky nwe -pady 5
      grid columnconfigure $lframe 0 -weight 1
      return
   }

   # Removes the specified element from the given frame list.
   proc remove {listid elid} {
      variable flists

      if {[dict exists $flists $listid flist $elid]} {
         destroy [dict get $flists $listid flist $elid]
         dict unset flists $listid flist $elid
      }
      return
   }

   # Removes all elements from the frame list.
   proc removeAll {listid} {
      variable flists
      
      if {[dict exists $flists $listid flist]} {
         dict for {elid val} [dict get $flists $listid flist] {
            destroy $val
            dict unset flists $listid flist $elid
         }
      }
      return
   }

   # Removes the specified list from the flists dictionary.
   proc delete {listid} {
      variable flists
      variable count

      if {[dict exists $flists $listid]} {
         dict unset flists $listid
         incr count -1
      }
      return
   }

   # Returns the path of the content frame containing the list elements.
   proc getList {listid} {
      variable flists

      if {[dict exists $flists $listid path]} {
         return [dict get $flists $listid path]
      }
   }

   # Returns the path of the specified element frame.
   proc getElement {listid elid} {
      variable flists

      if {[dict exists $flists $listid flist $elid]} {
         return [dict get $flists $listid flist $elid]
      }
   }

   # Returns a list of the element ids.
   proc getElementIdList {listid} {
      variable flists

      if {[dict exists $flists $listid flist]} {
         set templist ""
         set count 1
         foreach val [dict get $flists $listid flist] {
            if {$count%2 != 0} {
               set templist [concat $templist [list $val]]
            }
            incr count
         }
         return $templist
      }
   }

   # Returns 1 if element exists, and 0 if it doesn't.
   proc elementExists {listid elid} {
       variable flists

       if {[dict exists $flists $listid flist $elid]} {
           return 1
       } else {
           return 0
       }
   }

   # Updates and resizes the scrolledList with the specified listid.
   proc updateView {listid} {
      variable flists

      if {[dict exists $flists $listid path]} {
         update
         scrolledFrame resize [dict get $flists $listid path]
         # In some circumstances a second update and resize is required
         # to get the scrollbar to display correctly.
         update
         scrolledFrame resize [dict get $flists $listid path]
      }
   }

}

