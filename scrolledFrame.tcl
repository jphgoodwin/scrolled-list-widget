


namespace eval ::scrolledFrame {
   namespace ensemble create
   namespace export *

   # Create a scrollable frame.
   proc new {path args} {
      # Create a main frame.
      frame $path -bg pink
      
      # Create a scrollable canvas with scrollbars.
      eval {canvas $path.c -bg white -bd 0 -highlightthickness 0\
               -yscrollcommand [list $path.scrolly set]\
               -xscrollcommand [list $path.scrollx set]} $args
      set c $path.c
      ttk::scrollbar $path.scrolly -orient vertical -command [list $c yview]
      ttk::scrollbar $path.scrollx -orient horizontal -command [list $c xview]
      
      # Create a container frame which will always be the same size as the canvas or content,
      # whichever is greater.
      set container [frame $c.container -bg white]
      pack propagate $container 0

      # Create the content frame, whose size will be determined by its contents.
      set content [frame $container.content -bg white]

      # Pack the content frame and place the container as a canvas item.
      pack $content -anchor nw -fill x
      $c create window 0 0 -window $container -anchor nw

      # Grid the scrollable canvas and scrollbars within the main frame.
      grid $c -row 0 -column 0 -sticky news
      grid rowconfigure $path 0 -weight 1
      grid columnconfigure $path 0 -weight 1

      # Make adjustments when the outer frame is resized or the contents change size.
      bind $path.c <Expose> [list [namespace current]::resize $path]

      # Mousewheel bindings for scrolling.
      bind [winfo toplevel $path] <MouseWheel> [list +[namespace current] scroll $path yview %W %D]
      bind [winfo toplevel $path] <Shift-MouseWheel> [list +[namespace current] scroll $path xview %W %D]

      return $path
   }

   # Given the path of a scrollable frame widget, return the path of content frame.
   proc content {path} {
      return $path.c.container.content
   }

   # Make adjustments when the outer frame is resized or the contents change size.
   proc resize {path} {
      set c $path.c
      set container $c.container
      set content $container.content

      # Set the size of the container. At a minimum use the same width and height as the canvas.
      set width [winfo width $c]
      set height [winfo height $c]
      
      # If the requested width or height of the content frame is greater then use that width or height.
      if {[winfo reqwidth $content] > $width} {
         set width [winfo reqwidth $content]
      }
      if {[winfo reqheight $content] > $height} {
         set height [winfo reqheight $content]
      }
      $container configure -width $width -height $height

      # Configure the canvas' scroll region to match the height and width of the container.
      $c configure -scrollregion [list 0 0 $width $height]

      # Show or hide the scrollbars as necessary.
      # Horizontal scrolling.
      if {[winfo reqwidth $content] > [winfo width $c]} {
         grid $path.scrollx -row 1 -column 0 -sticky ew
      } else {
         grid forget $path.scrollx
      }
      # Vertical scrolling.
      if {[winfo reqheight $content] > [winfo height $c]} {
         grid $path.scrolly -row 0 -column 1 -sticky ns
      } else {
         grid forget $path.scrolly
      }
      return
   }

   # Handle mouswheel scrolling.
   proc scroll {path view W D} {
      if {[winfo exists $path.c] && [string match $path.c* $W]} {
         $path.c $view scroll [expr {-$D}] units
      }
   }
}

proc sfTest {} {
   scrolledFrame new .frame ""
   #.frame configure -width 40 -height 40
   set cframe [scrolledFrame content .frame]
   grid [frame $cframe.filler_1 -background white -width 100 -height 100]\
      [frame $cframe.filler_2 -background red -width 50 -height 50]
   pack .frame -expand yes -fill both
}


