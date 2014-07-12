#Rem
myGUI Module includes Slider, Button, RadioButton, Checkbox, VirtualController, Alert Dialog, File Input, File Output
Thanks Bob for the cool zoom effect code
#End

#if HOST="macos" And TARGET="glfw"
	Import "native/myGUI.${TARGET}.mac.${LANG}"
'#else
#elseif TARGET<>"html5"
	Import "native/myGUI.${TARGET}.${LANG}"
#end

Import mojo
Import diddy.framework
Import diddy.functions

Extern
	#If LANG="cpp" Then
		Function GetClickedButton:String()="myGUI::getClickedButton"
		Function ResetClickedButton:Void()="myGUI::resetClickedButton"
		Function ShareApp:Void(message:String)="myGUI::shareApp"
		Function ShowAlert:Bool(title:String, message:String, twoButtons:Bool=False, Button1:String="OK",Button2:String="Cancel")="myGUI::showAlert"
		Function SaveStringToFile:Void(message:String, filename:String) = "myGUI::saveStringToFile"
		Function LoadStringFromFile:String(filename:String) = "myGUI::loadStringFromFile"
	#Else
		Function GetClickedButton:String()="myGUI.getClickedButton"
		Function ResetClickedButton:Void()="myGUI.resetClickedButton"
		Function ShareApp:Void(message:String)="myGUI.shareApp"
		Function ShowAlert:Bool(title:String, message:String, twoButtons:Bool=False, Button1:String="OK",Button2:String="Cancel")="myGUI.showAlert"
		Function SaveStringToFile:Void(message:String, filename:String) = "myGUI.saveStringToFile"
		Function LoadStringFromFile:String(filename:String) = "myGUI.loadStringFromFile"
		
		Function ShowXNAKeyboard:Void(title:string="", prompt:string="", defaultText:String="") = "myGUI.showKeyboard"
		Function GetKeyboardInput:String()="myGUI.getKeyboardInput"
	#End
Public
#Rem
summary: myGUI slider. (under development)
ToDo: Respect the sign
#End
Class Slider
Public
	Field x:Float, y:Float				' Coordinates for position
Private
	Field min:Float, max:Float			' max & min values e.g: {min [0]___.___[10] max}
	Field range:Float					' max-min
	Field value:Int						' Current value
	Field scaleX:Float					' control slider width
	Field btn:Button					' shows a square button or an image button on the slider
	Field slide:Bool					' used to prevent slider from sliding
	Global sliding:Bool=False			' used to prevent multiple sliders from sliding together
	Field offset:Int					' Used for drawing image sliders
	
	'summary: Do not use.
	Method Slide:Void()
		If slide=True
			If Touch_X()>=Self.x And Touch_X()<=Self.x+(Self.range*scaleX)
				btn.x=Touch_X()-offset
				Self.value = ((btn.x-Self.x)/scaleX)+min
			ElseIf Touch_X()<Self.x
				btn.x=Self.x-offset
				Self.value=min
			ElseIf Touch_X()>Self.x+(Self.range*scaleX)
				btn.x=Self.x+(Self.range*scaleX)-offset
				Self.value=max
			EndIf
		EndIf
	End

Public
	'summary: uses a square button on the slider
	Method New(x:Float,y:Float, min:Float,max:Float, scaleX:Float=1, value:Float=(min+max)/2)
		Self.x = x
		Self.y = y
		Self.min = min
		Self.max = max
		Self.value = value
		Self.scaleX = scaleX
		slide=False
		range = Abs(max - min)
		offset=10
		btn = New Button(x+(value*scaleX)-offset,y-offset,20,20)
	End
	
	'summary: uses an image button(img,x,y) on the slider.
	Method New(img:GameImage,x:Float,y:Float, min:Float,max:Float, scaleX:Float=1, value:Float=(min+max)/2)
		Self.x = x
		Self.y = y
		Self.min = min
		Self.max = max
		Self.value = value
		Self.scaleX = scaleX
		slide=False
		range = Abs(max - min)
		offset=0
		'need to respect the sign
		btn = New Button(img,x+((value-min)*scaleX),y)
	End
	
	'summary: Need to be in the Draw method.
	Method Draw:Void()
		DrawLine(Self.x,Self.y,Self.x+(range*scaleX),Self.y)
		btn.Draw()
	End
	
	'summary: Need to be in the update method.
	Method Update:Void()
		Slide()
		If btn.Down() And Not sliding
			slide=True
			sliding=True
		EndIf
		If Not TouchDown()
			sliding=False
		EndIf
		If slide=True And Not TouchDown()
			slide=False
		EndIf
	End
	
	'summary: Get the slider current value
	Method GetValue:Int()
		Return value
	End
	
	'summary: Set the slider current value
	Method SetValue:Void(newValue:Int)
		value=newValue
	End
