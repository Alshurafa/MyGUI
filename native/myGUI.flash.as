import mx.controls.Alert;
import flash.ui.Mouse;

class myGUI
{
	static public function shareApp(message:String):void
	{
		
	}
	
	static public function showAlert(title:String, message:String, twoButtons:Boolean, Button1:String, Button2:String):Boolean
	{
		if (twoButtons==true){
			Alert.show(message,title,Alert.YES|Alert.NO);
		}else{
			Alert.show(message,title,Alert.OK);
		}
		return true;
	}
	
	static public function saveStringToFile(message:String,filename:String):void
	{
		
	}
	
	static public function loadStringFromFile(filename:String):String
	{
		return "";
	}
	
}