#tag Class
Class MirroredWindowBase
Inherits Window
	#tag Event
		Sub Activate()
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
		  
		  RaiseEvent Activate
		End Sub
	#tag EndEvent

	#tag Event
		Sub Close()
		  RaiseEvent Close()
		  
		  if GhostUpdater isa object then
		    GhostUpdater.Mode = Timer.ModeOff
		    RemoveHandler GhostUpdater.Action, WeakAddressOf GhostUpdater_Action
		    GhostUpdater = nil
		  end if
		  
		  if Ghost isa GhostWindow then
		    Ghost.Close
		    Ghost = nil
		  end if
		  
		  //
		  // If there are no other Ghosts, close the Scale window
		  //
		  dim closeIt as boolean = true // Assume we will
		  dim lastWindowIndex as integer = WindowCount - 1
		  for i as integer = 0 to lastWindowIndex
		    if Window( i ) isa GhostWindow then
		      closeIt = false
		      exit
		    end if
		  next
		  
		  if closeIt then
		    GhostScaleWindow.Close
		  end if
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub Deactivate()
		  if IgnoreActivate then
		    return
		  end if
		  
		  RaiseEvent Deactivate
		  
		  IsActive = false
		End Sub
	#tag EndEvent

	#tag Event
		Sub Open()
		  Ghost = new GhostWindow
		  
		  GhostScaleWindow.Show
		  
		  GhostUpdater = new Timer
		  AddHandler GhostUpdater.Action, WeakAddressOf GhostUpdater_Action
		  GhostUpdater.Period = 1000 / 10
		  GhostUpdater.Mode = Timer.ModeMultiple
		  
		  IsActive = true
		  
		  RaiseEvent Open()
		  
		  
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
		    dim newTop as integer = GhostScaleWindow.Top
		    dim newLeft as integer = self.Left + self.Width + 20
		    
		    if newLeft >= ( Screen( 0 ).Width - 10 ) then
		      newLeft = GhostScaleWindow.Left
		      newTop = self.Top + self.Height + 20
		    end if
		    
		    if newTop <= ( Screen( 0 ).Height - 10 ) then
		      GhostScaleWindow.Left = newLeft
		      GhostScaleWindow.Top = newTop
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
		  
		  if Ghost isa GhostWindow then
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
		    dim currentScale as double = GhostScaleWindow.Scale
		    
		    if currentScale <> LastScale or not IsSamePicture( p, LastImage ) then
		      LastScale = currentScale
		      LastImage = p
		      Ghost.GhostImage = p
		      Ghost.Invalidate
		    end if
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsSamePicture(p1 As Picture, p2 As Picture) As Boolean
		  if p1 = p2 then
		    return true
		  end if
		  
		  if p1 is nil and p2 is nil then
		    return true
		  end if
		  
		  if p1 is nil or p2 is nil then
		    return false
		  end if
		  
		  if p1.Width <> p2.Width or p1.Height <> p2.Height then
		    return false
		  end if
		  
		  if p1.Graphics.ScaleX <> p2.Graphics.ScaleX or p1.Graphics.ScaleY <> p2.Graphics.ScaleY then
		    return false
		  end if
		  
		  dim startµs as double = Microseconds
		  
		  dim data1 as string = p1.GetData( Picture.FormatTIFF )
		  dim data2 as string = p2.GetData( Picture.FormatTIFF )
		  dim isSame as boolean = StrComp( data1, data2, 0 ) = 0
		  
		  dim diff as double = Microseconds - startµs
		  System.DebugLog "Picture scanning took " + format( diff, "#,0" ) + " µs"
		  
		  return isSame
		  
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Activate()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Close()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Deactivate()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Open()
	#tag EndHook


	#tag Property, Flags = &h0
		AutoMoveGhostOnOpen As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Ghost As GhostWindow
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
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Size"
			InitialValue="400"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MaxHeight"
			Visible=true
			Group="Size"
			InitialValue="32000"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MaxWidth"
			Visible=true
			Group="Size"
			InitialValue="32000"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MinHeight"
			Visible=true
			Group="Size"
			InitialValue="64"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MinWidth"
			Visible=true
			Group="Size"
			InitialValue="64"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Size"
			InitialValue="600"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="CloseButton"
			Visible=true
			Group="Frame"
			InitialValue="True"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Frame"
			Visible=true
			Group="Frame"
			InitialValue="0"
			Type="Integer"
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
			Name="FullScreenButton"
			Visible=true
			Group="Frame"
			InitialValue="False"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MaximizeButton"
			Visible=true
			Group="Frame"
			InitialValue="True"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MinimizeButton"
			Visible=true
			Group="Frame"
			InitialValue="True"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Resizeable"
			Visible=true
			Group="Frame"
			InitialValue="True"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Title"
			Visible=true
			Group="Frame"
			InitialValue="Untitled"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="BackColor"
			Visible=true
			Group="Background"
			InitialValue="&hFFFFFF"
			Type="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Backdrop"
			Visible=true
			Group="Background"
			Type="Picture"
			EditorType="Picture"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasBackColor"
			Visible=true
			Group="Background"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ImplicitInstance"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Placement"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
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
			Name="Visible"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AutoMoveGhostOnOpen"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MenuBar"
			Visible=true
			Group="Menus"
			Type="MenuBar"
			EditorType="MenuBar"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MenuBarVisible"
			Visible=true
			Group="Deprecated"
			InitialValue="True"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Composite"
			Group="OS X (Carbon)"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FullScreen"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LiveResize"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MacProcID"
			Group="OS X (Carbon)"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