End

'summary: radio button
Class RadioButton Extends Button
	Field r:Float
	Field group:Int
	Global list:ArrayList<RadioButton> = New ArrayList<RadioButton>
	Global enum:IEnumerator<RadioButton> = list.Enumerator()

	'summary: Text radio Button with a circle to the right. IMPORTANT: Choose a unique group id for every group
	Method New(groupID:Int,x:Float,y:Float,r:Float=20,title:String=" ")
		Super.New(x,y,r*2,r*2,title)
		group=groupID
		Self.r=r
		If Count(groupID)=0 Then Self.checked=True
		list.Add(Self)
	End
	
	'summary: For image check box. IMPORTANT: Choose a unique group id for every group
	Method New(groupID:Int,img:GameImage, x:Float=SCREEN_WIDTH2, y:Float=SCREEN_HEIGHT2, scale:Float=1)
		Super.New(img, x, y, scale)
		group=groupID
		If Count(groupID)=0 Then Self.checked=True
		list.Add(Self)
	End

	'summary: Draw only this radio button
	Method Draw:Void()
		If img
			If Not Self.checked Then SetAlpha(0.5)
			img.Draw(x,y,rotation,scale*zScale,scale*zScale)
			SetAlpha(1)
		Else
			Local c:= GetColor()
			If checked
				DrawCircle(x+(r/2),y+(r/2),r)
				DrawText(title,x+r+10,y+(r/2),0,.5)
				If c[0]=0 And c[1]=0 And c[2]=0
					SetColor(255,255,255)
				Else
					SetColor(0,0,0)
				EndIf
				If r>10
					DrawCircle(x+(r/2),y+(r/2),r-5)
				Else
					DrawCircle(x+(r/2),y+(r/2),r)
				End
				SetColor(c[0],c[1],c[2])
				DrawText("x",x+(r/2),y+(r/2),.5,.5)
			Else
				SetColor(127,127,127)
				DrawCircle(x+(r/2),y+(r/2),r)
				DrawText(title,x+r+10,y+(r/2),0,.5)
				SetColor(c[0],c[1],c[2])
			End
		End
	End
	
	'summary: Update only this radio button
	Method Update:Void()
		If Self.Click()
			enum.Reset()
			While enum.HasNext()
				Local b:RadioButton= enum.NextObject()
				If b.group=Self.group And b.checked
					b.checked=False
				End
			End
			Self.checked=True
		EndIf
	End
	
	'summary: Update an entire group of Radio Buttons
	Function Update:Void(groupID:Int)
		enum.Reset()
		While enum.HasNext()
			Local b:RadioButton= enum.NextObject()
			If b.group=groupID
				b.Update()
			EndIf
		End
	End
	
	'summary: Draw an entire group of Radio Buttons
	Function Draw:Void(groupID:Int)
		enum.Reset()
		While enum.HasNext()
			Local b:RadioButton= enum.NextObject()
			If b.group=groupID
				b.Draw()
			EndIf
		End
	End
	
	'summary: Return the number of buttons in a Group
	Function Count:Int(groupID:Int)
		Local counter:Int=0
		enum.Reset()
		While enum.HasNext()
			Local b:RadioButton= enum.NextObject()
			b.Update()
			If b.group=groupID
				counter+=1
			EndIf
		End
		Return counter
	End
End

