#tag Class
Class MirroredWindow2Base
Inherits DesktopWindow
	#tag Event
		Sub Activated()
		  if IgnoreActivate then
		    //
		    // Already active so ignore this
		    //
		    return
		  end if
		  
		  IgnoreActivate = true
		  
		  IsActive = true
		  
		  //
		  // See if our ghost needs to be brought to the front
		  //
		  if Ghost isa object and not ( Window( 1 ) is Ghost ) then
		    Ghost.Show
		    self.Show
		  end if
		  
		  IgnoreActivate = false
		  
		  RaiseEvent Activated
		End Sub
	#tag EndEvent

	#tag Event
		Sub Closing()
		  RaiseEvent Closing()
		  
		  if GhostUpdater isa object then
		    GhostUpdater.Mode = Timer.ModeOff
		    RemoveHandler GhostUpdater.Action, WeakAddressOf GhostUpdater_Action
		    GhostUpdater = nil
		  end if
		  
		  if Ghost isa GhostWindow2 then
		    Ghost.Close
		    Ghost = nil
		  end if
		  
		  //
		  // If there are no other Ghosts, close the Scale window
		  //
		  dim closeIt as boolean = true // Assume we will
		  dim lastWindowIndex as integer = WindowCount - 1
		  for i as integer = 0 to lastWindowIndex
		    if Window( i ) isa GhostWindow2 then
		      closeIt = false
		      exit
		    end if
		  next
		  
		  if closeIt then
		    GhostScaleWindow2.Close
		  end if
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub Deactivated()
		  if IgnoreActivate then
		    return
		  end if
		  
		  RaiseEvent Deactivated
		  
		  IsActive = false
		End Sub
	#tag EndEvent

	#tag Event
		Sub Opening()
		  Ghost = new GhostWindow2
		  
		  GhostScaleWindow2.Show
		  
		  GhostUpdater = new Timer
		  AddHandler GhostUpdater.Action, WeakAddressOf GhostUpdater_Action
		  GhostUpdater.Period = 1000 / 10
		  GhostUpdater.Mode = Timer.ModeMultiple
		  
		  IsActive = true
		  
		  RaiseEvent Opening()
		  
		  if AutoMoveGhostOnOpen then
		    //
		    // Move the ghost window to somewhere more logical
		    //
		    dim newLeft as integer
		    dim newTop as integer
		    
		    if ScreenCount > 1 then
		      newLeft = Screen( 1 ).Left + self.Left
		      newTop = Screen( 1 ).Top + self.Top
		    else
		      newLeft = self.Left + self.Width + 20
		    end if
		    
		    //
		    // Make sure it's still visible
		    //
		    if newLeft < ( Screen( 0 ).Width - 10 ) and newTop < ( Screen( 0 ).Height - 10 ) then
		      Ghost.Left = newLeft
		      Ghost.Top = newTop
		    end if
		  end if
		  
		  //
		  // Move the controls
		  //
		  if true then
		    dim newTop as integer = GhostScaleWindow2.Top
		    dim newLeft as integer = self.Left + self.Width + 20
		    
		    if newLeft >= ( Screen( 0 ).Width - 10 ) then
		      newLeft = GhostScaleWindow2.Left
		      newTop = self.Top + self.Height + 20
		    end if
		    
		    if newTop <= ( Screen( 0 ).Height - 10 ) then
		      GhostScaleWindow2.Left = newLeft
		      GhostScaleWindow2.Top = newTop
		    end if
		  end if
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub DrawCursor(g as Graphics)
		  dim x as integer = System.MouseX - self.Left
		  dim y as integer = System.MouseY - self.Top
		  
		  if  x >= 0 and x <= self.Width and _
		    y >= 0 and y <= self.Height then
		    dim ovalOffset as Integer = kMouseDiameter / 2 
		    
		    g.ForeColor = &cFF000000
		    g.FillOval _
		    X - ovalOffset, _
		    Y - ovalOffset, _
		    kMouseDiameter, _
		    kMouseDiameter
		    
		    if System.MouseDown then
		      g.PenWidth = kOvalPenWidth
		      
		      dim diameter as integer = kMouseDiameter + kMouseDownDiameterAddition
		      dim outerOffset as integer = diameter / 2
		      
		      g.DrawOval x - outerOffset, _
		      y - outerOffset, _
		      diameter, _
		      diameter
		    end if
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub GhostUpdater_Action(sender As Timer)
		  #pragma unused sender
		  
		  if Ghost isa GhostWindow2 then
		    if Ghost.Title <> self.Title then
		      Ghost.Title = self.Title
		    end if
		    
		    dim p as Picture = self.BitmapForCaching( self.Width, self.Height )
		    self.DrawInto p.Graphics, 0, 0
		    
		    //
		    // Cursor
		    //
		    DrawCursor p.Graphics
		    
		    //
		    // Check to see if Ghost.Invalidate is necessary.
		    // We do this here because, once we call Invalidate,
		    // the Ghost must draw *something* or it will go blank.
		    //
		    dim currentScale as double = GhostScaleWindow2.Scale
		    
		    if currentScale <> LastScale or not M_Presentation.IsSamePicture( p, LastImage ) then
		      LastScale = currentScale
		      LastImage = p
		      Ghost.GhostImage = p
		      Ghost.Refresh
		    end if
		  end if
		  
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Activated()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Closing()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Deactivated()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Opening()
	#tag EndHook


	#tag Property, Flags = &h0
		AutoMoveGhostOnOpen As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Ghost As GhostWindow2
	#tag EndProperty

	#tag Property, Flags = &h21
		Private GhostUpdater As Timer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private IgnoreActivate As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private IsActive As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private LastImage As Picture
	#tag EndProperty

	#tag Property, Flags = &h21
		Private LastScale As Double = -1.0
	#tag EndProperty


	#tag Constant, Name = kMouseDiameter, Type = Double, Dynamic = False, Default = \"12", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMouseDownDiameterAddition, Type = Double, Dynamic = False, Default = \"10", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOvalPenWidth, Type = Double, Dynamic = False, Default = \"3", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Interfaces"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="MinimumWidth"
			Visible=true
			Group="Size"
			InitialValue="64"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="MinimumHeight"
			Visible=true
			Group="Size"
			InitialValue="64"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="MaximumWidth"
			Visible=true
			Group="Size"
			InitialValue="32000"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="MaximumHeight"
			Visible=true
			Group="Size"
			InitialValue="32000"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Size"
			InitialValue="400"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Size"
			InitialValue="600"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Type"
			Visible=true
			Group="Frame"
			InitialValue="0"
			Type="Types"
			EditorType="Enum"
			#tag EnumValues
				"0 - Document"
				"1 - Movable Modal"
				"2 - Modal Dialog"
				"3 - Floating Window"
				"4 - Plain Box"
				"5 - Shadowed Box"
				"6 - Rounded Window"
				"7 - Global Floating Window"
				"8 - Sheet Window"
				"9 - Metal Window"
				"11 - Modeless Dialog"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasCloseButton"
			Visible=true
			Group="Frame"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasMaximizeButton"
			Visible=true
			Group="Frame"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasMinimizeButton"
			Visible=true
			Group="Frame"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasFullScreenButton"
			Visible=true
			Group="Frame"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Resizeable"
			Visible=true
			Group="Frame"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Title"
			Visible=true
			Group="Frame"
			InitialValue="Untitled"
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasBackgroundColor"
			Visible=true
			Group="Background"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="BackgroundColor"
			Visible=true
			Group="Background"
			InitialValue="&hFFFFFF"
			Type="ColorGroup"
			EditorType="ColorGroup"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Backdrop"
			Visible=true
			Group="Background"
			InitialValue=""
			Type="Picture"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="DefaultLocation"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Locations"
			EditorType="Enum"
			#tag EnumValues
				"0 - Default"
				"1 - Parent Window"
				"2 - Main Screen"
				"3 - Parent Window Screen"
				"4 - Stagger"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="ImplicitInstance"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AutoMoveGhostOnOpen"
			Visible=true
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LastImage"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Picture"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LastScale"
			Visible=false
			Group="Behavior"
			InitialValue="-1.0"
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="MenuBar"
			Visible=true
			Group="Menus"
			InitialValue=""
			Type="DesktopMenuBar"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="MenuBarVisible"
			Visible=true
			Group="Deprecated"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Composite"
			Visible=false
			Group="OS X (Carbon)"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="FullScreen"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="MacProcID"
			Visible=false
			Group="OS X (Carbon)"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
