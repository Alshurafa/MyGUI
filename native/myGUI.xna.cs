class myGUI
{
	static string result="Not intiated yet";
	static string keyboardInput="Not intiated yet";
	
	public static string getClickedButton()
	{
		return result;
	}
	public static void resetClickedButton()
	{
		result="Not intiated yet";
	}
	
	public static string getKeyboardInput()
	{
#if WINDOWS
		return "XNAWINDOWS";
#else
		return keyboardInput;
#endif
	}
	
	public static void shareApp(string message)
	{

	}
	
	public static void showKeyboard(string title, string prompt, string defaultText)
	{
#if !WINDOWS
		keyboardInput = "Not intiated yet";
		Guide.BeginShowKeyboardInput(
			PlayerIndex.One,
			title,
			prompt,
			defaultText,
			asyncResult =>
			{
				keyboardInput = Guide.EndShowKeyboardInput(asyncResult);
			},
			null);
#endif
	}
	
	public static void showAlert(string title, string message, bool twoButtons, string Button1, string Button2)
	{
		result="No result yet";
#if !WINDOWS
		if (twoButtons){
			Guide.BeginShowMessageBox(
				title,
				message,
				new string[] { Button1 , Button2 },
				0,
				MessageBoxIcon.None,
				asyncResult =>
				{
					int? returned = Guide.EndShowMessageBox(asyncResult);
					if (returned==0)
						result=Button1;
					else
						result=Button2;
				},
				null);
		}else{
			Guide.BeginShowMessageBox(
				title,
				message,
				new string[] { Button1 },
				0,
				MessageBoxIcon.None,
				asyncResult =>
				{
					int? returned = Guide.EndShowMessageBox(asyncResult);
					if (returned==0)
						result=Button1;
				},
				null);
		}
#endif
	}
	
	public static void saveStringToFile(string message, string filename)
	{

#if WINDOWS
		FileStream stream = File.Open(filename, FileMode.OpenOrCreate);
#else
		IsolatedStorageFileStream stream = new IsolatedStorageFileStream(filename, FileMode.OpenOrCreate, IsolatedStorageFile.GetUserStoreForApplication());
#endif
		using(StreamWriter writer = new StreamWriter(stream)) 
		{ 
			writer.Write(message); 
		}
	}
	
	public static string loadStringFromFile(string filename)
	{
		string message;
#if WINDOWS
		FileStream stream = File.Open(filename, FileMode.OpenOrCreate);
#else
		IsolatedStorageFileStream stream = new IsolatedStorageFileStream(filename, FileMode.OpenOrCreate, IsolatedStorageFile.GetUserStoreForApplication());
#endif
		using (StreamReader reader = new StreamReader(stream)) 
		{ 
			message = reader.ReadToEnd().ToString(); 
		}
		return message;
	}
}