'summary: myGUI Checkbox.
Class CheckBox Extends Button
	Field drawbox:Bool
	'summary: For Text check box.
	Method New(x:Float,y:Float,w:Float,h:Float,title:String=" ",drawbox:Bool=True)
		Super.New(x,y,w,h,title)
		Self.drawbox=drawbox
	End
	
	'summary: For image check box.
	Method New(img:GameImage, x:Float=SCREEN_WIDTH2, y:Float=SCREEN_HEIGHT2, scale:Float=1)
		Super.New(img, x, y, scale)
		Self.drawbox=False
	End

	'summary: Need to be in the Draw method. Image will be drawn only if the checkbox checked.
	Method Draw:Void()
		If img
			If checked Then img.Draw(x,y,rotation,scale*zScale,scale*zScale)
		Else
			If drawbox
				DrawText(title,x+w+5,y+(h/2),0,.5)
				DrawRectOutline(x,y,w,h)
				If checked
					If w>10 And h>10
						DrawRect(x+5,y+5,w-10,h-10)
					Else
						DrawRect(x,y,w,h)
					End
				End
			Else
				DrawText(title,x+50,y+(h/2),0,.5)
			EndIf
		EndIf
	End
	
	'Method Draw:Void(img:GameImage,rotation:Float=0,scaleX:Float=1,scaleY:Float=1)
	'	img.Draw(x,y,rotation,scaleX,scaleY)
	'End
	
	'summary: Need to be in the update method.
	Method Update:Void()
		Super.Check()
		If Click()
			If snd
				snd.Play()
			End
		EndIf
	End
End

#Rem
 summary: myGUI Button. Can be used as a text button, image button, invisible button.
For zoom effect: turn on the "zoom_effect" flag and insert update() into the update method
For click effect: just turn on the "click_effect" flag
For clicking sound: setSound(GameSound)
#End
Class Button
'#Region Fields
	Field click_effect:Bool			' If enabled, it will show a click effect when clicked
	Field zoom_effect:Bool			' If enabled, it will zoom in & out when clicked (Thanks Bob!)
	Field checked:Bool				' For checkbox use
	Field midHandle:Bool			' For Gameimage, prefered to be True
'	Field radioButton:Bool			' Used to change drawing behavior
	Field title:String				' For text buttons
	Field x:Float, y:Float			' Coordinates for position
	Field w:Float, h:Float			' Button size
	Field scale:Float				' control the size of the button
	Field rotation:Float
	Field img:GameImage
	Field snd:GameSound
	
	' Do not modify. For zoom_effect
	Field zScale:Float
   	Field zScaleTo:Float
   	Field zdefaultScale:Float = 1
   	Field zoomedScale:Float = 1.25
   	Field zoomed:Bool = False
   	Field zoomReturn:Bool = True
