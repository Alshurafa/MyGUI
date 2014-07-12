
static char *C_STR( const String &t ){
	return t.ToCString<char>();
}

static OS_CHAR *OS_STR( const String &t ){
	return t.ToCString<OS_CHAR>();
}

FILE *pFile;

class myGUI
{
	public:
	static bool showAlert(String title, String message, bool twoButtons, String Button1, String Button2)
	{
		return true;
	}
	
	static void saveStringToFile(String message, String filename)
	{
		pFile = _wfopen(OS_STR(filename),L"w");
		fputws(OS_STR(message),pFile);
		fclose(pFile);
	}
	
	static String loadStringFromFile(String filename)
	{
		pFile = _wfopen(OS_STR(filename),L"r");
		if(pFile!=NULL)
		{
			wchar_t newString[256];
			fgetws(newString,256,pFile);
			
			String line = String(newString);
			fclose(pFile);
			return line;
		}
		fclose(pFile);
		return "";
	}
};