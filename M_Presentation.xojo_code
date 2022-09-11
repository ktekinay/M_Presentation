#tag Module
Protected Module M_Presentation
	#tag Method, Flags = &h1
		Protected Function IsSamePicture(p1 As Picture, p2 As Picture) As Boolean
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


	#tag Constant, Name = FontSize, Type = Double, Dynamic = False, Default = \"16", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
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
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