'#End Region

	'summary: For text buttons and invisible buttons.
	Method New(x:Float,y:Float,w:Float,h:Float, title:String=" ")
		checked=False
		zoom_effect=False
		click_effect = False
		Self.w=w
		Self.h=h
		Self.x=x
		Self.y=y
		Self.title = title
		midHandle=False
		
		zScale = zdefaultScale
		zScaleTo= zScale
	End
	
	'summary: For image buttons.
	Method New(img:GameImage, x:Float=SCREEN_WIDTH2, y:Float=SCREEN_HEIGHT2, scale:Float=1)
		Self.img=img	
		checked=False
		zoom_effect = False
		zoom_effect = False
		rotation=0
		Self.scale = scale
		Self.w=img.w*scale
		Self.h=img.h*scale
		Self.x=x
		Self.y=y
		Self.midHandle=img.MidHandle
		
		zScale = zdefaultScale
		zScaleTo= zScale
	End
	
	'summary: Need to be in the Draw method.
	Method Draw:Void()
		If Down() And click_effect
			If img
				img.Draw(x+5,y+5,rotation,scale*zScale,scale*zScale)
			Else
				Local c:= GetColor()
				SetColor(127,127,127)
				DrawRectOutline(x+5,y+5,w,h)
				DrawText(title,x+(w/2)+5,y+(h/2)+5,0.5,0.5)
				SetColor(c[0],c[1],c[2])
			EndIf
		Else
			If img
				img.Draw(x,y,rotation,scale*zScale,scale*zScale)
			Else
				DrawRectOutline(x,y,w,h)
				DrawText(title,x+(w/2),y+(h/2),0.5,0.5)
			EndIf
		EndIf
	End
	
	'summary: Set the clicking sound.
	Method SetSound:Void(s:GameSound)
		snd=s
	End
	
	'summary: For use with checkboxes. Need to be in the update method.
	Method Check:Void()
		If midHandle
			If TouchHit(0) And Touch_X() >= x-w/2 And Touch_X() < x+w/2 And Touch_Y() >= y-h/2 And Touch_Y() < y+h/2
				If Not checked
					checked=True
				Else
					checked=False
				End
			End
		Else
			If TouchHit(0) And Touch_X() >= x And Touch_X() < x+w And Touch_Y() >= y And Touch_Y() < y+h
				If Not checked
					checked=True
				Else
					checked=False
				End
			End
		End
	End
	
	'summary: Return true if the button is clicked.
	Method Click:Bool()
		If midHandle
			If TouchHit(0) And Touch_X() >= x-w/2 And Touch_X() < x+w/2 And Touch_Y() >= y-h/2 And Touch_Y() < y+h/2
				If zoom_effect
					Zoom(True,True)
				EndIf
				Return True
			Else
				Return False
			End
		Else
			If TouchHit(0) And Touch_X() >= x And Touch_X() < x+w And Touch_Y() >= y And Touch_Y() < y+h
				If zoom_effect
					Zoom(True,True)
				EndIf
				Return True
			Else
				Return False
			End
		End
	End
	
	'summary: Return true on mouse hover.
	Method Down:Bool()
		If midHandle
			If TouchDown(0) And Touch_X() >= x-w/2 And Touch_X() < x+w/2 And Touch_Y() >= y-h/2 And Touch_Y() < y+h/2
				Return True
			Else
				Return False
			End
		Else
			If TouchDown(0) And Touch_X() >= x And Touch_X() < x+w And Touch_Y() >= y And Touch_Y() < y+h
				Return True
			Else
				Return False
			End
		End
	End

	'summary: For use with zoom effect and clicking sound. Need to be in the update method.
	Method Update:Void()
		If Click()
			If snd
				snd.Play()
			End
		EndIf
		If (Abs(zScale - zScaleTo) > 0.01)
		    zScale += (zScaleTo - zScale) / 5.0
		    runningAnimation = True
		Else If (runningAnimation)
		    zScale = zScaleTo
		    runningAnimation = False
		    onAnimationDone();
		End If
	End
	
	Field runningAnimation:Bool = False
	
	'summary: Do not use!
	Method onAnimationDone:Void()
    	If (zoomReturn) 
            If (zoomedScale = zScale)
              Zoom(False, True)
            EndIf
        EndIf
    End
	
	'summary: Do not use!
	Method Zoom:Void(zoom:Bool, zoomReturn:Bool)
      	Self.zoomed = zoom
      	Self.zoomReturn = zoomReturn
      	If (zoom)
         	zScaleTo = zoomedScale
      	Else
         	zScaleTo = zdefaultScale
      	Endif 
   	End
End

Class VirtualController
	Field show:Bool
	Field arrows:Sprite
	Field btnA:Sprite
	Field btnB:Sprite
	Field eraser:Sprite
	Field eraserBig:Button 'Virtual Button for erase when virtual controller is not working
	
	Method New(dW:Int,dH:Int)
		show=False
		arrows=New Sprite(game.images.Find("arrows"),0,dH)
		arrows.y-=arrows.image.h
		arrows.alpha=.5
		btnA=New Sprite(game.images.Find("ButtonA"),dW,dH)
		btnA.x-=btnA.image.w
		btnA.y-=btnA.image.h
		btnA.alpha=.5
		btnB=New Sprite(game.images.Find("ButtonB"),dW,btnA.y)
		btnB.x-=btnB.image.w
		btnB.y-=btnB.image.h
		btnB.alpha=.5
		eraser=New Sprite(game.images.Find("eraser"),btnB.x+5,btnB.y+10)
		eraser.scaleX=.5
		eraser.scaleY=.5
		eraser.alpha=.5
		eraserBig= New Button(game.images.Find("eraser"),dW*.05,dH-40)
	End
	
	Method Draw:Void()
		If show
			arrows.Draw()
			btnA.Draw()
			btnB.Draw()
			eraser.Draw()
			DrawText(eraser.name,btnB.x+btnB.image.w/2,btnB.y+btnB.image.h/2,.5,.5) 'eraser name = number of erasers
		Else
			eraserBig.Draw()
			DrawText(eraser.name,eraserBig.x+eraserBig.img.w/2,eraserBig.y,.5,.5) 'eraser name = number of erasers
		End
	End
	
	Method Update:Void()
		If ButtonA()
			btnA.alpha=1
		Else
			btnA.alpha=.5
		End
		If ButtonB()
			btnB.alpha=1
		Else
			btnB.alpha=.5
		End
		If Arrows()
			arrows.alpha=1
		Else
			arrows.alpha=.5
		End
	End
	
	Method ButtonA:Bool()
		If (TouchDown(0) And Touch_X(0)>btnA.x And Touch_Y(0)>btnA.y) Or (TouchDown(1) And Touch_X(1)>btnA.x And Touch_Y(1)>btnA.y)
			Return True
		Else
			Return False
		End
	End
	
	Method ButtonB:Bool()
		If (TouchDown(0) And Touch_X(0)>btnB.x And Touch_Y(0)>btnB.y And Touch_Y(0)<btnA.y) Or
		(TouchDown(1) And Touch_X(1)>btnB.x And Touch_Y(1)>btnB.y And Touch_Y(1)<btnA.y)
			Return True
		Else
			Return False
		End
	End
	
	Method Arrows:Bool()
		If (TouchDown(0) And Touch_X(0)<arrows.image.w And Touch_Y(0)>arrows.y) Or (TouchDown(1) And Touch_X(1)<arrows.image.w And Touch_Y(1)>arrows.y)
			Return True
		Else
			Return False
		End
	End
	
	Method Shoot:Bool()
		If (TouchHit(0) And Touch_X(0)>btnA.x And Touch_Y(0)>btnA.y) Or (TouchHit(1) And Touch_X(1)>btnA.x And Touch_Y(1)>btnA.y)
			Return True
		Else
			Return False
		End
	End
	
	Method Erase:Bool()
		If (TouchHit(0) And Touch_X(0)>btnB.x And Touch_Y(0)>btnB.y And Touch_Y(0)<btnA.y) Or
		(TouchHit(1) And Touch_X(1)>btnB.x And Touch_Y(1)>btnB.y And Touch_Y(1)<btnA.y)
			Return True
		Else
			Return False
		End
	End
	
	Method MoveRight:Bool()
		If (TouchDown(0) And Touch_X(0)<arrows.image.w*1.3 And Touch_X(0)>arrows.image.w*2/3 And Touch_Y(0)>arrows.y) Or
		(TouchDown(1) And Touch_X(1)<arrows.image.w*1.3 And Touch_X(1)>arrows.image.w*2/3 And Touch_Y(1)>arrows.y)
			Return True
		Else
			Return False
		End
	End
	
	Method MoveLeft:Bool()
		If (TouchDown(0) And Touch_X(0)<arrows.image.w/3 And Touch_Y(0)>arrows.y) Or
		(TouchDown(1) And Touch_X(1)<arrows.image.w/3 And Touch_Y(1)>arrows.y)
			Return True
		Else
			Return False
		End
	End
	
	Method MoveDown:Bool()
		If (TouchDown(0) And Touch_X(0)<arrows.image.w And Touch_Y(0)>arrows.y+arrows.image.h/3) Or
		(TouchDown(1) And Touch_X(1)<arrows.image.w And Touch_Y(1)>arrows.y+arrows.image.h/3)
			Return True
		Else
			Return False
		End
	End
	
	Method MoveUp:Bool()
		If (TouchDown(0) And Touch_X(0)<arrows.image.w*1.3 And Touch_Y(0)>arrows.y And Touch_Y(0)<arrows.y+arrows.image.h2/3) Or
		(TouchDown(1) And Touch_X(1)<arrows.image.w*1.3 And Touch_Y(1)>arrows.y And Touch_Y(1)<arrows.y+arrows.image.h2/3)
			Return True
		Else
			Return False
		End
	End
End

Class GameControl
	Const touch:Int = 1
	Const keyboard:Int=0
	Const virtual:Int =2
	Field type:Int
	Field x:Float
	Field y:Float
	Field sensitivity:Float
	Field vc:VirtualController
	Method New()
		
	End
	Method Start:Void()
		vc= New VirtualController(dW,dH)
		sensitivity=0.05
		#If TARGET="ios"
			x=.4
		#Else
			x=-.4
		#End
		y=0
	End
	Method Update:Void()
		type=options.controlType
	End
	Method GoRight:Bool()
		If type=keyboard
			If KeyDown(KEY_RIGHT) Or KeyDown(KEY_D)
				Return True
			Else
				Return False
			End
		Elseif type=virtual
			If vc.MoveRight()
				Return True
			Else
				Return False
			End
		#If TARGET<>"flash"
		Elseif type=touch
			If AccelW()>y+sensitivity
				Return True
			Else
				Return False
			End
		#End
		End
		Return False
	End
	Method GoLeft:Bool()
		If type=keyboard
			If KeyDown(KEY_LEFT) Or KeyDown(KEY_A)
				Return True
			Else
				Return False
			End
		Elseif type=virtual
			If vc.MoveLeft()
				Return True
			Else
				Return False
			End
		#If TARGET<>"flash"
		Elseif type=touch
			If AccelW()<y-sensitivity
				Return True
			Else
				Return False
			End
		#End
		End
		Return False
	End
	Method GoDown:Bool()
		If type=keyboard
			If KeyDown(KEY_DOWN) Or KeyDown(KEY_S)
				Return True
			Else
				Return False
			End
		Elseif type=virtual
			If vc.MoveDown()
				Return True
			Else
				Return False
			End
		#If TARGET<>"flash"
		Elseif type=touch
			If AccelH()<x-sensitivity
				Return True
			Else
				Return False
			End
		#End
		End
		Return False
	End
	Method GoUp:Bool()
		If type=keyboard
			If KeyDown(KEY_UP) Or KeyDown(KEY_W)
				Return True
			Else
				Return False
			End
		Elseif type=virtual
			If vc.MoveUp()
				Return True
			Else
				Return False
			End
		#If TARGET<>"flash"
		Elseif type=touch
			If AccelH()>x+sensitivity
				Return True
			Else
				Return False
			End
		#End
		End
		Return False
	End
	Method Shoot:Bool()
		If type=keyboard
			If KeyHit(KEY_SPACE)
				Return True
			Else
				Return False
			End
		Elseif type=virtual
			If vc.Shoot()
				Return True
			Else
				Return False
			End
		Elseif type=touch
			If TouchHit(0)
				Return True
			Else
				Return False
			End
		End
		Return False
	End
	Method Erase:Bool()
		If type=keyboard
			If KeyHit(KEY_ENTER)
				Return True
			Else
				Return False
			End
		Elseif type=virtual
			If vc.Erase()
				Return True
			Else
				Return False
			End
		Elseif type=touch
			If vc.eraserBig.Click()
				Return True
			Else
				Return False
			End
		End
		Return False
	End
End

'summary: Return AccelY() which is reveresed in android
Function AccelH:Float()
	#If TARGET="ios"
		Return -AccelY()
	#ElseIf TARGET="android"
		Return AccelX()
	#Else
		Return 0
	#End
End

'summary: Return AccelX() which is reveresed in android
Function AccelW:Float()
	#If TARGET="ios"
		Return AccelX()
	#ElseIf TARGET="android"
		Return AccelY()
	#Else
		Return 0
	#End
End

'summary: Draw an image to fill the device width and height
Function DrawBG:Void(background:Image)
	Local bg:=background
	bg.SetHandle(0,0)
	DrawImage bg, 0, 0, 0, SCREEN_WIDTH/bg.Width(), SCREEN_HEIGHT/bg.Height()
End

'summary: Return TouchX() with respect to the virtual screen size
Function Touch_X:Float(i#=0)
	Return TouchX(i)/SCREENX_RATIO
End

'summary: Return TouchY() with respect to the virtual screen size
Function Touch_Y:Float(i#=0)
	Return TouchY(i)/SCREENY_RATIO
End