{-$IMPORTEDDATA ON}
unit FnCommon;

// to_do :
// morze: https://ru.wikipedia.org/wiki/%D0%90%D0%B7%D0%B1%D1%83%D0%BA%D0%B0_%D0%9C%D0%BE%D1%80%D0%B7%D0%B5

{$G+}
{$WARN SYMBOL_DEPRECATED OFF}
{$WARN SYMBOL_PLATFORM OFF}
{$WARN GARBAGE OFF}
{-$WARN UNIT_PLATFORM OFF}
// --- переменные среды Windows ---
//https://ru.wikipedia.org/wiki/%D0%9F%D0%B5%D1%80%D0%B5%D0%BC%D0%B5%D0%BD%D0%BD%D0%B0%D1%8F_%D1%81%D1%80%D0%B5%D0%B4%D1%8B_Windows

interface

(*ver 20140725*)

{-$D 'My Application version 2017.12.13'}

uses


  //ShareMem,
  Windows, SysUtils, Classes
  //, Graphics
  , ExtCtrls
  , Forms
  , IdGlobal, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdFTP
  ,   IdHashMessageDigest, idHash, idHashSha
  , IdSSLOpenSSL, IdSSLOpenSSLHeaders
  , Graphics, JPEG, GIFImg, PNGImage
  , Variants
  , ComObj
  , ShellAPI
  , ShlObj
  , ActiveX
  , xmldoc, xmldom, MSHTML, OleCtrls, SHDocVw
  , DB, ADODB, DBTables
  , UrlMon
  , Clipbrd
  , INIFiles
  , Controls
  , Grids
  , ComCtrls
  , Messages
  , CheckLst
  , Types
  , TlHelp32
  , StdCtrls
  , Buttons
  , WinSock
  , StrUtils
  , math
  , Dialogs
  , ImgList
  , Menus
  //, mmsystem // 20160421
  , WideStrUtils
  , EncdDecd
  , TypInfo, Rtti
  , Registry
  , NB30
  , CommCtrl
  , psAPI
  , Printers
  , Zlib , idZlib, idZlibHeaders
  , Generics.Defaults, Generics.Collections
  , UxTheme
  , DBXJSON
  , DateUtils


 ;

var
 MainFormHandle  : cardinal= 0; // хэндл главной формы приложения (!!!) переводить всех на использование этой переменной
 ClipBoardNextWnd: cardinal= 0; // хэндл окна для переключения наблюдателя за буфером обмена , см. ClipboardWatch
 AtomNameStart : PChar; // -- атом на старт прложения
 AtomNameWork  : PChar; // -- атом на работу приложения

const
  //-- Search String : ss.......

  ssEsteeLauder = 'http://www.esteelauder.ru/search/?s={0}';//-- только Ansi
  ssGoogle = 'http://www.google.ru/search?source=ig&hl=ru&q={0}';
  ssYandex = 'http://yandex.ru/yandsearch?text={0}&lr=213';
  ssGoodsmatrix = 'http://goodsmatrix.ru/goods-producer/{0}.html';
  //-- только для штрихкодов EAN-13 поиск товара (Россия)
  ssYandexMap = 'http://geocode-maps.yandex.ru/1.x/?geocode={0}' +
  (*'&results=50*)'&key={1}';//-- {0} адрес, пробелы на "+", {1} API ключ
  ssYandexMapAdv =
    'http://geocode-maps.yandex.ru/1.x/?geocode={0}&results={2}&key={1}';
  //-- {0} адрес, пробелы на "+", {1} API ключ, {2} количество возвращаемых результатов
  ssYandexMapExt = 'http://geocode-maps.yandex.ru/1.x/?geocode={0}{2}&key={1}';
  //-- {0} адрес, пробелы на "+", {1} API ключ {2} доп параметры
  ///http://maps.googleapis.com/maps/api/geocode/xml?address=%31%31%2B%D0%A7%D0%B8%D0%BA%D0%B8%D0%BD%D0%B0%2B%D0%9E%D0%B4%D0%B8%D0%BD%D1%86%D0%BE%D0%B2%D0%BE,+RU&sensor=false
  ssGoogleMap =
    'http://maps.googleapis.com/maps/api/geocode/xml?address={0},+RU&sensor=false&language=ru';

  //-- может быть как Ansi так и Unicode
  DegreeChar          = '°';
  CopyRightChar       = '©';
  RegisteredChar      = '®';
  DaggerChar          = '†';
  BulletChar          = '•';
  ElipBtnChar         = '…';
  EvroChar            = '€';
  DollarChar          = '$';
  RubleChar           = '₽';
  PercentChar         = '%';
  NumeroChar          = '№';
  NumberChar          = '#';
  TradeMarkChar       = '™';
  PromileChar         = '‰';
  DoubleDaggerChar    = '‡';
  CurrencySignChar    = '¤';
  ParagraphCahr       = '§';
  NotSignChar         = '¬';
  MicroChar           = 'µ';
  PlusMinusChar       = '±';
  LongMinus           = '—';
  MidleMinus          = '–';
  MidleDot            = '·';
  SuperScript1        = '¹';
  SuperScript2        = '²';
  SuperScript3        = '³';

  BadChars = '*\/:!?"''<>|'#10#13;
  SysBadChars : array[0..8] of PAnsiChar = ('\','/',':','*','?','"','<','>','|');
  SysBadCharsStr = '\/:*?<>|';
  SysBadCharsCS :  TSysCharSet = ['\','/',':','*','?','<','>','|'];
  cr = #13;  // \r OD
  lf = #10;  // \n OA
  crlf = cr + lf;
  tab = #9;
  CFGSoftFolder = 'KhS_Soft\';

  XMLTitleWOEncoding = '<?xml version="1.0"?>';
  XMLTitleWIN1251 = '<?xml version="1.0" encoding="windows-1251"?>';
  XMLTitleUTF8 = '<?xml version="1.0" encoding="UTF-8"?>';

  HTMLTitleWIN1251 = '<html><meta http-equiv="Content-Type" content="text/html; charset=windows-1251"/><body>';
  HTMLEnd = '</body></html>';

{$J+}
  SizeOfChar    : integer = 1;
  SizeOfWord    : integer = 2;
  SizeOfInteger : integer = 4;
  SizeOfDWord   : integer = 4;
  SizeOfInt64   : integer = 8;
  //--  размер символа в байтах для использования в функциях распределения памяти


{$J-}

const
  MAX_PATH_EX = 2048;

  VK_NULL = $00;

  VK_0 = $30;//0 key
  VK_1 = $31;//1 key
  VK_2 = $32;//2 key
  VK_3 = $33;//3 key
  VK_4 = $34;//4 key
  VK_5 = $35;//5 key
  VK_6 = $36;//6 key
  VK_7 = $37;//7 key
  VK_8 = $38;//8 key
  VK_9 = $39;//9 key

  VK_A = $41;//A key
  VK_B = $42;//B key
  VK_C = $43;//C key
  VK_D = $44;//D key
  VK_E = $45;//E key
  VK_F = $46;//F key
  VK_G = $47;//G key
  VK_H = $48;//H key
  VK_I = $49;//I key
  VK_J = $4A;//J key
  VK_K = $4B;//K key
  VK_L = $4C;//L key
  VK_M = $4D;//M key
  VK_N = $4E;//N key
  VK_O = $4F;//O key
  VK_P = $50;//P key
  VK_Q = $51;//Q key
  VK_R = $52;//R key
  VK_S = $53;//S key
  VK_T = $54;//T key
  VK_U = $55;//U key
  VK_V = $56;//V key
  VK_W = $57;//W key
  VK_X = $58;//X key
  VK_Y = $59;//Y key
  VK_Z = $5A;//Z key

  MAX_INTEGER   = 2147483647;
  MIN_INTEGER   = -2147483648;
  MAX_CARDINAL  = 4294967295;
  MAX_WORD      = $FFFF;
  MAX_DWORD     = $FFFFFFFF;
  MAX_DOUBLE    = 1.7E308;
  MAX_INT64     = 9223372036854775807; //$7FFFFFFFFFFFFFFF

  SYNCHRONIZE = $100000;
  //Enables the use of the thread handle in any of the wait functions.
  THREAD_ALL_ACCESS = $1F03FF;//All possible access rights for a thread object.
  THREAD_DIRECT_IMPERSONATION = $0200;
  //Required for a server thread that impersonates a client.
  THREAD_GET_CONTEXT = $0008;
  //Required to read the context of a thread using GetThreadContext.
  THREAD_IMPERSONATE = $0100;
  //Required to use a thread's security information directly without calling it by using a communication mechanism that provides impersonation services.
  THREAD_QUERY_INFORMATION = $0040;
  //Required to read certain information from the thread object, such as the exit code (see GetExitCodeThread).
  THREAD_SET_CONTEXT = $0010;
  //Required to write the context of a thread using SetThreadContext.
  THREAD_SET_INFORMATION = $0020;
  //Required to set certain information in the thread object.
  THREAD_SET_THREAD_TOKEN = $0080;
  //Required to set the impersonation token for a thread using SetTokenInformation.
  THREAD_SUSPEND_RESUME = $0002;
  //Required to suspend or resume a thread (see SuspendThread and ResumeThread).
  THREAD_TERMINATE = $0001;
  //Required to terminate a thread using TerminateThread.
  STD_THREAD_START_OPTIONS =//THREAD_ALL_ACCESS;
    THREAD_SET_INFORMATION or
    THREAD_QUERY_INFORMATION or
    THREAD_SUSPEND_RESUME or
    THREAD_TERMINATE or
    SYNCHRONIZE;
  THREAD_FULL = STD_THREAD_START_OPTIONS;
  THREAD_STANDART = STD_THREAD_START_OPTIONS;

  DT_LEFT_ALIGN = DT_SINGLELINE + DT_VCENTER + DT_LEFT + DT_END_ELLIPSIS;
  DT_LEFT_CALC = DT_LEFT_ALIGN - DT_END_ELLIPSIS + DT_CALCRECT;
  DT_RIGHT_ALIGN = DT_SINGLELINE + DT_VCENTER + DT_RIGHT + DT_END_ELLIPSIS;
  DT_RIGHT_CALC = DT_RIGHT_ALIGN - DT_END_ELLIPSIS + DT_CALCRECT;
  DT_CENTER_ALIGN = DT_SINGLELINE + DT_VCENTER + DT_CENTER + DT_END_ELLIPSIS;
  DT_CENTER_CALC = DT_CENTER_ALIGN - DT_END_ELLIPSIS + DT_CALCRECT;

(*ColorA*)  clPaleRed         = TColor($CCCCFF);
(*ColorB*)  clPaleGreen       = TColor($CCFFCC);
(*ColorC*)  clPaleBlue        = TColor($FFCCCC);
(*ColorD*)  clPaleYellow      = TColor($E0FFFF);
(*ColorE*)  clPaleOrange      = TColor($FFC896);//: RGB($FF,$80,$00);
(*ColorF*)  clPaleFuchsia     = TColor($FFEEFF);
(*ColorG*)  clSeaWaveLite     = $00e5FFbA;//$00C864FF;// TColor($00FF64C8);
(*ColorH*)  clDarkGreen       = TColor($002800);

(*ColorI*)  clDarkPaleRed     = TColor($8080FF);
(*ColorJ*)  clDarkPaleGreen   = TColor($80FF80);
(*ColorK*)  clDarkPaleBlue    = TColor($FF8080);
(*ColorL*)  clDarkPaleYellow  = TColor($80FFFF);
(*ColorM*)  clOrange          = TColor($0080FF);//: RGB($FF,$80,$00);
(*ColorN*)  clViolet          = 16711808;
(*ColorO*)  clJapanCalc       = TColor($C8FF50); //$0080FF00
(*ColorP*)

  clLiteGray        = TColor($ECECEC);
  clPaleGray        = clLiteGray;
  clTVDots          = TColor($6D6D6D);

  HLSMAX = 240;
  RGBMAX = 255;
  UNDEFINED =(HLSMAX * 2)div 3;

  SE_CREATE_TOKEN_NAME = 'SeCreateTokenPrivilege';
  SE_ASSIGNPRIMARYTOKEN_NAME = 'SeAssignPrimaryTokenPrivilege';
  SE_LOCK_MEMORY_NAME = 'SeLockMemoryPrivilege';
  SE_INCREASE_QUOTA_NAME = 'SeIncreaseQuotaPrivilege';
  SE_UNSOLICITED_INPUT_NAME = 'SeUnsolicitedInputPrivilege';
  SE_MACHINE_ACCOUNT_NAME = 'SeMachineAccountPrivilege';
  SE_TCB_NAME = 'SeTcbPrivilege';
  SE_SECURITY_NAME = 'SeSecurityPrivilege';
  SE_TAKE_OWNERSHIP_NAME = 'SeTakeOwnershipPrivilege';
  SE_LOAD_DRIVER_NAME = 'SeLoadDriverPrivilege';
  SE_SYSTEM_PROFILE_NAME = 'SeSystemProfilePrivilege';
  SE_SYSTEMTIME_NAME = 'SeSystemtimePrivilege';
  SE_PROF_SINGLE_PROCESS_NAME = 'SeProfileSingleProcessPrivilege';
  SE_INC_BASE_PRIORITY_NAME = 'SeIncreaseBasePriorityPrivilege';
  SE_CREATE_PAGEFILE_NAME = 'SeCreatePagefilePrivilege';
  SE_CREATE_PERMANENT_NAME = 'SeCreatePermanentPrivilege';
  SE_BACKUP_NAME = 'SeBackupPrivilege';
  SE_RESTORE_NAME = 'SeRestorePrivilege';
  SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';
  SE_DEBUG_NAME = 'SeDebugPrivilege';
  SE_AUDIT_NAME = 'SeAuditPrivilege';
  SE_SYSTEM_ENVIRONMENT_NAME = 'SeSystemEnvironmentPrivilege';
  SE_CHANGE_NOTIFY_NAME = 'SeChangeNotifyPrivilege';
  SE_REMOTE_SHUTDOWN_NAME = 'SeRemoteShutdownPrivilege';
  SE_UNDOCK_NAME = 'SeUndockPrivilege';
  SE_SYNC_AGENT_NAME = 'SeSyncAgentPrivilege';
  SE_ENABLE_DELEGATION_NAME = 'SeEnableDelegationPrivilege';
  SE_MANAGE_VOLUME_NAME = 'SeManageVolumePrivilege';

  AURL_ENABLEURL = 1;
  AURL_ENABLEEMAILADDR = 2;
  AURL_ENABLETELNO = 4;
  AURL_ENABLEEAURLS = 8;
  AURL_ENABLEDRIVELETTERS = 16;
  AURL_DISABLEMIXEDLGC = 32;

  SC_DRAGMOVE: Longint = $F012;

  NumberSCS: TSysCharSet =['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  RUSsymbSCS: TSysCharSet =['А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ё', 'Ж', 'З', 'И',
    'Й', 'К', 'Л', 'М', 'Н', 'О', 'П', 'Р', 'С', 'Т', 'У', 'Ф', 'Х', 'Ц', 'Ч',
    'Ш', 'Щ', 'Ъ', 'Ы', 'Ь', 'Э', 'Ю', 'Я', 'а', 'б', 'в', 'г', 'д', 'е', 'ё',
    'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф',
    'х', 'ц', 'ч', 'ш', 'щ', 'ъ', 'ы', 'ь', 'э', 'ю', 'я'];
  //A  65
  //Z  90
  //a  97
  //z 122
  SymbForWords: TSysCharSet = ['0'..'9','a' .. 'z','а', 'б', 'в', 'г', 'д',
    'е', 'ё', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т',
    'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ъ', 'ы', 'ь', 'э', 'ю', 'я', #32, #10, #13,'-'];
  RUSchars: array[0 .. 65]of char =('А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ё', 'Ж', 'З',
    'И', 'Й', 'К', 'Л', 'М', 'Н', 'О', 'П', 'Р', 'С', 'Т', 'У', 'Ф', 'Х', 'Ц',
    'Ч', 'Ш', 'Щ', 'Ъ', 'Ы', 'Ь', 'Э', 'Ю', 'Я', 'а', 'б', 'в', 'г', 'д', 'е',
    'ё', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у',
    'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ъ', 'ы', 'ь', 'э', 'ю', 'я');
  RUSsymb: array[0 .. 65]of ansichar =('А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ё', 'Ж',
    'З', 'И', 'Й', 'К', 'Л', 'М', 'Н', 'О', 'П', 'Р', 'С', 'Т', 'У', 'Ф', 'Х',
    'Ц', 'Ч', 'Ш', 'Щ', 'Ъ', 'Ы', 'Ь', 'Э', 'Ю', 'Я', 'а', 'б', 'в', 'г', 'д',
    'е', 'ё', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т',
    'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ъ', 'ы', 'ь', 'э', 'ю', 'я');
  HTMLsymb: array[0 .. 65]of string =('&#1040;', '&#1041;', '&#1042;',
    '&#1043;', '&#1044;', '&#1045;', '&#1025;', '&#1046;', '&#1047;', '&#1048;',
    '&#1049;', '&#1050;', '&#1051;', '&#1052;', '&#1053;', '&#1054;', '&#1055;',
    '&#1056;', '&#1057;', '&#1058;', '&#1059;', '&#1060;', '&#1061;', '&#1062;',
    '&#1063;', '&#1064;', '&#1065;', '&#1066;', '&#1067;', '&#1068;', '&#1069;',
    '&#1070;', '&#1071;', '&#1072;', '&#1073;', '&#1074;', '&#1075;', '&#1076;',
    '&#1077;', '&#1105;', '&#1078;', '&#1079;', '&#1080;', '&#1081;', '&#1082;',
    '&#1083;', '&#1084;', '&#1085;', '&#1086;', '&#1087;', '&#1088;', '&#1089;',
    '&#1090;', '&#1091;', '&#1092;', '&#1093;', '&#1094;', '&#1095;', '&#1096;',
    '&#1097;', '&#1098;', '&#1099;', '&#1100;', '&#1101;', '&#1102;',
    '&#1103;');
  JSSymb: array[0 .. 65]of string =('\u0410', '\u0411', '\u0412', '\u0413',
    '\u0414', '\u0415', '\u0401', '\u0416', '\u0417', '\u0418', '\u0419',
    '\u041A', '\u041B', '\u041C', '\u041D', '\u041E', '\u041F', '\u0420',
    '\u0421', '\u0422', '\u0423', '\u0424', '\u0425', '\u0426', '\u0427',
    '\u0428', '\u0429', '\u042A', '\u042B', '\u042C', '\u042D', '\u042E',
    '\u042F', '\u0430', '\u0431', '\u0432', '\u0433', '\u0434', '\u0435',
    '\u0451', '\u0436', '\u0437', '\u0438', '\u0439', '\u043A', '\u043B',
    '\u043C', '\u043D', '\u043E', '\u043F', '\u0440', '\u0441', '\u0442',
    '\u0443', '\u0444', '\u0445', '\u0446', '\u0447', '\u0448', '\u0449',
    '\u044A', '\u044B', '\u044C', '\u044D', '\u044E', '\u044F');
  DelimiterChars: TSysCharSet =[#1 .. #255]-['a' .. 'z', 'A' .. 'Z', '1' .. '9',
    '0', 'а' .. 'я', 'А' .. 'Я'];//#0 не нужен
  //-- а можно при инициализации получить строку из разделителей
  NormCharsA: PAnsiChar =
  //!!!! если не включать латинские символы, то на проверке правописания слова с этими символами не анализируются (типа, разделители идут)
    'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюяABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  NormCharsW: PChar = 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюяABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  RusCharsW : PChar = 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя';

  boolRus: array[boolean]of string =('Нет', 'Да');
  boolEng: array[boolean]of string =('No', 'Yes');
  boolJS: array[boolean]of string =('false', 'true');
  dwShort: array[1 .. 7]of string =('Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс');
  OfMonth : array[1..12] of string =   ('января',
                                        'февраля',
                                        'марта',
                                        'апреля',
                                        'мая',
                                        'июня',
                                        'июля',
                                        'августа',
                                        'сентября',
                                        'октября',
                                        'ноября',
                                        'декабря');
  // -- см. также
  // IdGlobalProtocols.wdays; // -- дни недели короткие нелокализованные
  // IdGlobalProtocols.monthnames // -- месяцы короткие нелокализованные


 // -- для IS_INTRESOURCE, EnumIcon,EnumRes,GetIcon
        // ms-help://embarcadero.rs_xe/DllProc/base/loadlibraryex.htm
   DONT_RESOLVE_DLL_REFERENCES        = $01;//0x00000001 If this value is used, and the executable module is a DLL, the system does not call DllMain for process and thread initialization and termination. Also, the system does not load additional executable modules that are referenced by the specified module.
   LOAD_IGNORE_CODE_AUTHZ_LEVEL       = $10;//0x00000010 If this value is used, the system does not perform automatic trust comparisons on the DLL or its dependents when they are loaded.
   LOAD_LIBRARY_AS_DATAFILE           = $02;//0x00000002 If this value is used, the system maps the file into the calling process's virtual address space as if it were a data file. Nothing is done to execute or prepare to execute the mapped file. Therefore, you cannot call functions like GetModuleHandle or GetProcAddress with this DLL. Using this value causes writes to read-only memory to raise an access violation. Use this flag when you want to load a DLL only to extract messages or resources from it.
   LOAD_LIBRARY_AS_DATAFILE_EXCLUSIVE = $40;//0x00000040 Similar to LOAD_LIBRARY_AS_DATAFILE, except that the DLL file on the disk is opened for exclusive write access. Therefore, other processes cannot open the DLL file for write access while it is in use. However, the DLL can still be opened by other processes.
   LOAD_LIBRARY_AS_IMAGE_RESOURCE     = $20;//0x00000020 If this value is used, the system maps the file into the process's virtual address space as an image file. However, the loader does not load the static imports or perform the other usual initialization steps. Use this flag when you want to load a DLL only to extract messages or resources from it.
   LOAD_WITH_ALTERED_SEARCH_PATH      = $08;//0x00000008

 //  -- GetUsernameEx
  NameUnknown            = 0;
  NameFullyQualifiedDN   = 1;
  NameSamCompatible      = 2;
  NameDisplay            = 3;
  NameUniqueId           = 6;
  NameCanonical          = 7;
  NameUserPrincipal      = 8;
  NameCanonicalEx        = 9;
  NameServicePrincipal   = 10;
  NameDnsDomain          = 12;

 // -- Ping
 pingErrorWSA      = -1;
 pingErrorSendEcho = -2;
 pingErrorTimeOut  = -3;// IP_REQ_TIMED_OUT
 pingError         = -4;

 IP_STATUS_BASE                  = 11000 ;
 IP_SUCCESS                      = 0     ;
 IP_BUF_TOO_SMALL                = 11001 ;
 IP_DEST_NET_UNREACHABLE         = 11002 ;
 IP_DEST_HOST_UNREACHABLE        = 11003 ;
 IP_DEST_PROT_UNREACHABLE        = 11004 ;
 IP_DEST_PORT_UNREACHABLE        = 11005 ;
 IP_NO_RESOURCES                 = 11006 ;
 IP_BAD_OPTION                   = 11007 ;
 IP_HW_ERROR                     = 11008 ;
 IP_PACKET_TOO_BIG               = 11009 ;
 IP_REQ_TIMED_OUT                = 11010 ;
 IP_BAD_REQ                      = 11011 ;
 IP_BAD_ROUTE                    = 11012 ;
 IP_TTL_EXPIRED_TRANSIT          = 11013 ;
 IP_TTL_EXPIRED_REASSEM          = 11014 ;
 IP_PARAM_PROBLEM                = 11015 ;
 IP_SOURCE_QUENCH                = 11016 ;
 IP_OPTION_TOO_BIG               = 11017 ;
 IP_BAD_DESTINATION              = 11018 ;
 IP_ADDR_DELETED                 = 11019 ;
 IP_SPEC_MTU_CHANGE              = 11020 ;
 IP_MTU_CHANGE                   = 11021 ;
 IP_UNLOAD                       = 11022 ;
 IP_GENERAL_FAILURE              = 11050 ;
 MAX_IP_STATUS                   = IP_GENERAL_FAILURE ;
 IP_PENDING                      = 11255 ;

 Divider_KB = 1024;
 Divider_MB = Divider_KB *1024;
 Divider_GB = Divider_MB *1024;

 WM_TEXTMESSAGE1  = WM_APP + $0FA0;
 WM_TEXTMESSAGE2  = WM_APP + $0FA1;

 MB_ICONAPPLICATION = $00000100;


type
  THackCustomTabControl = class(TCustomTabControl);
  THackWinControl = class(TWinControl);
  THackControl = class(TControl);
  THackGraphicControl = class(TGraphicControl);
  THackCustomListBox = class(TCustomListBox);
  THackHTTP = class(TIdHTTP); // -- for access to methods of the TIdCustomHTTP
  //-- для работы с TSpeedButton (получение Handle по Canvas.Handle)
  THackDrawGrid = class(TDrawGrid);
  THackCustomGrid = class(TCustomGrid);

//  TIntArr = array of integer;
//  TArrayOfInteger = TIntArr;

  PWndDescr =^TWndDescr;

  TWndDescr = record
    Handle: cardinal;
    ClassName: array[0 .. 255]of char;
    WndText: array[0 .. 255]of char;
    FileName: array[0 .. MAX_PATH_EX + 1]of char;
    Parent: cardinal;
  end;

  PWndDescrs =^TWndDescrs;
  TWndDescrs = array of TWndDescr;

  TWndDescrsEx = record
    Items: array of TWndDescr;
    function Fill(aParent : cardinal; aWithClear : boolean) : integer; overload;
    function Add(aWD: TWndDescr): integer;
    function FindWnd(const aText:string): integer; overload;//text or classname
    function FindWnd(aWnd: cardinal): integer; overload;
    procedure Delete(Index : integer);
    procedure Clear;
  end;

  TSplashType =(stNone, stInfo, stOk, stWarning, stError, stToast);
  TTriangleOrderBaseColor =(ttobcGray, ttobcRed, ttobcGreen, ttobcBlue, ttobcYellow);

  TSimpleSplash = class(TForm)
  private
    FSplashType: TSplashType;
    FSplashMessage:string;
    fShowTime : TDateTime;
    fMainColor : TColor;
    fFontColor : TColor;
    procedure SetSplashType(Value: TSplashType);
    procedure SetSplashCaption(const Value:string);
    procedure OnCloseSplash(Sender:TObject; var Action:TCloseAction);
    procedure WMTimer(var msg : TWMTimer); message WM_TIMER;
  protected
    procedure Paint; override;
  public
    constructor CreateSplash(AOwner: TComponent;const aSplashMessage:string;aSplashType: TSplashType); overload;
    constructor CreateSplash(AOwner: TComponent;const aSplashMessage:string; clrMain,clrFont: TColor); overload;
  published
    property SplashType: TSplashType read FSplashType write SetSplashType;
    property SplashMsg:string write SetSplashCaption;
    property MainColor : TColor read fMainColor write fMainColor;
    property FontColor : TColor read fFontColor write fFontColor;

  end;

  TXMLForm = class(TForm)
    _TV: TTreeView;
    _SpBT: TSpeedButton;
    _SpBX: TSpeedButton;
    _SpBC: TSpeedButton;
    _SpBL: TSpeedButton;
    Btn: TButton;
    procedure ProcessTreeViewText(Sender: TObject);
  private
    SourceXMLFile:string;
    SourceXMLText:string;
  end;

  TTVForm = class(TForm)
    TV: TTreeView;
    Btn: TButton;
    BtnCopy: TButton;
    BtnSave: TButton;
    procedure BtnCopyClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
  private
    ValueText:string;
  end;

  TRGForm = class(TForm)
    RG: TRadioGroup;
    ChB: TCheckBox;
    Btn: TButton;
  private
    procedure RGFormResize(Sender: TObject);
  end;



  PVariantArrayD2 =^TVariantArrayD2;
  TVariantArrayD2 = array of array of variant;
  TStringArrayD2 = array of array of string;

  //: см. NumberByWord
  TDefUnits =(dfNone,//пусто
    dfRuble,//рубли
    dfKop,//копейки
    dfUSD,//доллары США
    dfYear(*как возраст*), dfWeek, dfMonth, dfDay,//дни
    dfHour, dfMinute, dfSecond, dfFile, dfFileIn, dfSymbol, dfPart, dfByte, dfRecords,dfOrder, dfTest
     );

  TDefEnding =(deOne,deTwo,deThree);//склонения (малина, кот, сирень)

  PFileVersion =^TFileVersion;

  TFileVersion = packed record
    aVS_FIXEDFILEINFO: VS_FIXEDFILEINFO;
    InternalName: array[0 .. 2047]of char;//'InternalName'
    FileVersion: array[0 .. 2047]of char;//'FileVersion'
    FileDescription: array[0 .. 2047]of char;//'FileDescription'
    Comments: array[0 .. 2047]of char;//'Comments'
    CompanyName: array[0 .. 2047]of char;//'CompanyName'
    ProgramVendor: array[0 .. 2047]of char;//'CompanyName'
    LegalCopyright: array[0 .. 2047]of char;//'LegalCopyright'
    LegalTradeMarks: array[0 .. 2047]of char;//'LegalTradeMarks'
    OriginalFilename: array[0 .. 2047]of char;//'OriginalFilename'
    ProductVersion: array[0 .. 2047]of char;//'ProductVersio'
    ProductName: array[0 .. 2047]of char;//' ProductName'
    LangName: array[0 .. 2047]of char;
    CodePageName: array[0 .. 2047]of char;
    CodePageID: array[0 .. 7]of char;
    LanguageID: array[0 .. 7]of char;
  end;

  TSetLayeredWindowAttributes = function(hWindow: HWND; crKey: DWORD;
    bAlpha: Byte; dwFlags: DWORD): BOOL; stdcall;

  TaPInAddr = array[0 .. 10]of PInAddr;
  PaPInAddr =^TaPInAddr;

  TTabSheetInfo = record
    TabSheetname:string[255];
    TabSheetIndex: integer;
  end;

  RGBArray = array[0 .. 2]of Byte;

  PFileDate =^TFileDates;
  TFileDates = record
    DateCreate: TDateTime;
    DateOpen: TDateTime;
    DateWrite: TDateTime;
  end;

  PDatesIntervalItem =^TDatesIntervalItem;

  TDatesIntervalItem = record
    DateBegin: TDateTime;
    DateEnd: TDateTime;
    IsOn: boolean;
    function DateInDTI(aDateTime: TDateTime; aIncludeLimits: boolean = true): boolean;
    function GetXML:string;
    procedure SetDateTime(aIsBegin: boolean);
  end;

  PDatesIntervalList =^TDatesIntervalList;
  TDatesIntervalList = array of TDatesIntervalItem;

  TPicType =(ptNotImage = 0, ptBitmap = 1, ptICO = 2, ptJPG = 3, ptPNG = 4,
    ptGIF = 5, ptTIFF = 6, ptWMF = 7);
  const
  pngBackColor : TColor = clFuchsia;
  PicExt        : array[TPicType] of string = ('','.BMP','.ICO','.JPG','.PNG','.GIF','.TIF','.WMF');
  PicDataBase64 : array[TPicType] of string = ('','data:image/bmp;base64,','data:image/ico;base64,','data:image/jpeg;base64,','data:image/png;base64,','data:image/gif;base64,','data:image/tiff;base64,','data:image/wmf;base64,');
  PicFilter     : string =
            //'Все изображения|*.bmp;*.dib;*.jpg;*jpe;*jpeg;*.ico;*.emf;*.wmf;*.dcm;*.tiff;*.tif;*.cri|'+
            'JPEGs(*.jp*)|*.jp*|'+
            'PNGs(*.png)|*.png|'+
            'Bitmap(*.bmp)|*.bmp|'+
            'Icons (*.ico)|*.ico|'+
            'Enhanced Metafiles (*.emf)|*.emf|'+
            'Metafiles (*.wmf)|*.wmf|'+
            //'DICOM files(*.dcm)|*.dcm|'+
            'TIFF files (*.tiff;*.tif;*.cri)|*.tiff;*.tif;*.cri|'+
            'Все изображения|*.jp*;*.png;*.bmp;*.dib;*.ico;*.emf;*.wmf;*.tiff;*.tif;*.cri|'+
            'Все файлы(*.*)|*.*';
  ExcelFilter     : string =
            //'Все изображения|*.bmp;*.dib;*.jpg;*jpe;*jpeg;*.ico;*.emf;*.wmf;*.dcm;*.tiff;*.tif;*.cri|'+
            'Excel(*.xl*)|*.xl*|'+
            'CSV(*.csv)|*.csv|'+
            'Все файлы(*.*)|*.*';
  type
  TlclDataType = record
    ext     : string[64];
    datatype: string[128];
    pictype : TPicType;
  end;
  const//-- а можно загрузить доступные типы данных.....
  extList: array[0 .. 5]of TlclDataType =(
    (ext: '.GIF' ; datatype: 'image/gif'; pictype: ptGIF),
    (ext: '.PNG' ; datatype: 'image/png'; pictype: ptPNG),      //image/png, image/x-png
    (ext: '.JPEG'; datatype: 'image/jpg'; pictype: ptJPG),      //application/soundpix, image/jpeg, image/jpeg; image/spj, image/jpeg-x, image/jpg
    (ext: '.JPG' ; datatype: 'image/jpg'; pictype: ptJPG),      //application/soundpix, image/jpeg, image/jpeg; image/spj, image/jpeg-x, image/jpg
    (ext: '.JFIF'; datatype: 'image/jpg'; pictype: ptJPG),      // image/jpeg, image/pjpeg
    (ext: '.BMP' ; datatype: 'image/bmp'; pictype: ptBitmap)    //image/bitmap, image/bmp, image/x-bmp, image/x-ms-bmp
    );



  type
 // TIntegerArray = array of integer;

  TGradientFigure =(
      gfRectangle     = 0
    , gfRoundRect     = 1
    , gfStar2         = 2
    , gfStar3         = 3
    , gfStar4         = 4//!!! важно - используется для определения кол-ва точек
    , gfStar5         = 5// *
    , gfStar6         = 6// *
    , gfStar7         = 7// *
    , gfStar8         = 8// *
    , gfStar9         = 9// *
    , gfStar10        = 10// * , но больше смысла делать нет
    , gfEllipse       = 11
    , gfTriangleLeft  = 12//30
    , gfTriangleUp    = 13//31
    , gfTriangleRight = 14//32
    , gfTriangleDown  = 15//33
    , gfDiamond4      = 16//44
    );

  P3b =^T3b;
  T3b = array[0 .. 2]of Byte;

  TShapeEye = class(TShape)
  protected
    procedure Paint; override;
  end;

  TPswForm = class(TForm)
    procedure ShapeEnter(Sender: TObject);
    procedure ShapeLeave(Sender: TObject);
    private
     procedure OutStopHandler(var aMsg : TMessage); message WM_APP+$00A9;
  end;

  TNotifyForm = class(TForm)
    procedure NFShow(Sender: TObject);
    procedure NFRepaint(Sender: TObject);
    procedure NFKeyUp(Sender: TObject;var Key: Word; Shift: TShiftState);
    procedure NFMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure NFMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure NFClick(Sender: TObject);
    procedure NFClose(Sender: TObject;var Action: TCloseAction);
  public
    ctl3Ddraw  : boolean;
    strTitle   : shortstring;
    strMessage : string;
    bmp        : TBitmap;
  private
    rgn        : hRGN;
    rctTitle   : TRect;
    rctMessage : TRect;
    rctClose   : TRect;
    Extent     : boolean;
    rctOk      : TRect;
    rctCancel  : TRect;
    procedure Prepare;
    procedure WMSetFocus(var aMsg: TMessage); message WM_SETFOCUS;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  published
    constructor CreateWithParams(AOwner: TComponent;const aTitle: shortstring; const aMessage:string);//; aExtention : boolean);
    destructor Destroy; override;
  end;

  


  TQueryForm = class(TForm)
    Edit: TEdit;
    procedure QFRepaint(Sender: TObject);
    procedure QFKeyUp(Sender: TObject;var Key: Word; Shift: TShiftState);
    procedure QFMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure QFMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure QFClick(Sender: TObject);
    procedure QFClose(Sender: TObject;var Action: TCloseAction);


  public
    ctl3Ddraw: boolean;
    strTitle:string;
    strPrompt:string;
    bmp: TBitmap;
  private
    rgn: hRGN;
    rctTitle: TRect;
    rctPrompt: TRect;
    rctClose: TRect;
    rctOk: TRect;
    rctCancel: TRect;
    procedure Prepare(aWithBackGnd : boolean);
    procedure WMSetFocus(var aMsg: TMessage); message WM_SETFOCUS;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  published
    constructor CreateWithParams(AOwner: TComponent; const aTitle, aPrompt:string;var aText:string; aWithBackGnd : boolean);
    destructor Destroy; override;
  end;

  (******************************************************************************)
  PMenuFormItem =^TMenuFormItem;
  TMenuForm = class;

  TMenuFormEvent = procedure(pItem: PMenuFormItem)of object;

  TMenuFormItem = record
    Caption: array[1 .. 128]of char;
    Proc: TNotifyEvent;
    Rect: TRect;
    //-- а это, так, признак....
    Checked: boolean;
    //-- если заполнено, то применять (?) типа, ('Переключить на: УЖЕ сделано','Переключить на: НАДО сделать')
    ChkCaptions: array[boolean]of array[1 .. 128]of char;
    Data: Pointer;
    case ctl3D: boolean of
      false:
        (PenColor: TColor;
          BrushColor: TColor;
          FontColor: TColor);
      true:
        (Figure: TGradientFigure;
          BaseColor: TColor;
          TextColor: TColor);
  end;

  PMenuFormList =^TMenuFormList;
  TMenuFormList = array of TMenuFormItem;

  PMenuFormItemObject =^TMenuFormItemObject;

  TMenuFormItemObject = class(TObject)
    Item: TMenuFormItem;
  end;

  TMenuForm = class(TForm)
    procedure MFRepaint(Sender: TObject);
    procedure MFShowIn(aPoint: TPoint);
    procedure MFKeyUp(Sender: TObject;var Key: Word; Shift: TShiftState);
    procedure MFMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure MFMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure MFClick(Sender: TObject);
    procedure MFClose(Sender: TObject;var Action: TCloseAction);
  public
    //-- можно зарегистрировать Окно и Сообщение для работы при отсутствии процедур в списке Items
    ctl3Ddraw: boolean;
    Items: TMenuFormList;
    bmp: TBitmap;
  private
    inClick: boolean;
    BasePoint: TPoint;
    rgn: hRGN;
    rctTitle: TRect;
    rctClose: TRect;
    NeedFreeOnClose: boolean;
    procedure Prepare;
    procedure WMSetFocus(var aMsg: TMessage); message WM_SETFOCUS;
    ///procedure CMMouseLeave(var aMsg : TMessage); message CM_MOUSELEAVE;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  published
    constructor CreateWithParams(AOwner: TComponent;const aItems: TMenuFormList;
      aNeedFreeOnClose: boolean = true);
    destructor Destroy; override;
  end;

  (******************************************************************************)
Type
  TTone =//-- приводить к word при использовании
    (REST = 0, GbelowC = 196, A = 220, Asharp = 233, B = 247, C = 262,
    Csharp = 277, D = 294, Dsharp = 311, E = 330, F = 349, Fsharp = 370,
    G = 392, Gsharp = 415);

Type
  TDuration =//-- приводить к word при использовании
    (WHOLE = 1600, HALF = WHOLE div 2, QUARTER = HALF div 2,
    EIGHTH = QUARTER div 2, SIXTEENTH = EIGHTH div 2);

type
  PBeepItem =^TBeepItem;

  TBeepItem = record
    Frequency: Word;
    Duration: Word;
  end;

  PBeepSequence =^TBeepSequence;

  TBeepSequence = record
    Items: array of TBeepItem;
    NeedStop: boolean;
    procedure Load(const aINIFileName, aSection:string);
    function Add(afreq, aDur: Word; aIndex: integer =-1): integer;
    procedure Play(aReverse: boolean = false);
    procedure Stop;
    procedure Clear;
  end;

  TDatePart =(ddYear,//yy,yyyy Year
    ddQuart,//qq, q      Quarter
    ddMonth,//mm, m      Month
    ddDayOfWeek,//
    ddDayOfYear,//dy, y      DayOfYear
    ddDay,//dd, d      Day
    ddWeek,//wk, ww     Week
    ddHour,//hh,        Hour
    ddMinute,//mi, n      Minute
    ddSecond,//ss, s      Second
    ddMSecond);//ms     MilliSecond

type//см HandlerFileMapping, CopyFileNT, CopyFileNTMulti
  PShFileMapping =^TShFileMapping;

  TShFileMapping = record
    FromFileName: array[1 .. MAX_PATH]of char;
    IntoFileName: array[1 .. MAX_PATH]of char;
  end;

  PShFileMappingList =^TShFileMappingList;
  TShFileMappingList = array of TShFileMapping;

  (******************************************************************************)

type
  PWordCharRange =^TWordCharRange;
  TWordCharRange = record
    Min: Word;
    Max: Word;
  end;

  PDWordCharRange =^TDWordCharRange;
  TDWordCharRange = record
    Min: DWord;
    Max: DWord;
  end;


  PLongWordCharRange =^TLongWordCharRange;
  TLongWordCharRange = record
    Min: LongWord;
    Max: LongWord;
  end;


  TFontRange = record
    FontName:string[64];
    Ranges: array of TWordCharRange;
    procedure Fill(const aFontName:string);
    function CharExists(aChar: Word): boolean; overload;
    function CharExists(aChar: widechar): boolean; overload;
    procedure Clear;
  end;


  POSObjectItem = ^TOSObjectItem ;
  TOSObjectItem = record
   OSObject : array[1..MAX_PATH] of char;
   Index    : integer;
  end;

  POSObjectList = ^TOSObjectList;
  TOSObjectList = array of TOSObjectItem;

  TNamedImageList = class(TImageList)
   private
     OSobjects : TOSObjectList;
   public
     constructor Create(AOwner: TComponent); override;
     destructor Destroy; override;
     function IndexOf(const aOSObject : string) : integer;
     function PictureIndexOf(const aOSObject : string) : integer;
     function Add(const aOSObject : string; out aImageIndex : integer) : integer;
     function AddFromImageList(const aName : string; aImageList : TImageList; aIndex : integer; out aImageIndex : integer) : integer;
  end;

  TLVFColumnItem = record
   Caption   : string[50];
   Width     : integer;
   Alignment : TAlignment;
  end;

  TLVFColumnList = record
    Items : array of TLVFColumnItem;
  end;


  TListViewFiles = class(TListView)
    LabInfoSize: TLabel;
    ILIcons: TNamedImageList;
  private
    procedure WM_DROPFILES_Handler(var aMsg: TMessage); message WM_DROPFILES;
    procedure WM_CONTEXT_Handler(var aMsg: TMessage); message WM_CONTEXTMENU;
    procedure WM_DBLCLICK_Handler(var aMsg: TMessage); message WM_LBUTTONDBLCLK;
    procedure WM_KEYUP_Handler(var aMsg: TMessage); message WM_KEYUP;
  public
    procedure CalcCommonSize;
    procedure RefreshImageList(aClearImages : boolean = true);
    function AddFiles(const aFiles: TStringDynArray): integer;
    function UpdateItem(aIndex : integer; const aFileName : string) : boolean;
    function ColumnIndex(const aColumnCaption : string) : integer;
    function IndexOf_Caption(const aCaption : string) : integer;
    function RemoveByCaption(const aCaption : string) : integer;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;


  type

  Pip_option_information = ^Tip_option_information;
  Tip_option_information = packed record   // Информация заголовка IP (Наполнение этой структуры и формат полей описан в RFC791.
    Ttl         : byte;	 	        // Время жизни (используется traceroute-ом)
    Tos         : byte;	 	        // Тип обслуживания, обычно 0
    Flags       : byte;		        // Флаги заголовка IP, обычно 0
    OptionsSize : byte;		        // Размер данных в заголовке, обычно 0, максимум 40
    OptionsData : Pointer;	        // Указатель на данные
 end;

 Picmp_echo_reply = ^Ticmp_echo_reply;
 Ticmp_echo_reply = packed record
    Address  : u_long; 	    	        // Адрес отвечающего
    Status   : u_long;	    	        // IP_STATUS (см. ниже)
    RTTime   : u_long;	    	        // Время между эхо-запросом и эхо-ответом в миллисекундах
    DataSize : u_short; 	    	// Размер возвращенных данных
    Reserved : u_short; 	    	// Зарезервировано
    Data     : Pointer;       	        // Указатель на возвращенные данные
    Options  : Tip_option_information;   // Информация из заголовка IP
 end;
 PIPINFO = ^Tip_option_information;
 PVOID = Pointer;

 PAdapterStatus = ^TAdapterStatus;
 TAdapterStatus = record
    adapter_address : array [0..5] of char;
    filler          : array [1..4 * SizeOf(char) + 19 * SizeOf(Word) + 3 * SizeOf(DWORD)] of  Byte;
 end;

  TMemInfoMode = (
    mimPageFile = 0
   ,mimPageFileMax = 1
   ,mimWorkSet = 2
   ,mimWorkSetMax = 3
  );

  TSingleStruct = record
  case boolean of
    false : (float : single);
    true  : (int   : integer);
  end;
  TDoubleStruct = record
  case boolean of
    false : (float : double);
    true  : (int   : integer);
  end;
  TExtendedStruct = record
  case boolean of
    false : (float : extended);
    true  : (int   : int64);
  end;

  TPhoneNumberCountry = (
     pncUnknown = 0
    ,pncRU      = 1
    ,pncKrym    = 2
    ,pncBY      = 3
    ,pncKZ      = 4
    ,pncMobile  = 5
  );

 PMessageBoxItem = ^TMessageBoxItem;
 TMessageBoxItem = packed record
  wnd      : cardinal;
  Caption  : string[250];
 end;
 PMessageBoxList = ^TMessageBoxList;
 TMessageBoxList = array of TMessageBoxItem;

 // -- for ArrayVariantToExcelByCells functions
 TExcelCellLink = (eclFile, eclFolder, eclFolderOne, eclURL);
 TExcelCellLinkSet = set of TExcelCellLink;

 PFolderTreeItem = ^TFolderTreeItem;
 TFolderTreeItem = record
  folder : array[1..2048] of char;
  level  : integer;
 end;

 TFolderTreeList = record
  Items : array of TFolderTreeItem;
  function Fill(const aBaseFolder : string) : integer;
  function GetTreeText : string;
  function FillTreeView(aTV : TTreeView; aShortname : boolean) : boolean;
  procedure Clear;
 end;

 PParentProcessItem = ^TParentProcessItem;
 TParentProcessItem = record
  pid : cardinal;
  path : array[1..MAX_PATH] of char;
 end;

 PParentProcessList = ^TParentProcessList;
 TParentProcessList = record
  pid   : cardinal;
  Items : array of TParentProcessItem;
  function FillFor(aPID : cardinal) : boolean;
  function Clear : boolean;
 end;

 type
  PRocessWindowItem = ^TProcessWindowItem;
  TProcessWindowItem = record
    handle : cardinal;
    parent : cardinal;
    pid    : cardinal;
  end;

  PProcessWindowList = ^TProcessWindowList;
  TProcessWindowList = record
    Items : array of TProcessWindowItem;
    function Fill  : boolean;
    function About(aPID : cardinal; var aStr : string)  :integer;
    function Clear : boolean;
  end;

  PProcessItem =^TProcessItem;
  TProcessItem = record
    path      : array[0..MAX_PATH-1] of char;
    selfpid   : cardinal;
    mainwnd   : cardinal;
    parentpid : cardinal;
  end;

  PProcessList = ^TProcessList;
  TProcessList = record
    Items              : array of TProcessItem;
    ProcessWindowList  : TProcessWindowList;
    function GetIndex(aPID : cardinal) : integer;
    function Add(aPID : cardinal; const aModuleNameOnly : string; aParentPID : cardinal) : integer; overload;
    function Add(aPID : cardinal; aParentPID : cardinal) : integer; overload;
    function Fill(aParent : cardinal = 0) : boolean; overload;
    function Fill(const EXEName : string; aParent : cardinal = 0) : boolean; overload;
    function Clear : boolean;
  end;

  type
  PDriveItem = ^TDriveItem;
  TDriveItem = record
    DriveLetter     : string[1];
    VolumeName      : string[128];
    ShareName       : string[255];
    RootFolder      : string[32];
    DriverType      : byte; // drvTypes : array[0..5] of string = ('Unknown','Removable','Fixed','Network','CD-ROM','RAM Disk');
    TotalSize       : uint64;
    FreeSpace       : uint64;
    AvailableSpace  : uint64;
  end;

  TDriveList = record
    Items : array of TDriveItem;
    function Fill     : integer;
    function ToString : string;
    function Clear    : boolean;
  end;

  TRTTIDopInfo = record
    RealName        : ShortString;
    Visibility      : TMemberVisibility;
    UnitName        : ShortString;
    ParentClassName : ShortString;
  end;

  TRTTIDopInfoList = array of TRTTIDopInfo;

  (*work with ZIP*)
  type
   PZipFolderObject = ^TZipFolderObject;
   TZipFolderObject = packed record
     IsFolder : longbool;//boolean;    //    4 bytes
     Name     : array[1..510] of char; // 1020 bytes
   end;
   PZipFolderObjectList = ^TZipFolderObjectList;
   TZipFolderObjectList = array of TZipFolderObject;

   PPointDynArray = ^TPointDynArray;
   TPointDynArray = array of TPoint;

   TPercent = 0..100;

   TLangEngRus = (lerEng, lerRus);

   TEngRusPairs = array of array[TLangEngRus] of string;

   //https://www.scp-garant.ru/service/news/razreshenie_jekranov_sootnoshenie_storon/
   TAspect = record
     Name : string[24];
     Width : integer;
     Height : integer;
     Aspect : string[16];
   end;

   const MonitorAspectRatio : array[0..40] of TAspect =(
//      (Name:'CGA' 	             ;Width:320   ;Height:200  ;Aspect:'16:10'),
//      (Name:'EGA' 	             ;Width:640   ;Height:350  ;Aspect:'11:6'),
//      (Name:'VGA' 	             ;Width:640   ;Height:480  ;Aspect:'4:3'),

      (Name:'QVGA' 	             ;Width:320   ;Height:240  ;Aspect:'4:3'),
      (Name:'HVGA' 	             ;Width:320   ;Height:480  ;Aspect:'2:3'),
      (Name:'SIF(MPEG1 SIF)' 	   ;Width:352   ;Height:240  ;Aspect:'22:15'),
      (Name:'CIF(MPEG1 VideoCD)' ;Width:352   ;Height:288  ;Aspect:'11:9'),
      (Name:'WQVGA' 	           ;Width:400   ;Height:240  ;Aspect:'5:3'),
      (Name:'[MPEG2 SV-CD]' 	   ;Width:576   ;Height:480  ;Aspect:'12:10'),
      (Name:'HVGA' 	             ;Width:640   ;Height:240  ;Aspect:'8:3'),
      (Name:'nHD' 	             ;Width:640   ;Height:360  ;Aspect:'16:9'),
      (Name:'VGA' 	             ;Width:640   ;Height:480  ;Aspect:'4:3'),
      (Name:'WVGA' 	             ;Width:800   ;Height:480  ;Aspect:'5:3'),
      (Name:'SVGA' 	             ;Width:800   ;Height:600  ;Aspect:'4:3'),
      (Name:'FWVGA' 	           ;Width:854   ;Height:480  ;Aspect:'427:240'),
      (Name:'WSVGA' 	           ;Width:1024  ;Height:600  ;Aspect:'128:75'),
      (Name:'XGA' 	             ;Width:1024  ;Height:768  ;Aspect:'4:3'),
      (Name:'XGA+' 	             ;Width:1152  ;Height:864  ;Aspect:'4:3'),
      (Name:'WXVGA' 	           ;Width:1200  ;Height:600  ;Aspect:'2:1'),
      (Name:'WXGA' 	             ;Width:1280  ;Height:768  ;Aspect:'5:3'),
      (Name:'SXGA' 	             ;Width:1280  ;Height:1024 ;Aspect:'5:4'),
      (Name:'WXGA+' 	           ;Width:1440  ;Height:900  ;Aspect:'16:10'),
      (Name:'SXGA+' 	           ;Width:1400  ;Height:1050 ;Aspect:'4:3'),
      (Name:'XJXGA' 	           ;Width:1536  ;Height:960  ;Aspect:'16:10'),
      (Name:'WSXGA (x)' 	       ;Width:1536  ;Height:1024 ;Aspect:'3:2'),
      (Name:'WXGA++' 	           ;Width:1600  ;Height:900  ;Aspect:'16:9'),
      (Name:'WSXGA'	             ;Width:1600  ;Height:1024 ;Aspect:'25:16'),
      (Name:'UXGA' 	             ;Width:1600  ;Height:1200 ;Aspect:'4:3'),
      (Name:'WSXGA+' 	           ;Width:1680  ;Height:1050 ;Aspect:'8:5'),
      (Name:'Full HD' 	         ;Width:1920  ;Height:1080 ;Aspect:'16:9'),
      (Name:'WUXGA' 	           ;Width:1920  ;Height:1200 ;Aspect:'16:10'),
      (Name:'QWXGA' 	           ;Width:2048  ;Height:1152 ;Aspect:'16:9'),
      (Name:'QXGA' 	             ;Width:2048  ;Height:1536 ;Aspect:'4:3'),
      (Name:'WQXGA' 	           ;Width:2560  ;Height:1440 ;Aspect:'16:9'),
      (Name:'WQXGA' 	           ;Width:2560  ;Height:1600 ;Aspect:'16:10'),
      (Name:'WQSXGA' 	           ;Width:3200  ;Height:2048 ;Aspect:'25:16'),
      (Name:'QUXGA' 	           ;Width:3200  ;Height:2400 ;Aspect:'4:3'),
      (Name:'WQUXGA' 	           ;Width:3840  ;Height:2400 ;Aspect:'16:10'),
      (Name:'4K (Quad HD)' 	     ;Width:4096  ;Height:2160 ;Aspect:'256:135'),
      (Name:'HSXGA' 	           ;Width:5120  ;Height:4096 ;Aspect:'5:4'),
      (Name:'WHSXGA' 	           ;Width:6400  ;Height:4096 ;Aspect:'25:16'),
      (Name:'HUXGA' 	           ;Width:6400  ;Height:4800 ;Aspect:'4:3'),
      (Name:'Super Hi-Vision'    ;Width:7680  ;Height:4320 ;Aspect:'16:9'),
      (Name:'WHUXGA' 	           ;Width:7680  ;Height:4800 ;Aspect:'16:10'));

type
  THashType =
   ( htMD2, htMD4, htMD5,
     htSha1, htSha224, htSha256, htSha384, htSha512

   );

   // -- TerminateProcess, TerminateTask, GetWindowsByClass
  PWindowsByClass = ^TWindowsByClass;
  TWindowsByClass = record
    ClassName : string[255];
    windows   : TCardinalDynArray;
  end;

 THTTPMethod = (httpGet, httpPost, httpPut, httpDelete);

 // -- изменение надписей кнопок MessageBox-а #32770
 TMsgBoxBtnItem = record
   id   : integer;     // -- идентификатор (IDOK, IDNO и т.д.)
   text : string[16];
 end;


(***************************************************************************************************)
(***************************************************************************************************)
(***************************************************************************************************)


(***** end of type ********************************************************************************)
(***** END OF TYPES DECLARATIONS ******************************************************************)

(***************************************************************************************************)
(***************************************************************************************************)
(***************************************************************************************************)

procedure ShowSplash(const sCaption:string; sType: TSplashType); overload;
procedure ShowSplash(const sCaption:string; clrMain,clrFont : TColor); overload;
//procedure HideSplash; // -- не нужно это....
procedure FreeSplash;

function InputQueryPas(const ACaption, APromptLog, APromptPass:string;
                      const aComboItems: TStringDynArray;const aCurItem:string;
                      var LoginVal, PasswordVal:string;
                      OnDesktop : boolean = false): boolean; overload;
function InputQueryPas(const ACaption, APromptLog, APromptPass:string;
                      const aComboItems: TStrings;const aCurItem:string;
                      var LoginVal, PasswordVal:string; var Index : integer;
                      OnDesktop : boolean = false): boolean; overload;

function SelectQuery(const ACaption, APrompt:string;
                     const aComboItems: TStringDynArray;
                     const aCurItem:string;
                     var aItemIndex : integer): boolean;

procedure ShowEditBalloon(aEdit  :TCustomEdit; const aTitle,aText : string; aIconType : ShortInt = TTI_INFO);

procedure PatchINT3; stdcall;
(* --- Проверка эмулятора версии IE для приложения (действует на TWebBrowser (ы) в приложении) -- *)
//procedure CheckVersionIE; overload;
//procedure CheckVersionIE(aRoot: HKEY; const aKey : string; aVers : integer); overload;
procedure CallCheckVersionIE(aBaseVers : integer = 9999);
function IsDebug : boolean;

(*--- Системные, вспомогательные и т.п. функции ---*)
(*Тоже Sleep ---------------------------------------------------------------*)
procedure _sleep(ms: DWORD);
(* Memory functions ----------------------------------------------------------------------------- *)
function InfoMemory(var aPF, aPFm, aWS, aWSm : cardinal) : boolean;
function GetMemoryInfo(aMemInfoMode : TMemInfoMode) : cardinal;
procedure PackMemory;
procedure ClearMemory;
(*Получение глобального уникального идентификатора (GUID) ------------------*)
function CreateGuid:string;
function CreateClearGuid:string;
function CreateUuid:string;
function CreateClearUuid:string;
function CreateUuidNum:string;
(*Создание и Разрушение TStringList ----------------------------------------*)
procedure CreateStringList(var aStringList: TStringList);
procedure FreeStringList(var aStringList: TStringList);
(*Быстрая StringReplace (отсюда: http://fastcode.sourceforge.net/) -------------------------------*)
function StringReplaceEx(const S, OldPattern, NewPattern: string; Flags: TReplaceFlags): string;
(*Копирование строки в буфер -----------------------------------------------*)
procedure CopyStringIntoClipboard(const InputStr:string);
function GetClipboardName(Format : cardinal) : string;
function GetClipboardInfo(var fmt : cardinal; var Ext, About : string) : boolean;
procedure GetStringFromClipboard(out OutputStr:string);
procedure PasteStringFromClipboard(out OutputStr:string);
function GetFileListFromClipboard(const Dlm : string) : string;
function GetBytesFromClipboard(var Bytes : TBytes; Format : cardinal) : boolean;
procedure ClipboardWatch(Enable : boolean);
function AboutClipboard : string;
function GetCustomClipboardFormatsInfo : string;
//*ClipboardWatch нуждается в  procedure WMChangeCBChain(var msg: TWMChangeCBChain); message WM_CHANGECBCHAIN;
//*ClipboardWatch нуждается в  procedure WMDrawClipBoard(var msg: TWMDrawClipboard); message WM_DRAWCLIPBOARD;

function StringToMemory(const aStr : string) : cardinal;
function MemoryToString(const aMem : cardinal) : string;
function BytesToMemory(const aBytes : TBytes) : cardinal; overload;
function BytesToMemory(const aBytes : array of byte) : cardinal; overload;
function MemoryToBytes(const aMem : cardinal) : TBytes;

(*Строка в число с плавающей запятой с альтернативным разделителем ---------*)
function StrToFloatAltDS(const Value:string; aAltDecimalSeparator: char) : extended;
(*Число с плавающей запятой в строку в с альтернативным разделителем -------*)
function FormatFloatAltDS(const aFormat:string; Value: extended; aAltDecimalSeparator: char):string;
procedure FormatFloatThread(const Format : string; Value : extended; var Result : string);
(*Номер элемента в массиве (типа " A in [A,B,C,D]")*)
function Inner(const Val: byte;const ArrayOfVals: array of byte): integer; overload;
function Inner(const Val: integer;const ArrayOfVals: array of integer): integer; overload;
function Inner(const Val: cardinal; ArrayOfVals: array of cardinal): integer; overload;
function Inner(const Val: Word;const ArrayOfVals: array of Word): integer; overload;
function Inner(const Val:string;const ArrayOfVals: TStringDynArray) : integer; overload;
function Inner(const Val:Double;const ArrayOfVals: TDoubleDynArray) : integer; overload;
function Inner(const Val:Single;const ArrayOfVals: TSingleDynArray) : integer; overload;

function InnerBool(aTestVal: integer;const ArrayOfVals: array of integer) : boolean; overload;
function InnerBool(aTestVal: cardinal;const ArrayOfVals: array of cardinal) : boolean; overload;
function InnerBool(aTestVal: Word;const ArrayOfVals: array of Word): boolean; overload;
function InnerBool(aTestVal: Double;const ArrayOfVals: array of Double) : boolean; overload;
function InnerBool(aTestVal: Single;const ArrayOfVals: array of Single) : boolean; overload;

function EqualArray(const arrA, arrB : array of integer) : boolean; overload;
function EqualArray(const arrA, arrB : TIntegerDynArray) : boolean; overload;

(*Добавление элемена в массив (distinct)*)
function AddToIntDynArray(aval: integer;var aIDA: TIntegerDynArray): integer; overload;
function AddToIntDynArray(const aval: string;var aIDA: TIntegerDynArray; const dlm : string = ',.'): integer; overload;

procedure AddValuesIntoArray(const Values:TStringDynArray; var aArray: TIntegerDynArray);

procedure AddValueIntoArray(var aArray: TByteDynArray; aValue: Byte); overload;
procedure AddValueIntoArray(var aArray: TWordDynArray; aValue: Word); overload;
procedure AddValueIntoArray(var aArray: TIntegerDynArray;aValue: integer); overload;
procedure AddValueIntoArray(var aArray: TDoubleDynArray;aValue: double); overload;
procedure AddValueIntoArray(var aArray: TSingleDynArray;aValue: Single); overload;

procedure DelValueFromArray(var aArray: TByteDynArray; aValue: byte); overload;
procedure DelValueFromArray(var aArray: TWordDynArray; aValue: word); overload;
procedure DelValueFromArray(var aArray: TIntegerDynArray; aValue: integer); overload;
procedure DelValueFromArray(var aArray: TDoubleDynArray; aValue: Double); overload;
procedure DelValueFromArray(var aArray: TSingleDynArray; aValue: Single); overload;

procedure AssignIDA(const aSrc : TIntegerDynArray; var aDest : TIntegerDynArray); overload;
procedure AssignIDA(const aSrc : array of integer; var aDest : TIntegerDynArray); overload;
procedure AddIDA(const aSrc : TIntegerDynArray; var aDest : TIntegerDynArray); overload;

function GetStringIDA(const aSrc : TIntegerDynArray; const aArrDlm : string=',') : string; overload;
function IDA2Str(const aSrc : TIntegerDynArray; const aArrDlm : string=',') : string; overload;
function GetStringIDA(const aSrc : array of integer; const aArrDlm : string=',') : string; overload;
function IDA2Str(const aSrc : array of integer; const aArrDlm : string=',') : string; overload;
function GetXMLStringIDA(const aSrc : TIntegerDynArray; const Tag : string='value') : string; overload;
function GetXMLStringIDA(const aSrc : array of integer; const Tag : string='value') : string; overload;

procedure ClearDoubles(var IDA : TIntegerDynArray);


(*--- Internet and UTF procedures and functions ---*)
(*Преобразование символов для поисковой строки WEB (ANSI) -------------------*)
function GetStdSearchStringA(const Value: AnsiString): AnsiString;
function GetStdSearchStringW(const Value:String):String;
(*Преобразование строки в URL вида %D0%xx%D0%xx. для поисковой строки WEB ---*)
function AnsiStringToURL(URI: AnsiString): AnsiString;
(*Преобразование UTF-8 в ANSI -----------------------------------------------*)
function UTF8ToANSI(Value:String): AnsiString;
(*Преобразование строки URL с символами типа %D0%AD в ANSI ------------------*)
function URLStringIntoAnsiString(const aValue:string): AnsiString;
(*Преобразование строки с символами типа \\u04xx в строку -------------------*)
function OLD_JavaUTF8ToString(const aJavaFormatedUTFStr:string):string;


function HTMLStringToString(const aHTMLFormatedStr:string):string;
function StringToHTMLString(const aNormalStr:string):string;

procedure ReplaceRusSymbInHTML(const aHTMLFileName:string);

function ReplaceRusInURL(const aURL : string) : string;


(*Преобразование строки в строку Java типа \\u04xx --------------------------*)
function OLD_StringToJavaUTF8(const aString:string):string;


(*Проверка строки на кодировку UTF8 -----------------------------------------*)
function IsUTF8(const aStr:string): boolean;
(*Получение строки из массива символов --------------------------------------*)
function GetString(const aArrChar: array of char):string;
(*Преобразование массива байт(возможно содержащую UTF8string) в строку ------*)
function UTF8From2BytesString_PQ(const aBytes: TBytes):string; overload;
function UTF8From2BytesString_PQ(const aBytes: array of Byte):string; overload;
function UTF8From2BytesString_D0(const aBytes: TBytes):string; overload;
function UTF8From2BytesString_D0(const aBytes: array of Byte):string; overload;
//там же пример конвертации диких строк типа 'ÐÐ°Ð·Ð¾Ð²ÑÐ¹ Ðº' в читаемое....
function IsUnicode(const aTestStr:string): boolean;
function D0str2Str(const aDostr:string):string;

(******************************************************************************)
(******************************************************************************)
(******************************************************************************)
 // -- конвертеры в Интернете
 //http://www.artlebedev.ru/tools/decoder/advanced/
 //http://2cyr.com/decode/?lang=ru

(******************************************************************************)
(******************************************************************************)
(******************************************************************************)

(*Основная функция перевода строки в Юникод и HTML (%D0%BE и т.п.) ----------*)
function UTF8ToUnicode(const aInput:string;var aUnicode, aHTML:string): integer;
function AsUTF8(const aInput:string): string;
(*Основная функция перевода строки из Юникода в UTF8(WideString) и HTML (%D0%BE и т.п.) ----------*)
function UnicodeToUTF8(const aInput:string;var aUTF8:string): integer;



(* -- новая, адекватная, независимая от языка и CP -----------------*)
function JavaUTF8ToStringEx(const aUStr:string):string;
(* -- новая, адекватная, независимая от языка и CP -----------------*)
function StringToJavaUTF8Ex(const aString:string):string;



(* -- Набор байтов тпипа 4,101,4,59,0,68 в строку типа \\uXXXX*)
function BytesToJavaString(aBytes : array of byte; aStart,aLength : integer) : string;
procedure StringToJavaBytes(const aStr : string; var aBytes : TByteDynArray);
(*
 procedure test;
   var
    input : string;
    html : string;
    utf8 : string;
    bytes : TByteDynArray;
   begin
   input:='Пользователь_User_Login';
   UTF8ToUnicode(input,utf8,html);
   utf8:=StringToJavaUTF8Ex(input);
   StringToJavaBytes(input,bytes);
   utf8:=BytesToJavaString(bytes,0, Length(bytes));
   end;
*)


(******************************************************************************)
(******************************************************************************)
(******************************************************************************)

(*Перевод строки типа Óâàæàåìûé(àÿ) -> Уважаемый(ая) ------------------------*)
function GetRuSymb(aCode: smallint): ansichar;
function ConvertToRus(const aUnknownStr:string):string;

(*Перевод строки типа %XX%XX%XX в юникодную строку*)
function BytesStrToStr(const aBytesStr:string; aSign: char = '%'):string;
//-- встречается также '=' (типа =D0=A1=D0=BE)
function UnicodeToUTF8_HTML(const aInput:string;var aUTF8:string): integer;

(* перекодировка строк  *)

function AsUTF8mbwc(const aInput : string) : string;      // -- old name AsUTF16new
function AsUTF16(const aInput:string): string; //inline;
function AsWin1251mbwc(const aInput : string) : string;   // -- old name AsUTF8new
function AsURL(const aInput : string) : string;
function FromURL(const aInput : string) : string; // DelphiXE10.1 System.NetEncoding.TURLEncoding.Decode
function AsWin1251(const aInput:string) : string;
function Win1251ToUTF8(const aInput:string) : string;
function UTF8ToWin1251(const aInput:string) : string;

(*Определение типа строки (с "D0"("D1") или с "P"("Q") кодировками) ---------*)
function IsD0string(const aBytes: TBytes): boolean; overload;
function IsD0string(const aBytes: array of Byte): boolean; overload;
function IsPQstring(const aBytes: TBytes): boolean; overload;
function IsPQstring(const aBytes: array of Byte): boolean; overload;
(*Определение 4 байтовых символов в строке и упаковка в 2 байта -------------*)
function Is4bytesString(const aBytes: TBytes): boolean;
procedure Pack4bytes2bytes(var aBytes: TBytes);

function Base64_DecodeString(const Value:string):string;
function Base64_DecodeStringToStream(const Value:string; var aStream : TMemoryStream):integer;
procedure Base64_DecodeStringAndSave(const Value, FileName:string);
function Base64_EncodeString(const Value:string):string;



function Base64_EncodeImageFile(const aFileName:string):string;
function Base64_EncodeFile(const aFileName:string):string;
function Base64_EncodeStream(var aStream : TMemoryStream):string;
//PictureToBase64, PicToBase64, ImageToBase64, ImgToBase64
function EncodeBytes(const aArray : array of byte) : string;


(* Упаковка/ Распаковка файлов или массива байт(разные!!!) в/из формата GZip -------------------- *)
 function GZip_CompressFile(const aSrc, aDest : string) : boolean;
 function GZip_DeCompressFile(const aSrc, aDest : string) : boolean;
 function GZip_CompressBuff(const aSrc : TBytes; var aDest : TBytes) : boolean;
 function GZip_DeCompressBuff(const aSrc : TBytes; var aDest : TBytes) : boolean;
(* Упаковка/ Распаковка файлов или массива байт(разные!!!) в/из формата Zip -------------------- *)
 procedure ZipSysObject(const aZIPName, aSysObjectName : string);
 procedure GetZipObjectList(const aZIPName : string; var aZOL : TZipFolderObjectList);
 procedure UnzipSysObjects(const aZIPName, aUnZIPName : string; const aSysObjectsName : TStringDynArray);


function SendTextMessage1(Handle: HWND; Msg: UINT; WParam: UnicodeString; LParam: Integer): LRESULT;
function SendTextMessage2(Handle: HWND; Msg: UINT; WParam: UnicodeString; LParam: UnicodeString): LRESULT; overload;
function TextFromParam(Param : integer) : string;

function NormalChar(aChar: char): boolean; overload;
function NormalChar(aChar: ansichar): boolean; overload;
function CharInString(aChar: char;const aString:string): boolean; overload;
function CharInString(aChar: ansichar;const aString:string): boolean; overload;
function IsRusChar(aChar: char): boolean;

(*Получение папки на aUpLevels выше указанной*)
function UpDirectoryN(const aDirectory:string;const aUpLevels: integer):string;
(*Поиск первой существующей папки верхнего уровня от указанной ---------------*)
function GetFirstExistsFolder(const aStartDir : string) : string;
(*Получение имени файла из URL (методом поиска первого с конца разделителя) -*)
function ExtractFileNameFromURL(const aURL:string):string;
(*Получение имени файла из URL (методом StringReplace) ----------------------*)
function ExtractFileNameFromURL2(const aURL:string):string;
(*Получение поисковой строки из указанного шаблона (aSearchShablon) ---------*)
function FormatSearchString(const aSearchShablon, aSearchValue:string)  :string; overload;
function FormatSearchString(const aSearchShablon:string; aValues: array of const):string; overload;
(*Получение результатов запроса по ссылке(файл, страница, запрос-XML) в файл*)
function DownloadFile(const SourceURL, DestFile:string): boolean;
// see LoadImageIntoBitmap below

(*FTP. Подключение и переход на определенную папку -------------------------*)
function CreateAndConnect(const aFTPHost, aFTPFolder, aFTPLogin, aFTPPassword:string; aFTPPort: integer;var aFTP: TidFTP): boolean;
(*FTP. Копирование файлов на FTP сервер в указанную папку ------------------*)
function CopyFileToFTP(const aFTPHost, aFTPFolder, aFTPLogin,aFTPPassword:string; aFTPPort: integer;const aLocalFileName:string): boolean;
function CopyFilesToFTP(const aFTPHost, aFTPFolder, aFTPLogin,aFTPPassword:string; aFTPPort: integer; const aLocalFileNames: TStringDynArray): boolean;
function CopyFilesToFTPNoExists(const aFTPHost, aFTPFolder, aFTPLogin, aFTPPassword:string; aFTPPort: integer; const aLocalFileNames: TStringDynArray): boolean;
(*Чтение из открытого в другой программе текстового файла ------------------*)
function ReadBusyFileIntoString(const aFileName:string):string;
(*Установка папки (стандартный диалог выбора папки WINDOWS)*)
function SetFolder(_hwnd: integer;const FileName:string; StartDir: PChar;  TT: PChar):string;
(*Получение TIcon ассоциированное с расширением или файлом*)
function GetAssociatedIcon(const aExtOrName:string;var aIcon: TIcon; aNumIco: Word = 0): boolean;
(*Работа с ресурсами DLL, получение TIcon и т.д. ------------------------------------------------ *)
function IS_INTRESOURCE(lpszType: PChar): BOOL;
function EnumIcon(hMod : HMODULE; lpszType, lpszName: PChar; lParam: integer) : BOOL; stdcall;
procedure EnumRes(const aSysDLL : string;var aStrs : TStringDynArray; aIsGroup : boolean);
function GetIcon(const aSysDLL ,aName : string; var aIcon : TIcon; aIsGroup : boolean) : boolean;

procedure GetFileContextMenu(const Path:String; MousePoint: TPoint; WC: TWinControl);
function GetSizeOfFile(const fn:string): int64;

function GetFileName(const aInitDir, aFilter, aName, aDefExtWODot:string; aFilterInd: integer = 1):string;
function SetFile(const aInitDir, aFilter:string; var aFilterIndex: integer; aForSave: boolean):string;
function SelectFileName(var aFileName:string;const aMainFilter:string; aForSave: boolean): boolean;
(*Получение и установка дат файла*)
procedure FT2DT(ft: TFileTime;var dt: TDateTime);
function FileTimeToDateTime(aFT: TFileTime): TDateTime;
function SetFileDates(fn: PChar; FileDates: TFileDates): boolean;
function GetFileDates(afn: PChar): TFileDates;
function GetOffSetTime : TTime;
function FileIsReady(const aFilename : string; var aSize : int64) : boolean;
function DOSFileNameToURL(const aFN : string) : string;
function URLToDOSFileName(const aURL : string) : string;

procedure GetOSObjectDates(const aObjectName : string; var aFileDates : TFileDates);
function SetOSObjectDates(const aObjectName : string; aFileDates : TFileDates): boolean;

function ShellDeleteFile(aHwnd: integer;const aFileName:string;  aHardDel, aAtten: boolean): integer;
procedure PendingDeleteFile(const aFileName:string);
function ShellDeleteFolder(aHwnd: integer;const aFolderName:string; aAtten: boolean): integer;
function ShellMoveCopyFileNT(DoCopy: boolean;const FromFile, ToFile:string; out NewFileName:string; Ren, Atten: boolean): integer;
function GetAtoms : string;
function CloseMessageBoxes(aWithResult : integer; aAppHandle : cardinal = 0) : boolean;

// -- останов процессов по MainWindow(?) и PID
function TerminateApp(ProcessID: DWORD; Timeout: Integer): boolean;
function TerminateTask(Wnd: THandle; Timeout: Integer): boolean;
// -- получение списка окон указанного класса
function GetWindowsByClass(const ClassName : string; var WbC : TWindowsByClass) : boolean;
// -- получение списка окон указанного модуля (только EXE-наименование без полного пути)
function GetWindowsByModulename(const OnlyEXEName : string; var WbC : TWindowsByClass; MainOnly : boolean = false) : boolean;
// -- зачистка упоминаний атома
procedure ClearAtom(const AtomName : PChar);
// -- поиск запущенных процессов и их останов
function ClearIntstances(const OnlyEXEName : string) : boolean;
function ClearIntstances_OLD(const aAtomNameWork, MainFormClassName, OnlyEXEName : string) : boolean;
function GetInstanceCount : integer;



function ValidateComponentName(const aSrcName:string; var aResName:string): boolean;
procedure ClearMenuItem(aMI: TMenuItem);
function ClearPopupMenu(aPM: TPopUpMenu): boolean;
function ClearPopupMenuByTag(aPM: TPopUpMenu; aTags: array of integer;  aKeepTags: boolean): boolean;
function AddItemToPopupMenu(aPM: TPopUpMenu; aMainItem: TMenuItem; const ACaption:string; aProc: TNotifyEvent; aTag: integer = 0): TMenuItem;
function AddItemToMenu(aMenu: TMenu; aMainItem: TMenuItem;const ACaption:string; aProc: TNotifyEvent; aTag: integer; aChecked: boolean): TMenuItem;
function ShowPopupMenu(GraphCtrl: TGraphicControl; aMenu: TPopUpMenu): TPoint; overload;
function ShowPopupMenu(aWinCtrl: TWinControl; aMenu: TPopUpMenu): TPoint; overload;
function ShowPopupMenu(wnd: cardinal; aMenu: TPopUpMenu): TPoint; overload;
function GetSpeedButtonHandle(aSpB: TSpeedButton): cardinal;
procedure GetSpeedButtonRect(aSpB : TSpeedButton; var aRect : TRect);

(*--- Picture procedures and functions ---*)
function GetPictureType(const aURI:string): TPicType; overload;
function GetPictureType(aStream: TStream): TPicType; overload;
(*Загрузка изображения из файла в TImage -----------------------------------*)
(**)function LoadImageFromFileIntoImage(const aFile:string; aImage: TImage) : boolean;
(*Загрузка изображения из Internet-а в TImage ------------------------------*)
(**)function LoadImageFromURLIntoImage(const aURL:string; aImage: TImage): boolean;
(*Загрузка изображения из файла в TBitmap ----------------------------------*)
(**)function LoadImageFromFileIntoBitmap(const aFile:string; var aBMP: TBitmap): boolean;
(*Загрузка изображения из Internet-а в TBitmap -----------------------------*)
(**)function LoadImageFromURLIntoBitmap(const aURL:string; aBMP: TBitmap): boolean;
    function LoadImageFromURLIntoBitmapWithBackColor(const aURL:string; aBMP: TBitmap; BackColor : TColor): boolean;
//function PngToBMP(const URIPng : string; aBMP : TBitmap; BackColor : TColor);
(*ОСНОВНАЯ на 20140410 : загрузка изображения в Bitmap (file, url) ---------*)
function LoadImageIntoBitmap(const aURI:string; aBMP: TBitmap; ahndl: cardinal; BackColor : TColor = Graphics.clNone): boolean;
(*Загрузка файла из Internet-а ---------------------------------------------*)
function LoadImageFromURLIntoFile(const aURL, aFolder:string; aRaiseError: boolean): boolean;
// see DownloadFile above

function LoadURLIntoStream(const aURL : string; var aStream : TMemoryStream; aRaiseError: boolean): boolean;

function LoadStringFromURL(const aURL:string):string;

function LoadStringFromURI(const aURI : string; var aErrMsg : string; ahMod : cardinal = 0):string;

procedure LoadImageFromResourceJPG(var aBMP: TBitmap; const aResourceName:string);


function DateTimeGMT(DateTime : TDateTime = 0) : string;
procedure HTTPRequest(aMethod : THTTPMethod; const aURL, aHeaders, aData, aContentType : string; var aResultData,aResultMessage : string; waitTimeMS : integer = 500);

function SavePicture(aBMP : TBitmap; const aFilename : string; aPicType : TPicType): string;

function AboutPictureType(const aExt:string):string; overload;
function AboutPictureType(const aPT:TPicType):string; overload;


function SaveResourceIntoFile(const aResource, aFilename : string) : boolean;


function GetCustomColors : string;
function LoadCustomColors(const FileName : string) : string;
procedure SaveCustomColors(const FileName,CustomColorsText : string);

(*Загрузка картинки из поля таблицы базы данных (с анализом типа картинки)--*)
procedure DrawError(var aPNG: TPNGImage;const aErrText:string); overload;
procedure DrawError(var aGraphic: TGraphic;const aErrText:string); overload;

function StreamToBMP(aStream: TStream;var aBMP: TBitmap): boolean;
function PicStreamProps(aStream: TStream;var aWidth,aHeight: integer): boolean;
function FieldToBMP(aField: TField;var aBMP: TBitmap): boolean;
function FieldToGraphic(aField: TField; aGraphic: TGraphic;
  aCheckSize: int64 = 0): boolean;
procedure GraphicToField(aGraphic: TGraphic; aField: TField);
procedure GraphicToParameter(aParam: TParameter; aGraphic: TGraphic);

(*Копирование Bitmap в буфер обмена ----------------------------------------*)
procedure CopyBitmapToClipBoard(const aBitmap: TBitmap);
procedure CopyGraphicToClipBoard(const aGraphic: TGraphic);
function PasteBitmapFromClipBoard(aBitmap : TBitmap) : boolean;
procedure BitmapV5HeaderIntoBitmap(var bmp : TBitmap);
procedure BitmapHeaderIntoBitmap(var bmp : TBitmap);
function UpdateScreenShot(const basewnd : cardinal; var nextWnd: cardinal;const Txt : string) : integer;

function GetExtWODotForGraphic(const aGraphic: TGraphic):string;
(*Масштабирование Bitmap ---------------------------------------------------*)
procedure ScaleBitmap(var aBMP: TBitmap;const aKoef: double); overload;
function ScaleBitmap(var aBMP: TBitmap; aRect: TRect): double; overload;
(*Масштабирование Bitmap под TRect -----------------------------------------*)
function BmpIntoRect(var aBMP: TBitmap; aRect: TRect): double; overload; // -- масшьабирование
procedure BmpIntoRect(SrcBMP: TBitmap; aRect: TRect; var ResBMP : TBitmap); overload; // -- заполнение плиткой
function BmpIntoRectByHeight(var aBMP: TBitmap; aRect: TRect): integer;

//procedure VertTurnBitmap(var aBMP: TBitmap);
procedure Bmp2Png(aBMP : TBitmap; var aPng : TPngImage; aWidth,aHeight : integer; aTryTrn : boolean = true);
procedure Bmp2Ico(aBMP : TBitmap; var aIcon : TIcon; aSize : integer; aTryTrn : boolean = true);
function GetFileIcon(const aFileName : string; aIcon : TIcon; aSize : integer = 32): boolean;
procedure GetBmp16FromFileIcon(const aFileName:string;var aBMP: TBitmap; aTrnColor: TColor);

function GetObjectInfo(aObject: TObject):string;
function IsTComponent(aPointer: Pointer): boolean;
procedure GetProps(aObj: TObject;var aStrl: TStringList);
function AboutObject(Sender: TObject):string;
function AOS(Sender: TObject):string; // AboutObjectSimple
function AboutObjectByHandle(aWnd : hwnd) : string;
function GetOffset(aControl : TControl; var aX,aY : integer) : boolean;
function GMN(Obj: TObject): string; // GetMethodName//http://www.sql.ru/forum/actualutils.aspx?action=gotomsg&tid=813080&msg=9921273
//function GetFocusedWindow: HWND; // http://www.delphimaster.net/view/4-89076

procedure GetPreviousControl(aCurWnd : cardinal);overload;
procedure GetPreviousControl;overload;
procedure GetNextControl(aCurWnd : cardinal);overload;
procedure GetNextControl; overload;


procedure SetEnabledControls(aParent : TWinControl; aEnabled : boolean; const aCtrlForEnabled : array of TControl);



//  http://www.rsdn.ru/article/delphi/serialization.xml
procedure SaveComponentToFile(RootObject: TComponent; const FileName: TFileName);
procedure LoadComponentFromFile(RootObject: TComponent; const FileName: TFileName);

// http://robstechcorner.blogspot.ru/2009/09/delphi-2010-rtti-basics.html
function GetMethodsAndProperiesOfClassFast(aClassInfo : pointer; var aMethods : TList<TRTTIMethod>; var aProperties : TList<TRttiProperty>) : boolean;
function GetMethodsAndProperiesOfClass(aClassInfo : pointer; var aMethods : TList<TRTTIMethod>; var aProperties : TList<TRttiProperty>) : string;
function GetPropertiesForClass(aClassInfo : pointer; const aClassName : string; aProps : TList<TRttiProperty>) : string;
function GetDopPropertiesForClass(aClassInfo : pointer; var aProps : TRTTIDopInfoList; const aClassName: string = ''): integer; overload;
function GetPropertiesForClassFast(aClassInfo : pointer; const aClassName : string; aProps : TList<TRttiProperty>) : boolean;



(*Получение описания ошибки по коду ----------------------------------------*)
function GetErrorString(const aErrorCode: integer = MAX_INTEGER):string;
(*Запрос кода и описания ошибки WinSocket*)
function GetWSAErrorString(err: integer  = - 1) : string;
function CheckUsePort(port : word) : integer;
function NameToIPv4(const NetworkName:String):String; overload;
function NameToIPv4(const NetworkName:String; var aIPorError : string):boolean; overload;
function IPv4ToName(const IPAddr:string):string;

(* PING адреса возвращает время отклика в мс или pingErrorCode(0>)            *)
  function IcmpCreateFile() : THandle; stdcall; external 'ICMP.DLL' name 'IcmpCreateFile';
  function IcmpCloseHandle(IcmpHandle : THandle) : BOOL; stdcall; external 'ICMP.DLL'  name 'IcmpCloseHandle';
  function IcmpSendEcho(IcmpHandle : THandle;    // handle, возвращенный IcmpCreateFile()
                        DestAddress : u_long;    // Адрес получателя (в сетевом порядке)
                        RequestData : PVOID;     // Указатель на посылаемые данные
                        RequestSize : Word;      // Размер посылаемых данных
                        RequestOptns : PIPINFO;  // Указатель на посылаемую структуру  ip_option_information (может быть nil)
                        ReplyBuffer : PVOID;     // Указатель на буфер, содержащий ответы.
                        ReplySize : DWORD;       // Размер буфера ответов
                        Timeout : DWORD          // Время ожидания ответа в миллисекундах
                        ) : DWORD; stdcall; external 'ICMP.DLL' name 'IcmpSendEcho';

function Ping(const aIPAddr : string;out log : string; SizeOfBuffer : cardinal = 32;pngInterval: cardinal = 1000):integer;
function GetMacAddresses(const Machine: string; const Addresses: TStrings): Integer;
// -- получение используемых в системе портов (возможно получение полных сведений о подключениях )
procedure FillUsedPorts(var ports : TIntegerDynArray);
function GetConnections(asHtml : boolean; const HighLightPorts : array of integer) : string;
function GetPortPID(port : integer) : cardinal;



procedure CreateErrorMessage(const aProcName:string; E: Exception; aParams: array of const;var aResult:string); overload;
procedure CreateErrorMessage(const aProcName:string; E: Exception; aParams: array of const; aNeedShowError: boolean); overload;
function CreateErrorMessage(const aProcName:string; E: Exception; aParams: array of const) : string; overload;




// ms-help://embarcadero.rs_xe/ShellCC/platform/shell/reference/enums/csidl.htm
(*Получение папки для временного хранения файлов ---------------------------*)
function GetTempFolder:String;
(*Получение папки "Мои документы" ------------------------------------------*)
function GetDocFolder:string;
function GetCommonDocFolder:string;
(*Получение папки "Рабочий стол" -------------------------------------------*)
function GetDesktopFolder:string;
(*Получение папки "Мои рисунки" --------------------------------------------*)
function GetPictureFolder:string;
(*Получение папки профиля пользователя -------------------------------------*)
function GetUserFolder : string;
(*Получение папки ОС (WinAPI) ----------------------------------------------*)
function GetWindowsFolder:string;
(*Получение папки "Корзина"  -----------------------------------------------*)
function GetTrashFolder: string;
(*Получение папки ОС (Shell)  ----------------------------------------------*)
function GetSystemFolder(aCSIDL_Folder: integer; aSetBackSlash: boolean = true):string;
procedure GetUserPrivileges(SysUser: PChar; List: TStringList);

(* Установка русского, английского и произвольного(для восстановления) языка  *)
procedure SetRusLang;
procedure SetEngLang;
procedure SetLang(const aKeybLangName : PChar);
procedure GetLang(var aKeybLangName : PChar);


(* Работа с объектами DeviceContext, TCanvas : рисование, раскраска, вывод текста --------------- *)
function BMPtoRGN(bmp: Graphics.TBitmap; BkColor: TColor): hRGN;

procedure GetPoint(aBasePoint: TPoint; aAngleDegree: extended;  aRadius: extended;var aResPoint: TPoint); overload;
function GetPoint(aBasePoint: TPoint; aAngleDegree: extended; aRadius: extended) : TPoint; overload;
function GetAngle(LenX, LenY: extended): extended; overload;
function GetAngle(A, C: TPoint;var aQuart: Byte): extended; overload;
function GetAngleRad(A, C: TPoint): extended; overload;
function GetDistance(A,B : TPoint) : extended;
procedure GetCenter(A,B : TPoint; var C: TPoint);
function GetHypo(aCat,aAngleDegree : extended; aCatOpposite : boolean) : single;
function GetFont(const aName:string; aSize: integer; aStyle: TFontStyles): hFont;
function CreateFont(var aFont: TFont;const aName:string; aSize: integer; aStyle: TFontStyles; aColor: TColor): cardinal;
function CreateClearBrush : hBrush;


procedure BlueCaption(dc: hDC;const aRect: TRect;const aText:string;  Pressed: boolean = false);
procedure GreenCaption(dc: hDC;const aRect: TRect;const aText:string;  Pressed: boolean = false);
procedure YellowCaption(dc: hDC; aRect: TRect;const aText:string;   Pressed: boolean = false);
procedure RedButton(dc: hDC; aRect: TRect; Pressed: boolean = false);
procedure GrayButton(dc: hDC; aRect: TRect; Pressed: boolean = false);
procedure RedCaption(dc: hDC; aRect: TRect;const aText:string; aPressed: boolean = false);
procedure VioletCaption(dc: hDC; aRect: TRect;const aText:string; Pressed: boolean = false);
procedure GrayCaption(dc: hDC; aRect: TRect;const aText:string; Pressed: boolean = false);
// -- Фигуры с градиентной заливкой
procedure GradientFigureRegion(aRct : Trect; aGradientFigure: TGradientFigure; var aRgn : hRgn);
procedure GradientFigure(aCanvas: TCanvas; aGradientFigure: TGradientFigure; aRect: TRect; aBaseColor: TColor;const ACaption:string; aTextColor: TColor;  aPressed: boolean); overload;
procedure GradientFigure(aDC: hDC; aGradientFigure: TGradientFigure; aRect: TRect; aBaseColor: TColor;const ACaption:string; aTextColor: TColor; aPressed: boolean); overload;
procedure SimpleFigure(aDC: hDC; aGradientFigure: TGradientFigure;aRect: TRect; aBaseColor,aBorderColor: TColor;const ACaption:string; aTextColor: TColor); overload;
procedure GradientFigureBMP(aDC: hDC; aGradientFigure: TGradientFigure; aRect: TRect; aBaseColor: TColor;const ACaption:string; aTextColor: TColor; aPressed: boolean;var aBMP: TBitmap);
//HLS mode
procedure SimpleLED(aCanvas: TCanvas; aTop, aLeft: integer; IsOn: boolean); overload;
procedure SimpleLED(aHandle: HWND; aTop, aLeft: integer; IsOn: boolean); overload;
//RGB mode
procedure SimpleLED_old(aCanvas: TCanvas; aTop, aLeft: integer; IsOn: boolean); overload;
procedure SimpleLED_old(aHandle: HWND; aTop, aLeft: integer; IsOn: boolean); overload;
//RGB mode
procedure RedLED(const aCanvas: TCanvas; rct: TRect; Diameter: integer);
procedure RedLED2(const aCanvas: TCanvas; rct: TRect);
procedure GreenLED(aCanvas: TCanvas; rct: TRect; Diameter: integer);
procedure GreenLED2(const aCanvas: TCanvas; rct: TRect);
procedure BlueLED(aCanvas: TCanvas; rct: TRect; Diameter: integer);
procedure BlueLED2(aCanvas: TCanvas; rct: TRect);
procedure YellowLED(aCanvas: TCanvas; rct: TRect; Diameter: integer);
procedure YellowLED2(aCanvas: TCanvas; rct: TRect);
procedure GrayLED(const aCanvas: TCanvas; aRect: TRect);
procedure GrayLED2(const aCanvas: TCanvas; aRect: TRect);
procedure LED(const aCanvas: TCanvas; aRect: TRect; aDark, aLight: TColor);


function AddPoint(Pt  :TPoint; var Pts : TPointDynArray) : integer;
procedure GetMinMaxX(const pts : array of TPoint; var MinX, MaxX : integer);
procedure GetMinMaxY(const pts : array of TPoint; var MinY, MaxY : integer);
procedure WuLine(Canvas: TCanvas; Point1, Point2: TPoint; aColor: TColor);
procedure DrawWrongLine(aDC : hDC; aPt : TPoint; aLength : integer; aColor : TColor);
procedure DrawWrongLineSin(aDC : hDC; aPt : TPoint; aLength : integer; aColor : TColor);
procedure Circle(aDC : hDC; aPtCenter : TPoint ; aRadius : integer);
procedure DrawWavyLine(aDC : hDC; aPtA, aPtB : TPoint; aWidth : byte; aColor : TColor);
procedure EllipseExt(aDC : hDC; aPtA, aPtB : TPoint; aWidth : byte; aColor : TColor);
procedure SinusLine(aDC : hDC; aPtA, aPtB : TPoint; aWidth : byte; aColor : TColor; FirstUp : boolean);
procedure DrawBlot(aDC : hDC; Rct : TRect; aColor : TColor);
procedure DrawFlower(aDC : hDC; Center : TPoint; RadCommon, RadCenter : extended; Count : integer; clrPetal,clrCenter : TColor);
procedure DrawArrow(aDC : hDC; aPtA, aPtB : TPoint; aWidth : byte; aColor : TColor);
(*Инвертирование цвета (Возвращает контрастный цвет)*)
function InvertColor(Value: TColor): TColor;
function ContrastColor(Value: TColor): TColor;
(*Изменение цвета (вместо Pixels[x,y], много быстрее)*)
procedure ChangeColor(aBMP: TBitmap; aSrcColor, aDestColor: TColor);
function StringToColorDef(const aStr:string; aDefColor: TColor): TColor;
function RGBStrToColorDef(const aStr:string; aDefColor: TColor): TColor;

procedure SetGlyph(aSpeedButton: TSpeedButton; aImageList: TImageList;  aIndex: integer; aEnabled: boolean = true);overload;
procedure SetGlyph(aBitBtn: TBitBtn; aImageList: TImageList;  aIndex: integer; aEnabled: boolean = true);overload;
procedure SetGlyph(aSpeedButton: TSpeedButton; aImageList: TImageList; aIndexes: array of integer; aEnabled: boolean = true);overload;
procedure SetGlyph(aBitBtn: TBitBtn; aImageList: TImageList; aIndexes: array of integer; aEnabled: boolean = true);overload;
procedure SetGlyphEx(aSpeedButton: TSpeedButton; aImageList: TImageList; aSize: integer; aIndexes: array of integer; aEnabled: boolean = true);
procedure SetGlyphTwo(SpB: TSpeedButton; IL : TImageList; Indexes: array of integer);

function GlyphOfFile(const aExtOrFileName:string; aSpB: TSpeedButton): boolean;

procedure SetMultiLineCaption(Button : TButton; const MultiLineText : string); overload;
procedure SetMultiLineCaption(Button : TBitBtn; const MultiLineText : string); overload;
procedure SetMultiLineCaption(Button : TSpeedButton; const MultiLineText : string); overload;

procedure ALPHA_Window(WndHandle: HWND; Value: Byte);
procedure SetTransparentWindow(WndHandle: HWND; Value: Byte);
procedure AlphaBlt(aDestDC: hDC; aDestLeft, aDestTop, aDestWidth,
  aDestHeight: integer; aSrcDC: hDC; aSrcLeft, aSrcTop, aSrcWidth,
  aSrcHeight: integer; aAlpha: Byte); overload;
procedure AlphaBlt(aDestCanvas: TCanvas; aDestLeft, aDestTop, aDestWidth,
  aDestHeight: integer; aSrcCanvas: TCanvas; aSrcLeft, aSrcTop, aSrcWidth,
  aSrcHeight: integer; aAlpha: Byte); overload;

procedure ShakeScreen(aWnd : cardinal = 0); overload;
procedure ShakeScreen(aWnd,aDuration : cardinal); overload;
procedure RepaintWindow(wnd : cardinal);
procedure blink(wnd : cardinal);



procedure CalcTextSize(aDC: hDC;const aStr:string; aAlign: integer; var aSize: tagSize);
procedure DrawTransparentText(aDC: hDC;const aStr:string;var aRct: TRect; aAlign: integer); overload;
procedure DrawTransparentText(aCanvas: TCanvas;const aStr:string; var aRct: TRect; aAlign: integer); overload;

procedure DrawLine(aDC: hDC; ptFrom, ptTo: TPoint); overload;
procedure DrawLine(aCanvas: TCanvas; ptFrom, ptTo: TPoint); overload;
procedure DrawLineEx(aDC: hDC; ptFrom, ptTo: TPoint; aColor: TColor); overload;
procedure DrawLineEx(aCanvas: TCanvas; ptFrom, ptTo: TPoint; aColor: TColor); overload;

procedure DrawDotLine(aDC: hDC; ptFrom, ptTo: TPoint; aClr : TColor; aInt : integer); overload;
procedure DrawDotLine(aCanvas: TCanvas; ptFrom, ptTo: TPoint; aClr : TColor; aInt : integer); overload;

procedure DrawWeb(aDC: hDC; aRect: TRect; aColor: TColor = clGray); overload;
procedure DrawWeb(aCanvas: TCanvas; aRect: TRect; aColor: TColor = clGray); overload;

(*Замена всяческих спецсимоволов на пробелы (#32)*)
function NormalizeString(const InputString:string; const WOFormat: boolean = false):string;
function NormalizeStringSysPath(const InputString:string):string;
function ClearSysPath(const InputString:string):string;
function CheckForSysBadChars(const aTest : string) : boolean;
function ExistZeroChar(const Bytes : TBytes) : boolean;
function NormalizeComponentName(const InputString:string):string;
function NormalizeNumOnly(const InputString:string):string;
function NormalizeName(const Value:string):string;
function NormalizeNameHTML_DELETE(const Value:string):string; // -- used in MO2 --
function NormalizeNameXML(const Value:string):string;
function NormalizeDateTimeHavingString(const Value:string; dlm : char = #32):string;


function StringToXMLString(const aString:string):string;
function Str2XML(const aString:string):string;
function ValidXML(const aString:string):string;

function Str2JSON(const aString:string):string;

function PrepareHTMLPhones(const aSRC : string; aDlm : char = ';') : string;

function NormalizeExcelSheetName(const Value:string):string;

function CheckValidInteger(const Str:string; const PositivOnly: boolean = false): boolean;
function CheckValidInt64(const Str:string; const PositivOnly: boolean = false): boolean;
function CheckValidHex(const Str:string): boolean;
function CheckValidFloat(const Str:string): boolean;
function CheckDateInStrSafe(var DateStr:string): boolean; overload;
function CheckDateInStrSafe(const aTestStr : string; var aDateStr:string): boolean; overload;
function CheckDateTimeInStrSafe(const aTestStr : string; var aResStr:string): boolean;
// see below : CheckValidEMailAddress(const aAddr:string; var aResAddr : string): boolean;
function CheckValidPhoneNumber(const aTestStr : string; var aPNC : TPhoneNumberCountry; var aResStr:string): boolean;
function RandomByte(aPart: Byte): Byte;
function RandomDateTime(aMin,aMax : TDateTime) : TDateTime;
function RandomString : string; inline;

function FileToArrayOfBytes(const aFileName : string ; var aBytes : TByteDynArray) : cardinal;
(*Открытие файла, папки, URL и т.п. ----------------------------------------*)
function FileOpenNT(const aFileName:string): boolean;
function FileOpenNTWithParams(const aFileName, aParams:string): boolean;
(*Установка / сброс заключительного PathDelimiter-а ------------------------*)
procedure SetTailingBackSlash(var aPath:string; aSetting: boolean);
function SetTailBackSlash(const aPath:string; aSetting: boolean = true):string;

function GetParamStrByIndex(const aCmdLine : string; aIndex : integer) : string;
(*Сохраняет произвольную строку в файл (через TStringList) -----------------*)
function SaveStringIntoFileAnsi(const aStr: AnsiString; const aFileName:string): integer;
function SaveStringIntoFileWide(const aStr, aFileName:string): integer;
procedure SaveStringIntoFileStream(const aStr, aFileName:string; aOverWrite : boolean = true);
procedure SaveBytesIntoFileStream(const aData : TBytes; const aFileName:string; aOverWrite : boolean = true);
function SaveStringIntoFileStreamEx(const aStr, aFileName:string; aOverWrite : boolean = true) : string;
procedure SaveStringIntoFile(const aStr, aFileName:string);
procedure SaveStringIntoFileUTF8(const aStr, aFileName:string);
procedure SaveStringIntoFileDef(const aStr, aFileName:string);
(*Загружает содержимое файла в строку --------------------------------------*)
function LoadStringFromFile(const aFileName:string):string;
function LoadStringFromFileStream(const aFileName:string):string;
function LoadStringFromFileUTF8(const aFileName:string):string;
(*Проверка файла на возможность записи (свободен или нет) ------------------*)
function CanFileWrited(const aFileName : string) : boolean;
(*Очистка директории от файлов ---------------------------------------------*)
function ClearFiles(const aDir, aMask:string): boolean;
procedure DeleteFilesByMask(const aFolder, aMask:string);
(*Очистка директории ---------------------------------------------*)
function IsFolderEmpty(const aDir : string) : boolean;
function ClearFolder(const aDir : string): boolean; overload;
function ClearFolder(const aDir,Mask : string): boolean; overload;
function DeleteFolder(const aDir : string): boolean;


function FieldToFile(aField: TField;const aFileName:string):string;
function FieldToMemoryStream(aField: TField; var aMemoryStream: TMemoryStream): int64;


function StringToStream(const aStr:string;var aStream: TStream) : integer; overload;
function StringToStream(const aStr:string;var aStream: TMemoryStream) : integer; overload;
function StreamToFile(aStream: TStream;const aFileName:string): boolean;

function OSFileNameToURL(const afn:string):string;
function PrepareFileName(const aSrcFileName:string; aMAX_LENGTH: integer = MAX_PATH):string;

function GetAbsolutePath(const aFileName:string):string;
(* UNC, длинный путь к файлу *)
function GetLongFileName(const aSrcFileName : string) : string;
function GetLongPath(const aFileName:string):string;
function GetUNCName(const aFileName:string):string;
function ClearUNCName(const aFileName:string):string;


function GetStringHash(ht : THashType; const Str : string) : string;
function GetStreamHash(ht : THashType; Stream : TStream) : string;
function GetFileHash(ht : THashType; const aFileName : string): string;

function GetStringMD2(const Str : string) : string;
function GetStreamMD2(Stream : TStream) : string;
function GetFileMD2(const aFileName : string): string;
function GetStringMD4(const Str : string) : string;
function GetStreamMD4(Stream : TStream) : string;
function GetFileMD4(const aFileName : string): string;
function GetStringMD5(const Str : string) : string;
function GetStreamMD5(Stream : TStream) : string;
function GetFileMD5(const aFileName : string): string;

(*Получение версии файла*)
procedure GetFileVersion(const aFileName:string;var aFileVersion: TFileVersion);
//function GetFileVersionNew(const AFileName: string; aFileVer : TFileVersion): Cardinal;
//procedure GetFileVersion(const aFileName : string; var aFileVersion : string);//overload;

(*Заменяет одну строку на другую в файле (через TStringList) ---------------*)
function ReplaceStringInFile(const aFirst, aSecond, aFileName:string): boolean;
function GetAllFiles(const dir:string;var aStrings: TStringDynArray; const Mask:string = '*.*'): integer;
function GetAllFilesFullPath(const dir:string;var aStrings: TStringDynArray;const Mask:string = '*.*'): integer;
function GetAllFilesRecur(const dir:string;var aStrings: TStringDynArray; const Mask:string = '*.*'): integer;

function GetAllFoldersRecur(const dir:string;var aStrings: TStringDynArray) : integer; overload;
function GetAllFoldersRecur(const dir:string;var aStrings: TStringList) : integer; overload;

function GetFoldersMsg(const dir:string;var aStrings: TStringDynArray; aWnd: cardinal; aMsg: integer): integer; overload;
function GetFoldersThreeMsg(const dir:string;var aStrings: TStringDynArray; aWnd: cardinal; aMsg: integer): integer; overload;
function GetFoldersMsg(const dir:string;var aStrings: TStringList;  aWnd: cardinal; aMsg: integer): integer; overload;
function GetFoldersThreeMsg(const dir:string;var aStrings: TStringList;  aWnd: cardinal; aMsg: integer): integer; overload;
(*Получение всех папок из определенной в dir папке файлов*)
function GetAllFolders(const dir: PChar;var strl: TStringList): integer; overload;
function GetAllFolders(const dir: string;var aSDA: TStringDynArray): integer; overload;
function GetAllFoldersFullPath(const dir: PChar;var strl: TStringList): integer;
function GetAllFoldersThree(const dir: PChar;var strl: TStringList): integer;
function GetAllFoldersThreeEx(const dir: string): string;

function FolderIsEmpty(const dir:string): boolean;

function GetDiskType(const aDisk : string) : integer;
function GetDiskShareName(const aDisk : string) : string;
function SetVolumeLabelEx(lpRootPathName: PWideChar; lpVolumeName: PWideChar) : integer;
function CheckNetWorkDisk(const aDrive, aPath, aLogin, aPassword, aVolumeName : string) : boolean;

function JSON_GetValueObject(obj : TJSONObject; const tag : string) : TJSONValue; inline;
function JSON_GetValue(obj : TJSONObject; const tag : string; var value : integer) : boolean;  overload; inline;
function JSON_GetValue(obj : TJSONObject; const tag : string; var value : string) : boolean; overload; inline;


procedure XML2String(const aXMLFileNameOrXMLBody:string ; var aResult  : string);
function ExtractTagStrings(const aXMLBody, aTag : string; var aRes : TStringDynArray) : boolean;
function ExtractTagBody(const aXMLBody, aTag : string; var aRes : TStringDynArray) : boolean;
(* Получение списка значений из XML строки типа <T A="" B=""></T> ----------- *)
function GetXMLTagAttributes(const aTagRow : string; var aAttr : TStringDynArray) : boolean;
function GetXMLTagValues(const XMLBody, Tag : string; var Values : TStringDynArray) : boolean;
function GetNodeValue(aNode : IDOMNode) : string;
(*Загрузка TTreeView из файла или содержимого XML --------------------------*)
procedure FillTreeViewFromXML(const aXMLFileNameOrXMLBody:string; aTreeView: TTreeView); overload;
procedure FillTreeViewFromXML(const aXMLFileNameOrXMLBody:string;const ERP : TEngRusPairs; aTreeView: TTreeView);overload;
(*Отображение результатов выполнения скриптов в формате XML ******************)
procedure ShowXMLTreeView(const aTitle, aXMLFileOrBody:string; const aCFGName:string = ''); overload;
procedure ShowXMLTreeView(const aTitle, aXMLFileOrBody:string;const ERP : TEngRusPairs; const aCFGName:string = ''); overload;
procedure ShowXMLInTreeView(const aTitle, aXMLFileOrBody:string; const aCFGName:string = ''); overload;
procedure ShowXMLInTreeView(const aTitle, aXMLFileOrBody:string;const ERP : TEngRusPairs; const aCFGName:string = ''); overload;
procedure FillTreeView(aTV: TTreeView;const Value:string);
procedure ShowStringInTreeView(const aTitle, Value:string; const aCFGName:string = '');
function ShowRGForm(const aRGTitle:string;const aItems: array of string; const aChBTitle:string;var aNeedSave: boolean; const aCFGName:string = ''): integer;


(*Подчистка символов если подряд больше одного*)
function SlimFastEx(const InString:string;const Chars:string):string; overload;
procedure SlimFastEx(const InString:string;const Chars:string; var Result:string); overload;
(*Получение всех элементов строки*)
procedure OneTokenNT(const Value, Delim:string;const Index: integer; var Result:string); overload;
function OneTokenNT(const Value, Delim:string;const Index: integer) :string; overload;
(*Описание единиц словами*)
function GetDefUnit(Number: integer; aDefUnits: TDefUnits):string;
function GetEnding(Number: integer; const SourceWord : string; ending: TDefEnding):string;
(*Запись числа словами  с указанием типа ед.измерения*)
function NumberByWords(aNumber: extended; DefUnits: TDefUnits = dfNone):string;
function NumericToWords(aNumber: extended; DefUnits: TDefUnits = dfNone):string;
function NumberToWords(aNumber: extended; DefUnits: TDefUnits = dfNone):string;
function Num2Str(aNumber: extended; DefUnits: TDefUnits):string;

function IntToBin(Value: Byte; aNeedSep: boolean = false):string; overload;
function IntToBin(Value: Word; aNeedSep: boolean = false):string; overload;
function IntToBin(Value: smallint; aNeedSep: boolean = false):string; overload;
function IntToBin(Value: DWORD; aNeedSep: boolean = false):string; overload;
function IntToBin(Value: integer; aNeedSep: boolean = false):string; overload;
function IntToBin(Value: int64; aNeedSep: boolean = false):string; overload;

(*Копирование части строки с указанием начального и конечного "якоря"*)
function CopyFromTo(const aInput, aFrom, aTo:string; aCI, aWithAnchors: boolean):string;

function SplitStringCI(const S, Delimiter:string): TStringDynArray;
function SplitStringCIstrl(const S, Delimiter:string): TStringDynArray;
function TransStrR(const S:string;const Old:string;const New: char) :string; overload;
function TransStrR(const S:string;const Old:string;const New:string) :string; overload;
function LeaveChars(const aInput : String; aLeaveChars : TSysCharSet) : string; overload; (*!!! см. описание !!!*)
function LeaveChars(const aInput : AnsiString; aLeaveChars : TSysCharSet) : string; overload;

function Translit(const src : string) : string;
function rumetaphone(const Source : string) : string;

function StringBeginWith(const StrValue, BeginValue : string; CI : boolean = true) : boolean;
function StringHasA(const StrValue, MidValue : string; CI : boolean = true) : boolean;
function StringEndIn(const StrValue, EndValue : string; CI : boolean = true) : boolean;

(*Массив символов в строку (ленивка) *****************************************)
function ArrayOfCharToString(const aArray: array of char(*; aNeedQuoted: boolean = false*)):string; overload;
function ArrayOfCharToString(const aArray: array of ansichar(*; aNeedQuoted: boolean = false*)):string; overload;
function AC2Str(const aArray: array of char(*; aNeedQuoted: boolean = false*)) :string; overload;
function AC2Str(const aArray: array of ansichar(*; aNeedQuoted: boolean = false*)) :string; overload;

function AC2StrQuote(const aArray: array of char; aQuote: char = #0) :string; overload;
function AC2StrQuote(const aArray: array of ansichar; aQuote: char = #0) :string; overload;

procedure AC2AC(const Source : array of char; var Dest : array of char); overload;
procedure AC2AC(const Source : array of ansichar; var Dest : array of ansichar); overload;




(*Строка в массив символов (ленивка) *****************************************)
procedure StringToArrayOfChar(const aString:string; var aArray: array of char); overload;
procedure Str2AC(const aString:string;var aArray: array of char); overload;
procedure StringToArrayOfChar(const aString: AnsiString; var aArray: array of ansichar); overload;
procedure Str2AC(const aString: AnsiString; var aArray: array of ansichar); overload;

procedure Str2PChar(const aString:string; var aDest : PChar); overload;
procedure Str2PChar(const aString:ansistring; var aDest : PAnsiChar); overload;

function String2DynInt(const aDelimiters,aSource : string; var aIDA : TIntegerDynArray) : boolean;
function DynInt2String(const aDelimiter : string; const aIDA : TIntegerDynArray) : string;

(*Перевод кодировок WIN - DOS. Обертка для CharToOEM и OEMToChar*)
function AnsiToOEM(const aSourceAnsi: AnsiString):string;
function OEMToAnsi(const aSourceOEM: AnsiString):string;

function StringInArray(const aTest:string; const aArray: array of string): boolean;

function CheckValidEMailAddress(const aAddr:string; var aResAddr : string): boolean;
(*проверка EMail адресов с возвратом валидного списка ************************)
function PrepareAddrList(const aSource:string; aCaseSensitive: boolean):string;
// -- for search in code --
// CheckEMail
// ValidateEMail
// ------------------------
function ExtractMsgId(const aSRC : string) : string;

// -- Нечёткий поиск в тексте и словаре : https://habrahabr.ru/post/114997/
function LevenshteinDistance(const s1,s2 : string) : integer;
function LevenshteinDistanceText(const s1, s2: string): integer;

function UnQuotedStr(const aStr, aQuot:string):string;

function Old_FloatToHex(aFloat : single) : string;  overload;
function Old_FloatToHex(aFloat : double) : string; overload;

function FloatToHex(aFloat : single) : string; overload; //4 bytes
function HexToFloat(const aHex : string; var aFloat : single): boolean; overload;
function FloatToHex(aFloat : double) : string; overload; //8 bytes
function HexToFloat(const aHex : string; var aFloat : double): boolean; overload;
function FloatToHex(aFloat : extended) : string; overload;//10 bytes
function HexToFloat(const aHex : string; var aFloat : extended): boolean; overload;

function HexToBinary(val : int64) : string;

// HexToFloat, HextToSingle, HexToDouble - в комментариях ниже

procedure ShowNotify(const aMessage, aTitle : string);
function ShowNotifyExt(const aMessage, aTitle : string) : boolean;
procedure FreeNotify;
(*Красивенькая InputQuery (реализация в конце описателей TQueryForm)*)
function InputQueryNew(const aTitle, aPrompt:string;var aText:string; aWithBackGnd : boolean = false): boolean;
(*Ленивка для MessageBox-ов ------------------------------------------------*)
procedure ShowMessageInfo(const aMessage:string;const aTitle:string = '');
procedure ShowMessageWarning(const aMessage:string;const aTitle:string = ''); overload;
procedure ShowMessageWarning(var NoShow : boolean; const aMessage:string;const aTitle:string = ''); overload;
procedure ShowMessageError(const aMessage:string;const aTitle:string = '');
(* MessageBox с задержкой включения кнопок подтверждения *)
function ShowMessageThink(ThinkTimeMS : integer; const strText, strCaption:string; uType : cardinal) :integer;
  function MsgBoxBtnItem(id: integer; const text : string) : TMsgBoxBtnItem;
procedure MessageBoxBtnChange(const DlgTitle : string; const Btns : array of TMsgBoxBtnItem);
function MessageBoxBtns(hWnd: HWND; lpText, lpCaption: PWideChar; uType: UINT; const Btns : array of TMsgBoxBtnItem) : Integer;
(*Другие ленивки -----------------------------------------------------------*)
procedure CreatePSA(var aPSA: PSecurityAttributes);
procedure InitalizePSA(var aPSA: PSecurityAttributes);
procedure CreatePSAEx(var aPSA: PSecurityAttributes);
procedure InitalizePSAEx(var aPSA: PSecurityAttributes);
(*Возвращает IP адрес локального компьютера*)
function LocalIP:string;
function GetIpConfig : string;
(*Получение имени рабочий станции*)
function GetWorkStationName:string;
function GetFullWorkStationName:string;
(*Получение имени пользователя*)
function GetUserName:string;
function GetUserNameEx(ANameFormat: DWORD): string;
(*Выполнение консольной программы*)
function RunCMD(const command: string):string; // -- через Pipe
function RunCMD2(const command: string; toAnsi : boolean = true):string; // -- через >file
function RunCMD3(const command: string; toAnsi : boolean = true):string; // -- через Pipe
function ConsolExec(const cmd : string; toAnsi : boolean) : string;
function ExecViaCMDFile(const command : string; needshowcommand : boolean) : string;



function IsValidURL(const aURL : string) : boolean; // : http://www.bog.pp.ru/sitelife/URI.html
procedure ParseURL(const aURL : string; var aProto, aHost, aParams : string);


function GetDefaultPrinter: string;
(*Нажать кнопку клавиатуры в окне*)
procedure WndKeyPress(const Wnd: HWND;const aKey: integer);

procedure SetVisibleRow3(aGrid: TDrawGrid; aRow: integer);
//-- Вот эта вроде устойчиво работает
function GetColRow(aDrGr : TDrawGrid; var aCol, aRow : integer) : boolean;


function ScrollMessageBox(const aTopText, aMLText, aBottomText, ACaption:string; aIconType: integer; aBtnType: integer; HTML : boolean = false): integer;

procedure SetWidthOfDropDownList(aCB: TComboBox);  overload;
procedure SetWidthOfDropDownList(aCB: TComboBox; aWidth : integer); overload;

(* HardWare and Divecis functions *)
function ShiftDown: boolean;
function AltDown: boolean;
function CtrlDown: boolean;

procedure Sound(Frequency, Duration: integer);//Hz, mS
procedure Monitor_On;
procedure Monitor_Off;
procedure Monitor_SavePower;
function GetMonitorAspectRatio(Width,Height : integer) : string;

(*Получение имени приложения по имени файла (документа)*)
procedure GetDocumentEXEName(const FileName:string;var Result:string);
(*Получение имени приложения по расширению файла (документа)*)
procedure GetEXENameForDocument(const DocExtention:string;var aEXEName:string);

function GetCurrentWordApp:string;
function GetCurrentExcelApp:string;
(*Получение символьного обозначения колонки MS Excel по номеру и наоборот --*)
function ExcelColNumIntoMnemonic(aNum: integer):string;
function ExcelColMnemonicToNum(const aValue:string): integer;
(*Выгрузка двухмерной таблицы в MSExcel через variant ************************)
procedure ArrayVariantToExcel(const aTitle:string;const aVarArray2D: variant; aBoldRowCount: integer = 0);
procedure ArrayVariantToExcelEx(const aTitle:string;const aVarArray2D: variant; aBoldRowCount: integer = 0); overload;
procedure ArrayVariantToExcelByCells(const aTitle:string;const aVarArray2D: variant; aECLS : TExcelCellLinkSet; aBoldRowCount: integer = 0); overload;
procedure ArrayVariantToExcelByCells(_Book : variant; const aTitle:string;const aVarArray2D: variant; aECLS : TExcelCellLinkSet; aBoldRowCount: integer = 0); overload;
procedure ArrayVariantToExcelEx(const aShablonName,aListName,aTitle : string;const aVarArray2D : variant; const aFormatList : TStringDynArray; aIsFormatCol: boolean; const aOffset : TGridCoord); overload;

procedure GetExcelSheets(const ExcelFileName : string; var sheets : TStringDynArray);

procedure ExcelToArrayVariant(const ExcelFileName : string; SheetNum,Rows,Columns  : integer; var Cells : variant);


function XL_GetDecimalSeparator : string;

function XL_GetShortDateFormat:String; overload;
function XL_GetShortDateFormat(XLApp : variant):String; overload;
function XL_GetNumberFormat:String; overload;
function XL_GetNumberFormat(XLApp : variant):String; overload;
function XL_GetIntFormat:String; overload;
function XL_GetIntFormat(XLApp : variant):String; overload;
function XL_GetCurrencyFormat(aLCID: integer):String; overload;
function XL_GetCurrencyFormat(XLApp : variant;aLCID: integer):String; overload;



function IsModal(aForm : TForm) : boolean;

(* Удаление секции из файла INI*)
function DeleteSection(const INIFileName, SectionName : string) : boolean;

(*Сохранение позиции формы*)
procedure SavePosition(aCtrl: TWinControl;const aEXEName:string;const aSection:string = 'Position');
procedure SaveSize(aCtrl: TWinControl;const aEXEName:string;const aSection:string = 'Position');
procedure SavePos(aCtrl: TWinControl;const aEXEName:string;const aSection:string = 'Position');
(*Восстановление позиции формы*)
procedure RestorePosition(aCtrl: TWinControl;const aEXEName:string; const aSection:string = 'Position');
procedure RestoreSize(aCtrl: TWinControl;const aEXEName:string;const aSection:string = 'Position');
procedure RestorePos(aCtrl: TWinControl;const aEXEName:string;const aSection:string = 'Position');

procedure CheckFormPos(aForm  :TCustomForm);
procedure CheckWindowPos(aWnd : cardinal);
function GetWindowByCursor : cardinal;

(*Сохранение размеров колонок*)
procedure SaveColumns(aForm: TForm; aGrid: TDrawGrid;const aEXEName:string; const aSection:string = 'Position'); overload;
procedure SaveColumns(aForm: TForm; aListView: TListView;const aEXEName:string; const aSection:string = 'Position'); overload;
(*Восстановление размеров колонок*)
procedure RestoreColumns(aForm: TForm; aGrid: TDrawGrid;const aEXEName:string;
  const aSection:string = 'Position'); overload;
procedure RestoreColumns(aForm: TForm; aListView: TListView;
  const aEXEName:string;const aSection:string = 'Position'); overload;
(*Сохранение размеров колонок при разных конфигурациях*)
procedure SaveColumnsEx(aForm: TForm; aGrid: TDrawGrid;const aEXEName:string; const aSection:string = 'Position');
(*Восстановление размеров колонок  при разных конфигурациях*)
procedure RestoreColumnsEx(aForm: TForm; aGrid: TDrawGrid;const aEXEName:string; const aSection:string = 'Position');
(*Saving Active Page Index of PageControl*)
procedure SavePageControl(aForm: TForm; aPageControl: TCustomTabControl;
  const aEXEName:string;const aSection:string = 'Position');
procedure SavePageControlByTabname(aForm: TForm; aPageControl: TPageControl;
  const TabName:string;const aEXEName:string;
  const aSection:string = 'Position');
procedure SavePageControlOrder(aForm: TForm; aPageControl: TPageControl;
  const aEXEName:string;const aSection:string = 'Position');
(*Restoring  Active Page Index of PageControl*)
procedure RestorePageControl(aForm: TForm; aPageControl: TCustomTabControl;
  const aEXEName:string;const aSection:string = 'Position');
procedure RestorePageControlByTabName(aForm: TForm; aPageControl: TPageControl;
  const aEXEName:string;const aSection:string = 'Position');
procedure RestorePageControlOrder(aForm: TForm; aPageControl: TPageControl;
  const aEXEName:string;const aSection:string = 'Position');
(*Установка двойной буфферизации на все контролы родительского контрола*)
procedure SetDoubleBuffered(aCtrl: TWinControl; Value: boolean = true);
procedure SetDoubleBufferedNoCheckListBox(aCtrl: TWinControl;
  Value: boolean = true);
(*Установка размера (Width) TCheckBox-а (типа AutoSize)*)
procedure SetCheckBoxSize(const aCheckBox: TCheckBox);
(*Получение реальной клиентской области TGroupBox и размера(pix) его Caption*)
function GetRealClientRectGroupBox(const aGroupBox: TGroupBox;
  var ResRect: TRect): integer;
function GetTopOfRadioGroupItem(RG : TRadioGroup; Index : integer): integer;

function GetTextHeightByWidth(const aText:string; aFont: TFont; aWidth: integer;
  aNeedWordBreak: boolean = false): integer;
function GetTextWidthByHeight(const aText:string; aFont: TFont;
  aHeight: integer; aNeedWordBreak: boolean = false): integer;
function GetTextSize(const aText:string; aFont: TFont): TSize;

function GetTextRect(const aText:string; aFont: TFont; aAlign: integer): TRect;

procedure CalculateTextRectByWidth(const aText:string; aWidth: integer;
  aFont: TFont; aAlign: integer;var aRect: TRect;var FontSize: integer;
  aMaxFont: integer = 46);
function CalculateTextFont(const aText:string; aFont: TFont;
  aWidth, aHeight, aStSize, aFnSize: integer;var aRect: TRect): integer;

procedure SetMemLogScroll(aMemo: TMemo);
procedure SetListBoxHorzScrolWidth(aLB: TListBox);overload;
procedure SetListBoxHorzScrolWidth(aLB: TListBox; aScrollWidth  :integer);overload;
procedure SetListBoxHorzScrolWidth(aLB: TCheckListBox);overload;
procedure SetListBoxHorzScrolWidth(aLB: TCheckListBox; aScrollWidth  :integer);overload;
procedure SetListBoxWidth(aLB: TListBox);
//procedure SetListBoxHorzScrolWidth(aChLB : TCheckListBox; aDop : integer = 0); overload;

(*Сохранение строки в INI файле*)
procedure SaveString(const Section, Param, Value, aEXEName:string);
(*Загрузка строки из INI файла*)
procedure LoadString(const Section, Param:string;var Value:string;  const aEXEName:string);
(*Сохранение BOOL в INI файле*)
procedure SaveBool(const Section, Param:string;const Value: boolean;  const aEXEName:string);
(*Загрузка Bool из INI файла*)
procedure LoadBool(const Section, Param:string;var Value: boolean;    const aEXEName:string);
(*Сохранение Integer в INI файле*)

function ArrayOfIntegerToString(const Value : TIntegerDynArray): string; // string of hex(8)
procedure StringToArrayOfInteger(const aStr : string; var Value : TIntegerDynArray);

procedure SaveInteger(const Section, Param:string;const Value: integer;  const aEXEName:string);
procedure SaveArrayOfInteger(const Section, Param:string;const Value : TIntegerDynArray; const aEXEName:string);
(*Загрузка Integer из INI файла*)
procedure LoadInteger(const Section, Param:string;var Value: integer;   const aEXEName:string);
procedure LoadArrayOfInteger(const Section, Param:string;var Value: TIntegerDynArray; const aEXEName:string);
(*Сохранение Float в INI файле*)
procedure SaveFloat(const Section, Param:string;const Value: double;    const aEXEName:string); overload;
procedure SaveFloat(const Section, Param:string;const Value: Single;    const aEXEName:string); overload;
procedure SaveFloat(const Section, Param:string;const Value: extended;  const aEXEName:string); overload;
(*Загрузка Float из INI файла*)
procedure LoadFloat(const Section, Param:string;var Value: double; const aEXEName:string); overload;
procedure LoadFloat(const Section, Param:string;var Value: Single;  const aEXEName:string); overload;
procedure LoadFloat(const Section, Param:string;var Value: extended;  const aEXEName:string); overload;
procedure LoadFloatEx(const Section, Param:string;var Value: double; const aEXEName:string); overload;
procedure LoadFloatEx(const Section, Param:string;var Value: Single; const aEXEName:string); overload;
procedure LoadFloatEx(const Section, Param:string;var Value: extended; const aEXEName:string); overload;
(*Сохранение DateTime в INI файле*)
procedure SaveDateTime(const Section, Param:string;const Value: TDateTime; const aEXEName:string);
(*Загрузка DateTime из INI файла*)
procedure LoadDateTime(const Section, Param:string;var Value: TDateTime; const aEXEName:string);
(*Восстановление TDateTime из строки по формату*)
function StrToDateTimeByFormat(const aInputStrDate, aFormatStr:string) : TDateTime;
(* Выдает дату строкой с падежом месяца                                       *)
function GetLongDate(ThisDate : Tdate;QuotesDay : string = ''): string;
function GetLongDateY(ThisDate : Tdate;QuotesDay : string = ''): string;




function SecondsToHMS(aBigNumSeconds: int64; var aHours, aMinutes, aSeconds: Word): TTime;
function MinutesToHM(aBigNumMinutes: integer; var aHours, aMinutes: integer): TTime;
function MinSecToMinDecimal(const aMinSecStr : string) : single;
function SecondsToDecimal(aSeconds : integer) : single;
function SecondsToTime(aSeconds: int64): TTime; overload;
function SecondsToTime(aSeconds: int64; var Days : integer): TTime; overload;

function MinutesToTime(aMinutes: cardinal): TTime;
function MinutesToDateTime(aMinutes: int64): TDateTime;
function TimeToMinutes(aTime: TTime): int64;
function DateTimeToMinutes(aDateTime: TDateTime): int64;
function TimeToSeconds(aTime: TTime): int64;
function TimeToSecondsDouble(aTime: TTime): double;
function TimeToMSec(aDateTime: TDateTime): int64;
function MSecToTime(aMS : int64) : TTime;
function MSecToDateTime(aMS: int64): TDateTime;
function GetWindowsWorkTime(out days : integer) : TDateTime;

function DateTime(aValue : single) : TDateTime; overload;
function DateTime(aValue : real) : TDateTime; overload;
function DateTime(aValue : extended) : TDateTime; overload;

(* Работа с датой и временем представленными в формате Unix                   *)
function UnixTimeToDateTime(UnixTime : int64) : TDateTime;
function DateTimeToUnixTime(DateTime : TDateTime) : int64;


(*время работы по двум временным отрезкам*)
procedure GetWorkTime(aStartDateTime: TDateTime;var aDays: integer; var aTimes: TTime;var aDisplayString:string; aNeedMs: boolean = false); overload;
procedure GetWorkTime(aStartDateTime, aFinishDateTime: TDateTime;var aDays: integer;var aTimes: TTime;var aDisplayString:string; aNeedMs: boolean = false); overload;
function AboutInterval(aDateTime: TDateTime):string;
(*время работы по кол-ву минут и времени РАБОЧЕГО дня в ЧАСАХ*)
procedure GetRealWorkTime(aMinutes: integer;var aDays: integer;var aTime: TTime; var aStr:string; aWorkDay: integer = 9);
function GetCPUCount : integer;

(*Количество дней в месяце*)
function DaysThisMonth(const month, Year: Word): integer;
function GetLastDay(const month, Year: Word): integer;
(*Week Number*)
function GetWeek(const ADate: TDateTime): Word;//standart calculated
(*Номер квартала по месяцу*)
function GetQuart(const aMonth: integer): integer;
(*Попытка эмуляции DATEDIFF MSSQL*)
function DateDiff(aDatePart: TDatePart; const aStartDate, aEndDate: TDateTime): int64;
procedure DateDiffYMD(const aStartDate, aEndDate: TDateTime; var aYearsCount, aMonthsCount, aDaysCount: integer);
procedure DateDiffYMD_Diff(const aStartDate, aEndDate: TDateTime; var aYearsCount, aMonthsCount, aDaysCount: integer);
function DateDiffYMD_Diff_ByWords(const aStartDate, aEndDate: TDateTime):string;
(*Попытка эмуляции DATEPART MSSQL*)
function DatePart(aDatePart: TDatePart;const ADate: TDateTime): integer;
function DayOfWeekRus(aDate : TDateTime) : integer;
procedure GetQuartDates(aNumQuart, aYear: Word;var aStDate, aFndate: TDate);
function GetRusMonthNumber(const aFullRusMonthName : string) : integer;
function ThisYear : word;
function Replicate(const aStr : string; aNumber : integer) : string;


function GetWindowClassName(aWnd: HWND):string;
function GetWndText(aWnd: HWND):string;
function GetWindowTextEx(aWnd: HWND):string;
function GetWindowAppHandle(aWnd: HWND): cardinal;
function GetWindowPID(aWnd: HWND): cardinal;
function GetCurrentProcessHandle: cardinal; // -- практически то же что и HInstance, но надежнее, красивее и без непонятных ошибок при работе с открытыми EXE файлами с секцией exports
function GetProcessModule(aPID : cardinal): string;
function GetParentProcess(aPID : cardinal; var aParentPID : cardinal; var aParentEXE : string): boolean;
function GetWindowClassNameArr(aWnd: HWND):string;
procedure ListOfWindows(const ParentHandle: cardinal;var WndDescrs: TWndDescrs);
function GetWindowEXEModuleName(wnd:HWND):string; // для Win2K/XP. В Win9x нужно юзать GetWindowModuleFileName
function GetFullFileNameForPID(const aPID: cardinal) : string;
function GetFullFileNameForWindow(const WndHandle: cardinal) : string;

procedure SaveBytes(const aBytes: TByteDynArray;const aFileName:string);overload;
procedure SaveBytes(const aBytes: array of byte;const aFileName:string);overload;
procedure SaveBytes(const aBytes: TBytes;const aFileName:string);overload;


function GDV(const Value: variant):string; overload;
function GDV(aValue: TVarRec):string; overload;
function VarArrayToString(Value : variant) : string;
function VarArray1DToString(Value : variant) : string;
procedure GetDataSet(aADOc: TADOConnection;const aTableName, aOrder:string; var aResdataSet: TVariantArrayD2);
function GetTagData(const aXMLUnit, aTag:string):string;

(*3D треугольник показывающий сортировку*)
procedure SimpleTriAngleOrder(aCanvas: TCanvas; aLeft, aTop: integer;
  Desc: boolean; TriangleOrderBaseColor: TTriangleOrderBaseColor = ttobcGray;
  height: integer = 17); overload;
procedure SimpleTriAngleOrder(aDC: hDC; aLeft, aTop: integer; Desc: boolean;  TriangleOrderBaseColor: TTriangleOrderBaseColor = ttobcGray;  height: integer = 17); overload;
procedure DrawOrder(aDC: hDC; aRct: TRect; Desc: boolean; TriangleOrderBaseColor: TTriangleOrderBaseColor = ttobcGray);
procedure SimpleTriAngleRight(aDC: hDC; aTop, aLeft: integer; IsOn: boolean;  height: integer = 17);
procedure DrawGradient(aCanvas: TCanvas; Rect: TRect; aVertical: boolean;  Colors: array of TColor); overload;
procedure DrawGradient(aDC: hDC; Rect: TRect; Horizontal: boolean;  Colors: array of TColor); overload;
procedure ConvertColor(aStartColor, aFinishColor: TColor; var aCurrentColor: TColor;var aToFinishColor: boolean); overload;
procedure ConvertColor(var aColors: array of TColor;  var aToFinishColor: boolean); overload;
(*Отображение текста под определенным углом . Угол 10 задается как 100*)
procedure TextRotateDC(dc: hDC; X, Y: integer; lf: TLogFont; ClrTxt: TColor;
  sRotate: PChar; angle: integer); stdcall; overload;
procedure TextRotateDC(dc: hDC; Font: TFont; aRct: TRect; ShowStr: PChar;
  angle: integer; alg: integer = 0); stdcall; overload;
procedure TextRotateDC(dc: hDC; Font: hFont; aRct: TRect; ShowStr: PChar;
  angle: integer; alg: integer = 0);  stdcall; overload;

procedure FillImageListFromResource(aIL: TImageList;const aResourceName:string; aDefSize: integer = 16);
function AddIconForFile(aIL: TImageList;const aFileName:string) : integer;

function RgbToGray(RGBColor: TColor): ColorRef;
function ColorToGray(aColor: TColor) : TColor; overload;
procedure Color2RGB(aColor: TColor; var R,G,B : byte);
procedure ColorToGray(aDC: hDC; aRect: TRect); overload;
procedure ColorToGrayExColor(aDC: hDC; aRect: TRect; aColor: TColor);
procedure RGBtoHLS(RGB: TColor;var H, L, S: integer);
function HLStoRGB(H, L, S: integer): TColor;
procedure RGBToCMYK(R ,G ,B : byte; var C ,M ,Y ,K : byte);
procedure CMYKTORGB(C ,M ,Y ,K : byte; var R ,G ,B : byte);
function AsByte(val : integer) : byte;


function LightColor(aColor: TColor; aLighter: Byte): TColor;
function DarkColor(aColor: TColor; aLighter: Byte): TColor;

procedure LightBitmap(bmp : TBitmap; aLighter: Byte; trnColor : TColor = clFuchsia);

procedure VistaButton(aCanvas: TCanvas; aRect: TRect; aBaseColor: TColor; aUp: boolean = true); overload;
procedure VistaButtonRound(aCanvas: TCanvas; aRect: TRect; aBaseColor: TColor; aUp: boolean = true); overload;
procedure VistaButton(aDC: hDC; aRect: TRect; aBaseColor: TColor; aUp: boolean = true); overload;
procedure VistaButtonRound(aDC: hDC; aRect: TRect; aBaseColor: TColor; aUp: boolean = true); overload;
procedure VistaButtonRoundCaption(wnd: hWnd; aRect: TRect; aBaseColor: TColor; aOver : boolean; aUp: boolean = true);
function ThemeIsAero : boolean;
function HTMLRGBtoColor(const aClrStr6 : shortstring) : TColor; overload;
function HTMLRGBtoColor(const aClrStr6 : string) : TColor; overload;
function ColorToHTMLColor(aColor : TColor) : string;
function ColorToRGBString(aColor : TColor) : string;


(*Список доступных MSSQL серверов*)
function GetListOfMSSQLServers(var aListOfServers: TStringList): integer;

(*Сортировки (Содрано из Demos\Threads)*)
procedure BubbleSort(var A: array of integer); overload;
procedure BubbleSort(var A: array of Real); overload;
procedure SelectionSort(var A: array of integer); overload;
procedure SelectionSort(var A: array of Real); overload;
procedure QuickSort(var A: array of integer);  overload;
procedure QuickSort(var A: array of Real);  overload;
procedure QuickSort(var A: array of Word);  overload;
procedure QuickSort(var A: array of DWord);  overload;

(* Сортировка точек по кругу                                                  *)
procedure SortPointsByCircle(var aPoints : TPointDynArray; var CentralPoint : TPoint);
procedure SortPointsByCircle2(var aPoints : array of TPoint; var CentralPoint : TPoint);

function CheckExistsForm(aFormClass: TClass): boolean;

function CreateFileW(lpFileName: PWideChar; dwDesiredAccess, dwShareMode: DWORD;
  lpSecurityAttributes: PSecurityAttributes;
  dwCreationDisposition, dwFlagsAndAttributes: DWORD; hTemplateFile: THandle)
  : THandle; stdcall; external kernel32;

function AlphaBlendBlt(hdcDest: hDC; xoriginDest, yoriginDest, wDest,
  hDest: integer; hdcSrc: hDC; xoriginSrc, yoriginSrc, wSrc, hSrc: integer;
  const ftn: BLENDFUNCTION): boolean; stdcall;
  external 'MSIMG32.DLL' name 'AlphaBlend';

function UuidCreate(var GUID: TGUID): HResult; stdcall; external 'Rpcrt4.dll';

var
 _AppIniUserFile : string = '';

implementation

(******************************************************************************)

(*Быстрая StringReplace (StringReplaceEx) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

//function StringReplace(const aString, aOldPattern, aNewPattern: string; aFlags: TReplaceFlags): string;
//begin
//Result:=StringReplaceEx(aString, aOldPattern, aNewPattern, aFlags);
//end;

var
  AnsiUpcase: packed array[Char] of Char; {Upcase Lookup Table}
  srCodePage: UINT; {Active String Replace Windows CodePage}

{Setup Lookup Table for Ansi Uppercase}
procedure InitialiseAnsiUpcase;
var
  Ch: Char;
begin
  srCodePage := GetACP;
  for Ch := #0 to #255 do
    AnsiUpcase[Ch] := Ch;
  CharUpperBuffA(@AnsiUpcase, 256);
end;
(*Быстрая StringReplace (StringReplaceEx) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)


procedure AddBooleanValues;
const
 valTrue  : array[0..4] of string = ('true','Да','Yes','1','.T.');
 valFalse : array[0..4] of string = ('false','Нет','No','0','.F.');
var
 ind : integer;
 cnt : integer;
begin
for cnt:=0 to High(valTrue)
  do begin
  ind:=Length(TrueBoolStrs);
  SetLength(TrueBoolStrs, ind+1);
  TrueBoolStrs[ind]:=valTrue[cnt];
  end;
for cnt:=0 to High(valFalse)
  do begin
  ind:=Length(FalseBoolStrs);
  SetLength(FalseBoolStrs, ind+1);
  FalseBoolStrs[ind]:=valFalse[cnt];
  end;
end;

procedure InitProc;
var
 FN : string;
begin
//Randomize;
PatchINT3;

SizeOfChar    := SizeOf(char);
SizeOfWord    := SizeOf(Word);
SizeOfInteger := SizeOf(integer);
SizeOfDWord   := SizeOf(DWord);
SizeOfInt64   := SizeOf(int64);
try
FN:=Trim(ChangeFileExt(ExtractFileName(ParamStr(0)),'.INI'));
_AppIniUserFile:=Trim(SetTailBackSlash(GetDocFolder))+CFGSoftFolder+ChangeFileExt(FN,'')+'\';
if DirectoryExists(_AppIniUserFile) or
   ForceDirectories(_AppIniUserFile)
   then _AppIniUserFile:=Trim(_AppIniUserFile+FN+#0)
   else _AppIniUserFile:=Trim(SetTailBackSlash(GetTempFolder)+FN);

srCodePage := 0; {Invalidate AnsiUpcase Lookup Table}
InitialiseAnsiUpcase; //test
FN:=ChangeFileExt(ExtractFileName(ParamStr(0)),'')+'Start';
AtomNameStart := AllocMem(Length(FN)*SizeOfChar+1);
StrPCopy(AtomNameStart,FN);
FN:=ChangeFileExt(ExtractFileName(ParamStr(0)),'')+'Work';
AtomNameWork := AllocMem(Length(FN)*SizeOfChar+1);
StrPCopy(AtomNameWork,FN);
except
_AppIniUserFile:=Trim(SetTailBackSlash(GetTempFolder)+'App.ini');
end;
AddBooleanValues;
end;

procedure FinalProc;
begin
if GetInstanceCount<=1
   then ClearAtom(AtomNameWork)
   else GlobalDeleteAtom(GlobalFindAtom(AtomNameWork));
ClearAtom(AtomNameStart);
FreeMem(AtomNameWork);
FreeMem(AtomNameStart);
end;



(******************************************************************************)

var
  WndDesrscLocal: TWndDescrs;
//used in :
// function TWndDescrsEx.Fill
// procedure ListOfWindows

function EWPChilds(hwndNext: HWND; lp: LParam): boolean; stdcall;
var
  Chars: array[0 .. 255]of char;
  ln: integer;
  procedure GetFileName(const WndHandle: cardinal;
    var ModuleName: array of char);
  var
    ProcessID: DWORD;
    snap: cardinal;
    pe32: TPROCESSENTRY32;
    me32: TMODULEENTRY32;
  begin
    GetWindowThreadProcessId(WndHandle,@ProcessID);
    snap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS or TH32CS_SNAPMODULE,
      ProcessID);
    try
      if snap <> 0 then
      begin
        pe32.dwSize := SizeOf(TPROCESSENTRY32);
        me32.dwSize := SizeOf(TMODULEENTRY32);
        if Process32First(snap, pe32)then
        begin
          Module32First(snap, me32);
          if pe32.th32ProcessID = ProcessID then
          begin
            StrCopy(ModuleName, me32.szExePath);
            StrCopy(ModuleName, pe32.szExeFile);
            (*. . .*)
          end
          else
          begin
            while Process32Next(snap, pe32)do
            begin
              Module32Next(snap, me32);
              if pe32.th32ProcessID = ProcessID then
              begin
                StrCopy(ModuleName, me32.szExePath);
                //StrCopy(ModuleName,pe32.szExeFile);
                (*. . .*)
                Break;
              end;
            end;
          end;
          //ExtractIcon(hInstance,pe32.szExeFile,0);
        end;
      end;
    finally
      CloseHandle(snap);
    end;
  end;
  procedure GetFileNameME(const WndHandle: cardinal;
    var ModuleName: array of char);
  var
    ProcessID: DWORD;
    snap: cardinal;
    sz: integer;
    me32: TMODULEENTRY32;
  begin
    GetWindowThreadProcessId(WndHandle,@ProcessID);
    snap := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, ProcessID);
    try
      if snap <> 0 then
      begin
        sz := SizeOf(TMODULEENTRY32);
        FillChar(me32, sz, 0);
        me32.dwSize := sz;
        if Module32First(snap, me32)then
        begin
          if me32.th32ProcessID = ProcessID then
            StrCopy(ModuleName, me32.szExePath)
          else
            while Module32Next(snap, me32)do
            begin
              if me32.th32ProcessID = ProcessID then
              begin
                StrCopy(ModuleName, me32.szExePath);
                Break;
              end;
            end;
        end;
      end;
    finally
      CloseHandle(snap);
    end;
  end;

  function UTF8ToStrInner(Value:String):String;
  var
    Buffer: Pointer;
    BufLen: LongWord;
  begin
    BufLen := Length(Value)+ 4;
    GetMem(Buffer, BufLen);
    FillChar(Buffer^, BufLen, 0);
    MultiByteToWideChar(CP_UTF8, 0,@Value[1], BufLen - 4, Buffer, BufLen);
    Result := WideCharToString(Buffer);
    FreeMem(Buffer, BufLen);
  end;

var
  tmp:string;
  wnds: TWndDescr;
begin
  Result := true;
  if hwndNext <> 0 then
  begin
    FillChar(Chars, 256, 0);
    GetClassName(hwndNext, Chars, 255);
    if(Chars[0]<> #0) and
      ((lp=0) or (StrPas(PChar(lp))=''))
      then begin
      FillChar(wnds, SizeOf(TWndDescr), 0);
      wnds.Handle := hwndNext;
      StrCopy(wnds.ClassName, Chars);
      tmp := GetWndText(wnds.Handle);
      Str2AC(tmp, wnds.WndText);
      GetFileNameME(wnds.Handle, wnds.FileName);
      wnds.Parent := GetParent(wnds.Handle);
      ln := Length(WndDesrscLocal);
      SetLength(WndDesrscLocal, ln + 1);
      System.Move(wnds, WndDesrscLocal[ln], SizeOf(TWndDescr));
      end
      else
      Result := false;
  end;
end;


function TWndDescrsEx.Fill(aParent : cardinal; aWithClear : boolean) : integer;
begin
if aWithClear
   then SetLength(Items, 0);
Result := Length(Items);
SetLength(WndDesrscLocal, 0);
  try
  EnumChildWindows(aParent,@EWPChilds, 0);
  SetLength(Items, Result + Length(WndDesrscLocal));
  if Length(WndDesrscLocal)> 0
     then System.Move(WndDesrscLocal[0], Items[Result], SizeOf(TWndDescr)* Length(WndDesrscLocal));
  finally
  SetLength(WndDesrscLocal, 0);
  end;
Result := Length(Items);
end;

function TWndDescrsEx.Add(aWD: TWndDescr): integer;
var
  ind: integer;
begin
  try
    ind := FindWnd(aWD.Handle);
    if ind =-1 then
    begin
      ind := Length(Items);
      SetLength(Items, ind + 1);
      System.Move(aWD, Items[ind], SizeOf(TWndDescr));
    end;
    Result := ind;
  except
    on E: Exception do
      Result :=-1;
  end;
end;

function TWndDescrsEx.FindWnd(const aText:string): integer;
var
  cnt: integer;
  tmp:string;
begin
  Result :=-1;
  tmp := AnsiUpperCase(aText);
  for cnt := 0 to High(Items)do
    if(AnsiPos(tmp, AnsiUpperCase(AC2Str(Items[cnt].WndText)))<> 0)or
      (tmp = AnsiUpperCase(AC2Str(Items[cnt].ClassName)))then
    begin
      Result := cnt;
      Exit;
    end;
end;

function TWndDescrsEx.FindWnd(aWnd: cardinal): integer;
var
  cnt: integer;
begin
  Result :=-1;
  for cnt := 0 to High(Items)do
    if aWnd = Items[cnt].Handle then
    begin
      Result := cnt;
      Exit;
    end;
end;

procedure TWndDescrsEx.Delete(Index : integer);
begin
if (Index>=Low(Items)) and (Index<=High(Items))
   then begin
   if Index<>High(Items)
      then System.Move(Items[Index+1],Items[Index],(High(Items)-Index) * SizeOf(TWndDescr));
   Setlength(Items,Length(Items)-1);
   end;
end;

procedure TWndDescrsEx.Clear;
begin
  SetLength(Items, 0);
end;

(******************************************************************************)

{** ВАЖНО! Патч для ntdll.dll ********** НЕ УДАЛЯТЬ! ** для WinXP, Win2000 etc like WinNT}
procedure PatchINT3; //stdcall;
//var
//  NOP: Byte;
//  BytesWritten: DWORD;
//  NtDll: THandle;
//  P: Pointer;
begin
//  if Win32Platform <> VER_PLATFORM_WIN32_NT then
//    Exit;
//  NtDll := GetModuleHandle('NTDLL.DLL');
//  if NtDll = 0 then
//    Exit;
//  P := GetProcAddress(NtDll, 'DbgBreakPoint');
//  if P = nil then
//    Exit;
//  try
//    if char(P^)<> #$CC then
//      Exit;
//    NOP := $90;
//    if WriteProcessMemory(GetCurrentProcess, P,@NOP, 1, BytesWritten)and
//      (BytesWritten = 1)then
//      FlushInstructionCache(GetCurrentProcess, P, 1);
//  except
//    //Do not panic if you see an EAccessViolation here,  it is perfectly harmless!
//    on EAccessViolation do;
//    else
//      raise;
//  end;
end;

procedure CheckVersionIE; overload;
const
 key = '\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION';
 IE_EmulVer = 11001;
var
 errStep : string;
 RegKey  : TRegistry;
 app     : string;
begin
errStep:='';
try
RegKey:=TRegistry.Create;
try
RegKey.RootKey:=HKEY_CURRENT_USER;
if not RegKey.KeyExists(key)
   then if not RegKey.CreateKey(key)
           then begin
           errStep:='No Key exists : '+key;
           Exit;
           end;
if not RegKey.OpenKey(key, false)
   then begin
   errStep:='Can not open Key for write : '+key;
   Exit;
   end;
app:=ExtractFileName(ParamStr(0));
if not RegKey.ValueExists(app)
   then RegKey.WriteInteger(app,IE_EmulVer);
RegKey.CloseKey;
finally
RegKey.Free;
end;
except
 on E : Exception do ;
end;
end;

procedure CheckVersionIE(aRoot: HKEY; const aKey : string; aVers : integer); overload;
var
 errStep : string;
 RegKey  : TRegistry;
 app     : string;
begin
errStep:='';
try
RegKey:=TRegistry.Create;
try
RegKey.RootKey:=aRoot;
if not RegKey.KeyExists(aKey)
   then if not RegKey.CreateKey(aKey)
           then begin
           errStep:='No Key exists : '+aKey;
           Exit;
           end;
if not RegKey.OpenKey(aKey, false)
   then begin
   errStep:='Can not open Key for write : '+aKey;
   Exit;
   end;
app:=ExtractFileName(ParamStr(0));
if not RegKey.ValueExists(app)
   then RegKey.WriteInteger(app,aVers);
RegKey.CloseKey;
finally
RegKey.Free;
end;
except
 on E : Exception do ;
end;
end;

//https://msdn.microsoft.com/en-us/library/ee330730%28VS.85%29.aspx#browser_emulation
procedure CallCheckVersionIE(aBaseVers : integer = 9999);
type
 TEIEmulItem = record
   Root : hkey;
   Key  : string[255];
 end;

const
 BaseVers = 9999;
 //; Vers:11001
 Keys : array[0..2] of TEIEmulItem = (
 (Root:HKEY_CURRENT_USER ; Key: '\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION' ),
 (Root:HKEY_LOCAL_MACHINE; Key: '\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION'),
 (Root:HKEY_LOCAL_MACHINE; Key: '\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION')
 );
var
 cnt : integer;
begin
try
for cnt:=Low(Keys) to High(Keys) do with Keys[cnt] do CheckVersionIE(Root, string(Key), aBaseVers);
except
 on E : Exception do;
end;
end;

function IsDebug : boolean;
begin
{-$WARN SYMBOL_PLATFORM OFF}
Result:=DebugHook<>0;
{-$WARN SYMBOL_PLATFORM ON}
end;

(******************************************************************************)

(******************************************************************************)
type
  PVector =^TVector;

  TVector = record
    X: integer;
    Y: integer;
    Delta: integer;
    Next: PVector;
  end;

var
  HorzVect: PVector;
  VertVect: PVector;
  VectCount: integer;

function MakeIntegerA(Count: integer; Counts: array of integer;
  Points: array of TPoint): TIntegerDynArray;
var
  i, j: integer;
begin
  SetLength(Result, 1 + Count + Length(Points)* 2);
  j := 0;
  Result[j]:= Count;
  Inc(j);
  for i := 0 to Count - 1 do
  begin
    Result[j]:= Counts[i];
    Inc(j);
  end;
  for i := 0 to Length(Points)- 1 do
  begin
    Result[j]:= Points[i].X;
    Inc(j);
    Result[j]:= Points[i].Y;
    Inc(j);
  end;
end;

function AddVector(Vect: PVector; NewX, NewY, NewDelta: integer): PVector;
begin{function AddVector(Vect: PVector; xn, yn, dn: Integer): PVector}
  New(Result);
  with Result^do
  begin
    X := NewX;
    Y := NewY;
    Delta := NewDelta;
    Next := Vect;
  end;
  Inc(VectCount);
end;{function AddVector(Vect: PVector; xn, yn, dn: Integer): PVector}

function MakeRegion(const bmp: Graphics.TBitmap; BkColor: TColor)
  : TIntegerDynArray;
var
  Points: array of TPoint;
  Counts: array of integer;
  Count: integer;
  Index: integer;

  function IsFront(Color1, Color2, BkColor: TColor): integer;
  begin{function IsFront(Color1, Color2, BkColor: TColor): Integer}
    Result := 0;
    if Color1 <> BkColor then
    begin
      Result := Result or 1;
    end;
    if Color2 <> BkColor then
    begin
      Result := Result or 2;
    end;
    Result := Result mod 3;
  end;{function IsFront(Color1, Color2, BkColor: TColor): Integer}

  procedure HorzScan;
    procedure FirstScan;
    var
      X: integer;
      x0, D: integer;
    begin{procedure FirstScan}
      with bmp.Canvas do
      begin
        X := 0;
        while X < bmp.Width do
        begin
          while(X < bmp.Width)and(Pixels[X, 0]= BkColor)do
          begin
            Inc(X);
          end;
          if X < bmp.Width then
          begin
            x0 := X;
            D := 0;
            while(X < bmp.Width)and(Pixels[X, 0]<> BkColor)do
            begin
              Inc(D);
              Inc(X);
            end;
            HorzVect := AddVector(HorzVect, x0, 0, D);
          end;
        end;
      end;
    end;{procedure FirstScan}

    procedure MiddleScan;
    var
      X, Y: integer;
      x0, D: integer;
    begin{procedure MiddleScan}
      with bmp.Canvas do
      begin
        for Y := 1 to bmp.height - 1 do
        begin
          X := 0;
          while X < bmp.Width do
          begin
            while(X < bmp.Width)and
              (IsFront(Pixels[X, Y - 1], Pixels[X, Y], BkColor)= 0)do
            begin
              Inc(X);
            end;
            if X < bmp.Width then
            begin
              x0 := X;
              D := 0;
              if IsFront(Pixels[X, Y - 1], Pixels[X, Y], BkColor)= 2 then
              begin
                while(X < bmp.Width)and
                  (IsFront(Pixels[X, Y - 1], Pixels[X, Y], BkColor)= 2)do
                begin
                  Inc(D);
                  Inc(X);
                end;
              end
              else
              begin
                while(X < bmp.Width)and
                  (IsFront(Pixels[X, Y - 1], Pixels[X, Y], BkColor)= 1)do
                begin
                  Inc(D);
                  Inc(X);
                end;
                Inc(x0, D);
                D :=-D;
              end;
              HorzVect := AddVector(HorzVect, x0, Y, D);
            end;
          end;
        end;
      end;
    end;{procedure MiddleScan}

    procedure LastScan;
    var
      X, Y: integer;
      x0, D: integer;
    begin{procedure LastScan}
      Y := bmp.height;
      with bmp.Canvas do
      begin
        X := 0;
        while X < bmp.Width do
        begin
          while(X < bmp.Width)and(Pixels[X, Y - 1]= BkColor)do
          begin
            Inc(X);
          end;
          if X < bmp.Width then
          begin
            x0 := X;
            D := 0;
            while(X < bmp.Width)and(Pixels[X, Y - 1]<> BkColor)do
            begin
              Inc(D);
              Inc(X);
            end;
            HorzVect := AddVector(HorzVect, x0 + D, Y,-D);
          end;
        end;
      end;
    end;{procedure LastScan}

  begin{procedure HorzScan}
    HorzVect := nil;
    FirstScan;
    MiddleScan;
    LastScan;
  end;{procedure HorzScan}

  procedure VertScan;
    procedure FirstScan;
    var
      Y: integer;
      y0, D: integer;
    begin{procedure FirstScan}
      with bmp.Canvas do
      begin
        Y := 0;
        while Y < bmp.height do
        begin
          while(Y < bmp.height)and(Pixels[0, Y]= BkColor)do
          begin
            Inc(Y);
          end;
          if Y < bmp.height then
          begin
            y0 := Y;
            D := 0;
            while(Y < bmp.height)and(Pixels[0, Y]<> BkColor)do
            begin
              Inc(D);
              Inc(Y);
            end;
            VertVect := AddVector(VertVect, 0, y0 + D,-D);
          end;
        end;
      end;
    end;{procedure FirstScan}

    procedure MiddleScan;
    var
      X, Y: integer;
      y0, D: integer;
    begin{procedure MiddleScan}
      with bmp.Canvas do
      begin
        for X := 1 to bmp.Width - 1 do
        begin
          Y := 0;
          while Y < bmp.height do
          begin
            while(Y < bmp.height)and
              (IsFront(Pixels[X - 1, Y], Pixels[X, Y], BkColor)= 0)do
            begin
              Inc(Y);
            end;
            if Y < bmp.height then
            begin
              y0 := Y;
              D := 0;
              if IsFront(Pixels[X - 1, Y], Pixels[X, Y], BkColor)= 2 then
              begin
                while(Y < bmp.height)and
                  (IsFront(Pixels[X - 1, Y], Pixels[X, Y], BkColor)= 2)do
                begin
                  Inc(D);
                  Inc(Y);
                end;
                Inc(y0, D);
                D :=-D;
              end
              else
              begin
                while(Y < bmp.height)and
                  (IsFront(Pixels[X - 1, Y], Pixels[X, Y], BkColor)= 1)do
                begin
                  Inc(D);
                  Inc(Y);
                end;
              end;
              VertVect := AddVector(VertVect, X, y0, D);
            end;
          end;
        end;
      end;
    end;{procedure MiddleScan}

    procedure LastScan;
    var
      X, Y: integer;
      y0, D: integer;
    begin{procedure LastScan}
      X := bmp.Width;
      with bmp.Canvas do
      begin
        Y := 0;
        while Y < bmp.height do
        begin
          while(Y < bmp.height)and(Pixels[X - 1, Y]= BkColor)do
          begin
            Inc(Y);
          end;
          if Y < bmp.height then
          begin
            y0 := Y;
            D := 0;
            while(Y < bmp.height)and(Pixels[X - 1, Y]<> BkColor)do
            begin
              Inc(D);
              Inc(Y);
            end;
            VertVect := AddVector(VertVect, X, y0, D);
          end;
        end;
      end;
    end;{procedure LastScan}

  begin{procedure VertScan}
    VertVect := nil;
    FirstScan;
    MiddleScan;
    LastScan;
  end;{procedure VertScan}

  procedure MakeLinks;

    function LinkOne: integer;

      function Remove(var Vect: PVector; i: PVector): TVector;

        procedure AddPoint(x0, y0: integer);
        begin{procedure AddPoint(x0, y0: Integer)}
          Points[Index].X := x0;
          Points[Index].Y := y0;
          Inc(Index);
        end;{procedure AddPoint(x0, y0: Integer)}

      var
        Old: PVector;
      begin{function Remove(var Vect: PVector; i: PVector): TVector}
        Result := i^;
        AddPoint(Result.X, Result.Y);
        if i = Vect then
        begin
          Vect := Vect.Next;
        end
        else
        begin
          Old := Vect;
          while Old.Next <> i do
          begin
            Old := Old.Next;
          end;
          Old.Next := Old.Next.Next;
        end;
        Dispose(i);
        Dec(VectCount);
      end;{function Remove(var Vect: PVector; i: PVector): TVector}

      function FindVector(Vect: PVector; px, py: integer): PVector;
      begin{function FindVector(Vect: PVector; px, py: Integer): PVector}
        Result := nil;
        while Assigned(Vect)do
        begin
          if(Vect.X = px)and(Vect.Y = py)then
          begin
            Result := Vect;
            Exit;
          end;
          Vect := Vect.Next;
        end;
      end;{function FindVector(Vect: PVector; px, py: Integer): PVector}

    var
      i: PVector;
      P: TVector;
    begin{function LinkOne: Integer}
      Result := 0;
      i := HorzVect;
      while Assigned(i)do
      begin
        P := Remove(HorzVect, i);
        Inc(Result);
        i := FindVector(VertVect, P.X + P.Delta, P.Y);
        P := Remove(VertVect, i);
        Inc(Result);
        i := FindVector(HorzVect, P.X, P.Y + P.Delta);
      end;
    end;{function LinkOne: Integer}

  begin{procedure MakeLinks}
    SetLength(Points, VectCount);
    Index := 0;
    Count := 0;
    while VectCount > 0 do
    begin
      SetLength(Counts, Count + 1);
      Counts[Count]:= LinkOne;
      Inc(Count);
    end;
  end;{procedure MakeLinks}

  function MakeInteger(Count: integer; Counts: array of integer;
    Points: array of TPoint): TIntegerDynArray;
  var
    i, j: integer;
  begin
    SetLength(Result, 1 + Count + Length(Points)* 2);
    j := 0;
    Result[j]:= Count;
    Inc(j);
    for i := 0 to Count - 1 do
    begin
      Result[j]:= Counts[i];
      Inc(j);
    end;
    for i := 0 to Length(Points)- 1 do
    begin
      Result[j]:= Points[i].X;
      Inc(j);
      Result[j]:= Points[i].Y;
      Inc(j);
    end;
  end;

begin
  SetLength(Result, 0);
  VectCount := 0;
  HorzScan;
  VertScan;
  MakeLinks;
  Result := MakeInteger(Count, Counts, Points);
end;

function BMPtoRGN(bmp: Graphics.TBitmap; BkColor: TColor): hRGN;
var
  ArrPt: TIntegerDynArray;
begin
  ArrPt := MakeRegion(bmp, BkColor);
  try
    Result := CreatePolyPolygonRgn(ArrPt[ArrPt[0]+ 1], ArrPt[1], ArrPt[0],
      ALTERNATE);
  finally
    SetLength(ArrPt, 0);
  end;
end;

(******************************************************************************)

procedure GetPoint(aBasePoint: TPoint; aAngleDegree: extended; aRadius: extended;var aResPoint: TPoint);
var
  _Sin, _Cos: extended;
begin
  SinCos(DegToRad(aAngleDegree), _Sin, _Cos);
  aResPoint := Point(Round(aRadius * _Cos + aBasePoint.X), Round(aRadius * _Sin + aBasePoint.Y));
 // aResPoint := Point(Round(aRadius * _Sin + aBasePoint.X), Round(aRadius * _Cos + aBasePoint.Y));
end;

function GetPoint(aBasePoint: TPoint; aAngleDegree: extended; aRadius: extended) : TPoint;
var
  _Sin, _Cos: extended;
begin
  SinCos(DegToRad(aAngleDegree), _Sin, _Cos);
  Result := Point(Round(aRadius * _Cos + aBasePoint.X), Round(aRadius * _Sin + aBasePoint.Y));
 // aResPoint := Point(Round(aRadius * _Sin + aBasePoint.X), Round(aRadius * _Cos + aBasePoint.Y));
end;


function GetAngle(LenX, LenY: extended): extended;
begin
Result := RadToDeg(arctan(LenY / IfThen(LenX=0,0.1E100,LenX)));
end;

(*Получение угла по двум точкам относительно горизонта*)
//http://www.fxyz.ru/формулы_по_геометрии/плоские_фигуры/треугольник/решение_прямоугольного_треугольника/
function GetAngle(A, C: TPoint;var aQuart: Byte): extended;
var
  lnX, lnY: extended;
  q: Byte;
begin
  Result := 0;
  try
    lnX := Abs(A.X - C.X);
    lnY := Abs(A.Y - C.Y);
    if lnX = 0 then
      lnX := 0.0000001;
    Result := RadToDeg(arctan(lnY / lnX));
    q := 0;
    if(A.X > C.X)(*right*)and(A.Y <= C.Y)(*above*)then
      q := 1
    else if(A.X >= C.X)(*right*)and(A.Y > C.Y)(*below*)then
      q := 2
    else if(A.X < C.X)(*left*)and(A.Y >= C.Y)(*below*)then
      q := 3
    else if(A.X <= C.X)(*left*)and(A.Y < C.Y)(*above*)then
      q := 4;
    if odd(q)then
      Result := 90 - Result
    else
      Result := 90 + Result;
    if q > 2 then
      Result := 180 + Result;
    //case q of
    //1 : Result:=90-Result;
    //2 : Result:=90+Result;
    //3 : Result:=180+(90-Result);
    //4 : Result:=180+(90+Result);
    //end;
    if RoundTo(Result,-4)= 360 then
      Result := 0;
    aQuart := q;
  except
    on E: Exception do;
  end;
end;

function GetAngleRad(A, C: TPoint): extended;
var
  lnX, lnY: extended;
begin
  Result := 0;
  try
    lnX := Abs(A.X - C.X);
    lnY := Abs(A.Y - C.Y);
    if lnX = 0 then
      lnX := 0.0000001;
    Result := arctan(lnY / lnX);
  except
    on E: Exception do;
  end;
end;

function GetDistance(A,B : TPoint) : extended;
var
 x    : int64;
 y    : int64;
 val  : int64;
begin
Result:=0;
x:=(A.X-B.X);
y:=(A.Y-B.Y);
val:=x*x+y*y;
if val>=0 then Result:=sqrt(val); // -- сейчас быть не должно, но при integer возникало переполнение, квадрат уходил в отрицательные величины и ошибка
end;


procedure GetCenter(A,B : TPoint; var C: TPoint);
var
 q : byte;
begin
GetPoint(A,GetAngle(A,B,q)+90,GetDistance(A,B) / 2, C);
end;

function GetHypo(aCat,aAngleDegree : extended; aCatOpposite : boolean) : single;
var
 res : single;
 rad : single;
begin
Result:=0;
try
rad:=DegToRad(aAngleDegree);
if aCatOpposite
   then res:=sin(rad)
   else res:=cos(rad);
if res<>0
   then Result:= aCat / res;
except
on E  : Exception do ShowMessageError(E.Message+crlf+Format('%f',[aAngleDegree]));
end;
end;


function GetFont(const aName:string; aSize: integer;
  aStyle: TFontStyles): hFont;
var
  sz: integer;
  lf: TLogFont;
  dc: hDC;
begin
  sz := SizeOf(TLogFont);
  FillChar(lf, sz, 0);
  StrPLCopy(PChar(@lf.lfFaceName[0]), aName, 31);
  lf.lfCharSet := DEFAULT_CHARSET;
  lf.lfClipPrecision := OUT_TT_PRECIS;
  lf.lfQuality := CLEARTYPE_NATURAL_QUALITY;
  if aSize > 0 then
  begin
    dc := getDC(GetDesktopWindow);
    try
      lf.lfHeight :=-MulDiv(aSize, GetDeviceCaps(dc, LOGPIXELSY), 72)
    finally
      ReleaseDC(GetDesktopWindow, dc);
    end;
  end
  else
    lf.lfHeight := aSize;
  if fsBold in aStyle then
    lf.lfWeight := FW_BOLD
  else
    lf.lfWeight := FW_NORMAL;
  if fsItalic in aStyle then
    lf.lfItalic := 1;
  if fsUnderline in aStyle then
    lf.lfUnderline := 1;
  if fsStrikeOut in aStyle then
    lf.lfStrikeOut := 1;
  Result := CreateFontIndirect(lf);
end;

function CreateFont(var aFont: TFont;const aName:string; aSize: integer;
  aStyle: TFontStyles; aColor: TColor): cardinal;
begin
  aFont := TFont.Create;
  with aFont do
  begin
    Name := aName;
    Size := aSize;
    Color := aColor;
    Style := aStyle;
    Result := Handle;
  end;
end;

function CreateClearBrush : hBrush;
var
 lb : TLogBrush;
begin
lb.lbStyle:=BS_HOLLOW;
Result:=CreateBrushIndirect(lb);
end;

//позже надо оптимизировать рассчет цветов .....
procedure BlueCaption(dc: hDC;const aRect: TRect;const aText:string;
  Pressed: boolean = false);
var
  cnt: integer;
  rct: TRect;
  deltaClr: Byte;
  Width: integer;
  height: integer;
  CurColor: ColorRef;
  pn: hPen;
  br: hBrush;
  opn: hPen;
  obr: hBrush;
  er: Byte;
  otc: ColorRef;
begin
  pn := CreatePen(PS_SOLID, 1, clBlack);
  br := CreateSolidBrush(clBlack);
  opn := SelectObject(dc, pn);
  obr := SelectObject(dc, br);
  Width := aRect.Right - aRect.Left;
  height := aRect.Bottom - aRect.Top;
  deltaClr := Round((255 -(127 / height))/ height);
  er := 0;
  for cnt := 0 to height div 2 do
  begin
    if Pressed then
    begin
      if cnt * deltaClr > 127 then
      begin
        er := er + 2;
        CurColor := RGB(er, er, 255)
      end
      else
        CurColor := RGB(er, er, 255 - deltaClr * cnt);
    end
    else
    begin
      if cnt * deltaClr > 127 then
      begin
        er := er + 2;
        CurColor := RGB(er, er, 255)
      end
      else
        CurColor := RGB(er, er, 128 + cnt * deltaClr);
    end;
    if cnt = 0 then
      CurColor := RGB($00, $00, $00);
    pn := CreatePen(PS_SOLID, 1, CurColor);
    br := CreateSolidBrush(CurColor);
    DeleteObject(SelectObject(dc, pn));
    DeleteObject(SelectObject(dc, br));
    rct := Rect(aRect.Left + cnt, aRect.Top + cnt, aRect.Left + Width - cnt,
      aRect.Top + height - cnt);
    Rectangle(dc, rct.Left, rct.Top, rct.Right, rct.Bottom);
  end;
  otc := GetTextColor(dc);
  SetTextColor(dc, RGB($FF, $FF, $00));
  SetBkMode(dc, Transparent);
  System.Move(aRect, rct, SizeOf(TRect));
  DrawText(dc, PChar(aText), Length(aText), rct, DT_CENTER or DT_VCENTER or
    DT_SINGLELINE);
  SetBkMode(dc, Opaque);
  SetTextColor(dc, otc);
  DeleteObject(SelectObject(dc, opn));
  DeleteObject(SelectObject(dc, obr));
end;

procedure GreenCaption(dc: hDC;const aRect: TRect;const aText:string;
  Pressed: boolean = false);
var
  cnt: integer;
  rct: TRect;
  deltaClr: Byte;
  Width: integer;
  height: integer;
  CurColor: ColorRef;
  pn: hPen;
  br: hBrush;
  opn: hPen;
  obr: hBrush;
  er: Byte;
  otc: ColorRef;
begin
  pn := CreatePen(PS_SOLID, 1, clBlack);
  br := CreateSolidBrush(clBlack);
  opn := SelectObject(dc, pn);
  obr := SelectObject(dc, br);
  Width := aRect.Right - aRect.Left;
  height := aRect.Bottom - aRect.Top;
  deltaClr := Round((255 -(127 / height))/ height);
  er := 0;
  for cnt := 0 to height div 2 do
  begin
    if Pressed then
    begin
      if cnt * deltaClr > 127 then
      begin
        er := er + 2;
        CurColor := RGB(er, 255, er)
      end
      else
        CurColor := RGB(er, 255 - deltaClr * cnt, er);
    end
    else
    begin
      if cnt * deltaClr > 127 then
      begin
        er := er + 2;
        CurColor := RGB(er, 255, er)
      end
      else
        CurColor := RGB(er, 128 + cnt * deltaClr, er);
    end;
    if cnt = 0 then
      CurColor := RGB($00, $00, $00);
    pn := CreatePen(PS_SOLID, 1, CurColor);
    br := CreateSolidBrush(CurColor);
    DeleteObject(SelectObject(dc, pn));
    DeleteObject(SelectObject(dc, br));
    rct := Rect(aRect.Left + cnt, aRect.Top + cnt, aRect.Left + Width - cnt,
      aRect.Top + height - cnt);
    Rectangle(dc, rct.Left, rct.Top, rct.Right, rct.Bottom);
  end;
  otc := GetTextColor(dc);
  SetTextColor(dc, RGB($FF, $FF, $00));
  SetBkMode(dc, Transparent);
  System.Move(aRect, rct, SizeOf(TRect));
  DrawText(dc, PChar(aText), Length(aText), rct, DT_CENTER or DT_VCENTER or
    DT_SINGLELINE);
  SetBkMode(dc, Opaque);
  SetTextColor(dc, otc);
  DeleteObject(SelectObject(dc, opn));
  DeleteObject(SelectObject(dc, obr));
end;

procedure YellowCaption(dc: hDC; aRect: TRect;const aText:string;
  Pressed: boolean = false);
var
  cnt: integer;
  rct: TRect;
  deltaClr: Byte;
  Width: integer;
  height: integer;
  CurColor: ColorRef;
  pn: hPen;
  br: hBrush;
  opn: hPen;
  obr: hBrush;
  er: Byte;
  otc: ColorRef;
begin
  pn := CreatePen(PS_SOLID, 1, clBlack);
  br := CreateSolidBrush(clBlack);
  opn := SelectObject(dc, pn);
  obr := SelectObject(dc, br);
  Width := aRect.Right - aRect.Left;
  height := aRect.Bottom - aRect.Top;
  deltaClr := Round((255 -(127 / height))/ height);
  er := 0;
  for cnt := 0 to height div 2 do
  begin
    if Pressed then
    begin
      if cnt * deltaClr > 127 then
      begin
        er := er + 2;
        CurColor := RGB(255, 255, er)
      end
      else
        CurColor := RGB(255 - deltaClr * cnt, 255 - deltaClr * cnt, er);
    end
    else
    begin
      if cnt * deltaClr > 127 then
      begin
        er := er + 2;
        CurColor := RGB(255, 255, er)
      end
      else
        CurColor := RGB(128 + cnt * deltaClr, 128 + cnt * deltaClr, er);
    end;
    if cnt = 0 then
      CurColor := RGB($00, $00, $00);
    pn := CreatePen(PS_SOLID, 1, CurColor);
    br := CreateSolidBrush(CurColor);
    DeleteObject(SelectObject(dc, pn));
    DeleteObject(SelectObject(dc, br));
    rct := Rect(aRect.Left + cnt, aRect.Top + cnt, aRect.Left + Width - cnt,
      aRect.Top + height - cnt);
    Rectangle(dc, rct.Left, rct.Top, rct.Right, rct.Bottom);
  end;
  if aText <> '' then
  begin
    otc := GetTextColor(dc);
    SetTextColor(dc, RGB($0, $00, $80));
    SetBkMode(dc, Transparent);
    DrawText(dc, PChar(aText), Length(aText), aRect, DT_CENTER or DT_VCENTER or
      DT_SINGLELINE);
    SetBkMode(dc, Opaque);
    SetTextColor(dc, otc);

    DeleteObject(SelectObject(dc, opn));
    DeleteObject(SelectObject(dc, obr));
  end;
end;

procedure RedCaption(dc: hDC; aRect: TRect;const aText:string; aPressed: boolean = false);
var
  cnt: integer;
  rct: TRect;
  deltaClr: Single;
  deltaClrRes: Byte;
  Width: integer;
  height: integer;
  CurColor: ColorRef;
  pn: hPen;
  br: hBrush;
  opn: hPen;
  obr: hBrush;
  er: Byte;
  otc: ColorRef;
  dlX: integer;
  dlY: integer;
  res : byte;
begin
  dlX := Round((rct.Right - rct.Left)/ 4);
  dlY := Round((rct.Bottom - rct.Top)/ 4);
  pn := CreatePen(PS_SOLID, 1, clBlack);
  br := CreateSolidBrush(clBlack);
  opn := SelectObject(dc, pn);
  obr := SelectObject(dc, br);
  Width := aRect.Right - aRect.Left;
  height := aRect.Bottom - aRect.Top;
  if height = 0 then height := 10;
  deltaClr :=(255 / height);
  er := 0;
  for cnt := 0 to height div 2
    do begin
    deltaClrRes := Round(cnt * deltaClr);
    if deltaClrRes > 127 then deltaClrRes := 127;
    if aPressed
       then res:= byte(255 - deltaClrRes)
       else res:= byte(128 + deltaClrRes);
    CurColor := RGB(res, er, er);
    if cnt = 0 then CurColor := RGB($00, $00, $00);
    pn := CreatePen(PS_SOLID, 1, CurColor);
    br := CreateSolidBrush(CurColor);
    DeleteObject(SelectObject(dc, pn));
    DeleteObject(SelectObject(dc, br));
    rct := Rect(aRect.Left + cnt, aRect.Top + cnt, aRect.Left + Width - cnt, aRect.Top + height - cnt);
    if aText = 'X'
       then RoundRect(dc, rct.Left, rct.Top, rct.Right, rct.Bottom, dlX, dlY)
       else Rectangle(dc, rct.Left, rct.Top, rct.Right, rct.Bottom);
  end;
  if aText <> 'X' then
  begin
    otc := GetTextColor(dc);
    SetTextColor(dc, RGB($FF, $FF, $00));
    SetBkMode(dc, Transparent);
    DrawText(dc, PChar(aText), Length(aText), aRect, DT_CENTER or DT_VCENTER or
      DT_SINGLELINE);
    SetBkMode(dc, Opaque);
    SetTextColor(dc, otc);
  end
  else
  begin
    pn := CreatePen(PS_SOLID, 2, Graphics.ColorToRGB(clYellow));
    opn := SelectObject(dc, pn);
    MoveToEx(dc, aRect.Left + dlX, aRect.Top + dlY,nil);
    LineTo(dc, aRect.Right - dlX, aRect.Bottom - dlY);
    MoveToEx(dc, aRect.Right - dlX, aRect.Top + dlY,nil);
    LineTo(dc, aRect.Left + dlX, aRect.Bottom - dlY);
  end;
  DeleteObject(SelectObject(dc, opn));
  DeleteObject(SelectObject(dc, obr));
end;

procedure VioletCaption(dc: hDC; aRect: TRect;const aText:string;
  Pressed: boolean = false);
var
  cnt: integer;
  rct: TRect;
  deltaClr: Byte;
  Width: integer;
  height: integer;
  CurColor: ColorRef;
  pn: hPen;
  br: hBrush;
  opn: hPen;
  obr: hBrush;
  er: Byte;
  otc: ColorRef;
begin
  pn := CreatePen(PS_SOLID, 1, clBlack);
  br := CreateSolidBrush(clBlack);
  opn := SelectObject(dc, pn);
  obr := SelectObject(dc, br);
  Width := aRect.Right - aRect.Left;
  height := aRect.Bottom - aRect.Top;
  deltaClr := Round((255 -(127 / height))/ height);
  er := 0;
  for cnt := 0 to height div 2 do
  begin
    if Pressed then
    begin
      if cnt * deltaClr > 127 then
      begin
        er := er + 2;
        CurColor := RGB(255, er, 255)
      end
      else
        CurColor := RGB(255 - deltaClr * cnt, er, 255 - deltaClr * cnt);
    end
    else
    begin
      if cnt * deltaClr > 127 then
      begin
        er := er + 2;
        CurColor := RGB(255, er, 255)
      end
      else
        CurColor := RGB(128 + cnt * deltaClr, er, 128 + cnt * deltaClr);
    end;
    if cnt = 0 then
      CurColor := RGB($00, $00, $00);
    pn := CreatePen(PS_SOLID, 1, CurColor);
    br := CreateSolidBrush(CurColor);
    DeleteObject(SelectObject(dc, pn));
    DeleteObject(SelectObject(dc, br));
    rct := Rect(aRect.Left + cnt, aRect.Top + cnt, aRect.Left + Width - cnt,
      aRect.Top + height - cnt);
    Rectangle(dc, rct.Left, rct.Top, rct.Right, rct.Bottom);
  end;
  if aText <> '' then
  begin
    otc := GetTextColor(dc);
    SetTextColor(dc, RGB($80, $80, $00));
    SetBkMode(dc, Transparent);
    DrawText(dc, PChar(aText), Length(aText), aRect, DT_CENTER or DT_VCENTER or
      DT_SINGLELINE);
    SetBkMode(dc, Opaque);
    SetTextColor(dc, otc);

    DeleteObject(SelectObject(dc, opn));
    DeleteObject(SelectObject(dc, obr));
  end;
end;

procedure RedButton(dc: hDC; aRect: TRect; Pressed: boolean = false);
var
  cnt: integer;
  rct: TRect;
  rctCr: TRect;
  deltaClr: Byte;
  Width: integer;
  height: integer;
  CurColor: ColorRef;
  pn: hPen;
  br: hBrush;
  opn: hPen;
  obr: hBrush;
  //er       : byte;
  dlX: integer;
  dlY: integer;
begin
  rctCr := Bounds(0, 0, 0, 0);
  pn := CreatePen(PS_SOLID, 1, clBlack);
  br := CreateSolidBrush(clBlack);
  opn := SelectObject(dc, pn);
  obr := SelectObject(dc, br);
  Width := aRect.Right - aRect.Left;
  height := aRect.Bottom - aRect.Top;
  dlX := Round(Width / 4);
  dlY := Round(height / 4);
  if height = 0 then
    height := 10;
  deltaClr := Round((255 -(127 / height))/ height);
  //er:=0;
  for cnt := 0 to height div 2 do
  begin
    //if Pressed
    //then begin
    //if cnt*deltaClr>127
    //then begin
    //er:=er+2;
    //CurColor:=RGB(255,er,er)
    //end
    //else CurColor:=RGB(255-DeltaClr*cnt,er,er);
    //end
    //else begin
    //if cnt*deltaClr>127
    //then begin
    //er:=er+2;
    //CurColor:=RGB(128+cnt*deltaClr,er,er)
    //end
    //else CurColor:=RGB(128+cnt*deltaClr,er,er);
    //end ;
    if Pressed then
    begin
      if cnt * deltaClr > 127 then
        CurColor := RGB(255, 0, 0)
      else
        CurColor := RGB(255 - deltaClr * cnt, 0, 0);
    end
    else
    begin
      if cnt * deltaClr > 127 then
      begin
        CurColor := RGB(255, 0, 0)
      end
      else
        CurColor := RGB(128 + cnt * deltaClr, 0, 0);
    end;
    if cnt = 0 then
      CurColor := RGB($00, $00, $00);
    pn := CreatePen(PS_SOLID, 1, CurColor);
    br := CreateSolidBrush(CurColor);
    DeleteObject(SelectObject(dc, pn));
    DeleteObject(SelectObject(dc, br));
    rct := Rect(aRect.Left + cnt//+integer(Pressed)
      , aRect.Top + cnt//+integer(Pressed)
      , aRect.Left + Width - cnt//+integer(Pressed)
      , aRect.Top + height - cnt//+integer(Pressed)
      );
    if rctCr.Right = 0 then
      System.Move(rct, rctCr, SizeOf(TRect));
    RoundRect(dc, rct.Left, rct.Top, rct.Right, rct.Bottom, dlX, dlY);
  end;

  pn := CreatePen(PS_SOLID, 2, Graphics.ColorToRGB(clYellow));
  DeleteObject(SelectObject(dc, pn));

  MoveToEx(dc, rctCr.Left + dlX, rctCr.Top + dlY,nil);
  LineTo(dc, rctCr.Right - dlX, rctCr.Bottom - dlY);
  MoveToEx(dc, rctCr.Right - dlX, rctCr.Top + dlY,nil);
  LineTo(dc, rctCr.Left + dlX, rctCr.Bottom - dlY);

  DeleteObject(SelectObject(dc, opn));
  DeleteObject(SelectObject(dc, obr));
end;

procedure GrayButton(dc: hDC; aRect: TRect; Pressed: boolean = false);
var
  cnt: integer;
  rct: TRect;
  rctCr: TRect;
  deltaClr: Byte;
  Width: integer;
  height: integer;
  CurColor: ColorRef;
  pn: hPen;
  br: hBrush;
  opn: hPen;
  obr: hBrush;
  //er       : byte;
  dlX: integer;
  dlY: integer;
begin
  rctCr := Bounds(0, 0, 0, 0);
  pn := CreatePen(PS_SOLID, 1, clBlack);
  br := CreateSolidBrush(clBlack);
  opn := SelectObject(dc, pn);
  obr := SelectObject(dc, br);
  Width := aRect.Right - aRect.Left;
  height := aRect.Bottom - aRect.Top;
  dlX := Round(Width / 4);
  dlY := Round(height / 4);
  if height = 0 then
    height := 10;
  deltaClr := Round((255 -(127 / height))/ height);
  //er:=0;
  for cnt := 0 to height div 2 do
  begin
    //if Pressed
    //then begin
    //if cnt*deltaClr>127
    //then begin
    //er:=er+2;
    //CurColor:=RGB(255,er,er)
    //end
    //else CurColor:=RGB(255-DeltaClr*cnt,er,er);
    //end
    //else begin
    //if cnt*deltaClr>127
    //then begin
    //er:=er+2;
    //CurColor:=RGB(128+cnt*deltaClr,er,er)
    //end
    //else CurColor:=RGB(128+cnt*deltaClr,er,er);
    //end ;
    if Pressed then
    begin
      if cnt * deltaClr > 127 then
        CurColor := RGB(255, 255, 255)
      else
        CurColor := RGB(255 - deltaClr * cnt, 255 - deltaClr * cnt,
          255 - deltaClr * cnt);
    end
    else
    begin
      if cnt * deltaClr > 127 then
      begin
        CurColor := RGB(255, 255, 255)
      end
      else
        CurColor := RGB(128 + cnt * deltaClr, 128 + cnt * deltaClr,
          128 + cnt * deltaClr);
    end;
    if cnt = 0 then
      CurColor := RGB($00, $00, $00);
    pn := CreatePen(PS_SOLID, 1, CurColor);
    br := CreateSolidBrush(CurColor);
    DeleteObject(SelectObject(dc, pn));
    DeleteObject(SelectObject(dc, br));
    rct := Rect(aRect.Left + cnt//+integer(Pressed)
      , aRect.Top + cnt//+integer(Pressed)
      , aRect.Left + Width - cnt//+integer(Pressed)
      , aRect.Top + height - cnt//+integer(Pressed)
      );
    if rctCr.Right = 0 then
      System.Move(rct, rctCr, SizeOf(TRect));
    RoundRect(dc, rct.Left, rct.Top, rct.Right, rct.Bottom, dlX, dlY);
  end;

  pn := CreatePen(PS_SOLID, 2, Graphics.ColorToRGB(clBlack));
  DeleteObject(SelectObject(dc, pn));

  MoveToEx(dc, rctCr.Left + dlX, rctCr.Top + dlY,nil);
  LineTo(dc, rctCr.Right - dlX, rctCr.Bottom - dlY);
  MoveToEx(dc, rctCr.Right - dlX, rctCr.Top + dlY,nil);
  LineTo(dc, rctCr.Left + dlX, rctCr.Bottom - dlY);

  DeleteObject(SelectObject(dc, opn));
  DeleteObject(SelectObject(dc, obr));
end;

procedure GrayCaption(dc: hDC; aRect: TRect;const aText:string;
  Pressed: boolean = false);
var
  cnt: integer;
  rct: TRect;
  deltaClr: Byte;
  Width: integer;
  height: integer;
  CurColor: ColorRef;
  pn: hPen;
  br: hBrush;
  opn: hPen;
  obr: hBrush;
  otc: ColorRef;
  bkMode: integer;
begin
  pn := CreatePen(PS_SOLID, 1, clBlack);
  br := CreateSolidBrush(clBlack);
  opn := SelectObject(dc, pn);
  obr := SelectObject(dc, br);
  Width := aRect.Right - aRect.Left;
  height := aRect.Bottom - aRect.Top;
  if height=0
     then deltaClr:=0
     else deltaClr := Round((255 -(127 / height))/ height);
  for cnt := 0 to height div 2 do
  begin
    if Pressed then
    begin
      if cnt * deltaClr > 127 then
        CurColor := RGB(255, 255, 255)
      else
        CurColor := RGB(255 - deltaClr * cnt, 255 - deltaClr * cnt,
          255 - deltaClr * cnt);
    end
    else
    begin
      if cnt * deltaClr > 127 then
      begin
        CurColor := RGB(255, 255, 255)
      end
      else
        CurColor := RGB(128 + cnt * deltaClr, 128 + cnt * deltaClr,
          128 + cnt * deltaClr);
    end;
    if cnt = 0 then
      CurColor := RGB($00, $00, $00);
    pn := CreatePen(PS_SOLID, 1, CurColor);
    br := CreateSolidBrush(CurColor);
    DeleteObject(SelectObject(dc, pn));
    DeleteObject(SelectObject(dc, br));
    rct := Rect(aRect.Left + cnt, aRect.Top + cnt, aRect.Left + Width - cnt,
      aRect.Top + height - cnt);
    Rectangle(dc, rct.Left, rct.Top, rct.Right, rct.Bottom);
  end;
  otc := GetTextColor(dc);
  SetTextColor(dc, RGB($00, $00, $00));
  bkMode := GetBkMode(dc);
  SetBkMode(dc, Transparent);
  DrawText(dc, PChar(aText), Length(aText), aRect, DT_CENTER or DT_VCENTER or
    DT_SINGLELINE);
  SetBkMode(dc, Opaque);
  SetBkMode(dc, bkMode);
  SetTextColor(dc, otc);
  DeleteObject(SelectObject(dc, opn));
  DeleteObject(SelectObject(dc, obr));
end;


procedure GradientFigureRegion(aRct : Trect; aGradientFigure: TGradientFigure; var aRgn : hRgn);
const
  rounder  : integer = 15;
  dopDivRad: integer = 1;
var
 rnd : integer;
 cpt: TPoint;
 rad: integer;
 cnt: integer;
 sn, cs: extended;
 arr: array of TPoint;
begin
if aRgn<>0 then DeleteObject(aRgn);
aRgn:=0;
try
rnd := Round((aRct.Right - aRct.Left)/ rounder);
cpt := Point(aRct.Left + Round((aRct.Right - aRct.Left)/ 2), aRct.Top + Round((aRct.Bottom - aRct.Top)/ 2));
case aGradientFigure of
      gfRectangle:
        aRgn:=CreateRectRgn(aRct.Left, aRct.Top, aRct.Right, aRct.Bottom);
      gfRoundRect:
        aRgn:=CreateRoundRectRgn(aRct.Left, aRct.Top, aRct.Right, aRct.Bottom, rnd, rnd);
      gfEllipse: aRgn:=CreateEllipticRgnIndirect(aRct);
      gfStar2, gfStar3, gfStar4, gfStar5, gfStar6, gfStar7, gfStar8, gfStar9, gfStar10:
        begin
        if aRct.Right - aRct.Left > aRct.Bottom - aRct.Top
           then rad := cpt.Y - aRct.Top
           else rad := cpt.X - aRct.Left;
        SetLength(arr, integer(aGradientFigure)* 2);
        try
        for cnt := 0 to High(arr)
          do begin
          SinCos(DegToRad(cnt *(360 / Length(arr))- 90), sn, cs);
          arr[cnt].X := Round(rad /(integer(odd(cnt))* (dopDivRad + integer(aGradientFigure in[gfStar3, gfStar4]))+ 1)*cs + cpt.X);
          arr[cnt].Y := Round(rad /(integer(odd(cnt))*(dopDivRad + integer(aGradientFigure in[gfStar3, gfStar4]))+ 1)*sn + cpt.Y);
          end;
        aRgn:=CreatePolygonRgn((@arr[0])^,Length(arr),WINDING);
        finally
        SetLength(arr, 0);
        end;
        end;
      gfTriangleLeft:
           begin
           Setlength(arr,3);
           arr[0]:=Point(aRct.Right, aRct.Top);
           arr[1]:=Point(aRct.Right,aRct.Bottom);
           arr[2]:=Point(aRct.Left, cpt.Y);
           aRgn:=CreatePolygonRgn((@arr[0])^,Length(arr),WINDING);
           end;
      gfTriangleUp:
           begin
           Setlength(arr,3);
           arr[0]:=Point(aRct.Left, aRct.Bottom);
           arr[1]:=Point(aRct.Right, aRct.Bottom);
           arr[2]:=Point(cpt.X, aRct.Top);
           aRgn:=CreatePolygonRgn((@arr[0])^,Length(arr),WINDING);
           end;
      gfTriangleRight:
           begin
           Setlength(arr,3);
           arr[0]:= Point(aRct.Left, aRct.Bottom);
           arr[1]:= Point(aRct.Left, aRct.Top);
           arr[2]:= Point(aRct.Right, cpt.Y);
           aRgn:=CreatePolygonRgn((@arr[0])^,Length(arr),WINDING);
           end;
      gfTriangleDown:
           begin
           Setlength(arr,3);
           arr[0]:= Point(aRct.Left, aRct.Top);
           arr[1]:= Point(aRct.Right, aRct.Top);
           arr[2]:= Point(cpt.X, aRct.Bottom);
           aRgn:=CreatePolygonRgn((@arr[0])^,Length(arr),WINDING);
           end;
      gfDiamond4:
           begin
           Setlength(arr,4);
           arr[0]:=Point(cpt.X, aRct.Top);
           arr[1]:=Point(aRct.Right, cpt.Y);
           arr[2]:=Point(cpt.X, aRct.Bottom);
           arr[3]:=Point(aRct.Left, cpt.Y);
           aRgn:=CreatePolygonRgn((@arr[0])^,Length(arr),WINDING);
           end;
    end;
finally
SetLength(arr,0);
end;
if aRgn=0 then ShowMessageInfo(GetErrorString(GetlastError));
end;


procedure GradientFigure(aCanvas: TCanvas; aGradientFigure: TGradientFigure;
  aRect: TRect; aBaseColor: TColor;const ACaption:string; aTextColor: TColor;
  aPressed: boolean); overload;
  procedure DrawFigure(aRct: TRect; aRNDx, aRNDy: integer);
  var
    cpt: TPoint;
    rad: integer;
    cnt: integer;
    sn, cs: extended;
    arr: array of TPoint;
  const
    dopDivRad: integer = 1;
    //чем больше , тем меньше внутренний радиус и тем выраженне фигура
    //star3,star4 лучше при 2, остальные хорошо при 1
  begin
    cpt := Point(aRct.Left + Round((aRct.Right - aRct.Left)/ 2),
      aRct.Top + Round((aRct.Bottom - aRct.Top)/ 2));
    case aGradientFigure of
      gfRectangle:
        aCanvas.Rectangle(aRct);
      gfRoundRect:
        aCanvas.RoundRect(aRct, aRNDx, aRNDy);
      gfEllipse:
        aCanvas.Ellipse(aRct);
      gfStar2, gfStar3, gfStar4, gfStar5, gfStar6, gfStar7, gfStar8,
        gfStar9, gfStar10:
        begin
          if aRct.Right - aRct.Left > aRct.Bottom - aRct.Top then
            rad := cpt.Y - aRct.Top
          else
            rad := cpt.X - aRct.Left;
          SetLength(arr, integer(aGradientFigure)* 2);
          try
            for cnt := 0 to High(arr)do
            begin
              SinCos(DegToRad(cnt *(360 / Length(arr))- 90), sn, cs);
              arr[cnt].X :=
                Round(rad /(integer(odd(cnt))*
                (dopDivRad + integer(aGradientFigure in[gfStar3, gfStar4]))+ 1)*
                cs + cpt.X);
              arr[cnt].Y :=
                Round(rad /(integer(odd(cnt))*
                (dopDivRad + integer(aGradientFigure in[gfStar3, gfStar4]))+ 1)*
                sn + cpt.Y);
            end;
            aCanvas.Polygon(arr);
          finally
            SetLength(arr, 0);
          end;
        end;
      gfTriangleLeft:
           aCanvas.Polygon([Point(aRct.Right, aRct.Top), Point(aRct.Right,aRct.Bottom), Point(aRct.Left, cpt.Y)]);
      gfTriangleUp:
           aCanvas.Polygon([Point(aRct.Left, aRct.Bottom), Point(aRct.Right, aRct.Bottom), Point(cpt.X, aRct.Top)]);
      gfTriangleRight:
           aCanvas.Polygon([Point(aRct.Left, aRct.Bottom), Point(aRct.Left, aRct.Top), Point(aRct.Right, cpt.Y)]);
      gfTriangleDown:
           aCanvas.Polygon([Point(aRct.Left, aRct.Top), Point(aRct.Right, aRct.Top), Point(cpt.X, aRct.Bottom)]);
      gfDiamond4:
           aCanvas.Polygon([Point(cpt.X, aRct.Top), Point(aRct.Right, cpt.Y), Point(cpt.X, aRct.Bottom), Point(aRct.Left, cpt.Y)]);
    end;
  end;

var
  H, L, S: integer;
  wdt, hgt: integer;
  dlt: Single;
  cnt: integer;
  rct: TRect;
  rnd: integer;
  //ofn     : hFont;
const
  minLight: integer = 40;
  maxLight: integer = 230;
  rounder: integer = 15;//-- получено эмпирическим путем :-)
begin
  try
    RGBtoHLS(aBaseColor, H, L, S);
    wdt := Abs(aRect.Right - aRect.Left);
    if wdt=0 then wdt:=1;
    hgt := Abs(aRect.Bottom - aRect.Top);
    if hgt=0 then hgt:=1;
    if wdt > hgt then
    begin
      dlt :=(maxLight - minLight)/ hgt;
      for cnt := 0 to hgt div 2 do
      begin
        if aPressed then
          L := minLight + Round(dlt *(hgt div 2 - cnt))
        else
          L := minLight + Round(dlt * cnt);
        aCanvas.Pen.Color := HLStoRGB(H, L, S);
        aCanvas.Brush.Color := aCanvas.Pen.Color;
        rct := Rect(aRect.Left + cnt, aRect.Top + cnt, aRect.Right - cnt,
          aRect.Bottom - cnt);
        rnd := Round((rct.Right - rct.Left)/ rounder);
        if((rct.Right - rct.Left)* 0.50 <= rnd)or
          ((rct.Bottom - rct.Top)* 0.50 <= rnd)then
          rnd := rnd div 2;

        DrawFigure(rct, rnd, rnd)
        //DrawFigure(rct,round((rct.Right - rct.Left) *0.05),round((rct.Bottom - rct.Top) *0.05))
      end;
    end
    else
    begin
      dlt :=(maxLight - minLight)/ wdt;
      for cnt := 0 to wdt div 2 do
      begin
        if aPressed then
          L := minLight + Round(dlt *(wdt div 2 - cnt))
        else
          L := minLight + Round(dlt * cnt);
        aCanvas.Pen.Color := HLStoRGB(H, L, S);
        aCanvas.Brush.Color := aCanvas.Pen.Color;
        rct := Rect(aRect.Left + cnt, aRect.Top + cnt, aRect.Right - cnt,
          aRect.Bottom - cnt);
        rnd := Round((rct.Right - rct.Left)/ rounder);
        if((rct.Right - rct.Left)* 0.50 <= rnd)or
          ((rct.Bottom - rct.Top)* 0.50 <= rnd)then
          rnd := rnd div 2;
        DrawFigure(rct, rnd, rnd);

        //DrawFigure(rct,round((rct.Right - rct.Left) / rounder))
        //DrawFigure(rct,round((rct.Right - rct.Left) *0.15),round((rct.Bottom - rct.Top) *0.15))
      end;
    end;
    if ACaption <> ''
       then begin
      //ofn:=SelectObject(aCanvas.Handle,GetFont('Tahoma',11,[]));
      System.Move(aRect, rct, SizeOf(TRect));
      //OffsetRect(rct, 0, -rct.Top+1);
      SetBkMode(aCanvas.Handle, Transparent);
      SetTextColor(aCanvas.Handle, aTextColor);
      if aPressed
         then OffsetRect(rct, 1, 1);
      if GetTextWidthByHeight(ACaption, aCanvas.Font, aRect.Bottom - aRect.Top, true)> aRect.Right - aRect.Left
         then begin
         hgt := DrawText(aCanvas.Handle, ACaption, Length(ACaption), rct, DT_VCENTER + DT_CENTER + DT_WORDBREAK or DT_CALCRECT)div 2;
         OffsetRect(rct, 0, hgt);
         if rct.Right - rct.Left <= aRect.Right - aRect.Left
            then DrawText(aCanvas.Handle, ACaption, Length(ACaption), rct, DT_VCENTER + DT_CENTER + DT_WORDBREAK);
         //hgt:=GetTextHeightByWidth(aCaption,aCanvas.Font,aRect.Right-aRect.Left,true);
         //OffsetRect(rct, 0, ((rct.Bottom - rct.Top)-hgt) div 2);
         //DrawText(aCanvas.Handle,aCaption,Length(aCaption),rct,DT_VCENTER+DT_CENTER+DT_WORDBREAK);
         //-- при малых размерах aRect текст может вылезать если используется не вся высота DC (Canvas).
         //-- избежать этого можно используя промежуточную TBitMap
         end
         else DrawText(aCanvas.Handle, ACaption, Length(ACaption), rct,  DT_CENTER_ALIGN);
      SetBkMode(aCanvas.Handle, Opaque);
      //DeleteObject(SelectObject(aCanvas.Handle,ofn));
      end;
  except

  end;
end;

type//from Graphics.pas
  PPoints =^TPoints;
  TPoints = array[0 .. 0]of TPoint;


  procedure DrawFigureDC(aDC : hDC; aGradientFigure : TGradientFigure;  aRct: TRect; aRND: integer); inline;
  var
    cpt: TPoint;
    rad: integer;
    cnt: integer;
    sn, cs: extended;
    arr: array of TPoint;
  const
    dopDivRad: integer = 1;
    //чем больше , тем меньше внутренний радиус и тем выраженне фигура
    //star3,star4 лучше при 2, остальные хорошо при 1
  begin
    cpt := Point(aRct.Left + Round((aRct.Right - aRct.Left)/ 2),
      aRct.Top + Round((aRct.Bottom - aRct.Top)/ 2));
    case aGradientFigure of
      gfRectangle:
        Rectangle(aDC, aRct.Left, aRct.Top, aRct.Right, aRct.Bottom);
      gfRoundRect:
        RoundRect(aDC, aRct.Left, aRct.Top, aRct.Right, aRct.Bottom,
          aRND, aRND);
      gfEllipse:
        Ellipse(aDC, aRct.Left, aRct.Top, aRct.Right, aRct.Bottom);
      gfStar2, gfStar3, gfStar4, gfStar5, gfStar6, gfStar7, gfStar8,
        gfStar9, gfStar10:
        begin
          if aRct.Right - aRct.Left > aRct.Bottom - aRct.Top then
            rad := cpt.Y - aRct.Top
          else
            rad := cpt.X - aRct.Left;
          SetLength(arr, integer(aGradientFigure)* 2);
          try
            for cnt := 0 to High(arr)do
            begin
              SinCos(DegToRad(cnt *(360 / Length(arr))- 90), sn, cs);
              arr[cnt].X :=
                Round(rad /(integer(odd(cnt))*
                (dopDivRad + integer(aGradientFigure in[gfStar3, gfStar4]))+ 1)*
                cs + cpt.X);
              arr[cnt].Y :=
                Round(rad /(integer(odd(cnt))*
                (dopDivRad + integer(aGradientFigure in[gfStar3, gfStar4]))+ 1)*
                sn + cpt.Y);
            end;
            Windows.Polygon(aDC, arr[0], Length(arr));
          finally
            SetLength(arr, 0);
          end;
        end;
      gfTriangleLeft, gfTriangleUp, gfTriangleRight, gfTriangleDown:
        begin
          SetLength(arr, 3);
          try
            case aGradientFigure of
              gfTriangleLeft:
                begin
                  arr[0]:= Point(aRct.Right, aRct.Top);
                  arr[1]:= Point(aRct.Right, aRct.Bottom);
                  arr[2]:= Point(aRct.Left, cpt.Y);
                end;
              gfTriangleUp:
                begin
                  arr[0]:= Point(aRct.Left, aRct.Bottom);
                  arr[1]:= Point(aRct.Right, aRct.Bottom);
                  arr[2]:= Point(cpt.X, aRct.Top);
                end;
              gfTriangleRight:
                begin
                  arr[0]:= Point(aRct.Left, aRct.Bottom);
                  arr[1]:= Point(aRct.Left, aRct.Top);
                  arr[2]:= Point(aRct.Right, cpt.Y);
                end;
              gfTriangleDown:
                begin
                  arr[0]:= Point(aRct.Left, aRct.Top);
                  arr[1]:= Point(aRct.Right, aRct.Top);
                  arr[2]:= Point(cpt.X, aRct.Bottom);
                end;
            end;
            Windows.Polygon(aDC, arr[0], Length(arr));
          finally
            SetLength(arr, 0);
          end;
        end;
    end;
  end;

procedure GradientFigure(aDC: hDC; aGradientFigure: TGradientFigure;  aRect: TRect; aBaseColor: TColor;const ACaption:string; aTextColor: TColor;  aPressed: boolean); overload;
//  procedure DrawFigure(aRct: TRect; aRND: integer);
//  var
//    cpt: TPoint;
//    rad: integer;
//    cnt: integer;
//    sn, cs: extended;
//    arr: array of TPoint;
//  const
//    dopDivRad: integer = 1;
//    //чем больше , тем меньше внутренний радиус и тем выраженне фигура
//    //star3,star4 лучше при 2, остальные хорошо при 1
//  begin
//    cpt := Point(aRct.Left + Round((aRct.Right - aRct.Left)/ 2),
//      aRct.Top + Round((aRct.Bottom - aRct.Top)/ 2));
//    case aGradientFigure of
//      gfRectangle:
//        Rectangle(aDC, aRct.Left, aRct.Top, aRct.Right, aRct.Bottom);
//      gfRoundRect:
//        RoundRect(aDC, aRct.Left, aRct.Top, aRct.Right, aRct.Bottom,
//          aRND, aRND);
//      gfEllipse:
//        Ellipse(aDC, aRct.Left, aRct.Top, aRct.Right, aRct.Bottom);
//      gfStar2, gfStar3, gfStar4, gfStar5, gfStar6, gfStar7, gfStar8,
//        gfStar9, gfStar10:
//        begin
//          if aRct.Right - aRct.Left > aRct.Bottom - aRct.Top then
//            rad := cpt.Y - aRct.Top
//          else
//            rad := cpt.X - aRct.Left;
//          SetLength(arr, integer(aGradientFigure)* 2);
//          try
//            for cnt := 0 to High(arr)do
//            begin
//              SinCos(DegToRad(cnt *(360 / Length(arr))- 90), sn, cs);
//              arr[cnt].X :=
//                Round(rad /(integer(odd(cnt))*
//                (dopDivRad + integer(aGradientFigure in[gfStar3, gfStar4]))+ 1)*
//                cs + cpt.X);
//              arr[cnt].Y :=
//                Round(rad /(integer(odd(cnt))*
//                (dopDivRad + integer(aGradientFigure in[gfStar3, gfStar4]))+ 1)*
//                sn + cpt.Y);
//            end;
//            Windows.Polygon(aDC, arr[0], Length(arr));
//          finally
//            SetLength(arr, 0);
//          end;
//        end;
//      gfTriangleLeft, gfTriangleUp, gfTriangleRight, gfTriangleDown:
//        begin
//          SetLength(arr, 3);
//          try
//            case aGradientFigure of
//              gfTriangleLeft:
//                begin
//                  arr[0]:= Point(aRct.Right, aRct.Top);
//                  arr[1]:= Point(aRct.Right, aRct.Bottom);
//                  arr[2]:= Point(aRct.Left, cpt.Y);
//                end;
//              gfTriangleUp:
//                begin
//                  arr[0]:= Point(aRct.Left, aRct.Bottom);
//                  arr[1]:= Point(aRct.Right, aRct.Bottom);
//                  arr[2]:= Point(cpt.X, aRct.Top);
//                end;
//              gfTriangleRight:
//                begin
//                  arr[0]:= Point(aRct.Left, aRct.Bottom);
//                  arr[1]:= Point(aRct.Left, aRct.Top);
//                  arr[2]:= Point(aRct.Right, cpt.Y);
//                end;
//              gfTriangleDown:
//                begin
//                  arr[0]:= Point(aRct.Left, aRct.Top);
//                  arr[1]:= Point(aRct.Right, aRct.Top);
//                  arr[2]:= Point(cpt.X, aRct.Bottom);
//                end;
//            end;
//            Windows.Polygon(aDC, arr[0], Length(arr));
//          finally
//            SetLength(arr, 0);
//          end;
//        end;
//    end;
//  end;

var
  H, L, S: integer;
  wdt, hgt: integer;
  dlt: Single;
  cnt: integer;
  rct: TRect;
  clr: TColorRef;
  opn, pn: hPen;
  obr, br: hBrush;
  ofn: hFont;
const
  minLight: integer = 40;
  maxLight: integer = 230;
  rounder: integer = 15;//-- получено эмпирическим путем :-)
begin
  pn := GetStockObject(DC_PEN);
  opn := SelectObject(aDC, pn);
  br := GetStockObject(DC_BRUSH);
  obr := SelectObject(aDC, br);
  try
    RGBtoHLS(aBaseColor, H, L, S);
    wdt := Abs(aRect.Right - aRect.Left);
    hgt := Abs(aRect.Bottom - aRect.Top);
    if wdt > hgt then
    begin
      dlt :=(maxLight - minLight)/ hgt;
      for cnt := 0 to hgt div 2 do
      begin
        if aPressed then
          L := minLight + Round(dlt *(hgt div 2 - cnt))
        else
          L := minLight + Round(dlt * cnt);
        clr := Graphics.ColorToRGB(HLStoRGB(H, L, S));
        SetDCPenColor(aDC, clr);
        SetDCBrushColor(aDC, clr);
        rct := Rect(aRect.Left + cnt, aRect.Top + cnt, aRect.Right - cnt,
          aRect.Bottom - cnt);
        DrawFigureDC(aDC, aGradientFigure, rct, Round((rct.Right - rct.Left)/ rounder))
      end;
    end
    else
    begin
      if wdt=0
         then dlt :=0
         else dlt :=(maxLight - minLight)/ wdt;
      for cnt := 0 to wdt div 2 do
      begin
        if aPressed then
          L := minLight + Round(dlt *(wdt div 2 - cnt))
        else
          L := minLight + Round(dlt * cnt);
        clr := Graphics.ColorToRGB(HLStoRGB(H, L, S));
        SetDCPenColor(aDC, clr);
        SetDCBrushColor(aDC, clr);
        rct := Rect(aRect.Left + cnt, aRect.Top + cnt, aRect.Right - cnt,
          aRect.Bottom - cnt);
        DrawFigureDC(aDC, aGradientFigure, rct, Round((rct.Right - rct.Left)/ rounder))
      end;
    end;
    if ACaption <> '' then
    begin
      //ofn := SelectObject(aDC, GetFont('Tahoma', 11,[]));
      System.Move(aRect, rct, SizeOf(TRect));
      SetBkMode(aDC, Transparent);
      SetTextColor(aDC, aTextColor);
      if aPressed then
        OffsetRect(rct, 1, 1);
      DrawText(aDC, ACaption, Length(ACaption), rct, DT_CENTER_ALIGN);
      SetBkMode(aDC, Opaque);
      DeleteObject(SelectObject(aDC, ofn));
    end;
  finally
    DeleteObject(SelectObject(aDC, opn));
    DeleteObject(SelectObject(aDC, obr));
  end;
end;

procedure SimpleFigure(aDC: hDC; aGradientFigure: TGradientFigure; aRect: TRect; aBaseColor,aBorderColor: TColor;const ACaption:string; aTextColor: TColor); overload;
var
  rct: TRect;
  opn, pn: hPen;
  obr, br: hBrush;
  ofn: hFont;
const
  minLight: integer = 40;
  maxLight: integer = 230;
  rounder: integer = 15;//-- получено эмпирическим путем :-)
begin
  pn := GetStockObject(DC_PEN);
  opn := SelectObject(aDC, pn);
  br := GetStockObject(DC_BRUSH);
  obr := SelectObject(aDC, br);
  try
  SetDCPenColor(aDC, aBorderColor);
  SetDCBrushColor(aDC, aBaseColor);
  DrawFigureDC(aDC, aGradientFigure, aRect, Round((aRect.Right - aRect.Left)/ rounder));
  if ACaption <> ''
     then begin
     ofn := SelectObject(aDC, GetFont('Tahoma', 11,[]));
     System.Move(aRect, rct, SizeOf(TRect));
     SetBkMode(aDC, Transparent);
     SetTextColor(aDC, aTextColor);
     DrawText(aDC, ACaption, Length(ACaption), rct, DT_CENTER_ALIGN);
     SetBkMode(aDC, Opaque);
     DeleteObject(SelectObject(aDC, ofn));
     end;
  finally
    DeleteObject(SelectObject(aDC, opn));
    DeleteObject(SelectObject(aDC, obr));
  end;
end;

procedure GradientFigureBMP(aDC: hDC; aGradientFigure: TGradientFigure;
  aRect: TRect; aBaseColor: TColor;const ACaption:string; aTextColor: TColor;
  aPressed: boolean;var aBMP: TBitmap);
var
  bmp: TBitmap;
begin
  bmp := TBitmap.Create;
  try
    with bmp do
    begin
      Width := Abs(aRect.Right - aRect.Left);
      height := Abs(aRect.Bottom - aRect.Top);
      Canvas.Brush.Color := clFuchsia;
      Canvas.FillRect(Bounds(0, 0, Width, height));
      GradientFigure(Canvas, aGradientFigure, Bounds(0, 0, Width, height),
        aBaseColor, ACaption, aTextColor, aPressed);
      TransparentBlt(aDC, aRect.Left, aRect.Top, Width, height, Canvas.Handle,
        0, 0, Width, height, clFuchsia);
    end;
    if Assigned(aBMP)then
      aBMP.Assign(bmp);
  finally
    FreeAndNil(bmp);
  end;
end;

(******************************************************************************)
constructor TNotifyForm.CreateWithParams(AOwner: TComponent; const aTitle: shortstring;const aMessage:string);//; aExtention : boolean);
var
  Wnd: cardinal;
begin
  //-- only one......
  Wnd := FindWindow('TNotifyForm',nil);
  while Wnd <> 0 do
  begin
    SendMessage(Wnd, WM_CLOSE, 0, 0);
    _sleep(10);
    DestroyWindow(Wnd);
    _sleep(10);
    //SendMessage(wnd,WM_DESTROY,0,0);  _sleep(10);
    Wnd := FindWindow('TNotifyForm',nil);
  end;
  inherited CreateNew(AOwner);
  Name:='NotifyForm_'+ChangeFileExt(ExtractFileName(ParamStr(0)),'');
  try
    Position := poDefaultSizeOnly;
    RestorePos(self, ParamStr(0));
  except
   Position := poOwnerFormCenter;
  end;
  TabStop := false;
  BorderStyle := bsNone;
  //Extent:=aExtention ;
  Extent:= false ;
  ctl3Ddraw := false;
  bmp := nil;
  rgn := 0;
  strTitle := aTitle;
  strMessage := aMessage;
  Prepare;
  onShow  :=NFShow;
  OnPaint := NFRepaint;
  OnKeyUp := NFKeyUp;
  onMouseDown := NFMouseDown;
  onMouseMove := NFMouseMove;
  onClick := NFClick;
  onClose := NFClose;
  ALPHA_Window(Handle, 255);
end;

destructor TNotifyForm.Destroy;
begin
  try
    SavePos(self, ParamStr(0));
  except
  end;
  if Assigned(bmp)then
    FreeAndNil(bmp);
  if rgn <> 0 then
    DeleteObject(rgn);
  inherited Destroy;
end;

procedure TNotifyForm.Prepare;
  procedure SetProps(aCanvas: TCanvas; aFontClr, aPenClr, aBrushClr: TColor);
  begin
    with aCanvas do
    begin
      Brush.Color := aBrushClr;
      Pen.Color := aPenClr;
      Font.Color := aFontClr;
    end;
  end;

  procedure DeltaRect(var aRect : Trect; aLeft,aTop,aRight,aBottom : integer);
  begin
  with aRect do
    begin
    Left  := Left   + aLeft;
    Top   := Top    + aTop;
    Right := Right  + aRight;
    Bottom:= Bottom + aBottom;
    end;
  end;

var
  sz   : TSize;
  _str : string;
  wdt  : integer;
const
  clsBtnOff: integer = 6;
  minMsgRectWidth    = 200;
  minMsgRectHeight   = 70;
  algTitle           = DT_LEFT_ALIGN;
  algMessage         = DT_LEFT or DT_VCENTER or DT_WORDBREAK;
begin
  if Assigned(bmp)then
    FreeAndNil(bmp);
  bmp := TBitmap.Create;
  try
    //bmp.Canvas.Font.Assign(Application.MainForm.Font);
    bmp.Canvas.Font.Handle := GetFont('Tahoma', 8,[]);

    rctTitle:=Bounds(0,0,1,1);
    _str:=IfThen(strTitle<>'',string(strTitle),'ЙQ') ;
    DrawText(bmp.Canvas.Handle,_str,Length(_str),rctTitle,algTitle or DT_CALCRECT);
    rctMessage:=Bounds(0,0,1,1);
    _str:=IfThen(strMessage<>'',strMessage,'ЙQ') ;
    DrawText(bmp.Canvas.Handle,_str,Length(_str),rctMessage,algMessage xor DT_WORDBREAK or DT_CALCRECT);
    if rctMessage.Right>rctTitle.Right
       then sz.cx:=rctMessage.Right
       else sz.cx:=rctTitle.Right;
    sz.cy:=bmp.Canvas.Textheight('ЙQ');



//    _str:=IfThen(strTitle<>'',string(strTitle),'ЙQ');
//    sz := GetTextSize(_str, bmp.Canvas.Font);
//    inc(sz.cx,8);
    rctTitle := Rect(1, 1, sz.cx + 8, sz.cy + 8);
    if rctTitle.Right > Screen.Width div 3 * 2 then
    begin
      rctTitle := Rect(1, 1, Screen.Width div 3 * 2, sz.cy + 2);
      rctTitle.Bottom := GetTextHeightByWidth(string(strTitle), bmp.Canvas.Font,rctTitle.Right, true)+ 2;
    end
    else
    if rctTitle.Right<minMsgRectWidth
       then rctTitle.Right:=minMsgRectWidth;

    rctMessage := Bounds(1
                        , rctTitle.Bottom
                        , rctTitle.Right + rctTitle.Bottom + 2
                        , GetTextHeightByWidth(strMessage, bmp.Canvas.Font, rctTitle.Right + rctTitle.Bottom + 2, true)+6);// ибо смещение текста +4, ну и еще +2 снизу
//    if rctMessage.Right-rctMessage.Left<minMsgRectWidth
//       then begin
//       rctTitle := Rect(1, 1, minMsgRectWidth - rctTitle.Bottom , rctTitle.Bottom);
//       rctMessage.Right := minMsgRectWidth+1;
//       end;
    if rctMessage.Bottom-rctMessage.Top<minMsgRectHeight
       then rctMessage.Bottom:=rctMessage.Top+minMsgRectHeight;

    rctClose := Bounds(rctTitle.Right + 2, 0, rctTitle.Bottom, rctTitle.Bottom);


    wdt := (rctMessage.Right-rctMessage.Left) div 7;
    rctOk := Bounds(wdt, rctMessage.Bottom + 4, wdt * 2, (rctTitle.Bottom- rctTitle.Top));
    rctCancel := Bounds(rctMessage.Right - wdt * 3, rctMessage.Bottom + 4,wdt * 2, (rctTitle.Bottom- rctTitle.Top));

    //rctMessage.Bottom := rctMessage.Bottom + 4;
    //OffsetRect(rctMessage, 0, 2);
    if rctClose.Right > rctMessage.Right then
      bmp.Width := rctClose.Right
    else
      bmp.Width := rctMessage.Right;

    if Extent
       then bmp.height := rctOk.Bottom
       else bmp.height := rctMessage.Bottom;
    //rctTitle.Bottom+2+rctMessage.Bottom-rctMessage.Top;
    bmp.Canvas.Brush.Color := clFuchsia;
    bmp.Canvas.FillRect(bmp.Canvas.ClipRect);
    SelectObject(bmp.Canvas.Handle, bmp.Canvas.Font.Handle);
    if ctl3Ddraw then
    begin
      //GradientFigure(bmp.Canvas, gfRoundRect, rctTitle, clBlue,string(strTitle),clYellow, false);
      BlueCaption(bmp.Canvas.handle,rctTitle,string(strTitle));
      GradientFigure(bmp.Canvas, gfRoundRect, rctClose, clRed, '', clYellow, false);
      //GradientFigure(bmp.Canvas, gfRoundRect, rctMessage, clBlue, strMessage, clAqua, false);
      GrayCaption(bmp.Canvas.handle,rctMessage,strMessage);
      if Extent
         then begin
         GreenCaption(bmp.Canvas.handle,rctOk,'Принять');
         RedCaption(bmp.Canvas.handle,rctCancel,'Отменить');
         end;
    end
    else
    begin
      bmp.Canvas.Pen.Color := clBlack;
      SetProps(bmp.Canvas, clAqua, clBlack, clBlue);
      bmp.Canvas.RoundRect(rctTitle, 5, 5);
      DeltaRect(rctTitle,4,0,-4,0);
      DrawTransparentText(bmp.Canvas.Handle,string(strTitle), rctTitle, algTitle);
      DeltaRect(rctTitle,-4,0,4,0);
      SetProps(bmp.Canvas, clBlack, clBlack, clInfoBk);
      bmp.Canvas.RoundRect(rctMessage, 5, 5);
      DeltaRect(rctMessage,4,4,-4,-4);
      DrawTransparentText(bmp.Canvas.Handle, strMessage, rctMessage, algMessage);
      DeltaRect(rctMessage,-4,-4,4,4);
      SetProps(bmp.Canvas, clBlack, clBlack, clRed);
      bmp.Canvas.RoundRect(rctClose, 5, 5);
      if Extent
         then begin
         SetProps(bmp.Canvas, clBlack, clBlack, clLime);
         bmp.Canvas.RoundRect(rctOk, 5, 5);
         DrawTransparentText(bmp.Canvas.Handle, 'Принять', rctOk, DT_CENTER_ALIGN);
         SetProps(bmp.Canvas, clBlack, clBlack, clRed);
         bmp.Canvas.RoundRect(rctCancel, 5, 5);
         SetProps(bmp.Canvas, clYellow, clBlack, clRed);
         DrawTransparentText(bmp.Canvas.Handle, 'Отменить', rctCancel, DT_CENTER_ALIGN);
         end ;

      //SetProps(bmp.Canvas,clBlack,clYellow,clRed);
      //bmp.Canvas.Pen.Width:=2;
      //DrawLine(bmp.Canvas,Point(rctClose.Left+clsBtnOff-1,rctClose.Top+clsBtnOff),Point(rctClose.Right-clsBtnOff,rctClose.Bottom-clsBtnOff));
      //DrawLine(bmp.Canvas,Point(rctClose.Right-clsBtnOff,rctClose.Top+clsBtnOff),Point(rctClose.Left+clsBtnOff-1,rctClose.Bottom-clsBtnOff));
    end;
    SetProps(bmp.Canvas, clBlack, clYellow, clRed);
    bmp.Canvas.Pen.Width := 2;
    DrawLine(bmp.Canvas
           , Point(rctClose.Left + clsBtnOff - 1,rctClose.Top + clsBtnOff)
           , Point(rctClose.Right - clsBtnOff,rctClose.Bottom - clsBtnOff));
    DrawLine(bmp.Canvas
          , Point(rctClose.Right - clsBtnOff,rctClose.Top + clsBtnOff)
          , Point(rctClose.Left + clsBtnOff - 1,rctClose.Bottom - clsBtnOff));

    //if Width < bmp.Width then
      Width := bmp.Width;
    //if height < bmp.height then
      height := bmp.height;
    rgn := BMPtoRGN(bmp, clFuchsia);
    SetWindowRgn(Handle, rgn, LongBool(true));
  finally
  end;
  Invalidate;
end;

procedure TNotifyForm.WMSetFocus(var aMsg: TMessage);
var
  Wnd: cardinal;
begin
  Wnd := GetFocus;
  if Handle <> HWND(aMsg.WParam)then
    SendMessage(HWND(aMsg.WParam), WM_SETFOCUS, WParam(Wnd), 0);
  aMsg.Result := 0;
  ReplyMessage(aMsg.Result);
end;

procedure TNotifyForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle + WS_EX_NOACTIVATE + MB_SYSTEMMODAL;
end;

procedure TNotifyForm.NFShow(Sender: TObject);
var
 prev : boolean;
begin
prev:=Extent;
Extent:=isModal(self);
if prev<>Extent then Prepare;
if Left+Width>Screen.DesktopWidth
   then Left:=Screen.DesktopWidth - Width - 4 else
if Left<0
   then Left:= 4;
if Top+Height>Screen.DesktopHeight
   then Top:=Screen.DesktopHeight - Height - 4 else
if Top<0
   then Top:= 4;
end;

procedure TNotifyForm.NFRepaint(Sender: TObject);
begin
  if Assigned(bmp)then
    Canvas.Draw(0, 0, bmp);
end;

procedure TNotifyForm.NFKeyUp(Sender: TObject;var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
      Key := VK_NULL;
      if fsModal in FormState
         then ModalResult:=mrCancel
         else Close;
      end;
    VK_RETURN:
      begin
      Key := VK_NULL;
      if fsModal in FormState
         then ModalResult:=mrOk
         else Close;
      end;

  end;
end;

procedure TNotifyForm.NFMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if(Button = mbLeft)and(Cursor = crSizeAll)then
  begin
    ReleaseCapture;
    SendMessage(Handle, WM_SYSCOMMAND, SC_DRAGMOVE, 0);
  end;
end;

procedure TNotifyForm.NFMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  Cursor := crDefault;
  if PtInRect(rctTitle, Point(X, Y))then
    Cursor := crSizeAll
  else
  if PtInRect(rctClose, Point(X, Y)) or
     PtInRect(rctOk, Point(X, Y)) or
     PtInRect(rctCancel, Point(X, Y))
     then Cursor := crHandPoint
end;

procedure TNotifyForm.NFClick(Sender: TObject);
var
  pt: TPoint;
begin
  GetCursorPos(pt);
  Windows.ScreenToClient(Handle, pt);
  if PtInRect(rctTitle, pt)then
  begin

  end
  else if PtInRect(rctMessage, pt)then
  begin

  end
  else if PtInRect(rctClose, pt)then
  begin
  if fsModal in FormState
     then ModalResult:=mrClose
     else Close;
  end
  else if PtInRect(rctOk, pt)then
  begin
   if fsModal in FormState
     then ModalResult:=mrOk
     else Close;
  end
  else if PtInRect(rctCancel, pt)then
  begin
   if fsModal in FormState
     then ModalResult:=mrCancel
     else Close;
  end
end;

procedure TNotifyForm.NFClose(Sender: TObject;var Action: TCloseAction);
begin

  Action := caFree;
end;

procedure ShowNotify(const aMessage, aTitle : string);
var
 nf:TNotifyForm;
begin
nf:=TNotifyForm.CreateWithParams(Application,shortstring(aTitle),aMessage);//, false);
nf.Show;
SetForegroundWindow(nf.Handle);
end;

function ShowNotifyExt(const aMessage, aTitle : string) : boolean;
var
 nf:TNotifyForm;
begin
nf:=TNotifyForm.CreateWithParams(Application,shortstring(aTitle),aMessage);//, false);
try
Result:=nf.ShowModal=mrOk;
finally
nf.Free;
end;
end;

procedure FreeNotify;
var
  Wnd: cardinal;
begin
  //-- only one......
  Wnd := FindWindow('TNotifyForm',nil);
  while Wnd <> 0 do
  begin
    SendMessage(Wnd, WM_CLOSE, 0, 0);
    _sleep(10);
    DestroyWindow(Wnd);
    _sleep(10);
    //SendMessage(wnd,WM_DESTROY,0,0);  _sleep(10);
    Wnd := FindWindow('TNotifyForm',nil);
  end;
end;

//var
// nf : TNotifyForm;
//begin
//nf:=TNotifyForm.CreateWithParams(Application,shortstring(string(_title)+FormatDateTime(' [hh:nn:ss.zzz]',Now)),_message+crlf+Edit1.Text);
//nf.Show;

(******************************************************************************)
(******************************************************************************)
(******************************************************************************)
(******************************************************************************)

constructor TQueryForm.CreateWithParams(AOwner: TComponent; const aTitle, aPrompt:string;var aText:string; aWithBackGnd : boolean);
var
  Wnd: cardinal;
  Rgn : hRGN;
  Rct : TRect;
begin
  //-- only one......
  Wnd := FindWindow('TQueryForm',nil);
  while Wnd <> 0 do
  begin
    SendMessage(Wnd, WM_CLOSE, 0, 0);
    _sleep(10);
    DestroyWindow(Wnd);
    _sleep(10);
    //SendMessage(wnd,WM_DESTROY,0,0);  _sleep(10);
    Wnd := FindWindow('TQueryForm',nil);
  end;

  inherited CreateNew(AOwner);
  KeyPreview:=true;
  Name:='QueryForm_'+ChangeFileExt(ExtractFileName(ParamStr(0)),'');
  try
    Position := poDefaultSizeOnly;
    RestorePos(self, ParamStr(0));
  except
   Position := poOwnerFormCenter;
  end;
  with Screen do rgn:=CreateRectRgn(DesktopLeft,DesktopTop,DesktopWidth, DesktopWidth);
  try
  GetWindowRect(Handle,Rct);
  if not RectInRegion(Rgn, Rct)
     then begin
     if Assigned(Application) and Assigned(Application.MainForm)
        then begin
        Left:=Application.MainForm.Left + (Application.MainForm.Width - Width) div 2;
        Top:=Application.MainForm.Top + (Application.MainForm.Height - Height) div 2;
        end
        else begin
        Left:=Screen.Monitors[0].Left + (Screen.Monitors[0].Width - Width) div 2;
        Top:=Screen.Monitors[0].Top + (Screen.Monitors[0].Height - Height) div 2;
        end;
     end;
  finally
  DeleteObject(rgn);
  end;
  TabStop := false;
  BorderStyle := bsNone;
  ctl3Ddraw := false;
  bmp := nil;
  strTitle := aTitle;
  strPrompt := aPrompt;
  Edit := TEdit.Create(self);
  with Edit do
  begin
    Parent := self;
    ctl3D := false;
    Text := aText;
  end;
  Prepare(aWithBackGnd);
  OnPaint := QFRepaint;
  OnKeyUp := QFKeyUp;
  onMouseDown := QFMouseDown;
  onMouseMove := QFMouseMove;
  onClick := QFClick;
  //if not IsModal(self.Handle)
  //then onClose:=QFClose;
  ALPHA_Window(Handle, 255);
end;

destructor TQueryForm.Destroy;
begin
  try
    SavePos(self, ParamStr(0));
  except
  end;
  if Assigned(bmp)then
    FreeAndNil(bmp);
  if rgn <> 0 then
    DeleteObject(rgn);
  inherited Destroy;
end;

procedure TQueryForm.Prepare(aWithBackGnd : boolean);
  procedure SetProps(aCanvas: TCanvas; aFontClr, aPenClr, aBrushClr: TColor);
  begin
    with aCanvas do
    begin
      Brush.Color := aBrushClr;
      Pen.Color := aPenClr;
      Font.Color := aFontClr;
    end;
  end;

var
  sz: TSize;
  wdt: integer;
const
  clsBtnOff: integer = 6;
begin
  if Assigned(bmp)then
    FreeAndNil(bmp);
  bmp := TBitmap.Create;
  try
    //bmp.Canvas.Font.Assign(Application.MainForm.Font);
    bmp.Canvas.Font.Handle := GetFont('Tahoma', 8,[]);
    sz := GetTextSize(string(strTitle), bmp.Canvas.Font);
    wdt := GetTextSize(string('ЩЩЩ Принять ЩЩЩ  ЩЩЩ Отменить ЩЩЩ'), bmp.Canvas.Font).cx;
    if sz.cx < wdt then
      sz.cx := wdt;
    rctTitle := Rect(1, 1, sz.cx + 8, sz.cy + 8);
    if rctTitle.Right > Screen.Width div 3 * 2 then
    begin
      rctTitle := Rect(1, 1, Screen.Width div 3 * 2, sz.cy + 2);
      rctTitle.Bottom := GetTextHeightByWidth(string(strTitle), bmp.Canvas.Font,
        rctTitle.Right, true)+ 2;
    end;
    rctClose := Bounds(rctTitle.Right + 2, 0, rctTitle.Bottom, rctTitle.Bottom);
    rctPrompt := Bounds(1, rctTitle.Bottom, rctTitle.Right + rctTitle.Bottom +
      2, GetTextHeightByWidth(strPrompt, bmp.Canvas.Font,
      rctTitle.Right (*+ rctTitle.Bottom + 2*), true));
    rctPrompt.Bottom := rctPrompt.Bottom + 4;
    OffsetRect(rctPrompt, 0, 4);
    if rctClose.Right > rctPrompt.Right then
      bmp.Width := rctClose.Right
    else
      bmp.Width := rctPrompt.Right;
    Edit.Left := 4;
    Edit.Top := rctPrompt.Bottom + 4;
    Edit.Width := rctPrompt.Right - Edit.Left * 2;
    rctPrompt.Bottom := Edit.Top + Edit.height + 4;
    wdt := Edit.Width div 7;
    rctOk := Bounds(wdt, rctPrompt.Bottom + 4, wdt * 2, Edit.height);
    rctCancel := Bounds(rctPrompt.Right - wdt * 3, rctPrompt.Bottom + 4, wdt * 2, Edit.height);

    bmp.height := rctOk.Bottom+4;
    //rctTitle.Bottom+2+rctMessage.Bottom-rctMessage.Top;
    //bmp.Height:=Edit.Top+Edit.Height+4;
    bmp.Canvas.Brush.Color := clFuchsia;
    if aWithBackGnd
       then begin
       bmp.Width:=bmp.Width+2 ;
       DrawFrameControl(bmp.Canvas.Handle,bmp.Canvas.ClipRect,DFC_BUTTON, DFCS_BUTTONPUSH)
       end
       else bmp.Canvas.FillRect(bmp.Canvas.ClipRect);
    SelectObject(bmp.Canvas.Handle, bmp.Canvas.Font.Handle);
    if ctl3Ddraw
      then begin
      GradientFigure(bmp.Canvas, gfRoundRect, rctTitle, clBlue,string(strTitle), clYellow, false);
      GradientFigure(bmp.Canvas, gfRoundRect, rctClose, clRed, '',  clYellow, false);
      GradientFigure(bmp.Canvas, gfRoundRect, rctPrompt, clBlue, strPrompt, clAqua, false);
      GradientFigure(bmp.Canvas, gfRoundRect, rctOk, clGreen, 'Принять', clBlack, false);
      GradientFigure(bmp.Canvas, gfRoundRect, rctCancel, clRed, 'Отменить', clYellow, false);
      end
      else begin
      bmp.Canvas.Pen.Color := clBlack;
      SetProps(bmp.Canvas, clAqua, clBlack, clBlue);
      bmp.Canvas.RoundRect(rctTitle, 5, 5);
      DrawTransparentText(bmp.Canvas.Handle,string(strTitle), rctTitle, DT_CENTER_ALIGN);
      SetProps(bmp.Canvas, clBlack, clBlack, clInfoBk);
      if not aWithBackGnd then bmp.Canvas.RoundRect(rctPrompt, 5, 5);
      rctPrompt.Top:=rctPrompt.Top+2;
      rctPrompt.Left := rctPrompt.Left + 4;
      rctPrompt.Right := rctPrompt.Right - 4;
      DrawTransparentText(bmp.Canvas.Handle, strPrompt, rctPrompt, DT_LEFT or DT_VCENTER or DT_WORDBREAK);
      SetProps(bmp.Canvas, clBlack, clBlack, clRed);
      bmp.Canvas.RoundRect(rctClose, 5, 5);
      SetProps(bmp.Canvas, clBlack, clBlack, clLime);
      bmp.Canvas.RoundRect(rctOk, 5, 5);
      DrawTransparentText(bmp.Canvas.Handle, 'Принять', rctOk, DT_CENTER_ALIGN);
      SetProps(bmp.Canvas, clBlack, clBlack, clRed);
      bmp.Canvas.RoundRect(rctCancel, 5, 5);
      SetProps(bmp.Canvas, clYellow, clBlack, clRed);
      DrawTransparentText(bmp.Canvas.Handle, 'Отменить', rctCancel, DT_CENTER_ALIGN);
      end;
    SetProps(bmp.Canvas, clBlack, clYellow, clRed);
    bmp.Canvas.Pen.Width := 2;
    DrawLine(bmp.Canvas, Point(rctClose.Left + clsBtnOff - 1,
      rctClose.Top + clsBtnOff), Point(rctClose.Right - clsBtnOff,
      rctClose.Bottom - clsBtnOff));
    DrawLine(bmp.Canvas, Point(rctClose.Right - clsBtnOff,
      rctClose.Top + clsBtnOff), Point(rctClose.Left + clsBtnOff - 1,
      rctClose.Bottom - clsBtnOff));

    if Width < bmp.Width then
      Width := bmp.Width;
    if height < bmp.height then
      height := bmp.height;
    rgn := BMPtoRGN(bmp, clFuchsia);
    if aWithBackGnd
       then begin
       self.Width := bmp.Width;
       self.Height:= bmp.Height;
       end
       else SetWindowRgn(Handle, rgn, LongBool(true))
  finally
  end;
  Invalidate;
end;

procedure TQueryForm.WMSetFocus(var aMsg: TMessage);
var
  Wnd: cardinal;
begin
  Wnd := GetFocus;
  if Handle <> HWND(aMsg.WParam)then
    SendMessage(HWND(aMsg.WParam), WM_SETFOCUS, WParam(Wnd), 0);
  aMsg.Result := 0;
  ReplyMessage(aMsg.Result);
end;

procedure TQueryForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle + WS_EX_NOACTIVATE;
end;

procedure TQueryForm.QFRepaint(Sender: TObject);
begin
  if Assigned(bmp)then
    Canvas.Draw(0, 0, bmp);
end;

procedure TQueryForm.QFKeyUp(Sender: TObject;var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
        Key := VK_NULL;
        Close;
      end;
    VK_RETURN:
      begin
        Key := VK_NULL;
        ModalResult := mrOk;
      end;
  end;
end;

procedure TQueryForm.QFMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if(Button = mbLeft)and(Cursor = crSizeAll)then
  begin
    ReleaseCapture;
    SendMessage(Handle, WM_SYSCOMMAND, SC_DRAGMOVE, 0);
  end;
end;

procedure TQueryForm.QFMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  Cursor := crDefault;
  if PtInRect(rctTitle, Point(X, Y))then
    Cursor := crSizeAll
  else if PtInRect(rctClose, Point(X, Y))then
    Cursor := crHandPoint
  else if PtInRect(rctOk, Point(X, Y))then
    Cursor := crHandPoint
  else if PtInRect(rctCancel, Point(X, Y))then
    Cursor := crHandPoint
  else
end;

procedure TQueryForm.QFClick(Sender: TObject);
var
  pt: TPoint;
begin
  GetCursorPos(pt);
  Windows.ScreenToClient(Handle, pt);
  if PtInRect(rctTitle, pt)then
  begin

  end
  else if PtInRect(rctPrompt, pt)then
  begin
  end
  else if PtInRect(rctOk, pt)then
  begin
    //if IsModal(self.Handle)
    //then ModalResult:=mrOk
    //else Close;
    ModalResult := mrOk;
  end
  else if PtInRect(rctCancel, pt)then
  begin
    //if IsModal(self.Handle)
    //then ModalResult:=mrcancel
    //else Close;
    ModalResult := mrCancel;
  end
  else if PtInRect(rctClose, pt)then
  begin
    ModalResult := mrCancel;
  end
end;

procedure TQueryForm.QFClose(Sender: TObject;var Action: TCloseAction);
begin
if not (fsModal in FormState)
   then Action := caFree;
end;


var   // -- !!! из-за грёбаной TCustomForm.SetWindowToMonitor;
 IQN_Handle : cardinal = 0;
 IQN_Point  : TPoint = (X:-1;Y:-1);

procedure IQNTimerProc(wnd: HWND; Msg: UINT; idEvent: UINT; Time: DWORD); stdcall;
var
 wi : TWindowInfo;
begin
if (IQN_Handle<>0) and (IQN_Point.X>-1) and (IQN_Point.Y>-1)
   then begin
   GetWindowInfo(IQN_Handle, wi);
   if (wi.dwStyle and WS_VISIBLE>0) and
      ((wi.rcWindow.Left<>IQN_Point.X) or (wi.rcWindow.Top<>IQN_Point.X))
      then begin
      SetWindowPos(IQN_Handle,0,IQN_Point.X,IQN_Point.Y,0,0,SWP_NOSIZE or SWP_NOZORDER);
      KillTimer(IQN_Handle,1);
      end;
   end;
end;


function InputQueryNew(const aTitle, aPrompt:string; var aText:string; aWithBackGnd : boolean = false): boolean;
begin
  Result := false;
  with TQueryForm.CreateWithParams(Application, aTitle, aPrompt, aText, aWithBackGnd)do
    try
    if Screen.MonitorCount>1
       then begin
       IQN_Handle:=Handle;
       if Assigned(Application) and Assigned(Application.MainForm)
          then IQN_Point:=Point(Left,Top)
          else IQN_Point:=Point((Screen.Width - Width) div 2 ,(Screen.Height - Height) div 2);
       SetTimer(IQN_Handle,1,50,@IQNTimerProc);
       end;

      if ShowModal = mrOk then
      begin
        aText := Edit.Text;
        Result := true;
      end;
    finally
      Free;
    end;
end;

(******************************************************************************)

constructor TMenuForm.CreateWithParams(AOwner: TComponent;
  const aItems: TMenuFormList; aNeedFreeOnClose: boolean = true);
var
  Wnd: cardinal;
begin
  //-- only one......
  Wnd := FindWindow('TMenuForm',nil);
  while Wnd <> 0 do
  begin
    SendMessage(Wnd, WM_CLOSE, 0, 0);
    _sleep(10);
    DestroyWindow(Wnd);
    _sleep(10);
    //SendMessage(wnd,WM_DESTROY,0,0);  _sleep(10);
    Wnd := FindWindow('TNotifyForm',nil);
  end;
  inherited CreateNew(AOwner);
  Name:='mfTools';
  NeedFreeOnClose := aNeedFreeOnClose;
  TabStop := false;
  BorderStyle := bsNone;
  ctl3Ddraw := true;
  bmp := nil;
  rgn := 0;
  SetLength(Items, Length(aItems));
  System.Move(aItems[0], Items[0], SizeOf(TMenuFormItem)* Length(Items));
  Prepare;
  OnPaint := MFRepaint;
  OnKeyUp := MFKeyUp;
  onMouseDown := MFMouseDown;
  onMouseMove := MFMouseMove;
  onClick := MFClick;
  onClose := MFClose;
  ALPHA_Window(Handle, 255);
  inClick := false;
  try
    RestorePos(self, ParamStr(0));
  except
  end;
end;

destructor TMenuForm.Destroy;
begin
  try
    SavePos(self, ParamStr(0));
  except
  end;
  if Assigned(bmp)then
    FreeAndNil(bmp);
  if rgn <> 0 then
    DeleteObject(rgn);
  inherited Destroy;
end;

procedure TMenuForm.Prepare;
  procedure SetProps(aCanvas: TCanvas; aFontClr, aPenClr, aBrushClr: TColor);
  begin
    with aCanvas do
    begin
      Brush.Color := aBrushClr;
      Pen.Color := aPenClr;
      Font.Color := aFontClr;
    end;
  end;

var
  cnt: integer;
  sz: TSize;
  maxWidth: integer;
  maxHeight: integer;
begin
  if Assigned(bmp)then
    FreeAndNil(bmp);
  bmp := TBitmap.Create;
  try
    //bmp.Canvas.Font.Assign(Application.MainForm.Font);
    bmp.Canvas.Font.Handle := GetFont('Tahoma', 8,[]);
    maxWidth := 0;
    maxHeight := 0;
    for cnt := 0 to High(Items)do
    begin
      sz := GetTextSize(AC2Str(Items[cnt].Caption), bmp.Canvas.Font);
      if sz.cx > maxWidth then
        maxWidth := sz.cx;
      if sz.cy > maxHeight then
        maxHeight := sz.cy;
    end;
    maxWidth := maxWidth + 16;
    if maxWidth > Screen.Width div 5 * 2 then
      maxWidth := Screen.Width div 5 * 2;
    maxHeight := maxHeight + 6;
    bmp.Width := maxWidth + 4;
    bmp.height :=(maxHeight + 4)*(Length(Items))+ maxHeight div 2 + 4;
    bmp.Canvas.Brush.Color := clFuchsia;
    bmp.Canvas.FillRect(bmp.Canvas.ClipRect);
    for cnt := 0 to High(Items)do
    begin
      Items[cnt].Rect := Bounds(2,(maxHeight + 4)*(cnt)+ maxHeight div 2,
        maxWidth, maxHeight);
      Items[cnt].ctl3D := ctl3Ddraw;
      if Items[cnt].ctl3D then
      begin
        Items[cnt].Figure := gfRoundRect;
        Items[cnt].BaseColor := clAqua;
        Items[cnt].TextColor := clBlack;
      end
      else
      begin
        Items[cnt].BrushColor := clInfoBk;
        Items[cnt].PenColor := clBlack;
        Items[cnt].FontColor := clBlack;
      end;
    end;

    if Length(Items)> 0
       then BasePoint.Y := Items[0].Rect.Top +(Items[0].Rect.Bottom - Items[0].Rect.Top)div 2;
    // -- заголовок (синяя вертикальная полоса)
    if BasePoint.X>Screen.Width
       then BasePoint.X:=BasePoint.X-Screen.Width;
    rctTitle := Bounds(BasePoint.X, 0, maxHeight, bmp.height);
    if ctl3Ddraw
       then GradientFigure(bmp.Canvas, gfRoundRect, rctTitle, clBlue, '', clBlack, false)
       else begin
       SetProps(bmp.Canvas, clBlack, clGreen, clPaleGreen);
       bmp.Canvas.RoundRect(rctTitle, 5, 5);
       end;
    // -- закрыватель (красная горизонтальная полоса)
    rctClose := Bounds(maxWidth - maxHeight, 0, maxHeight, maxHeight div 2 - 1);
    if ctl3Ddraw//отключена реализция закрытия через CMMouseLeave
       then GradientFigure(bmp.Canvas, gfRoundRect, rctClose, clRed, '', clBlack, false)
       else begin
       SetProps(bmp.Canvas, clYellow, clBlack, clRed);
       bmp.Canvas.RoundRect(rctClose, 3, 3);
       end;

    for cnt := 0 to High(Items)do
    begin
      if Items[cnt].ctl3D then
      begin
        GradientFigure(bmp.Canvas, Items[cnt].Figure, Items[cnt].Rect, Items[cnt].BaseColor, '', Items[cnt].TextColor, false);
        SetProps(bmp.Canvas, Items[cnt].TextColor, Items[cnt].BaseColor, Items[cnt].BaseColor);
      end
      else
      begin
        SetProps(bmp.Canvas, Items[cnt].FontColor, Items[cnt].PenColor, Items[cnt].BrushColor);
        bmp.Canvas.RoundRect(Items[cnt].Rect, 5, 5);
      end;
      Items[cnt].Rect.Left := Items[cnt].Rect.Left + 4;
      DrawTransparentText(bmp.Canvas, AC2Str(Items[cnt].Caption),
        Items[cnt].Rect, DT_LEFT_ALIGN);
      Items[cnt].Rect.Left := Items[cnt].Rect.Left - 4;
    end;

    Width := bmp.Width;
    height := bmp.height;
    rgn := BMPtoRGN(bmp, clFuchsia);
    SetWindowRgn(Handle, rgn, LongBool(true));
  finally
  end;
  Invalidate;
end;

procedure TMenuForm.WMSetFocus(var aMsg: TMessage);
var
  Wnd: cardinal;
begin
  Wnd := GetFocus;
  if Handle <> HWND(aMsg.WParam)then
    SendMessage(HWND(aMsg.WParam), WM_SETFOCUS, WParam(Wnd), 0);
  aMsg.Result := 0;
  ReplyMessage(aMsg.Result);
end;

//procedure TMenuForm.CMMouseLeave(var aMsg : TMessage);
//begin
//aMsg.Result:=1;
//ReplyMessage(aMsg.Result);
//if not inClick then Close;
//end;

procedure TMenuForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle + WS_EX_NOACTIVATE;
end;

procedure TMenuForm.MFShowIn(aPoint: TPoint);
var
  pt: TPoint;
begin
BasePoint.Y := 0;
if aPoint.X + Width > Screen.DesktopWidth
   then pt.X := Screen.Width - Width
   else pt.X := aPoint.X;
BasePoint.X := aPoint.X - pt.X + 8;
if aPoint.Y + height > Screen.DesktopHeight
   then pt.Y := aPoint.Y - height
   else pt.Y := aPoint.Y;
Left := pt.X;
Top := pt.Y;
//Show;
Visible:=true;
BringToFront;
Prepare;
Repaint;
Left := pt.X; // -- !!! из-за грёбаной TCustomForm.SetWindowToMonitor;
Top := pt.Y;
if BasePoint.Y > 0
   then begin
   System.Move(BasePoint, pt, SizeOf(TPoint));
   Windows.ClientToScreen(Handle, pt);
   SetCursorPos(pt.X, pt.Y);
   end;
end;

procedure TMenuForm.MFRepaint(Sender: TObject);
begin
  if Assigned(bmp)then
    Canvas.Draw(0, 0, bmp);
end;

procedure TMenuForm.MFKeyUp(Sender: TObject;var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
        Key := VK_NULL;
        Close;
      end;
  end;
end;

procedure TMenuForm.MFMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if(Button = mbLeft)and(Cursor = crSizeAll)then
  begin
    ReleaseCapture;
    SendMessage(Handle, WM_SYSCOMMAND, SC_DRAGMOVE, 0);
  end;
end;

procedure TMenuForm.MFMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
var
  pt: TPoint;
  ind: integer;
  cnt: integer;
begin
  Cursor := crDefault;
  pt := Point(X, Y);
  ind :=-1;

  for cnt := 0 to High(Items)do
    if PtInRect(Items[cnt].Rect, pt)then
    begin
      ind := cnt;
      Break;
    end;
  if(ind >= Low(Items))and(ind <= High(Items))then
    Cursor := crHandPoint
  else if PtInRect(rctClose, pt)and(ind =-1)then
  else if PtInRect(rctTitle, pt)and(ind =-1)then
    Cursor := crSizeAll;
end;

procedure TMenuForm.MFClick(Sender: TObject);
var
  pt: TPoint;
  ind: integer;
  cnt: integer;
  MFIO: TMenuFormItemObject;
begin
  inClick := true;
  try
    GetCursorPos(pt);
    Windows.ScreenToClient(Handle, pt);
    ind :=-1;

    for cnt := 0 to High(Items)do
      if PtInRect(Items[cnt].Rect, pt)then
      begin
        ind := cnt;
        Break;
      end;

    if(PtInRect(rctTitle, pt)or PtInRect(rctClose, pt))and(ind =-1)then
    begin
      Close;
    end
    else
    begin
      for cnt := 0 to High(Items)do
        if PtInRect(Items[cnt].Rect, pt)then
        begin
          Hide;
          if Assigned(Items[cnt].Proc)then
          begin
            (*ATTENTION*) //-- ?? before,  see TMenuItem release ??
            if(AC2Str(Items[cnt].ChkCaptions[false])<> '')and
              (AC2Str(Items[cnt].ChkCaptions[true])<> '')then
            begin
              Items[cnt].Checked := not Items[cnt].Checked;
              System.Move(Items[cnt].ChkCaptions[Items[cnt].Checked][1],
                Items[cnt].Caption[1], Length(Items[cnt].Caption)* SizeOfChar);
            end;

            MFIO := TMenuFormItemObject.Create;
            try
              System.Move(Items[cnt], MFIO.Item, SizeOf(TMenuFormItem));
              Items[cnt].Proc(MFIO);
              System.Move(MFIO.Item, Items[cnt], SizeOf(TMenuFormItem));
            finally
              MFIO.Free;
            end;
          end;
          Close;
          //Break;
        end;
    end;
  finally
    inClick := false;
  end;
end;

procedure TMenuForm.MFClose(Sender: TObject;var Action: TCloseAction);
begin
  if NeedFreeOnClose then
    Action := caFree
    //else Action:=caFree
end;

(******************************************************************************)

procedure TBeepSequence.Load(const aINIFileName, aSection:string);
var
  ini: TINIFile;
  strl: TStringList;
  sda: TStringDynArray;
  cnt: integer;
  ind: integer;
begin
  Clear;
  ini := TINIFile.Create(aINIFileName);
  strl := TStringList.Create;
  try
    ini.ReadSectionValues(aSection, strl);
    for cnt := 0 to strl.Count - 1 do
    begin
      sda := SplitString(Trim(Copy(strl[cnt], Pos('=', strl[cnt])+ 1,
        Length(strl[cnt]))), ',;');
      ind :=-1;
      if(Length(sda)= 2)and CheckValidInteger(sda[0], true)and
        CheckValidInteger(sda[1], true)then
        ind := Add(StrToInt(sda[0]), StrToInt(sda[1]));
      if ind =-1 then;
    end;
    NeedStop := false;
  finally
    FreeAndNil(ini);
    FreeStringList(strl);
  end;
end;

function TBeepSequence.Add(afreq, aDur: Word; aIndex: integer =-1): integer;
var
  ind: integer;
begin
  ind := Length(Items);
  SetLength(Items, ind + 1);
  if(aIndex =-1)or(aIndex >= High(Items))then
  begin
    Items[ind].Frequency := afreq;
    Items[ind].Duration := aDur;
    Result := ind;
  end
  else
  begin
    System.Move(Items[aIndex], Items[aIndex + 1],
      (ind - aIndex)* SizeOf(TBeepItem));
    Items[aIndex].Frequency := afreq;
    Items[aIndex].Duration := aDur;
    Result := aIndex;
  end;
end;

procedure TBeepSequence.Play(aReverse: boolean = false);
var
  cnt: integer;
begin
  NeedStop := false;
  if not aReverse then
    cnt := 0
  else
    cnt := High(Items);
  while(cnt >= Low(Items))and(cnt <= High(Items))do
  begin
    _sleep(1);
    if NeedStop then
      Exit;
    with Items[cnt]do
      Windows.Beep(Frequency, Duration);
    _sleep(1);
    if NeedStop then
      Exit;
    if aReverse then
      Dec(cnt)
    else
      Inc(cnt);
  end;
end;

procedure TBeepSequence.Stop;
begin
  NeedStop := true;
  _sleep(1);
end;

procedure TBeepSequence.Clear;
begin
  Stop;
  SetLength(Items, 0);
end;

(******************************************************************************)

procedure TFontRange.Fill(const aFontName:string);
var
  dc: hDC;
  hf: hFont;
  lpgs: PGlyphSet;
  res: DWORD;
  cnt: integer;
  rng: array of tagWCRANGE;
  ind: integer;
begin
  Clear;
  FontName := shortstring(aFontName);
  hf := GetFont(string(FontName), 10,[]);
  dc := getDC(0);
  lpgs := nil;
  try
    SelectObject(dc, hf);
    res := GetFontUnicodeRanges(dc,nil);
    lpgs := Allocmem(res);
    GetFontUnicodeRanges(dc, lpgs);
    if lpgs^.cRanges > 0 then
    begin
      SetLength(rng, lpgs^.cRanges);
      System.Move(lpgs^.Ranges[0], rng[0], lpgs^.cRanges * SizeOf(tagWCRANGE));
      for cnt := 0 to High(rng)do
      begin
        if(Word(rng[cnt].wcLow)>= 32)then
        begin
          ind := Length(Ranges);
          SetLength(Ranges, ind + 1);
          Ranges[ind].Min := Word(rng[cnt].wcLow);
          Ranges[ind].Max := Ranges[ind].Min + rng[cnt].cGlyphs;
        end;
      end;
    end;
  finally
    if Assigned(lpgs)then
      FreeMem(lpgs);
    SetLength(rng, 0);
    ReleaseDC(0, dc);
    DeleteObject(hf);
  end;
end;

function TFontRange.CharExists(aChar: Word): boolean;
var
  cntR: integer;
begin
  Result := false;
  for cntR := 0 to High(Ranges)do
  begin
    Result :=((aChar >= Ranges[cntR].Min)and(aChar <= Ranges[cntR].Max));
    if Result then
      Break;
  end;
end;

function TFontRange.CharExists(aChar: widechar): boolean;
begin
  Result := CharExists(Word(aChar));
end;

procedure TFontRange.Clear;
begin
  SetLength(Ranges, 0);
end;

(******************************************************************************)

(* --- TIconList --- *)
constructor TNamedImageList.Create(AOwner: TComponent);
begin
inherited Create(AOwner);
end;

destructor TNamedImageList.Destroy;
begin
SetLength(OSObjects,0);
Clear;
inherited Destroy;
end;

function TNamedImageList.IndexOf(const aOSObject : string) : integer;
var
 cnt : integer;
 tst : string;
begin
tst:=AnsiUpperCase(aOSObject);
if DirectoryExists(tst)
   then SetTailbackSlash(tst);
for cnt:=0 to High(OSObjects)
  do if AnsiUpperCase(AC2Str(OSObjects[cnt].OSObject)) = tst
        then begin
        Result:=cnt;
        Exit;
        end;
Result:=-1;
end;


function TNamedImageList.PictureIndexOf(const aOSObject : string) : integer;
var
 cnt : integer;
 tst : string;
begin
tst:=AnsiUpperCase(aOSObject);
if DirectoryExists(tst)
   then SetTailbackSlash(tst);
for cnt:=0 to High(OSObjects)
  do if AC2Str(OSObjects[cnt].OSObject) = tst
        then begin
        Result:=OSObjects[cnt].Index;
        Exit;
        end;
Add(aOSObject,Result);
end;


function TNamedImageList.Add(const aOSObject : string; out aImageIndex : integer) : integer;
var
 os_obj : string;
begin
Result:=IndexOf(aOSObject);
if Result=-1
   then begin
   Result:=Length(OSObjects);
   SetLength(OSObjects,Result+1);
   os_obj:=AnsiUpperCase(aOSObject);
   if DirectoryExists(os_obj)
      then os_Obj:=SetTailBackSlash(os_obj);
   Str2AC(os_obj,OSObjects[Result].OSObject);
   OSObjects[Result].Index:=AddIconForFile(self,os_obj);
   end;
aImageIndex:=OsObjects[Result].Index;
end;


function TNamedImageList.AddFromImageList(const aName : string; aImageList : TImageList; aIndex : integer; out aImageIndex : integer) : integer;
var
 bmp : TBitmap;
begin
Result:=IndexOf(aName);
if Result=-1
   then begin
   bmp := TBitmap.Create;
   try
   aImageList.DrawingStyle:=dsTransparent;
   with bmp do
     begin
     Width:=aImageList.Width;
     Height:=aImageList.Height;
     Canvas.Brush.Color:=clFuchsia;
     Canvas.FillRect(Bounds(0,0,Width,Height));
     end;
   aImageList.Draw(bmp.Canvas,0,0,aIndex);
   Result:=Length(OSObjects);
   SetLength(OSObjects,Result+1);
   Str2AC(AnsiUpperCase(aName),OSObjects[Result].OSObject);
   if Assigned(bmp)and not bmp.Empty
      then OSObjects[Result].Index := self.AddMasked(bmp, clFuchsia);
   finally
   bmp.Free;
   end;
   end;
aImageIndex:=OsObjects[Result].Index;
end;

procedure TListViewFiles.WM_DROPFILES_Handler(var aMsg: TMessage);
var
  hDrop: cardinal;
  cnt: integer;
  fCnt: cardinal;
  buf: PChar;
  Size: cardinal;
  files: TStringDynArray;
  ind: integer;
  Item: TListItem;

  bmp: TBitmap;
begin
  Screen.Cursor := crAppStart;
  SetLength(files, 0);
  try
    //http://msdn.microsoft.com/en-us/library/bb774303%28VS.85%29.aspx
    //http://msdn.microsoft.com/en-us/library/bb776905%28v=vs.85%29.aspx
    hDrop := cardinal(aMsg.WParam);
    fCnt := DragQueryFile(hDrop, cardinal(-1),nil, 0);
    try
      //SetLength(files,fCnt);
      for cnt := 0 to fCnt - 1 do
      begin
        Size := DragQueryFile(hDrop, 0,nil, 0);
        Size :=(Size + 2)* cardinal(SizeOfChar);
        buf := Allocmem(Size);
        try
          DragQueryFile(hDrop, cnt, buf, Size);
          ind := Length(files);
          SetLength(files, ind + 1);
          files[ind]:= StrPas(buf);
          if DirectoryExists(files[ind])then
            GetAllFilesRecur(files[ind], files);
        finally
          FreeMem(buf);
        end;
      end;
    finally
      DragFinish(hDrop);
    end;
    if Length(files)= 0 then
      Exit;
    Items.BeginUpdate;
    try
      for cnt := 0 to High(files)do
      begin
        Item := Items.Add;
        if Assigned(ILIcons)then
        begin
          bmp := TBitmap.Create;
          try
            GetBmp16FromFileIcon(files[cnt], bmp, clFuchsia);
            ind :=-1;
            if Assigned(bmp)and not bmp.Empty then
              ind := ILIcons.AddMasked(bmp, clFuchsia);
            Item.ImageIndex := ind;
          finally
            //FreeAndNil(bmp);
            bmp.Free;
          end;
        end;
        Item.Caption := files[cnt];
        Item.SubItems.Add(FormatFloat(',##0', GetSizeOfFile(Item.Caption)));
        Item.SubItems.Add(AnsiUpperCase(Copy(ExtractFileExt(Item.Caption), 2,
          MAX_PATH)));
      end;
      CalcCommonSize;
    finally
      SetLength(files, 0);
      Screen.Cursor := crDefault;
      Items.EndUpdate;
    end;
  except
    on E: Exception do;
  end;
end;

procedure TListViewFiles.WM_CONTEXT_Handler(var aMsg: TMessage);
var
  MousePos: TPoint;
  Handled: boolean;
begin
MousePos:=Point(aMsg.LParamLo, aMsg.LParamHi);
Windows.ScreenToClient(aMsg.wParam,MousePos);
if Assigned(OnContextPopup)
   then begin
   OnContextPopup(self, MousePos, Handled);
   if Handled then Exit;
   end;
if Assigned(ItemFocused)and FileExists(ItemFocused.Caption)
   then GetFileContextMenu(ItemFocused.Caption, MousePos, self);
end;

procedure TListViewFiles.WM_DBLCLICK_Handler(var aMsg: TMessage);
begin
  if Assigned(OnDblClick)
     then  OnDblClick(self)
     else
  if Assigned(ItemFocused)and FileExists(ItemFocused.Caption)
     then FileOpenNT(ItemFocused.Caption);
end;

procedure TListViewFiles.WM_KEYUP_Handler(var aMsg: TMessage);
var
  Key: Word;
  Shift: TShiftState;
  cnt: integer;
  ndi: boolean;
begin
  Key := aMsg.WParam;
  //MouseOriginToShiftState , KeysToShiftState ......
  Shift := KeyDataToShiftState(aMsg.LParam);
  if Assigned(OnKeyUp)
     then OnKeyUp(self, Key, Shift)
     else
  if not Assigned(OnKeyUp) and not Assigned(OnKeyDown) and not Assigned(OnKeyPress)
     then begin
     case Key of
      VK_DELETE:
        begin
          Items.BeginUpdate;
          try
            ndi := Assigned(ILIcons);
            for cnt := Items.Count - 1 downto 0 do
              if(Items[cnt].Selected)or(ssShift in Shift)then
              begin
                Items[cnt].Delete;
                if ndi and(ILIcons.Count > cnt)then
                  ILIcons.Delete(cnt);
              end;
          finally
            Items.EndUpdate;
          end;
          //if ssShift in Shift
          CalcCommonSize;
        end;
      end;
      inherited;
      end;
end;


procedure TListViewFiles.CalcCommonSize;
var
  cnt: integer;
  sz: integer;
begin
  try
    sz := 0;
    for cnt := 0 to Items.Count - 1
       do  sz := sz + StrToIntDef(StringReplace(Items[cnt].SubItems[0], #160, '',
        [rfReplaceAll]), 0);

    if Assigned(LabInfoSize)
       then begin
       LabInfoSize.Caption := Format('Общий размер : %s %s в %d %s', [FormatFloat(',0', sz), GetDefUnit(sz, dfByte) , Items.Count, GetDefUnit(Items.Count, dfFileIn)]);
       LabInfoSize.Tag:=sz;
       end;
  except
    on E: Exception do
  end;
end;


procedure TListViewFiles.RefreshImageList(aClearImages : boolean = true);
var
 cnt : integer;
begin
if aClearImages
   then ILIcons.Clear;
Items.BeginUpdate;
try
for cnt:=0 to Items.Count-1
  do //Items[cnt].ImageIndex:=AddIconForFile(ILIcons,Items[cnt].Caption);
     Items[cnt].ImageIndex:=ILIcons.PictureIndexOf(Items[cnt].Caption);
finally
Items.EndUpdate;
end;
end;


function TListViewFiles.AddFiles(const aFiles: TStringDynArray): integer;
var
  cnt: integer;
  ind: integer;
  Item: TListItem;
  bmp: TBitmap;
  fd : TFileDates;
begin
  Result := 0;
  try
    for cnt := 0 to High(aFiles)do
    begin
      Item := Items.Add;
      if Assigned(ILIcons)then
      begin
        bmp := TBitmap.Create;
        try
          GetBmp16FromFileIcon(aFiles[cnt], bmp, clFuchsia);
          ind :=-1;
          if Assigned(bmp)and not bmp.Empty then
            ind := ILIcons.AddMasked(bmp, clFuchsia);
          Item.ImageIndex := ind;
        finally
          bmp.Free;
        end;
      end;
      Item.Caption := aFiles[cnt];
      Item.SubItems.Add(FormatFloat(',##0', GetSizeOfFile(Item.Caption)));
      Item.SubItems.Add(AnsiUpperCase(Copy(ExtractFileExt(Item.Caption), 2, MAX_PATH)));
      GetOSObjectDates(aFiles[cnt],fd);
      if fd.DateCreate<>0
         then Item.SubItems.Add(FormatDateTime('dd.mm.yyyy hh:nn:ss',fd.DateCreate));
      Result := Result + 1;
    end;
    CalcCommonSize;
  except
    on E: Exception do
  end;
end;


function TListViewFiles.UpdateItem(aIndex : integer; const aFileName : string) : boolean;
var
 fd : TFileDates;
begin
Result:=False;
try
Items[aIndex].Caption:=aFileName;
Items[aIndex].ImageIndex :=AddIconForFile(ILIcons,aFileName);
Items[aIndex].SubItems[0]:=FormatFloat(',##0', GetSizeOfFile(aFileName));
Items[aIndex].SubItems[1]:=AnsiUpperCase(Copy(ExtractFileExt(aFileName), 2, MAX_PATH));
GetOSObjectDates(aFileName,fd);
if fd.DateCreate<>0
   then Items[aIndex].SubItems[2]:=FormatDateTime('dd.mm.yyyy hh:nn:ss',fd.DateCreate);
Result:=True;
except
on E : Exception do ;
end;
end;


function TListViewFiles.ColumnIndex(const aColumnCaption : string) : integer;
var
 cnt : integer;
 tst : string;
begin
Result:=-1;
tst:=AnsiUpperCase(aColumnCaption);
for cnt:=0 to Columns.Count-1
  do if tst = AnsiUpperCase(Columns[cnt].Caption)
        then begin
        Result:=cnt;
        Break;
        end;
end;


function TListViewFiles.IndexOf_Caption(const aCaption : string) : integer;
var
 cnt : integer;
begin
Result:=-1;
for cnt:=0 to Items.Count-1
  do if Items[cnt].Caption = aCaption
        then begin
        Result:=cnt;
        Break;
        end;
end;


function TListViewFiles.RemoveByCaption(const aCaption : string) : integer;
begin
Result:=IndexOf_Caption(aCaption);
if Result=-1 then Exit;
Items.BeginUpdate;
try
Items[Result].Delete;
finally
Items.EndUpdate;
end;
if Result>0
   then Result:=Result-1;
if Result>Items.Count-1 then Result:=-1;

end;

constructor TListViewFiles.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  //
end;

destructor TListViewFiles.Destroy;
begin
  //
  inherited Destroy;
end;


(* --- TFolderTreeList --- *)

function TFolderTreeList.Fill(const aBaseFolder : string) : integer;
  procedure AddChild(const aFolder : string; aLvl : integer);
  var
    sda : TStringDynArray;
    cnt : integer;
    ind : integer;
  begin
  GetAllFolders(aFolder,sda);
  for cnt:=0 to High(sda)
    do begin
    ind:=Length(Items);
    Setlength(Items,ind+1);
    with Items[ind]
      do begin
      Str2AC(sda[cnt],folder);
      level:=aLvl;
      AddChild(sda[cnt],aLvl+1);
      end;
    end;
  end;
var
 lvl : integer;
begin
Clear;
lvl:=0;
SetLength(Items,1);
with Items[0]
  do begin
  Str2AC(aBaseFolder,folder);
  level:=lvl;
  AddChild(aBaseFolder,lvl+1);
  end;
Result:=Length(Items);
end;

function TFolderTreeList.GetTreeText : string;
var
 cnt : integer;
begin
Result:='';
for cnt:=0 to High(Items)
  do Result:=Result+DupeString(#9,Items[cnt].Level)+AC2Str(Items[cnt].Folder)+crlf;
Result:=Trim(Result);
end;

function TFolderTreeList.FillTreeView(aTV : TTreeView; aShortName : boolean) : boolean;
var
 cnt : integer;
 tmp : string;
 SS  : TStringStream;
begin
aTV.Items.BeginUpdate;
try
for cnt:=0 to aTV.Items.Count-1
  do if Assigned(aTV.Items[cnt].Data)
        then FreeMem(aTV.Items[cnt].Data);
tmp:=GetTreeText;
  SS:=TStringStream.Create;
  try
  SS.WriteString(tmp);
  SS.Position:=0;
  aTV.LoadFromStream(SS);
  finally
  SS.Free;
  end;
for cnt:=0 to aTV.Items.Count-1
  do begin
  tmp:=SetTailbackSlash(aTV.Items[cnt].Text);
  aTV.Items[cnt].Data:=AllocMem(Length(tmp)*SizeOfChar+1);
  StrPCopy(aTV.Items[cnt].Data,tmp);
  if aShortName
     then aTV.Items[cnt].Text:=SetTailbackSlash(StringReplace(tmp,FnCommon.UpDirectoryN(tmp,1),'',[rfIgnoreCase]),false);
  end;
aTV.FullExpand;
finally
aTV.Items.EndUpdate;
end;
Result:=true;
end;

procedure TFolderTreeList.Clear;
begin
Setlength(Items,0);
end;

(******************************************************************************)

procedure SimpleLED(aCanvas: TCanvas; aTop, aLeft: integer; IsOn: boolean);
const
  LedSize: integer = 17;
begin
  if IsOn then
    GradientFigure(aCanvas, gfEllipse, Bounds(aLeft, aTop, LedSize, LedSize),
      clLime, '', clYellow, false)
  else
    GradientFigure(aCanvas, gfEllipse, Bounds(aLeft, aTop, LedSize, LedSize),
      clRed, '', clYellow, false)
end;

procedure SimpleLED(aHandle: HWND; aTop, aLeft: integer; IsOn: boolean);
const
  LedSize: integer = 17;
var
  dc: hDC;
begin
  dc := GetWindowDC(aHandle);
  try
    if IsOn then
      GradientFigure(dc, gfEllipse, Bounds(aLeft, aTop, LedSize, LedSize),
        clLime, '', clYellow, false)
    else
      GradientFigure(dc, gfEllipse, Bounds(aLeft, aTop, LedSize, LedSize),
        clRed, '', clYellow, false)
  finally
    ReleaseDC(aHandle, dc);
  end;
end;

(*Красно-зеленая 3D лампочка с диаметром 15*)
procedure SimpleLED_old(aCanvas: TCanvas; aTop, aLeft: integer; IsOn: boolean);
var
  cnt: integer;
  pnClr, brClr: TColor;
  pnStyle: TPenStyle;
  pnWdt: integer;
begin
  pnClr := aCanvas.Pen.Color;
  pnStyle := aCanvas.Pen.Style;
  pnWdt := aCanvas.Pen.Width;
  brClr := aCanvas.Brush.Color;
  aCanvas.Pen.Color := clBlack;
  aCanvas.Pen.Color := clGray;
  aCanvas.Pen.Style := psSolid;
  aCanvas.Pen.Width := 1;
  Ellipse(aCanvas.Handle, aLeft, aTop, aLeft + 17, aTop + 17);
  if IsOn then
  begin
    for cnt := 0 to 8 do
    begin
      aCanvas.Brush.Color := RGB(0, 128 + cnt * 15, 0);
      aCanvas.Pen.Color := aCanvas.Brush.Color;
      Ellipse(aCanvas.Handle, aLeft + 1 + cnt, aTop +(cnt + 1),
        aLeft +(15 - cnt div 3)+ 1, aTop +(15 - cnt div 3)+ 1);
    end;
  end
  else
  begin
    for cnt := 0 to 8 do
    begin
      aCanvas.Brush.Color := RGB(128 + cnt * 15, 0, 0);
      aCanvas.Pen.Color := aCanvas.Brush.Color;
      Ellipse(aCanvas.Handle, aLeft + 1 + cnt, aTop +(cnt + 1),
        aLeft +(15 - cnt div 3)+ 1, aTop +(15 - cnt div 3)+ 1);
    end;
  end;
  aCanvas.Pen.Color := pnClr;
  aCanvas.Pen.Style := pnStyle;
  aCanvas.Pen.Width := pnWdt;
  aCanvas.Brush.Color := brClr;
end;

procedure SimpleLED_old(aHandle: HWND; aTop, aLeft: integer; IsOn: boolean);
var
  cnt: integer;
  clr: TColor;
  dc: hDC;
  br: hBrush;
  pn: hPen;
  obr: hBrush;
  opn: hPen;
begin
  dc := GetWindowDC(aHandle);
  pn := CreatePen(PS_SOLID, 1, clBlack);
  br := CreateSolidBrush(clBlack);
  SelectObject(dc, pn);
  SelectObject(dc, br);
  try
    Ellipse(dc, aLeft, aTop, aLeft + 17, aTop + 17);
    if IsOn then
    begin
      for cnt := 0 to 8 do
      begin
        clr := RGB(0, 128 + cnt * 15, 0);
        br := CreateSolidBrush(clr);
        pn := CreatePen(PS_SOLID, 1, clr);
        opn := SelectObject(dc, pn);
        DeleteObject(opn);
        obr := SelectObject(dc, br);
        DeleteObject(obr);
        Ellipse(dc, aLeft + 1 + cnt, aTop +(cnt + 1), aLeft +(15 - cnt div 3)+
          1, aTop +(15 - cnt div 3)+ 1);
      end;
    end
    else
    begin
      for cnt := 0 to 8 do
      begin
        clr := RGB(128 + cnt * 15, 0, 0);
        br := CreateSolidBrush(clr);
        pn := CreatePen(PS_SOLID, 1, clr);
        opn := SelectObject(dc, pn);
        DeleteObject(opn);
        obr := SelectObject(dc, br);
        DeleteObject(obr);
        Ellipse(dc, aLeft + 1 + cnt, aTop +(cnt + 1), aLeft +(15 - cnt div 3)+
          1, aTop +(15 - cnt div 3)+ 1);
      end;
    end;
  finally
    ReleaseDC(aHandle, dc);
    DeleteObject(pn);
    DeleteObject(br);
  end;
end;

procedure RedLED(const aCanvas: TCanvas; rct: TRect; Diameter: integer);
var
  cnt: integer;
  pnClr, brClr: TColor;
  pnStyle: TPenStyle;
  pnWdt: integer;
  deltaClr: Single;
  deltaClrRes: integer;
  forVal: integer;
begin
  pnClr := aCanvas.Pen.Color;
  pnStyle := aCanvas.Pen.Style;
  pnWdt := aCanvas.Pen.Width;
  brClr := aCanvas.Brush.Color;
  aCanvas.Pen.Color := clBlack;
  aCanvas.Brush.Color := clGray;
  aCanvas.Pen.Style := psSolid;
  aCanvas.Pen.Width := 1;
  Ellipse(aCanvas.Handle, rct.Left, rct.Top, rct.Right, rct.Bottom);
  //deltaClr:=(255-(127 / Diameter)) / Diameter;
  deltaClr :=(255 / Diameter);
  forVal := Diameter div 2;
  for cnt := 0 to forVal do
  begin
    deltaClrRes := Round(cnt * deltaClr);
    if deltaClrRes > 127 then
      deltaClrRes := 127;
    aCanvas.Brush.Color := RGB(Byte(128 + deltaClrRes), 0, 0);
    aCanvas.Pen.Color := aCanvas.Brush.Color;
    Ellipse(aCanvas.Handle, rct.Left + cnt, rct.Top +(cnt),
      rct.Left +((Diameter - 1)- cnt div 3),
      rct.Top +((Diameter - 1)- cnt div 3));
  end;
  aCanvas.Pen.Color := pnClr;
  aCanvas.Pen.Style := pnStyle;
  aCanvas.Pen.Width := pnWdt;
  aCanvas.Brush.Color := brClr;
end;

procedure RedLED2(const aCanvas: TCanvas; rct: TRect);
var
  w, H: integer;
  diam: integer;
begin
  w := Abs(rct.Right - rct.Left);
  H := Abs(rct.Bottom - rct.Top);
  if w > H then
    diam := H
  else
    diam := w;
  RedLED(aCanvas, rct, diam);
end;

(*Зеленая 3D лампочка*)
procedure GreenLED(aCanvas: TCanvas; rct: TRect; Diameter: integer);
var
  cnt: integer;
  pnClr, brClr: TColor;
  pnStyle: TPenStyle;
  pnWdt: integer;
  deltaClr: Single;
  deltaClrRes: integer;
  forVal: integer;
begin
  pnClr := aCanvas.Pen.Color;
  pnStyle := aCanvas.Pen.Style;
  pnWdt := aCanvas.Pen.Width;
  brClr := aCanvas.Brush.Color;
  aCanvas.Pen.Color := clBlack;
  aCanvas.Brush.Color := clGray;
  aCanvas.Pen.Style := psSolid;
  aCanvas.Pen.Width := 1;
  Ellipse(aCanvas.Handle, rct.Left, rct.Top, rct.Right, rct.Bottom);
  //deltaClr:=(255-(127 / Diameter)) / Diameter;
  deltaClr := 255 / Diameter;
  forVal := Diameter div 2;
  for cnt := 0 to forVal do
  begin
    deltaClrRes := Round(cnt * deltaClr);
    if deltaClrRes > 127 then
      deltaClrRes := 127;
    aCanvas.Brush.Color := RGB(0, 128 + deltaClrRes, 0);
    aCanvas.Pen.Color := aCanvas.Brush.Color;
    Ellipse(aCanvas.Handle, rct.Left + cnt, rct.Top +(cnt),
      rct.Left +((Diameter - 1)- cnt div 3),
      rct.Top +((Diameter - 1)- cnt div 3));
  end;
  aCanvas.Pen.Color := pnClr;
  aCanvas.Pen.Style := pnStyle;
  aCanvas.Pen.Width := pnWdt;
  aCanvas.Brush.Color := brClr;
end;

procedure GreenLED2(const aCanvas: TCanvas; rct: TRect);
var
  w, H: integer;
  diam: integer;
begin
  w := Abs(rct.Right - rct.Left);
  H := Abs(rct.Bottom - rct.Top);
  if w > H then
    diam := H
  else
    diam := w;
  GreenLED(aCanvas, rct, diam);
end;

(*Синяя 3D лампочка*)
procedure BlueLED(aCanvas: TCanvas; rct: TRect; Diameter: integer);
var
  cnt: integer;
  pnClr, brClr: TColor;
  pnStyle: TPenStyle;
  pnWdt: integer;
  deltaClr: Single;
  deltaClrRes: integer;
  forVal: integer;
begin
  pnClr := aCanvas.Pen.Color;
  pnStyle := aCanvas.Pen.Style;
  pnWdt := aCanvas.Pen.Width;
  brClr := aCanvas.Brush.Color;
  aCanvas.Pen.Color := clBlack;
  aCanvas.Brush.Color := clGray;
  aCanvas.Pen.Style := psSolid;
  aCanvas.Pen.Width := 1;
  Ellipse(aCanvas.Handle, rct.Left, rct.Top, rct.Left + Diameter,
    rct.Top + Diameter);//rct.Right,rct.Bottom);
  //deltaClr:=(255-(127 / Diameter)) / Diameter;
  deltaClr := 255 / Diameter;
  forVal := Diameter div 2;
  for cnt := 0 to forVal do
  begin
    deltaClrRes := Round(cnt * deltaClr);
    if deltaClrRes > 127 then
      deltaClrRes := 127;
    aCanvas.Brush.Color := RGB(0, 0, 128 + deltaClrRes);
    aCanvas.Pen.Color := aCanvas.Brush.Color;
    Ellipse(aCanvas.Handle, rct.Left + cnt, rct.Top +(cnt),
      rct.Left +((Diameter - 1)- cnt div 3),
      rct.Top +((Diameter - 1)- cnt div 3));
  end;
  aCanvas.Pen.Color := pnClr;
  aCanvas.Pen.Style := pnStyle;
  aCanvas.Pen.Width := pnWdt;
  aCanvas.Brush.Color := brClr;
end;

procedure BlueLED2(aCanvas: TCanvas; rct: TRect);
var
  w, H: integer;
  diam: integer;
begin
  w := Abs(rct.Right - rct.Left);
  H := Abs(rct.Bottom - rct.Top);
  if w > H then
    diam := H
  else
    diam := w;
  BlueLED(aCanvas, rct, diam);
end;

(*Желтая 3D лампочка*)
procedure YellowLED(aCanvas: TCanvas; rct: TRect; Diameter: integer);
var
  cnt: integer;
  pnClr, brClr: TColor;
  pnStyle: TPenStyle;
  pnWdt: integer;
  deltaClr: Single;
  deltaClrRes: integer;
  forVal: integer;
begin
  pnClr := aCanvas.Pen.Color;
  pnStyle := aCanvas.Pen.Style;
  pnWdt := aCanvas.Pen.Width;
  brClr := aCanvas.Brush.Color;
  aCanvas.Pen.Color := clBlack;
  aCanvas.Brush.Color := clGray;
  aCanvas.Pen.Style := psSolid;
  aCanvas.Pen.Width := 1;
  Ellipse(aCanvas.Handle, rct.Left, rct.Top, rct.Right, rct.Bottom);
  //deltaClr:=(255-(127 / Diameter)) / Diameter;
  deltaClr := 255 / Diameter;
  forVal := Diameter div 2;
  for cnt := 0 to forVal do
  begin
    deltaClrRes := Round(cnt * deltaClr)+ 128;
    if deltaClrRes > 255 then
      deltaClrRes := 255;
    aCanvas.Brush.Color := RGB(deltaClrRes, deltaClrRes, 0);
    aCanvas.Pen.Color := aCanvas.Brush.Color;
    Ellipse(aCanvas.Handle, rct.Left + cnt, rct.Top +(cnt),
      rct.Left +((Diameter - 1)- cnt div 3),
      rct.Top +((Diameter - 1)- cnt div 3));
  end;
  aCanvas.Pen.Color := pnClr;
  aCanvas.Pen.Style := pnStyle;
  aCanvas.Pen.Width := pnWdt;
  aCanvas.Brush.Color := brClr;
end;

procedure YellowLED2(aCanvas: TCanvas; rct: TRect);
var
  w, H: integer;
  diam: integer;
begin
  w := Abs(rct.Right - rct.Left);
  H := Abs(rct.Bottom - rct.Top);
  if w > H then
    diam := H
  else
    diam := w;
  YellowLED(aCanvas, rct, diam);
end;

(*Серая 3D лампочка*)
procedure GrayLED(const aCanvas: TCanvas; aRect: TRect);
var
  cnt: integer;
  pnClr: TColor;
  brClr: TColor;
  pnStyle: TPenStyle;
  pnWdt: integer;
  deltaClr: Single;
  deltaClrRes: integer;
  forVal: integer;
  Diameter: integer;
begin
  Diameter := Abs(aRect.Right - aRect.Left);
  cnt := Abs(aRect.Bottom - aRect.Top);
  if cnt < Diameter then
    Diameter := cnt;
  pnClr := aCanvas.Pen.Color;
  pnStyle := aCanvas.Pen.Style;
  pnWdt := aCanvas.Pen.Width;
  brClr := aCanvas.Brush.Color;
  aCanvas.Pen.Color := clBlack;
  aCanvas.Brush.Color := clGray;
  aCanvas.Pen.Style := psSolid;
  aCanvas.Pen.Width := 1;
  try
    Ellipse(aCanvas.Handle, aRect.Left, aRect.Top, aRect.Right, aRect.Bottom);
    //deltaClr:=(255-(127 / Diameter )) / Diameter;
    deltaClr := 255 / Diameter;
    //deltaClr:=(255-127) / (Diameter / 2);
    forVal := Diameter div 2;
    for cnt := 0 to forVal do
    begin
      deltaClrRes := Round(cnt * deltaClr)+ 128;
      if deltaClrRes > 255 then
        deltaClrRes := 255;
      aCanvas.Brush.Color := RGB(deltaClrRes, deltaClrRes, deltaClrRes);
      aCanvas.Pen.Color := aCanvas.Brush.Color;
      Ellipse(aCanvas.Handle, aRect.Left + cnt, aRect.Top +(cnt),
        aRect.Left +((Diameter - 1)- cnt div 3),
        aRect.Top +((Diameter - 1)- cnt div 3));
    end;
  finally
    aCanvas.Pen.Color := pnClr;
    aCanvas.Pen.Style := pnStyle;
    aCanvas.Pen.Width := pnWdt;
    aCanvas.Brush.Color := brClr;
  end;
end;

procedure GrayLED2(const aCanvas: TCanvas; aRect: TRect);
begin
  GrayLED(aCanvas, aRect);
end;

procedure LED(const aCanvas: TCanvas; aRect: TRect; aDark, aLight: TColor);
var
  w, H: integer;
  diam: integer;
  rad: integer;
  dltR: Single;
  dltG: Single;
  dltB: Single;
  fromR: Byte;//short
  fromG: Byte;
  fromB: Byte;
  toR: Byte;//short
  toG: Byte;
  toB: Byte;

  curR: smallint;//short
  curG: smallint;
  curB: smallint;

  cnt: integer;

  dltX: Single;
  dltY: Single;

  rct: TRect;

  prPen: TColor;
  prBr : TColor;

begin
prPen:= aCanvas.Pen.Color;
prBr:=aCanvas.Brush.Color;
try

  w := Abs(aRect.Right - aRect.Left);
  H := Abs(aRect.Bottom - aRect.Top);
  if w > H then
    diam := H
  else
    diam := w;
  rad := Round(diam / 2);
  fromR := GetRvalue(aDark);
  fromG := GetGvalue(aDark);
  fromB := GetBvalue(aDark);
  toR := GetRvalue(aLight);
  toG := GetGvalue(aLight);
  toB := GetBvalue(aLight);

  dltR :=(toR - fromR)/ rad;
  dltG :=(toG - fromG)/ rad;
  dltB :=(toB - fromB)/ rad;

  dltX :=(w / 2)/ rad;
  dltY :=(H / 2)/ rad;
  if dltY <> dltX then;

  for cnt := 0 to rad do
  begin
    curR := Round(cnt * dltR)+ fromR;
    curG := Round(cnt * dltG)+ fromG;
    curB := Round(cnt * dltB)+ fromB;
    aCanvas.Brush.Color := RGB(curR, curG, curB);
    aCanvas.Pen.Color := aCanvas.Brush.Color;
    //ROUND : //Ellipse(aCanvas.Handle,aRect.Left+cnt,aRect.Top+(cnt),aRect.Left+((diam-1)-cnt div 3),aRect.Top+((diam-1)-cnt div 3));
    rct := Rect(aRect.Left + Round(cnt * dltX), aRect.Top + Round(cnt * dltY),
      aRect.Right - Round(cnt * dltX), aRect.Bottom - Round(cnt * dltY));
    aCanvas.Ellipse(rct);
  end;
finally
aCanvas.Pen.Color:=prPen;
aCanvas.Brush.Color:=prBr;
end;
end;



(*Отображение точки с Alpha - каналом*)
{$R-}
procedure AlphaBlendPixel(Canvas: TCanvas; X, Y: integer; R, G, B: Byte;
  ARatio: Real);
Var
  LBack, LNew: TRGBTriple;
  LMinusRatio: Real;
  clr: TColor;
  rct: TRect;
begin
  rct := Canvas.ClipRect;
  if(rct.Right <= X)or(X < 0)or(rct.Bottom <= Y)or(Y < 0)then
    Exit;
  clr := Canvas.Pixels[X, Y];
  LBack.rgbtRed := GetRvalue(clr);
  LBack.rgbtBlue := GetBvalue(clr);
  LBack.rgbtGreen := GetGvalue(clr);
  LMinusRatio := 1 - ARatio;
  LNew.rgbtBlue := Round(B * ARatio + LBack.rgbtBlue * LMinusRatio);
  LNew.rgbtGreen := Round(G * ARatio + LBack.rgbtGreen * LMinusRatio);
  LNew.rgbtRed := Round(R * ARatio + LBack.rgbtRed * LMinusRatio);
  Canvas.Pixels[X, Y]:= RGB(LNew.rgbtRed, LNew.rgbtGreen, LNew.rgbtBlue);
end;
{$R+}

function AddPoint(Pt  :TPoint; var Pts : TPointDynArray) : integer;
begin
Result:=Length(Pts);
SetLength(Pts, Result+1);
System.Move(Pt, Pts[Result], SizeOf(TPoint));
end;

procedure GetMinMaxX(const pts : array of TPoint; var MinX, MaxX : integer);
var
 cnt : integer;
begin
MinX:=MAX_INTEGER;
MaxX:=MIN_INTEGER;
for cnt:=0 to High(pts)
  do begin
  if MinX>pts[cnt].X
     then MinX:=pts[cnt].X;
  if MaxX<pts[cnt].X
     then MaxX:=pts[cnt].X;
  end
end;

procedure GetMinMaxY(const pts : array of TPoint; var MinY, MaxY : integer);
var
 cnt : integer;
begin
MinY:=MAX_INTEGER;
MaxY:=MIN_INTEGER;
for cnt:=0 to High(pts)
  do begin
  if MinY>pts[cnt].Y
     then MinY:=pts[cnt].Y;
  if MaxY<pts[cnt].Y
     then MaxY:=pts[cnt].Y;
  end
end;

procedure WuLine(Canvas: TCanvas; Point1, Point2: TPoint; aColor: TColor);
var
  deltax, deltay, loop, start, finish: integer;
  dx, dy, dydx: Single;//fractional parts
  LR, LG, LB: Byte;
  x1, x2, y1, y2: integer;
begin
  x1 := Point1.X;
  y1 := Point1.Y;
  x2 := Point2.X;
  y2 := Point2.Y;
  deltax := Abs(x2 - x1);//Calculate deltax and deltay for initialisation
  deltay := Abs(y2 - y1);
  if(deltax = 0)or(deltay = 0)//straight lines
  then
  begin
    Canvas.Pen.Color := aColor;
    Canvas.MoveTo(x1, y1);
    Canvas.LineTo(x2, y2);
    Exit;
  end;
  LR :=(aColor and $000000FF);
  LG :=(aColor and $0000FF00)shr 8;
  LB :=(aColor and $00FF0000)shr 16;
  if deltax > deltay then
  begin//horizontal or vertical
    if y2 > y1//determine rise and run
    then
      dydx :=-(deltay / deltax)
    else
      dydx := deltay / deltax;
    if x2 < x1 then
    begin
      start := x2;//right to left
      finish := x1;
      dy := y2;
    end
    else
    begin
      start := x1;//left to right
      finish := x2;
      dy := y1;
      dydx :=-dydx;//inverse slope
    end;
    for loop := start to finish do
    begin
      AlphaBlendPixel(Canvas, loop, trunc(dy), LR, LG, LB, 1 - frac(dy));
      AlphaBlendPixel(Canvas, loop, trunc(dy)+ 1, LR, LG, LB, frac(dy));
      dy := dy + dydx;//next point
    end;
  end
  else
  begin
    if x2 > x1//determine rise and run
    then
      dydx :=-(deltax / deltay)
    else
      dydx := deltax / deltay;
    if y2 < y1 then
    begin
      start := y2;//right to left
      finish := y1;
      dx := x2;
    end
    else
    begin
      start := y1;//left to right
      finish := y2;
      dx := x1;
      dydx :=-dydx;//inverse slope
    end;
    for loop := start to finish do
    begin
      AlphaBlendPixel(Canvas, trunc(dx), loop, LR, LG, LB, 1 - frac(dx));
      AlphaBlendPixel(Canvas, trunc(dx)+ 1, loop, LR, LG, LB, frac(dx));
      dx := dx + dydx;//next point
    end;
  end;
end;

 procedure DrawWrongLine(aDC : hDC; aPt : TPoint; aLength : integer; aColor : TColor);
 const
  Hgt : integer = 2;
 var
  lb : TLogBrush;
  ob : hBrush;
  op : hPen;
  pts: array of TPoint;
  sz : integer;
  ind : integer;
 begin
 lb.lbStyle:=BS_HOLLOW;
 ob:=SelectObject(aDC,CreateBrushIndirect(lb));
 op:=SelectObject(aDC,CreatePen(PS_SOLID, 1, aColor));
 try
 SetLength(pts,1);
 sz:=SizeOf(TPoint);
 System.Move(aPt,pts[0],sz);
 while pts[High(pts)].X - pts[Low(pts)].X < aLength
   do begin
   ind:=Length(pts);
   SetLength(pts,ind+1);
   if pts[ind-1].Y=aPt.Y
      then pts[ind].Y:=aPt.Y+Hgt
      else pts[ind].Y:=aPt.Y;
   pts[ind].X:=pts[ind-1].X+Hgt;
   end;
  PolyLine(aDC,pts[0],Length(pts));
 finally
 Setlength(pts,0);
 DeleteObject(SelectObject(aDC,op));
 DeleteObject(SelectObject(aDC,ob));
 end;
 end;

 procedure DrawWrongLineSin(aDC : hDC; aPt : TPoint; aLength : integer; aColor : TColor);
 const
  Hgt : integer = 3;
 var
  lb    : TLogBrush;
  ob    : hBrush;
  op    : hPen;
  pts   : array of TPoint;
  ind   : integer;
  cnt   : integer;
  koefX : double;
  koefY : double;
 begin
 lb.lbStyle:=BS_HOLLOW;
 ob:=SelectObject(aDC,CreateBrushIndirect(lb));
 op:=SelectObject(aDC,CreatePen(PS_SOLID, 1, aColor));
 try
 koefX:=2;//Round(Hgt / 2);
 koefY:=1.5;
 for cnt:=0 to 1000
 //while pts[High(pts)].X - pts[Low(pts)].X < aLength
   do begin
   ind:=Length(pts);
   SetLength(pts,ind+1);
   pts[ind]:=Point(aPt.X+Round(cnt*koefX), aPt.Y+Round(sin(cnt / koefY * pi) * koefY) + Hgt);
   if pts[ind].X>aPt.X+aLength then Break;
   end;
 PolyLine(aDC,pts[0],Length(pts));
 finally
 Setlength(pts,0);
 DeleteObject(SelectObject(aDC,op));
 DeleteObject(SelectObject(aDC,ob));
 end;
 end;


 procedure Circle(aDC : hDC; aPtCenter : TPoint ; aRadius : integer);
 var
  rct : TRect;
 begin
 with aPtCenter do rct:=Rect(X-aRadius, Y-aRadius, X+aRadius, Y+aRadius );
 with rct do Ellipse(aDC,Left,Top,Right,Bottom);
 end;

 procedure DrawWavyLine(aDC : hDC; aPtA, aPtB : TPoint; aWidth : byte; aColor : TColor);
 const
   needBezie = false;
 var
  lb      : TLogBrush;
  ob      : hBrush;
  op      : hPen;
  halfH   : integer;
  quartH  : integer;
  ang     : double;   // -- angle of main direction
  qrt     : byte;
  ptA1    : TPoint;
  ptA2    : TPoint;
  lenLine : integer;  // -- common length of line in main direction
  lenCur  : integer;  // -- current length of line in main direction in calculation
  pts     : array of TPoint;
  ind     : integer;
 begin
 lb.lbStyle:=BS_HOLLOW;
 ob:=SelectObject(aDC,CreateBrushIndirect(lb));
 op:=SelectObject(aDC,CreatePen(PS_SOLID, 1, aColor));
 try
 //-- debug -- main direction line
 //-- debug -- MoveToEx(aDC, aPtA.X, aPtA.Y, nil);
 //-- debug -- LineTo(aDC, aPtB.X, aPtB.Y);
 halfH :=Round(aWidth / 2);         // -- distance for left/right from main direction
 //quartH:=Round(aWidth / 4);         // -- distance on main direct
 quartH:=halfH;                       // it better (more beautiful)
 ang:=GetAngle(aPtA, aPtB, qrt);
 GetPoint(aPtA,ang,halfH,ptA1);     // -- right(left) line from main direcrtion
 GetPoint(aPtA,ang+180,halfH,ptA2); // -- left(right) line from main direcrtion
 lenLine:=Round(GetDistance(aPtA, aPtB));
 lenCur:=0;
 inc(lenCur,quartH);
 SetLength(pts,1);
 System.Move(aPtA,pts[0],SizeOf(TPoint));
 while lenCur<lenLine
   do begin
   // -- calc center
   ind:=Length(pts);
   SetLength(pts,ind+1);
   GetPoint(aPtA,ang+90,lenCur,pts[ind]);
   inc(lenCur,quartH);
   if not needBezie and (lenCur>=lenLine) then Break;
   // -- calc left(right)
   ind:=Length(pts);
   SetLength(pts,ind+1);
   GetPoint(PtA1,ang+90,lenCur,pts[ind]);
   inc(lenCur,quartH);
   if  not needBezie and (lenCur>=lenLine) then Break;
   // -- calc right(left)
   ind:=Length(pts);
   SetLength(pts,ind+1);
   GetPoint(PtA2,ang+90,lenCur,pts[ind]);
   inc(lenCur,quartH);
   if  not needBezie and (lenCur>=lenLine) then Break;
   // надо вычислять именно 3 точки (центр, выше, ниже), иначе некрасиво получается....
   end;
   //-- debug -- DeleteObject(SelectObject(aDC, CreatePen(PS_SOLID,1,clRed)));
   ind:=Length(pts);
    if not needBezie
       then PolyLine(aDC,pts[0],ind)
       else PolyBezier(aDC,pts[0],ind);
 finally
 SetLength(pts,0);
 DeleteObject(SelectObject(aDC,op));
 DeleteObject(SelectObject(aDC,ob));
 end;
end;




procedure EllipseExt(aDC : hDC; aPtA, aPtB : TPoint; aWidth : byte; aColor : TColor);

  function MakeOffsetTransform(dx, dy: Extended): XFORM;
  begin
    Result.eM11 := 1;
    Result.eM12 := 0;
    Result.eM21 := 0;
    Result.eM22 := 1;
    Result.eDx := dx;
    Result.eDy := dy;
  end;

  function MakeRotateTransform(Angle: Extended): XFORM;
  begin
    Result.eM11 := Cos(Angle);
    Result.eM12 := Sin(Angle);
    Result.eM21 := -Sin(Angle);
    Result.eM22 := Cos(Angle);
    Result.eDx := 0;
    Result.eDy := 0;
  end;

var
  lb      : TLogBrush;
  ob      : hBrush;
  op      : hPen;
  ang     : double;   // -- angle of main direction
  qrt     : byte;
  dist    : extended;
  ptCenter : TPoint;
  ptRad    : TPoint;
  rct   : TRect;
begin
 lb.lbStyle:=BS_HOLLOW;
 ob:=SelectObject(aDC,CreateBrushIndirect(lb));
 op:=SelectObject(aDC,CreatePen(PS_SOLID, 1, aColor));
 try
 ang:=GetAngle(aPtA, aPtB, qrt);
 dist:=GetDistance(aPtA, aPtB);
 GetPoint(aPtA, ang+90, dist/2 ,ptCenter) ;
// GetPoint(ptCenter,ang,IfThen(aWidth<>0,aWidth/2,dist/10),PtL1);
// GetPoint(ptCenter,ang+180,IfThen(aWidth<>0,aWidth/2,dist/10),PtL2);
//    Circle(aDC, PtL1 ,5);
//    Circle(aDC, PtL2 ,5);
 rct:=Bounds(0,0,Round(dist),aWidth);
 ptRad:=Point( ptCenter.X - (rct.Right-rct.Left) div 2, ptCenter.Y - (rct.Bottom-rct.Top) div 2);
 OffsetRect(rct,ptRad.X, ptRad.Y);
//    Rectangle(aDC,rct.Left,rct.Top, rct.Right,rct.Bottom );
//    DrawLine(aDC,Point(rct.Left,rct.Top), Point(rct.Right,rct.Bottom));
//    DrawLine(aDC,Point(rct.Right,rct.Top), Point(rct.Left,rct.Bottom));
    SetGraphicsMode(aDC, GM_ADVANCED);
    SetWorldTransform(aDC, MakeOffsetTransform(ptCenter.X, ptCenter.Y));
    ang:=GetAngleRad(aPtA, aPtB);
    if qrt in [1,3] then ang:=Pi-ang;
    ModifyWorldTransform(aDC, MakeRotateTransform(ang) , MWT_LEFTMULTIPLY);//
    ModifyWorldTransform(aDC, MakeOffsetTransform(-ptCenter.X, -ptCenter.Y), MWT_LEFTMULTIPLY);
//    Rectangle(aDC, rct.Left,rct.Top, rct.Right,rct.Bottom);
//    DrawLine(aDC,Point(rct.Left,rct.Top), Point(rct.Right,rct.Bottom));
//    DrawLine(aDC,Point(rct.Right,rct.Top), Point(rct.Left,rct.Bottom));
    Ellipse(aDC, rct.Left,rct.Top, rct.Right,rct.Bottom);
    SetWorldTransform(aDC, MakeOffsetTransform(0, 0));
    ModifyWorldTransform(aDC, MakeRotateTransform(0) , MWT_LEFTMULTIPLY);//
//    rct:=Rect(0,0,400,20);
//    DrawTransparentText(aDC,Format('%d, %f', [qrt, ang]),rct,DT_LEFT or DT_TOP);
//    rct:=Rect(0,0,400,40);
//    DrawTransparentText(aDC,Format('%f(%f), %f(%f), %f(%f)', [Pi,RadToDeg(Pi), Pi/2,RadToDeg(Pi/2), Pi/4,RadToDeg(Pi/4)]),rct,DT_LEFT or DT_BOTTOM or DT_SINGLELINE);
 finally
 DeleteObject(SelectObject(aDC,op));
 DeleteObject(SelectObject(aDC,ob));
 end;
end;




 procedure SinusLine(aDC : hDC; aPtA, aPtB : TPoint; aWidth : byte; aColor : TColor; FirstUp : boolean);
 type
  TDrawMode = (dmTest,dmHord, dmBezie, dmHalfCircle);

 const
  mult : integer    =      4;
  Krnd : extended   =    0.5;  // -- с таким округлителем лучше
  mode : TDrawMode  = dmHord;
 var
  lb      : TLogBrush;
  ob      : hBrush;
  op      : hPen;
  ang     : double;   // -- angle of main direction
  qrt     : byte;
  dist    : extended;

  ptCenter : TPoint;

  ptL1      : TPoint;  // -- точки на линии , как правило на 1/4 от крайних точек
  ptL1c     : TPoint;  // -- ... центр
  ptL1a     : TPoint;  // -- ... антогонист безиндексной
  ptRad     : TPoint;  // -- центральная точка окружности, для которой отрезок основной линии является хордой
  ptL2      : TPoint;  // -- точки на линии , как правило на 1/4 от крайних точек
  ptL2c     : TPoint;  // -- ... центр
  ptL2a     : TPoint;  // -- ... антогонист безиндексной
  pts       : array of TPoint; // -- набор точек для тображения кривой Безье
  ind       : integer; // -- размерность набора точек
//  ptCheck   : TPoint;  // -- выи

  x1,x2     : integer;
  y1,y2     : integer;

  rad : extended;

  L : extended;
  h : extended;
 // rct : TRect;

 begin
 lb.lbStyle:=BS_HOLLOW;
 ob:=SelectObject(aDC,CreateBrushIndirect(lb));
 op:=SelectObject(aDC,CreatePen(PS_SOLID, 1, aColor));
 //op:=SelectObject(aDC,CreatePen(PS_SOLID, 1, clNavy));
 try
 ang:=GetAngle(aPtA, aPtB, qrt);
 dist:=GetDistance(aPtA, aPtB);
 GetPoint(aPtA, ang+90, dist/2 ,ptCenter) ;
 GetPoint(aPtA, ang+90, dist/4   ,PtL1c) ;
 GetPoint(aPtA, ang+90, dist/4*3 ,PtL2c) ;


// DeleteObject(SelectObject(aDC,CreatePen(PS_SOLID, 1, clRed)));
// DrawLine(aDC,aPtA,ptCenter) ;
// Circle(aDC, aPtA,10);
//
// DeleteObject(SelectObject(aDC,CreatePen(PS_SOLID, 1, clGreen)));
// Circle(aDC, ptCenter,10);
//
// DeleteObject(SelectObject(aDC,CreatePen(PS_SOLID, 1, clNavy)));
// DrawLine(aDC,aPtB,ptCenter) ;
// Circle(aDC, aPtB,10);
//
// DeleteObject(SelectObject(aDC,CreatePen(PS_SOLID, 1, aColor)));

 case mode of
 dmTest :
    begin
    EllipseExt(aDC, aPtA, aPtB, aWidth, aColor);
    end;
 dmHord :
    begin
    GetPoint(PtL1c, ang+180 , IfThen(aWidth<>0,aWidth,dist/10) ,ptRad);
    h:=GetDistance(ptRad,ptL1c);
    // -- mode 1 --------
    //L:=dist/4;
    //rad := ((L*L) / h + h ) / 2;
    // -- mode 2 --------
    L:=dist/2;
    rad:= (h/2) + Power(L,2) / (8*h);

    GetPoint(PtL1c,ang+180,rad-h, ptRad);
     with ptRad
      do begin
      x1:=Round(X-rad-Krnd);
      y1:=Round(Y-rad-Krnd);
      x2:=Round(X+rad+Krnd);
      y2:=Round(Y+rad+Krnd);
      end;
    Arc(aDC,x1, y1, x2, y2,ptCenter.X, ptCenter.Y, aPtA.X, aPtA.Y);
    //Circle(aDc,ptL1rad,5);

    GetPoint(PtL2c,ang-180,h-rad, ptRad);
     with ptRad
      do begin
      x1:=Round(X-rad-Krnd);
      y1:=Round(Y-rad-Krnd);
      x2:=Round(X+rad+Krnd);
      y2:=Round(Y+rad+Krnd);
      end;
    Arc(aDC,x1, y1, x2, y2,ptCenter.X, ptCenter.Y, aPtB.X, aPtB.Y);
    //Circle(aDc,ptL1rad,5);
  end;
  dmBezie :  // -- это кривая Безье ----------------------------------------------------------------
     begin
    if FirstUp
       then begin   // -- это для Bezie
       GetPoint(PtL1c, ang     , IfThen(aWidth<>0,aWidth,dist/10)*mult ,PtL1a);
       GetPoint(PtL1c, ang+180 , IfThen(aWidth<>0,aWidth,dist/10)*mult ,PtL1);
       GetPoint(PtL2c, ang+180 , IfThen(aWidth<>0,aWidth,dist/10)*mult ,PtL2a);
       GetPoint(PtL2c, ang     , IfThen(aWidth<>0,aWidth,dist/10)*mult ,PtL2);
       end
       else begin
       GetPoint(PtL1c, ang+180 , IfThen(aWidth<>0,aWidth,dist/10)*mult ,PtL1a);
       GetPoint(PtL1c, ang     , IfThen(aWidth<>0,aWidth,dist/10)*mult ,PtL1);
       GetPoint(PtL2c, ang     , IfThen(aWidth<>0,aWidth,dist/10)*mult ,PtL2a);
       GetPoint(PtL2c, ang+180 , IfThen(aWidth<>0,aWidth,dist/10)*mult ,PtL2);
       end;
//       Circle(aDC, PtL1,5);
//       Circle(aDC, PtL1a,5);
//       Circle(aDC, PtL1c,5);

    SetLength(pts,4);
    System.Move(aPtA,pts[0], SizeOf(TPoint));
    System.Move(PtL1,pts[1], SizeOf(TPoint));
    System.Move(PtL2,pts[2], SizeOf(TPoint));
    System.Move(aPtB,pts[3], SizeOf(TPoint));
    ind:=Length(pts);
    PolyBezier(aDC,pts[0],ind);
    end;
 dmHalfCircle :// -- это волна из двух дуг радиусом в 1\4 длинны линии -----------------------------
    begin
    rad:=dist/4;
     with ptL1c
      do begin
      x1:=X-Round(rad);
      y1:=Y-Round(rad);
      x2:=X+Round(rad);
      y2:=Y+Round(rad);
      end;
    if FirstUp
       then Arc(aDC,x1,y1,x2,y2,ptCenter.X,ptCenter.y,aPtA.X,aPtA.Y)
       else Arc(aDC,x1,y1,x2,y2,aPtA.X,aPtA.Y,ptCenter.X,ptCenter.y) ;

    with ptL2c
      do begin
      x1:=X-Round(rad);
      y1:=Y-Round(rad);
      x2:=X+Round(rad);
      y2:=Y+Round(rad);
      end;
    if FirstUp
       then Arc(aDC,x1,y1,x2,y2,ptCenter.X,ptCenter.y,aPtB.X,aPtB.Y)
       else Arc(aDC,x1,y1,x2,y2,aPtB.X,aPtB.Y,ptCenter.X,ptCenter.y);

    end;
 end;
 finally
 SetLength(pts,0);
 DeleteObject(SelectObject(aDC,op));
 DeleteObject(SelectObject(aDC,ob));
 end;
 end;
// ---

procedure DrawFlower(aDC : hDC; Center : TPoint; RadCommon, RadCenter : extended; Count : integer; clrPetal,clrCenter : TColor);
type
 TRay = record
  pt  : TPoint;
  dist: extended;
  ang : extended;
 end;


 var
  ob      : hBrush;
  op      : hPen;
  segment : extended;
  cnt     : integer;
  rays    : array of TRay;
  szp     : integer;
  rct     : TRect;
  dlt     : extended;
  pts     : array[0..3] of TPoint;
  ptclr   : TPointDynArray;
begin
szp:=SizeOf(TPoint);
SetLength(rays, Count);
segment:=RadToDeg((pi*2) / Count);// - ln*2 ;
rct:=Bounds(Center.X-Round(RadCommon),Center.Y-Round(RadCommon),Round(RadCommon),Round(RadCommon));
for cnt:=0 to High(rays)
  do begin
  rays[cnt].ang:=segment*cnt;
  rays[cnt].dist:=RadCommon;
  GetPoint(Center, rays[cnt].ang, rays[cnt].dist, rays[cnt].pt);
  end;
 FillRect(aDC,rct,CreateSolidBrush(Graphics.ColorToRGB(clWhite)));
 ob:=SelectObject(aDC,CreateSolidBrush(Graphics.ColorToRGB(clrCenter)));
 op:=SelectObject(aDC,CreatePen(PS_SOLID, 1, ColorToRGB(clrPetal)));
 try

 dlt:=10;
 SetLength(ptclr,0);
// -- отрисовка лепестков --------------------------------------------------------------------------
 for cnt:=0 to High(rays)
   do begin
   System.Move(Center, pts[0],szp);
   GetPoint(Center,rays[cnt].ang-dlt(*-Random(15)*),rays[cnt].dist*1.5, pts[1]);
   GetPoint(Center,rays[cnt].ang+dlt(*+Random(15)*),rays[cnt].dist*1.5, pts[2]);
   System.Move(Center, pts[3],szp);
   PolyBezier(aDC, pts[0], 4);
   AddPoint(GetPoint(Center,rays[cnt].ang,RadCenter+2),ptclr);
   end;


// -- открываем "доступ ко внутренним полостям" ----------------------------------------------------
 DeleteObject(SelectObject(aDC,CreateSolidBrush(Graphics.ColorToRGB(clrPetal))));
 DeleteObject(SelectObject(aDC,CreatePen(PS_SOLID, 1, Graphics.ColorToRGB(clrPetal))));
 Circle(aDC,Center,Round(RadCenter));
 for cnt:=0 to  High(ptclr)
   do with ptclr[cnt] do ExtFloodFill(aDC,X,Y,Graphics.ColorToRGB(clrPetal),FLOODFILLBORDER);

 DeleteObject(SelectObject(aDC,CreateSolidBrush(Graphics.ColorToRGB(clrCenter))));
 DeleteObject(SelectObject(aDC,CreatePen(PS_SOLID, 1, Graphics.ColorToRGB(clrPetal))));
 Circle(aDC,Center,Round(RadCenter));

 finally
 SetLength(rays,0);
 DeleteObject(SelectObject(aDC,op));
 DeleteObject(SelectObject(aDC,ob));
 end;
end;



// ---
procedure DrawBlot(aDC : hDC; Rct : TRect; aColor : TColor);
type
 TRay = record
  pt  : TPoint;
  dist: extended;
  ang : extended;
 end;


function GetRandomAngle(Index : integer; const r : array of TRay) : extended;
var
 cyc : integer;
 cnt : integer;
 ok  : boolean;
 dlt : extended;
begin
cyc:=0;
dlt:=30 / Length(r);
Result:=Random(361);
while cyc<100
  do begin
  Result:=Random(361);
  ok:=true;
  for cnt:=0 to Index
    do if (r[cnt].ang+dlt>=Result) or (r[cnt].ang+dlt<=Result)
          then begin
          ok:=false;
          Break;
          end;
  if ok then Break;
  inc(cyc);
  end;
end;

const
 maxDist = 200;
 direct : array[boolean] of integer = (-1, 1);
 minAngSpline : extended = 5;
 maxAngSpline : extended = 15;
 maxMid       : extended = 30;
 var
  lb      : TLogBrush;
  ob      : hBrush;
  op      : hPen;
  ln      : integer;
  segment : extended;
  cnt     : integer;
  Center  : TPoint;
  rays    : array of TRay;
  dltAng  : extended;
  dltDir  : boolean;
  ptsSpl  : TPointDynArray;
  pts     : array[0..3] of TPoint;
  szp     : integer;
  rad     : extended;
  nextind : integer;
  midang  : extended;
  dist    : extended;
  outpts  : array of array[0..1] of TPoint;
  highdist: extended;
begin
szp:=SizeOf(TPoint);
Randomize;
ln:=5+Random(7);
SetLength(rays, ln);
segment:=RadToDeg((pi*2) / ln);// - ln*2 ;
rad:=50;
highdist:=0;
Center:=Point(rct.left+(rct.right-rct.left) div 2,rct.top+(rct.bottom-rct.top) div 2);
for cnt:=0 to High(rays)
  do begin
  rays[cnt].ang:=segment*cnt;
  dltDir:=boolean(Random(2));
  dltAng:=segment / (3+Random(4));
  rays[cnt].ang:=rays[cnt].ang+direct[dltDir]*dltAng;
//  if rays[cnt].ang<0
//     then rays[cnt].ang:=GetRandomAngle(cnt,rays);
  rays[cnt].dist:=maxDist / 2 + Random(maxDist);
  GetPoint(Center, rays[cnt].ang, rays[cnt].dist, rays[cnt].pt);
  if highdist<rays[cnt].dist
     then highdist:=rays[cnt].dist;
  end;

 FillRect(aDC,rct,CreateSolidBrush(Graphics.ColorToRGB(clWhite)));
 lb.lbStyle:=BS_SOLID;
 lb.lbColor:=aColor;
 ob:=SelectObject(aDC,CreateBrushIndirect(lb));
 op:=SelectObject(aDC,CreatePen(PS_SOLID, 1, Graphics.ColorToRGB(aColor)));
 try



// -- отрисовка лепестков --------------------------------------------------------------------------
 for cnt:=0 to High(rays)
   do begin
   // -- это
   System.Move(Center, pts[0],szp);
////   GetPoint(Center,rays[cnt].ang-10(*-Random(15)*),rays[cnt].dist*1.5, pts[1]);
////   GetPoint(Center,rays[cnt].ang+10(*+Random(15)*),rays[cnt].dist*1.5, pts[2]);
   dist:=Random(Round((highdist - rays[cnt].dist) / 10));
   if dist<>0 then ;
   GetPoint(Center,rays[cnt].ang-10-dist,rays[cnt].dist*1.5, pts[1]);
   GetPoint(Center,rays[cnt].ang+10+dist,rays[cnt].dist*1.5, pts[2]);
   System.Move(Center, pts[3],szp);
   PolyBezier(aDC, pts[0], 4);
   Circle(aDC,GetPoint(rays[cnt].pt,rays[cnt].ang,-4),2);
   //with rays[cnt].pt
   //   do ExtFloodFill(aDC,X,Y,ColorToRGB(aColor),FLOODFILLBORDER);
   end;


// -- открываем "доступ ко внутренним полостям" ----------------------------------------------------
 DeleteObject(SelectObject(aDC,CreateSolidBrush(Graphics.ColorToRGB(clWhite))));
 DeleteObject(SelectObject(aDC,CreatePen(PS_SOLID, 1, Graphics.ColorToRGB(clWhite))));
 Circle(aDC,Center,Round(rad));
 DeleteObject(SelectObject(aDC,CreateSolidBrush(Graphics.ColorToRGB(aColor))));
 DeleteObject(SelectObject(aDC,CreatePen(PS_SOLID, 1, aColor)));

 SetLength(outpts,Length(rays));
 for cnt:=0 to High(rays)
   do begin
   if cnt<High(rays)
      then begin
      nextind:=cnt+1;
      midang:=(rays[nextind].ang-rays[cnt].ang) / 2;
      end
      else begin
      nextind:=0;
      midang:=(360 - rays[cnt].ang ) / 2;
      end;
   GetPoint(Center,rays[cnt].ang+minAngSpline,rad*IfThen(midang>maxMid,2.25,1.5), pts[0]);
   if GetDistance(Center,rays[cnt].pt)<=GetDistance(Center,pts[0])+15
   //   then System.Move(rays[cnt].pt, pts[0], szp);  //GetPoint(Center,rays[cnt].ang+minAngSpline,rad*1.4, pts[0]);
      then GetPoint(Center,rays[cnt].ang+2,rays[cnt].dist-4, pts[0]);
   GetPoint(Center,rays[cnt].ang+maxAngSpline,rad, pts[1]);
   GetPoint(Center,rays[nextind].ang-maxAngSpline,rad, pts[2]);
   GetPoint(Center,rays[nextind].ang-minAngSpline,rad*IfThen(midang>maxMid,2.25,1.5), pts[3]);
   if GetDistance(Center,rays[nextind].pt)<=GetDistance(Center,pts[3])+15
   //   then System.Move(rays[nextind].pt, pts[3], szp); //GetPoint(Center,rays[nextind].ang-minAngSpline,rad*1.4, pts[3]);
      then GetPoint(Center,rays[nextind].ang-2,rays[nextind].dist-4, pts[3]);
   dist:=GetDistance(pts[0],pts[3]);
   if Dist<20
      then begin
      GetPoint(Center,rays[cnt].ang+midang-2,rad*1.5, pts[1]);
      GetPoint(Center,rays[cnt].ang+midang+2,rad*1.5, pts[2]);
      end
      else
   if (dist>=20) and (dist<=30)
      then begin
      GetPoint(Center,rays[cnt].ang+midang-2,rad*1.4, pts[1]);
      GetPoint(Center,rays[cnt].ang+midang+2,rad*1.4, pts[2]);
      end;
   PolyBezier(aDC, pts[0], 4);

   // -- вывод отладочной информации --------------------------------------------------------------
   //rct:=Bounds(pts[0].X, pts[0].Y, 200,20);
   //DrawTransparentText(aDC,Format('%3.0f',[GetDistance(pts[0],pts[3])]),rct,DT_LEFT_ALIGN);
   //Circle(aDC, pts[0],3);
   //Circle(aDC, pts[3],3);
   //Circle(aDC, rays[cnt].pt,2);
   //DrawArrow(aDC,pts[0],pts[3],1,clRed);

   // -- соединительные точки внутренних переходов ------------------------------------------------
   System.Move(pts[0],outpts[cnt,1],szp);
   System.Move(pts[3],outpts[nextind,0],szp);
   if highdist<rays[cnt].dist
      then highdist:=rays[cnt].dist;
   end;

///ExtFloodFill(aDC,Center.X,Center.Y,ColorToRGB(aColor),FLOODFILLBORDER);
 finally
 SetLength(ptsSpl,0);
 SetLength(rays,0);
 DeleteObject(SelectObject(aDC,op));
 DeleteObject(SelectObject(aDC,ob));
 end;
end;


//   DeleteObject(SelectObject(aDC,CreatePen(PS_SOLID, 1, clRed)));
//   Circle(aDC, pts[0], 3);
//   rct:=Bounds(pts[0].X, pts[0].Y, 20,20);
//   DrawTransparentText(aDC,IntToStr(cnt),rct,DT_LEFT_ALIGN);
//   DeleteObject(SelectObject(aDC,CreatePen(PS_SOLID, 1, clGreen)));
//   Circle(aDC, pts[1], 3);
//   DeleteObject(SelectObject(aDC,CreatePen(PS_SOLID, 1, clBlue)));
//   Circle(aDC, pts[2], 3);
//   DeleteObject(SelectObject(aDC,CreatePen(PS_SOLID, 1, clFuchsia)));
//   Circle(aDC, pts[3], 3);
//   DeleteObject(SelectObject(aDC,CreatePen(PS_SOLID, 1, clBlack)));


procedure DrawArrow(aDC : hDC; aPtA, aPtB : TPoint; aWidth : byte; aColor : TColor);
const
 maxlen = 50;
var
 pn  : hPen;
 ang : extended;
 qrt : byte;
 ptC : TPoint;
 rad : single;//extended;
 dist : extended;
begin
//rad:=0;
try
pn := SelectObject(aDC, CreatePen(PS_SOLID,aWidth,Graphics.ColorToRGB(aColor)));
try
dist:=GetDistance(aPtA,aPtB);
// -- 01 --
//if dist<=maxlen
//   then rad:=dist * 0.4
//   else rad:=maxlen;

// -- 02 --
//if (dist>=0) and (dist<=50) then rad:=dist*0.5 else
//if (dist>50) and (dist<=200) then rad:=dist*0.25 else
//rad:=dist*0.15;

// -- 03 --
//rad:=dist * (40/(integer(dist<100)+1))/dist;

// -- 04.0 --
//rad:=dist * math.Log10(dist)/10;
// -- 04.1 --
//rad:=dist * math.Log2(dist)/30;
// -- 04.2 --
rad:=dist * math.LogN(11, dist)/10;

MoveToEx(aDC,aPtA.X, aPtA.Y,nil);
LineTo(aDC,aPtB.X, aPtB.Y);
ang:=GetAngle(aPtA,aPtB,qrt);
ang:=ang-80;
GetPoint(aPtB,ang,rad,ptC);
MoveToEx(aDC,aPtB.X, aPtB.Y,nil);
LineTo(aDC,ptC.X, ptC.Y);
ang:=ang-20;
GetPoint(aPtB,ang,rad,ptC);
MoveToEx(aDC,aPtB.X, aPtB.Y,nil);
LineTo(aDC,ptC.X, ptC.Y);
finally
DeleteObject(SelectObject(aDC,pn));
end;
except
 // * на запредельных значениях типа X=234543 и Y=-765422 возникает Invalid floating point operation
end;
end;

(*Инвертирование цвета (Возвращает контрастный цвет)*)
function InvertColor(Value: TColor): TColor;
var
 _rgb : TColorRef;
begin
_rgb:=Graphics.ColorToRGB(Value);
Result := RGB(255 - GetRvalue(_rgb), 255 - GetGvalue(_rgb),255 - GetBvalue(_rgb));
//  {-$R}
//  if Value =-1 then
//    Result := RGB(128, 128, 128)
//  else
//    Result := RGB(Abs(255 - GetRvalue(Value)), Abs(255 - GetGvalue(Value)),Abs(255 - GetBvalue(Value)));
//  {+$R}
end;


function ContrastColor(Value: TColor): TColor;
begin
Result:=ColorToGray(Value);
if (GetRValue(Result)+GetBValue(Result)+GetBValue(Result))/3 >128
   then Result:=clBlack
   else Result:=clWhite;
end;

procedure ChangeColor(aBMP: TBitmap; aSrcColor, aDestColor: TColor);
  procedure ColorToB3(aColor: TColor;var aB3: T3b);
  begin//BGR
    aB3[0]:= GetBvalue(aColor);
    aB3[1]:= GetGvalue(aColor);
    aB3[2]:= GetRvalue(aColor);
  end;

var
  i, j: integer;
  Src: T3b;
  Dest: T3b;
  f3b: P3b;
begin
  ColorToB3(aSrcColor, Src);
  ColorToB3(aDestColor, Dest);
  aBMP.PixelFormat := pf24bit;
  for i := 0 to aBMP.height - 1 do
  begin
    f3b := aBMP.ScanLine[i];//Получаем строку изображения
    for j := 0 to aBMP.Width - 1 do
    begin
      if(f3b^[0]= Src[0])and(f3b^[1]= Src[1])and(f3b^[2]= Src[2])then
        System.Move(Dest[0], f3b^[0], SizeOf(T3b));
      if(j < pred(aBMP.Width))then
        Inc(f3b);
    end;
  end;
end;

function StringToColorDef(const aStr:string; aDefColor: TColor): TColor;
var
  tmpStr:string;
begin
  if Trim(aStr)= '' then
  begin
    Result := aDefColor;
    Exit;
  end;
  try
    tmpStr := aStr;
    tmpStr := StringReplace(tmpStr, '#', '$',[]);
    Result := StringToColor(tmpStr);
  except
    Result := aDefColor;
  end;
end;

function RGBStrToColorDef(const aStr:string; aDefColor: TColor): TColor;
var
  tmpStr:string;
  R,G,B : byte;
begin
try
tmpStr:=aStr;
tmpStr:=StringReplace(tmpStr, '#', '$',[]);
tmpStr:=Copy(tmpStr+'FFFFFF',1,6);
R:=StrToInt('$'+Copy(tmpStr,1,2));
G:=StrToInt('$'+Copy(tmpStr,3,2));
B:=StrToInt('$'+Copy(tmpStr,5,2));
Result:=TColor(RGB(R,G,B));
tmpStr:='';
except
Result:=aDefColor;
end;
end;

procedure SetGlyph(aSpeedButton: TSpeedButton; aImageList: TImageList;
  aIndex: integer; aEnabled: boolean = true);
begin
  SetGlyph(aSpeedButton, aImageList,[aIndex], aEnabled);
end;

procedure SetGlyph(aBitBtn: TBitBtn; aImageList: TImageList;
  aIndex: integer; aEnabled: boolean = true);
begin
  SetGlyph(aBitBtn, aImageList,[aIndex], aEnabled);
end;

procedure SetGlyph(aSpeedButton: TSpeedButton; aImageList: TImageList;
  aIndexes: array of integer; aEnabled: boolean = true); overload;
var
  bmp: TBitmap;
  cnt: integer;
begin
  bmp := TBitmap.Create;
  try
    with bmp do
    begin
      Width := aImageList.Width;
      height := aImageList.height;
      TransparentColor := clFuchsia;
      Transparent := true;
      Canvas.Brush.Color := TransparentColor;
      Canvas.FillRect(Rect(0, 0, Width, height));
    end;
    aImageList.DrawingStyle := dsTransparent;
    for cnt := 0 to High(aIndexes)do
      if (aIndexes[cnt]>=0) and (aIndexes[cnt]<=aImageList.Count-1)
         then aImageList.Draw(bmp.Canvas, 0, 0, aIndexes[cnt]);
    aSpeedButton.NumGlyphs := 1;
    if not aEnabled then
      ColorToGrayExColor(bmp.Canvas.Handle, Bounds(0, 0, bmp.Width, bmp.height),
        clFuchsia);
    //CopyBitmapToClipBoard(bmp);
    aSpeedButton.Glyph.Assign(bmp);
    aSpeedButton.Invalidate;
  finally
    FreeAndNil(bmp);
  end;
end;

procedure SetGlyph(aBitBtn: TBitBtn; aImageList: TImageList; aIndexes: array of integer; aEnabled: boolean = true); overload;
var
  bmp: TBitmap;
  cnt: integer;
begin
  bmp := TBitmap.Create;
  try
    with bmp do
    begin
      Width := aImageList.Width;
      height := aImageList.height;
      TransparentColor := clFuchsia;
      Transparent := true;
      Canvas.Brush.Color := TransparentColor;
      Canvas.FillRect(Rect(0, 0, Width, height));
    end;
    aImageList.DrawingStyle := dsTransparent;
    for cnt := 0 to High(aIndexes)do
      if (aIndexes[cnt]>=0) and (aIndexes[cnt]<=aImageList.Count-1)
         then aImageList.Draw(bmp.Canvas, 0, 0, aIndexes[cnt]);
    aBitBtn.NumGlyphs := 1;
    if not aEnabled then
      ColorToGrayExColor(bmp.Canvas.Handle, Bounds(0, 0, bmp.Width, bmp.height),
        clFuchsia);
    //CopyBitmapToClipBoard(bmp);
    aBitBtn.Glyph.Assign(bmp);
    aBitBtn.Invalidate;
  finally
    FreeAndNil(bmp);
  end;
end;

//-- работает, в принципе, но, как это понятно, после масштабирования речь о прозрачности не идет.....
procedure SetGlyphEx(aSpeedButton: TSpeedButton; aImageList: TImageList;
  aSize: integer; aIndexes: array of integer; aEnabled: boolean = true);
var
  bmp: TBitmap;
  _bmp: TBitmap;
  cnt: integer;
begin
  bmp := TBitmap.Create;
  _bmp := TBitmap.Create;
  try
    with bmp do
    begin
      Width := aImageList.Width;
      height := aImageList.height;
      TransparentColor := clFuchsia;
      Transparent := true;
      Canvas.Brush.Color := TransparentColor;
      Canvas.FillRect(Rect(0, 0, Width, height));
    end;
    with _bmp do
    begin
      Width := aSize;
      height := aSize;
      TransparentColor := clFuchsia;
      Transparent := true;
      Canvas.Brush.Color := TransparentColor;
      Canvas.FillRect(Rect(0, 0, Width, height));
    end;
    aImageList.DrawingStyle := dsTransparent;
    for cnt := 0 to High(aIndexes)do
      aImageList.Draw(bmp.Canvas, 0, 0, aIndexes[cnt]);
    aSpeedButton.NumGlyphs := 1;
    if not aEnabled then
      ColorToGrayExColor(bmp.Canvas.Handle, Bounds(0, 0, bmp.Width, bmp.height),
        clFuchsia);
    //CopyBitmapToClipBoard(bmp);
    SetStretchBltMode(_bmp.Canvas.Handle, HALFTONE);
    StretchBlt(_bmp.Canvas.Handle, 0, 0, aSize, aSize, bmp.Canvas.Handle, 0, 0,
      bmp.Width, bmp.height, SRCCOPY);
    aSpeedButton.Glyph.Assign(_bmp);
    aSpeedButton.Invalidate;
  finally
    FreeAndNil(_bmp);
    FreeAndNil(bmp);
  end;
end;

procedure SetGlyphTwo(SpB: TSpeedButton; IL : TImageList; Indexes: array of integer);
var
  bmp: TBitmap;
  cnt: integer;
begin
  bmp := TBitmap.Create;
  try
    with bmp do
    begin
      Width := IL.Width*2;
      height := IL.height;
      TransparentColor := clFuchsia;
      Transparent := true;
      Canvas.Brush.Color := TransparentColor;
      Canvas.FillRect(Rect(0, 0, Width, height));
    end;
    IL.DrawingStyle := dsTransparent;
    for cnt := 0 to High(Indexes)do
      if (Indexes[cnt]>=0) and (Indexes[cnt]<=IL.Count-1)
         then IL.Draw(bmp.Canvas, 0, 0, Indexes[cnt]);
    bmp.Canvas.Draw(IL.Width,0,bmp);
    ColorToGrayExColor(bmp.Canvas.Handle, Bounds(IL.Width, 0, IL.Width, bmp.height), clFuchsia);
    SpB.NumGlyphs := 2;
    SpB.Glyph.Assign(bmp);
    //CopyBitmapToClipBoard(bmp);
    SpB.Invalidate;
  finally
    FreeAndNil(bmp);
  end;
end;

function GlyphOfFile(const aExtOrFileName:string; aSpB: TSpeedButton): boolean;
var
  ico: TIcon;
  bmp: TBitmap;
begin
  ico := TIcon.Create;
  bmp := TBitmap.Create;
  try
    GetAssociatedIcon(aExtOrFileName, ico);
    bmp.Width := ico.Width;
    bmp.height := ico.height;
    bmp.Canvas.Draw(0, 0, ico);
    if aSpB.Glyph.Empty then
    begin
      aSpB.Glyph.Width := 16;
      aSpB.Glyph.height := 16;
      aSpB.Glyph.Canvas.Brush.Color := clRed;
      aSpB.Glyph.Canvas.FillRect(Bounds(0, 0, 16, 16));
      aSpB.Glyph.TransparentColor := clFuchsia;
      aSpB.Glyph.Transparent := true;
      aSpB.NumGlyphs := 1;
    end;
    SetStretchBltMode(bmp.Canvas.Handle, HALFTONE);
    StretchBlt(bmp.Canvas.Handle, 0, 0, 16, 16, bmp.Canvas.Handle, 0, 0,
      bmp.Width, bmp.height, SRCCOPY);
    bmp.Width := 16;
    bmp.height := 16;
    aSpB.Glyph.Assign(bmp);
    Result := true;
  finally
    bmp.Free;
    ico.Free;
  end;
end;

(*****************************************************************************)

procedure SetMultiLineCaption(Button : TButton; const MultiLineText : string);
begin
SetWindowLong(Button.Handle,GWL_STYLE,GetWindowLong(Button.Handle,GWL_STYLE) or BS_MULTILINE);
Button.Caption:=MultiLineText;
end;

procedure SetMultiLineCaption(Button : TBitBtn; const MultiLineText : string); overload;
var
 Wnd : hWnd;
begin
Wnd := TButtonControl(Button).Handle;
SetWindowLong(Wnd,GWL_STYLE,GetWindowLong(Wnd,GWL_STYLE) or BS_MULTILINE);
Button.Caption:=MultiLineText;
end;


procedure SetMultiLineCaption(Button : TSpeedButton; const MultiLineText : string); overload;
var
 Wnd : hWnd;
begin
Wnd := WindowFromDC(THackGraphicControl(Button).Canvas.Handle);
SetWindowLong(Wnd,GWL_STYLE,GetWindowLong(Wnd,GWL_STYLE) or BS_MULTILINE);
Button.Caption:=MultiLineText;
end;

(******************************************************************************)

procedure ALPHA_Window(WndHandle: HWND; Value: Byte);
var
  SetLayeredWindowAttributes: TSetLayeredWindowAttributes;
  LibHandle: cardinal;
  WinLongStyle: Longint;
const
  LibName = user32;
  FunName = 'SetLayeredWindowAttributes';
begin
  WinLongStyle := GetWindowLong(WndHandle, GWL_EXSTYLE);
  if WinLongStyle and WS_EX_LAYERED = 0 then
    SetWindowLong(WndHandle, GWL_EXSTYLE, WinLongStyle or WS_EX_LAYERED);
  //if WinLongStyle and WS_EX_TOPMOST = 0 then SetWindowLong(WndHandle, GWL_EXSTYLE, WinLongStyle or WS_EX_TOPMOST);
  LibHandle := LoadLibrary(user32);
  try
    if LibHandle = 0 then
      Exit;
    @SetLayeredWindowAttributes := GetProcAddress(LibHandle, FunName);
    if Assigned(@SetLayeredWindowAttributes)then
    begin
      SetLayeredWindowAttributes(WndHandle, 0, Value, LWA_ALPHA);
      UpdateWindow(WndHandle);
    end;
  finally
    FreeLibrary(LibHandle);
  end;
end;

procedure SetTransparentWindow(WndHandle: HWND; Value: Byte);
begin
  ALPHA_Window(WndHandle, Value);
end;

procedure AlphaBlt(aDestDC: hDC; aDestLeft, aDestTop, aDestWidth,
  aDestHeight: integer; aSrcDC: hDC; aSrcLeft, aSrcTop, aSrcWidth,
  aSrcHeight: integer; aAlpha: Byte);
var
  bmp: TBitmap;
  dtWnd: cardinal;
  dtDC: hDC;
  dc: hDC;
  blend: BLENDFUNCTION;
begin
  blend.BlendOp := AC_SRC_OVER;
  blend.BlendFlags := 0;
  blend.SourceConstantAlpha := aAlpha;
  blend.AlphaFormat := 0;
  dtWnd := GetDesktopWindow;
  dtDC := getDC(dtWnd);
  dc := CreateCompatibleDC(dtDC);//не зависит!
  bmp := TBitmap.Create;
  try
    with bmp do
    begin
      PixelFormat := pfDevice;
      Width := aSrcWidth;
      height := aSrcHeight;
      BitBlt(bmp.Canvas.Handle, 0, 0, Width, height, aSrcDC, aSrcLeft,
        aSrcTop, SRCCOPY);
    end;
    SelectObject(dc, bmp.Handle);
    AlphaBlendBlt(aDestDC//Результатный девайс, подготовки не требуется
      , aDestLeft, aDestTop, aDestWidth, aDestHeight, dc//а вот накладываемый!...
      , aSrcLeft, aSrcTop, aSrcWidth, aSrcHeight, blend);
  finally
    DeleteDC(dc);
    ReleaseDC(dtWnd, dtDC);
    FreeAndNil(bmp);
  end;

end;

procedure AlphaBlt(aDestCanvas: TCanvas; aDestLeft, aDestTop, aDestWidth,
  aDestHeight: integer; aSrcCanvas: TCanvas; aSrcLeft, aSrcTop, aSrcWidth,
  aSrcHeight: integer; aAlpha: Byte);
begin
  AlphaBlt(aDestCanvas.Handle, aDestLeft, aDestTop, aDestWidth, aDestHeight,
    aSrcCanvas.Handle, aSrcLeft, aSrcTop, aSrcWidth, aSrcHeight, aAlpha);
end;


procedure ShakeScreen(aWnd : cardinal = 0);
const
 defmonitor : integer = 0;
 deltaX     : integer = 10;
 deltaY     : integer = 10;
var
 rctStay  : TRect;
 cnt      : integer;
 bmp      : TBitmap;
 wnd      : cardinal;
 dc       : hDc;
 mLeft    : integer;
 mTop     : integer;
 mWidth   : integer;
 mHeight  : integer;
 monitor  : integer;
begin
if aWnd=0
 then if Assigned(Application) and Assigned(Application.MainForm)
        then monitor:=Application.MainForm.Monitor.MonitorNum
        else monitor:=Screen.MonitorFromWindow(GetWindowByCursor).MonitorNum
 else monitor:=Screen.MonitorFromWindow(aWnd).MonitorNum; // GetWindowByCursor
try
bmp:=TBitmap.Create;
wnd:=GetDesktopWindow;
dc:=GetWindowDC(wnd);
try
mLeft   := Screen.Monitors[monitor].Left;
mTop    := Screen.Monitors[monitor].Top;
mWidth  := Screen.Monitors[monitor].Width;
mHeight := Screen.Monitors[monitor].Height;
rctStay:=Bounds(mLeft,0,mWidth,mHeight);
with bmp do
 begin
 Width:=mWidth+deltaX*2;
 Height:=mHeight+deltaY*2;
 Canvas.Brush.Color:=clBlack;
 end;
bmp.Canvas.FillRect(Bounds(0,0,bmp.Width,bmp.Height));
StretchBlt(bmp.Canvas.Handle,deltaX,deltaY,mWidth,mHeight,dc,mLeft,mTop,mWidth,mHeight,SRCCOPY);
cnt:=10;
while cnt>0 do
   begin
   // -- Нормальная
   StretchBlt(dc,mLeft,mTop,mWidth,mHeight,bmp.Canvas.Handle,deltaX,deltaY,mWidth,mHeight,SRCCOPY);
   _sleep(5*cnt+1);
   // -- двигаем вверх (видна рамка справа-снизу)
   StretchBlt(dc,mLeft,mTop,mWidth,mHeight,bmp.Canvas.Handle,deltaX*2,deltaY*2,mWidth,mHeight,SRCCOPY);
   _sleep(5*cnt+1);
   // -- двигаем вниз (видна рамка слева-сверху)
   StretchBlt(dc,mLeft,mTop,mWidth,mHeight,bmp.Canvas.Handle,0,0,mWidth,mHeight,SRCCOPY);
   _sleep(5*cnt+1);
   dec(cnt);
   end;
StretchBlt(dc,mLeft,mTop,mWidth,mHeight,bmp.Canvas.Handle,deltaX,deltaY,mWidth,mHeight,SRCCOPY);
UpdateWindow(wnd);
RedrawWindow(wnd,nil,0, RDW_ERASE or RDW_INVALIDATE);
finally
ReleaseDC(wnd,dc);
bmp.Free;
end;
except
  on E : Exception do ;//LogErrorMessage('T_Main.ShakeScreen',E,[]);
end
end;

procedure ShakeScreen(aWnd,aDuration : cardinal);
const
 defmonitor : integer = 0;
 deltaX     : integer = 10;
 deltaY     : integer = 10;
var
 rctStay  : TRect;
 cnt      : integer;
 bmp      : TBitmap;
 wnd      : cardinal;
 dc       : hDc;
 mLeft    : integer;
 mTop     : integer;
 mWidth   : integer;
 mHeight  : integer;
 monitor  : integer;
 timeStop : TDateTime;

begin
if aWnd=0
 then if Assigned(Application) and Assigned(Application.MainForm)
        then monitor:=Application.MainForm.Monitor.MonitorNum
        else monitor:=Screen.MonitorFromWindow(GetWindowByCursor).MonitorNum
 else monitor:=Screen.MonitorFromWindow(aWnd).MonitorNum; // GetWindowByCursor
try
bmp:=TBitmap.Create;
wnd:=GetDesktopWindow;
dc:=GetWindowDC(wnd);
try
mLeft   := Screen.Monitors[monitor].Left;
mTop    := Screen.Monitors[monitor].Top;
mWidth  := Screen.Monitors[monitor].Width;
mHeight := Screen.Monitors[monitor].Height;
rctStay:=Bounds(mLeft,0,mWidth,mHeight);
with bmp do
 begin
 Width:=mWidth+deltaX*2;
 Height:=mHeight+deltaY*2;
 Canvas.Brush.Color:=clBlack;
 end;
bmp.Canvas.FillRect(Bounds(0,0,bmp.Width,bmp.Height));
StretchBlt(bmp.Canvas.Handle,deltaX,deltaY,mWidth,mHeight,dc,mLeft,mTop,mWidth,mHeight,SRCCOPY);
cnt:=10;
if aDuration>0
   then timeStop:=Now+MSecToDateTime(int64(aDuration))
   else timeStop:=0;
while cnt>0 do
   begin
   // -- Нормальная
   StretchBlt(dc,mLeft,mTop,mWidth,mHeight,bmp.Canvas.Handle,deltaX,deltaY,mWidth,mHeight,SRCCOPY);
   _sleep(5*cnt+1);
   // -- двигаем вверх (видна рамка справа-снизу)
   StretchBlt(dc,mLeft,mTop,mWidth,mHeight,bmp.Canvas.Handle,deltaX*2,deltaY*2,mWidth,mHeight,SRCCOPY);
   _sleep(5*cnt+1);
   // -- двигаем вниз (видна рамка слева-сверху)
   StretchBlt(dc,mLeft,mTop,mWidth,mHeight,bmp.Canvas.Handle,0,0,mWidth,mHeight,SRCCOPY);
   _sleep(5*cnt+1);
   if (timeStop=0) or (timeStop<Now)
     then dec(cnt);
   end;
StretchBlt(dc,mLeft,mTop,mWidth,mHeight,bmp.Canvas.Handle,deltaX,deltaY,mWidth,mHeight,SRCCOPY);
UpdateWindow(wnd);
RedrawWindow(wnd,nil,0, RDW_ERASE or RDW_INVALIDATE);
finally
ReleaseDC(wnd,dc);
bmp.Free;
end;
except
  on E : Exception do ;//LogErrorMessage('T_Main.ShakeScreen',E,[]);
end
end;

procedure RepaintWindow(wnd : cardinal);
var
 rct : TRect;
begin
GetWindowRect(wnd,rct);
OffsetRect(rct,-rct.Left, -rct.Top);
InvalidateRect(wnd,rct,LongBool(true));
UpdateWindow(wnd);
SendMessage(wnd,WM_NCPAINT,0,0);
sleep(1);
SendMessage(wnd,WM_ERASEBKGND, 0,0);
sleep(1);
SendMessage(wnd,WM_PAINT, 0,0);
sleep(1);
end;

procedure blink(wnd : cardinal);
var
 fwi : TFlashWInfo;
 cnt : integer;
 clrs  : array[boolean] of TColor;
 clrFl : boolean;

 rct : Trect;
 dc : hDC ;
 br : hBrush;
begin
if GetWindowLong(wnd, GWL_STYLE) and WS_BORDER > 0
   then begin
   fwi.cbSize:=SizeOf(TFlashWInfo);
   fwi.hwnd:=wnd;
   fwi.uCount:=5;
   fwi.dwTimeout:=100;
   fwi.dwFlags:=FLASHW_ALL;
   FlashWindowEx(fwi);
   Exit;
   end;

clrFl:=false;
GetWindowRect(wnd, rct);
rct:= Bounds(1,1,(rct.Right-rct.left)-2, (rct.Bottom - rct.Top)-2);
dc:=GetWindowDC(wnd);
try
clrs[false]:=clPaleRed;
clrs[true]:=GetDCBrushColor(dc);//GetPixel(dc, rct.Right div 2, rct.Bottom  div 2);
cnt:=0;
while cnt<5
 do begin
 br:=CreateSolidBrush(clrs[clrFl]);
 FillRect(dc, rct, br);
 DeleteObject(br);
 _sleep(50);
 clrFl:=not clrFl;
 br:=CreateSolidBrush(clrs[clrFl]);
 FillRect(dc, rct, br);
 DeleteObject(br);
 _sleep(50);
 inc(cnt);
 end;
finally
ReleaseDC(wnd, dc);
end;

RedrawWindow(wnd, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_UPDATENOW or RDW_ERASENOW);//RDW_ERASE or RDW_INVALIDATE or RDW_ALLCHILDREN);

//
////RepaintWindow(wnd);
//rct:=Rect(rct.Left-2, rct.Top-2, rct.Right+2, rct.Bottom+2);
//InvalidateRect(wnd,@rct,longbool(true));
//InvalidateRect(wnd,nil,longbool(true));
//UpdateWindow(wnd);
//rgn:=CreateRectRgn(rct.Left, rct.Top, rct.Right, rct.Bottom);
//RedrawWindow(wnd, rct, rgn,RDW_ERASENOW or RDW_INVALIDATE);

//SendMessage(wnd,WM_NCPAINT, wParam(rgn),0);
//DeleteObject(rgn);
//sleep(1);
//SendMessage(wnd,WM_ERASEBKGND, 0,0);
//sleep(1);
//SendMessage(wnd,WM_SETREDRAW, 1,0);
//sleep(1);
//SendMessage(wnd,WM_PAINT, 0,0);
//sleep(1);
end;


procedure CalcTextSize(aDC: hDC;const aStr:string; aAlign: integer;
  var aSize: tagSize);
var
  rct: TRect;
  alg: integer;
begin
  alg := aAlign;
  if(DT_CALCRECT and alg = 0)then
    alg := alg + DT_CALCRECT;
  rct := Bounds(0, 0, 1, 1);
  DrawText(aDC, aStr, Length(aStr), rct, alg);
  aSize.cx := rct.Right - rct.Left;
  aSize.cy := rct.Bottom - rct.Top;
end;

procedure DrawTransparentText(aDC: hDC;const aStr:string;var aRct: TRect;
  aAlign: integer);
var
  rct: TRect;
  //dX  : integer;
  //dY  : integer;
begin
  System.Move(aRct, rct, SizeOf(TRect));
  //if ((DT_VCENTER and aAlign <>0) or
  //(DT_CENTER and aAlign <>0)) and
  //(DT_CALCRECT and aAlign = 0)
  //then begin
  //rct:=Rect(0,0,1,1);
  //DrawText(aDC,PChar(aStr),Length(aStr),rct,aAlign or DT_CALCRECT);
  //dX:=Round((aRct.Right - aRCT.Left) / 2 - (rct.Right - rct.Left) / 2) ;
  //dY:=Round((aRct.Bottom - aRCT.Top)  / 2- (rct.Bottom - rct.Top) / 2);
  /// /   System.Move(aRct,rct,SizeOf(TRect));
  /// /   if (DT_CENTER and aAlign <>0) then OffsetRect(rct,dX,0);
  /// /   if (DT_VCENTER and aAlign <>0) then OffsetRect(rct,0,dY);
  //OffsetRect(rct,aRct.Left,aRct.Top);
  //end;
  SetBkMode(aDC, Transparent);
  DrawText(aDC, PChar(aStr), Length(aStr), rct, aAlign);
  SetBkMode(aDC, Opaque);
end;

procedure DrawTransparentText(aCanvas: TCanvas;const aStr:string;
  var aRct: TRect; aAlign: integer);
begin
  //aCanvas.Lock;
  //try
  DrawTransparentText(aCanvas.Handle, aStr, aRct, aAlign)
  //finally
  //while aCanvas.LockCount>0 do aCanvas.UnLock;
  //end;
end;

procedure DrawLine(aDC: hDC; ptFrom, ptTo: TPoint);
begin
  Windows.MoveToEx(aDC, ptFrom.X, ptFrom.Y,nil);
  Windows.LineTo(aDC, ptTo.X, ptTo.Y);
end;


procedure DrawLine(aCanvas: TCanvas; ptFrom, ptTo: TPoint);
begin
  aCanvas.Lock;
  try
    Windows.MoveToEx(aCanvas.Handle, ptFrom.X, ptFrom.Y,nil);
    Windows.LineTo(aCanvas.Handle, ptTo.X, ptTo.Y);
  finally
    aCanvas.UnLock;
  end;
end;

procedure DrawLineEx(aDC: hDC; ptFrom, ptTo: TPoint; aColor: TColor);
var
 opn : hPen;
begin
opn:=SelectObject(aDC,CreatePen(PS_SOLID,1,aColor));
try
  Windows.MoveToEx(aDC, ptFrom.X, ptFrom.Y,nil);
  Windows.LineTo(aDC, ptTo.X, ptTo.Y);
finally
DeleteObject(SelectObject(aDC,opn));
end;
end;

procedure DrawLineEx(aCanvas: TCanvas; ptFrom, ptTo: TPoint; aColor: TColor);
var
 clr : TColor;
begin
clr:=aCanvas.Pen.Color;
aCanvas.Pen.Color:=aColor;
aCanvas.Lock;
try
  Windows.MoveToEx(aCanvas.Handle, ptFrom.X, ptFrom.Y,nil);
  Windows.LineTo(aCanvas.Handle, ptTo.X, ptTo.Y);
finally
aCanvas.UnLock;
aCanvas.Pen.Color:=clr;
end;
end;



type
 PDotLineProps = ^TDotLineProps;
 TDotLineProps = record
  dc : hDC;
  int : integer;
  clr : TColor;
  A   : TPoint;
  B   : TPoint;
end;



procedure ENumPoints(aX,aY : integer; aData : pointer);stdcall;
begin
with PDotLineProps(aData)^
  do begin
  if Abs(A.X-B.X)>Abs(A.Y-B.Y)
    then begin
    if (aX mod int = 0)
       then SetPixel(dc,aX,aY,clr);
    end
    else begin
    if (aY mod int = 0)
        then SetPixel(dc,aX,aY,clr);
    end;
  end
end;


procedure DrawDotLine(aDC: hDC; ptFrom, ptTo: TPoint; aClr : TColor; aInt : integer); overload;
var
 dlp : TDotLineProps;
begin
dlp.dc:=aDC;
dlp.int:=aInt;
dlp.clr:=aClr;
dlp.A:=ptFrom;
dlp.B:=ptTo;
LineDDA(ptFrom.X,ptFrom.Y,ptTo.X,ptTo.Y,@ENumPoints,integer(@dlp));
end;


procedure DrawDotLine(aCanvas: TCanvas; ptFrom, ptTo: TPoint; aClr : TColor; aInt : integer); overload;
//var
// dlp : TDotLineProps;
begin
DrawDotLine(aCanvas.Handle, ptFrom, ptTo, aClr, aInt);
//dlp.dc:=aCanvas.Handle;
//dlp.int:=aInt;
//dlp.clr:=aClr;
//dlp.A:=ptFrom;
//dlp.B:=ptTo;
//LineDDA(ptFrom.X,ptFrom.Y,ptTo.X,ptTo.Y,@ENumPoints,integer(@dlp));
end;




procedure DrawWeb(aDC: hDC; aRect: TRect; aColor: TColor = clGray);
//type
//PPoints = ^TPoints;
//TPoints = array[0..0] of TPoint;
  procedure AddIntItem(aInt: double;var aArr: TDoubleDynArray);
  var
    ind: integer;
  begin
    ind := Length(aArr);
    SetLength(aArr, ind + 1);
    aArr[ind]:= aInt;
  end;

const
  AngDegMax: double = 360 *(PI / 180);
var
  LB: LOGBRUSH;
  obr, br: hBrush;
  opn, pn: hPen;
  ptC: TPoint;
  radius: integer;
  angDeg: double;
  angArr: TDoubleDynArray;
  ind: integer;
  ptA, ptB: TPoint;
  ptM: TPoint;
  radM: double;
  radCirc: integer;
  pi_180: double;
  _Sin: double;
  _Cos: double;
  ptArr: array of TPoint;
begin
  Randomize;
  pi_180 :=(PI / 180);
  FillChar(LB, 0, SizeOf(LOGBRUSH));
  LB.lbStyle := HOLLOW_BRUSH;
  br := CreateBrushIndirect(LB);
  obr := SelectObject(aDC, br);
  pn := CreatePen(PS_SOLID, 1, aColor);
  opn := SelectObject(aDC, pn);
  try
    with aRect do
      ptC := Point(Abs(Right - Left), Abs(Bottom - Top));
    radius := ptC.X;
    if ptC.Y > ptC.X then
      radius := ptC.Y;
    ptC := Point(aRect.Left + ptC.X div 3 + Random(ptC.X div 3 * 2),
      aRect.Top + ptC.Y div 3 + Random(ptC.Y div 3 * 2));

    angDeg := Random(45)* pi_180;
    AddIntItem(angDeg, angArr);
    while angArr[High(angArr)]< AngDegMax do
    begin
      angDeg := angDeg +(Random(30)+ Random(15)+ 2)* pi_180;
      if angDeg >= AngDegMax then
      begin
        AddIntItem(angArr[Low(angArr)], angArr);
        Break;
      end;
      AddIntItem(angDeg, angArr);
    end;
    for ind := 0 to High(angArr)do
    begin
      SinCos(angArr[ind], _Sin, _Cos);
      ptA := Point(Round(radius * _Cos + ptC.X), Round(radius * _Sin + ptC.Y));
      //if ind=High(angArr)
      //then pn:=CreatePen(PS_SOLID,1,clWhite)
      //else
      //if ind=High(angArr)-1
      //then pn:=CreatePen(PS_SOLID,1,clRed)
      //else pn:=CreatePen(PS_SOLID,1,aColor);
      //DeleteObject(SelectObject(aDC,pn));
      DrawLine(aDC, ptC, ptA);
    end;
    pn := CreatePen(PS_SOLID, 1, aColor);
    DeleteObject(SelectObject(aDC, pn));
    radCirc := Random(radius div 20)+ Random(radius div 10);
    while radCirc <= radius do
    begin
      for ind := 1 to High(angArr)do
      begin
        SinCos(angArr[ind - 1], _Sin, _Cos);
        ptA := Point(Round((radCirc)* _Cos + ptC.X),
          Round((radCirc)* _Sin + ptC.Y));
        SinCos(angArr[ind], _Sin, _Cos);
        ptB := Point(Round((radCirc)* _Cos + ptC.X),
          Round((radCirc)* _Sin + ptC.Y));
        if ind < High(angArr)then
        begin
          SinCos(angArr[ind - 1]+ Abs((angArr[ind]- angArr[ind - 1]))/ 2,
            _Sin, _Cos);
          radM := radCirc - sqrt(power((ptA.X - ptB.X), 2)+
            power((ptA.Y - ptB.Y), 2))* 0.25;
          ptM := Point(Round(radM * _Cos + ptC.X), Round(radM * _Sin + ptC.Y));
        end
        else
        begin//-- это ВИДИМЫЕ граничные линии
          SinCos(DegToRad(180)+ angArr[High(angArr)]/ 2 +
            angArr[High(angArr)- 1]/ 2, _Sin, _Cos);
          //angArr[ind] + (AngDegMax - angArr[ind])
          radM := radCirc - sqrt(power((ptA.X - ptB.X), 2)+
            power((ptA.Y - ptB.Y), 2))* 0.25;
          ptM := Point(Round(radM * _Cos + ptC.X), Round(radM * _Sin + ptC.Y));
        end;

        SetLength(ptArr, 4);
        try
          System.Move(ptA, ptArr[0], SizeOf(TPoint));
          System.Move(ptM, ptArr[1], SizeOf(TPoint));
          System.Move(ptM, ptArr[2], SizeOf(TPoint));
          //-- именно так, но почему ???
          System.Move(ptB, ptArr[3], SizeOf(TPoint));
          PolyBezier(aDC, ptArr[0], 4);
        finally
          SetLength(ptArr, 0);
        end;
      end;
      radCirc := radCirc + Random(radius div 20)+ Random(radius div 10);
    end;
    //
    //pn:=CreatePen(PS_SOLID,1,clBlue);
    //DeleteObject(SelectObject(aDC,pn));
    //DrawLine(aDC,ptC,Point(ptC.X+radius,ptC.Y));

  finally
    DeleteObject(SelectObject(aDC, opn));
    DeleteObject(SelectObject(aDC, obr));
    SetLength(angArr, 0);
  end;
end;

procedure DrawWeb(aCanvas: TCanvas; aRect: TRect; aColor: TColor = clGray);
  procedure AddIntItem(aInt: double;var aArr: TDoubleDynArray);
  var
    ind: integer;
  begin
    ind := Length(aArr);
    SetLength(aArr, ind + 1);
    aArr[ind]:= aInt;
  end;

const
  AngDegMax: double = 360 *(PI / 180);
var
  OldBrush: TBrush;
  OldPen: TPen;
  ptC: TPoint;
  radius: integer;
  angDeg: double;
  angArr: TDoubleDynArray;
  ind: integer;
  ptA, ptB: TPoint;
  ptM: TPoint;
  radM: double;
  radCirc: integer;
  pi_180: double;
  _Sin: double;
  _Cos: double;
  ptArr: array of TPoint;
begin
  Randomize;
  pi_180 :=(PI / 180);
  OldBrush := TBrush.Create;
  OldPen := TPen.Create;
  try
    OldBrush.Assign(aCanvas.Brush);
    OldPen.Assign(aCanvas.Pen);
    aCanvas.Brush.Style := bsClear;
    aCanvas.Pen.Color := aColor;
    with aRect do
      ptC := Point(Abs(Right - Left), Abs(Bottom - Top));
    radius := ptC.X;
    if ptC.Y > ptC.X then
      radius := ptC.Y;
    ptC := Point(aRect.Left + ptC.X div 3 + Random(ptC.X div 3 * 2),
      aRect.Top + ptC.Y div 3 + Random(ptC.Y div 3 * 2));
    angDeg := Random(45)* pi_180;
    AddIntItem(angDeg, angArr);
    while angArr[High(angArr)]< AngDegMax do
    begin
      angDeg := angDeg +(Random(30)+ Random(15)+ 2)* pi_180;
      if angDeg >= AngDegMax then
      begin
        AddIntItem(angArr[Low(angArr)], angArr);
        Break;
      end;
      AddIntItem(angDeg, angArr);
    end;
    for ind := 0 to High(angArr)do
    begin
      SinCos(angArr[ind], _Sin, _Cos);
      ptA := Point(Round(radius * _Cos + ptC.X), Round(radius * _Sin + ptC.Y));
      DrawLine(aCanvas.Handle, ptC, ptA);
    end;
    radCirc := Random(radius div 20)+ Random(radius div 10);
    while radCirc <= radius do
    begin
      for ind := 1 to High(angArr)do
      begin
        SinCos(angArr[ind - 1], _Sin, _Cos);
        ptA := Point(Round((radCirc)* _Cos + ptC.X),
          Round((radCirc)* _Sin + ptC.Y));
        SinCos(angArr[ind], _Sin, _Cos);
        ptB := Point(Round((radCirc)* _Cos + ptC.X),
          Round((radCirc)* _Sin + ptC.Y));
        if ind < High(angArr)then
        begin
          SinCos(angArr[ind - 1]+ Abs((angArr[ind]- angArr[ind - 1]))/ 2,
            _Sin, _Cos);
          radM := radCirc - sqrt(power((ptA.X - ptB.X), 2)+
            power((ptA.Y - ptB.Y), 2))* 0.25;
          ptM := Point(Round(radM * _Cos + ptC.X), Round(radM * _Sin + ptC.Y));
        end
        else
        begin//-- это ВИДИМЫЕ граничные линии
          SinCos(DegToRad(180)+ angArr[High(angArr)]/ 2 +
            angArr[High(angArr)- 1]/ 2, _Sin, _Cos);
          //angArr[ind] + (AngDegMax - angArr[ind])
          radM := radCirc - sqrt(power((ptA.X - ptB.X), 2)+
            power((ptA.Y - ptB.Y), 2))* 0.25;
          ptM := Point(Round(radM * _Cos + ptC.X), Round(radM * _Sin + ptC.Y));
        end;

        SetLength(ptArr, 4);
        try
          System.Move(ptA, ptArr[0], SizeOf(TPoint));
          System.Move(ptM, ptArr[1], SizeOf(TPoint));
          System.Move(ptM, ptArr[2], SizeOf(TPoint));
          //-- именно так, но почему ???
          System.Move(ptB, ptArr[3], SizeOf(TPoint));
          aCanvas.PolyBezier(ptArr);
        finally
          SetLength(ptArr, 0);
        end;
      end;
      radCirc := radCirc + Random(radius div 20)+ Random(radius div 10);
    end;
  finally
    aCanvas.Pen.Assign(OldPen);
    OldPen.Free;
    aCanvas.Brush.Assign(OldBrush);
    OldBrush.Free;
    SetLength(angArr, 0);
  end;
end;

(******************************************************************************)

var
  SimpleSplash: TSimpleSplash;

constructor TSimpleSplash.CreateSplash(AOwner: TComponent;
  const aSplashMessage:string; aSplashType: TSplashType);
var
  sz : TSize;
begin
  CreateNew(AOwner);
  SetDoubleBuffered(self);
  BorderStyle := bsNone;
  Font.Name := 'Tahoma';
  Font.Size := 10;
  Canvas.Font.Assign(Font);
  Width := Screen.DesktopWidth div 3;
  height := 30;
  sz:=Canvas.TextExtent(aSplashMessage);
  if Width<sz.cx then Width:=sz.cx+8;
  if Height<sz.cy then Height:=sz.cy+8;
  Left := Screen.DesktopWidth div 2 - Width div 2;
  Top := Screen.DesktopHeight div 2 - height div 2;
  FormStyle := fsStayOnTop;
  Position := poScreenCenter;
  Visible := true;
  fMainColor:=Graphics.clNone;
  fFontColor:=Graphics.clNone;
  FSplashType := aSplashType;
  if aSplashType=stToast
     then Top := Screen.DesktopHeight div 10 * 7;
  FSplashMessage := aSplashMessage;
  onClose:=OnCloseSplash;
  BringToFront;
  Repaint;
end;



constructor TSimpleSplash.CreateSplash(AOwner: TComponent; const aSplashMessage:string; clrMain,clrFont: TColor);
var
  sz : TSize;
begin
  CreateNew(AOwner);
  SetDoubleBuffered(self);
  BorderStyle := bsNone;
  Font.Name := 'Tahoma';
  Font.Size := 10;
  Canvas.Font.Assign(Font);
  Width := Screen.DesktopWidth div 3;
  height := 30;
  sz:=Canvas.TextExtent(aSplashMessage);
  if Width<sz.cx then Width:=sz.cx+8;
  if Height<sz.cy then Height:=sz.cy+8;
  Left := Screen.DesktopWidth div 2 - Width div 2;
  Top := Screen.DesktopHeight div 2 - height div 2;
  FormStyle := fsStayOnTop;
  Position := poScreenCenter;
  Visible := true;
  fMainColor:=clrMain;
  fFontColor:=clrFont;
  //FSplashType := aSplashType;
  //if aSplashType=stToast
  //   then Top := Screen.DesktopHeight div 10 * 7;
  FSplashMessage := aSplashMessage;
  onClose:=OnCloseSplash;
  BringToFront;
  Repaint;
end;

procedure TSimpleSplash.SetSplashType(Value: TSplashType);
begin
  FSplashType := Value;
  Invalidate;
end;

procedure TSimpleSplash.SetSplashCaption(const Value:string);
begin
  FSplashMessage := Value;
  Invalidate;
end;

procedure TSimpleSplash.OnCloseSplash(Sender:TObject; var Action:TCloseAction);
begin
try
Hide;
Action:=caFree;
except
end;
end;


procedure TSimpleSplash.WMTimer(var msg : TWMTimer);
begin
case msg.TimerID of
 1 : begin
     if fShowTime+EncodeTime(0,0,5,0)<Now
        then begin
        KillTimer(Handle,1);
        FreeSplash;
        end;
     end;
end;
inherited;
end;


procedure TSimpleSplash.Paint;
begin
if fMainColor<>Graphics.clNone
   then GradientFigure(Canvas,gfRectangle,ClientRect,fMainColor,FSplashMessage,fFontColor,false)
   else
  case FSplashType of
    stInfo:
      BlueCaption(Canvas.Handle, ClientRect, FSplashMessage);
    stOk:
      GreenCaption(Canvas.Handle, ClientRect, FSplashMessage);
    stWarning:
      YellowCaption(Canvas.Handle, ClientRect, FSplashMessage);
    stError:
      RedCaption(Canvas.Handle, ClientRect, FSplashMessage);
  else
    GrayCaption(Canvas.Handle, ClientRect, FSplashMessage);
  end;
end;


(*DATESINTERVALITEM*)
function TDatesIntervalItem.DateInDTI(aDateTime: TDateTime;
  aIncludeLimits: boolean = true): boolean;
begin
  if aIncludeLimits//-- можно через добавление EncodeTime(0,0,0,3)
  then
    Result :=(aDateTime >= DateBegin)and(aDateTime <= DateEnd)
  else
    Result :=(aDateTime > DateBegin)and(aDateTime < DateEnd)
end;

function TDatesIntervalItem.GetXML:string;
begin
  Result := Format('<DII><DB>%s</DB><DE>%s</DE></DII>',
    [FormatDateTime('yyyymmdd hh:nn:ss', DateBegin),
    FormatDateTime('yyyymmdd hh:nn:ss', DateEnd)])
end;

procedure TDatesIntervalItem.SetDateTime(aIsBegin: boolean);
  procedure CalcPosition(var ALeftTop: TPoint; aWidth, aHeight: integer);
  var
    scrWdt: integer;
    scrHgt: integer;
  begin
    scrWdt := GetSystemMetrics(SM_CXSCREEN);
    scrHgt := GetSystemMetrics(SM_CYSCREEN);
    if ALeftTop.X + aWidth > scrWdt then
      ALeftTop.X := ALeftTop.X - aWidth;
    if ALeftTop.Y + aHeight > scrHgt then
      ALeftTop.Y := ALeftTop.Y - aHeight;
  end;

var
  _F: TForm;
  _DTP_Date: TDateTimePicker;
  _DTP_Time: TDateTimePicker;
  _BBOk: TBitBtn;
  _BBCancel: TBitBtn;
  tmp_dt: TDateTime;
  pt: TPoint;
begin
  _F := TForm.CreateNew(Application);
  _DTP_Date := TDateTimePicker.Create(_F);
  _DTP_Date.DateTime := 0;
  _DTP_Time := TDateTimePicker.Create(_F);
  _DTP_Time.DateTime := 0;
  _BBOk := TBitBtn.Create(Application);
  _BBCancel := TBitBtn.Create(Application);
  try
    with _F do
    begin
      if aIsBegin then
        Caption := 'Интервал : начало'
      else
        Caption := 'Интервал : окончание';
      Windows.GetCursorPos(pt);
      BorderStyle := bsDialog;
      FormStyle := fsStayOnTop;
      Position := poDefaultSizeOnly;
    end;
    with _DTP_Date do
    begin
      Parent := _F;
      Left := 4;
      Top := 4;
      DateFormat := dfLong;
      if aIsBegin then
        DateTime := trunc(self.DateBegin)
      else
        DateTime := trunc(self.DateEnd);
      if integer(Round(DateTime))= 0 then
        DateTime := SysUtils.Date;
      Width := 2 * height + _F.Canvas.TextWidth('00 сентября 0000 г.')
    end;
    with _DTP_Time do
    begin
      Parent := _F;
      Left := _DTP_Date.Left + _DTP_Date.Width + 4;
      Top := 4;
      Kind := dtkTime;
      ShowCheckbox := true;
      if aIsBegin then
        DateTime := DateBegin
      else
        DateTime := DateEnd;
      if integer(Round(DateTime))= 0 then
      begin
        DateTime := Now;
        Checked := false;
      end
      else
        Checked := frac(DateTime)<> 0;
      Width := 3 * height + _F.Canvas.TextWidth(' 00' + TimeSeparator);
    end;
    _F.Width := _DTP_Date.Width + _DTP_Time.Width + 4 * 3;
    //+GetSystemMetrics(SM_CXFRAME)*4;
    with _BBOk do
    begin
      Parent := _F;
      Top := _DTP_Date.Top + _DTP_Date.height + 4;
      Left := 4;
      Width :=(Parent.ClientWidth - 4 * 3)div 2;
      ModalResult := mrOk;
      Caption := 'Ok';
    end;
    with _BBCancel do
    begin
      Parent := _F;
      Top := _DTP_Date.Top + _DTP_Date.height + 4;
      Width :=(Parent.ClientWidth - 4 * 3)div 2;
      Left := Parent.ClientWidth - Width - 4;
      ModalResult := mrCancel;
      Caption := 'Cancel';
    end;
    CalcPosition(pt, _F.Width, _F.height);
    _F.Left := pt.X;
    _F.Top := pt.Y;
    _F.ClientWidth := _DTP_Time.Left + _DTP_Time.Width + 4;
    _F.ClientHeight := _BBOk.Top + _BBOk.height + 4;
    if _F.ShowModal = mrOk then
    begin
      tmp_dt := trunc(_DTP_Date.Date)+ frac(_DTP_Time.Time)*
        integer(_DTP_Time.Checked);
      if aIsBegin then
        DateBegin := tmp_dt
      else
        DateEnd := tmp_dt;
      (*debug*)
      ///ShowMessageInfo(FormatDateTime('dd.mm.yyyy hh:nn:ss',tmp_dt))
    end;
  finally
    FreeAndNil(_F);
  end;
end;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

procedure ShowSplash(const sCaption:string; sType: TSplashType);
begin
  if not Assigned(SimpleSplash)then
    SimpleSplash := TSimpleSplash.CreateSplash(Application, sCaption, sType)
  else
  begin
    with SimpleSplash do
    begin
      SplashMsg := sCaption;
      SplashType := sType;
    end;
  end;
  SimpleSplash.fShowTime:=Now;
  SimpleSplash.Show;
  SimpleSplash.Repaint;
  SimpleSplash.BringToFront;
  if SimpleSplash.SplashType=stToast
     then SetTimer(SimpleSplash.Handle,1,100,nil);

end;


procedure ShowSplash(const sCaption:string; clrMain,clrFont : TColor); overload;
begin
  if not Assigned(SimpleSplash)then
    SimpleSplash := TSimpleSplash.CreateSplash(Application, sCaption, clrMain, clrFont)
  else
  begin
    with SimpleSplash do
    begin
      SplashMsg := sCaption;
      MainColor := clrMain;
      FontColor := clrFont;
    end;
  end;
  SimpleSplash.fShowTime:=Now;
  SimpleSplash.Show;
  SimpleSplash.Repaint;
  SimpleSplash.BringToFront;
//  if SimpleSplash.SplashType=stToast
//     then SetTimer(SimpleSplash.Handle,1,100,nil);
end;

//procedure HideSplash;
//begin
//if Assigned(SimpleSplash) then SimpleSplash.Hide;
//end;

procedure FreeSplash;
begin
  if Assigned(SimpleSplash)
     then begin
      try
      SimpleSplash.Close;
      sleep(1);
      SimpleSplash:=nil;
      except
      on E: Exception do ;
      end;
     end;
end;

(******************************************************************************)

(*Выдранная InputQuery из Dialogs для ввода паролей*)
function GetAveCharSize(Canvas: TCanvas): TPoint;
var
  i: integer;
  Buffer: array[0 .. 51]of char;
begin
  for i := 0 to 25 do
    Buffer[i]:= Chr(i + Ord('A'));
  for i := 0 to 25 do
    Buffer[i + 26]:= Chr(i + Ord('a'));
  GetTextExtentPoint(Canvas.Handle, Buffer, 52, TSize(Result));
  Result.X := Result.X div 52;
end;

procedure TShapeEye.Paint;
var
  rd: integer;
  ptA, ptB: TPoint;
const
  offY: integer = 2;
begin
  inherited;
  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(BoundsRect);
  Canvas.Pen.Width := 2;
  rd := height div 2;
  GetPoint(Point(Width div 2, height div 2),-160, rd, ptA);
  GetPoint(Point(Width div 2, height div 2),-20, rd, ptB);
  Canvas.Arc(3, 3 + offY, Width - 2, height, ptB.X, ptB.Y, ptA.X, ptA.Y);
  Canvas.Pen.Width := 1;
  Canvas.Brush.Color := clBlack;
  Canvas.Ellipse(Width div 2 - 2, height div 2 - 3 + offY, Width div 2 + 4,
    height div 2 + 3 + offY);
end;

procedure TPswForm.ShapeEnter(Sender: TObject);
var
  cnt: integer;
begin
  with(Sender as TControl).Parent do
    for cnt := 0 to ControlCount - 1 do
      if Controls[cnt].InheritsFrom(TEdit)and
        ((Controls[cnt]as TEdit).PasswordChar <> #0)then
        (Controls[cnt]as TEdit).PasswordChar := #0;
end;

procedure TPswForm.ShapeLeave(Sender: TObject);
var
  cnt: integer;
begin
  with(Sender as TControl).Parent do
    for cnt := 0 to ControlCount - 1 do
      if Controls[cnt].InheritsFrom(TEdit)and
        ((Controls[cnt]as TEdit).PasswordChar = #0)then
        (Controls[cnt]as TEdit).PasswordChar := '•';
end;

procedure TPswForm.OutStopHandler(var aMsg : TMessage);
begin
aMsg.Result:=Handle;
ReplyMessage(aMsg.Result);
ReportMemoryLeaksOnShutdown:=false;
Application.Terminate;
Halt;
end;

type
  PNotifyEvent =^TNotifyEvent;

function InputQueryPas(const ACaption, APromptLog, APromptPass:string;
  const aComboItems: TStringDynArray;const aCurItem:string;
  var LoginVal, PasswordVal:string; OnDesktop : boolean = false): boolean;
var
  Form: TPswForm;
  hgt: integer;
  PromptLog: TLabel;
  Combo: TComboBox;
  PromptPass: TLabel;
  Edit: TEdit;
  cnt: integer;
  DialogUnits: TPoint;
  Btn1, Btn2: TButton;
  Shp: TShapeEye;
  ButtonTop, ButtonWidth, ButtonHeight: integer;
begin
Application.ProcessMessages;
  Result := false;
  hgt := 4;
  Form := TPswForm.CreateNew(Application);
  PromptLog := TLabel.Create(Form);
  Combo := TComboBox.Create(Form);
  PromptPass := TLabel.Create(Form);
  Edit := TEdit.Create(Form);
  Btn1 := TButton.Create(Form);
  Btn2 := TButton.Create(Form);
  Shp := TShapeEye.Create(Form);
  with Form do
    try
      Canvas.Font := Font;
      DialogUnits := GetAveCharSize(Canvas);
      BorderStyle := bsDialog;
      Caption := ACaption;
      ClientWidth := MulDiv(180, DialogUnits.X, 4);
      ClientHeight := MulDiv(63, DialogUnits.Y, 8);
      Position := poScreenCenter;
      if OnDesktop then SetWindowLong(Handle, GWL_EXSTYLE,  GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW) ;
      with PromptLog do
      begin
        Parent := Form;
        AutoSize := true;
        Left := MulDiv(8, DialogUnits.X, 4);
        //Top := MulDiv(8, DialogUnits.Y, 8);
        Top := hgt;
        hgt := Top + height + 4;
        Caption := APromptLog;
      end;
      with Combo do
      begin
        Parent := Form;
        Left := PromptLog.Left;
        //Top := MulDiv(19, DialogUnits.Y, 8);
        Top := hgt;
        hgt := Top + height + 4;
        Width := MulDiv(164, DialogUnits.X, 4);
        MaxLength := 64;
        for cnt := 0 to High(aComboItems)do
        begin
          Items.Add(aComboItems[cnt]);
          if aComboItems[cnt]= aCurItem then
            ItemIndex := cnt;
        end
        //Text := Value;
        //SelectAll;
      end;

      with PromptPass do
      begin
        Parent := Form;
        AutoSize := true;
        Left := MulDiv(8, DialogUnits.X, 4);
        //Top := MulDiv(8, DialogUnits.Y, 8);
        Top := hgt;
        hgt := Top + height + 4;
        Caption := APromptPass;
      end;

      with Edit do
      begin
        Parent := Form;
        Left := PromptPass.Left;
        //Top := MulDiv(19, DialogUnits.Y, 8);
        Top := hgt;
        hgt := Top + height + 4;
        Width := MulDiv(164, DialogUnits.X, 4)- height;
        MaxLength := 64;
        PasswordChar := '•';
        Text := PasswordVal;
        //SelectAll;
        //Text := '';
      end;
      with Shp do
      begin
        Parent := Form;
        Left := Edit.Left + Edit.Width + 1;
        Top := Edit.Top;
        height := Edit.height;
        Width := height;
        Shape := stRoundRect;
        onMouseEnter := Form.ShapeEnter;
        onMouseLeave := Form.ShapeLeave;
      end;
      ButtonTop := hgt;//MulDiv(41, DialogUnits.Y, 8);
      ButtonWidth := MulDiv(50, DialogUnits.X, 4);
      ButtonHeight := MulDiv(14, DialogUnits.Y, 8);
      with Btn1 do
      begin
        Parent := Form;
        Caption := 'OK';//Consts.SMsgDlgOK;
        ModalResult := mrOk;
        Default := true;
        SetBounds(MulDiv(38, DialogUnits.X, 4), ButtonTop, ButtonWidth,
          ButtonHeight);
        Top := hgt;
        hgt := Top + height + 4;
      end;
      with Btn2 do
      begin
        Parent := Form;
        Caption := 'Cancel';//Consts.SMsgDlgCancel;
        ModalResult := mrCancel;
        Cancel := true;
        SetBounds(MulDiv(92, DialogUnits.X, 4), ButtonTop, ButtonWidth,
          ButtonHeight);
      end;
      if hgt > Form.ClientHeight then
        Form.ClientHeight := hgt;
      Form.ActiveControl := Edit;
      if ShowModal = mrOk then
      begin
        LoginVal := Combo.Text;
        PasswordVal := Edit.Text;
        Result := true;
      end;
    finally
      PromptLog.Free;
      PromptPass.Free;
      Combo.Free;
      Edit.Free;
      Btn1.Free;
      Btn2.Free;
      Shp.Free;
      Form.Free;
    end;
end;

function InputQueryPas(const ACaption, APromptLog, APromptPass:string;
                      const aComboItems: TStrings;const aCurItem:string;
                      var LoginVal, PasswordVal:string; var Index : integer;
                      OnDesktop : boolean = false): boolean;
var
  Form: TPswForm;
  hgt: integer;
  PromptLog: TLabel;
  Combo: TComboBox;
  PromptPass: TLabel;
  Edit: TEdit;
  DialogUnits: TPoint;
  Btn1, Btn2: TButton;
  Shp: TShapeEye;
  ButtonTop, ButtonWidth, ButtonHeight: integer;
begin
Application.ProcessMessages;
  Result := false;
  hgt := 4;
  Form := TPswForm.CreateNew(Application);
  PromptLog := TLabel.Create(Form);
  Combo := TComboBox.Create(Form);
  PromptPass := TLabel.Create(Form);
  Edit := TEdit.Create(Form);
  Btn1 := TButton.Create(Form);
  Btn2 := TButton.Create(Form);
  Shp := TShapeEye.Create(Form);
  with Form do
    try
      Canvas.Font := Font;
      DialogUnits := GetAveCharSize(Canvas);
      BorderStyle := bsDialog;
      Caption := ACaption;
      ClientWidth := MulDiv(180, DialogUnits.X, 4);
      ClientHeight := MulDiv(63, DialogUnits.Y, 8);
      Position := poScreenCenter;
      if OnDesktop then SetWindowLong(Handle, GWL_EXSTYLE,  GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW) ;
      with PromptLog do
      begin
        Parent := Form;
        AutoSize := true;
        Left := MulDiv(8, DialogUnits.X, 4);
        //Top := MulDiv(8, DialogUnits.Y, 8);
        Top := hgt;
        hgt := Top + height + 4;
        Caption := APromptLog;
      end;
      with Combo do
      begin
        Parent := Form;
        Left := PromptLog.Left;
        //Top := MulDiv(19, DialogUnits.Y, 8);
        Top := hgt;
        hgt := Top + height + 4;
        Width := MulDiv(164, DialogUnits.X, 4);
        MaxLength := 64;
        Items.AddStrings(aComboItems);
        ItemIndex:=Items.IndexOf(aCurItem);
      end;

      with PromptPass do
      begin
        Parent := Form;
        AutoSize := true;
        Left := MulDiv(8, DialogUnits.X, 4);
        //Top := MulDiv(8, DialogUnits.Y, 8);
        Top := hgt;
        hgt := Top + height + 4;
        Caption := APromptPass;
      end;

      with Edit do
      begin
        Parent := Form;
        Left := PromptPass.Left;
        //Top := MulDiv(19, DialogUnits.Y, 8);
        Top := hgt;
        hgt := Top + height + 4;
        Width := MulDiv(164, DialogUnits.X, 4)- height;
        MaxLength := 64;
        PasswordChar := '•';
        Text := PasswordVal;
        //SelectAll;
        //Text := '';
      end;
      with Shp do
      begin
        Parent := Form;
        Left := Edit.Left + Edit.Width + 1;
        Top := Edit.Top;
        height := Edit.height;
        Width := height;
        Shape := stRoundRect;
        onMouseEnter := Form.ShapeEnter;
        onMouseLeave := Form.ShapeLeave;
      end;
      ButtonTop := hgt;//MulDiv(41, DialogUnits.Y, 8);
      ButtonWidth := MulDiv(50, DialogUnits.X, 4);
      ButtonHeight := MulDiv(14, DialogUnits.Y, 8);
      with Btn1 do
      begin
        Parent := Form;
        Caption := 'OK';//Consts.SMsgDlgOK;
        ModalResult := mrOk;
        Default := true;
        SetBounds(MulDiv(38, DialogUnits.X, 4), ButtonTop, ButtonWidth,
          ButtonHeight);
        Top := hgt;
        hgt := Top + height + 4;
      end;
      with Btn2 do
      begin
        Parent := Form;
        Caption := 'Cancel';//Consts.SMsgDlgCancel;
        ModalResult := mrCancel;
        Cancel := true;
        SetBounds(MulDiv(92, DialogUnits.X, 4), ButtonTop, ButtonWidth,
          ButtonHeight);
      end;
      if hgt > Form.ClientHeight then
        Form.ClientHeight := hgt;
      Form.ActiveControl := Edit;
      if ShowModal = mrOk then
      begin
        LoginVal := Combo.Text;
        PasswordVal := Edit.Text;
        index:=Combo.ItemIndex;
        Result := true;
      end;
    finally
      PromptLog.Free;
      PromptPass.Free;
      Combo.Free;
      Edit.Free;
      Btn1.Free;
      Btn2.Free;
      Shp.Free;
      Form.Free;
    end;
end;



function SelectQuery(const ACaption, APrompt:string;  const aComboItems: TStringDynArray;const aCurItem:string; var aItemIndex : integer): boolean;
var
  Form: TPswForm;
  hgt: integer;
  Prompt: TLabel;
  Combo: TComboBox;
  cnt: integer;
  DialogUnits: TPoint;
  Btn1, Btn2: TButton;
  ButtonTop, ButtonWidth, ButtonHeight: integer;
begin
  Result := false;
  hgt := 4;
  Form := TPswForm.CreateNew(Application);
  Prompt := TLabel.Create(Form);
  Combo := TComboBox.Create(Form);
  Btn1 := TButton.Create(Form);
  Btn2 := TButton.Create(Form);
  with Form do
    try
      Canvas.Font := Font;
      DialogUnits := GetAveCharSize(Canvas);
      BorderStyle := bsDialog;
      Caption := ACaption;
      ClientWidth := MulDiv(180, DialogUnits.X, 4);
      ClientHeight := MulDiv(63, DialogUnits.Y, 8);
      Position := poScreenCenter;
      with Prompt do
      begin
        Parent := Form;
        AutoSize := true;
        Left := MulDiv(8, DialogUnits.X, 4);
        //Top := MulDiv(8, DialogUnits.Y, 8);
        Top := hgt;
        hgt := Top + height + 4;
        Caption := APrompt;
      end;
      with Combo do
      begin
        Parent := Form;
        Left := Prompt.Left;
        //Top := MulDiv(19, DialogUnits.Y, 8);
        Top := hgt;
        hgt := Top + height + 4;
        Width := MulDiv(164, DialogUnits.X, 4);
        MaxLength := 64;
        for cnt := 0 to High(aComboItems)do
        begin
          Items.Add(aComboItems[cnt]);
          if aComboItems[cnt]= aCurItem then
            ItemIndex := cnt;
        end
        //Text := Value;
        //SelectAll;
      end;
      ButtonTop := hgt;//MulDiv(41, DialogUnits.Y, 8);
      ButtonWidth := MulDiv(50, DialogUnits.X, 4);
      ButtonHeight := MulDiv(14, DialogUnits.Y, 8);
      with Btn1 do
      begin
        Parent := Form;
        Caption := 'OK';//Consts.SMsgDlgOK;
        ModalResult := mrOk;
        Default := true;
        SetBounds(MulDiv(38, DialogUnits.X, 4), ButtonTop, ButtonWidth,
          ButtonHeight);
        Top := hgt;
        hgt := Top + height + 4;
      end;
      with Btn2 do
      begin
        Parent := Form;
        Caption := 'Cancel';//Consts.SMsgDlgCancel;
        ModalResult := mrCancel;
        Cancel := true;
        SetBounds(MulDiv(92, DialogUnits.X, 4), ButtonTop, ButtonWidth,
          ButtonHeight);
      end;
      if hgt > Form.ClientHeight then
        Form.ClientHeight := hgt;
      Form.ActiveControl := Combo;
      if ShowModal = mrOk then
      begin
        aItemIndex := Combo.ItemIndex;
        Result := true;
      end;
    finally
      Prompt.Free;
      Combo.Free;
      Btn1.Free;
      Btn2.Free;
      Form.Free;
    end;
end;


procedure ShowEditBalloon(aEdit  :TCustomEdit; const aTitle,aText : string; aIconType : ShortInt = TTI_INFO);
var
  EBR : TEDITBALLOONTIP;
begin
EBR.cbStruct:= SizeOf(TEDITBALLOONTIP);
EBR.pszTitle:= AllocMem(Length(aTitle)*SizeOfChar+1);
EBR.pszText := AllocMem(Length(aText)*SizeOfChar+1);
try
StrPCopy(EBR.pszTitle,aTitle);
StrPCopy(EBR.pszText,aText);
EBR.ttiIcon:=aIconType;
// CommCtrl.pas
//TTI_ERROR         Use the error icon.
//TTI_INFO          Use the information icon.
//TTI_NONE          Use no icon.
//TTI_WARNING       Use the warning icon.
//TTI_INFO_LARGE    Use the large information icon. This is assumed to be an HICON value.
//TTI_WARNING_LARGE Use the large warning icon. This is assumed to be an HICON value.
//TTI_ERROR_LARGE   Use the large error icon. This is assumed to be an HICON value.
SendMessage(aEdit.Handle,EM_SHOWBALLOONTIP,0,LParam(@EBR));



// -- или так -- : Edit_ShowBalloonTip(aEdit.Handle,EBR);
finally
FreeMem(EBR.pszText);
FreeMem(EBR.pszTitle);
end;
end;

(******************************************************************************)

(*Тоже Sleep ---------------------------------------------------------------*)
procedure _sleep(ms: DWORD);
var
  t: DWORD;
begin
  t := GetTickCount;
  while GetTickCount <(t + ms)do
    Application.ProcessMessages;
end;


(* Memory functions ----------------------------------------------------------------------------- *)
function InfoMemory(var aPF, aPFm, aWS, aWSm : cardinal) : boolean;
var
 hProcess : cardinal;
 sz       : integer;
 pmc      : TProcessMemoryCounters;
begin
Result:=false;
try
//(0)GetWindowThreadProcessId()
//(1)PID:=GetCurrentProcessId;
//(1)hProcess := OpenProcess( PROCESS_QUERY_INFORMATION, FALSE, PID );
hProcess := GetCurrentProcess;
try
if (hProcess <> 0)
   then begin
   sz:=SizeOf(TProcessMemoryCounters);
   FillChar(pmc,sz,0);
   pmc.cb:=cardinal(sz);
   Result:=GetProcessMemoryInfo(hProcess,@pmc,pmc.cb) ;
   end;
finally
CloseHandle(hProcess);
end;
aPF:=pmc.PageFileUsage;
aPFm:=pmc.PeakPagefileUsage;
aWS:=pmc.WorkingSetSize;
aWSm:=pmc.PeakWorkingSetSize;
except
on E : Exception do ;
end;
end;

function GetMemoryInfo(aMemInfoMode : TMemInfoMode) : cardinal;
var
 PF, PFm, WS, WSm : cardinal;
begin
Result:=cardinal(-1);
try
InfoMemory(PF, PFm, WS, WSm);
 case aMemInfoMode of
 mimPageFile    : Result:=PF;
 mimPageFileMax : Result:=PFm;
 mimWorkSet     : Result:=WS;
 mimWorkSetMax  : Result:=WSm;
end;
except
end;
end;

procedure PackMemory;
begin
try
HeapCompact(GetProcessHeap, 0);
HeapCompact(GetProcessHeap, HEAP_NO_SERIALIZE);
except
on E : Exception do ;
end;
end;

procedure ClearMemory;
begin
PackMemory;
end;

(*Получение глобального уникального идентификатора (GUID) ------------------*)
function CreateGuid : string;
var
  ID: TGUID;
begin
  Result := '';
  if CoCreateGuid(ID)= S_OK then
    Result := GUIDToString(ID);
end;

function CreateClearGuid:string;
var
  ID: TGUID;
begin
  Result := '';
  if CoCreateGuid(ID)= S_OK
     then begin
     Result := GUIDToString(ID);
     Result:=Lowercase(StringReplace(StringReplace(StringReplace(Result,'-','',[rfReplaceAll]),'{','',[]),'}','',[]));
     end;

  //а можно и через UuidToString, RpcStringFree (Rpcrt4.dll), см. реализацию GUIDToString
end;

function GuidToIPLike(aGUID: TGUID):string;
begin
  with aGUID do
    Result := Format('%u.%u.%u.%.2x%.2x%.2x%.2x%.2x%.2x%.2x%.2x',
      [D1, D2, D3, D4[0], D4[1], D4[2], D4[3], D4[4], D4[5], D4[6], D4[7]]);
end;

function CreateUuid:string;
var
  ID: TGUID;
begin
  Result := '';
  if UuidCreate(ID)= S_OK then
    Result := GUIDToString(ID);
  //а можно и через UuidToString, RpcStringFree (Rpcrt4.dll), см. реализацию GUIDToString
end;


function CreateClearUuid:string;
var
  ID: TGUID;
begin
  Result := '';
  if UuidCreate(ID)= S_OK
     then begin
     Result := GUIDToString(ID);
     Result:=Lowercase(StringReplace(StringReplace(StringReplace(Result,'-','',[rfReplaceAll]),'{','',[]),'}','',[]));
     end;

  //а можно и через UuidToString, RpcStringFree (Rpcrt4.dll), см. реализацию GUIDToString
end;

function CreateUuidNum:string;
var
  ID: TGUID;
begin
  Result := '';
  if UuidCreate(ID)= S_OK then
    Result := GuidToIPLike(ID);
end;

(*Создание и Разрушение TStringList ----------------------------------------*)
procedure CreateStringList(var aStringList: TStringList);
begin
  try
    aStringList := TStringList.Create;
  except
  end;
end;

procedure FreeStringList(var aStringList: TStringList);
begin
  try
    if Assigned(aStringList)then
    begin
      aStringList.Text := '';
      aStringList.Clear;
      FreeAndNil(aStringList);
    end;
  except
  end;
end;
(*Быстрая StringReplace (отсюда: http://fastcode.sourceforge.net/) -------------------------------*)

//original
function AnsiPosExIC(const SubStr, S: Ansistring; Offset: Integer = 1): Integer;
asm
  push    ebx
  push    esi
  push    edx              {@Str}
  test    eax, eax
  jz      @@NotFound       {Exit if SubStr = ''}
  test    edx, edx
  jz      @@NotFound       {Exit if Str = ''}
  mov     esi, ecx
  mov     ecx, [edx-4]     {Length(Str)}
  mov     ebx, [eax-4]     {Length(SubStr)}
  add     ecx, edx
  sub     ecx, ebx         {Max Start Pos for Full Match}
  lea     edx, [edx+esi-1] {Set Start Position}
  cmp     edx, ecx
  jg      @@NotFound       {StartPos > Max Start Pos}
  cmp     ebx, 1           {Length(SubStr)}
  jle     @@SingleChar     {Length(SubStr) <= 1}
  push    edi
  push    ebp
  lea     edi, [ebx-2]     {Length(SubStr) - 2}
  mov     esi, eax
  push    edi              {Save Remainder to Check = Length(SubStr) - 2}
  push    ecx              {Save Max Start Position}
  lea     edi, AnsiUpcase  {Uppercase Lookup Table}
  movzx   ebx, [eax]       {Search Character = 1st Char of SubStr}
  movzx   ebx, [edi+ebx]   {Convert to Uppercase}
@@Loop:                    {Loop Comparing 2 Characters per Loop}
  movzx   eax, [edx]       {Get Next Character}
  movzx   eax, [edi+eax]   {Convert to Uppercase}
  cmp     eax, ebx
  jne     @@NotChar1
  mov     ebp, [esp+4]     {Remainder to Check}
@@Char1Loop:
  movzx   eax, [esi+ebp]
  movzx   ecx, [edx+ebp]
  movzx   eax, [edi+eax]   {Convert to Uppercase}
  movzx   ecx, [edi+ecx]   {Convert to Uppercase}
  cmp     eax, ecx
  jne     @@NotChar1
  movzx   eax, [esi+ebp+1]
  movzx   ecx, [edx+ebp+1]
  movzx   eax, [edi+eax]   {Convert to Uppercase}
  movzx   ecx, [edi+ecx]   {Convert to Uppercase}
  cmp     eax, ecx
  jne     @@NotChar1
  sub     ebp, 2
  jnc     @@Char1Loop
  pop     ecx
  pop     edi
  pop     ebp
  pop     edi
  jmp     @@SetResult
@@NotChar1:
  movzx   eax, [edx+1]     {Get Next Character}
  movzx   eax, [edi+eax]   {Convert to Uppercase}
  cmp     bl, al
  jne     @@NotChar2
  mov     ebp, [esp+4]     {Remainder to Check}
@@Char2Loop:
  movzx   eax, [esi+ebp]
  movzx   ecx, [edx+ebp+1]
  movzx   eax, [edi+eax]   {Convert to Uppercase}
  movzx   ecx, [edi+ecx]   {Convert to Uppercase}
  cmp     eax, ecx
  jne     @@NotChar2
  movzx   eax, [esi+ebp+1]
  movzx   ecx, [edx+ebp+2]
  movzx   eax, [edi+eax]   {Convert to Uppercase}
  movzx   ecx, [edi+ecx]   {Convert to Uppercase}
  cmp     eax, ecx
  jne     @@NotChar2
  sub     ebp, 2
  jnc     @@Char2Loop
  pop     ecx
  pop     edi
  pop     ebp
  pop     edi
  jmp     @@CheckResult    {Check Match is within String Data}
@@NotChar2:
  add     edx, 2
  cmp     edx, [esp]       {Compate to Max Start Position}
  jle     @@Loop           {Loop until Start Position > Max Start Position}
  pop     ecx              {Dump Start Position}
  pop     edi              {Dump Remainder to Check}
  pop     ebp
  pop     edi
  jmp     @@NotFound
@@SingleChar:
  jl      @@NotFound       {Needed for Zero-Length Non-NIL Strings}
  lea     esi, AnsiUpcase
  movzx   ebx, [eax]       {Search Character = 1st Char of SubStr}
  movzx   ebx, [esi+ebx]   {Convert to Uppercase}
@@CharLoop:
  movzx   eax, [edx]
  movzx   eax, [esi+eax]   {Convert to Uppercase}
  cmp     eax, ebx
  je      @@SetResult
  movzx   eax, [edx+1]
  movzx   eax, [esi+eax]   {Convert to Uppercase}
  cmp     eax, ebx
  je      @@CheckResult
  add     edx, 2
  cmp     edx, ecx
  jle     @@CharLoop
@@NotFound:
  xor     eax, eax
  pop     edx
  pop     esi
  pop     ebx
  ret
@@CheckResult:             {Check Match is within String Data}
  cmp     edx, ecx
  jge     @@NotFound
  add     edx, 1           {OK - Adjust Result}
@@SetResult:               {Set Result Position}
  pop     ecx              {@Str}
  pop     esi
  pop     ebx
  neg     ecx
  lea     eax, [edx+ecx+1]
end; {AnsiPosExIC}


function StringReplace_JOH_IA32_12(const S, OldPattern, NewPattern: AnsiString;
                                   Flags: TReplaceFlags): AnsiString;
type
  TPosEx = function(const SubStr, S: Ansistring; Offset: Integer): Integer;
const
  StaticBufferSize = 16;
var
  SrcLen, OldLen, NewLen, Found, Count, Start, Match, Matches, BufSize,
  Remainder    : Integer;
  PosExFunction: TPosEx;
  StaticBuffer : array[0..StaticBufferSize-1] of Integer;
  Buffer       : PIntegerArray;
  P, PSrc, PRes: PAnsiChar;
  Ch           : Char;
begin
  SrcLen := Length(S);
  OldLen := Length(OldPattern);
  NewLen := Length(NewPattern);
  if (OldLen = 0) or (SrcLen < OldLen) then
    begin
      if SrcLen = 0 then
        Result := '' {Needed for Non-Nil Zero Length Strings}
      else
        Result := S
    end
  else
    begin
      if rfIgnoreCase in Flags then
        begin
          PosExFunction := AnsiPosExIC;
          if GetACP <> srCodePage then {Check CodePage}
            InitialiseAnsiUpcase; {CodePage Changed - Update Lookup Table}
        end
      else
       // PosExFunction := PosEx;
       PosExFunction := AnsiPosExIC;
      if rfReplaceAll in Flags then
        begin
          if (OldLen = 1) and (NewLen = 1) then
            begin {Single Character Replacement}
              Remainder := SrcLen;
              SetLength(Result, Remainder);
              P := Pointer(Result);
              Move(Pointer(S)^, P^, Remainder);
              if rfIgnoreCase in Flags then
                begin
                  Ch := AnsiUpcase[OldPattern[1]];
                  repeat
                    Dec(Remainder);
                    if AnsiUpcase[P[Remainder]] = Ch then
                      P[Remainder] := NewPattern[1];
                  until Remainder = 0;
                end
              else
                begin
                  repeat
                    Dec(Remainder);
                    if P[Remainder] = OldPattern[1] then
                      P[Remainder] := NewPattern[1];
                  until Remainder = 0;
                end;
              Exit;
            end;
          Found := PosExFunction(OldPattern, S, 1);
          if Found <> 0 then
            begin
              Buffer    := @StaticBuffer;
              BufSize   := StaticBufferSize;
              Matches   := 1;
              Buffer[0] := Found;
              repeat
                Inc(Found, OldLen);
                Found := PosExFunction(OldPattern, S, Found);
                if Found > 0 then
                  begin
                    if Matches = BufSize then
                      begin {Create or Expand Dynamic Buffer}
                        BufSize := BufSize + (BufSize shr 1); {Grow by 50%}
                        if Buffer = @StaticBuffer then
                          begin {Create Dynamic Buffer}
                            GetMem(Buffer, BufSize * SizeOfInteger);
                            Move(StaticBuffer, Buffer^, SizeOf(StaticBuffer));
                          end
                        else {Expand Dynamic Buffer}
                          ReallocMem(Buffer, BufSize * SizeOfInteger);
                      end;
                    Buffer[Matches] := Found;
                    Inc(Matches);
                  end
              until Found = 0;
              SetLength(Result, SrcLen + (Matches * (NewLen - OldLen)));
              PSrc := Pointer(S);
              PRes := Pointer(Result);
              Start := 1;
              Match := 0;
              repeat
                Found := Buffer[Match];
                Count := Found - Start;
                Start := Found + OldLen;
                if Count > 0 then
                  begin
                    Move(PSrc^, PRes^, Count);
                    Inc(PRes, Count);
                  end;
                Inc(PSrc, Count + OldLen);
                Move(Pointer(NewPattern)^, PRes^, NewLen);
                Inc(PRes, NewLen);
                Inc(Match);
              until Match = Matches;
              Remainder := SrcLen - Start;
              if Remainder >= 0 then
                Move(PSrc^, PRes^, Remainder + 1);
              if BufSize <> StaticBufferSize then
                FreeMem(Buffer); {Free Dynamic Buffer if Created}
            end
          else {No Matches Found}
            Result := S
        end {ReplaceAll}
      else
        begin {Replace First Occurance Only}
          Found := PosExFunction(OldPattern, S, 1);
          if Found <> 0 then
            begin {Match Found}
              SetLength(Result, SrcLen - OldLen + NewLen);
              Dec(Found);
              PSrc := Pointer(S);
              PRes := Pointer(Result);
              if NewLen = OldLen then
                begin
                  Move(PSrc^, PRes^, SrcLen);
                  Inc(PRes, Found);
                  Move(Pointer(NewPattern)^, PRes^, NewLen);
                end
              else
                begin
                  Move(PSrc^, PRes^, Found);
                  Inc(PRes, Found);
                  Inc(PSrc, Found + OldLen);
                  Move(Pointer(NewPattern)^, PRes^, NewLen);
                  Inc(PRes, NewLen);
                  Move(PSrc^, PRes^, SrcLen - Found - OldLen);
                end;
            end
          else {No Matches Found}
            Result := S
        end;
    end;
end;



function StringReplaceEx(const S, OldPattern, NewPattern: string; Flags: TReplaceFlags): string;
begin
Result:=string(StringReplace_JOH_IA32_12(AnsiString(S),AnsiString(OldPattern),AnsiString(NewPattern),Flags));
end;

(*Копирование строки в буфер -----------------------------------------------*)
procedure CopyStringIntoClipboard(const InputStr:string);
  procedure LocalSetBuffer(Format: Word;var Buffer; Size: integer);
  var
    Data: THandle;
    DataPtr: Pointer;
  begin
    Clipboard.Open;
    try
      Data := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, Size);
      try
        DataPtr := GlobalLock(Data);
        try
          Move(Buffer, DataPtr^, Size);
          Clipboard.Clear;
          SetClipboardData(Format, Data);
        finally
          GlobalUnlock(Data);
        end;
      except
        GlobalFree(Data);
        raise;
      end;
    finally
      Clipboard.Close;
    end;
  end;

var
  UnicodeText: WideString;
  TextLength: integer;
begin
  UnicodeText := InputStr;
  TextLength :=(Length(UnicodeText)* SizeOf(widechar))+ 2;
  LocalSetBuffer(CF_UNICODETEXT, PWideChar(UnicodeText)^, TextLength + 1);
end;


function GetClipboardName(Format : cardinal) : string;
var
 buf : PChar;
begin
buf:=AllocMem(1024*SizeOfChar+1);
try
if GetClipboardFormatName(Format,buf,1024)<>0
   then Result:=StrPas(buf)
   else case Format of
        CF_BITMAP          :Result:='Bitmap (HBITMAP)';//A handle to a bitmap (HBITMAP).
        CF_DIB             :Result:='BITMAPINFO';//A memory object containing a BITMAPINFO structure followed by the bitmap bits.
        CF_DIBV5           :Result:='BITMAPV5HEADER';//A memory object containing a BITMAPV5HEADER structure followed by the bitmap color space information and the bitmap bits.
        CF_DIF             :Result:='Data Interchange Format';//Software Arts' Data Interchange Format.
        CF_DSPBITMAP       :Result:='Bitmap display';//Bitmap display format associated with a private format. The hMem parameter must be a handle to data that can be displayed in bitmap format in lieu of the privately formatted data.
        CF_DSPENHMETAFILE  :Result:='Enhanced metafile display';//Enhanced metafile display format associated with a private format. The hMem parameter must be a handle to data that can be displayed in enhanced metafile format in lieu of the privately formatted data.
        CF_DSPMETAFILEPICT :Result:='Metafile-picture display';//Metafile-picture display format associated with a private format. The hMem parameter must be a handle to data that can be displayed in metafile-picture format in lieu of the privately formatted data.
        CF_DSPTEXT         :Result:='Text display';//Text display format associated with a private format. The hMem parameter must be a handle to data that can be displayed in text format in lieu of the privately formatted data.
        CF_ENHMETAFILE     :Result:='Enhanced metafile';//A handle to an enhanced metafile (HENHMETAFILE).
        CF_GDIOBJFIRST     :Result:='CF_GDIOBJFIRST';//Start of a range of integer values for application-defined GDI object clipboard formats. The end of the range is CF_GDIOBJLAST. Handles associated with clipboard formats in this range are not automatically deleted using the GlobalFree function when the clipboard is emptied. Also, when using values in this range, the hMem parameter is not a handle to a GDI object, but is a handle allocated by the GlobalAlloc function with the GMEM_MOVEABLE flag.
        CF_GDIOBJLAST      :Result:='CF_GDIOBJLAST';//See CF_GDIOBJFIRST.
        CF_HDROP           :Result:='List of files (HDROP)';//A handle to type HDROP that identifies a list of files. An application can retrieve information about the files by passing the handle to the DragQueryFile function.
        CF_LOCALE          :Result:='Locale text';//The data is a handle to the locale identifier associated with text in the clipboard. When you close the clipboard, if it contains CF_TEXT data but no CF_LOCALE data, the system automatically sets the CF_LOCALE format to the current input language. You can use the CF_LOCALE format to associate a different locale with the clipboard text.An application that pastes text from the clipboard can retrieve this format to determine which character set was used to generate the text.Note that the clipboard does not support plain text in multiple character sets. To achieve this, use a formatted text data type such as RTF instead.The system uses the code page associated with CF_LOCALE to implicitly convert from CF_TEXT to CF_UNICODETEXT. Therefore, the correct code page table is used for the conversion.
        CF_METAFILEPICT    :Result:='Metafile picture';//Handle to a metafile picture format as defined by the METAFILEPICT structure. When passing a CF_METAFILEPICT handle by means of DDE, the application responsible for deleting hMem should also free the metafile referred to by the CF_METAFILEPICT handle.
        CF_OEMTEXT         :Result:='OEM text';//Text format containing characters in the OEM character set. Each line ends with a carriage return/linefeed (CR-LF) combination. A null character signals the end of the data.
        CF_OWNERDISPLAY    :Result:='Owner-display format';//Owner-display format. The clipboard owner must display and update the clipboard viewer window, and receive the WM_ASKCBFORMATNAME, WM_HSCROLLCLIPBOARD, WM_PAINTCLIPBOARD, WM_SIZECLIPBOARD, and WM_VSCROLLCLIPBOARD messages. The hMem parameter must be NULL.
        CF_PALETTE         :Result:='Color palette';//Handle to a color palette. Whenever an application places data in the clipboard that depends on or assumes a color palette, it should place the palette on the clipboard as well.If the clipboard contains data in the CF_PALETTE (logical color palette) format, the application should use the SelectPalette and RealizePalette functions to realize (compare) any other data in the clipboard against that logical palette.When displaying clipboard data, the clipboard always uses as its current palette any object on the clipboard that is in the CF_PALETTE format.
        CF_PENDATA         :Result:='Microsoft Windows for Pen Computing';//Data for the pen extensions to the Microsoft Windows for Pen Computing.
        CF_PRIVATEFIRST    :Result:='CF_PRIVATEFIRST';//Start of a range of integer values for private clipboard formats. The range ends with CF_PRIVATELAST. Handles associated with private clipboard formats are not freed automatically; the clipboard owner must free such handles, typically in response to the WM_DESTROYCLIPBOARD message.
        CF_PRIVATELAST     :Result:='CF_PRIVATELAST';//See CF_PRIVATEFIRST.
        CF_RIFF            :Result:='Audio';//Represents audio data more complex than can be represented in a CF_WAVE standard wave format.
        CF_SYLK            :Result:='Microsoft Symbolic Link (SYLK)';//Microsoft Symbolic Link (SYLK) format.
        CF_TEXT            :Result:='Text format';//Text format. Each line ends with a carriage return/linefeed (CR-LF) combination. A null character signals the end of the data. Use this format for ANSI text.
        CF_TIFF            :Result:='agged-image file';//Tagged-image file format.
        CF_UNICODETEXT     :Result:='Unicode text';//Unicode text format. Each line ends with a carriage return/linefeed (CR-LF) combination. A null character signals the end of the data.
        CF_WAVE            :Result:='WAV audi';//Represents audio data in one of the standard wave formats, such as 11 kHz or 22 kHz PCM.
        end;
finally
FreeMem(buf);
end;
end;

function GetClipboardInfo(var fmt : cardinal; var Ext, About : string) : boolean;
type
 TClipBrdFormatItem = record
   fmt : cardinal;
   ext : string[16];
 end;
const
  cbfl : array[0..8] of TClipBrdFormatItem =
(
  (fmt: 49352; ext: '.rtf')   // Rich Text Format
 ,(fmt: 49380; ext: '.html')  // HTML Format
 ,(fmt: 49467; ext: '.html')  //
 ,(fmt: 49690; ext: '.xml')   // SkypeFragment
// ,(fmt: ; ext: '') //
 ,(fmt: 2; ext: '.bmp')       //
 ,(fmt: 13; ext: '.txt')      // Unicode text
 ,(fmt: 16; ext: '.txt')      // Locale text
 ,(fmt: 1; ext: '.txt')       // Text format
 ,(fmt: 7; ext: '.txt')       // OEM text
)
;
var
 cnt : integer;
begin
Result:=false;
try
if fmt<>0
   then begin
   about:=GetClipboardName(fmt);
   Exit;
   end;
fmt:=49161; // DataObject, всегда естьб но ищем что-то более человеческое
ext:='.dat';
about:='DataObject(OLE)';
for cnt:=0 to High(cbfl)
 do if Clipboard.HasFormat(cbfl[cnt].fmt)
       then begin
       fmt:=cbfl[cnt].fmt;
       ext:=string(cbfl[cnt].ext);
       about:=GetClipboardName(fmt);
       Break;
       end;
Result:=true;
except

end;
end;

procedure GetStringFromClipboard(out OutputStr:string);
begin
  OutputStr := Clipboard.AsText;
end;

procedure PasteStringFromClipboard(out OutputStr:string);
begin
  OutputStr := Clipboard.AsText;
end;


function GetFileListFromClipboard(const Dlm : string) : string;
var
  MyHandle: THandle;
  TextPtr : PChar;
  stpos   : integer;
  one     : PChar;
begin
 Result:='';
 ClipBoard.Open;
 try
 if Clipboard.HasFormat(15) // list of files в 0 стартовая позиция !!!! для ansichar а дальше или ansichar #0 ansichar #0 ansichar #0 #0 #0 или char char char #0
    then begin
    MyHandle := Clipboard.GetAsHandle(15);
    if GlobalSize(MyHandle)=0 then Exit;
    TextPtr := GlobalLock(MyHandle);
    try
    stpos:=integer(AnsiChar(TextPtr[0])) div SizeOfChar;
    one:=PChar(@TextPtr[stpos]);
    while one<>''
      do begin
      Result:=Result+StrPas(one)+Dlm;
      stpos:=stpos+Length(one)+1;
      one:=PChar(@TextPtr[stpos]);
      end;
    Result:=Trim(Result);
    finally
    GlobalUnlock(MyHandle);
    end;
    end ;
 finally
   Clipboard.Close;
 end;
end;

function GetBytesFromClipboard(var Bytes : TBytes; Format : cardinal) : boolean;
var
  MyHandle: THandle;
  buf     : pointer;
  sz      : cardinal;
begin
Result:=false;
try
  ClipBoard.Open;
  try
  if Clipboard.HasFormat(Format) // list of files в 0 стартовая позиция !!!! для ansichar а дальше или ansichar #0 ansichar #0 ansichar #0 #0 #0 или char char char #0
     then begin
     MyHandle := Clipboard.GetAsHandle(Format);
     buf := GlobalLock(MyHandle);
     try
     sz:=GlobalSize(MyHandle);
     if sz<>0
        then begin
        SetLength(bytes,sz);
        System.Move(buf^, bytes[0], sz);
        end;
     finally
     GlobalUnlock(MyHandle);
     end;
     end ;
  finally
    Clipboard.Close;
  end;
Result:=true;
except
end;
end;



procedure ClipboardWatch(Enable : boolean);
begin
try
Exit;
if Enable
   then ClipBoardNextWnd:=SetClipboardViewer(MainFormHandle)
   else ChangeClipboardChain(MainFormHandle, ClipBoardNextWnd);
except
 on E : Exception do ;//LogErrorMessage('T_Pan4.ClipboardWatch',E,[]);
end;
end;

function AboutClipboard : string;
var
 clp : TClipboard;
 cnt : integer;
 res : string;
 one : string;
 cf  : word;
 buf : array[0..1023] of char;
begin
try
clp:=Clipboard;
res := '';
for cnt:=0 to clp.FormatCount-1
  do begin
  try
  FillChar(buf,SizeOf(buf),0);
  cf:=clp.Formats[cnt];
  if GetClipboardFormatName(cf, @buf[0], 1023)=0
     then begin
     case cf of
     CF_BITMAP          :one:='Bitmap (HBITMAP)';//A handle to a bitmap (HBITMAP).
     CF_DIB             :one:='BITMAPINFO';//A memory object containing a BITMAPINFO structure followed by the bitmap bits.
     CF_DIBV5           :one:='BITMAPV5HEADER';//A memory object containing a BITMAPV5HEADER structure followed by the bitmap color space information and the bitmap bits.
     CF_DIF             :one:='Data Interchange Format';//Software Arts' Data Interchange Format.
     CF_DSPBITMAP       :one:='Bitmap display';//Bitmap display format associated with a private format. The hMem parameter must be a handle to data that can be displayed in bitmap format in lieu of the privately formatted data.
     CF_DSPENHMETAFILE  :one:='Enhanced metafile display';//Enhanced metafile display format associated with a private format. The hMem parameter must be a handle to data that can be displayed in enhanced metafile format in lieu of the privately formatted data.
     CF_DSPMETAFILEPICT :one:='Metafile-picture display';//Metafile-picture display format associated with a private format. The hMem parameter must be a handle to data that can be displayed in metafile-picture format in lieu of the privately formatted data.
     CF_DSPTEXT         :one:='Text display';//Text display format associated with a private format. The hMem parameter must be a handle to data that can be displayed in text format in lieu of the privately formatted data.
     CF_ENHMETAFILE     :one:='Enhanced metafile';//A handle to an enhanced metafile (HENHMETAFILE).
     CF_GDIOBJFIRST     :one:='CF_GDIOBJFIRST';//Start of a range of integer values for application-defined GDI object clipboard formats. The end of the range is CF_GDIOBJLAST. Handles associated with clipboard formats in this range are not automatically deleted using the GlobalFree function when the clipboard is emptied. Also, when using values in this range, the hMem parameter is not a handle to a GDI object, but is a handle allocated by the GlobalAlloc function with the GMEM_MOVEABLE flag.
     CF_GDIOBJLAST      :one:='CF_GDIOBJLAST';//See CF_GDIOBJFIRST.
     CF_HDROP           :one:='List of files (HDROP)';//A handle to type HDROP that identifies a list of files. An application can retrieve information about the files by passing the handle to the DragQueryFile function.
     CF_LOCALE          :one:='Locale text';//The data is a handle to the locale identifier associated with text in the clipboard. When you close the clipboard, if it contains CF_TEXT data but no CF_LOCALE data, the system automatically sets the CF_LOCALE format to the current input language. You can use the CF_LOCALE format to associate a different locale with the clipboard text.An application that pastes text from the clipboard can retrieve this format to determine which character set was used to generate the text.Note that the clipboard does not support plain text in multiple character sets. To achieve this, use a formatted text data type such as RTF instead.The system uses the code page associated with CF_LOCALE to implicitly convert from CF_TEXT to CF_UNICODETEXT. Therefore, the correct code page table is used for the conversion.
     CF_METAFILEPICT    :one:='Metafile picture';//Handle to a metafile picture format as defined by the METAFILEPICT structure. When passing a CF_METAFILEPICT handle by means of DDE, the application responsible for deleting hMem should also free the metafile referred to by the CF_METAFILEPICT handle.
     CF_OEMTEXT         :one:='OEM text';//Text format containing characters in the OEM character set. Each line ends with a carriage return/linefeed (CR-LF) combination. A null character signals the end of the data.
     CF_OWNERDISPLAY    :one:='Owner-display format';//Owner-display format. The clipboard owner must display and update the clipboard viewer window, and receive the WM_ASKCBFORMATNAME, WM_HSCROLLCLIPBOARD, WM_PAINTCLIPBOARD, WM_SIZECLIPBOARD, and WM_VSCROLLCLIPBOARD messages. The hMem parameter must be NULL.
     CF_PALETTE         :one:='Color palette';//Handle to a color palette. Whenever an application places data in the clipboard that depends on or assumes a color palette, it should place the palette on the clipboard as well.If the clipboard contains data in the CF_PALETTE (logical color palette) format, the application should use the SelectPalette and RealizePalette functions to realize (compare) any other data in the clipboard against that logical palette.When displaying clipboard data, the clipboard always uses as its current palette any object on the clipboard that is in the CF_PALETTE format.
     CF_PENDATA         :one:='Microsoft Windows for Pen Computing';//Data for the pen extensions to the Microsoft Windows for Pen Computing.
     CF_PRIVATEFIRST    :one:='CF_PRIVATEFIRST';//Start of a range of integer values for private clipboard formats. The range ends with CF_PRIVATELAST. Handles associated with private clipboard formats are not freed automatically; the clipboard owner must free such handles, typically in response to the WM_DESTROYCLIPBOARD message.
     CF_PRIVATELAST     :one:='CF_PRIVATELAST';//See CF_PRIVATEFIRST.
     CF_RIFF            :one:='Audio';//Represents audio data more complex than can be represented in a CF_WAVE standard wave format.
     CF_SYLK            :one:='Microsoft Symbolic Link (SYLK)';//Microsoft Symbolic Link (SYLK) format.
     CF_TEXT            :one:='Text format';//Text format. Each line ends with a carriage return/linefeed (CR-LF) combination. A null character signals the end of the data. Use this format for ANSI text.
     CF_TIFF            :one:='agged-image file';//Tagged-image file format.
     CF_UNICODETEXT     :one:='Unicode text';//Unicode text format. Each line ends with a carriage return/linefeed (CR-LF) combination. A null character signals the end of the data.
     CF_WAVE            :one:='WAV audi';//Represents audio data in one of the standard wave formats, such as 11 kHz or 22 kHz PCM.

  CF_MAX_XP            :one:='';


     else one:='-- unknown --';
     end
     end
     else one:=AC2Str(buf);
  res:=res + Format('%d '#9': %s'+crlf,[cf,one]);
  except
  Break;
  end;
  end;
Result:=res;
//ShowMessageInfo('Фрагмент  в буфере можно обработать как:'+crlf+res, 'Буфер обмена.');
except
end;
end;


function GetCustomClipboardFormatsInfo : string;
const lenCC : integer = 1024;
var
 cnt : integer;
 buf : PChar;
begin
try
Result := '';
buf:=AllocMem(lenCC*SizeOfChar+1);
try
for cnt:=$C000 to $FFFF
  do if GetClipboardFormatName(cnt, buf, lenCC)<>0
     then Result:=Result + Format('%d '#9': %s'+crlf,[cnt,Trim(StrPas(buf))]);
finally
FreeMem(buf);
end;
//RegisterClipboardFormat function
//https://msdn.microsoft.com/en-us/library/windows/desktop/ms649049(v=vs.85).aspx
except
end;
end;

//procedure TMainFormOfApplication.WMChangeCBChain(var msg: TWMChangeCBChain);
//begin
//try
//if msg.Remove=clpBrdNextWnd
//   then clpBrdNextWnd:=msg.Next
//   else SendMessage(clpBrdNextWnd, WM_CHANGECBCHAIN, msg.Remove, msg.Next);
//except
// on E : Exception do ;
//end;
//end;
//
//procedure TMainFormOfApplication.WMDrawClipBoard(var msg: TWMDrawClipboard);
//var
// pw    : TWindowPlacement;
// isPic : boolean;
//begin
//try
//try
//isPic:=false;
//try
//IsPic:=Clipboard.HasFormat(CF_PICTURE);
//except
//end;
//if isPic
//   then begin
//   // off cliboardviewer
//   // process and modify a picture from cliboard
//   // on cliboardviewer
//   end;
//finally
//SendMessage(clpBrdNextWnd, WM_DRAWCLIPBOARD, 0, 0);
//end;
//except
// on E : Exception do LogErrorMessage('T_Pan4.WMDrawClipBoard',E,[]);
//end;
//end;


function StringToMemory(const aStr : string) : cardinal;
var
 tmp : PChar;
begin
Result:=GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE,Length(aStr)*SizeOfChar+1);
tmp := GlobalLock(Result);
try
StrPCopy(tmp, aStr);
finally
GlobalUnLock(Result);
end;
end;

function MemoryToString(const aMem : cardinal) : string;
var
 tmp : PChar;
begin
tmp:=GlobalLock(aMem);
try
Result:=StrPas(tmp);
finally
GlobalUnlock(aMem);
GlobalFree(aMem);
end;
end;


function BytesToMemory(const aBytes : TBytes) : cardinal;
var
 ln  : cardinal;
 tmp : pointer;
begin
ln:=cardinal(Length(aBytes));
Result:=GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE,ln);
tmp := GlobalLock(Result);
try
if Length(aBytes)>0
   then System.Move(aBytes[0],tmp^, ln);
finally
GlobalUnLock(Result);
end;
end;

function BytesToMemory(const aBytes : array of byte) : cardinal;
var
 ln  : cardinal;
 tmp : pointer;
begin
ln:=cardinal(Length(aBytes));
Result:=GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE,ln);
tmp := GlobalLock(Result);
try
if Length(aBytes)>0
   then System.Move(aBytes[0],tmp^, ln);
finally
GlobalUnLock(Result);
end;
end;

function MemoryToBytes(const aMem : cardinal) : TBytes;
var
 ln  : cardinal;
 tmp : pointer;
begin
ln:=GlobalSize(aMem);
SetLength(Result, ln);
tmp:=GlobalLock(aMem);
try
if ln>0
   then System.Move(tmp^,Result[0],ln);
finally
GlobalUnlock(aMem);
GlobalFree(aMem);
end;
end;



function StrToFloatAltDS(const Value:string; aAltDecimalSeparator: char) : extended;
var
  ds: char;
begin
  ds := FormatSettings.DecimalSeparator;
  try
    FormatSettings.DecimalSeparator := aAltDecimalSeparator;
    Result := StrToFloat(Value);
  finally
    FormatSettings.DecimalSeparator := ds;
  end;
end;

function FormatFloatAltDS(const aFormat:string; Value: extended;
  aAltDecimalSeparator: char):string;
var
  ds: char;
begin
  ds := FormatSettings.DecimalSeparator;
  try
    FormatSettings.DecimalSeparator := aAltDecimalSeparator;
    Result := FormatFloat(aFormat, Value);
  finally
    FormatSettings.DecimalSeparator := ds;
  end;
end;

procedure FormatFloatThread(const Format : string; Value : extended; var Result : string);
var
  buf : PChar;
//  val : extended;
begin
buf:=AllocMem(255*SizeOfChar+1);
try
FloatToTextFmt(buf, Value, fvExtended,PChar(Format), FormatSettings);
Result:=StrPas(buf);
finally
FreeMem(buf);
end;
end;

(*Номер элемента в массиве (типа " A in [A,B,C,D]")*)

function Inner(const Val: byte;const ArrayOfVals: array of byte): integer;
var
  i: integer;
begin
  Result :=-1;
  for i := Low(ArrayOfVals)to High(ArrayOfVals)do
    if ArrayOfVals[i]= Val then
    begin
      Result := i;
      Exit;
    end;
end;

function Inner(const Val: integer;const ArrayOfVals: array of integer): integer;
var
  i: integer;
begin
  Result :=-1;
  for i := Low(ArrayOfVals)to High(ArrayOfVals)do
    if ArrayOfVals[i]= Val then
    begin
      Result := i;
      Exit;
    end;
end;

function Inner(const Val: cardinal; ArrayOfVals: array of cardinal): integer;
var
  i: integer;
begin
  Result :=-1;
  for i := Low(ArrayOfVals)to High(ArrayOfVals)do
    if ArrayOfVals[i]= Val then
    begin
      Result := i;
      Exit;
    end;
end;

function Inner(const Val: Word;const ArrayOfVals: array of Word): integer;
var
  i: integer;
begin
  Result :=-1;
  for i := Low(ArrayOfVals)to High(ArrayOfVals)do
    if ArrayOfVals[i]= Val then
    begin
      Result := i;
      Exit;
    end;
end;

function Inner(const Val:string;const ArrayOfVals: TStringDynArray): integer;
var
  i: integer;
begin
  Result :=-1;
  for i := Low(ArrayOfVals)to High(ArrayOfVals)do
    if ArrayOfVals[i]= Val then
    begin
      Result := i;
      Exit;
    end;
end;


function Inner(const Val:Double;const ArrayOfVals: TDoubleDynArray) : integer;
var
  i: integer;
begin
  Result :=-1;
  for i := Low(ArrayOfVals)to High(ArrayOfVals)do
    if ArrayOfVals[i]= Val then
    begin
      Result := i;
      Exit;
    end;
end;

function Inner(const Val:Single;const ArrayOfVals: TSingleDynArray) : integer;
var
  i: integer;
begin
  Result :=-1;
  for i := Low(ArrayOfVals)to High(ArrayOfVals)do
    if ArrayOfVals[i]= Val then
    begin
      Result := i;
      Exit;
    end;
end;


function InnerBool(aTestVal: integer; const ArrayOfVals: array of integer): boolean;
var
  cnt: integer;
begin
  Result := false;
  for cnt := 0 to High(ArrayOfVals)do
    if aTestVal = ArrayOfVals[cnt]then
    begin
      Result := true;
      Exit;
    end;
end;

function InnerBool(aTestVal: cardinal; const ArrayOfVals: array of cardinal): boolean;
var
  cnt: integer;
begin
  Result := false;
  for cnt := 0 to High(ArrayOfVals)do
    if aTestVal = ArrayOfVals[cnt]then
    begin
      Result := true;
      Exit;
    end;
end;

function InnerBool(aTestVal: Word;const ArrayOfVals: array of Word) : boolean; overload;
var
  cnt: integer;
begin
  Result := false;
  for cnt := 0 to High(ArrayOfVals)do
    if aTestVal = ArrayOfVals[cnt]then
    begin
      Result := true;
      Exit;
    end;
end;

function InnerBool(aTestVal: Double;const ArrayOfVals: array of Double) : boolean; overload;
var
  cnt: integer;
begin
  Result := false;
  for cnt := 0 to High(ArrayOfVals)do
    if aTestVal = ArrayOfVals[cnt]then
    begin
      Result := true;
      Exit;
    end;
end;

function InnerBool(aTestVal: Single;const ArrayOfVals: array of Single) : boolean; overload;
var
  cnt: integer;
begin
  Result := false;
  for cnt := 0 to High(ArrayOfVals)do
    if aTestVal = ArrayOfVals[cnt]then
    begin
      Result := true;
      Exit;
    end;
end;


function EqualArray(const arrA, arrB : array of integer) : boolean;
var
 A,B : TIntegerDynArray;
 cnt : integer;
begin
try
Result:=False;
if Length(arrA)<>Length(arrB) then Exit;
AssignIDA(arrA,A);
AssignIDA(arrB,B);
for cnt:=0 to High(A)
  do if A[cnt]<>B[cnt]
        then Exit;
Result:=true;
finally
SetLength(A,0);
SetLength(B,0);
end;
end;

function EqualArray(const arrA, arrB : TIntegerDynArray) : boolean;
var
 A,B : TIntegerDynArray;
 cnt : integer;
begin
Result:=False;
try
if Length(arrA)<>Length(arrB) then Exit;
AssignIDA(arrA,A);  QuickSort(A);
AssignIDA(arrB,B);  QuickSort(B);
for cnt:=0 to High(A)
  do if A[cnt]<>B[cnt]
        then Exit;
Result:=true;
finally
SetLength(A,0);
SetLength(B,0);
end;
end;


function AddToIntDynArray(aval: integer;var aIDA: TIntegerDynArray): integer;
begin
  Result := Inner(aval, aIDA);
  if Result =-1 then
  begin
    Result := Length(aIDA);
    SetLength(aIDA, Result + 1);
    aIDA[Result]:= aval;
  end;
end;

function AddToIntDynArray(const aval: string;var aIDA: TIntegerDynArray; const dlm : string = ',.'): integer; overload;
var
 sda : TStringDynArray;
 cnt : integer;
begin
Result:=0;
sda:=SplitString(aval,dlm);
for cnt:=0 to High(sda)
  do if CheckValidInteger(sda[cnt])
        then inc(Result,integer(AddToIntDynArray(StrToInt(sda[cnt]),aIDA)>-1));
end;

procedure AddValuesIntoArray(const Values:TStringDynArray; var aArray: TIntegerDynArray);
var
 cnt : integer;
begin
for cnt:=0 to High(Values)
  do if CheckValidInteger(Values[cnt])
        then AddToIntDynArray(StrToInt(Values[cnt]),aArray);
end;

procedure AddValueIntoArray(var aArray: TByteDynArray; aValue: Byte);
var
  ind: integer;
begin
  ind := Length(aArray);
  SetLength(aArray, ind + 1);
  aArray[ind]:= aValue;
end;

procedure AddValueIntoArray(var aArray: TWordDynArray; aValue: Word);
var
  ind: integer;
begin
  ind := Length(aArray);
  SetLength(aArray, ind + 1);
  aArray[ind]:= aValue;
end;

procedure AddValueIntoArray(var aArray: TIntegerDynArray; aValue: integer);
var
  ind: integer;
begin
  ind := Length(aArray);
  SetLength(aArray, ind + 1);
  aArray[ind]:= aValue;
end;


procedure AddValueIntoArray(var aArray: TDoubleDynArray;aValue: double);
var
  ind: integer;
begin
  ind := Length(aArray);
  SetLength(aArray, ind + 1);
  aArray[ind]:= aValue;
end;

procedure AddValueIntoArray(var aArray: TSingleDynArray;aValue: Single);
var
  ind: integer;
begin
  ind := Length(aArray);
  SetLength(aArray, ind + 1);
  aArray[ind]:= aValue;
end;


procedure DelValueFromArray(var aArray: TByteDynArray; aValue: byte);
var
  ind: integer;
begin
ind:=Inner(aValue, aArray);
if ind<=-1 then Exit
else
if ind<High(aArray)
   then System.Move(aArray[ind+1],aArray[ind],(High(aArray)-ind)*SizeOf(byte));
SetLength(aArray,Length(aArray)-1);
end;

procedure DelValueFromArray(var aArray: TWordDynArray; aValue: word);
var
  ind: integer;
begin
ind:=Inner(avalue, aArray);
if ind<=-1 then Exit
else
if ind<High(aArray)
   then System.Move(aArray[ind+1],aArray[ind],(High(aArray)-ind)*SizeOfWord);
SetLength(aArray,Length(aArray)-1);
end;

procedure DelValueFromArray(var aArray: TIntegerDynArray; aValue: integer);
var
  ind: integer;
begin
ind:=Inner(avalue, aArray);
if ind<=-1 then Exit
else
if ind<High(aArray)
   then System.Move(aArray[ind+1],aArray[ind],(High(aArray)-ind)*SizeOfInteger);
SetLength(aArray,Length(aArray)-1);
end;


procedure DelValueFromArray(var aArray: TDoubleDynArray; aValue: Double);
var
  ind: integer;
begin
ind:=Inner(avalue, aArray);
if ind<=-1 then Exit
else
if ind<High(aArray)
   then System.Move(aArray[ind+1],aArray[ind],(High(aArray)-ind)*SizeOf(Double));
SetLength(aArray,Length(aArray)-1);
end;

procedure DelValueFromArray(var aArray: TSingleDynArray; aValue: Single);
var
  ind: integer;
begin
ind:=Inner(avalue, aArray);
if ind<=-1 then Exit
else
if ind<High(aArray)
   then System.Move(aArray[ind+1],aArray[ind],(High(aArray)-ind)*SizeOf(Single));
SetLength(aArray,Length(aArray)-1);
end;

procedure AssignIDA(const aSrc : TIntegerDynArray; var aDest : TIntegerDynArray);
begin
SetLength(aDest, Length(aSrc));
if Length(aSrc)>0
   then System.Move(aSrc[0],aDest[0],Length(aSrc)*SizeOfInteger);
end;

procedure AssignIDA(const aSrc : array of integer; var aDest : TIntegerDynArray);
begin
SetLength(aDest, Length(aSrc));
if Length(aSrc)>0
   then System.Move(aSrc[0],aDest[0],Length(aSrc)*SizeOfInteger);
end;

procedure AddIDA(const aSrc : TIntegerDynArray; var aDest : TIntegerDynArray);
var
 ind : integer;
begin
ind:=Length(aDest);
SetLength(aDest, ind+Length(aSrc));
if Length(aSrc)>0
   then System.Move(aSrc[0],aDest[ind],Length(aSrc)*SizeOfInteger);
end;

function GetStringIDA(const aSrc : TIntegerDynArray; const aArrDlm : string=',') : string;
var
 cnt : integer;
 hg  : integer;
begin
Result:='';
hg:=High(aSrc);
for cnt:=0 to hg
  do Result:=Result+IntToStr(aSrc[cnt])+IfThen(cnt<hg,aArrDlm);
end;

function IDA2Str(const aSrc : TIntegerDynArray; const aArrDlm : string=',') : string;
begin
Result:=GetStringIDA(aSrc, aArrDlm);
end;

function GetStringIDA(const aSrc : array of integer; const aArrDlm : string=',') : string;
var
 cnt : integer;
 hg  : integer;
begin
Result:='';
hg:=High(aSrc);
for cnt:=0 to hg
  do Result:=Result+IntToStr(aSrc[cnt])+IfThen(cnt<hg,aArrDlm);
end;

function IDA2Str(const aSrc : array of integer; const aArrDlm : string=',') : string;
begin
Result:=GetStringIDA(aSrc, aArrDlm);
end;

function GetXMLStringIDA(const aSrc : TIntegerDynArray; const Tag : string='value') : string;
const
  shablon : string = '<%0:s>%1:d</%0:s>';
var
 cnt   : integer;
 _tag  : string;
begin
Result:='';
_tag:=StringReplace(StringReplace(Tag,'<','',[rfReplaceAll]),'>','',[rfReplaceAll]);
for cnt:=0 to High(aSrc)
  do Result:=Result+Format(shablon,[_tag, aSrc[cnt]]);
end;

function GetXMLStringIDA(const aSrc : array of integer; const Tag : string='value') : string;
const
  shablon : string = '<%0:s>%1:d</%0:s>';
var
 cnt   : integer;
 _tag  : string;
begin
Result:='';
_tag:=StringReplace(StringReplace(Tag,'<','',[rfReplaceAll]),'>','',[rfReplaceAll]);
for cnt:=0 to High(aSrc)
  do Result:=Result+Format(shablon,[_tag, aSrc[cnt]]);
end;

procedure ClearDoubles(var IDA : TIntegerDynArray);
var
 cnt : integer;
 ind : integer;
begin
for cnt:=High(IDA) downto 0
  do begin
  ind:=Inner(IDA[cnt],IDA);
  if (ind>-1) and (ind<>cnt)
     then begin
     if ind<High(IDA)
        then System.Move(IDA[ind+1],IDA[ind],(High(IDA)-ind)*SizeOfInteger);
     SetLength(IDA,Length(IDA)-1);
     end;
  end;
end;

(*Преобразование символов для поисковой строки WEB (ANSI) -------------------*)
function GetStdSearchStringA(const Value: AnsiString): AnsiString;
const
  SpecSymbs = #09#10#11#12#13#32#160;
var
  cnt: integer;
  Src: AnsiString;
  Val: Byte;
begin
  Result := '';
  if Value = '' then
    Exit;
  Src := Value;
  for cnt := 1 to Length(SpecSymbs)do
    Src := AnsiString(StringReplace(string(Src),string(SpecSymbs[cnt]), ' ',
      [rfReplaceAll]));
  for cnt := 1 to Length(Src)do
  begin
    Val := Ord(Src[cnt]);
    if(Val < 127)and(Val <> 32)then
      Result := Result + Src[cnt]
    else
      Result := Result + '%' + AnsiString(IntToHex(Val, 2));
  end;
end;
//%D0%BE%D0%B4%D0%B8%D0%BD%D1%86%D0%BE%D0%B2%D0%BE+%D1%87%D0%B8%D0%BA%D0%B8%D0%BD%D0%B0+11

function GetStdSearchStringW(const Value:String):String;
begin
  Result := string(GetStdSearchStringA(AnsiString(Value)));
end;

(*Преобразование строки в URL вида %D0%xx%D0%xx. для поисковой строки WEB ---*)
{$WARNINGS OFF}

function AnsiStringToURL(URI: AnsiString): AnsiString;
var
  i, Len: integer;
begin
  Result := '';
  URI := AnsiToUtf8(URI);
  Len := Length(URI);
  for i := 1 to Len do
    Result := Result + '%' + IntToHex(Ord(URI[i]), 2);
end;
{$WARNINGS ON}

(*Преобразование UTF-8 в ANSI -----------------------------------------------*)
//forum.vingrad.ru/forum/topic-233298/0.html
//forum.vingrad.ru/forum/topic-133239/anchor-entry1007351/0.html
{Convert string from UTF-8 format into ASCII}
{Convert string from UTF-8 format mixed with standart ASCII symbols($00..$7f)}
function UTF8ToANSI(Value:String): AnsiString;
  function UTF8ToStrInner(Value:String):String;
  var
    Buffer: Pointer;
    BufLen: LongWord;
  begin
    BufLen := Length(Value)+ 4;
    GetMem(Buffer, BufLen);
    FillChar(Buffer^, BufLen, 0);
    MultiByteToWideChar(CP_UTF8, 0,@Value[1], BufLen - 4, Buffer, BufLen);
    Result := WideCharToString(Buffer);
    FreeMem(Buffer, BufLen);
  end;

var
  Digit:String;
  i: integer;
  HByte: Byte;
  Len: Byte;
  ic: integer;
begin
  ic :=-1;
  try
    Result := '';
    Len := 0;
    if Value = '' then
      Exit;
    for i := 1 to Length(Value)do
    begin
      ic := i;
      if Len > 0 then
      begin
        Digit := Digit + Value[i];
        Dec(Len);
        if Len = 0 then
          Result := Result + AnsiString(UTF8ToStrInner(Digit));
      end
      else
      begin
        HByte := Ord(Value[i]);
        if HByte in[$00 .. $7F]//Standart ASCII chars
        then
          Result := Result + AnsiString(Value[i])
        else
        begin
          //Get length of UTF-8 char
          if HByte and $FC = $FC then
            Len := 6
          else if HByte and $F8 = $F8 then
            Len := 5
          else if HByte and $F0 = $F0 then
            Len := 4
          else if HByte and $E0 = $E0 then
            Len := 3
          else if HByte and $C0 = $C0 then
            Len := 2
          else
          begin
            Result := Result + AnsiString(Value[i]);
            Continue;
          end;
          Dec(Len);
          Digit := Value[i];
        end;
      end;
    end;
  except
    on E: Exception do
      CreateErrorMessage('UTF8ToANSI', E,[Length(Value), ic, Value[ic]], true);
  end;
end;
(*************************************************************************************************)

(*Преобразование строки URL с символами типа %D0%AD в ANSI ------------------*)
function URLStringIntoAnsiString(const aValue:string): AnsiString;
var
  tmp:string;
  TwoByte: TBytes;
  //wchr    : WideChar;
  res: AnsiString;
  win1251cls: TEncoding;
begin
  Result := AnsiString(aValue);
  if aValue = '' then
    Exit;
  tmp := aValue;
  res := '';
  try
    while tmp <> '' do
    begin
      if(Copy(tmp, 1, 2)= '%D')and(Copy(tmp, 4, 1)= '%')
      //--  UTF symbol here
      then
      begin
        SetLength(TwoByte, 2);
        win1251cls := TEncoding.GetEncoding(1251);//иначе Memory leak
        try
          TwoByte[0]:= Byte(StrToInt('$' + Copy(tmp, 2, 2)));
          TwoByte[1]:= Byte(StrToInt('$' + Copy(tmp, 5, 2)));
          //TEncoding.GetEncoding(UTF8);
          res := res + AnsiString(StringOf(TEncoding.Convert(TEncoding.UTF8,
            win1251cls, TwoByte)));
        finally
          win1251cls.Free;
          SetLength(TwoByte, 0);
        end;
        Delete(tmp, 1, 6);
      end
      else if tmp[1]= '%'//-- ANSI symbol
      then
      begin
        SetLength(TwoByte, 1);
        try
          TwoByte[0]:= Byte(StrToInt('$' + Copy(tmp, 2, 2)));
          res := res + ansichar(TwoByte[0]);
        finally
          SetLength(TwoByte, 0);
        end;
        Delete(tmp, 1, 3);
      end
      else
      begin//-- ASCII symbol
        res := res + AnsiString(tmp[1]);
        Delete(tmp, 1, 1);
      end;
    end;
  finally
  end;
  Result := res;
end;

(*Преобразование строки с символами типа \\u04xx в строку -------------------*)
function OLD_JavaUTF8ToString(const aJavaFormatedUTFStr:string):string;
//-- оставлено во избежание... ИБО!
var
  cnt: integer;
  tmp:string;
  strl: TStringList;
begin
  Result := '';
  strl := TStringList.Create;
  try
    tmp := aJavaFormatedUTFStr;
    while tmp <> '' do
    begin
      cnt := Pos('\\u', tmp);
      if cnt = 1 then
      begin
        strl.Add(Copy(tmp, 4, 4));
        tmp := Copy(tmp, 8, Length(tmp))
      end
      else
      begin
        strl.Add(Copy(tmp, 1, 1));
        tmp := Copy(tmp, 2, Length(tmp));
      end;
    end;
    for cnt := 0 to strl.Count - 1 do
    begin
      if(Length(strl[cnt])= 4)and(Pos('04', strl[cnt])= 1)then
        Result := Result + widechar(StrToInt('$' + strl[cnt]))
      else
        Result := Result + strl[cnt];
    end;
  finally
    FreeStringList(strl);
  end;
end;



function HTMLStringToString(const aHTMLFormatedStr:string):string;
//const
//RUSsymb : array[0..65] of string =
//('А','Б','В','Г','Д','Е','Ё','Ж','З','И','Й','К','Л','М','Н','О','П','Р','С','Т','У','Ф','Х','Ц','Ч','Ш','Щ','Ъ','Ы','Ь','Э','Ю','Я',
//'а','б','в','г','д','е','ё','ж','з','и','й','к','л','м','н','о','п','р','с','т','у','ф','х','ц','ч','ш','щ','ъ','ы','ь','э','ю','я');
var
  cnt: integer;
  tmp:string;
begin
  Result := '';
  try
    tmp := aHTMLFormatedStr;
    for cnt := 0 to High(HTMLsymb)do
      tmp := StringReplace(tmp,string(HTMLsymb[cnt]),string(RUSsymb[cnt]),
        [rfReplaceAll]);
    Result := tmp;
  finally
  end;
end;

function StringToHTMLString(const aNormalStr:string):string;
//const
//HTMLsymb : array[0..65] of string =
//('&#1040;','&#1041;','&#1042;','&#1043;','&#1044;','&#1045;','&#1025;','&#1046;','&#1047;','&#1048;','&#1049;','&#1050;','&#1051;','&#1052;','&#1053;','&#1054;','&#1055;','&#1056;','&#1057;','&#1058;','&#1059;','&#1060;','&#1061;','&#1062;','&#1063;','&#1064;','&#1065;','&#1066;','&#1067;','&#1068;','&#1069;','&#1070;','&#1071;',
//'&#1072;','&#1073;','&#1074;','&#1075;','&#1076;','&#1077;','&#1105;','&#1078;','&#1079;','&#1080;','&#1081;','&#1082;','&#1083;','&#1084;','&#1085;','&#1086;','&#1087;','&#1088;','&#1089;','&#1090;','&#1091;','&#1092;','&#1093;','&#1094;','&#1095;','&#1096;','&#1097;','&#1098;','&#1099;','&#1100;','&#1101;','&#1102;','&#1103;');
//RUSsymb : array[0..65] of string =
//('А','Б','В','Г','Д','Е','Ё','Ж','З','И','Й','К','Л','М','Н','О','П','Р','С','Т','У','Ф','Х','Ц','Ч','Ш','Щ','Ъ','Ы','Ь','Э','Ю','Я',
//'а','б','в','г','д','е','ё','ж','з','и','й','к','л','м','н','о','п','р','с','т','у','ф','х','ц','ч','ш','щ','ъ','ы','ь','э','ю','я');
var
  cnt: integer;
  tmp:string;
begin
  Result := '';
  try
    tmp := aNormalStr;
    for cnt := 0 to High(RUSsymb)do
      tmp := StringReplace(tmp,string(RUSsymb[cnt]),string(HTMLsymb[cnt]),
        [rfReplaceAll]);
    Result := tmp;
  finally
  end;
end;

procedure ReplaceRusSymbInHTML(const aHTMLFileName:string);
var
  backFileName:string;
  HTMLText:string;
  cnt: integer;
begin
  if not FileExists(aHTMLFileName)then
    Exit;
  backFileName := ChangeFileExt(aHTMLFileName,
    StringReplace(ExtractFileExt(aHTMLFileName), '.', '.~',[]));
  try
    CopyFile(PChar(aHTMLFileName), PChar(backFileName), false);
  except
    Exit;
  end;
  HTMLText := LoadStringFromFile(aHTMLFileName);
  try
    for cnt := Low(RUSsymb)to High(RUSsymb)do
    //HTMLText:=StringReplace(HTMLText,string(RUSsymb[cnt]), StringToJavaUTF8(string(RUSsymb[cnt])),[rfReplaceAll]);
      HTMLText := StringReplace(HTMLText,string(RUSsymb[cnt]),
        string(JSSymb[cnt]),[rfReplaceAll]);

  finally
    SaveStringIntoFile(HTMLText, aHTMLFileName);
  end;
end;


function ReplaceRusInURL(const aURL : string) : string;
var
 cnt : integer;
 ch  : char;
begin
Result:='';
for cnt:=1 to Length(aURL)
  do begin
  ch:=aURL[cnt];
  if not IsRusChar(ch)
     then Result := Result + ch
     else Result := Result + string(AnsiStringToURL(ansistring(ch)));
  end;
end;



(*
 const
 JavaStr =
 '{4100:"\\u043c",4101:"\\u0444\\u0443\\u0442.",10507:"'+
 '\\u041f\\u0435\\u0440\\u0435\\u0434\\u0432\\u0438\\u043d\\u0443\\u0442\\u044c '+
 '\\u0432\\u043b\\u0435\\u0432\\u043e"';
 begin
 ShowMessage(JavaUTF8ToString(JavaStr))
 end;
*)
(*Преобразование строки в строку Java типа \\u04xx --------------------------*)
function OLD_StringToJavaUTF8(const aString:string):string;
var
  cnt: integer;
  sym: integer;
begin
  Result := '';
  if aString = '' then
    Exit;
  for cnt := 1 to Length(aString)do
  begin
    sym := Ord(aString[cnt]);
    if sym <= 127 then
      Result := Result + aString[cnt]
    else
      Result := Result + Format('\u%s',[IntToHex(sym, 4)]);
  end;
end;



(*Проверка строки на кодировку UTF8 -----------------------------------------*)
function IsUTF8(const aStr:string): boolean;
var
  tmp:string;
begin
  Result := false;
  if Length(aStr)= 0 then
    Exit;
  tmp := System.UTF8ToString(RawByteString(aStr));
  Result := Pos(#$FFFD, tmp)= 0;
end;

(*Преобразование массива байт(возможно содержащую UTF8string) в строку ------*)

function UTF8From2BytesString_PQ(const aBytes: TBytes):string; overload;

var
  cnt: integer;
begin
  Result := '';
  cnt := Low(aBytes);
  while cnt <= High(aBytes)do
  begin
    if aBytes[cnt]in[80, 81]then
    begin
      if cnt + 1 > High(aBytes)then
        Break;
      Result := Result + OLD_JavaUTF8ToString
        ('\\u04' + IntToHex(Byte($40 * integer(aBytes[cnt]= 81)+
        aBytes[cnt + 1]), 2));
      cnt := cnt + 2;
    end
    else
    begin
      Result := Result + Chr(aBytes[cnt]);
      cnt := cnt + 1;
    end;
  end;
end;

function UTF8From2BytesString_PQ(const aBytes: array of Byte):string; overload;
var
  cnt: integer;
begin
  Result := '';
  cnt := Low(aBytes);
  while cnt <= High(aBytes)do
  begin
    if aBytes[cnt]in[80, 81]then
    begin
      if cnt + 1 > High(aBytes)then
        Break;
      Result := Result + OLD_JavaUTF8ToString
        ('\\u04' + IntToHex(Byte($40 * integer(aBytes[cnt]= 81)+
        aBytes[cnt + 1]), 2));
      cnt := cnt + 2;
    end
    else
    begin
      Result := Result + Chr(aBytes[cnt]);
      cnt := cnt + 1;
    end;
  end;
end;

(*

 const D0_str1 : UTF8String = 'ÐÐ°Ð·Ð¾Ð²ÑÐ¹ ÐºÐ°ÑÐ´Ð¸Ð³Ð°Ð½ Ñ V-Ð¾Ð±ÑÐ°Ð·Ð½ÑÐ¼ Ð²ÑÑÐµÐ·Ð¾Ð¼';

 const D0_str2 : string ='ÐÐ°Ð·Ð¾Ð²ÑÐ¹ ÐºÐ°ÑÐ´Ð¸Ð³Ð°Ð½ Ð¸Ð· ÑÐ¼ÐµÑÐ°Ð½Ð½Ð¾Ð¹ Ð¿ÑÑÐ¶Ð¸ Ñ V â Ð¾Ð±ÑÐ°Ð·Ð½ÑÐ¼ Ð²ÑÑÐµÐ·Ð¾Ð¼, Ð·Ð°ÑÑÐµÐ³Ð¸Ð²Ð°ÐµÑÑÑ Ð½Ð° Ð¿ÑÐ³Ð¾Ð²Ð¸ÑÐ°Ñ Ð²Ð¿ÐµÑ'+'ÐµÐ´Ð¸, Ñ Ð½ÐµÐ±Ð¾Ð»ÑÑÐ¸Ð¼Ð¸ ÑÑÑÐ°Ð¼Ð¸ Ð¿Ð¾ Ð¿Ð¾Ð´Ð¾Ð»Ñ, Ð²Ð½ÑÑÑÐµÐ½Ð½Ð¸Ð¹ Ð²ÑÑÐµÐ· Ð¾Ð±ÑÐ°Ð±Ð¾ÑÐ°Ð½ Ð²ÐµÐ»ÑÑÐ¾'+'Ð²Ð¾Ð¹ Ð»ÐµÐ½ÑÐ¾Ð¹. ÐÐµÐ·Ð°Ð¼ÐµÐ½Ð¸Ð¼ÑÐ¹ Ð½Ð°ÑÑÐ´ Ð´Ð»Ñ Ð·Ð¸Ð¼Ñ';
 procedure TForm1.SpeedButton13Click(Sender: TObject);
 var
 bt : array of byte;
 cnt : integer;
 ind : integer;
 begin
 for cnt:=1 to Length(D0_str2)
 do begin
 ind:=Length(bt);
 SetLength(bt,ind+1);
 if D0_str2[cnt]='Ð' then bt[ind]:=$D0 else
 if D0_str2[cnt]='Ñ' then bt[ind]:=$D1 else
 bt[ind]:=byte(D0_str2[cnt]) ;
 end;
 if Length(bt)>0 then ShowMessageInfo(UTF8From2BytesString_D0(bt));
 end;
*)

function UTF8From2BytesString_D0(const aBytes: TBytes):string; overload;

var
  cnt: integer;
  tmp:string;
begin
  Result := '';
  tmp := '';
  cnt := Low(aBytes);
  while cnt <= High(aBytes)do
  begin
    tmp := tmp + '%' + IntToHex(aBytes[cnt], 2);
    cnt := cnt + 1;
  end;
  Result := string(URLStringIntoAnsiString(tmp));
end;

function UTF8From2BytesString_D0(const aBytes: array of Byte):string; overload;
var
  cnt: integer;
  tmp:string;
begin
  Result := '';
  tmp := '';
  cnt := Low(aBytes);
  while cnt <= High(aBytes)do
  begin
    tmp := tmp + '%' + IntToHex(aBytes[cnt], 2);
    cnt := cnt + 1;
  end;
  Result := string(URLStringIntoAnsiString(tmp));
end;

function D0str2Str(const aDostr:string):string;
var
  bt: array of Byte;
  cnt: integer;
  ind: integer;
begin
  try
    for cnt := 1 to Length(aDostr)do
    begin
      ind := Length(bt);
      SetLength(bt, ind + 1);
      if aDostr[cnt]= 'Ð' then
        bt[ind]:= $D0
      else if aDostr[cnt]= 'Ñ' then
        bt[ind]:= $D1
      else
        bt[ind]:= Byte(aDostr[cnt]);
    end;
    Result := UTF8From2BytesString_D0(bt);
  finally
    SetLength(bt, 0);
  end;
end;

function IsUnicode(const aTestStr:string): boolean;
var
  buf: PChar;
  bufsz: cardinal;
  bufres: PINT;
begin
  bufsz := Length(aTestStr)* SizeOfChar + 1;
  buf := Allocmem(bufsz);
  bufres := Allocmem(SizeOfInteger);
  try
    StrPCopy(buf, aTestStr);
    bufres^:= IS_TEXT_UNICODE_STATISTICS or IS_TEXT_UNICODE_CONTROLS;
    Result := IsTextUnicode(@buf[0], bufsz, bufres);
    //then begin
    //bufinf:='';
    //if bufres^ and IS_TEXT_UNICODE_ASCII16>0 then bufinf:=bufinf+crlf+'The text is Unicode, and contains only zero-extended ASCII values/characters.';
    //if bufres^ and IS_TEXT_UNICODE_REVERSE_ASCII16>0 then bufinf:=bufinf+crlf+' Same as the preceding, except that the Unicode text is byte-reversed.';
    //(**)if bufres^ and IS_TEXT_UNICODE_STATISTICS>0 then bufinf:=bufinf+crlf+' The text is probably Unicode, with the determination made by applying statistical analysis. Absolute certainty is not guaranteed. See the Remarks section.';
    //if bufres^ and IS_TEXT_UNICODE_REVERSE_STATISTICS>0 then bufinf:=bufinf+crlf+' Same as the preceding, except that the text that is probably Unicode is byte-reversed.';
    //(**)if bufres^ and IS_TEXT_UNICODE_CONTROLS>0 then bufinf:=bufinf+crlf+' The text contains Unicode representations of one or more of these nonprinting characters: RETURN, LINEFEED, SPACE, CJK_SPACE, TAB.';
    //if bufres^ and IS_TEXT_UNICODE_REVERSE_CONTROLS>0 then bufinf:=bufinf+crlf+' Same as the preceding, except that the Unicode characters are byte-reversed.';
    // //if bufres^ and IS_TEXT_UNICODE_BUFFER_TOO_SMALL>0 then bufinf:=bufinf+' There are too few characters in the buffer for meaningful analysis (fewer than two bytes).';
    //if bufres^ and IS_TEXT_UNICODE_SIGNATURE>0 then bufinf:=bufinf+crlf+' The text contains the Unicode byte-order mark (BOM) 0xFEFF as its first character.';
    //if bufres^ and IS_TEXT_UNICODE_REVERSE_SIGNATURE>0 then bufinf:=bufinf+crlf+' The text contains the Unicode byte-reversed byte-order mark (Reverse BOM) 0xFFFE as its first character.';
    //if bufres^ and IS_TEXT_UNICODE_ILLEGAL_CHARS>0 then bufinf:=bufinf+crlf+' The text contains one of these Unicode-illegal characters: embedded Reverse BOM, UNICODE_NUL, CRLF (packed into one WORD), or 0xFFFF.';
    //if bufres^ and IS_TEXT_UNICODE_ODD_LENGTH>0 then bufinf:=bufinf+crlf+' The number of characters in the string is odd. A string of odd length cannot (by definition) be Unicode text.';
    //if bufres^ and IS_TEXT_UNICODE_NULL_BYTES>0 then bufinf:=bufinf+crlf+' The text contains null bytes, which indicate non-ASCII text.';
    //(**)if bufres^ and IS_TEXT_UNICODE_UNICODE_MASK>0 then bufinf:=bufinf+crlf+' This flag constant is a combination of IS_TEXT_UNICODE_ASCII16, IS_TEXT_UNICODE_STATISTICS, IS_TEXT_UNICODE_CONTROLS, IS_TEXT_UNICODE_SIGNATURE.';
    //if bufres^ and IS_TEXT_UNICODE_REVERSE_MASK>0 then bufinf:=bufinf+crlf+' This flag constant is a combination of IS_TEXT_UNICODE_REVERSE_ASCII16, IS_TEXT_UNICODE_REVERSE_STATISTICS, IS_TEXT_UNICODE_REVERSE_CONTROLS, IS_TEXT_UNICODE_REVERSE_SIGNATURE.';
    // //if bufres^ and IS_TEXT_UNICODE_NOT_UNICODE>0 then bufinf:=bufinf+'_MASK This flag constant is a combination of IS_TEXT_UNICODE_ILLEGAL_CHARS, IS_TEXT_UNICODE_ODD_LENGTH, and two currently unused bit flags.';
    //if bufres^ and IS_TEXT_UNICODE_NOT_ASCII_MASK>0 then bufinf:=bufinf+crlf+' This flag constant is a combination of IS_TEXT_UNICODE_NULL_BYTES and three currently unused bit flags.';
    //
    //
    //ShowMessage('Is unicode'+crlf+bufinf);
    //
    //end
    //else ShowMessage('Is NOT unicode');
  finally
    FreeMem(bufres);
    FreeMem(buf);
  end;
end;

function UTF8ToUnicode(const aInput:string;var aUnicode, aHTML:string): integer;
var
  resMBS: PAnsiChar;
  lenMBS: integer;
  res: integer;
  erc: cardinal;
  cnt: integer;
  resBytes: TBytes;
  strAns: AnsiString;
  err : string;

begin
  Result := 0;
try
err:='10';
  SetLastError(0);
err:='20';
  aUnicode := '';
err:='30';
  aHTML := '';
err:='40';
  lenMBS := 0;
err:='50';
  resMBS := nil;
err:='60';
  try
    res := WideCharToMultiByte(CP_UTF8, 0, PChar(aInput), Length(aInput), resMBS, lenMBS,nil,nil);
err:='70';
    erc := GetLastError;
err:='80';
    if (res > 0)and(erc = 0)
       then(*all right!*)
       else begin
       Result := integer(erc);
       Exit;
       end;
err:='90';
    lenMBS := res;
err:='100';
    resMBS := Allocmem(lenMBS+1);
err:='110';
    res := WideCharToMultiByte(CP_UTF8, 0, PChar(aInput), Length(aInput), resMBS, lenMBS,nil,nil);
err:='120';
    strAns := StrPas(resMBS);
err:='130';
    if (res = lenMBS)and(strAns <> '')
       then begin
err:='140';
       aUnicode := string(strAns);
err:='150';
       resBytes := BytesOf(strAns);
err:='160';
       for cnt := 0 to High(resBytes) do aHTML := aHTML + '%' + IntToHex(resBytes[cnt], 2);
       end;
err:='170';
  finally
    if Assigned(resMBS)then
      FreeMem(resMBS);
    SetLength(resBytes, 0);
    strAns := '';
  end;
except
 on E : Exception
  do begin
  CreateErrorMessage('UTF8ToUnicode',E,[aInput, err],err);
  if err<>'' then ;
  end;
end;
end;


function AsUTF8(const aInput:string): string; inline;
var
  resMBS: array of ansichar;
  lenMBS: integer;
  res: integer;
  erc: cardinal;
  //cnt: integer;
  //resBytes: TBytes;
  strAns: AnsiString;
  err : string;

begin
 Result := '';
try
err:='10';
  SetLastError(0);
err:='20';

err:='40';
  lenMBS := 0;
err:='50';
  resMBS := nil;
err:='60';
  try
    lenMBS := WideCharToMultiByte(CP_UTF8, 0, PChar(aInput), Length(aInput), @resMBS, lenMBS,nil,nil);
err:='70';
    erc := GetLastError;
err:='80';
    if (lenMBS = 0) or (erc <> 0)
       then begin
       Result := aInput;
       Exit;
       end;
err:='100';
    SetLength(resMBS,lenMBS+1);
err:='110';
    res := WideCharToMultiByte(CP_UTF8, 0, PChar(aInput), Length(aInput), @resMBS[0], lenMBS,nil,nil);
err:='120';
if res<>0 then ;
    Result := string(StrPas(PAnsiChar(@resMBS[0])));
  finally
  SetLength(resMBS,0);
  strAns := '';
  end;
except
 on E : Exception
  do begin
  CreateErrorMessage('UTF8ToUnicode',E,[aInput, err],err);
  if err<>'' then ;
  end;
end;
end;




// ??? аналог в function UnicodeToUTF8_HTML(const aInput:string;var aUTF8:string): integer;
function UnicodeToUTF8(const aInput:string;var aUTF8:string): integer;
var
  resMBS: PChar;
  lenMBS: integer;
  res: integer;
  erc: cardinal;
begin
  Result := 0;
  aUTF8 := '';
  lenMBS := 0;
  resMBS := nil;
  SetLastError(0);
  try
    res := MultiByteToWideChar(CP_UTF8, 0, PAnsiChar(AnsiString(aInput)), Length(aInput), resMBS, lenMBS);
    erc := GetLastError;
    if(res > 0)and(erc = 0)then
    else
    begin
      Result := integer(erc);
      Exit;
    end;
    lenMBS := res;
    resMBS := Allocmem(lenMBS * SizeOfChar + 1);
    res := MultiByteToWideChar(CP_UTF8, 0, PAnsiChar(AnsiString(aInput)), Length(aInput), resMBS, lenMBS);
    if res = lenMBS then aUTF8 := StrPas(resMBS);
  finally
    FreeMem(resMBS);
  end;
end;





function JavaUTF8ToStringEx(const aUStr:string):string;
var
  Src:string;
  wd: Word;
begin
  Result := '';
  // -- так сложно, так как разбирается смешанная строка типа \uXXXX_abcd \uYYYY
  Src := AnsiUpperCase(StringReplace(aUStr, '\', '',[rfReplaceAll]));
  while Src <> '' do
  begin
    if Pos('U', Src)= 1 then
    begin
      wd := StrToInt('$' + Copy(Src, 2, 4));
      Delete(Src, 1, 5);
    end
    else
    begin
      wd := Word(Copy(Src, 1, 1)[1]);
      Delete(Src, 1, 1);
    end;
    Result := Result + Chr(wd);
  end;
end;


function StringToJavaUTF8Ex(const aString:string):string;
var
  cnt: integer;
begin
  Result := '';
  for cnt := 1 to Length(aString)
    do Result := Result + Format('\u%s',[IntToHex(Ord(aString[cnt]), 4)]);
end;


function BytesToJavaString(aBytes : array of byte; aStart,aLength : integer) : string;
var
 cnt : integer;
 tmp : string;
begin
cnt:=aStart;
while cnt<aStart+aLength
  do begin
  tmp:=tmp+'\\u'+IntToHex(aBytes[cnt],2)+IntToHex(aBytes[cnt+1],2);
  inc(cnt,2);
  end;
Result:=JavaUTF8ToStringEx(tmp);
end;


procedure StringToJavaBytes(const aStr : string; var aBytes : TByteDynArray);
var
 cnt : integer;
 ind : integer;
 sym : word;
begin
Setlength(aBytes,length(aStr)*2);
for cnt:=1 to Length(aStr)
  do begin
  sym:=Ord(aStr[cnt]);
  ind:=(cnt-1)*2;
  aBytes[ind]:=hibyte(sym);
  aBytes[ind+1]:=lobyte(sym);
  end;
end;



function GetRuSymb(aCode: smallint): ansichar;
var
  cnt: integer;
begin
  Result := '?';
  if aCode < $7F then
  begin
    Result := ansichar(aCode);
    Exit;
  end
  else
    for cnt := Low(RUSsymb)to High(RUSsymb)do
      if Ord(RUSsymb[cnt])= aCode then
      begin
        Result := RUSsymb[cnt];
        Exit;
      end;
end;

function ConvertToRus(const aUnknownStr:string):string;
var
  cnt: integer;
  code: smallint;
begin
  Result := '';
  for cnt := 1 to Length(aUnknownStr)do
  begin
    code := Ord(aUnknownStr[cnt]);
    if(code > $7F)and(code <= $FF)then
      Result := Result + string(GetRuSymb(code))
    else
      Result := Result + aUnknownStr[cnt]
  end;
end;

function ConvertToRus_New(const aUnknownStr:string):string;
var
  cnt: integer;
begin
  Result := aUnknownStr;
  for cnt := Low(RUSsymb)to High(RUSsymb)do
    Result := StringReplace(Result, char(Ord(RUSsymb[cnt])), char(RUSsymb[cnt]),
      [rfReplaceAll]);
end;

function BytesStrToStr(const aBytesStr:string; aSign: char = '%'):string;
//-- встречается также '=' (типа =D0=A1=D0=BE)
  procedure AddByte(var aBytes: TBytes; aval: Byte);
  var
    ind: integer;
  begin
    ind := Length(aBytes);
    SetLength(aBytes, ind + 1);
    aBytes[ind]:= aval;
  end;

var
  Src:string;
  bytes: TBytes;
begin
  Src := aBytesStr;
  SetLength(bytes, 0);
  try
    while Src <> '' do
    begin
      if Pos(aSign, Src)= 1 then
      begin
        AddByte(bytes, Byte(StrToInt('$' + Copy(Src, 2, 2))));
        Delete(Src, 1, 3);
      end
      else
      begin
        AddByte(bytes, Byte(Copy(Src, 1, 1)[1]));
        Delete(Src, 1, 1);
      end;
    end;
    Result := StringOf(bytes);
  finally
    SetLength(bytes, 0);
  end;
end;

// ?? аналог в function UnicodeToUTF8_HTML(const aInput:string;var aUTF8:string): integer;
function UnicodeToUTF8_HTML(const aInput:string;var aUTF8:string): integer;
var
  resMBS: PChar;
  lenMBS: integer;
  res: integer;
  erc: cardinal;
  Str:string;
begin
//Result:=UnicodeToUTF8(aInput, aUTF8);
  Result := 0;
  Str := BytesStrToStr(aInput); // -- вот видимо только из-за этой строки
  //if res>0 then ;
  //гЃ“г‚“гЃ°г‚“гЃЇ
  //a??a??a?°a??a??
  //UnicodeToUTF8(str,aUTF8);
  aUTF8 := '';
  lenMBS := 0;
  resMBS := nil;
  try
    res := MultiByteToWideChar(CP_UTF8, 0, PAnsiChar(AnsiString(Str)),
      Length(Str), resMBS, lenMBS);
    erc := GetLastError;
    if(res > 0)and(erc = 0)then
    else
    begin
      Result := integer(erc);
      Exit;
    end;
    lenMBS := res;
    resMBS := Allocmem(lenMBS * SizeOfChar + 1);
    res := MultiByteToWideChar(CP_UTF8, 0, PAnsiChar(AnsiString(Str)),
      Length(Str), resMBS, lenMBS);
    if res = lenMBS then
      aUTF8 := StrPas(resMBS);
  finally
    FreeMem(resMBS);
  end;
end;



function AsUTF8mbwc(const aInput : string) : string;
var
// htm : string;
 err  :string;
begin
try
//UTF8ToUnicode(aInput, Result, htm);
//htm:='';
Result:=AsUTF16(aInput);
except
 on E : Exception do
   begin
   CreateErrorMessage('AsUTF8mbwc',E,[aInput],err);
   if err<>'' then ;
   end;
end;
end;

function AsUTF16(const aInput:string): string; //inline;
var
  inp   : string;
  resMBS: PAnsiChar;
  lenMBS: integer;
begin
 Result := '';
try
  inp:=Trim(aInput);
  if inp='' then Exit;
  lenMBS := WideCharToMultiByte(CP_UTF8, 0, PChar(inp), -1, nil, 0, nil,nil);
  resMBS:=AllocMem(lenMBS+1);
  try
  WideCharToMultiByte(CP_UTF8, 0, PChar(inp), -1, resMBS, lenMBS, nil,nil);
  Result := string(StrPas(resMBS));
  finally
  FreeMem(resMBS);
  end;
except
 //on E : Exception do LogErrorMessage('AsUTF16',E,[aInput]);
end;
end;


function AsWin1251mbwc(const aInput : string) : string;
begin
UnicodeToUTF8(aInput, Result);
end;

function AsURL(const aInput : string) : string;
var
 res : TBytes;
 cnt : integer;
begin
res:=TEncoding.Convert(TEncoding.Default, TEncoding.UTF8, BytesOf(aInput));
Result:='';
for cnt := 0 to High(res) do Result := Result + '%' + IntToHex(res[cnt], 2);
end;

function FromURL(const aInput : string) : string;
//function TURLEncoding.Decode(const AValue: string; const Options: TDecodeOptions): string;
const
  H2BConvert: array[Ord('0')..Ord('f')] of SmallInt =
    ( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,-1,-1,-1,-1,-1,-1,
     -1,10,11,12,13,14,15,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     -1,10,11,12,13,14,15);

  function IsHexChar(C: Byte): Boolean; inline;
  begin
    Result := C in [Ord('0')..Ord('9'), Ord('A')..Ord('F'), Ord('a')..Ord('f')];
  end;

var
  ValueBuff: TBytes;
  Buff: TBytes;
  Cnt: Integer;
  Pos: Integer;
  Len: Integer;
begin
  Cnt := 0;
  Pos := 0;
  ValueBuff := TEncoding.UTF8.GetBytes(aInput);
  Len := Length(ValueBuff);
  SetLength(Buff, Len);
  while Pos < Len do
  begin
    if (ValueBuff[Pos] = Ord('%')) and ((Pos + 2) < Len)  and IsHexChar(ValueBuff[Pos + 1]) and IsHexChar(ValueBuff[Pos + 2]) then
    begin
      Buff[Cnt] := (H2BConvert[ValueBuff[Pos + 1]]) shl 4 or H2BConvert[ValueBuff[Pos + 2]];
      Inc(Pos, 3);
    end
    else
    begin
      if {(TDecodeOption.PlusAsSpaces in Options) and }(ValueBuff[Pos] = Ord('+')) then
        Buff[Cnt] := Ord(' ')
      else
        Buff[Cnt] := ValueBuff[Pos];
      Inc(Pos);
    end;
    Inc(Cnt);
  end;
  Result := TEncoding.UTF8.GetString(Buff, 0 , Cnt);
end;

function AsWin1251(const aInput:string) : string;
begin
Result:=StringOf(TEncoding.Convert(TEncoding.UTF8,TEncoding.Default,BytesOf(aInput)));
end;

function Win1251ToUTF8(const aInput:string) : string;
begin
Result:=StringOf(TEncoding.Convert(TEncoding.Default,TEncoding.UTF8,BytesOf(aInput)));
end;

function UTF8ToWin1251(const aInput:string) : string;
begin
Result:=StringOf(TEncoding.Convert(TEncoding.UTF8,TEncoding.Default,BytesOf(aInput)));
end;

(*
 const D0_str1 : UTF8String = 'ÐÐ°Ð·Ð¾Ð²ÑÐ¹ ÐºÐ°ÑÐ´Ð¸Ð³Ð°Ð½ Ñ V-Ð¾Ð±ÑÐ°Ð·Ð½ÑÐ¼ Ð²ÑÑÐµÐ·Ð¾Ð¼';

 const D0_str2 : string ='ÐÐ°Ð·Ð¾Ð²ÑÐ¹ ÐºÐ°ÑÐ´Ð¸Ð³Ð°Ð½ Ð¸Ð· ÑÐ¼ÐµÑÐ°Ð½Ð½Ð¾Ð¹ Ð¿ÑÑÐ¶Ð¸ Ñ V â Ð¾Ð±ÑÐ°Ð·Ð½ÑÐ¼ Ð²ÑÑÐµÐ·Ð¾Ð¼, Ð·Ð°ÑÑÐµÐ³Ð¸Ð²Ð°ÐµÑÑÑ Ð½Ð° Ð¿ÑÐ³Ð¾Ð²Ð¸ÑÐ°Ñ Ð²Ð¿ÐµÑ'+'ÐµÐ´Ð¸, Ñ Ð½ÐµÐ±Ð¾Ð»ÑÑÐ¸Ð¼Ð¸ ÑÑÑÐ°Ð¼Ð¸ Ð¿Ð¾ Ð¿Ð¾Ð´Ð¾Ð»Ñ, Ð²Ð½ÑÑÑÐµÐ½Ð½Ð¸Ð¹ Ð²ÑÑÐµÐ· Ð¾Ð±ÑÐ°Ð±Ð¾ÑÐ°Ð½ Ð²ÐµÐ»ÑÑÐ¾'+'Ð²Ð¾Ð¹ Ð»ÐµÐ½ÑÐ¾Ð¹. ÐÐµÐ·Ð°Ð¼ÐµÐ½Ð¸Ð¼ÑÐ¹ Ð½Ð°ÑÑÐ´ Ð´Ð»Ñ Ð·Ð¸Ð¼Ñ';
 procedure TForm1.SpeedButton13Click(Sender: TObject);
 var
 bt : array of byte;
 cnt : integer;
 ind : integer;
 begin
 for cnt:=1 to Length(D0_str2)
 do begin
 ind:=Length(bt);
 SetLength(bt,ind+1);
 if D0_str2[cnt]='Ð' then bt[ind]:=$D0 else
 if D0_str2[cnt]='Ñ' then bt[ind]:=$D1 else
 bt[ind]:=byte(D0_str2[cnt]) ;
 end;
 if Length(bt)>0 then ShowMessageInfo(UTF8From2BytesString_D0(bt));
 end;
*)

(*Определение типа строки (с "D0"("D1") или с "P"("Q") кодировками) ---------*)
function _StringOf(const aBytes: array of Byte):string;
var
  bytes: TBytes;
begin
  Result := '';
  if Length(aBytes)= 0 then
    Exit;
  try
    SetLength(bytes, Length(aBytes));
    System.Move(aBytes[0], bytes[0], Length(aBytes));
    Result := StringOf(bytes);
  finally
    SetLength(bytes, 0);
  end;
end;

//-- а в других помечено как KOI-8R
//Subject: =?UTF-8?B?UmU6INCf0L7QtNGC0LLQtdGA0LTQuNGC0LUg0JLQsNGIINC30LDQutCw0Lch?=

function IsD0string(const aBytes: TBytes): boolean;
var
  cnt: integer;
  ln: integer;
  num: integer;
begin
  Result := false;
  ln := Length(aBytes);
  if ln = 0 then
    Exit;
  num := 0;
  for cnt := Low(aBytes)to High(aBytes)do
    Inc(num, integer((aBytes[cnt]= $D0)or(aBytes[cnt]= $D1)));
  Result :=((num /(ln / 100))>= 33);
  //or (DetectUTF8Encoding(RawByteString(StringOf(aBytes))) = etUSASCII);
end;

function IsD0string(const aBytes: array of Byte): boolean;
var
  cnt: integer;
  ln: integer;
  num: integer;
begin
  Result := false;
  ln := Length(aBytes);
  if ln = 0 then
    Exit;
  num := 0;
  for cnt := Low(aBytes)to High(aBytes)do
    Inc(num, integer((aBytes[cnt]= $D0)or(aBytes[cnt]= $D1)));
  Result :=((num /(ln / 100))>= 33);
  //or (DetectUTF8Encoding(RawByteString(_StringOf(aBytes))) = etUSASCII);
end;

function IsPQstring(const aBytes: TBytes): boolean;
var
  cnt: integer;
  ln: integer;
  num: integer;
begin
  Result := false;
  ln := Length(aBytes);
  if ln = 0 then
    Exit;
  num := 0;
  for cnt := Low(aBytes)to High(aBytes)do
    Inc(num, integer((aBytes[cnt]= 80)or(aBytes[cnt]= 81)));
  Result :=((num /(ln / 100))>= 33);
  //or (DetectUTF8Encoding(RawByteString(StringOf(aBytes))) = etUTF8);
end;

function IsPQstring(const aBytes: array of Byte): boolean;
var
  cnt: integer;
  ln: integer;
  num: integer;
begin
  Result := false;
  ln := Length(aBytes);
  if ln = 0 then
    Exit;
  num := 0;
  for cnt := Low(aBytes)to High(aBytes)do
    Inc(num, integer((aBytes[cnt]= 80)or(aBytes[cnt]= 81)));
  Result :=((num /(ln / 100))>= 33);
  //(DetectUTF8Encoding(RawByteString(_StringOf(aBytes))) = etUTF8);
end;

(*Определение 4 байтовых символов в строке и упаковка в 2 байта -------------*)
function Is4bytesString(const aBytes: TBytes): boolean;
var
  cnt: integer;
  ln: integer;
  num: integer;
begin
  Result := false;
  ln := Length(aBytes);
  if ln = 0 then
    Exit;
  num := 0;
  for cnt := Low(aBytes)to High(aBytes)do
    Inc(num, integer(aBytes[cnt]= 0));
  Result :=(num /(ln / 100))>= 50;
end;

procedure Pack4bytes2bytes(var aBytes: TBytes);
var
  cnt: integer;
  tmpBytes: TBytes;
  ind: integer;
begin
  SetLength(tmpBytes, 0);
  cnt := 0;
  while cnt <= High(aBytes)do
  begin
    ind := Length(tmpBytes);
    SetLength(tmpBytes, ind + 1);
    tmpBytes[ind]:= aBytes[cnt];
    Inc(cnt, 2);
  end;
  SetLength(aBytes, Length(tmpBytes));
  System.Move(tmpBytes[0], aBytes[0], Length(tmpBytes));
end;

function Base64_DecodeString(const Value:string):string;
var
  bytes: TBytes;
begin
  try
    (*old*)bytes := DecodeBase64(AnsiString(Value));
    (*old*)Result := StringOf(bytes);
    Result := StringReplace(Result, #$A#$A, crlf,[rfReplaceAll]);
    (*почему-то #$D*)
  finally
    SetLength(bytes, 0);
  end;
end;

function Base64_DecodeStringToStream(const Value:string; var aStream : TMemoryStream):integer;
var
  prepStr : string;
  bytes   : TBytes;
begin
Result:=0;
try
if Value='' then Exit;
prepStr:=Value;
prepStr:=StringReplace(prepStr,'#$A','',[rfReplaceAll]) ;
prepStr:=StringReplace(prepStr,'#$D','',[rfReplaceAll]) ;
bytes := DecodeBase64(AnsiString(prepStr));
if Length(bytes)>0
   then begin
   aStream.Write(bytes[0],Length(bytes));
   aStream.Position:=0;
   Result:=aStream.Size;
   end;
finally
SetLength(bytes, 0);
prepStr:='';
end;
end;

procedure Base64_DecodeStringAndSave(const Value, FileName:string);
var
  bytes: TBytes;
  fs: TfileStream;
begin
  //if FileExists(FileName)
  //then fs:=TFileStream.Create(FileName,fmOpenWrite)
  //else fs:=TFileStream.Create(FileName,fmCreate or fmOpenWrite);
  fs := TfileStream.Create(FileName, fmCreate);
  try
    bytes := DecodeBase64(AnsiString(Value));
    fs.Write(bytes[0], Length(bytes));
  finally
    fs.Free;
    SetLength(bytes, 0);
  end;
end;

function Base64_EncodeString(const Value:string):string;
var
  tmp: AnsiString;
  buf: PAnsiChar;
begin
  tmp := AnsiString(Value);
  buf := Allocmem(Length(tmp)+ 1);
  try
    StrPCopy(buf, tmp);
    tmp := EncodeBase64(buf, Length(tmp));
    Result := string(tmp);
  finally
    FreeMem(buf);
  end;
end;



function Base64_EncodeImageFile(const aFileName:string):string;
var
  ext:string;
  _dt:string;
  fs: TfileStream;
  bytes: PAnsiChar;
begin
  Result := '';
  if not FileExists(aFileName)then
    Exit;
  ext := AnsiUpperCase(ExtractFileExt(aFileName));
  _dt := AboutPictureType(ext);
  if _dt = '' then
    Exit;
  fs := TfileStream.Create(aFileName, fmOpenRead or fmShareDenyWrite);
  //or fmShareCompat);
  try
    if fs.Size = 0 then
      Exit;
    fs.Position := 0;
    bytes := Allocmem(fs.Size);
    try
      fs.ReadBuffer(bytes^, fs.Size);
      Result := '"data:' + _dt + ';base64,' +
        string(EncodeBase64(bytes, fs.Size))+ '"';
    finally
      FreeMem(bytes);
    end;
  finally
    fs.Free;
  end;
end;



function Base64_EncodeFile(const aFileName:string):string;
var
  fs   : TfileStream;
  bytes: PAnsiChar;
begin
  Result := '';
  if not FileExists(aFileName)then Exit;
  fs := TfileStream.Create(aFileName, fmOpenRead or fmShareDenyWrite);
  try
    if fs.Size = 0 then Exit;
    fs.Position := 0;
    bytes := Allocmem(fs.Size);
    try
    fs.ReadBuffer(bytes^, fs.Size);
    Result := string(EncodeBase64(bytes, fs.Size));
    finally
    FreeMem(bytes);
    end;
  finally
  fs.Free;
  end;
end;


function Base64_EncodeStream(var aStream : TMemoryStream) : string;
var
  bytes: PAnsiChar;
begin
 Result := '';
 aStream.Position := 0;
 bytes := Allocmem(aStream.Size);
 try
 aStream.ReadBuffer(bytes^, aStream.Size);
 Result := string(EncodeBase64(bytes, aStream.Size));
 finally
 FreeMem(bytes);
 end;
Result:=StringReplace(Result,crlf,'',[rfReplaceAll]);
end;


function EncodeBytes(const aArray : array of byte) : string;
var
 tmp : AnsiString;
begin
Result:='';
try
if Length(aArray)=0 then Exit;
tmp:=EncodeBase64(@aArray[Low(aArray)],Length(aArray));
Result:=string(tmp);
except
  on E : Exception do ;//LogErrorMessage('EncodeBytes',E,[]);
end;
end;


   function GZip_CompressFile(const aSrc, aDest : string) : boolean;
   var
    fsSrc   : TFileStream;
    fsDest  : TFileStream;
   begin
   Result:=false;
   try
   fsSrc:=TFileStream.Create(aSrc,fmOpenRead or fmShareDenyNone);
   fsDest:=TFileStream.Create(aDest,fmCreate);
   try
   CompressStream(fsSrc, fsDest, clMax, zsGZip);
   finally
   fsSrc.free;
   fsDest.free;
   end;
   Result:=true;
   except
     on E : Exception do ;
   end;
   end;

   function GZip_DeCompressFile(const aSrc, aDest : string) : boolean;
   var
    fsSrc   : TFileStream;
    fsDest  : TFileStream;
   begin
   Result:=false;
   try
   fsSrc:=TFileStream.Create(aSrc,fmOpenRead or fmShareDenyNone);
   fsDest:=TFileStream.Create(aDest,fmCreate);
   try
   DeCompressStream(fsSrc, fsDest);
   finally
   fsSrc.free;
   fsDest.free;
   end;
   Result:=true;
   except
     on E : Exception do ;
   end;
   end;


   function GZip_CompressBuff(const aSrc : TBytes; var aDest : TBytes) : boolean;
   var
    outSize : cardinal;
    outPtr  : pointer;
   begin
   Result:=false;
   try
   try
   CompressBuf(aSrc,Length(aSrc),outPtr,outSize);
   Setlength(aDest,outSize);
   System.Move(outPtr^,aDest[0],outSize);
   finally
   FreeMem(outPtr);
   end;
   Result:=true;
   except
     on E : Exception do ;
   end;
   end;

   function GZip_DeCompressBuff(const aSrc : TBytes; var aDest : TBytes) : boolean;
   var
    outEst  : integer; // -- ??? должен быть больше 0, размер промежуточного буфера?, остается установленным
    outPtr  : Pointer;
    outSize : integer;
   begin
   Result:=false;
   try
   try
   outEst:=0;
   DecompressBuf(aSrc,Length(aSrc),outEst,outPtr,outSize);
   Setlength(aDest,outSize);
   System.Move(outPtr^,aDest[0],outSize);
   finally
   FreeMem(outPtr);
   end;
   Result:=true;
   except
     on E : Exception do ;
   end;
   end;



 // -- подмога вот здесь :
 // http://forum.sources.ru/index.php?showtopic=201707&view=showall
 // http://www.programmersforum.ru/showthread.php?t=69851
 // -- aZIPName : имя сжатой ZIP папки
 // -- aSysObjectName : имя файла или папки для упаковки в aZIPName
procedure ZipSysObject(const aZIPName, aSysObjectName : string);
// -- идентичный заголовок делает Windows при создании сжатой папки
const ziphdr : array[0..21] of byte = ($50,$4B,$05,$06,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00);
var
  FS        : TFileStream;
  res       : HRESULT;
  pISD      : IShellDispatch;
  vDir      : OleVariant;
  vFlag     : OleVariant;
  vSysObj   : OleVariant;
  toFolder  : Folder;
begin
try
if not FileExists(aZIPName)
   then begin
   FS:=TFileStream.Create(aZIPName,fmCreate);
   try
   FS.Write(ziphdr[0],Length(ziphdr));
   finally
   FS.Free;
   end;
   end;
if not FileExists(aZIPName)
   then Exit;
CoInitialize(nil);
try
res:= CoCreateInstance(CLSID_Shell, nil, CLSCTX_INPROC_SERVER,IID_IShellDispatch, pISD);
if Succeeded(res)
   then begin
   vDir:=aZIPName;
   res:=pISD.NameSpace(vDir, ToFolder);
   if Succeeded(res)
      then begin
      vSysObj:=aSysObjectName;
      vFlag:=4; // Do not display a progress dialog box
      res := ToFolder.CopyHere(vSysObj, vFlag);
      if Succeeded(res) then ;
      end;
   end;
finally
vSysObj:=Unassigned;
vFlag:=Unassigned;
vDir:=Unassigned;
CoUninitialize();
end;
except
on E : Exception do ;
end;
end;



procedure GetZipObjectList(const aZIPName : string; var aZOL : TZipFolderObjectList);
var
  res          : HRESULT;
  pISD         : IShellDispatch;
  vZipDir      : OleVariant;
  ZipFolder    : Folder;
  ZipItems     : FolderItems;
  OneItem      : FolderItem;
  itemsCount   : integer;
  cnt          : integer;
  itemName     : WideString;
  isFld        : smallint;
  ind          : integer;
begin
try
CoInitialize(nil);
try
res:= CoCreateInstance(CLSID_Shell, nil, CLSCTX_INPROC_SERVER,IID_IShellDispatch, pISD);
if Succeeded(res)
   then begin
   vZipDir:=aZIPName;
   res:=pISD.NameSpace(vZipDir, ZipFolder);
   if Succeeded(res)
      then begin
      res:=ZipFolder.Items(ZipItems);
      if not Succeeded(res) then Exit;
      res:=ZipItems.get_Count(itemsCount);
      if not Succeeded(res) then Exit;
      cnt:=0;
      while cnt<itemsCount
         do begin
         res:=ZipItems.Item(cnt, OneItem);
         if not Succeeded(res) then Break;
         res:=OneItem.get_IsFolder(isFld);
         if not Succeeded(res) then Break;
         res:=OneItem.get_Name(itemName);
         if not Succeeded(res) then Break;
         ind:=Length(aZOL);
         SetLength(aZOL,ind+1);
         aZOL[ind].IsFolder:=isFld<>0;
         Str2AC(aZIPName+'\'+string(itemName), aZOL[ind].Name);
         if aZOL[ind].IsFolder
            then GetZipObjectList(AC2Str(aZOL[ind].Name), aZOL);
         inc(cnt);
         end;
      end;
   end;
finally
vZipDir :=Unassigned;
CoUninitialize();
end;
except
on E : Exception do ;
end;
end;


// -- aZIPName        : имя сжатой ZIP папки
// -- aUnZIPName      : имя папки-приемника распаковвываемых объектов (файлы, папки)
// -- aSysObjectsName : список имен файлов или папок для распаковки
procedure UnzipSysObjects(const aZIPName, aUnZIPName : string; const aSysObjectsName : TStringDynArray);
var
  res          : HRESULT;
  pISD         : IShellDispatch;
  vZipDir      : OleVariant;
  vFlag        : OleVariant;
  vUnZipDir    : OleVariant;
  vSysObj      : OleVariant;
  UnZipFolder  : Folder;
  cnt          : integer;
begin
try
CoInitialize(nil);
try
res:= CoCreateInstance(CLSID_Shell, nil, CLSCTX_INPROC_SERVER,IID_IShellDispatch, pISD);
if Succeeded(res)
   then begin
   vZipDir:=aZIPName;
   vUnZipDir:=aUnZIPName;
   res:=pISD.NameSpace(vUnZipDir, UnZipFolder);
   if Succeeded(res)
      then begin
      for cnt:=0 to High(aSysObjectsName)
        do begin
        try
        vSysObj:=aSysObjectsName[cnt];
        vFlag:=4; // Do not display a progress dialog box
        res := UnZipFolder.CopyHere(vSysObj, vFlag);
        if Succeeded(res) then ;
        except
        end;
        end;
      end;
   end;
finally
vZipDir :=Unassigned;
vFlag :=Unassigned;
vUnZipDir:=Unassigned;
vSysObj :=Unassigned;
CoUninitialize();
end;
except
on E : Exception do ;
end;
end;


function SendTextMessage1(Handle: HWND; Msg: UINT; WParam: UnicodeString; LParam: Integer): LRESULT;
begin
Result := SendMessage(Handle, Msg, Windows.WParam(PWideChar(WParam)), LParam);
end;

function SendTextMessage2(Handle: HWND; Msg: UINT; WParam: UnicodeString;LParam: UnicodeString): LRESULT;
begin
Result := SendMessage(Handle, Msg, Windows.WParam(PWideChar(WParam)),Windows.LParam(PWideChar(LParam)));
end;

function TextFromParam(Param : integer) : string;
begin
Result:=StrPas(PChar(Param));
end;

function NormalChar(aChar: char): boolean;
//var
//isRusSymb : boolean;
//cnt       : integer;
begin
  Result := StrScan(NormCharsW, aChar)<> nil;
  //isRusSymb:=false;
  //for cnt:=0 to High(RUSsymb)
  //do if aChar=RUSchars[cnt]
  //then begin
  //isRusSymb:=true;
  //Break;
  //end;
  //Result:= isRusSymb or
  // //CharInSet(aChar,RUSsymbSCS) or
  //CharInSet(aChar, NumberSCS) or
  //(ansichar(aChar) in [#65..#90]) or (ansichar(aChar) in [#97..#122])
end;

function NormalChar(aChar: ansichar): boolean;
begin
  Result := StrScan(NormCharsA, aChar)<> nil;
end;

function CharInString(aChar: char;const aString:string): boolean;
begin
  Result := StrScan(PChar(aString), aChar)<> nil;
end;

function CharInString(aChar: ansichar;const aString:string): boolean;

begin
  Result := StrScan(PAnsiChar(AnsiString(aString)), aChar)<> nil;
end;


function IsRusChar(aChar: char): boolean;
begin
Result := StrScan(RusCharsW, aChar)<> nil;
end;

(*Получение строки из массива символов --------------------------------------*)

function GetString(const aArrChar: array of char):string;

begin
  Result := StrPas(PChar(@aArrChar[Low(aArrChar)]));
end;

(*Получение папки на aUpLevels выше указанной*)

function UpDirectoryN(const aDirectory:string;const aUpLevels: integer):string;
var
  prev: string;
  tmpS: string;
  tmpI: integer;
begin
  tmpI := aUpLevels;
  tmpS := SetTailBackSlash(Trim(aDirectory), false);
  Result := tmpS;
  while tmpI > 0 do
  begin
    prev:=tmpS;
    tmpS := SetTailBackSlash(ExtractFilePath(tmpS), false);
    if prev=tmpS
       then begin
       Result:=GetDesktopFolder;
       Exit;
       end;
    Dec(tmpI);
  end;
  Result := SetTailBackSlash(tmpS, true);
end;

(*Поиск первой существующей папки верхнего уровня от указанной ---------------*)
function GetFirstExistsFolder(const aStartDir : string) : string;
var
 prev : string;
begin
Result:=aStartDir;
while not DirectoryExists(Result) and (Result<>'')
  do begin
  prev:=Result;
  Result:=UpDirectoryN(Result,1);
  if prev=Result
     then Result:='';
  end;
end;

(*Получение имени файла из URL (методом поиска первого с конца разделителя) -*)
function ExtractFileNameFromURL(const aURL:string):string;
var
  cnt: integer;
begin
  Result := '';
  if aURL = '' then
    Exit;
  cnt := Length(aURL);
  while(aURL[cnt]<> '/')and(cnt > 0)do
    Dec(cnt);
  if cnt > 0 then
    Result := StringReplace(Copy(aURL, cnt + 1, Length(aURL)), '%20', ' ',
      [rfReplaceAll]);
end;

(*Получение имени файла из URL (методом StringReplace) ----------------------*)
function ExtractFileNameFromURL2(const aURL:string):string;
begin
  Result := StringReplace(ExtractFileName(StringReplace(aURL, '/', '\',
    [rfReplaceAll])), '%20', ' ',[rfReplaceAll]);
end;

(*Получение поисковой строки из указанного шаблона (aSearchShablon)*)
function FormatSearchString(const aSearchShablon, aSearchValue:string):string;
begin
  Result := 'http://';
  if(aSearchShablon = '')or(Pos('{0}', aSearchShablon)= 0)or
    (aSearchValue = '')then
    Exit;
  Result := StringReplace(aSearchShablon, '{0}', aSearchValue,[rfReplaceAll]);
end;

function FormatSearchString(const aSearchShablon:string;
  aValues: array of const):string;
var
  cnt: integer;
begin
  Result := aSearchShablon;
  for cnt := 0 to High(aValues)do
    Result := StringReplace(Result, Format('{%d}',[cnt]), GDV(aValues[cnt]),[]);
end;

(*Получение результатов запроса по ссылке(файл, страница, запрос-XML) в файл*)
function DownloadFile(const SourceURL, DestFile:string): boolean;
begin
  try
    Result := UrlDownloadToFile(nil, PChar(SourceURL), PChar(DestFile),
      0,nil)= 0;
  except
    Result := false;
  end;
end;

function CreateAndConnect(const aFTPHost, aFTPFolder, aFTPLogin,
  aFTPPassword:string; aFTPPort: integer;var aFTP: TidFTP): boolean;
var
  folder_Exist: boolean;
  erc: integer;
  tmp:string;
begin
  Result := false;
  try
    folder_Exist := false;
    aFTP := TidFTP.Create(nil);
    with aFTP do
    begin
      Host := aFTPHost;
      Port := aFTPPort;
      Username := aFTPLogin;
      Password := aFTPPassword;
      Passive := true;
      Connect;
      if Connected then
      begin
        try
          ChangeDir(aFTPFolder);
          folder_Exist := true;
        except
          folder_Exist := false;
        end;
      end;
      Result := Connected and folder_Exist;
    end;
  except
    on E: Exception do
    begin
      erc := GetLastError;
      tmp := Format(FormatDateTime('dd.mm.yyyy hh:nn:ss', Now)+
        ' : Error "CreateAndConnect" to "%s" on "%s": %s (%s)',
        [aFTPFolder, aFTPHost, E.Message, GetErrorString(erc)]);
    end;
  end;
end;

function CopyFileToFTP(const aFTPHost, aFTPFolder, aFTPLogin,
  aFTPPassword:string; aFTPPort: integer;const aLocalFileName:string): boolean;
var
  files: TStringDynArray;
begin
  SetLength(files, 1);
  try
    files[0]:= aLocalFileName;
    Result := CopyFilesToFTP(aFTPHost, aFTPFolder, aFTPLogin, aFTPPassword,
      aFTPPort, files);
  finally
    SetLength(files, 0);
  end;
end;

function CopyFilesToFTP(const aFTPHost, aFTPFolder, aFTPLogin,
  aFTPPassword:string; aFTPPort: integer;
  const aLocalFileNames: TStringDynArray): boolean;
var
  cnt: integer;
  erc: integer;
  ers:string;
  aFTP: TidFTP;
begin
  Result := false;
  try
    if CreateAndConnect(aFTPHost, aFTPFolder, aFTPLogin, aFTPPassword, aFTPPort,
      aFTP)then
    begin
      try
        for cnt := 0 to High(aLocalFileNames)do
          try
            aFTP.Put(aLocalFileNames[cnt],
              ExtractFileName(aLocalFileNames[cnt]), false);
          except
            on E: Exception do
            begin
              erc := GetLastError;
              ers := Format
                ('Ошибка при копировании "%s" на "%s" в папку "%s" : %s. %s',
                [aLocalFileNames[cnt], aFTPHost, aFTPFolder, E.Message,
                GetErrorString(erc)]);
              ShowMessageWarning(ers);
              Exit;
            end;
          end;
      finally
        if Assigned(aFTP)then
        begin
          if aFTP.Connected then
            aFTP.Disconnect;
          FreeAndNil(aFTP);
        end;
      end;
    end;
    Result := true;
  except
    on E: Exception do
    begin
    end;
  end;
end;

function CopyFilesToFTPNoExists(const aFTPHost, aFTPFolder, aFTPLogin,
  aFTPPassword:string; aFTPPort: integer;
  const aLocalFileNames: TStringDynArray): boolean;
var
  cnt: integer;
  erc: integer;
  ers:string;
  fn:string;
  aFTP: TidFTP;
begin
  Result := false;
  try
    if CreateAndConnect(aFTPHost, aFTPFolder, aFTPLogin, aFTPPassword, aFTPPort,
      aFTP)then
    begin
      try
        for cnt := 0 to High(aLocalFileNames)do
          try
            fn := ExtractFileName(aLocalFileNames[cnt]);
            if aFTP.FileDate(fn)= 0 then
              aFTP.Put(aLocalFileNames[cnt], fn, false);
          except
            on E: Exception do
            begin
              erc := GetLastError;
              ers := Format
                ('Ошибка при копировании "%s" на "%s" в папку "%s" : %s. %s',
                [aLocalFileNames[cnt], aFTPHost, aFTPFolder, E.Message,
                GetErrorString(erc)]);
              ShowMessageWarning(ers);
              Exit;
            end;
          end;
      finally
        if Assigned(aFTP)then
        begin
          if aFTP.Connected then
            aFTP.Disconnect;
          FreeAndNil(aFTP);
        end;
      end;
    end;
    Result := true;
  except
    on E: Exception do
    begin
    end;
  end;
end;

(*Чтение из открытого в другой программе текстового файла ------------------*)
function ReadBusyFileIntoString(const aFileName:string):string;
var
  PSA: PSecurityAttributes;
  hFile: cardinal;
  FileSize: cardinal;
  buf: PAnsiChar;
  ReadSize: cardinal;
begin
  buf := nil;
  Result := '';
  CreatePSA(PSA);
  hFile := CreateFile(PChar(aFileName), GENERIC_READ, FILE_SHARE_READ or
    FILE_SHARE_WRITE, PSA, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  try
    if hFile <> INVALID_HANDLE_VALUE then
    begin
      FileSize := GetFileSize(hFile,nil);
      buf := Allocmem(FileSize + 1);
      ReadFile(hFile, buf^, FileSize, ReadSize,nil);
      Result := string(StrPas(buf));
    end
    else
    begin
      ShowMessageWarning(GetErrorString(GetLastError));
    end;
  finally
    if buf <> nil then
      FreeMem(buf);
    CloseHandle(hFile);
    FreeMem(PSA);
  end;
end;

(*----------------------------------------------------------------------------*)

var
  _FNO:string;//FileNameOnly
  _SD: PChar;//Start Dir

function BCBP(_hwnd: cardinal; UMsg, WParam, LParam: DWORD): integer; stdcall;
var
  lpBuffer: PChar;
  pt:string;
begin
  if UMsg = BFFM_SELCHANGED then
  begin
    if LParam <> 0 then
    begin
      lpBuffer := Allocmem(MAX_PATH_EX * SizeOfChar + 1);
      (SHGetPathFromIDList(Ptr(WParam), lpBuffer));
      {Вариант 2}
      if(StrPas(lpBuffer)<> '')then
        if StrPas(lpBuffer)[Length(StrPas(lpBuffer))]<> '\' then
          pt := StrPas(lpBuffer)+ '\'
        else
          pt := StrPas(lpBuffer);
      if(_FNO = '')or(_FNO = '*.*')then
        SendMessage(_hwnd, BFFM_ENABLEOK, 0, 1)
      else
        SendMessage(_hwnd, BFFM_ENABLEOK, 0, integer(FileExists(pt + _FNO)));
      {Вариант 1 - ПЕРЕСТАЛ РАБОТАТЬ! ??? 27.11.2002}
      //if SysUtils.FileSearch(_FNO, StrPas(lpBuffer))<>''
      //then SendMessage(_hwnd,BFFM_ENABLEOK,0,1)
      //else SendMessage(_hwnd,BFFM_ENABLEOK,0,0);
      //SendMessage(_hwnd,BFFM_ENABLEOK,0,Integer(FileSearch(_FNO, StrPas(lpBuffer))<>''));
      SendMessage(_hwnd, BFFM_SETSTATUSTEXT, 1, integer(lpBuffer));
      FreeMem(lpBuffer);
    end;
  end
  else if UMsg = BFFM_INITIALIZED then
  begin
    SendMessage(_hwnd, BFFM_SETSELECTION, 1, integer(_SD));
  end;
  BCBP := 0;
end;

function SetFolder(_hwnd: integer;const FileName:string; StartDir: PChar;
  TT: PChar):string;
var
  bi: TbrowseInfo;
  pidlBrowse: PItemIDList;
  pidlStart: PItemIDList;
  lpBuffer: PChar;
const
  Str: PChar = 'C:\';
begin
  CoInitialize(nil);
  FillChar(bi, SizeOf(TbrowseInfo), 0);
  lpBuffer := Allocmem(MAX_PATH_EX * SizeOfChar + 1);
  try
    try
      _FNO := FileName;
      _SD := StartDir;
      SHGetSpecialFolderLocation(_hwnd, integer(@Str){CSIDL_DESKTOP},
        pidlStart);
      bi.iImage := 1;
      bi.hwndOwner := _hwnd;
      bi.pidlRoot := pidlStart;
      bi.pszDisplayName := lpBuffer;
      bi.lpszTitle := TT;
      bi.ulFlags := BIF_RETURNONLYFSDIRS or BIF_STATUSTEXT or
        BIF_NEWDIALOGSTYLE or BIF_EDITBOX or
      //BIF_SHAREABLE or // отключает показ сетевых дисков
        BIF_UAHINT or BIF_DONTGOBELOWDOMAIN;//? не работает ?
      bi.lpfn :=@BCBP;
      bi.LParam := 1;
      pidlBrowse := SHBrowseForFolder(bi);
      if Assigned(pidlBrowse)then
      begin
        (SHGetPathFromIDList(pidlBrowse, lpBuffer));
        Result := StrPas(lpBuffer);
      end;
    except
    end;
  finally
    FreeMem(lpBuffer);
    CoUninitialize;
  end;
end;

(*Получение TIcon ассоциированное с расширением или файлом*)
//-- пример вызова --
//procedure TForm1.SpeedButton1Click(Sender: TObject);
//var
//ico : TIcon;
//begin
//ico:=TIcon.Create;
//try
//GetAssociatedIcon(Edit1.Text,ico);
//Image1.Picture.Icon.Assign(ico);
//finally
//FreeAndNil(ico);
//end
//end;
function GetAssociatedIcon(const aExtOrName:string;var aIcon: TIcon; aNumIco: Word = 0): boolean;
var
  fn:string;
  del: boolean;
  num: Word;
begin
  del := false;
  Result := false;
  try
    if(aExtOrName = '')then   Exit;
    fn := AnsiUpperCase(aExtOrName);
    try
    if not FileExists(fn)
       then begin
       if fn[1]<> '.' then fn := '.' + fn;
       fn := SetTailBackSlash(GetTempFolder)+ FormatDateTime('yyyymmddhhnnsszzz', Now)+ fn;
       SaveStringIntoFile(BulletChar, fn);
       del := true;
       end;
      num := aNumIco;
      aIcon.Handle := ExtractAssociatedIcon(HInstance, PChar(fn), num);
      Result := aIcon.Handle > 0;
    finally
    if del and FileExists(fn)then DeleteFile(fn);
    end;
  except
    on E: Exception do CreateErrorMessage('GetAssociatedIcon', E,[aExtOrName], true);
  end;
end;


  function IS_INTRESOURCE(lpszType: PChar): BOOL;
  begin
  Result := ULONG_PTR(lpszType) shr 16 = 0;   // -- Windows.pas line 32955  (analog)
  end;

  function EnumIcon(hMod : HMODULE; lpszType, lpszName: PChar; lParam: integer) : BOOL;//stdcall;
  begin
  if boolean(IS_INTRESOURCE(lpszName))
     then TStrings(lParam).Add(IntToStr(Integer(lpszName)))
     else TStrings(lParam).Add(lpszName);
  Result := True;
  end;

  procedure EnumRes(const aSysDLL : string;var aStrs : TStringDynArray; aIsGroup : boolean);
  var
   hLib : cardinal;
   cnt  : integer;
   strl : TStringList;
   tmp : string;
  begin
  Setlength(aStrs,0);
  //hLib:=LoadModule(PAnsiChar(AnsiString(aSysDLL)),nil);
  hLib:=LoadLibraryEx(PChar(aSysDLL),0,LOAD_LIBRARY_AS_DATAFILE_EXCLUSIVE and LOAD_LIBRARY_AS_IMAGE_RESOURCE);
  if hLib=0 then Exit;
  strl:=TStringList.Create;
  try
  if aIsGroup
     then EnumResourceNames(hLib,RT_GROUP_ICON,@EnumIcon,integer(strl))
     else EnumResourceNames(hLib,RT_ICON,@EnumIcon,integer(strl));
  ;
  tmp:=GetErrorString(GetLastError);
  if strl.count=0 then strl.add(tmp);
  SetLength(aStrs,strl.Count);
  for cnt:=0 to strl.Count-1 do aStrs[cnt]:=strl[cnt];
  finally
  FreeStringList(strl);
  FreeLibrary(hLib);
  end;
  end;

  function GetIcon(const aSysDLL ,aName : string; var aIcon : TIcon; aIsGroup : boolean) : boolean;
  var
   hLib : cardinal;
   res  : hrsrc;
   hndl : cardinal;
   rn   : PChar;
  begin
  Result:=false;
  hLib:=LoadLibraryEx(PChar(aSysDLL),0,LOAD_LIBRARY_AS_DATAFILE_EXCLUSIVE and LOAD_LIBRARY_AS_IMAGE_RESOURCE);
  if hLib=0 then Exit;
  try
  if CheckValidInteger(aName) // -- без всяких AllocMem  - FreeMem (AV и другая веселая шняга!)
     then rn:=MAKEINTRESOURCE(word(StrToInt(aName)))
     else rn:=PChar(aName);
  if aIsGroup
     then res:=FindResource(hLib, rn ,RT_GROUP_ICON)
     else res:=FindResource(hLib, rn ,RT_ICON);
  if res=0 then Exit;
  hndl:=LoadIcon(hLib, rn);
  if hndl=0 then Exit;
  aIcon:=TIcon.Create;
  aIcon.Handle:=hndl;
  Result:=true;
  finally
  FreeLibrary(hLib);
  end;
  end;


(*--------------------------------------------------------------------------*)
//Это для работы самого меню, как оконного элемента
function MenuCallback(Wnd: HWND; Msg: UINT; WParam: WParam; LParam: LParam)
  : LRESULT; stdcall;
var
  ContextMenu2: IContextMenu2;
begin
  case Msg of
    WM_CREATE:
      begin
        ContextMenu2 := IContextMenu2(PCreateStruct(LParam).lpCreateParams);
        SetWindowLong(Wnd, GWL_USERDATA, Longint(ContextMenu2));
        Result := DefWindowProc(Wnd, Msg, WParam, LParam);
      end;
    WM_INITMENUPOPUP:
      begin
        ContextMenu2 := IContextMenu2(GetWindowLong(Wnd, GWL_USERDATA));
        ContextMenu2.HandleMenuMsg(Msg, WParam, LParam);
        Result := 0;
      end;
    WM_DRAWITEM, WM_MEASUREITEM:
      begin
        ContextMenu2 := IContextMenu2(GetWindowLong(Wnd, GWL_USERDATA));
        ContextMenu2.HandleMenuMsg(Msg, WParam, LParam);
        Result := 1;
      end;
  else
    Result := DefWindowProc(Wnd, Msg, WParam, LParam);
  end;
end;

//Это для создания самого меню, как оконного элемента
function CreateMenuCallbackWnd(const ContextMenu: IContextMenu2): HWND;
const
  IcmCallbackWnd = 'ICMCALLBACKWND';
var
  WndClass: TWndClass;
begin
  FillChar(WndClass, SizeOf(WndClass), #0);
  WndClass.lpszClassName := PChar(IcmCallbackWnd);
  WndClass.lpfnWndProc :=@MenuCallback;
  WndClass.HInstance := HInstance;
  Windows.RegisterClass(WndClass);
  Result := CreateWindow(IcmCallbackWnd, IcmCallbackWnd, WS_POPUPWINDOW, 0, 0,
    0, 0, 0, 0, HInstance, Pointer(ContextMenu));
end;

procedure GetFileContextMenu(const Path:String; MousePoint: TPoint;
  WC: TWinControl);
var
  CoInit: HResult;
  aResult: HResult;
  CommonDir:String;
  FileName:String;
  Desktop: IShellFolder;
  ShellFolder: IShellFolder;
  pchEaten: cardinal;
  Attr: cardinal;
  PathPIDL: PItemIDList;
  FilePIDL: array[0 .. 1]of PItemIDList;
  ShellContextMenu: HMenu;
  ICMenu: IContextMenu;
  ICMenu2: IContextMenu2;
  PopupMenuResult: BOOL;
  CMD: TCMInvokeCommandInfo;
  M: IMAlloc;
  ICmd: integer;
  CallbackWindow: HWND;
  pt: TPoint;

begin
  //Первичная инициализация
  FillChar(FilePIDL, SizeOf(PItemIDList)* Length(FilePIDL), 0);
  System.Move(MousePoint, pt, SizeOf(TPoint));
  ClientToScreen(WC.Handle, pt);
  ShellContextMenu := 0;
  Attr := 0;
  PathPIDL := nil;
  CallbackWindow := 0;
  CoInit := CoInitializeEx(nil, COINIT_MULTITHREADED);
  //CoInit := CoInitialize(nil);
  try
    //Получаем пути и имя фала
    FileName := ExtractFileName(Path);
    CommonDir := ExtractFilePath(Path);

    //Получаем указатель на интерфейс рабочего стола
    if SHGetDesktopFolder(Desktop)<> S_OK then
      RaiseLastOSError;
    //Если работаем с папкой
    if FileName = '' then
    begin
      //CommonDir:=SetTailBackSlash(CommonDir, false);
      //Получаем указатель на папку "Мой компьютер"
      if(SHGetSpecialFolderLocation(0, CSIDL_DRIVES, PathPIDL)<> S_OK)or
        (Desktop.BindToObject(PathPIDL,nil, IID_IShellFolder,
        Pointer(ShellFolder))<> S_OK)then
        RaiseLastOSError;
      //Получаем указатель на директорию
      ShellFolder.ParseDisplayName(WC.Handle,nil, StringToOleStr(CommonDir),
        pchEaten, FilePIDL[0], Attr);
      //Получаем указатель на контектсное меню папки
      //AResult := ShellFolder.GetUIObjectOf(WC.Handle, 1, FilePIDL[0], IID_IContextMenu, nil, Pointer(ICMenu));
      aResult := ShellFolder.GetUIObjectOf(WC.Handle, 1, FilePIDL[0],
        IID_IContextMenu,nil, ICMenu);
    end
    else
    begin
      //Получаем указатель на папку "Мой компьютер"
      if(Desktop.ParseDisplayName(WC.Handle,nil, StringToOleStr(CommonDir),
        pchEaten, PathPIDL, Attr)<> S_OK)or
        (Desktop.BindToObject(PathPIDL,nil, IID_IShellFolder,
        Pointer(ShellFolder))<> S_OK)then
        RaiseLastOSError;
      //Получаем указатель на файл
      ShellFolder.ParseDisplayName(WC.Handle,nil, StringToOleStr(FileName),
        pchEaten, FilePIDL[0], Attr);
      //Получаем указатель на контектсное меню файла
      aResult := ShellFolder.GetUIObjectOf(WC.Handle, 1, FilePIDL[0],
        IID_IContextMenu,nil, Pointer(ICMenu));
    end;
    //Если указатель на конт. меню есть, делаем так:
    if Succeeded(aResult)then
    begin
      ICMenu2 := nil;
      //Создаем меню
      ShellContextMenu := CreatePopupMenu;
      //Производим его наполнение
      if Succeeded(ICMenu.QueryContextMenu(ShellContextMenu, 0, 1, $7FFF,
        {CMF_EXPLORE or}CMF_NORMAL))then
        if Succeeded(ICMenu.QueryInterface(IContextMenu2, ICMenu2))then
          CallbackWindow := CreateMenuCallbackWnd(ICMenu2);
      try
        //Показываем меню
        PopupMenuResult := TrackPopupMenu(ShellContextMenu, TPM_LEFTALIGN or
          TPM_LEFTBUTTON or TPM_RIGHTBUTTON or TPM_RETURNCMD, pt.X//MousePoint.X
          , pt.Y//MousePoint.Y
          , 0, CallbackWindow,nil);
      finally
        ICMenu2 := nil;
      end;
      //Если был выбран какой либо пункт меню:
      if PopupMenuResult then
      begin
        //Индекс этого пункта будет лежать в ICmd
        ICmd := Longint(PopupMenuResult)- 1;
        //Заполняем структуру TCMInvokeCommandInfo
        FillChar(CMD, SizeOf(TCMInvokeCommandInfo), #0);
        with CMD do
        begin
          cbSize := SizeOf(TCMInvokeCommandInfo);
          HWND := WC.Handle;
          lpVerb := MakeIntResourceA(ICmd);
          nShow := SW_SHOWNORMAL;
        end;
        //Выполняем InvokeCommand с заполненной структурой
        aResult := ICMenu.InvokeCommand(CMD);
        if aResult <> S_OK then
          RaiseLastOSError;
      end;
    end;
  finally
    //Освобождаем занятые ресурсы чтобы небыло утечки памяти
    if FilePIDL[0]<> nil then
    begin
      //Для освобождения использем IMalloc
      SHGetMAlloc(M);
      if M <> nil then
        M.Free(FilePIDL[0]);
      M := nil;
    end;
    if PathPIDL <> nil then
    begin
      SHGetMAlloc(M);
      if M <> nil then
        M.Free(PathPIDL);
      M := nil;
    end;
    if ShellContextMenu <> 0 then
      DestroyMenu(ShellContextMenu);
    if CallbackWindow <> 0 then
      DestroyWindow(CallbackWindow);
    ICMenu := nil;
    ShellFolder := nil;
    Desktop := nil;
    if CoInit = S_OK then
      CoUninitialize;
  end;
end;


function GetSizeOfFile(const fn:string): int64;
var
  Search: TSearchRec;
begin
if FindFirst(fn, faAnyFile, Search)=0
   then try
        Result := Search.Size;
        finally
        FindClose(Search);
        end
  else Result :=-1;
end;

function GetFileName(const aInitDir, aFilter, aName, aDefExtWODot:string;
  aFilterInd: integer = 1):string;
var
  SD: TSaveDialog;
  dir:string;
  fn:string;
begin
  fn := '';
  SD := TSaveDialog.Create(Application.MainForm);
  try
    dir := aInitDir;
    if DirectoryExists(dir)then
      SD.InitialDir := dir
    else
    begin
      dir := ExtractFilePath(aName);
      if not DirectoryExists(dir)then
      begin
        dir := UpDirectoryN(dir, 1);
        while not DirectoryExists(dir)do
          dir := UpDirectoryN(dir, 1);
      end;
    end;
    SD.Filter := aFilter;
    SD.FilterIndex := aFilterInd;
    SD.DefaultExt := aDefExtWODot;
    if SD.Execute then
    begin
      fn := SD.FileName;
      if(ExtractFileExt(fn)= '')and(SD.DefaultExt <> '')then
        fn := ChangeFileExt(fn, SD.DefaultExt);
    end;
    Result := fn;
  finally
    FreeAndNil(SD);
  end;
end;

function SetFile(const aInitDir, aFilter:string; var aFilterIndex: integer; aForSave: boolean):string;
begin
  Result := ExtractFilePath(aInitDir);
  SelectFileName(Result, aFilter, aForSave);
end;

(*Выбор файла для загрузки/сохранения данных *********************************)
function SelectFileName(var aFileName:string;const aMainFilter:string; aForSave: boolean): boolean;
var
  OD: TOpenDialog;
  SD: TSaveDialog;
  dir:string;
  frm: TForm;
  Wnd: cardinal;
  err:string;
begin
  Result := false;
  frm := nil;
  Wnd := 0;
  if Assigned(Application)and Assigned(Application.MainForm)then
  begin
    frm := Application.MainForm;
    Wnd := frm.Handle;
  end;
  try
    if not aForSave then
    begin
      OD := TOpenDialog.Create(frm);
      try
        if aFileName = '' then
          aFileName := GetDesktopFolder;
        dir := ExtractFilePath(aFileName);
        if DirectoryExists(dir)then
          OD.InitialDir := dir
        else
          OD.InitialDir := GetDocFolder;
        OD.FileName:=ExtractFileName(aFileName);
        OD.Title := 'Открытие файла';
        //OD.Filter:='Файлы CSV(*.csv)|*.CSV|Все файлы(*.*)|*.*';
        if aMainFilter=''
           then OD.Filter := 'Все файлы(*.*)|*.*'
           else OD.Filter := aMainFilter;
        OD.FilterIndex := 1;
        OD.FileName := ExtractFileName(aFileName);
        if OD.Execute(Wnd)then
        begin
          aFileName := OD.FileName;
          Result := true;
        end;
      finally
        FreeAndNil(OD);
      end;
    end//-----
    else
    begin
      SD := TSaveDialog.Create(frm);
      try
        if aFileName = '' then
          aFileName := GetDesktopFolder;
        dir := ExtractFilePath(aFileName);
        if DirectoryExists(dir)then
          SD.InitialDir := dir
        else
          SD.InitialDir := GetDocFolder;
        SD.Title := 'Сохранение файла';
        //SD.Filter:='Файлы CSV(*.csv)|*.CSV';
        SD.Filter := aMainFilter;
        SD.FilterIndex := 1;
        SD.FileName:=ExtractFileName(aFileName);
        SD.DefaultExt := Copy(aMainFilter, PosEx('.', aMainFilter,
          Length(aMainFilter)- 5)+ 1, Length(aMainFilter));
        if SD.Execute(Wnd)then
        begin
          if ExtractFileExt(SD.FileName)= '' then
            aFileName := SD.FileName + '.' + SD.DefaultExt
          else
            aFileName := SD.FileName;
          Result := true;
        end;
      finally
        FreeAndNil(SD);
      end;
    end;//-----
  except
    on E: Exception do
    begin
      CreateErrorMessage('SelectFileName', E,[aFileName, aMainFilter,
        aForSave], err);
    end;
  end;
end;




procedure EncodeSystemTime(var st: TSystemTime;const aDay, aMonth, aYear, aHour,
  aMin, aSec, aMSec: Word);
begin
  st.wDay := aDay;
  st.wDayOfWeek := DayOfWeek(Encodedate(aYear, aMonth, aDay));
  st.wHour := aHour;
  st.wMilliseconds := aMSec;
  st.wMinute := aMin;
  st.wMonth := aMonth;
  st.wSecond := aSec;
  st.wYear := aYear;
end;

procedure DecodeSystemTime(const st: TSystemTime;var res: TDateTime);
begin
  res := Encodedate(st.wYear, st.wMonth, st.wDay)+ EncodeTime(st.wHour,
    st.wMinute, st.wSecond, st.wMilliseconds);
end;

procedure FT2DT(ft: TFileTime;var dt: TDateTime);
var
  lt: TFileTime;
  st: TSystemTime;
begin
  FileTimeToLocalFileTime(ft, lt);
  FileTimeToSystemTime(lt, st);
  DecodeSystemTime(st, dt);
end;

function FileTimeToDateTime(aFT: TFileTime): TDateTime;
var
  lft: TFileTime;
  st: TSystemTime;
begin
  FileTimeToLocalFileTime(aFT, lft);
  FileTimeToSystemTime(lft, st);
  DecodeSystemTime(st, Result);
end;

function SetFileDates(fn: PChar; FileDates: TFileDates): boolean;
var
  ftc, fto, ftw: TFileTime;
  lt : TFileTime;
  st: TSystemTime;
  hf: integer;
  hnd : cardinal;
  Y, M, D, z, S, n, H: Word;
  psa : PSecurityAttributes;
begin
  DecodeDate(FileDates.DateCreate, Y, M, D);
  DecodeTime(FileDates.DateCreate, H, n, S, z);
  EncodeSystemTime(st, D, M, Y, H, n, S, z);
  SystemTimeToFileTime(st, lt);
  LocalFileTimeToFileTime(lt, ftc);

  DecodeDate(FileDates.DateOpen, Y, M, D);
  DecodeTime(FileDates.DateOpen, H, n, S, z);
  EncodeSystemTime(st, D, M, Y, H, n, S, z);
  SystemTimeToFileTime(st, lt);
  LocalFileTimeToFileTime(lt, fto);


  DecodeDate(FileDates.DateWrite, Y, M, D);
  DecodeTime(FileDates.DateWrite, H, n, S, z);
  EncodeSystemTime(st, D, M, Y, H, n, S, z);
  SystemTimeToFileTime(st, lt);
  LocalFileTimeToFileTime(lt, ftw);

Result:=false;
  //hf:=FileOpen(fn, fmOpenWrite or fmShareDenyNone);
  if FileExists(StrPas(fn))
     then begin
     hf := FileOpen(StrPas(fn), fmOpenWrite);
     try
      Result := SetFileTime(hf,@ftc,@fto,@ftw);//sets last-write time for file
     finally
      FileClose(hf);
     end;
     end
     else
   if DirectoryExists(StrPas(fn))
     then begin
     CreatePSA(psa);
     hnd := CreateFile(
                   PChar(SetTailBackSlash(StrPas(fn),false)),
                   GENERIC_WRITE or GENERIC_READ ,
                   FILE_SHARE_WRITE,
                   psa,
                   OPEN_EXISTING,
                   FILE_FLAG_BACKUP_SEMANTICS,
                   0);
     try
      if hnd<>INVALID_HANDLE_VALUE
         then SetFileTime(hnd,@ftc,@fto,@ftw)
         else ShowMessageInfo(getErrorString(GetLastError));
     finally
     CloseHandle(hnd);
     FreeMem(psa);
     end;
     end;
end;

function GetFileDates(afn: PChar): TFileDates;
var
  sz: integer;
  ftc, fto, ftw: PFILETIME;
  hf: integer;
  tmp:string;
  SR  : TSearchRec;
  SRh : cardinal;
begin
  tmp := StrPas(afn);
  FillChar(Result, SizeOf(TFileDates), 0);
  sz := SizeOf(TFileTime);
  ftc := Allocmem(sz);
  FillChar(ftc^, SizeOf(TFileTime), 0);
  fto := Allocmem(sz);
  FillChar(fto^, SizeOf(TFileTime), 0);
  ftw := Allocmem(sz);
  FillChar(ftw^, SizeOf(TFileTime), 0);
  try
   if FileExists(tmp)
      then begin
      hf := FileOpen(tmp, fmOpenRead or fmShareDenyWrite or fmShareCompat);
      try
        if hf <>-1
           then GetFileTime(hf, ftc, fto, ftw)
           else Exit;
       finally
       FileClose(hf);
       end;
       FT2DT(ftc^, Result.DateCreate);
       FT2DT(fto^, Result.DateOpen);
       FT2DT(ftw^, Result.DateWrite);
       end
      else
   if DirectoryExists(afn)
      then begin
      SRh:=FindFirst(SetTailBackSlash(afn)+'.',faDirectory,SR);
      try
      if SRh=0
         then begin
         FT2DT(SR.FindData.ftCreationTime, Result.DateCreate);
         FT2DT(SR.FindData.ftLastAccessTime, Result.DateOpen);
         FT2DT(SR.FindData.ftLastWriteTime, Result.DateWrite);
         end;
      finally
      FindClose(SR);
      end;
      end
    else
    begin
      SetLastError((0));
      FillChar(Result, SizeOf(TFileDates), 0);
    end;
  finally
    FreeMem(ftc);
    FreeMem(fto);
    FreeMem(ftw);
  end;
end;

function GetOffSetTime : TTime;
var
 lst : TSystemTime;
 sst : TSystemTime;
begin
GetLocalTime(lst);
GetSystemTime(sst);
Result:=SystemTimeToDateTime(lst)-SystemTimeToDateTime(sst);
end;


function FileIsReady(const aFilename : string; var aSize : int64) : boolean;
var
 szA   : int64;
 PSA   : PSecurityAttributes;
 hFile : cardinal;
 szB   : cardinal;
begin
Result:=True;
try
szA:=GetSizeOfFile(aFileName);
CreatePSA(PSA);
hFile := CreateFile(PChar(aFileName), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, PSA, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
try
if hFile <> INVALID_HANDLE_VALUE
   then szB := GetFileSize(hFile,nil)
   else szB:=0;
finally
CloseHandle(hFile);
FreeMem(PSA);
end;
Result:=int64(szB) = szA;
if Result then aSize:=szA else aSize:=0;
except
end;
end;

function DOSFileNameToURL(const aFN : string) : string;
begin
Result:='';
if FileExists(aFN)
   then Result:='file://'+StringReplace(aFN,'\','/',[]);
end;

function URLToDOSFileName(const aURL : string) : string;
begin
Result:=aURL;
if AnsiPos('file://', AnsiLowerCase(aURL))=1
   then Result:=StringReplace(Copy(aURL,Length('file://')+1,Length(aURL)),'/','\',[]);
end;



procedure GetOSObjectDates(const aObjectName : string; var aFileDates : TFileDates);
var
  tmp:string;
  SR  : TSearchRec;
  SRh : cardinal;
begin
  tmp := aObjectName;
  if DirectoryExists(tmp)
     then tmp:=SetTailBackSlash(tmp)+'.';
  FillChar(aFileDates, SizeOf(TFileDates), 0);
  SRh:=FindFirst(tmp,faAnyFile or faDirectory,SR);
  try
  if SRh=0
     then begin
     FT2DT(SR.FindData.ftCreationTime, aFileDates.DateCreate);
     FT2DT(SR.FindData.ftLastAccessTime, aFileDates.DateOpen);
     FT2DT(SR.FindData.ftLastWriteTime, aFileDates.DateWrite);
     end;
  finally
  FindClose(SR);
  end;
end;

function SetOSObjectDates(const aObjectName : string; aFileDates : TFileDates): boolean;
var
  ftc, fto, ftw: TFileTime;
  lt : TFileTime;
  st: TSystemTime;

  hnd : cardinal;

  psa : PSecurityAttributes;
  flg : integer;
  offsettime : TTime;
begin
offsettime:=EncodeTime(1,0,0,0);
DateTimeToSystemTime(aFileDates.DateCreate+offsettime,st);
  SystemTimeToFileTime(st, lt);
  LocalFileTimeToFileTime(lt, ftc);

DateTimeToSystemTime(aFileDates.DateOpen+offsettime,st);
  SystemTimeToFileTime(st, lt);
  LocalFileTimeToFileTime(lt, fto);

DateTimeToSystemTime(aFileDates.DateWrite+offsettime,st);
  SystemTimeToFileTime(st, lt);
  LocalFileTimeToFileTime(lt, ftw);

Result:=false;
if FileExists(aObjectName)
   then flg:=FILE_ATTRIBUTE_NORMAL
   else flg:=FILE_FLAG_BACKUP_SEMANTICS;
   CreatePSA(psa);
   hnd := CreateFile(
                 PChar(aObjectName),
                 GENERIC_WRITE or GENERIC_READ ,
                 FILE_SHARE_WRITE,
                 psa,
                 OPEN_EXISTING,
                 flg,
                 0);
   try
    if hnd<>INVALID_HANDLE_VALUE
       then SetFileTime(hnd,@ftc,@fto,@ftw)
       else ShowMessageInfo(getErrorString(GetLastError));
   finally
   CloseHandle(hnd);
   FreeMem(psa);
   end;
end;


(*Удаление файла методом Windows*)
(**************************************************************)
(*Удаление файла*)
(*Hwnd - Handle формы вызывающей функцию*)
(*FileName - Имя удаляемого файла*)
(*HardDel - True > в корзину , False > жесткое удаление*)
(*Atten - True > запрос на подтверждение удаления*)
(**)
(*Результат 0 - удаление прошло успешно , иначе код ошибки*)
(**************************************************************)
function ShellDeleteFile(aHwnd: integer;const aFileName:string;aHardDel, aAtten: boolean): integer;
var
  fo: TSHFileOpStruct;
begin
Result:=0;
try
  fo.pFrom := Allocmem(Length(aFileName)* SizeOfChar + 4);
  fo.pTo := Allocmem(Length(aFileName)* SizeOfChar + 4);
  try
  if aHwnd<0
    then fo.Wnd := 0
    else fo.Wnd := aHwnd;
    fo.fAnyOperationsAborted := true;
    fo.wFunc := FO_DELETE;
    StrPCopy(fo.pFrom, aFileName);
    StrPCopy(fo.pTo, aFileName);
    //s:=strpas(FileName)+#0; // For destroy a BUG ?!
    //fo.pFrom:=PChar(s);     // For destroy a BUG ?!
    //fo.pTo:=PChar(Trim(FileName));
    fo.fFlags := FOF_FILESONLY;
    if not aHardDel then
      fo.fFlags := fo.fFlags + FOF_ALLOWUNDO;
    if not aAtten then
      fo.fFlags := fo.fFlags + FOF_NOCONFIRMATION;
    fo.hNameMappings := nil;
    fo.lpszProgressTitle := 'Удаление...';
    Result := ShellAPI.SHFileOperation(fo);
    if Result = 0
       then SHChangeNotify(SHCNE_DELETE, SHCNF_PATH, fo.pFrom,fo.pTo);
  finally
    FreeMem(fo.pTo);
    FreeMem(fo.pFrom);
  end;
except
end;
end;


procedure PendingDeleteFile(const aFileName:string);
begin
try
 if FileExists(aFileName) then MoveFileEx(PChar(aFileName),nil,MOVEFILE_DELAY_UNTIL_REBOOT);
except
end;
end;



function ShellDeleteFolder(aHwnd: integer;const aFolderName:string; aAtten: boolean): integer;
var
  fo: TSHFileOpStruct;
begin
FillChar(fo, SizeOf(TSHFileOpStruct),#0);
try
if aHwnd<0
  then fo.Wnd := 0
  else fo.Wnd := aHwnd;
  fo.fAnyOperationsAborted := false;
  fo.wFunc := FO_DELETE;
  fo.pFrom := Allocmem(Length(aFolderName)* SizeOfChar + 1);
  StrPCopy(fo.pFrom, aFolderName);
  fo.fFlags := FOF_SILENT or FOF_NOERRORUI or FOF_ALLOWUNDO;
  if not aAtten then fo.fFlags := fo.fFlags or FOF_NOCONFIRMATION;
  fo.lpszProgressTitle := 'Удаление...';
  Result := ShellAPI.SHFileOperation(fo);
  if Result = 0
     then SHChangeNotify(SHCNE_DELETE, SHCNF_PATH, fo.pFrom,fo.pTo);
finally
  FreeMem(fo.pFrom);
end;
end;


procedure HandlerFileMapping(SHNM: Pointer;var ShFM: TShFileMappingList);
type
  PSHNMPtr =^TSHNMPtr;

  TSHNMPtr = record
    ItemCount: UINT;
    ArrPtrAddr: UINT;
  end;

  function GetStringW(aWCPointer: PChar; aWCLength: UINT):string;
  var
    fnw: PWideChar;
  begin
    fnw := Allocmem(integer(aWCLength) * SizeOfChar+ 2);
    try
      System.Move(aWCPointer^, fnw^, integer(aWCLength) * SizeOfChar);
      WideCharToStrVar(fnw, Result);
    finally
      FreeMem(fnw);
    end;
  end;

var
  cnt: integer;
  shnmp: TSHNMPtr;
  shnma: array of TSHNameMapping;
begin
  System.Move(SHNM^, shnmp, SizeOf(TSHNMPtr));
  cnt := shnmp.ItemCount;
  if cnt = 0 then
    Exit;
  SetLength(ShFM, cnt);
  SetLength(shnma, cnt);
  try
    System.Move(Ptr(shnmp.ArrPtrAddr)^, shnma[0], SizeOf(TSHNameMapping)* cnt);
    for cnt := 0 to High(shnma)do
      with shnma[cnt]do
      begin
        StrPCopy(@ShFM[cnt].FromFileName[1], GetStringW(pszOldPath,
          cchOldPath));
        StrPCopy(@ShFM[cnt].IntoFileName[1], GetStringW(pszNewPath,
          cchNewPath));
      end;
  finally
    SetLength(shnma, 0);
  end;
end;

function ShellMoveCopyFileNT(DoCopy: boolean;const FromFile, ToFile:string; out NewFileName:string; Ren, Atten: boolean): integer;
var
  fo: TSHFileOpStruct;
  so: array[0 .. MAX_PATH]of char;
  si: array[0 .. MAX_PATH]of char;
  ShFM: TShFileMappingList;
begin
  FillChar(so, Length(so)* SizeOfChar, 0);
  FillChar(si, Length(si)* SizeOfChar, 0);
  Str2AC(FromFile, so);
  Str2AC(ToFile, si);


  //StrPCopy(@so[0],FromFile);
  //StrPCopy(@si[0],ToFile);

  FillChar(fo, SizeOf(TSHFileOpStruct), 0);
  fo.pFrom :=@so[0];
  fo.pTo :=@si[0];
  fo.Wnd := GetDesktopWindow;
  fo.fAnyOperationsAborted := LongBool(false);
  if DoCopy then
  begin
    fo.wFunc := FO_COPY;
    fo.lpszProgressTitle := 'Копирование...';
  end
  else
  begin
    fo.wFunc := FO_MOVE;
    fo.lpszProgressTitle := 'Перемещение...';
  end;
  fo.fFlags := FOF_ALLOWUNDO or FOF_WANTMAPPINGHANDLE or FOF_NORECURSION;
  if DirectoryExists(FromFile)then  // для обединения папки (при существующей целевой папке копируют или премещают папку с таким же путем надо отключать Atten )
    fo.fFlags := fo.fFlags or FOF_MULTIDESTFILES;
  if Ren then
    fo.fFlags := fo.fFlags or FOF_RENAMEONCOLLISION;
  if not Atten then
    fo.fFlags := fo.fFlags or FOF_NOCONFIRMMKDIR or FOF_NOCONFIRMATION
  else
    fo.fFlags := fo.fFlags or FOF_CONFIRMMOUSE;
  Result := ShellAPI.SHFileOperation(fo);
  if Result = 0 then
    SHChangeNotify(SHCNE_CREATE, SHCNF_PATH, PChar(ExtractFilePath(FromFile)),
      PChar(ExtractFilePath(ToFile)));
  NewFileName := ToFile;
  if Assigned(fo.hNameMappings)then
  begin
    HandlerFileMapping(fo.hNameMappings, ShFM);
    if Length(ShFM)> 0 then
      NewFileName := StrPas(PChar(@ShFM[0].IntoFileName[1]));
    //NewFileName:=StrPas(@ShFM[0].FromFileName[1])+crlf+StrPas(@ShFM[0].IntoFileName[1]);
    SHFreeNameMappings(THandle(fo.hNameMappings));
  end;
end;



function GetAtoms : string;
var
 cnt : word ;
 buff: array[1..512] of char;
 op  : uint;
begin
// http://msdn.microsoft.com/en-us/library/windows/desktop/ff468795(v=vs.85).aspx
Result:='';
for cnt:=Low(word) to High(Word)//$BFFF
  do begin
  op:=GlobalGetAtomName(cnt,PChar(@buff[1]),SizeOf(buff));
  if (op>0) and (buff[1]<>'#'(*признак пустой записи в таблице*))
     then Result:=Result+Format('%d : %s',[cnt,AC2Str(buff)])+crlf;
  end;
end;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)
var
  MBL       : TMessageBoxList;
  ParHandle : cardinal = 0;

function EWP(hwndNext : hWnd;lp : lParam): boolean; stdcall;
var
 ClsName : string;
 ind       : integer;
begin
 Result := True;
 if hwndNext <> 0
 then begin
 ClsName:=GetWindowClassName(hwndNext);
 if (ClsName='#32770') and (ParHandle=GetParent(hwndNext))
    then begin
    ind:=Length(MBL);
    SetLength(MBL,ind+1);
    MBL[ind].wnd:=hwndNext;
    MBL[ind].Caption:=ShortString(GetWndText(MBL[ind].wnd));
   end
  else Result := False;
 end;
end;



function CloseMessageBoxes(aWithResult : integer; aAppHandle : cardinal = 0) : boolean;
var
 cnt : integer;
 res : integer;
begin
res:=-1;
Result:=false;
try
try
if aAppHandle<>0
  then ParHandle:=aAppHandle
  else ParHandle:=Application.Handle;
SetLength(MBL,0);
EnumWindows(@EWP,0);
res:=0;
for cnt:=0 to High(MBL)
  do try
     inc(res,integer(EndDialog(MBL[cnt].wnd,aWithResult)));
     except
     end;
finally
Result:=res=Length(MBL);
Setlength(MBL,0);
end;
except
end;
end;
(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)


function EnumTerminateAppWindowsProc(Wnd: THandle; ProcessID: DWORD): Boolean; stdcall;
var
  PID: DWORD;
begin
  GetWindowThreadProcessId(Wnd, @PID);
  if ProcessID = PID then
    PostMessage(Wnd, WM_CLOSE, 0, 0);
  Result := True;
end;

function TerminateApp(ProcessID: DWORD; Timeout: Integer): boolean;
var
  ProcessHandle: THandle;
begin
  Result := false;
  if ProcessID <> GetCurrentProcessId then
  begin
    ProcessHandle := OpenProcess(SYNCHRONIZE or PROCESS_TERMINATE, False, ProcessID);
    if ProcessHandle <> 0 then
    try
      EnumWindows(@EnumTerminateAppWindowsProc, LPARAM(ProcessID));
      if WaitForSingleObject(ProcessHandle, Timeout) = WAIT_OBJECT_0
        then Result:=false//   Result := taClean
      else
      if TerminateProcess(ProcessHandle, 0) then
        Result := true;
    finally
      CloseHandle(ProcessHandle);
    end;
  end;
end;

function TerminateTask(Wnd: THandle; Timeout: Integer): boolean;
var
  PID: DWORD;
begin
  if GetWindowThreadProcessId(Wnd, @PID) <> 0 then
    Result := TerminateApp(PID, Timeout)
  else
    Result := false;
end;

function EWPByClass(hwndNext: HWND; lp: LParam): boolean; stdcall;
var
  cls : string;
  tmp : string;
  ind : integer;
  _wbc : PWindowsByClass;
begin
_wbc:=Ptr(lp);
cls:=AnsiLowercase(string(_wbc^.ClassName));
Result := true;
if hwndNext <> 0
   then begin
   tmp:=AnsiLowerCase(GetWindowClassName(hwndNext));
   if tmp=cls
      then begin
      ind:=Length(_wbc^.windows);
      SetLength(_wbc^.windows,ind+1);
      _wbc^.windows[ind]:=hwndNext;
      end;
    end
    else Result := false;
end;

function GetWindowsByClass(const ClassName : string; var WbC : TWindowsByClass) : boolean;
begin
Result:=false;
try
WbC.ClassName:=ShortString(ClassName);
Setlength(WbC.windows,0);
EnumChildWindows(GetDesktopWindow,@EWPByClass,lParam(@WbC));
Result:=true;
except
end;
end;

function EWPByModuleName(hwndNext: HWND; lp: LParam): boolean; stdcall;
var
  cls : string;
  tmp : string;
  ind : integer;
  _wbc : PWindowsByClass;
  main : boolean; // -- только главные окна процесса (для подсчета запущенных экземпляров приложения)
begin
_wbc:=Ptr(lp);
cls:=AnsiLowercase(string(_wbc^.ClassName));
main:=cls[1]=#32;
cls:=trim(cls);
Result := true;
if hwndNext <> 0
   then begin
   if (main and (GetWindowLong(hwndNext,GWL_EXSTYLE) and WS_EX_APPWINDOW <> 0)) or
      not main
      then begin
      tmp:=Ansilowercase(ExtractFileName(GetProcessModule(GetWindowPID(hwndNext))));
      if tmp=cls
          then begin
          ind:=Length(_wbc^.windows);
          SetLength(_wbc^.windows,ind+1);
          _wbc^.windows[ind]:=hwndNext;
          end;
      end;
    end
    else Result := false;
end;

function GetWindowsByModuleName(const OnlyEXEName : string; var WbC : TWindowsByClass; MainOnly : boolean = false) : boolean;
begin
Result:=false;
try
WbC.ClassName:=ShortString(IfThen(MainOnly,' ','')+OnlyEXEName);
Setlength(WbC.windows,0);
EnumChildWindows(GetDesktopWindow,@EWPByModuleName,lParam(@WbC));
Result:=true;
except
end;
end;

procedure ClearAtom(const AtomName : PChar);
var
 atm : ATOM;
begin
atm:=GlobalFindAtom(AtomName);
while atm<>0
  do begin
  GlobalDeleteAtom(atm);
  atm:=GlobalFindAtom(AtomName);
  end;
end;


function ClearIntstances(const OnlyEXEName : string) : boolean;
var
 WbC : TWindowsByClass;
 cnt : integer;
begin
Result:=false;
try
GetWindowsByModulename(OnlyEXEName,wbc,true);
for cnt:=0 to High(WbC.windows)
    do TerminateTask(WbC.windows[cnt], 250);
Result:=true;
except
end;
end;


function ClearIntstances_OLD(const aAtomNameWork, MainFormClassName, OnlyEXEName : string) : boolean;
var
 atm : ATOM;
 wnd : cardinal;
 tst : string;
 str : string;
 WbC : TWindowsByClass;
 cnt : integer;
begin
Result:=false;
try
atm:=GlobalFindAtom(PChar(aAtomNameWork));
while atm>0
 do begin
 GlobalDeleteAtom(atm);
 atm:=GlobalFindAtom(PChar(aAtomNameWork));
 end;
tst:=AnsiLowercase(OnlyEXEName);
if GetWindowsByClass(MainFormClassName, WbC)
   then begin
   for cnt:=0 to High(WbC.windows)
     do begin
     wnd:=WbC.windows[cnt];
     str:=Ansilowercase(ExtractFileName(GetProcessModule(GetWindowPID(wnd))));
     if Pos(tst,str)<>0
        then TerminateTask(wnd, 250);
     end;
   end;
Result:=true;
except
end;
end;

function GetInstanceCount : integer;
var
 wbc : TWindowsByClass;
begin
GetWindowsByModuleName(ExtractFileName(ParamStr(0)),wbc,true);
Result:=Length(wbc.windows);
end;

(******************************************************************************)

function ValidateComponentName(const aSrcName:string;
  var aResName:string): boolean;
var
  cnt: integer;
begin
  Result := false;
  aResName := aSrcName;
  if aResName = '' then
    Exit;
  if CharInSet(aResName[1],['0' .. '9'])then
    Exit;
  for cnt := 1 to Length(aResName)//without regional symbols!!!
    do
    if not CharInSet(aResName[cnt],['a' .. 'z', 'A' .. 'Z', '0' .. '9',
      '_'])then
      aResName[cnt]:= '_';
  Result := true;
end;

(*----------------------------------------------------------------------------*)
procedure ClearMenuItem(aMI: TMenuItem);
var
  cnt: integer;
  mi: TMenuItem;
begin
  for cnt := aMI.Count - 1 downto 0 do
  begin
    ClearMenuItem(aMI[cnt]);
    mi := aMI[cnt];
    aMI.Delete(cnt);
    FreeAndNil(mi);
  end;
end;

function ClearPopupMenu(aPM: TPopUpMenu): boolean;
var
  cnt: integer;
  mi: TMenuItem;
begin
  for cnt := aPM.Items.Count - 1 downto 0 do
  begin
    mi := aPM.Items[cnt];
    if mi.Count>0 then ClearMenuItem(mi);
    aPM.Items.Delete(cnt);
    mi.Name := '';
    FreeAndNil(mi);
  end;
  Result :=(aPM.Items.Count = 0);
end;



function ClearPopupMenuByTag(aPM: TPopUpMenu; aTags: array of integer;
  aKeepTags: boolean): boolean;
var
  cnt: integer;
  mi: TMenuItem;
begin
  for cnt := aPM.Items.Count - 1 downto 0 do
    if((Inner(aPM.Items[cnt].Tag, aTags)>-1)and not aKeepTags)or
      ((Inner(aPM.Items[cnt].Tag, aTags)=-1)and aKeepTags)then
    begin
      mi := aPM.Items[cnt];
      aPM.Items.Delete(cnt);
      mi.Free;
    end;
  Result := true;
end;

// -- ВНИМАНИЕ -------------------------------------------------------------------------------------
// при длинных строках (свыше 79 символов) необходимо выставлять PopupMenu.OwnerDraw:=true;
// или подключать TImageList для изменения типа TMenuItem в любой отличный от MFT_STRING
// т.к. 0-вой пункт меню будет обрезан
// см .
// ms-help://embarcadero.rs_xe/Winui/winui/windowsuserinterface/resources/menus/menureference/menustructures/menuiteminfo.htm
// особенно в части реализации TMenuItemInfo.dwTypeData и TMenuItemInfo.cch
// в фунлции Menus.TMenu.DoBiDiModeChanged
// результат получен 20140910 на Embarcadero® Delphi® XE Version 15.0.3953.35171 Enterprise
// ---------- Пример тестовой процедуры ------------------------------------------------------------
//procedure TForm1.SpeedButton1Click(Sender: TObject);
//const
// items : array[0..1] of string = (
// '1089125 KupiVip->Диспетчерская/От клиента/перенос доставки 27.08.2014 10:15:38 (Закрыт)'
//,'1088666 KupiVip->Диспетчерская/От клиента/перенос доставки 26.08.2014 19:59:13 (Закрыт)'
// );
//var
// pm  : TPopupMenu;
// mi  : TMenuItem;
// cnt : integer;
//begin
//if Sender is TSpeedButton
//   then begin
//   pm:=TPopupMenu.Create(self);
//   pm.AutoHotkeys:=maManual;
//   pm.MenuAnimation:=[maNone];
//   pm.OwnerDraw:=true; // -- критично, комментарь для проверки
//   for cnt:=0 to High(items)
//     do begin
//     mi:=AddItemToPopupMenu(pm,nil,items[cnt],SpeedButton1Click,cnt);
//     if Assigned(mi)
//        then begin
//        end;
//     end;
//   ShowPopupMenu(SpeedButton1,pm);
//   end
//   else
//if Sender is TMenuItem
//   then begin
//   ShowMessageInfo((Sender as TMenuItem).Caption);
//   end;
//end;
// -------------------------------------------------------------------------------------------------

function AddItemToPopupMenu(aPM: TPopUpMenu; aMainItem: TMenuItem; const ACaption:string; aProc: TNotifyEvent; aTag: integer = 0): TMenuItem;
const
  mainRev : boolean = false;
  popRev  : boolean = false;
begin
aPM.AutoHotkeys:=maManual;
Result := TMenuItem.Create(aPM);
with Result
  do begin
  if Assigned(aMainItem)
     then Name := aMainItem.Name + '_' + NormalizeComponentName(CreateUuid)+ '_' + FormatFloat('000000000', aPM.Items.Count)
     else Name := aPM.Name + '_' + NormalizeComponentName(CreateUuid)+ '_' +FormatFloat('000000000', aPM.Items.Count);
  onClick := aProc;
  Caption := ACaption;
  Tag := aTag;
  end;
if Assigned(aMainItem)
   then if mainRev
           then  aMainItem.Insert(0,Result)
           else  aMainItem.Add(Result)
   else if popRev
           then aPM.Items.Insert(0, Result)
           else aPM.Items.Add(Result);
end;

function AddItemToMenu(aMenu: TMenu; aMainItem: TMenuItem;const ACaption:string;
  aProc: TNotifyEvent; aTag: integer; aChecked: boolean): TMenuItem;
var
  cnt: integer;
begin
aMenu.AutoHotkeys:=maManual;
  for cnt := 0 to aMainItem.Count - 1 do
    aMainItem.Items[cnt].Checked := false;
  Result := TMenuItem.Create(aMenu);
  with Result do
  begin
    if Assigned(aMainItem)then
    //Name:=aMainItem.Name+'_'+FormatDateTime('yyyymmdd_hhnnsszzz',Now)+'_'+IntToStr(aTag)
      Name := aMainItem.Name + '_' + NormalizeComponentName(CreateUuid)+ '_' +
        IntToStr(aTag)
    else//Name:=aMenu.Name+'_'+FormatDateTime('yyyymmdd_hhnnsszzz',Now)+'_'+IntToStr(aTag);
      Name := aMenu.Name + '_' + NormalizeComponentName(CreateUuid)+ '_' +
        IntToStr(aTag);
    onClick := aProc;
    Caption := ACaption;
    Tag := aTag;
    Checked := aChecked;
  end;
  if Assigned(aMainItem)then
    aMainItem.Add(Result)
  else
    aMenu.Items.Insert(0, Result);
end;

function ShowPopupMenu(GraphCtrl: TGraphicControl; aMenu: TPopUpMenu): TPoint;
var
  Wnd: HWND;
begin
  try
    Wnd := WindowFromDC(THackGraphicControl(GraphCtrl).Canvas.Handle);
    //Wnd:=GetSpeedButtonHandle(aSpB);
    Result := Point(GraphCtrl.Left, GraphCtrl.Top + GraphCtrl.height);
    Windows.ClientToScreen(Wnd, Result);
    if Assigned(aMenu)
       then begin
       aMenu.PopupComponent:=GraphCtrl;
       aMenu.Popup(Result.X, Result.Y);
       end;
  except
    on E: Exception do
      CreateErrorMessage('ShowPopupMenu', E,[], true);
  end;
end;

function ShowPopupMenu(aWinCtrl: TWinControl; aMenu: TPopUpMenu): TPoint;
//var
// rct : TRect;
begin
if not Assigned(aWinCtrl) or not Assigned(aMenu)
   then Exit;
ShowPopupMenu(aWinCtrl.Handle, aMenu);
end;


function ShowPopupMenu(wnd: cardinal; aMenu: TPopUpMenu): TPoint;
var
 rct : TRect;
begin
if not IsWindow(wnd) or not Assigned(aMenu)
   then Exit;
  try
  GetWindowRect(wnd,rct);
  Result:=rct.TopLeft;
  aMenu.PopupComponent:=FindControl(wnd);
  aMenu.Popup(rct.Left, rct.Top + (rct.Bottom - rct.Top));
  except
    on E: Exception do
      CreateErrorMessage('ShowPopupMenu(wnd)', E,[wnd], true);
  end;
end;


function GetSpeedButtonHandle(aSpB: TSpeedButton): cardinal;
begin
Result:=WindowFromDC(THackGraphicControl(aSpB).Canvas.Handle);
end;

procedure GetSpeedButtonRect(aSpB : TSpeedButton; var aRect : TRect);
var
 wnd : cardinal;
 pt  : TPoint;
begin
wnd:=WindowFromDC(THackGraphicControl(aSpB).Canvas.Handle);
pt:=Point(aSpb.Left, aSpb.Top);
ClientToScreen(wnd, pt);  // -- именно для этого вся эта бодяга (PopupMenu работает по Screen координатам)
aRect:=Bounds(pt.X, pt.Y, aSpB.Width, aSpb.Height);
end;

(*хлам*)//
(*хлам*)//function GetListFromFile(const aFileName : string) : boolean;
(*хлам*)//var
(*хлам*)//strl : TStringList;
(*хлам*)//ind  : integer;
(*хлам*)//res  : array of string;
(*хлам*)//tmp     : string;
(*хлам*)//psStart : integer;
(*хлам*)//psEnd   : integer;
(*хлам*)//labBegin : string;
(*хлам*)//labEnd : string;
(*хлам*)//begin
(*хлам*)//Result:=false;
(*хлам*)//strl:=TStringList.Create;
(*хлам*)//try
(*хлам*)//strl.LoadFromFile(aFileName);
(*хлам*)//if (TextPos(PChar(strl.Text),'</ol>')=nil) and
(*хлам*)//(TextPos(PChar(strl.Text),'</ul>')=nil)
(*хлам*)//then Exit;
(*хлам*)//labBegin:=CreateGUID;
(*хлам*)//labEnd:=CreateGUID;
(*хлам*)//tmp:=strl.Text;
(*хлам*)//tmp:=StringReplace(tmp,'<ol',labBegin,[rfReplaceAll,rfIgnoreCase]);
(*хлам*)//tmp:=StringReplace(tmp,'<ul',labBegin,[rfReplaceAll,rfIgnoreCase]);
(*хлам*)//tmp:=StringReplace(tmp,'</ol',labEnd,[rfReplaceAll,rfIgnoreCase]);
(*хлам*)//tmp:=StringReplace(tmp,'</ul',labEnd,[rfReplaceAll,rfIgnoreCase]);
(*хлам*)//psStart:=Pos(labBegin,tmp);
(*хлам*)//while psStart<>0
(*хлам*)//do begin
(*хлам*)//ind:=Length(Res);
(*хлам*)//SetLength(res,ind+1);
(*хлам*)//psEnd:=Pos(labEnd,tmp);
(*хлам*)//res[ind]:=Copy(tmp,psStart(*+Length(labBegin)*),psEnd-1);
(*хлам*)//Delete(tmp,1,psEnd+Length(labEnd));
(*хлам*)//psStart:=Pos(labBegin,tmp);
(*хлам*)//end;
(*хлам*)//strl.Clear;
(*хлам*)//strl.Add(labBegin);
(*хлам*)//strl.Add(labEnd);
(*хлам*)//for ind:=0 to High(Res) do strl.Add(res[ind]);
(*хлам*)//strl.Add(tmp);
(*хлам*)//tmp:=SetTailBackSlash(GetTempFolder)+FormatDateTime('oul_yyyymmdd_hhnnsszzz',Now)+'.txt';
(*хлам*)//strl.SaveToFile(tmp);
(*хлам*)//FileOpenNT(tmp);
(*хлам*)//Result:=True;
(*хлам*)//finally
(*хлам*)//SetLength(res,0);
(*хлам*)//if Assigned(strl)
(*хлам*)//then begin
(*хлам*)//strl.Clear;
(*хлам*)//FreeAndNil(strl);
(*хлам*)//end;
(*хлам*)//end;
(*хлам*)//end;

function GetPictureType(const aURI:string): TPicType;
var
  MemStream : TMemoryStream;
  PSA       : PSecurityAttributes;
  hFile     : cardinal;
  IndyHTTP  : TidHTTP;
  buf       : array[0 .. 64]of ansichar;
  ReadSize  : cardinal;
const
  icoSign: array[0 .. 3]of Byte =(00, 00, 01, 00);
begin
  Result := ptNotImage;
  try
    if (Length(aURI)=0) or
       DirectoryExists(aURI) or
       (aURI[1]='.')
       then Exit;
    if FileExists(aURI)then
    begin
      CreatePSA(PSA);
      hFile := CreateFile(PChar(aURI), GENERIC_READ, FILE_SHARE_READ or
        FILE_SHARE_WRITE, PSA, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
      try
        if hFile <> INVALID_HANDLE_VALUE then
          ReadFile(hFile, buf, 64, ReadSize,nil);
      finally
        CloseHandle(hFile);
        FreeMem(PSA);
      end;
    end
    else
    begin
      MemStream := TMemoryStream.Create;
      IndyHTTP := TidHTTP.Create(nil);
      try
        IndyHTTP.Get(aURI, MemStream);
        MemStream.Position := 0;
        MemStream.Read(buf, 64);
      finally
        FreeAndNil(IndyHTTP);
        MemStream.Free;
      end;
    end;

    if(StrPos(PAnsiChar(@buf[0]), 'BM')<> nil)  //-- можно через структуру типа {Mnemonic, PicType}
      then  Result := ptBitmap
      else
    if(StrPos(PAnsiChar(@buf[6]), 'JFIF')<> nil)or
      (StrPos(PAnsiChar(@buf[6]), 'Exif')<> nil)
      then  Result := ptJPG
      else
    if(StrPos(PAnsiChar(@buf[1]), 'PNG'#$0D)<> nil)
      then Result := ptPNG
      else
    if(StrPos(PAnsiChar(@buf[0]), 'MM')<> nil)or
      (StrPos(PAnsiChar(@buf[0]), 'II')<> nil)
      then Result := ptTIFF
      else
    if//buf[2]= 01 ico (02 cur), buf[4] - кол-во
      //(buf[6]=buf[7]) or (byte(buf[6])=(byte(buf[7]) shl 1)) //  под такое условие ZIP пападает....
      (Byte(buf[0])= icoSign[0])and(Byte(buf[1])= icoSign[1])and
      (Byte(buf[2])= icoSign[2])and(Byte(buf[3])= icoSign[3])
      then Result := ptICO
      else
    if(StrPos(PAnsiChar(@buf[0]), 'GIF8')<> nil)//GIF89a,GIF87a
      then Result := ptGIF
      else
    if(StrPos(PAnsiChar(@buf[50]), 'WMFC')<> nil)
      then Result := ptWMF
      else;
  except
    on E: Exception do;
  end;
end;

function GetPictureType(aStream: TStream): TPicType;
var
  Pos: int64;
  buf: array[0 .. 64]of ansichar;
const
  icoSign: array[0 .. 3]of Byte =(00, 00, 01, 00);
begin
  Result := ptNotImage;
  try
    Pos := aStream.Position;
    try
      aStream.Position := 0;
      aStream.Read(buf, 64);
       aStream.Position := Pos;

      if(StrPos(PAnsiChar(@buf[0]), 'BM')<> nil)
      //-- можно через структуру типа {Mnemonic, PicType}
      then
        Result := ptBitmap
      else if(StrPos(PAnsiChar(@buf[6]), 'JFIF')<> nil)or
             (StrPos(PAnsiChar(@buf[6]), 'Exif')<> nil) or
             (StrPos(PAnsiChar(@buf[6]), 'Adobe')<> nil)
             then
        Result := ptJPG
      else if(StrPos(PAnsiChar(@buf[1]), 'PNG'#$0D)<> nil)then
        Result := ptPNG
      else if(StrPos(PAnsiChar(@buf[0]), 'MM')<> nil)or
        (StrPos(PAnsiChar(@buf[0]), 'II')<> nil)then
        Result := ptTIFF
      else if//buf[2]= 01 ico (02 cur), buf[4] - кол-во
      //(buf[6]=buf[7]) or (byte(buf[6])=(byte(buf[7]) shl 1)) //  под такое условие ZIP пападает....
        (Byte(buf[0])= icoSign[0])and(Byte(buf[1])= icoSign[1])and
        (Byte(buf[2])= icoSign[2])and(Byte(buf[3])= icoSign[3])then
        Result := ptICO
      else if(StrPos(PAnsiChar(@buf[0]), 'GIF8')<> nil)//GIF89a,GIF87a
      then
        Result := ptGIF
      else if(StrPos(PAnsiChar(@buf[50]), 'WMFC')<> nil)then
        Result := ptWMF
      else;
    finally
      aStream.Position := Pos;
    end;
  except
    on E: Exception do;
  end;
end;

(*Загрузка изображения из файла в TImage -----------------------------------*)
function LoadImageFromFileIntoImage(const aFile:string; aImage: TImage) : boolean;
var
  //ext:string;
  png: TPNGImage;
  gif: TGIFImage;
  jpg: TJpegImage;
  pt: TPicType;
begin
  Result := false;
  if not Assigned(aImage)then
    Exit;
  //if Assigned(aImage.Picture) then aImage.Picture.Free;
  if not FileExists(aFile)then
    Exit;
  //ext := AnsiUpperCase(ExtractFileExt(aFile));
  pt := GetPictureType(aFile);
  try
    if pt = ptPNG//if ext = '.PNG'
    then
    begin
      png := TPNGImage.Create;
      try
        png.LoadFromFile(aFile);
        png.TransparentColor:=pngBackColor;
        aImage.Picture.Assign(png as TGraphic);

      finally
        FreeAndNil(png);
      end;
    end
    else if pt = ptGIF//if ext = '.GIF'
    then
    begin
      gif := TGIFImage.Create;
      try
        gif.LoadFromFile(aFile);
        //aImage.Picture.LoadFromFile(aFile);
        aImage.Picture.Assign(gif as TGraphic);
      finally
        FreeAndNil(gif);
      end;
    end
    else if pt = ptICO//if ext = '.ICO'
    then
    begin
      if not Assigned(aImage.Picture.Icon)then
        aImage.Picture.Icon := TIcon.Create;
      aImage.Picture.Icon.LoadFromFile(aFile);
    end
    else if pt = ptTIFF
    then begin
    if not Assigned(aImage.Picture.Icon)then
        aImage.Picture.Graphic := TWICImage.Create;
    aImage.Picture.Graphic.LoadFromFile(aFile);
    end
    else if pt = ptBitmap//if ext = '.BMP'
    then
    begin
      if not Assigned(aImage.Picture.Bitmap)then
        aImage.Picture.Bitmap := TBitmap.Create;
      aImage.Picture.Bitmap.LoadFromFile(aFile);
    end
    else if pt = ptJPG//if AnsiPos('.J', ext)= 1//-- jpg, jpeg, jfif
    then
    begin
      jpg := TJpegImage.Create;
      try
        jpg.LoadFromFile(aFile);
        aImage.Picture.Assign(jpg as TGraphic);
      finally
        FreeAndNil(jpg);
      end;
    end;
    Result := true;
  except
    on E: Exception do
    begin
      MessageBox(Application.Handle, PWideChar(Format('ERROR. %s : %s. %s ',
        ['LoadImageFromFileIntoImage', E.Message, GetErrorString])),
        'Сбой выполнения', MB_ICONWARNING);
    end;
  end;
end;

(*Загрузка изображения из Internet-а в TImage ------------------------------*)
function LoadImageFromURLIntoImage(const aURL:string; aImage: TImage): boolean;
var
  Stream: TMemoryStream;
begin
Result := false;
if not Assigned(aImage)then Exit;
if FileExists(aURL)
  then Result:=LoadImageFromFileIntoImage(aURL, aImage)
  else begin
  Stream:=TMemoryStream.Create;
  try
  Result:=LoadURLIntoStream(aURL,Stream,false);
  finally
  Stream.Free;
  end;
  end;
end;

(*Загрузка изображения из файла в TBitmap ----------------------------------*)
function LoadImageFromFileIntoBitmap(const aFile:string; var aBMP: TBitmap): boolean;
begin
Result:=LoadImageIntoBitmap(aFile,aBMP,0);
end;

(*Загрузка изображения из Internet-а в TBitmap -----------------------------*)
function LoadImageFromURLIntoBitmap(const aURL:string; aBMP: TBitmap): boolean;
begin
Result:=LoadImageIntoBitmap(aURL,aBMP,0);
end;

(*Загрузка изображения из Internet-а в TBitmap -----------------------------*)
function LoadImageFromURLIntoBitmapWithBackColor(const aURL:string; aBMP: TBitmap; BackColor : TColor): boolean;
begin
Result:=LoadImageIntoBitmap(aURL,aBMP,0,BackColor);
end;



//function PngToBMP(const URIPng : string; aBMP : TBitmap; BackColor : TColor);
//var
//  Stream : TMemoryStream;
//begin
//Stream:=TMemoryStream.Create;
//try
//LoadURLIntoStream(URIPng,Stream,false);
//if GetPictureType(Stream)=ptPNG
//   then begin
//   end
//   else LoadImageIntoBitmap(URIPng, aBMP);
//finally
//Stream.Free;
//end;
//end;

(*ОСНОВНАЯ на 20140410 : загрузка изображения в Bitmap (file, url) ---------*)
function LoadImageIntoBitmap(const aURI:string; aBMP: TBitmap; ahndl: cardinal; BackColor : TColor = Graphics.clNone): boolean;
var
  Stream      : TMemoryStream;
  FileStream  : TfileStream;
  IndyHTTP    : TidHTTP;
  png         : TPNGImage;
  gif         : TGIFImage;
  jpg         : TJpegImage;
  ico         : TIcon;
  wmf         : TMetafile;
  tif         : TWICImage;
  pt          : TPicType;
  hndl        : cardinal;
  res         : hrsrc;
  mem         : hGlobal;
  buf         : PChar;
  sz          : cardinal;
  inf         : string;
begin
  Result := false;
  try
    inf := 'Start';
    if not Assigned(aBMP)
       then aBMP := TBitmap.Create;
    Stream := TMemoryStream.Create;
    try
    if ahndl <> 0
       then hndl := ahndl
       else hndl := GetModuleHandle(PChar(ParamStr(0)));
    res := FindResource(hndl, PChar(aURI), RT_RCDATA);
    inf := 'Data';
    if FileExists(aURI)
       then begin
       inf := 'File';
       FileStream := TfileStream.Create(aURI, fmOpenRead or fmShareDenyWrite);
        try
        Stream.LoadFromStream(FileStream);
        finally
        FileStream.Free;
        end;
       end
       else
    if (res > 0)
       then begin
       inf := 'Resource';
       sz := SizeofResource(hndl, res);
       if sz > 0
          then begin
          mem := LoadResource(hndl, res);
          buf := LockResource(mem);
           try
           Stream.Write(buf^, sz);
           finally
           UnlockResource(res);
           end;
          end;
       end
       else begin
       inf := 'URL';
       IndyHTTP := TidHTTP.Create(nil);
       try
       try
       IndyHTTP.Request.UserAgent:='Mozilla/3.0'; // -- для google static map важно
       IndyHTTP.AllowCookies:=True;
       IndyHTTP.ProtocolVersion:=pv1_1;
       if Pos('HTTPS://',UpperCase(aURI))<>0
          then begin
          IndyHTTP.IOHandler:=TIdSSLIOHandlerSocketOpenSSL.Create(IndyHTTP);
          with (IndyHTTP.IOHandler as TIdSSLIOHandlerSocketOpenSSL)
             do begin
             SSLOptions.Method := sslvSSLv23;
             //SSLOptions.Mode := sslmUnassigned;
             //SSLOptions.VerifyMode := [];
             //SSLOptions.VerifyDepth := 0;
             end;
          end;
       IndyHTTP.Get(aURI, Stream);
       except
       IndyHTTP.Put(aURI, Stream);
       end;
       finally
       FreeAndNil(IndyHTTP);
       end;
       end;
      inf := 'Stream';
      Stream.Position := 0;
      if Stream.Size = 0 then
        Exit;
      pt := GetPictureType(Stream);
      inf := 'Image';
      case pt of
        ptPNG:
          begin
            png := TPNGImage.Create;
            try
              png.LoadFromStream(Stream);
              if BackColor<>Graphics.clNone
                 then begin
                 with aBMP do
                    begin
                    Width:=png.Width;
                    Height:=png.Height;
                    Canvas.Brush.Color:=BackColor;
                    Canvas.FillRect(Rect(0,0,Width,Height));
                    Canvas.Draw(0,0,png);
                    end;
                 end
                 else (aBMP as TGraphic).Assign(png as TGraphic);
            finally
              FreeAndNil(png);
            end;
          end;
        ptGIF:
          begin
            gif := TGIFImage.Create;
            try
              gif.LoadFromStream(Stream);
              (aBMP as TGraphic).Assign(gif as TGraphic);
            finally
              FreeAndNil(gif);
            end;
          end;
        ptICO:
          begin
            ico := TIcon.Create;
            try
              ico.LoadFromStream(Stream);
              (aBMP as TGraphic).Assign(ico as TGraphic);
            finally
              FreeAndNil(ico);
            end;
          end;
        ptBitmap:
          begin
            aBMP.LoadFromStream(Stream);
          end;
        ptJPG:
          begin
            jpg := TJpegImage.Create;
            try
              jpg.LoadFromStream(Stream);
              (aBMP as TGraphic).Assign(jpg as TGraphic);
            finally
              FreeAndNil(jpg);
            end;
          end;
        ptTIFF:
          begin
            tif:=TWICImage.Create;
            try
              tif.LoadFromStream(Stream);
              (aBMP as TGraphic).Assign(tif as TGraphic);
            finally
            tif.Free;
            end ;
          end;
        ptWMF:
          begin
            wmf := TMetafile.Create;
            try
              wmf.LoadFromStream(Stream);
              (aBMP as TGraphic).Assign(wmf as TGraphic);
            finally
              FreeAndNil(wmf);
            end;
          end;
      else begin
      Stream.Position:=0;
      inf:=SetTailBackSlash(GetDocFolder)+'Khs_Soft\'+ChangeFileext(ExtractFileName(Paramstr(0)),'')+'\UnknownPics\';
      if not DirectoryExists(inf)
         then if not ForceDirectories(inf)
                 then inf:=SetTailBackSlash(GetTempFolder);
      inf:=inf+ExtractFileName(StringReplace(aURI,'/','\',[rfReplaceAll]));
      Stream.SaveToFile(inf);
      end;
      end;
      Result := true;
    finally
      Stream.Free;
    end;
  except
    on E: Exception do
    begin
      //CreateErrorMessage('LoadImageIntoBitmap', E,[inf, aURI], inf);
      //WriteLn(inf);
      //MessageBox(Application.Handle, PChar(inf), 'Сбой выполнения', MB_ICONWARNING);
    end;
  end;
end;

(*Загрузка файла из Internet-а ---------------------------------------------*)
function LoadImageFromURLIntoFile(const aURL, aFolder:string; aRaiseError: boolean): boolean;
var
  IndyHTTP: TidHTTP;
  Stream: TMemoryStream;
  FileName:string;
begin
  Result := false;
  if FileExists(aURL)
     then begin
     CopyFile(PChar(aURL), PChar(SetTailBackSlash(aFolder)+ ExtractFileNameFromURL(aURL)), false);
     FileOpenNT(aURL);
     Exit;
     end;
  FileName := SetTailBackSlash(aFolder)+ ExtractFileNameFromURL(aURL);
  Stream := TMemoryStream.Create;
  IndyHTTP := TidHTTP.Create(nil);
  try
    try
      try
        IndyHTTP.Get(aURL, Stream);
      except
        on E: Exception do
        begin
          if aRaiseError then
            MessageBox(Application.Handle,
              PWideChar(Format('ERROR. %s(%s) : %s. %s ',
              ['LoadImageFromURLIntoFile (Get)', aURL, E.Message,
              GetErrorString])), 'Сбой выполнения', MB_ICONWARNING);
          Exit;
        end;
      end;
      Stream.Position := 0;
      if Stream.Size = 0 then
        Exit;
      Stream.SaveToFile(FileName);
      Result := true
    except
      on E: Exception do
      begin
        if aRaiseError then
          MessageBox(Application.Handle, PWideChar(Format('ERROR. %s : %s. %s ',
            ['LoadImageFromURLIntoFile', E.Message, GetErrorString])),
            'Сбой выполнения', MB_ICONWARNING);
      end;
    end;
  finally
    FreeAndNil(IndyHTTP);
    Stream.Free;
  end;
end;


function LoadURLIntoStream(const aURL : string; var aStream : TMemoryStream; aRaiseError: boolean): boolean;
var
  IndyHTTP: TidHTTP;
  psA : integer;
  hdr : string;
  pt  : TPicType;
  cntPT  : TPicType;
begin
Result:=false;
if not Assigned(aStream)
   then aStream:=TMemoryStream.Create
   else aStream.Clear;
try
try
if FileExists(aURL)
   then begin
   aStream.LoadFromFile(aURL);
   aStream.Position:=0;
   end
   else
if IsValidURL(aURL)
   then begin
   IndyHTTP := TidHTTP.Create(nil);
   try
    try
    IndyHTTP.Get(aURL, aStream);
    finally
    FreeAndNil(IndyHTTP);
    end;
   except
   on E: Exception
       do begin
       if aRaiseError
          then MessageBox(Application.Handle, PWideChar(Format('ERROR. %s(%s) : %s. %s ', ['LoadURLIntoStream (Get)', aURL, E.Message, GetErrorString])), 'Сбой выполнения', MB_ICONWARNING);
       end;
   end;
   end
   else begin
   psA:=AnsiPos(',',aURL);
   if psA>0
      then begin
      hdr:=AnsiLowerCase(Copy(aURL,1,psA));
      pt:=ptNotImage;
      for cntPT:=Low(PicDataBase64) to High(PicDataBase64)
         do if hdr=PicDataBase64[cntPT]
               then begin
               pt:=cntPT;
               Break;
               end;
      if pt=ptNotImage
         then Exit;
      end;
   hdr:=Copy(aURL,Length(hdr)+1,Length(aURL));
   Base64_DecodeStringToStream(hdr,aStream);
   aStream.Position:=0;
   if GetPictureType(aStream)=ptNotImage
      then aStream.Clear;
   end;
finally
aStream.Position := 0;
Result:=aStream.Size > 0
end;
except
  on E: Exception do
  begin
    if aRaiseError then
      MessageBox(Application.Handle, PWideChar(Format('ERROR. %s : %s. %s ',
        ['LoadImageFromURLIntoFile', E.Message, GetErrorString])),
        'Сбой выполнения', MB_ICONWARNING);
  end;
end;
end;



function LoadStringFromURL(const aURL:string):string;
var
  IndyHTTP: TidHTTP;
  Stream: TMemoryStream;
  buf: PChar;
  dop: PAnsiChar;
  sz: integer;
  Utmp:string;
  stp : string;
begin
if FileExists(aURL)
   then begin
   Result:=LoadStringFromFile(aURL);
   Exit;
   end;

stp:='Подготовка';
  Result := '';
  IndyHTTP := TidHTTP.Create(nil);
  Stream := TMemoryStream.Create;
  try
    try
      stp:='Выполнение "GET"';
      IndyHTTP.Request.UserAgent:='Mozilla/3.0'; // -- для google static map важно
      IndyHTTP.Request.Accept:='plain/text;*/*';
      IndyHTTP.AllowCookies:=True;
      IndyHTTP.ProtocolVersion:=pv1_1;
      IndyHTTP.ReadTimeout:=500;
      IndyHTTP.ConnectTimeout:=1500;
      if Pos('HTTPS://',UpperCase(aURL))<>0
         then begin
          IndyHTTP.IOHandler:=TIdSSLIOHandlerSocketOpenSSL.Create(IndyHTTP);
          with (IndyHTTP.IOHandler as TIdSSLIOHandlerSocketOpenSSL)
             do begin
             SSLOptions.Method := sslvSSLv23;
             //SSLOptions.Mode := sslmUnassigned;
             //SSLOptions.VerifyMode := [];
             //SSLOptions.VerifyDepth := 0;
             end;
          end;
      try
      IndyHTTP.Get(aURL, Stream);
      except
      IndyHTTP.Put(aURL, Stream);
      end;


      Stream.Position := 0;
      sz := Stream.Size * SizeOfChar;
      dop := Allocmem(Stream.Size + 1);
      buf := Allocmem(sz + 1);
      try
      stp:='Чтение потока';
        Stream.Read(dop^, sz);
      stp:='Декодирование строки';
        UnicodeToUTF8(string(StrPas(dop)), Utmp);
      stp:='Копирование буфера';
        StrPCopy(buf, Utmp);

        Result := StrPas(buf);
      finally
      stp:='Освобождение памяти';
        FreeMem(buf);
        FreeMem(dop);
      end;
    except
      on E: Exception do
      begin
        MessageBox(Application.Handle, PWideChar(Format('ERROR. %s : %s. %s ',
          ['LoadStringFromURL', E.Message, GetErrorString, stp, IfThen(Assigned(Stream),Format('Stream(байт):%d',[Stream.Size]),'No stream')])), 'Сбой выполнения',
          MB_ICONWARNING);
      end;
    end;

  finally
    FreeAndNil(IndyHTTP);
    Stream.Free;
  end;
end;


function LoadStringFromURI(const aURI : string; var aErrMsg : string; ahMod : cardinal = 0):string;
const
 ResTypes : array[0..2] of PChar = (RT_HTML, RT_STRING, RT_RCDATA);
 ResInfo  : array[0..2] of string = ('HTML', 'STRING', 'RCDATA');
var  // sequence : resources, files, url
 hndl   : cardinal;
 res    : cardinal;
 cnt    : integer;
 rt     : string;
 sz     : cardinal;
 stream : TMemoryStream;
 buf    : PAnsiChar;
 mem    : HGLOBAL;
begin
//if (Length(fn)>=MAX_PATH) then fn:='\\?\UNC\'+StringReplace(fn,'\\','',[]);
aErrMsg:='';
Result:='';
try
stream := TMemoryStream.Create;
try
if ahMod=0
   then hndl := GetModuleHandle(PChar(ParamStr(0)))
   else hndl := ahMod;
if hndl>0
   then for cnt:=0 to High(ResTypes)
          do begin
          res := FindResource(hndl, PChar(aURI), ResTypes[cnt]);
          if res>0
             then begin
             rt:='resource '+ResInfo[cnt];
             break;
             end;
          end
   else res:=0;
if res>0 // -- resource
   then begin
   sz := SizeofResource(hndl, res);
   if sz > 0
      then begin
      mem := LoadResource(hndl, res);
      buf := LockResource(mem);
      try
      Result:=string(StrPas(buf));
      finally
      UnlockResource(res);
      end;
      end;
   end
else begin
rt:='request';
if FileExists(aURI) // -- file
   then begin
   Result:=LoadStringFromFile(aURI);
   rt:='file';
   end
   else begin// -- try load by URL
   Result:=LoadStringFromURL(aURI);
   rt:='url';
   end;
end;
if (Result<>'') and (stream.Size>0)
   then begin
   stream.Position:=0;
   buf:=AllocMem(stream.size+1);
   try
   stream.Read(buf^, stream.Size);
   Result:=string(StrPas(buf));
   finally
   FreeMem(buf);
   end;
   end;
finally
stream.Free;
end;
aErrMsg:='ok:'+rt;
except
 on E : Exception do CreateErrorMessage('LoadStringFromURI',E,[rt],aErrMsg);
end;
end;

procedure LoadImageFromResourceJPG(var aBMP: TBitmap;
  const aResourceName:string);
var
  res: hrsrc;
  buf: PChar;
  mem: hGlobal;
  sz: cardinal;
  ms: TMemoryStream;
  jpg: TJpegImage;
begin
  res := FindResource(HInstance, PChar(aResourceName), RT_RCDATA);
  if res = 0 then
    Exit;
  sz := SizeofResource(HInstance, res);
  if sz = 0 then
    Exit;
  mem := LoadResource(HInstance, res);
  ms := TMemoryStream.Create;
  buf := LockResource(mem);
  try
    ms.Write(buf^, sz);
    ms.Position := 0;
    if ms.Size = int64(sz)then
    begin
      jpg := TJpegImage.Create;
      try
        jpg.LoadFromStream(ms);
        if not Assigned(aBMP)then
          aBMP := TBitmap.Create;
        aBMP.Assign((jpg as TGraphic));
      finally
        FreeAndNil(jpg);
      end;
    end;
  finally
    UnlockResource(res);
    ms.Free;
  end;
end;

{
var
  Stream      : TMemoryStream;
  FileStream  : TfileStream;
  IndyHTTP    : TidHTTP;

  hndl        : cardinal;
  res         : hrsrc;
  mem         : hGlobal;
  buf         : PChar;
  sz          : cardinal;
  inf         : string;
begin
  Result := false;
  try
    inf := 'Start';
    if not Assigned(aBMP)
       then aBMP := TBitmap.Create;
    Stream := TMemoryStream.Create;
    try
    if ahndl <> 0
       then hndl := ahndl
       else hndl := GetModuleHandle(PChar(ParamStr(0)));
    res := FindResource(hndl, PChar(aURI), RT_RCDATA);
    inf := 'Data';
    if FileExists(aURI)
       then begin
       inf := 'File';
       FileStream := TfileStream.Create(aURI, fmOpenRead or fmShareDenyWrite);
        try
        Stream.LoadFromStream(FileStream);
        finally
        FileStream.Free;
        end;
       end
       else
    if (res > 0)
       then begin
       inf := 'Resource';
       sz := SizeofResource(hndl, res);
       if sz > 0
          then begin
          mem := LoadResource(hndl, res);
          buf := LockResource(mem);
           try
           Stream.Write(buf^, sz);
           finally
           UnlockResource(res);
           end;
          end;
       end
       else begin
       inf := 'URL';
       IndyHTTP := TidHTTP.Create(nil);
       try
       try
       IndyHTTP.Request.UserAgent:='Mozilla/3.0'; // -- для google static map важно
       IndyHTTP.AllowCookies:=True;
       IndyHTTP.ProtocolVersion:=pv1_1;
       if Pos('HTTPS://',UpperCase(aURI))<>0
          then begin
          IndyHTTP.IOHandler:=TIdSSLIOHandlerSocketOpenSSL.Create(IndyHTTP);
          with (IndyHTTP.IOHandler as TIdSSLIOHandlerSocketOpenSSL)
             do begin
             SSLOptions.Method := sslvSSLv23;
             //SSLOptions.Mode := sslmUnassigned;
             //SSLOptions.VerifyMode := [];
             //SSLOptions.VerifyDepth := 0;
             end;
          end;
       IndyHTTP.Get(aURI, Stream);
       except
       IndyHTTP.Put(aURI, Stream);
       end;
       finally
       FreeAndNil(IndyHTTP);
       end;
       end;
      inf := 'Stream';
      Stream.Position := 0;
      if Stream.Size = 0 then
        Exit;
      pt := GetPictureType(Stream);
      inf := 'Image';
      case pt of
        ptPNG:
          begin
            png := TPNGImage.Create;
            try
              png.LoadFromStream(Stream);
              (aBMP as TGraphic).Assign(png as TGraphic);
            finally
              FreeAndNil(png);
            end;
          end;
        ptGIF:
          begin
            gif := TGIFImage.Create;
            try
              gif.LoadFromStream(Stream);
              (aBMP as TGraphic).Assign(gif as TGraphic);
            finally
              FreeAndNil(gif);
            end;
          end;
        ptICO:
          begin
            ico := TIcon.Create;
            try
              ico.LoadFromStream(Stream);
              (aBMP as TGraphic).Assign(ico as TGraphic);
            finally
              FreeAndNil(ico);
            end;
          end;
        ptBitmap:
          begin
            aBMP.LoadFromStream(Stream);
          end;
        ptJPG:
          begin
            jpg := TJpegImage.Create;
            try
              jpg.LoadFromStream(Stream);
              (aBMP as TGraphic).Assign(jpg as TGraphic);
            finally
              FreeAndNil(jpg);
            end;
          end;
        ptTIFF:
          begin
            tif:=TWICImage.Create;
            try
              tif.LoadFromStream(Stream);
              (aBMP as TGraphic).Assign(tif as TGraphic);
            finally
            tif.Free;
            end ;
          end;
        ptWMF:
          begin
            wmf := TMetafile.Create;
            try
              wmf.LoadFromStream(Stream);
              (aBMP as TGraphic).Assign(wmf as TGraphic);
            finally
              FreeAndNil(wmf);
            end;
          end;
      else begin
      Stream.Position:=0;
      inf:=SetTailBackSlash(GetDocFolder)+'Khs_Soft\'+ChangeFileext(ExtractFileName(Paramstr(0)),'')+'\UnknownPics\';
      if not DirectoryExists(inf)
         then if not ForceDirectories(inf)
                 then inf:=SetTailBackSlash(GetTempFolder);
      inf:=inf+ExtractFileName(StringReplace(aURI,'/','\',[rfReplaceAll]));
      Stream.SaveToFile(inf);
      end;
      end;
      Result := true;
    finally
      Stream.Free;
    end;
  except
    on E: Exception do
    begin
      //CreateErrorMessage('LoadImageIntoBitmap', E,[inf, aURI], inf);
      //WriteLn(inf);
      //MessageBox(Application.Handle, PChar(inf), 'Сбой выполнения', MB_ICONWARNING);
    end;
  end;
end;

}







////--> http://www.php.su/phphttp/docs/rfc2616/rfc2616.pdf 14.18 Date: Tue, 15 Nov 1994 08:12:31 GMT
function DateTimeGMT(DateTime : TDateTime = 0) : string;
const
 shablon : string = 'ddd, dd mmm yyyy hh:nn:ss "GMT"';
var
 ft : TFormatSettings;
 st : TSystemTime;
 dt : TdateTime;
begin  // --> Parse : IdGlobalProtocols.RawStrInternetToDateTime
if DateTime=0
   then begin
   GetSystemTime(st);
   with st do dt:=EncodeDate(wYear,wMonth,wDay)+EncodeTime(wHour,wMinute,wSecond,wMilliseconds);
   end
   else dt:=DateTime;
GetLocaleFormatSettings(MAKELCID(MAKELANGID(1033, SUBLANG_ENGLISH_US), SORT_DEFAULT), ft);
Result:=FormatDateTime('ddd, dd mmm yyyy hh:nn:ss "GMT"',dt,ft);
end;

// -- aHeaders  - заголовки (авторизация, контекстозависимая инфа и т.п.)
// передаются строкой в виде Key:Value;......KeyN:ValueN ([:] - разделитель в паре [;] - разделитель строк заголовка)
procedure HTTPRequest(aMethod : THTTPMethod; const aURL, aHeaders, aData, aContentType : string; var aResultData,aResultMessage : string; waitTimeMS : integer = 500);
const
 Method : array[THTTPMethod] of string = ('GET','POST','PUT','DELETE');
var
 HTTP           : TidHTTP;
 ResponceStream : TMemoryStream;
 ResultStream   : TStringStream;
 SendStringList : TStringList;
 SendStream     : TMemoryStream;
 bytes          : TBytes;
begin
try
HTTP := TidHTTP.Create(nil);
ResponceStream:=TMemoryStream.Create;
try
  //HTTP.Request.UserAgent:='Mozilla/3.0'; // -- для google static map важно
  HTTP.Request.Accept:='text/html, application/xhtml+xml, application/json, plain/text, */*';
  HTTP.Request.UserAgent:='Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; .NET CLR 1.0.3705;)';
  HTTP.AllowCookies:=True;
  HTTP.ProtocolVersion:=pv1_1;
  HTTP.HandleRedirects:=true;
  if Pos('https://',LowerCase(aURL))=1
    then begin
    HTTP.IOHandler:=TIdSSLIOHandlerSocketOpenSSL.Create(HTTP);
    with TIdSSLIOHandlerSocketOpenSSL(HTTP.IOHandler) do
       begin
       SSLOptions.Method  := sslvSSLv23;
       ReadTimeout        := waitTimeMS;
       ConnectTimeout     := waitTimeMS;
       end;
    end
    else begin
    HTTP.ReadTimeout    :=waitTimeMS;
    HTTP.ConnectTimeout :=waitTimeMS;
    end;
    HTTP.Request.ContentType:=aContentType;
    HTTP.Request.Method:=Method[aMethod];
    try
    if aHeaders<>''
       then begin
//       HTTP.Request.CustomHeaders.Text:=StringReplace(aHeaders,';',crlf,[rfReplaceAll]);


       SendStringList:= TStringList.Create;
       try
       SendStringList.Text:=StringReplace(aHeaders,';',crlf,[rfReplaceAll]);
       HTTP.Request.CustomHeaders.AddStdValues(SendStringList);
       finally
       FreeStringList(SendStringList);
       end;
       end;
    SendStream:=TMemoryStream.Create;
    try
    if aData<>''
       then begin
       bytes:=BytesOf(AnsiString(aData));
       SendStream.WriteBuffer(bytes[0], Length(bytes));
       end;

    case aMethod of
    httpGet     : HTTP.Get(aURL, ResponceStream);
    httpPost    : HTTP.Post(aURL, SendStream, ResponceStream);
    httpPut     : HTTP.Put(aURL, SendStream, ResponceStream);
    httpDelete  : HTTP.Delete(aURL);
    end;

    finally
    SendStream.Free;
    end;
    except
    on E : EIdHTTPProtocolException
       do begin
       aResultData:=E.ErrorMessage;
       if HTTP.ResponseCode = 302  // -- лечится HTTP.HandleRedirects:=true;
          then ;
       end;
    end;
aResultMessage:=Format('%d;%s',[HTTP.ResponseCode, HTTP.ResponseText]);
if HTTP.ResponseCode=200 // -- нормально всё
   then begin
   // -- тут по хорошему проверять на тип содержимого нужно.....
   ResultStream:=TStringStream.Create;
   try
   ResponceStream.Position:=0;
   ResultStream.LoadFromStream(ResponceStream);
   ResultStream.Position:=0;
   aResultData:=ResultStream.DataString;
   finally
   FreeAndNil(ResultStream);
   end;
   end;
finally
FreeAndNil(ResponceStream);
FreeAndNil(HTTP);
end;
except
end;
end;



function SavePicture(aBMP : TBitmap; const aFilename : string; aPicType : TPicType): string;
var
  fn   : string;
  bmp  : TBitmap;
  IconSizeX : integer;
  IconSizeY : integer;
  AndMask   : TBitmap;
  XOrMask   : TBitmap;
  IconInfo  : TIconInfo;
  ico  : TIcon;
  jpg  : TJpegImage;
  png  : TPNGImage;
  gif  : TGIFImage;
  tif  : TWICImage;
  wmf  : TMetafile;
begin
Result := '';
try
  if not Assigned(aBMP)
    or (aBMP.Empty)
    or ((aBMP.Width=0) or (aBMP.Height=0))
    or (aPicType = ptNotImage)
    or (aFilename='')
    then Exit;
  fn:=aFilename;
  if AnsiUpperCase(ExtractFileExt(fn))<>PicExt[aPicType]
     then ChangeFileExt(fn,PicExt[aPicType]);
  case aPicType of
  ptBitmap  :
    begin
     bmp := TBitmap.Create;
     try
     aBMP.SaveToFile(aFilename);
     finally
     FreeAndNil(bmp);
     end;
    end;
  ptICO      :
    begin
    AndMask := TBitmap.Create;
    XOrMask := TBitmap.Create;
    ico := TIcon.Create;
    try
    IconSizeX := aBMP.Width;//GetSystemMetrics(SM_CXICON);
    IconSizeY := aBMP.Height;//GetSystemMetrics(SM_CYICON);
    AndMask.Monochrome := True;
    AndMask.Width := IconSizeX;
    AndMask.Height := IconSizeY;
    AndMask.Canvas.Brush.Color := clBlack;
    AndMask.Canvas.FillRect(Rect(0, 0, IconSizeX, IconSizeY));
    XOrMask.Width := IconSizeX;
    XOrMask.Height := IconSizeY;
    XORMask.Assign(aBMP);
    IconInfo.fIcon := true;
    IconInfo.xHotspot := 0;
    IconInfo.yHotspot := 0;
    IconInfo.hbmMask := AndMask.Handle;
    IconInfo.hbmColor := XOrMask.Handle;
    ico.Handle := CreateIconIndirect(IconInfo);
    ico.SaveToFile(aFilename);
    finally
    AndMask.Free;
    XOrMask.Free;
    DestroyIcon(ico.Handle);
    ico.Free;
    end;

    end;
  ptJPG      :
    begin
     jpg := TJpegImage.Create;
     try
     jpg.CompressionQuality := 100;
     jpg.Assign(aBMP);
     jpg.SaveToFile(aFilename);
     finally
     FreeAndNil(jpg);
     end;
    end;
  ptPNG      :
    begin
     png := TPNGImage.Create;
     try
     png.Assign(aBMP);
     png.CompressionLevel:=3;
     png.TransparentColor:=pngBackColor;
     //png.TransparentColor:=aBMP.TransparentColor;
     //png.Transparent:=aBMP.TransparentColor<>Graphics.clNone;
     png.SaveToFile(aFilename);
     finally
     FreeAndNil(png);
     end;
    end;
  ptGIF      :
    begin
     gif := TGIFImage.Create;
     try
     gif.Assign((aBMP as TGraphic));
     gif.SaveToFile(aFilename);
     finally
     FreeAndNil(gif);
     end;
    end;
  ptTIFF     :
    begin
     tif := TWICImage.Create;
     try
     tif.Assign(aBMP);
     tif.SaveToFile(aFilename);
     finally
     FreeAndNil(tif);
     end;
    end;
  ptWMF     :
    begin
     wmf := TMetafile.Create;
     try
     wmf.SetSize(aBMP.Width, aBMP.Height); // -- тут потом какие-то пересчеты происходят....
     with TMetafileCanvas.Create(wmf, 0) do
      try
      Draw(0,0,aBMP);
      finally
      Free;
      end;
     wmf.SaveToFile(aFilename);
     finally
     FreeAndNil(wmf);
     end;
    end;
  end;
  Result:=fn;
  except
    on E: Exception do CreateErrorMessage('SaveImage',E,[aFileName,PicExt[aPicType]],Result);
  end;
end;

//ptICO 'image/icon,image/x-icon', ptTIFF 'image/tiff', ptWMF 'image/wmf, image/x-win-metafile, image/x-wmf, video/wmf'
function AboutPictureType(const aExt:string):string;
var
  cnt: integer;
begin
  Result := '';
  for cnt := 0 to High(extList)do
    if string(extList[cnt].ext)= aExt then
    begin
      Result := string(extList[cnt].datatype);
      Exit;
    end;
end;

function AboutPictureType(const aPT:TPicType):string;
var
  cnt: integer;
begin
  Result := '';
  for cnt := 0 to High(extList)do
    if extList[cnt].pictype= aPT then
    begin
      Result := string(extList[cnt].datatype);
      Exit;
    end;
end;



function SaveResourceIntoFile(const aResource, aFilename : string) : boolean;
var
  res: hrsrc;
  buf: PChar;
  mem: hGlobal;
  sz: cardinal;
  ms: TMemoryStream;
begin
Result:=false;
try
  res := FindResource(HInstance, PChar(aResource), RT_RCDATA);
  if res = 0 then
    Exit;
  sz := SizeofResource(HInstance, res);
  if sz = 0 then
    Exit;
  mem := LoadResource(HInstance, res);
  ms := TMemoryStream.Create;
  buf := LockResource(mem);
  try
    ms.Write(buf^, sz);
    ms.Position := 0;
    if ms.Size = int64(sz)then
    begin
    ms.SaveToFile(aFileName);
    Result:=true;
    end;
  finally
    UnlockResource(res);
    ms.Free;
  end;
except
on E : Exception do ;
end;
end;



function GetCustomColors : string;
begin
Result:=
  'ColorA='+IntToHex(Graphics.ColorToRGB(clPaleRed       ),6)+crlf+
  'ColorB='+IntToHex(Graphics.ColorToRGB(clPaleGreen     ),6)+crlf+
  'ColorC='+IntToHex(Graphics.ColorToRGB(clPaleBlue      ),6)+crlf+
  'ColorD='+IntToHex(Graphics.ColorToRGB(clPaleYellow    ),6)+crlf+
  'ColorE='+IntToHex(Graphics.ColorToRGB(clPaleOrange    ),6)+crlf+
  'ColorF='+IntToHex(Graphics.ColorToRGB(clPaleFuchsia   ),6)+crlf+
  'ColorG='+IntToHex(Graphics.ColorToRGB(clSeaWaveLite   ),6)+crlf+
  'ColorH='+IntToHex(Graphics.ColorToRGB(clDarkGreen     ),6)+crlf+
  'ColorI='+IntToHex(Graphics.ColorToRGB(clDarkPaleRed   ),6)+crlf+
  'ColorJ='+IntToHex(Graphics.ColorToRGB(clDarkPaleGreen ),6)+crlf+
  'ColorK='+IntToHex(Graphics.ColorToRGB(clDarkPaleBlue  ),6)+crlf+
  'ColorL='+IntToHex(Graphics.ColorToRGB(clDarkPaleYellow),6)+crlf+
  'ColorM='+IntToHex(Graphics.ColorToRGB(clOrange        ),6)+crlf+
  'ColorN='+IntToHex(Graphics.ColorToRGB(clViolet        ),6)+crlf+
  'ColorO='+IntToHex(Graphics.ColorToRGB(clJapanCalc     ),6)+crlf+
  'ColorP='+'000000';
end;

function LoadCustomColors(const FileName : string) : string;
begin
Result:='';
if FileExists(FileName)
   then Result:=LoadStringFromURL(FileName);
if Result=''
   then Result:=GetCustomColors;
end;

procedure SaveCustomColors(const FileName,CustomColorsText : string);
begin
SaveStringIntoFileStream(CustomColorsText,FileName);
end;


procedure DrawError(var aPNG: TPNGImage;const aErrText:string);
var
  rct: TRect;
  bmp: TBitmap;
  dir:string;
begin
  bmp := TBitmap.Create;
  try
    with bmp do
    begin
      Canvas.Font.Name := 'Arial';
      Canvas.Font.Size := 9;
      Canvas.Font.Color := clNavy;
      Canvas.Brush.Color := clPaleRed;
      Width := 100;
      height := Canvas.TextHeight('ЙQ|Y')* 3;
      rct := Rect(0, 0, Width, height);
      DrawText(Canvas.Handle, aErrText, Length(aErrText), rct, DT_CENTER_CALC);
      if Width < rct.Right then
        Width := rct.Right;
      if height < rct.Bottom then
        height := rct.Bottom;
      DrawText(Canvas.Handle, aErrText, Length(aErrText), rct, DT_CENTER_ALIGN);
    end;
    dir := SetTailBackSlash(GetTempFolder)+ 'badPics\';
    if ForceDirectories(dir)then
      try
        bmp.SaveToFile(dir + FormatDateTime('yyyymmdd_hhnnsszz', Now)+ '.bmp');
      except
      end;
    if not Assigned(aPNG)then
      aPNG := TPNGImage.Create;
    aPNG.Assign(bmp);
  finally
    bmp.Free;
  end;
end;

procedure DrawError(var aGraphic: TGraphic;const aErrText:string); overload;
var
  rct: TRect;
  bmp: TBitmap;
  dir:string;
begin
  bmp := TBitmap.Create;
  try
    with bmp do
    begin
      Canvas.Font.Name := 'Arial';
      Canvas.Font.Size := 9;
      Canvas.Font.Color := clNavy;
      Canvas.Brush.Color := clPaleRed;
      Width := 100;
      height := Canvas.TextHeight('ЙQ|Y')* 3;
      rct := Rect(0, 0, Width, height);
      DrawText(Canvas.Handle, aErrText, Length(aErrText), rct, DT_CENTER_CALC);
      if Width < rct.Right then
        Width := rct.Right;
      if height < rct.Bottom then
        height := rct.Bottom;
      DrawText(Canvas.Handle, aErrText, Length(aErrText), rct, DT_CENTER_ALIGN);
    end;
    dir := SetTailBackSlash(GetTempFolder)+ 'badPics\';
    if ForceDirectories(dir)then
      try
        bmp.SaveToFile(dir + FormatDateTime('yyyymmdd_hhnnsszz', Now)+ '.bmp');
      except
      end;
    if not Assigned(aGraphic)then
      aGraphic := TPNGImage.Create;
    aGraphic.Assign(bmp);
  finally
    bmp.Free;
  end;
end;

(*Загрузка картинки из поля таблицы базы данных (с анализом типа картинки)--*)
function StreamToBMP(aStream: TStream;var aBMP: TBitmap): boolean;
var
  png: TPNGImage;
  gif: TGIFImage;
  jpg: TJpegImage;
  ico: TIcon;
  wmf: TMetafile;
  tif: TWICImage;
begin
Result:=False;
try
aStream.Position:=0;
case GetPictureType(aStream) of
ptPNG: begin
       png := TPNGImage.Create;
       try
       png.LoadFromStream(aStream);
       try
       //Project Router.exe raised exception class EPNGCannotChangeTransparent with message 'Setting bit transparency color is not allowed for png images containing alpha value for each pixel (COLOR_RGBALPHA and COLOR_GRAYSCALEALPHA)'.
       if not png.Header.ColorType in [COLOR_RGBALPHA, COLOR_GRAYSCALEALPHA]
          then png.TransparentColor:=Graphics.ColorToRGB(pngBackColor)
       except
       on E : Exception  do
         begin
         if E is EPNGCannotChangeTransparent
            then ;
         end;
       end;
       try
       (aBMP as TGraphic).Assign(png as TGraphic);
       except
       aBMP.Width:=png.Width;
       aBMP.Height:=png.Height;
       aBMP.Canvas.Draw(0,0,png);
       end;
       finally
       FreeAndNil(png);
       end;
       end;
ptGIF: begin
       gif := TGIFImage.Create;
       try
       gif.LoadFromStream(aStream);
       (aBMP as TGraphic).Assign(gif as TGraphic);
       finally
       FreeAndNil(gif);
       end;
       end;
ptICO: begin
       ico := TIcon.Create;
       try
       ico.LoadFromStream(aStream);
       (aBMP as TGraphic).Assign(ico as TGraphic);
       finally
       FreeAndNil(ico);
       end;
       end;
ptJPG: begin
       jpg := TJpegImage.Create;
       try
       jpg.LoadFromStream(aStream);
       (aBMP as TGraphic).Assign(jpg as TGraphic);
       finally
       FreeAndNil(jpg);
       end;
       end;
ptWMF: begin
       wmf := TMetafile.Create;
       try
       wmf.LoadFromStream(aStream);
       (aBMP as TGraphic).Assign(wmf as TGraphic);
       finally
       FreeAndNil(wmf);
       end;
       end;
ptTIFF:begin
       tif:=TWICImage.Create;
       try
       tif.LoadFromStream(aStream);
       (aBMP as TGraphic).Assign(tif as TGraphic);
       finally
       tif.Free;
       end ;
       end;
ptBitmap: begin
          aBMP.LoadFromStream(aStream);
          end;
else begin
//  Stream.Position:=0;
//  inf:=SetTailBackSlash(GetDocFolder)+'Khs_Soft\'+ChangeFileext(ExtractFileName(Paramstr(0)),'')+'\UnknownPics\';
//  if not DirectoryExists(inf)
//     then if not ForceDirectories(inf)
//             then inf:=SetTailBackSlash(GetTempFolder);
//  inf:=inf+ExtractFileName(StringReplace(aURI,'/','\',[rfReplaceAll]));
//  Stream.SaveToFile(inf);
Result:=False;
Exit;
end;
end;
Result:=True;
except
end;
end;


(*Загрузка картинки из поля таблицы базы данных (с анализом типа картинки)--*)
function PicStreamProps(aStream: TStream;var aWidth,aHeight: integer): boolean;
var
  png: TPNGImage;
  gif: TGIFImage;
  jpg: TJpegImage;
  ico: TIcon;
  wmf: TMetafile;
  tif: TWICImage;
  bmp: TBitmap;
begin
aWidth:=-1;
aHeight:=-1;
Result:=False;
try
aStream.Position:=0;
case GetPictureType(aStream) of
ptPNG: begin
       png := TPNGImage.Create;
       try
       png.LoadFromStream(aStream);
       png.TransparentColor:=pngBackColor;
       aWidth:=png.Width;
       aHeight:=png.Height;
       finally
       FreeAndNil(png);
       end;
       end;
ptGIF: begin
       gif := TGIFImage.Create;
       try
       gif.LoadFromStream(aStream);
       aWidth:=gif.Width;
       aHeight:=gif.Height;
       finally
       FreeAndNil(gif);
       end;
       end;
ptICO: begin
       ico := TIcon.Create;
       try
       ico.LoadFromStream(aStream);
       aWidth:=ico.Width;
       aHeight:=ico.Height;
       finally
       FreeAndNil(ico);
       end;
       end;
ptJPG: begin
       jpg := TJpegImage.Create;
       try
       jpg.LoadFromStream(aStream);
       aWidth:=jpg.Width;
       aHeight:=jpg.Height;
       finally
       FreeAndNil(jpg);
       end;
       end;
ptWMF: begin
       wmf := TMetafile.Create;
       try
       wmf.LoadFromStream(aStream);
       aWidth:=wmf.Width;
       aHeight:=wmf.Height;
       finally
       FreeAndNil(wmf);
       end;
       end;
ptTIFF:begin
       tif:=TWICImage.Create;
       try
       tif.LoadFromStream(aStream);
       aWidth:=tif.Width;
       aHeight:=tif.Height;
       finally
       tif.Free
       end ;
       end;
ptBitmap:
       begin
       bmp := TBitmap.Create;
       try
       bmp.LoadFromStream(aStream);
       aWidth:=bmp.Width;
       aHeight:=bmp.Height;
       finally
       FreeAndNil(bmp);
       end;
       end;
else begin
//  Stream.Position:=0;
//  inf:=SetTailBackSlash(GetDocFolder)+'Khs_Soft\'+ChangeFileext(ExtractFileName(Paramstr(0)),'')+'\UnknownPics\';
//  if not DirectoryExists(inf)
//     then if not ForceDirectories(inf)
//             then inf:=SetTailBackSlash(GetTempFolder);
//  inf:=inf+ExtractFileName(StringReplace(aURI,'/','\',[rfReplaceAll]));
//  Stream.SaveToFile(inf);
Result:=False;
Exit;
end;
end;
Result:=True;
except
end;
end;

function FieldToBMP(aField: TField;var aBMP: TBitmap): boolean;
var
  strm: TMemoryStream;
  bytes: array of Byte;
  ln: integer;
begin
Result := false;
if(aField.IsNull)(*or not (aField.IsBlob)*)then Exit;
if not Assigned(aBMP) then aBMP := TBitmap.Create;
strm := TMemoryStream.Create;
try
ln := Length(aField.AsBytes);
if ln > 0
   then begin
   SetLength(bytes, ln);
   System.Move(aField.AsBytes[0], bytes[0], ln);
   end;
strm.WriteBuffer((@bytes[0])^, ln);
StreamToBMP(strm,aBMP);
finally
Result := Assigned(aBMP)and(aBMP.Width <> 0)and(aBMP.height <> 0);
FreeAndNil(strm);
end;
end;

//function FieldToPNG(aField: TField;var aPNG: TPNGImage): boolean;
//var
//  strm: TMemoryStream;
//  //bytes   : array of byte;
//  ln: integer;
//  tmp:string;
//  tmpPNG: TPNGImage;
//begin
//  Result := false;
//  ln := 0;
//  try
//    if(aField.IsNull)(*or not (aField.IsBlob)*)then
//      Exit;
//    if not Assigned(aPNG)then
//      Exit;
//    tmpPNG := TPNGImage.Create;
//    strm := TMemoryStream.Create;
//    try
//      ln := Length(aField.AsBytes);
//      //SetLength(bytes,ln);
//      //try
//      //if ln>0
//      //then begin
//      //System.Move(aField.AsBytes[0],bytes[0],ln);
//      // //strm.WriteBuffer((@bytes[0])^,ln);
//      //strm.Write((@bytes[0])^,ln);
//      // //strm.WriteBuffer(bytes,ln);
//      //end;
//      //finally
//      //Setlength(bytes,0);
//      //end;
//      strm.Size := ln;
//      strm.seek(0, soFromBeginning);
//      if ln > 0 then
//        strm.Write((@aField.AsBytes[0])^, ln)
//      else
//        Exit;
//      strm.seek(0, soFromBeginning);
//      ln := strm.Size;
//      sleep(1);
//
//      if(ln > 0)and Assigned(aPNG)then
//      begin
//        tmpPNG.LoadFromStream(strm);
//        aPNG.Assign(tmpPNG);
//      end
//      else
//        DrawError(aPNG, 'Empty stream or not valid PNG.');
//    finally
//      tmpPNG.Free;
//      Result := Assigned(aPNG)and(aPNG.Width <> 0)and(aPNG.height <> 0);
//      if Assigned(strm)then
//      begin
//        strm.Clear;
//        strm.Free;
//      end;
//    end;
//  except
//    on E: Exception do
//    begin
//      CreateErrorMessage('FieldToPNG', E,[aPNG.ClassName, aPNG.Width,
//        aPNG.height, ln], tmp);
//      DrawError(aPNG, tmp);
//      Result := false;
//    end;
//  end;
//end;

function FieldToGraphic(aField: TField; aGraphic: TGraphic; aCheckSize: int64 = 0): boolean;
var
  strm: TMemoryStream;
  bytes: array of Byte;
  ln: integer;
  tmp:string;
  tmpGrph: TGraphic;
  //strm: TStream;
  //ln  : integer;
  //tmp : string;
begin
  Result := false;
  ln := 0;
  try
    if(aField.IsNull)(*or not (aField.IsBlob)*)then
      Exit;
    if not Assigned(aGraphic)then
      Exit;
    //strm:=TBlobStream.Create(TBlobField(aField), bmRead);
    //try
    //ln:=strm.Size;
    //strm.Seek(0,soFromBeginning);
    //aGraphic.LoadFromStream(strm as TStream) ;
    //_sleep(1);
    //finally
    //Result:=Assigned(aGraphic) and (aGraphic.Width<>0) and (aGraphic.Height<>0);
    //if Assigned(strm)
    //then strm.Free;
    //end;
    if aGraphic is TPNGImage then
      tmpGrph := TPNGImage.Create
    else if aGraphic is TJpegImage then
      tmpGrph := TJpegImage.Create
    else if aGraphic is TGIFImage then
      tmpGrph := TGIFImage.Create
    else if aGraphic is TBitmap then
      tmpGrph := TBitmap.Create
    else
      Exit;

    strm := TMemoryStream.Create;
    try
      ln := Length(aField.AsBytes);
      SetLength(bytes, ln);
      try
        if ln > 0 then
        begin
          System.Move(aField.AsBytes[0], bytes[0], ln);
          strm.WriteBuffer((@bytes[0])^, ln);
          //strm.WriteBuffer(bytes,ln);
        end;
      finally
        SetLength(bytes, 0);
      end;
      strm.Position := 0;
      if(aCheckSize > 0)then
        if aCheckSize <> strm.Size then
        begin
          DrawError(aGraphic, 'Bad Size of a Picture.');
        end;
      ln := strm.Size;
      strm.seek(0, 0);
      if(ln > 0)and Assigned(aGraphic)then
      begin
        tmpGrph.LoadFromStream(strm);
        aGraphic.Assign(tmpGrph);
      end
      else
        DrawError(aGraphic, 'Empty stream or not valid Graphic.');
    finally
      tmpGrph.Free;
      Result := Assigned(aGraphic)and(aGraphic.Width <> 0)and
        (aGraphic.height <> 0);
      if Assigned(strm)then
      begin
        strm.Clear;
        strm.Free;
      end;

      //FreeAndNil(strm);
    end;
  except
    on E: Exception do
    begin
      CreateErrorMessage('FieldToGraphic', E,
        [aGraphic.ClassName, aGraphic.Width, aGraphic.height, ln], tmp);
      DrawError(aGraphic, tmp);
      Result := false;
      //Result:=Assigned(aGraphic) and (aGraphic.Width<>0) and (aGraphic.Height<>0);
    end;
  end;
end;



//function FieldToGraphic(aField : TField; var aGraphic : TGraphic; aCheckSize : int64 = 0) : boolean;
//procedure DrawError(const aErrText : string);
//var
//rct : Trect;
//bmp : TBitmap;
//dir : string;
//begin
//bmp:=TBitmap.Create;
//try
//with bmp do
//begin
//Canvas.Font.Name:='Arial';
//Canvas.Font.Size:=9;
//Canvas.Font.Color:=clNavy;
//Canvas.Brush.Color:=clPaleRed;
//Width:=100;
//Height:=Canvas.TextHeight('ЙQ|Y')*3;
//rct:=Rect(0,0,Width,Height);
//DrawText(Canvas.Handle,aErrText,Length(aErrText),rct,DT_CENTER_CALC);
//if Width<rct.Right then Width:=rct.Right;
//if Height<rct.Bottom then Height:=rct.Bottom;
//DrawText(Canvas.Handle,aErrText,Length(aErrText),rct,DT_CENTER_ALIGN);
//end;
//dir:=SetTailBackSlash(GetTempFolder)+'badPics\';
//if ForceDirectories(dir)
//then try
//bmp.SaveToFile(dir+FormatDateTime('yyyymmdd_hhnnsszz',Now)+'.bmp');
//except
//end;
//if not Assigned(aGraphic) then aGraphic:=TPngImage.Create;
//aGraphic.Assign(bmp);
//finally
//bmp.Free;
//end;
//end;
//var
//strm    : TMemoryStream;
//bytes   : array of byte;
//ln      : integer;
//tmp     : string;
/// / strm: TStream;
/// / ln  : integer;
/// / tmp : string;
//begin
//Result:=False;
//ln:=0;
//try
//if (aField.IsNull) (*or not (aField.IsBlob)*) then Exit;
//if not Assigned(aGraphic) then Exit;
/// /strm:=TBlobStream.Create(TBlobField(aField), bmRead);
/// /try
/// /ln:=strm.Size;
/// /strm.Seek(0,soFromBeginning);
/// /aGraphic.LoadFromStream(strm as TStream) ;
/// /_sleep(1);
/// /finally
/// /Result:=Assigned(aGraphic) and (aGraphic.Width<>0) and (aGraphic.Height<>0);
/// /if Assigned(strm)
/// /   then strm.Free;
/// /end;
//strm:=TMemoryStream.Create;
//try
//ln:=Length(aField.AsBytes);
//SetLength(bytes,ln);
//try
//if ln>0
//then begin
//System.Move(aField.AsBytes[0],bytes[0],ln);
//strm.WriteBuffer((@bytes[0])^,ln);
// //strm.WriteBuffer(bytes,ln);
//end;
//finally
//Setlength(bytes,0);
//end;
//strm.Position:=0;
//if (aCheckSize>0)
//then if aCheckSize<>strm.Size
//then begin
//DrawError('Bad Size of a Picture.');
//end;
//ln:=strm.Size;
//strm.seek(0,0);
//if (ln>0) and Assigned(aGraphic)
//then aGraphic.LoadFromStream(strm)
//else DrawError('Empty stream or not valid Graphic.');
//finally
//Result:=Assigned(aGraphic) and (aGraphic.Width<>0) and (aGraphic.Height<>0);
//if Assigned(strm)
//then begin
//strm.Clear;
//strm.Free;
//end;
//
/// /FreeAndNil(strm);
//end;
//except
//on E : Exception
//do begin
//CreateErrorMessage('FieldToGraphic',E,[aGraphic.ClassName,aGraphic.Width,aGraphic.Height,ln],tmp);
//DrawError(tmp);
//Result:=False;
// //Result:=Assigned(aGraphic) and (aGraphic.Width<>0) and (aGraphic.Height<>0);
//end;
//end;
//end;

procedure GraphicToField(aGraphic: TGraphic; aField: TField);
var
  ts: TStream;
begin
  aField.Value := null;
  if not Assigned(aGraphic)then
    Exit;
  ts := TMemoryStream.Create;
  try
    aGraphic.SaveToStream(ts);
    ts.Position := 0;
    TBlobField(aField).LoadFromStream(ts);
  finally
    FreeAndNil(ts);
  end;
end;

{* Запись изображения в параметр хранимой процедуры                           *}
procedure GraphicToParameter(aParam: TParameter; aGraphic: TGraphic);
var
  ts: TStream;
begin
  aParam.Value := null;
  if not Assigned(aGraphic)then
    Exit;
  ts := TMemoryStream.Create;
  try
    aGraphic.SaveToStream(ts);
    ts.Position := 0;
    aParam.LoadFromStream(ts, ftBLOB);
  finally
    FreeAndNil(ts);
  end;
end;

(*Копирование Bitmap в буфер обмена ----------------------------------------*)


procedure CopyBitmapToClipBoard(const aBitmap: TBitmap);
var
  MyFormat: Word;
  AData: cardinal;
  APalette: hPalette;
begin
  if not Assigned(aBitmap)then
    Exit;
  Clipboard.Clear;
  aBitmap.SaveToClipBoardFormat(MyFormat, AData, APalette);
  Clipboard.SetAsHandle(MyFormat, AData);
end;


procedure CopyBitmapToClipBoard_NEW(const aBitmap: TBitmap);
var
  MyFormat: Word;
  AData: cardinal;
  APalette: hPalette;
  bmp  :TBitmap;

begin

//aBitmap.SaveToFile(SettailBackSlash(GetDesktopFolder)+'0\1.bmp');
  if not Assigned(aBitmap)then
    Exit;
  Clipboard.Clear;
  bmp:=TBitmap.Create;
  try
  bmp.Width:=aBitmap.Width;
  bmp.Height:=aBitmap.Height;
  bmp.PixelFormat:=pf32bit;
  BitBlt(bmp.Canvas.Handle,0,0,bmp.Width,bmp.Height,aBitmap.canvas.Handle,0,0,SRCCOPY);
  //bmp.SaveToFile(SettailBackSlash(GetDesktopFolder)+'0\2.bmp');
  bmp.SaveToClipBoardFormat(MyFormat, AData, APalette);
  finally
  bmp.Free;
  //bmp:=nil;
  end;

  Clipboard.SetAsHandle(MyFormat, AData);
end;


procedure CopyGraphicToClipBoard(const aGraphic: TGraphic);
var
  MyFormat: Word;
  AData: cardinal;
  APalette: hPalette;
begin
  Clipboard.Clear;
  aGraphic.SaveToClipBoardFormat(MyFormat, AData, APalette);
  Clipboard.SetAsHandle(MyFormat, AData);
end;


function PasteBitmapFromClipBoard(aBitmap : TBitmap) : boolean;
begin
Result:=False;
if Clipboard.HasFormat(CF_BITMAP)  // check for another grfaphic formats!!!
   then begin
   aBitmap.LoadFromClipboardFormat(CF_BITMAP,ClipBoard.GetAsHandle(CF_BITMAP),0);
   Result:=True;
   end;
end;

procedure BitmapV5HeaderIntoBitmap(var bmp : TBitmap);
var
 bytes : TBytes;
 header : TBitmapV5Header;
 BytesOnPixel : integer;
 LineInBytes : integer;
 currentPos : integer;
 rows  :integer;
 line : Pointer;
begin
if Assigned(bmp)
   then try bmp.Free except end;
bmp:=nil;
GetBytesFromClipboard(bytes,17);
if length(bytes)=0 then Exit;
System.Move(bytes[0],header,SizeOf(TBitmapV5Header)); // SizeOf(BITMAPV5HEADER)
if (header.bV5Width=0) or (header.bV5Height=0)
   then Exit;
bmp:=TBitmap.Create;
bmp.Width :=header.bV5Width;
bmp.Height:=header.bV5Height;
BytesOnPixel:=(header.bV5BitCount div 8);
LineInBytes:=BytesOnPixel*bmp.Width;
case BytesOnPixel of
1: bmp.PixelFormat:=pf8bit;
2: bmp.PixelFormat:=pf16bit;
3: bmp.PixelFormat:=pf24bit;
4: bmp.PixelFormat:=pf32bit;
end;
currentPos:=header.bV5Size(*сам*) + SizeOf(CIEXYZTRIPLE)(*структура в нем*)+4;
for rows:=bmp.Height-1 downto 0
  do begin
  line:=bmp.ScanLine[rows];
  System.Move(bytes[currentPos],line^, LineInBytes);
  inc(currentPos, LineInBytes);
  end;
end;


procedure BitmapHeaderIntoBitmap(var bmp : TBitmap);
var
 bytes : TBytes;
 header : TBitmapInfoHeader;
 BytesOnPixel : integer;
 LineInBytes : integer;
 currentPos : integer;
 rows  :integer;
 line : Pointer;
begin
if Assigned(bmp)
   then try bmp.Free except end;
bmp:=nil;
GetBytesFromClipboard(bytes,8);
if length(bytes)=0 then Exit;
System.Move(bytes[0],header,SizeOf(TBitmapInfoHeader)); // SizeOf(BITMAPV5HEADER)
if (header. biWidth=0) or (header.biHeight=0)
   then Exit;
bmp:=TBitmap.Create;
bmp.Width :=header.biWidth;
bmp.Height:=header.biHeight;
BytesOnPixel:=(header.biBitCount div 8);
LineInBytes:=BytesOnPixel*bmp.Width;
case BytesOnPixel of
1: bmp.PixelFormat:=pf8bit;
2: bmp.PixelFormat:=pf16bit;
3: bmp.PixelFormat:=pf24bit;
4: bmp.PixelFormat:=pf32bit;
end;
currentPos:=header.biSize(*сам*) + 12;//+ SizeOf(CIEXYZTRIPLE)(*структура в нем*)+4;
for rows:=bmp.Height-1 downto 0
  do begin
  line:=bmp.ScanLine[rows];
  System.Move(bytes[currentPos],line^, LineInBytes);
  inc(currentPos, LineInBytes);
  end;
end;


function UpdateScreenShot(const basewnd : cardinal; var nextWnd: cardinal;const Txt : string) : integer;
var
 bmp    : TBitmap;
 inf    : TBitmap;
 rctCalc: TRect;
 rctWnd : TRect;
 rctTxt : Trect;
 str    : string;
 cnt    : integer;
 wdtTxt : integer;
 wdt    : integer;
 sda    : TStringDynArray;
 Pt     : TPoint;
begin
Result:=0;
try
bmp:=TBitmap.Create;
inf:=TBitmap.Create;
try
if Clipboard.HasFormat(CF_PICTURE)
   then bmp.Assign(Clipboard)
   else Exit;
ChangeClipboardChain(baseWnd, nextWnd);
ClipBoard.Clear;
bmp.PixelFormat:=pf32bit;
with inf do
  begin
  PixelFormat:=pf24bit;
  Canvas.Font.name:='Tahoma';
  Canvas.Font.Size:=10;
  Canvas.Font.Color:=clRed;
  Canvas.Brush.Color:=clWhite;
  Canvas.Pen.Color:=clRed;
  str:=StringReplace(Txt,#32,#160,[rfReplaceAll]);
  sda:=SplitString(str,#10);
  wdtTxt:=10;
  for cnt:=0 to high(sda)
    do begin
    rctCalc:=Bounds(0,0,1,20);
    DrawText(Canvas.Handle,PChar(sda[cnt]),Length(sda[cnt]),rctCalc,DT_CALCRECT or DT_LEFT or DT_TOP);
    wdt:=rctCalc.Right - rctCalc.Left;
    if wdt>wdtTxt
       then wdtTxt:=wdt;
    end;
  wdtTxt:=wdtTxt+20;
  rctTxt:=Bounds(0,0,wdtTxt,Canvas.TextHeight('ЙQ|')*Length(sda)+4);
  Width:=rctTxt.Right-rctTxt.Left;
  Height:=rctTxt.Bottom - rctTxt.Top;
  canvas.Rectangle(rctTxt);
  rctTxt.Left:=rctTxt.Left+10;
  SetTextColor(Canvas.Handle,Graphics.ColorToRGB(clNavy));
  DrawTransparentText(Canvas.Handle,str,rctTxt,DT_LEFT or DT_TOP(* or DT_WORDBREAK*));
  end;
rctWnd:=Bounds(0,0,bmp.Width, bmp.Height);
Pt:=Point(rctWnd.Left+ ((rctWnd.Right - rctWnd.left) - inf.Width) div 2, 0);
AlphaBlt(bmp.Canvas,Pt.X, Pt.Y, inf.Width, inf.Height, inf.Canvas,0,0,inf.Width, inf.Height,160);
ClipBoard.Clear;
CopyBitmapToClipBoard(bmp);
Result:=Clipboard.GetHashCode;
finally
nextWnd:=SetClipboardViewer(baseWnd);
inf.Free;
bmp.Free;
end;
except
 on E : Exception do;
end
end;


function GetExtWODotForGraphic(const aGraphic: TGraphic):string;
begin
  Result := '';
  if aGraphic is TBitmap then
    Result := 'BMP'
  else if aGraphic is TJpegImage then
    Result := 'JPG'
  else if aGraphic is TPNGImage then
    Result := 'PNG'
  else if aGraphic is TIcon then
    Result := 'ICO'
  else if aGraphic is TMetafile then
    Result := 'WMF'
  else;
end;

(*Масштабирование Bitmap ---------------------------------------------------*)
procedure ScaleBitmap(var aBMP: TBitmap;const aKoef: double);
var
  tmpBMP: Graphics.TBitmap;
begin
tmpBMP := Graphics.TBitmap.Create;
try
  with tmpBMP
    do begin
    Width := Round(aBMP.Width * aKoef);
    height := Round(aBMP.height * aKoef);
    SetStretchBltMode(Canvas.Handle, STRETCH_HALFTONE);
    StretchBlt(Canvas.Handle, 0, 0, Width, height, aBMP.Canvas.Handle, 0, 0, aBMP.Width, aBMP.height, SRCCOPY);
    end;
aBMP.Assign(tmpBMP);
finally
FreeAndNil(tmpBMP);
end;
end;

(*Масштабирование Bitmap под TRect -----------------------------------------*)
function ScaleBitmap(var aBMP: TBitmap; aRect: TRect) : double;
begin
  Result:=BmpIntoRect(aBMP, aRect);
end;

function BmpIntoRect(var aBMP: TBitmap; aRect: TRect) : double;
var
  tmp: TBitmap;
begin
  Result :=(aRect.Bottom - aRect.Top)/ aBMP.Height;
  if Round(Result * aBMP.Width)>(aRect.Right - aRect.Left)
     then  Result :=(aRect.Right - aRect.Left)/ aBMP.Width;
try
  tmp := TBitmap.Create;
  try
    tmp.Width  := Round(aBMP.Width * Result);
    tmp.Height := Round(aBMP.Height * Result);
    SetStretchBltMode(tmp.Canvas.Handle, STRETCH_HALFTONE);
    StretchBlt(tmp.Canvas.Handle, 0, 0, tmp.Width, tmp.Height, aBMP.Canvas.Handle, 0, 0, aBMP.Width, aBMP.Height, SRCCOPY);
    //CopyBitmapToClipBoard(tmp);
    //aBMP.Assign(tmp);
    aBMP.Width := aRect.Right - aRect.Left;
    aBMP.height := aRect.Bottom - aRect.Top;
    //aBMP.Canvas.Brush.Color:=clFuchsia;
    //FillRect(aBMP.Canvas.Handle,Bounds(0,0,aBMP.Width,aBMP.Height),aBMP.Canvas.Brush.Handle);
    aBMP.Assign(tmp);
    //BitBlt(aBMP.canvas.Handle,0,0,tmp.Width, tmp.Height, tmp.Canvas.Handle, 0,0, SRCCOPY);
  finally
//    FreeAndNil(tmp);
   tmp.FreeImage;
   tmp.Free;
  end;
except
 on E : Exception do
   begin
   if (aBMP<>nil) or (aRect.Left<>0) then ;
   end;
end;
end;

procedure BmpIntoRect(SrcBMP: TBitmap; aRect: TRect; var ResBMP : TBitmap);
var
 cntW : integer;
 cntH : integer;
 bmpLine : TBitmap;
 bmpVert : TBitmap;
begin
try
bmpLine:=TBitmap.Create;
bmpVert:=TBitmap.Create;
try
bmpLine.Width:=Round((aRect.Right - aRect.Left) / SrcBMP.Width + 1)*SrcBMP.Width;
bmpLine.Height:=SrcBMP.Height;

bmpVert.Assign(SrcBMP);
//VertTurnBitmap(bmpVert);

ResBMP.Width:=aRect.Right - aRect.Left;
ResBMP.Height:=aRect.Bottom - aRect.Top;

cntW:=0;
while cntW<ResBMP.Width
  do begin
  if Odd(cntW)
     then BitBlt(bmpLine.Canvas.Handle,cntW,0,SrcBMP.Width,SrcBMP.Height,SrcBMP.canvas.Handle,0,0,SRCCOPY)
     else BitBlt(bmpLine.Canvas.Handle,cntW,0,bmpVert.Width,bmpVert.Height,bmpVert.canvas.Handle,0,0,SRCCOPY);


  cntW:=cntW+SrcBMP.Width;
  end;

cntH:=0;
while cntH<ResBMP.Height
  do begin
  BitBlt(ResBMP.Canvas.Handle,0,cntH,bmpLine.Width,bmpLine.Height,bmpLine.canvas.Handle,0,0,SRCCOPY);
  cntH:=cntH+SrcBMP.Height;
  end;
  finally
   bmpVert.FreeImage;
   bmpVert.Free;
   bmpLine.FreeImage;
   bmpLine.Free;
  end;
except
 on E : Exception do
   begin

   end;
end;
end;

function BmpIntoRectByHeight(var aBMP: TBitmap; aRect: TRect): integer;
var
  koef: double;
  tmp: TBitmap;
begin
  koef :=(aRect.Bottom - aRect.Top)/ aBMP.height;
  Result := Round(koef * aBMP.Width);
  tmp := TBitmap.Create;
  try
    tmp.Width := Round(aBMP.Width * koef);
    tmp.height := Round(aBMP.height * koef);
    SetStretchBltMode(tmp.Canvas.Handle, STRETCH_HALFTONE);
    StretchBlt(tmp.Canvas.Handle, 0, 0, tmp.Width, tmp.height,
      aBMP.Canvas.Handle, 0, 0, aBMP.Width, aBMP.height, SRCCOPY);
    aBMP.Assign(tmp);;
  finally
    FreeAndNil(tmp);
  end;
end;

//procedure VertTurnBitmap(var aBMP: TBitmap);
//var
//  bmp: TBitmap;
//  X, Y: integer;
//begin
//  bmp := TBitmap.Create;
//  try
//    bmp.Assign(aBMP);
//    for X := 0 to aBMP.Width - 1 do
//      for Y := 0 to aBMP.height - 1 do
//        bmp.Canvas.Pixels[X, Y]:= aBMP.Canvas.Pixels[X, aBMP.height - Y - 1];
//    aBMP.Assign(bmp);
//  finally
//    FreeAndNil(bmp);
//  end;
//end;

//
//procedure VertTurnBitmap(var aBMP: TBitmap);
//var
//  h,w: integer;
//  dest: array of T3b;
//  f3b : P3b;
//begin
//  aBMP.PixelFormat := pf24bit;
//  SetLength(dest,aBMP.Width);
//  for h := 0 to aBMP.height - 1 do
//  begin
//    f3b := aBMP.ScanLine[h];//Получаем строку изображения
//    for w := 0 to aBMP.Width - 1 do
//    begin
////      if(f3b^[0]= Src[0])and(f3b^[1]= Src[1])and(f3b^[2]= Src[2])then
////        System.Move(Dest[0], f3b^[0], SizeOf(T3b));
//      if(w < pred(aBMP.Width))then
//        Inc(f3b);
//    end;
//  end;
//end;

procedure Bmp2Png(aBMP : TBitmap; var aPng : TPngImage; aWidth,aHeight : integer; aTryTrn : boolean = true);
var
 srcBMP : TBitmap;
 backBMP : TBitmap;
 trnColor : TColor;
 pngWidth : integer;
 pngHeight : integer;
 rctBMP : TRect;
begin
if not Assigned(aPng) then Exit;
pngWidth  := aWidth;
pngHeight := aHeight;
srcBMP  :=TBitmap.Create;
backBMP :=TBitmap.Create;
try
with backBMP do
  begin
  Width:=pngWidth;
  Height:=pngHeight;
  end;
srcBMP.Assign(aBMP);
if (srcBMP.Width<>pngWidth) or
   (srcBMP.Height<>pngHeight)
   then ScaleBitmap(srcBMP, Bounds(0,0,pngWidth, pngHeight));
rctBMP:=Bounds((pngWidth - srcBMP.Width) div 2,(pngHeight - srcBMP.Height) div 2,srcBMP.Width, srcBMP.Height);
trnColor:=srcBMP.Canvas.Pixels[0, srcBMP.Height-1];
with backBMP do
  begin
  Canvas.Brush.Color:=trnColor;
  Canvas.FillRect(Bounds(0,0,pngWidth, pngHeight));
  Canvas.Draw(rctBMP.Left, rctBMP.Top, srcBMP);
  end;
aPng.Assign(backBMP);
if aTryTrn
   then aPng.TransparentColor:=trnColor;
finally
backBMP.Free;
srcBMP.Free;
end;
end;


procedure Bmp2Ico(aBMP : TBitmap; var aIcon : TIcon; aSize : integer; aTryTrn : boolean = true);
// -- при такой комбинации фонов маски и базовой картинки иконка получается прозрачной,
// -- но в некоторых вьюверах не отображается (XnView)
const
 maskBase    : TColor = clWhite; // -- если это поменять местами ...
 maskBmpRect : TColor = clBlack; // -- вот с этим, то происходит инверсия цветов BMP
 bmpBase     : TColor = clBlack;
var
    AndMask   : TBitmap;
    XOrMask   : TBitmap;
    IconSizeX : integer;
    IconSizeY : integer;
    II        : TIconInfo;
    rctBMP    : TRect;
    srcBMP    : TBitmap;
    icoWidth  : integer;
    icoHeight : integer;
    baseColor : TColor;
    trnColor  : TColor;
    cntX      : integer;
    cntY      : integer;
begin
icoWidth  := aSize;
icoHeight := aSize;
srcBMP:=TBitmap.Create;
AndMask := TBitmap.Create;
XOrMask := TBitmap.Create;
try
 srcBMP.Assign(aBMP);
 if (srcBMP.Width>icoWidth) or
    (srcBMP.Height>icoHeight)
    then ScaleBitmap(srcBMP, Bounds(0,0,icoWidth, icoHeight));
 rctBMP:=Bounds((icoWidth - srcBMP.Width) div 2,(icoHeight - srcBMP.Height) div 2,srcBMP.Width, srcBMP.Height);
 IconSizeX := icoWidth;
 IconSizeY := icoHeight;
 AndMask.Monochrome := True;
 AndMask.Width := IconSizeX;
 AndMask.Height := IconSizeY;
 AndMask.Canvas.Brush.Color := maskBase;
 AndMask.Canvas.FillRect(Rect(0, 0, IconSizeX, IconSizeY));
 if not aTryTrn
    then begin
    AndMask.Canvas.Brush.Color := maskBmpRect;
    AndMask.Canvas.FillRect(rctBMP);
    end
    else begin
    trnColor:=srcBMP.Canvas.Pixels[0,srcBMP.Height-1];
    for cntX:=0 to srcBmp.Width-1
      do for cntY:=0 to srcBMP.Height-1
         do if srcBMP.Canvas.Pixels[cntX,cntY]<>trnColor
              then AndMask.Canvas.Pixels[cntX+rctBMP.Left,cntY+rctBMP.Top]:=maskBmpRect;
    end;
 XOrMask.Monochrome:=false;
 XOrMask.Width := IconSizeX;
 XOrMask.Height := IconSizeY;
 baseColor:=bmpBase;
 XOrMask.Canvas.Brush.Color:=baseColor;
 XOrMask.Canvas.Brush.Color:=baseColor;
 XOrMask.Canvas.FillRect(Rect(0, 0, IconSizeX, IconSizeY));
 XORMask.Transparent:=True;
 // ChangeColor(srcBMP,baseColor, clFuchsia); // инвертированный цвет (для clFuchsia это clLime) будет отображаться в контрольной BMP (GetIco.DPR)
 XORMask.Canvas.Draw(rctBMP.Left,rctBMP.Top,srcBMP);
 II.fIcon := true;
 II.xHotspot := 0;
 II.yHotspot := 0;
 II.hbmMask := AndMask.Handle;
 II.hbmColor := XOrMask.Handle;
 aIcon.Handle := CreateIconIndirect(II);
finally
AndMask.Free;
XOrMask.Free;
srcBMP.Free;
end;
end;

function GetFileIcon(const aFileName : string; aIcon : TIcon; aSize : integer = 32): boolean;
var
 FileExt : string;
 NumIco  : word;
 bmp     : TBitmap;
begin
Result:=false;
try
if not Assigned(aIcon)
   then Exit;
FileExt:=UpperCase(ExtractFileExt(aFileName));
aIcon.Transparent := true;
if(FileExt = '.EXE')or(FileExt = '.ICO')or(FileExt = '.DLL')
  then begin
  aIcon.Handle := ExtractIcon(HInstance, PChar(aFileName), 0);
  if aIcon.Handle = 0//-- для DLL актуально
    then begin
    NumIco:=0;
    aIcon.Handle := ExtractAssociatedIcon(HInstance, PChar(aFileName), NumIco);
    end;
  end
  else
if GetPictureType(aFileName)<>ptNotImage
  then begin
  bmp:=TBitmap.Create;
  try
  LoadImageFromURLIntoBitmap(aFileName,bmp);
  ScaleBitmap(bmp, Bounds(0,0,aSize, aSize));
  aIcon.Transparent:=true;
  Bmp2Ico(bmp, aIcon, aSize);
  finally
  bmp.Free;
  end;
  end
  else GetAssociatedIcon(aFileName,aIcon);
Result:=true;
except
 on E  : Exception do ;//LogMessageError('GetFileIcon'
end;
end;

procedure GetBmp16FromFileIcon(const aFileName:string;var aBMP: TBitmap; aTrnColor: TColor);
var
  //NumIco: Word;
  //FileExt:string;
  Icon: TIcon;
  bmp: TBitmap;
  SysMenuClr: DWORD;
  MenuColor: TColor;
  //II : IconInfo;
begin
  //SetStretchBltMode : STRETCH_DELETESCANS or HALFTONE
  SysMenuClr := GetSysColor(COLOR_MENU);
  if SysMenuClr = DWORD(Graphics.ColorToRGB(clMenu))then
    MenuColor := clMenu
  else
    MenuColor := clBtnFace;//clMenuBar;
  if not Assigned(aBMP)then
    aBMP := TBitmap.Create;
  with aBMP do
  begin
    Width := 16;
    height := 16;
    Transparent := true;
    TransparentColor := MenuColor;
    Canvas.Brush.Color := aTrnColor;
    Canvas.FillRect(Bounds(0, 0, Width, height));
    SetStretchBltMode(Canvas.Handle, HALFTONE);
  end;
  Icon := TIcon.Create;
  bmp := TBitmap.Create;
  try
  if not GetFileIcon(aFileName, Icon)
     then ;
    with bmp do
    begin
      height := Icon.height;
      Width := Icon.Width;
      Transparent := true;
      TransparentColor := MenuColor;
      Canvas.Brush.Color := MenuColor;
      Canvas.FillRect(Bounds(0, 0, Width, height));
      SetStretchBltMode(Canvas.Handle, HALFTONE);
    end;
    DrawIcon(bmp.Canvas.Handle, 0, 0, Icon.Handle);
    aBMP.Canvas.StretchDraw(Bounds(0, 0, 16, 16), bmp);
    //CopyBitmapToClipBoard(aBMP);
  finally
    FreeAndNil(Icon);
    FreeAndNil(bmp);
  end;
end;


function GetObjectInfo(aObject: TObject):string;
begin
  Result := 'Unassigned';
  if not Assigned(aObject)then
    Exit;
  Result := aObject.ClassName;
  if aObject.InheritsFrom(TComponent)then
    Result := Result + '.' + TComponent(aObject).Name;
end;

function IsTComponent(aPointer: Pointer): boolean;
  function CheckSub(aParent: TObject): boolean;
  var
    cnt: integer;
    cmp: TComponent;
    ctr: TWinControl;
  begin
    Result := false;
    if aParent.InheritsFrom(TComponent)and
      ((aParent as TComponent).ComponentCount > 0)then
    begin
      cmp :=(aParent as TComponent);
      for cnt := 0 to cmp.ComponentCount - 1 do
      begin
        if Pointer(cmp.Components[cnt])= aPointer then
          Result := true;
        if not Result then
          Result := CheckSub(TObject(cmp.Components[cnt]));
        if Result then
          Exit;
      end
    end
    else if aParent.InheritsFrom(TWinControl)and
      ((aParent as TWinControl).ControlCount > 0)then
    begin
      ctr := aParent as TWinControl;
      for cnt := 0 to ctr.ControlCount - 1 do
      begin
        if Pointer(ctr.Controls[cnt])= aPointer then
          Result := true;
        if not Result then
          Result := CheckSub(TObject(ctr.Controls[cnt]));
        if Result then
          Exit;
      end;
    end;
  end;

var
  cnt: integer;
begin
  for cnt := 0 to Application.ComponentCount - 1 do
  begin
    Result := Pointer(Application.Components[cnt])= aPointer;
    if not Result then
      Result := CheckSub(Application.Components[cnt]);
    if Result then
      Exit;
  end;
  Result := false;
end;

procedure GetProps(aObj: TObject;var aStrl: TStringList);
var
  PropList: PPropList;
  i: integer;
begin
  try
    aStrl.Add(GetObjectInfo(aObj));
    PropList := Allocmem(SizeOf(PropList^));
    i := 0;
    try
      GetPropList(aObj.ClassType.ClassInfo, tkProperties +[tkMethod], PropList);
      while(PropList^[i]<> nil)and(i < High(PropList^))do
      begin
        aStrl.Add(string(PropList^[i].Name)+ ': ' +
          string(PropList^[i].PropType^.Name));
        Inc(i);
      end;
    finally
      FreeMem(PropList);
    end;
  except

  end;
end;

function AboutObject(Sender: TObject): string;
var
 pc    : TWinControl;
 obj   : TObject;
 par   : TComponent;
 pcstr : string;
 cls   : TClass;
begin
Result := '';
try
try
  if not Assigned(Sender)then
    Exit;
  if IsTComponent(Sender)
     then begin
     Result := Sender.UnitName + '.' + Sender.ToString + '.' +  (Sender as TComponent).Name;
     if (Sender is TControl)
        then begin
        pcstr:='';
        pc:=(Sender as TControl).Parent;
        while Assigned(pc) do
          begin
          pcstr:=pc.ClassName+'.'+pc.Name+'; '+pcstr;
          pc:=pc.Parent;
          end;
        if pcstr<>'' then Result:=Result+'. Parent: '+Copy(pcstr,1,Length(pcstr)-2);
        end;
     end
  else
  if Sender.InheritsFrom(TComponent)
     then begin
     obj:=Sender;
     par:=nil;
     while Assigned(obj)
       do begin
       with obj do Result := Format('%s.%s;',[UnitName,ClassName])+Result;
       cls:=obj.ClassParent;
       if (cls<>nil) and (cls.ClassName='TComponent')
          then par:=TComponent(obj.ClassParent)
          else Exit;
       try
       if (not Assigned(par))
       or (Assigned(par) and not (par is TComponent))
       or ((par as TComponent).ComponentCount<0)
          then Exit;
        if ((par as TComponent).ToString<>'')
           then
           else Exit;
       except
       on E : Exception do Exit;
       end;
       if par.ClassType.ClassName<>'' then ;
       if par.InheritsFrom(TObject)
          then obj:=par as TObject
          else Exit;
       end;
     end
  else Result := Sender.UnitName + '.' + Sender.ToString + ':' + IntToStr(cardinal(Sender));
except
on E : Exception
  do begin
  CreateErrorMessage('AboutObject',E,[], pcstr);
  Result:=Result+pcstr;
  end;
end;
finally
if (Length(Result)>0) and (Result[Length(Result)]=';')
   then Result:=Copy(Result,1,Length(Result)-1)
end;
end;


function AOS(Sender: TObject): string;
var
 obj   : TObject;
 pcstr : string;
begin
Result := '';
try
if not Assigned(Sender)then Exit;
if IsTComponent(Sender)
   then Result := Sender.UnitName + '.' + Sender.ToString + '.' +  (Sender as TComponent).Name
   else
   if Sender.InheritsFrom(TComponent)
      then begin
      obj:=Sender;
      with obj do Result := Format('%s.%s;',[UnitName,ClassName])+Result;
      end
      else Result := Sender.UnitName + '.' + Sender.ToString + ':' + IntToStr(cardinal(Sender));
except
on E : Exception
  do begin
  CreateErrorMessage('AboutObject(AOS)',E,[], pcstr);
  Result:=Result+pcstr;
  end;
end;
end;

function FindControl(aBaseControl : TWinControl; const aCtrlname : string; aCtrlHandle : hwnd) : TControl;
var
 cnt : integer;
begin
result:=nil;
for cnt:=0 to aBaseControl.ControlCount-1
  do if (aBaseControl.Controls[cnt].ClassName = aCtrlname) and
        ((aBaseControl.Controls[cnt] is TWinControl) and ((aBaseControl.Controls[cnt] as TWinControl).Handle = aCtrlHandle))
        then begin
        result:=aBaseControl.Controls[cnt];
        Exit;
        end
        else
    if (aBaseControl.Controls[cnt] is TWinControl)
        then begin
        result:=FindControl((aBaseControl.Controls[cnt] as TWinControl), aCtrlName, aCtrlHandle);
        if Assigned(result) then Exit;
        end;
end;


function AboutObjectByHandle(aWnd : hwnd) : string;
var
 cnt  : integer;
 ctrl : TControl;
begin
result:='';
try
if aWnd>0
   then result:=GetWindowClassName(aWnd)
   else Exit;
ctrl:=Controls.FindControl(aWnd);
if Assigned(ctrl)
   then begin
   result:=AboutObject(ctrl);
   Exit;
   end;
for cnt:=0 to Screen.FormCount-1
  do if Application.ActiveFormHandle = Screen.Forms[cnt].Handle
        then ctrl:=FindControl(Screen.Forms[cnt], result, aWnd);
if Assigned(ctrl)
   then result:=AboutObject(ctrl);
if result<>'' then ;
except
on E : Exception do ;//LogErrorMessage('GetAboutByHandle',E,[GetAboutByHandle(Msg.hwnd),Msg.hwnd, Msg.Message]);
end;
end;


function GetOffset(aControl : TControl; var aX,aY : integer) : boolean;
var
 par : TWinControl;
 dlt : integer;
begin
Result:=False;
try
aX:=aControl.Left;
aY:=aControl.Top;
par:=aControl.Parent;
while Assigned(par)
  do begin
  inc(aX,par.Left);
  inc(aY,par.Top);
  if par.InheritsFrom(TForm)
     then begin
     dlt:=((par as TForm).Width - (par as TForm).ClientWidth) div 2;
     inc(aX,dlt);
     inc(aY,(par as TForm).Height - (par as TForm).ClientHeight-dlt);
     end;
  par:=par.Parent;
  end;
Result:=true;
except
end;
end;

//http://www.sql.ru/forum/actualutils.aspx?action=gotomsg&tid=813080&msg=9921273
//autor: http://www.sql.ru/forum/memberinfo.aspx?mid=146704
function GMN(Obj: TObject): string;  // GetMethodName
var
  CallAddr, MethAddr, MaxAddr: Cardinal;
  pb, methEnd: PAnsiChar;
  i, Count: Integer;
begin
Result:='';
try
if not Assigned(Obj) then Exit;
   asm
     mov CallAddr, ebp;
     add CallAddr, 4;
   end;
   MaxAddr := 0;
   CallAddr := PCardinal(CallAddr)^;
   pb := PAnsiChar(Obj.ClassType) + vmtMethodTable;
   pb := PPointer(pb)^;
   if Assigned(pb) then
   begin
     Count := PWord(pb)^;
     inc(pb, SizeOfWord);
     for i := 1 to Count do
     begin
       methEnd := pb + PWord(pb)^; //Len
       Inc(pb, SizeOfWord);
       MethAddr := PCardinal(pb)^; //CodeAddress
       if (MethAddr < CallAddr) and (MethAddr > MaxAddr) then
       begin
         MaxAddr := MethAddr;
         if MaxAddr <= MethAddr then
           Result := Obj.MethodName(Pointer(MethAddr));
       end;
       pb := methEnd;
     end;
   end;
except
  on E : Exception do CreateErrorMessage('GetMethodName',E,[],Result);
end;
end;


function GetFocusedWindow: HWND; (*ATTENTION*) // На отладке по шагам вызывает полное зависание ...
var
CurrThID, ThID: DWORD;
begin
result := GetForegroundWindow;
if result <> 0 then
begin
CurrThID := GetCurrentThreadId;
ThID := GetWindowThreadProcessId(result, // handle to window
nil // process identifier
);
result := 0;
if CurrThID = ThId then
result := GetFocus
else
begin
if AttachThreadInput(CurrThID, ThID, True) then  (*ATTENTION*) // ... вот на этом шаге
begin
result := GetFocus;
AttachThreadInput(CurrThID, ThID, False);
end;
end;
end;
end;



procedure GetPreviousControl(aCurWnd : cardinal);
begin
// -- иногда, когда родитель Inherits(TForm), срабатывает, но на TScrollBox - НЕТ
PostMessage(aCurWnd,WM_NEXTDLGCTL,1,0);// see "Remarks" in https://msdn.microsoft.com/en-us/library/windows/desktop/ms645432(v=vs.85).aspx
end;

procedure GetPreviousControl;
begin
// -- эмулируем нажатие Shift-Tab
keybd_event(VK_SHIFT, 0, 0, 0);
keybd_event(VK_TAB, 0, 0, 0);
keybd_event(VK_TAB, 0, KEYEVENTF_KEYUP, 0);
keybd_event(VK_SHIFT, 0, KEYEVENTF_KEYUP, 0);
end;


procedure GetNextControl(aCurWnd : cardinal);
begin
// -- иногда, когда родитель Inherits(TForm), срабатывает, но на TScrollBox - НЕТ
PostMessage(aCurWnd,WM_NEXTDLGCTL,0,0);// see "Remarks" in https://msdn.microsoft.com/en-us/library/windows/desktop/ms645432(v=vs.85).aspx
end;

procedure GetNextControl;
begin
// -- эмулируем нажатие Tab
keybd_event(VK_TAB, 0, 0, 0);
keybd_event(VK_TAB, 0, KEYEVENTF_KEYUP, 0);
end;






procedure SetEnabledControls(aParent : TWinControl; aEnabled : boolean; const aCtrlForEnabled : array of TControl);
  function InArray(aCtrl : TControl) : boolean;
  var
   cnt : integer;
  begin
  Result:=true;
  for cnt:=0 to High(aCtrlForEnabled) do
    if aCtrlForEnabled[cnt] = aCtrl then Exit;
  Result:=false;
  end;

  function IsContainer(bParent : TControl) : boolean;
  begin
  Result:=bParent.InheritsFrom(TWinControl) and ((bParent as TWinControl).ControlCount>0);
  end;

  procedure BaseSet(bParent : TControl);
  begin
  if InArray(bParent)
     then bParent.Enabled:=aEnabled
     else bParent.Enabled:=not aEnabled;
  end;

  procedure se(bParent : TControl);
  var
   cnt: integer;
  begin
  if IsContainer(bParent)
     then begin
     for cnt:=0 to (bParent as TWinControl).ControlCount-1
         do begin
         if IsContainer((bParent as TWinControl).Controls[cnt])
            then se((bParent as TWinControl).Controls[cnt] as TWinControl)
            else BaseSet((bParent as TWinControl).Controls[cnt]);
         end;
     end
     else BaseSet(bParent);
  end;
begin
se(aParent);
end;


procedure SaveComponentToFile(RootObject: TComponent; const FileName: TFileName);
var
  FileStream: TFileStream;
  MemStream: TMemoryStream;
begin
  FileStream := TFileStream.Create(FileName, fmCreate);
  MemStream := TMemoryStream.Create;
  try
    MemStream.WriteComponent(RootObject);
    MemStream.Position := 0;
    ObjectBinaryToText(MemStream, FileStream);
  finally
    MemStream.Free;
    FileStream.Free;
  end;
end;

procedure LoadComponentFromFile(RootObject: TComponent; const FileName: TFileName);
var
  FileStream: TFileStream;
  MemStream: TMemoryStream;
begin
  FileStream := TFileStream.Create(FileName, 0);
  MemStream := TMemoryStream.Create;
  try
    ObjectTextToBinary(FileStream, MemStream);
    MemStream.Position := 0;
    MemStream.ReadComponent(RootObject);
  finally
    MemStream.Free;
    FileStream.Free;
  end;
end;


// http://robstechcorner.blogspot.ru/2009/09/delphi-2010-rtti-basics.html

function GetMethodsAndProperiesOfClassFast(aClassInfo : pointer; var aMethods : TList<TRTTIMethod>; var aProperties : TList<TRttiProperty>) : boolean;
const
 MembVisNote: array[TMemberVisibility] of string = ('Private', 'Protected', 'Public', 'Published');
var
  RttiContext : TRttiContext;
  RttiType    : TRttiType;
begin
Result      := false;
RttiContext := TRttiContext.Create;
try
  RttiType := RttiContext.GetType(aClassInfo);
  if Assigned(RttiType)
     then begin
     aMethods     := TList<TRTTIMethod>.Create;
     aProperties  := TList<TRttiProperty>.Create;
     aMethods.AddRange(RttiType.GetMethods);
     aProperties.AddRange(RttiType.GetProperties);
     Result:=true;
     end;
finally
  RttiContext.Free;
end;
end;


function GetMethodsAndProperiesOfClass(aClassInfo : pointer; var aMethods : TList<TRTTIMethod>; var aProperties : TList<TRttiProperty>) : string;
const
 MembVisNote: array[TMemberVisibility] of string = ('Private', 'Protected', 'Public', 'Published');
var
  RttiContext : TRttiContext;
  RttiType : TRttiType;
  RttiMethod : TRttiMethod;
  RttiProperty : TRttiProperty;
begin
Result      := '';
RttiContext := TRttiContext.Create;
try
  RttiType := RttiContext.GetType(aClassInfo);  // Можно через String (t := c.FindType(aClassName)); НО!!! обязательно в формате [ModuleName.ClassName]
  if Assigned(RttiType)
     then begin
     aMethods     := TList<TRTTIMethod>.Create;
     aProperties  := TList<TRttiProperty>.Create;
     Result:=Result+Replicate('~',10)+' Methods '+Replicate('~',20)+crlf+crlf;
     for RttiMethod in RttiType.GetMethods
        do begin
        aMethods.Add(RttiMethod);
        Result:=Result+RttiMethod.ToString+Format(' (%s.%s)',[TRTTIMember(RttiMethod).Parent.ToString,MembVisNote[RttiMethod.Visibility]])+crlf;
        end;
     Result:=Result+crlf+Replicate('~',10)+' Properties '+Replicate('~',20)+crlf+crlf;
     for RttiProperty in RttiType.GetProperties
       do if (integer(RttiProperty.Visibility)=3)
             then begin
             aProperties.Add(RttiProperty);
             Result:=Result+RttiProperty.ToString+Format(' (%s.%s)',[TRTTIMember(RttiProperty).Parent.ToString,MembVisNote[RttiProperty.Visibility]])+crlf;
             end;
     end;
finally
  RttiContext.Free;
end;
end;

function GetPropertiesForClass(aClassInfo : pointer; const aClassName : string; aProps : TList<TRttiProperty>) : string;
var
  rttiContext  : TRttiContext;
  rttiType     : TRttiType;
  rttiProperty : TRttiProperty;
begin
Result:='';
if not Assigned(aProps) then Exit;
rttiContext := TRttiContext.Create;
try
  rttiType := rttiContext.GetType(aClassInfo);
  if Assigned(rttiType)
     then begin
     for rttiProperty in rttiType.GetProperties
         do if (aClassName='') // -- смотрим все
            or (TRTTIMember(rttiProperty).Parent.Name = aClassName)
            then begin
            Result := Result + rttiProperty.ToString + ' ('+TRTTIMember(rttiProperty).Parent.Name+')'+crlf;
            aProps.Add(rttiProperty);
            end;
     end
finally
rttiContext.Free;
end;
end;

function GetDopPropertiesForClass(aClassInfo : pointer; var aProps : TRTTIDopInfoList; const aClassName: string = ''): integer;
var
  rttiContext  : TRttiContext;
  rttiType     : TRttiType;
  rttiProperty : TRttiProperty;
  className    : string;
  //str : string;
begin
//str:='';
Result:=0;
rttiContext := TRttiContext.Create;
try
  rttiType := rttiContext.GetType(aClassInfo);
  if Assigned(rttiType)
     then begin
     for rttiProperty in rttiType.GetProperties
         do begin
         try className:=rttiProperty.Parent.Name except className:='*'; end;
         if (className=aClassName) or (className='')
            then begin
            Result:=Length(aProps);
            SetLength(aProps, Result+1);
            try aProps[Result].RealName:=AnsiString(rttiProperty.Name) except end;
            try aProps[Result].Visibility:=rttiProperty.Visibility except end;
            try aProps[Result].UnitName:=AnsiString(rttiProperty.ClassParent.UnitName) except end;
            aProps[Result].ParentClassName:=AnsiString(className)
            end;
         end;
     end
finally
rttiContext.Free;
end;
//if str<>'' then ShowMessageWarning(str);
end;

function GetPropertiesForClassFast(aClassInfo : pointer; const aClassName : string; aProps : TList<TRttiProperty>) : boolean;
var
  rttiContext  : TRttiContext;
  rttiType     : TRttiType;
begin
Result:=false;
if not Assigned(aProps) then Exit;
rttiContext := TRttiContext.Create;
try
  rttiType := rttiContext.GetType(aClassInfo);
  if Assigned(rttiType)
     then begin
     aProps.AddRange(rttiType.GetProperties);
     Result:=true;
//     for rttiProperty in rttiType.GetProperties
//         do if (aClassName='') // -- смотрим все
//            or (TRTTIMember(rttiProperty).Parent.Name = aClassName)
//            then begin
//            Result := Result + rttiProperty.ToString + ' ('+TRTTIMember(rttiProperty).Parent.Name+')'+crlf;
//            aProps.Add(rttiProperty);
//            end;
     end;
finally
rttiContext.Free;
end;
end;


(*Получение описания ошибки по коду ----------------------------------------*)
// а также http://rguitp-pi.narod.ru/program/codeserrors.htm (там есть, например, ошибка 3024)
function GetErrorString(const aErrorCode: integer = MAX_INTEGER):string;
var
  ErrorCode: integer;
begin
  if aErrorCode = MAX_INTEGER
     then ErrorCode := GetLastError
     else ErrorCode := aErrorCode;
  Result := 'Код ошибки ОС : ' + IntToStr(ErrorCode)+ ' (' + SysErrorMessage(ErrorCode)+ ')';
// -- преобразователь
//tmp:=StringReplace(GetErrorString(ErrorCode),Format('Код ошибки ОС : %d',[ErrorCode]),'',[]);
//if tmp<>' ()' then tmp:=StringReplace(tmp,crlf,'',[]);
end;

(*Запрос кода и описания ошибки WinSocket*)
function GetWSAErrorString(err: integer  = - 1):string;
var
  ErrorCode: integer;
begin
if err=-1
   then ErrorCode := WSAGetLastError
   else ErrorCode := err;
  Result := 'Код ошибки : ' + IntToStr(ErrorCode)+ ' (' +
    SysErrorMessage(ErrorCode)+ ')';
end;

function CheckUsePort(port : word) : integer;
  procedure SetBlocking(sock : cardinal; isblocking : boolean);
  var
    temp : longint;
  begin
  temp:=longint(not IsBlocking);
  ioctlsocket(sock,fionbio,temp);
  end;
var
 WSAData    : TWSAData;
 socket     : TSocket;  // -- указатель на серверный сокет
 SockAddrIn : TSockAddrIn;
 temp       : longint;
begin
Result:=-1;
if WSAStartUp(257, WSAData)<>0 then Exit;
try
temp:=0;
socket := WinSock.socket(pf_inet, sock_stream, getprotobyname('tcp').p_proto);
SetBlocking(socket, false);
setsockopt(socket, ipproto_tcp, so_reuseaddr, @temp, sizeof(temp));
if socket <> socket_error
   then begin
   fillchar(SockAddrIn, sizeof(TSockAddrIn), 0);
   with SockAddrIn
      do begin
      sin_family := af_inet;
      sin_addr.s_addr := inaddr_any;
      sin_port := htons(port);
      fillchar(sin_zero, sizeof(sin_zero), 0);
      end;
   {$R-}
   result:=bind(socket, SockAddrIn, sizeof(TSockAddrIn));
   {$R+}
   if result<>0
      then result:=WSAGetLastError// LogWarningMessage(Format('CheckPort: Cannot bind port [%d]',[port]),nil,[])
      else closesocket(socket);
   end
   else ;//LogErrorMessage(Format('CheckPort: Cannot create socket for port [%d]',[port]),nil,[]);
finally
WSACleanup;
end;
end;

function NameToIPv4(const NetworkName:String):String;
var
  HostEntry: PHostEnt;
  Data: WSAData;
  Address: In_Addr;
  erc: cardinal;
begin
  erc := 0;
  try
    try
      if WSAStartup(MakeWord(1, 1), Data)= 0 then
      begin
        HostEntry := gethostbyname(PAnsiChar(AnsiString(NetworkName)));
        erc := GetLastError;
        if erc = 0 then
        begin
          Address := PInAddr(HostEntry^.h_addr_list^)^;
          Result := string(inet_ntoa(Address));
        end
        else
          Result := '0.0.0.0';
      end
      else
        Result := GetErrorString(erc);
    finally
      WSACleanup;
    end;
  except
    on E: Exception do
      CreateErrorMessage('NameToIPv4(GetIPAddress)', E,[NetworkName], true);
  end;
end;

function NameToIPv4(const NetworkName:String; var aIPorError : string):boolean; overload;
var
  HostEntry: PHostEnt;
  Data: WSAData;
  Address: In_Addr;
  erc: cardinal;
begin
Result:=false;
  erc := 0;
  try
    try
      if WSAStartup(MakeWord(1, 1), Data)= 0 then
      begin
        HostEntry := gethostbyname(PAnsiChar(AnsiString(NetworkName)));
        erc := GetLastError;
        if erc = 0 then
        begin
          Address := PInAddr(HostEntry^.h_addr_list^)^;
          aIPorError := string(inet_ntoa(Address));
          Result:=true;
        end
        else
          aIPorError := '0.0.0.0';
      end
      else
        aIPorError := GetErrorString(erc);
    finally
      WSACleanup;
    end;
  except
    on E: Exception do CreateErrorMessage('NameToIPv4(GetIPAddress)', E,[NetworkName], aIPorError);
  end;
end;

function IPv4ToName(const IPAddr:string):string;
var
  SockAddrIn: TSockAddrIn;
  HostEnt: PHostEnt;
  WSAData: TWSAData;
begin
  try
    WSAStartup(MakeWord(1, 1), WSAData);
    try
      SockAddrIn.sin_addr.s_addr := inet_addr(PAnsiChar(AnsiString(IPAddr)));
      HostEnt := gethostbyaddr(@SockAddrIn.sin_addr.s_addr, 4, AF_INET);
      if HostEnt <> nil then
        Result := string(StrPas(HostEnt^.h_name))
      else
        Result := '';
    finally
      WSACleanup;
    end;
  except
    on E: Exception do
      CreateErrorMessage('IPv4ToName(IPAddrToName)', E,[IPAddr], true);
  end;
end;

(* PING адреса возвращает время отклика в мс или pingErrorCode(0>)            *)
{$R-}
{INETADR} function d_addr(const aIPaddr : string) : integer;
{INETADR}     var
{INETADR}     pa  : PAnsiChar;
{INETADR}     sa  : TInAddr;
{INETADR}     Host: PHostEnt;
{INETADR}     str : string;
{INETADR} begin
{INETADR} Result:=inet_addr(PAnsiChar(ansistring(aIPaddr)));
{INETADR} if Result>0//=INADDR_NONE
{INETADR}    then begin
{INETADR}    host:=GetHostByName(PAnsiChar(ansistring(aIPaddr)));
{INETADR}    if Host = nil
{INETADR}       then exit
{INETADR}       else  begin
{INETADR}       // Преобразование
{INETADR}       pa := Host^.h_addr_list^;
{INETADR}       sa.S_un_b.s_b1 := pa[0];
{INETADR}       sa.S_un_b.s_b2 := pa[1];
{INETADR}       sa.S_un_b.s_b3 := pa[2];
{INETADR}       sa.S_un_b.s_b4 := pa[3];
{INETADR}       str:=IntToStr(Ord(sa.S_un_b.s_b1))+'.'+IntToStr(Ord(sa.S_un_b.s_b2))+'.'+IntToStr(Ord(sa.S_un_b.s_b3))+'.'+IntToStr(Ord(sa.S_un_b.s_b4));
{INETADR}       Result:=inet_addr(PAnsiChar(ansistring(str)));
{INETADR}       end;
{INETADR}    end;
{INETADR} end;
{$R+}

function IsIPv4(const aIPorName  :string)  :boolean;
var
 sda : TStringDynArray;
 cnt : integer;
 prt : integer;
begin
Result:=false;
sda:=SplitString(aIporname,'.');
if Length(sda)<>4 then Exit;
for cnt:=0 to High(sda)
  do begin
  prt:=-1;
  if CheckValidInteger(sda[cnt])
     then prt:=StrToInt(sda[cnt])
     else
  if CheckValidHex(sda[cnt])
     then prt:=StrToInt('$'+StringReplace(sda[cnt],'$','',[rfReplaceAll]));
  if (prt<0) or (prt>255) then Exit;
  end;
Result:=true;
end;

function Ping(const aIPAddr : string; out log : string; SizeOfBuffer : cardinal = 32;pngInterval: cardinal = 1000):integer;
var
 hIP               : THandle;
 pingBuffer        : array of Char;
 pIpe              : Picmp_echo_reply;
 wVersionRequested : WORD;
 lwsaData          : TWSAData;
 error             : DWORD;
 destAddress       : In_Addr;
// domname           : string;
 //resIPa            : string;
 //resIPb            : string;
 IPaddr            : string;
begin
IPaddr:=aIPaddr;
//domname:=GetUserNameEx(NameDnsDomain);
//if domname<>'' then ;
IPaddr:=NameToIPv4(aIPAddr);
if not IsIPv4(IPaddr)
   then IPaddr:=IPv4ToName(aIPAddr);

if SizeOfBuffer<=0 then SizeOfBuffer:=32;
SetLength(pingBuffer,SizeOfBuffer);
//FillChar(pingBuffer,SizeOf(pingBuffer),Chr(255));
hIP := IcmpCreateFile();
GetMem( pIpe,sizeof(Ticmp_echo_reply) + sizeof(pingBuffer));
pIpe.Data := @pingBuffer;
pIpe.DataSize :=Length(pingBuffer);
wVersionRequested := MakeWord(1,1);
error := WSAStartup(wVersionRequested,lwsaData);
try
try
if error<>0
   then begin
   Result:=pingErrorWSA;
   log:='Error in call to WSAStartup(). Error code: '+IntToStr(error)+'. ';
   Exit;
   end;
destAddress.S_addr :=d_addr(IPaddr);
if CharInSet(IPaddr[1], ['0'..'9'])
  then log:=log+'Посылка на '+IPAddr+' ['+ IPv4ToName(IPAddr)+'] '+' буфер размером (байт) '+IntToStr(Length(pingBuffer))+'. '
  else log:=log+'Посылка на '+IPAddr+' ['+ string(StrPas(inet_ntoa(destAddress)))+'] '+' буфер размером (байт) '+IntToStr(Length(pingBuffer))+'. ';
IcmpSendEcho(hIP,
             destAddress.S_addr,
             @pingBuffer,
             sizeof(pingBuffer),
             Nil,
             pIpe,
             sizeof(Ticmp_echo_reply) + sizeof(pingBuffer),
             pngInterval);
error := GetLastError();
if (error <> 0)
  then begin
  Result:=pingErrorSendEcho;
  case error of
  IP_REQ_TIMED_OUT :  begin
                      log:=log+'Превышено время ожидания отклика...';
                      Result:=pingErrorTimeOut;
                      end;
  else log:=log+'Error in call to IcmpSendEcho(). Error code: '+IntToStr(error)+'. ';
  end;
  Exit;
  end;
log:=log+'Отклик от : '+IntToStr(LoByte(LoWord(pIpe^.Address)))+'.'+
                        IntToStr(HiByte(LoWord(pIpe^.Address)))+'.'+
                        IntToStr(LoByte(HiWord(pIpe^.Address)))+'.'+
                        IntToStr(HiByte(HiWord(pIpe^.Address)))+'. ';
log:=log+'Время отклика: '+IntToStr(pIpe.RTTime)+' мс'+'. ';
Result:=pIpe.RTTime;
except
on E : Exception
  do begin
  log:=GetErrorString(GetLastError)+cr+E.Message;
  Result:=pingError;
  Exit;
  end;
end;
//end;
finally
IcmpCloseHandle(hIP);
WSACleanup();
FreeMem(pIpe);
end;
//SetLength(pingBuffer,0);
end;


function AdapterToString(Adapter: TAdapterStatus): string;
begin
  with Adapter do Result :=
      Format('%2.2x-%2.2x-%2.2x-%2.2x-%2.2x-%2.2x',
      [Integer(adapter_address[0]), Integer(adapter_address[1]),
      Integer(adapter_address[2]), Integer(adapter_address[3]),
      Integer(adapter_address[4]), Integer(adapter_address[5])]);
end;{function}

function GetMacAddresses(const Machine: string; const Addresses: TStrings): Integer;
const
 NCBNAMSZ    =  16;    // absolute length of a net name
 MAX_LANA    = 254;    // lana's in range 0 to MAX_LANA inclusive
 NRC_GOODRET = $00;    // good return
 NCBASTAT    = $33;    // NCB ADAPTER STATUS
 NCBRESET    = $32;    // NCB RESET
 NCBENUM     = $37;    // NCB ENUMERATE LANA NUMBERS
type
  PNCB = ^TNCB;
  TNCBPostProc = procedure(P: PNCB); stdcall;
  TNCB = record
    ncb_command: Byte;
    ncb_retcode: Byte;
    ncb_lsn: Byte;
    ncb_num: Byte;
    ncb_buffer: PChar;
    ncb_length: Word;
    ncb_callname: array [0..NCBNAMSZ - 1] of char;
    ncb_name: array [0..NCBNAMSZ - 1] of char;
    ncb_rto: Byte;
    ncb_sto: Byte;
    ncb_post: TNCBPostProc;
    ncb_lana_num: Byte;
    ncb_cmd_cplt: Byte;
    ncb_reserve: array [0..9] of char;
    ncb_event: THandle;
  end;
  PLanaEnum = ^TLanaEnum;
  TLanaEnum = record
    Length: Byte;
    lana: array [0..MAX_LANA] of Byte;
  end;
  ASTAT = record
    adapt: TAdapterStatus;
    namebuf: array [0..29] of TNameBuffer;
  end;
var
  NCB        : TNCB;
  Enum       : TLanaEnum;
  I          : integer;
  Adapter    : ASTAT;
  MachineName: string;
begin
  Result := -1;
  Addresses.Clear;
  MachineName := AnsiUpperCase(Machine);
  if MachineName = '' then MachineName := '*';
  FillChar(NCB, SizeOf(NCB), #0);
  NCB.ncb_command := NCBENUM;
  NCB.ncb_buffer  := Pointer(@Enum);
  NCB.ncb_length  := SizeOf(Enum);
  if Word(NetBios(@NCB)) = NRC_GOODRET then
  begin
    Result := Enum.Length;
    for I := 0 to Ord(Enum.Length) - 1 do
    begin
      FillChar(NCB, SizeOf(TNCB), #0);
      NCB.ncb_command  := NCBRESET;
      NCB.ncb_lana_num := Enum.lana[I];
      if Word(NetBios(@NCB)) = NRC_GOODRET then
      begin
        FillChar(NCB, SizeOf(TNCB), #0);
        NCB.ncb_command  := NCBASTAT;
        NCB.ncb_lana_num := Enum.lana[i];
        StrLCopy(NCB.ncb_callname, PChar(MachineName), NCBNAMSZ);
        StrPCopy(@NCB.ncb_callname[Length(MachineName)],
          StringOfChar(' ', NCBNAMSZ - Length(MachineName)));
        NCB.ncb_buffer := PChar(@Adapter);
        NCB.ncb_length := SizeOf(Adapter);
        if Word(NetBios(@NCB)) = NRC_GOODRET
           then Addresses.Add(AdapterToString(Adapter.adapt));
        NCB.ncb_buffer:=nil;
        FillChar(Adapter.adapt,30,#0);
        end;
    end;
  end;
end;{function}


procedure FillUsedPorts(var ports : TIntegerDynArray);
var
 cmd : string;
 res : string;
 src : string;
 strl : TStringList;
// sda : TStringDynArray;
 cnt : integer;
begin
SetLength(ports,0);
res := SetTailBackSlash(GetTempFolder)+'ports.txt';
cmd := SetTailBackSlash(GetTempFolder)+'ports.cmd';
DeleteFile(PChar(res));
DeleteFile(PChar(cmd));
src:='chcp 1251'+crlf+'netstat -an > "'+res+'"';
SaveStringIntoFile(src,cmd);
RunCMD('cmd /C"'+cmd+'"');
DeleteFile(PChar(cmd));
if not FileExists(res) then Exit;
strl:=TStringList.Create;
try
strl.LoadFromFile(res);
for cnt:=4 to strl.Count-1
  do begin
  //SlimFastEx(strl[cnt],' ',src);
  //SplitString(Trim(src),' ') :
  // 0 протокол
  // 1 локальное IPAddress:port
  // 2 внешнеее IPAddress:port
  // 3 состояние
  // 4 (возможное при -aon) PID процесса, который пользует это подключение
  src:=SplitString(Trim(SplitString(Trim(SlimFastEx(strl[cnt],' ')),' ')[1]),':')[1];
  AddToIntDynArray(StrToIntDef(src,0),ports);
  end;
//ShowMessageInfo(strl.Text);
finally
strl.Free;
end;
end;



function GetConnections(asHtml : boolean; const HighLightPorts : array of integer) : string;
   function HighlightStr(str : string) : boolean;
   var
    cnt : integer;
   begin
   Result:=true;
   for cnt:=0 to High(HighLightPorts)
     do if Pos(Format(':%d'#160#160,[HighLightPorts[cnt]]),str)<>0
           then Exit;
   Result:=false;
   end;

const
head : string =
 '<!DOCTYPE html>'+
 '<html xmlns="http://www.w3.org/1999/xhtml" xmlns:vml="urn:schemas-microsoft-com:vml">'+
 '<head>'+
 '<title>Список подключений</title>'+
 '<meta http-equiv="Content-Type" content="text/html; charset=windows-1251"/>'+
 '</head>'+
 '<body>'+
 '<table border="1" bordercolor="#404040" style="font-size: 75%">';
 oneCell = '<td>'#160#160'%s'#160#160'</td>';

var
 cmd : string;
 res : string;
 src : string;
 strl: TStringList;
 sda : TStringDynArray;
 cnt : integer;
 hl_in   : boolean;
 hl_out  : boolean;
 pid : cardinal;
 self : cardinal;
begin
Result:='';
self:=GetCurrentProcessId;
res := SetTailBackSlash(GetTempFolder)+'ports.txt';
cmd := SetTailBackSlash(GetTempFolder)+'ports.cmd';
DeleteFile(PChar(res));
DeleteFile(PChar(cmd));
src:='chcp 1251'+crlf+'netstat -aon | more > "'+res+'"';
SaveStringIntoFile(src,cmd);
RunCMD('cmd /C"'+cmd+'"');
DeleteFile(PChar(cmd));
if not FileExists(res) then Exit;
if not asHtml
   then Result:=LoadStringFromURL(res)
   else begin
   Result:=head;
    strl:=TStringList.Create;
    try
    strl.LoadFromFile(res);
    for cnt:=2 to strl.Count-1
      do begin
      pid:=0;
      hl_in:=false;
      hl_out:=false;
      src:=Trim(SlimFastEx(strl[cnt],' '));
      if (cnt<4) and (AnsiPos(' адрес',src)>0)
         then src:=StringReplace(src,' адрес',#160'адрес',[rfReplaceAll]);
      sda:=SplitString(src,' ');
      src:='';
      if High(sda)>=0
         then src:=src+Format(oneCell,[sda[0]]);
      if High(sda)>=1
         then begin
         src:=src+Format(oneCell,[sda[1]]);
         hl_in:=HighlightStr(sda[1]+#160#160);
         end;
      if High(sda)>=2
         then begin
         src:=src+Format(oneCell,[sda[2]]);
         hl_out:=HighlightStr(sda[2]+#160#160);
         end;
      if High(sda)>=3
         then src:=src+Format(oneCell,[sda[3]]);
      if High(sda)>=4
         then begin
         pid:=StrToIntDef(trim(sda[4]),0);
         src:=src+Format(oneCell,[sda[4]]);
         end;

      if hl_in
         then begin
         if self=pid
            then Result:=Result+Format('<tr bgcolor="#CCFFCC">%s</tr>',[src])
            else Result:=Result+Format('<tr bgcolor="#FFCCCC">%s</tr>',[src]) ;
         end
         else
      if hl_out
         then Result:=Result+Format('<tr bgcolor="#FFFFCC">%s</tr>',[src])
         else Result:=Result+Format('<tr>%s</tr>',[src]);

  end;
  finally
  strl.Free;
  end;
  Result:=Result+'</table></body></html>'
  end;
end;


function GetPortPID(port : integer) : cardinal;
var
 cmd : string;
 res : string;
 src : string;
 strl: TStringList;
 sda : TStringDynArray;
 cnt : integer;
 tst : string;
begin
Result:=0;
res := SetTailBackSlash(GetTempFolder)+'ports.txt';
cmd := SetTailBackSlash(GetTempFolder)+'ports.cmd';
DeleteFile(PChar(res));
DeleteFile(PChar(cmd));
src:='chcp 1251'+crlf+'netstat -aon | more > "'+res+'"';
SaveStringIntoFile(src,cmd);
RunCMD('cmd /C"'+cmd+'"');
DeleteFile(PChar(cmd));
if not FileExists(res) then Exit;
tst:=':'+IntToStr(port)+DaggerChar;
strl:=TStringList.Create;
try
strl.LoadFromFile(res);
for cnt:=2 to strl.Count-1
  do begin
  src:=Trim(SlimFastEx(strl[cnt],' '));
  if (cnt<4) and (AnsiPos(' адрес',src)>0)
     then src:=StringReplace(src,' адрес',#160'адрес',[rfReplaceAll]);
  sda:=SplitString(src,' ');
  src:='';
  if High(sda)<=0 then Continue;
  if Trim(sda[0])<>'TCP' then Continue;
  if High(sda)<=1 then Continue;
  if Pos(tst,Trim(sda[1])+DaggerChar)<>0
     then begin
     if (High(sda)>=4) and CheckValidInteger(sda[4])
        then Result:=StrToInt(sda[4])
        else Result:=MAX_CARDINAL;
     Break;
     end ;
  end;
finally
strl.Free;
end;
end;


procedure CreateErrorMessage(const aProcName:string; E: Exception; aParams: array of const;var aResult:string);
const
  FmtShablon:string = '"%s" : %s. %s.';
var
  errcode: cardinal;
  errmsg:string;
  cnt: integer;
  ParamStr:string;
begin
  errcode := GetLastError;
  errmsg := GetErrorString(errcode);
  try
  if Assigned(E)
    then errmsg := Format(FmtShablon,[aProcName, E.Message, errmsg])
    else errmsg := Format(FmtShablon,[aProcName, '(Exception is NIL)', errmsg]);
    ParamStr := '';
    for cnt := 0 to High(aParams)do
      ParamStr := ParamStr + GDV(aParams[cnt])+ '; ';
    if Length(ParamStr)> 0 then
    begin
      SetLength(ParamStr, Length(ParamStr)- 1);
      errmsg := errmsg + ' : [' + ParamStr + ']';
    end;
    aResult := errmsg
  finally
    errmsg := '';
  end;
end;

procedure CreateErrorMessage(const aProcName:string; E: Exception; aParams: array of const; aNeedShowError: boolean);
var
  ResStr:string;
begin
  CreateErrorMessage(aProcName, E, aParams, ResStr);
  if aNeedShowError then
    ShowMessageError(ResStr, 'Сообщение об ошибке [' + Application.Title + ']');
end;

function CreateErrorMessage(const aProcName:string; E: Exception; aParams: array of const) : string;
begin
  CreateErrorMessage(aProcName, E, aParams, Result);
end;

(*Получение папки для временного хранения файлов ---------------------------*)
function GetTempFolder:String;
var
  tempFolder: array[0 .. MAX_PATH_EX]of char;
begin
  GetTempPath(MAX_PATH,@tempFolder);
  Result := Trim(StrPas(tempFolder));
end;

function GetDocFolder:string;
Var
  SFolder: PItemIDList;
  SpecialPath: Array[0 .. MAX_PATH_EX]Of char;
begin
  FillChar(SpecialPath, Length(SpecialPath), #0);
  SHGetSpecialFolderLocation(HInstance, CSIDL_PERSONAL, SFolder);
  SHGetPathFromIDList(SFolder, SpecialPath);
  Result := Trim(string(SpecialPath));
end;

function GetCommonDocFolder:string;
Var
  SFolder: PItemIDList;
  SpecialPath: Array[0 .. MAX_PATH_EX]Of char;
begin
  FillChar(SpecialPath, Length(SpecialPath), #0);
  SHGetSpecialFolderLocation(HInstance, CSIDL_COMMON_DOCUMENTS, SFolder);
  SHGetPathFromIDList(SFolder, SpecialPath);
  Result := Trim(string(SpecialPath));
end;

(*Получение папки "Рабочий стол" -------------------------------------------*)
function GetDesktopFolder:string;
var
  SFolder: PItemIDList;
  SpecialPath: Array[0 .. MAX_PATH_EX]Of char;
begin
  FillChar(SpecialPath, Length(SpecialPath), #0);
  SHGetSpecialFolderLocation(HInstance, CSIDL_DESKTOP, SFolder);
  SHGetPathFromIDList(SFolder, SpecialPath);
  //Result := Trim(string(SpecialPath));
  Result:=SetTailBackSlash(Ac2Str(SpecialPath));
end;

(*Получение папки "Мои рисунки" --------------------------------------------*)
function GetPictureFolder:string;
Var
  SFolder: PItemIDList;
  SpecialPath: Array[0 .. MAX_PATH_EX] Of char;
begin
  FillChar(SpecialPath, Length(SpecialPath), #0);
  SHGetSpecialFolderLocation(HInstance, CSIDL_MYPICTURES, SFolder);
  SHGetPathFromIDList(SFolder, SpecialPath);
  //Result := Trim(string(SpecialPath));
  Result:=SetTailBackSlash(Ac2Str(SpecialPath));
end;

function GetUserFolder : string;
Var
  SFolder: PItemIDList;
  SpecialPath: Array[0 .. MAX_PATH_EX]Of char;
begin
  FillChar(SpecialPath, Length(SpecialPath), #0);
  SHGetSpecialFolderLocation(HInstance, CSIDL_PROFILE , SFolder);
  SHGetPathFromIDList(SFolder, SpecialPath);
  //Result := Trim(string(SpecialPath));
  Result:=SetTailBackSlash(Ac2Str(SpecialPath));
end;


function GetWindowsFolder:string;
var
  buf: PChar;
begin
  buf := Allocmem(MAX_PATH_EX * SizeOfChar + 1);
  try
    GetWindowsDirectory(buf, Strlen(buf)- 1);
    Result := SetTailBackSlash(StrPas(buf));
  finally
    FreeMem(buf);
  end;
end;

function GetTrashFolder: string;
begin
Result:=GetSystemFolder(CSIDL_BITBUCKET);
end;

function GetSystemFolder(aCSIDL_Folder: integer;
  aSetBackSlash: boolean = true):string;
var
  SFolder: PItemIDList;
  SpecialPath: Array[0 .. MAX_PATH_EX]Of char;
begin
  FillChar(SpecialPath, Length(SpecialPath), #0);
  SHGetSpecialFolderLocation(HInstance, aCSIDL_Folder, SFolder);
  SHGetPathFromIDList(SFolder, SpecialPath);
  Result := SetTailBackSlash(Trim(string(SpecialPath)), aSetBackSlash);
end;

{$R-}

//-- по возможности использовать запуск от имени локального админитсратора (прав больше : 25 против 5 у пользователя)
procedure GetUserPrivileges(SysUser: PChar; List: TStringList);
const
  TokenSize = 800;//(SizeOf(Pointer)=4 *200)
  sz = 255;
var
  hToken: THandle;
  pTokenInfo: PTOKENPRIVILEGES;
  ReturnLen: cardinal;
  i: integer;
  PrivName: PChar;
  DisplayName: PChar;
  NameSize: cardinal;
  DisplSize: cardinal;
  LangId: cardinal;
begin
  pTokenInfo := Allocmem(TokenSize);
  PrivName := Allocmem(sz);
  DisplayName := Allocmem(sz);
  try
    if not OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or
      TOKEN_QUERY, hToken)then
      MessageBox(Application.Handle,
        'Ошибка запуска процесса получения списка привелегий.', 'Упс!',
        MB_ICONERROR);
    if not GetTokenInformation(hToken, TokenPrivileges, pTokenInfo, TokenSize,
      ReturnLen)then
      MessageBox(Application.Handle, 'Ошибка в получении списка привелегий.',
        'Упс!', MB_ICONERROR);
    for i := 0 to pTokenInfo^.PrivilegeCount - 1 do
    begin
      DisplSize := sz;
      NameSize := sz;
      FillChar(PrivName^, sz, 0);
      FillChar(DisplayName^, sz, 0);
      LangId := 0419;
      LookupPrivilegeName(SysUser, pTokenInfo.Privileges[i].Luid, PrivName,
        NameSize);
      LookupPrivilegeDisplayName(SysUser, PrivName, DisplayName,
        DisplSize, LangId);
      List.Add(Trim(StrPas(PrivName))+{^I}' - ' + Trim(StrPas(DisplayName)));
    end;
  finally
    FreeMem(PrivName);
    FreeMem(DisplayName);
    FreeMem(pTokenInfo);
  end;
end;
{$R+}


(* Установка русского, английского и произвольного(для восстановления) языка  *)
procedure SetRusLang;
//var
//Layout : array[0.. KL_NAMELENGTH] of char;
begin
//LoadKeyboardLayout(StrCopy(Layout,'00000419'),KLF_ACTIVATE);
LoadKeyboardLayout('00000419',KLF_ACTIVATE);
end;

procedure SetEngLang;
//var
//Layout : array[0.. KL_NAMELENGTH] of char;
begin
//LoadKeyboardLayout(StrCopy(Layout,'00000409'),KLF_ACTIVATE);
LoadKeyboardLayout('00000409',KLF_ACTIVATE);
end;


procedure SetLang(const aKeybLangName : PChar);
begin
LoadKeyboardLayout(aKeybLangName,KLF_ACTIVATE);
end;

procedure GetLang(var aKeybLangName : PChar);
begin
aKeybLangName:=AllocMem(KL_NAMELENGTH+1);
GetKeyboardLayoutName(aKeybLangName);
end;

//
//SE_CREATE_TOKEN_NAME           = 'SeCreateTokenPrivilege';
//SE_UNSOLICITED_INPUT_NAME      = 'SeUnsolicitedInputPrivilege';
//SE_MACHINE_ACCOUNT_NAME        = 'SeMachineAccountPrivilege';
//SE_REMOTE_SHUTDOWN_NAME        = 'SeRemoteShutdownPrivilege';
//SE_SYNC_AGENT_NAME             = 'SeSyncAgentPrivilege';
//SE_ENABLE_DELEGATION_NAME      = 'SeEnableDelegationPrivilege';
//
//
//
//
//
//
//
//
//SeImpersonatePrivilege - Имитация клиента после проверки подлинности
//SeCreateGlobalPrivilege - Создание глобальных объектов
//SeIncreaseWorkingSetPrivilege - Увеличение рабочего набора процесса
//SeTimeZonePrivilege - Изменение часового пояса
//SeCreateSymbolicLinkPrivilege - Создание символических ссылок

(*Замена строки определенным символом*)
function TransStr(const S:string;const Old:string;const New: char):string;
var
  i, j: integer;
  L, o: integer;
  Str:string;
begin
  Result := '';
  i := 1;
  L := Length(S);
  o := Length(Old);
  while i <= L do
  begin
    Str := S[i];
    for j := 1 to o do
    begin
      if Str = Old[j]then
      begin
        if New <> #0 then
          Str := New
        else
          Str := '';
        Break;
      end;
    end;
    Result := Result + Str;
    Inc(i);
  end;
end;

(*Замена всяческих спецсимоволов на пробелы (#32)*)
function NormalizeString(const InputString:string;
  const WOFormat: boolean = false):string;
  function IsSpaceLike(const Symbol: char): boolean;
  const
    SpaceLikeAll: TSysCharSet =[#0 .. #32, #127, #160];
    //SpaceLikeWOFormat  : set of char = [#1..#8,#11,#12,#127,#160];
    SpaceLikeWOFormat: TSysCharSet =[#1 .. #10, #11, #12, #13, #127, #160];
  begin
    if not WOFormat then
      Result := CharInSet(Symbol, SpaceLikeAll)
    else
      Result := CharInSet(Symbol, SpaceLikeWOFormat);
  end;

var
  cnt: integer;
  CharPresent: boolean;
begin
  Result := '';
  if InputString = '' then
    Exit;
  CharPresent := false;
  for cnt := 1 to Length(InputString)do
  begin
    if IsSpaceLike(InputString[cnt])then
      if not CharPresent then
      begin
        CharPresent := true;
        Result := Result + ' ';
      end
      else//да есть уже такой!
    else
    begin
      CharPresent := false;
      Result := Result + InputString[cnt];
    end;
  end;
end;

function NormalizeStringSysPath(const InputString:string):string;
begin
  Result := Trim(TransStr(NormalizeString(InputString, true),BadChars, #0));
end;

function ClearSysPath(const InputString:string):string;
begin
  Result := Trim(TransStr(NormalizeString(InputString, true),SysBadCharsStr, #0));
end;



function CheckForSysBadChars(const aTest : string) : boolean;
var
 cnt : integer;
 tst : PAnsiChar;
begin
Result:=true;
//tst:=AllocMem(Length(aTest)+1);
try
//StrPCopy(tst,AnsiString(aTest));
tst:=PAnsiChar(AnsiString(aTest)); // -- просто получаем укзатель....
for cnt:=0 to High(SysBadChars)
  do if StrPos(tst,SysBadChars[cnt])<>nil
        then Exit;
Result:=false;
finally
//Freemem(tst);
end;
end;

function ExistZeroChar(const Bytes : TBytes) : boolean;
var
 cnt : integer;
begin
Result:=true;
for cnt:=0 to High(Bytes)
  do if Bytes[cnt]=0 then Exit;
Result:=false;
end;

function NormalizeComponentName(const InputString:string):string;
begin
  Result := Trim(TransStr(NormalizeString(InputString, true), BadChars, #0));
  Result := Trim(TransStr(Result, '{}-', #0));
end;

function NormalizeNumOnly(const InputString:string):string;
var
  cnt: integer;
begin
  Result := '';
  for cnt := 1 to Length(InputString)do
    if CharInSet(InputString[cnt],['0', '1' .. '9'])then
      Result := Result + InputString[cnt];
end;

function NormalizeName(const Value:string):string;
begin
  Result := Value;
  Result := StringReplace(Result, '\n', crlf,[rfReplaceAll]);
  Result := StringReplace(Result, '\', '\\',[rfReplaceAll]);
  Result := StringReplace(Result, '"', '\"',[rfReplaceAll]);
  Result := StringReplace(Result, '/', '\/',[rfReplaceAll]);
  Result := StringReplace(Result, '''', '\''',[rfReplaceAll]);
  Result := StringReplace(Result, '|', '-''',[rfReplaceAll]);
  Result := StringReplace(Result, crlf, '\n',[rfReplaceAll]);
end;

function NormalizeNameHTML_DELETE(const Value:string):string;
begin
// -- это попытка как-то (видимо???) уйти от ошибок синтаксиса JS
  Result := Value;
  Result := StringReplace(Result, crlf, '<br>',[rfReplaceAll]);
  Result := StringReplace(Result, '&', '&amp;',[rfReplaceAll]);
  Result := StringReplace(Result, '\n', '<br>',[rfReplaceAll]);
  Result := StringReplace(Result, '\', '\\',[rfReplaceAll]);
  Result := StringReplace(Result, '"', '&quot;',[rfReplaceAll]);
  //Result := StringReplace(Result, '</', CopyRightChar+RegisteredChar,[rfReplaceAll]);
  //Result := StringReplace(Result, '/', '&#8260;',[rfReplaceAll]);
  //Result := StringReplace(Result, CopyRightChar+RegisteredChar, '</',[rfReplaceAll]);
  Result := StringReplace(Result, cr, '&#10;',[rfReplaceAll]);
end;

function NormalizeNameXML(const Value:string):string;
var
  cnt: integer;
begin
  Result := Value;
  for cnt := 1 to 31 do
    Result := StringReplace(Result, Chr(cnt), ' ',[rfReplaceAll]);
  Result := StringReplace(Result, '&', '&amp;',[rfReplaceAll]);
  Result := StringReplace(Result, '<', '&lt;',[rfReplaceAll]);
  Result := StringReplace(Result, '>', '&gt;',[rfReplaceAll]);
  Result := StringReplace(Result, '"', '&quot;',[rfReplaceAll]);
  Result := StringReplace(Result, '''', '&apos;',[rfReplaceAll]);
  Result := StringReplace(Result, #160, '&#160;',[rfReplaceAll]);
  //Result:=StringReplace(Result,'#$'  ,'&#x'   ,[rfReplaceAll]);
  Result := StringReplace(Result, '&amp;#', '&#',[rfReplaceAll]);
  Result := StringReplace(Result, '/', '&#47;',[rfReplaceAll]);
  //-- область затычек :-( --
  Result := StringReplace(Result, '&#1;', '',[rfReplaceAll]);
end;

// -- нормализует строку, в которой встречаются фрагменты похожие на дату и время
function NormalizeDateTimeHavingString(const Value:string; dlm : char = #32):string;
var
 str : string;
 sda : TStringDynArray;
 cnt : integer;
 tst : string;
 bD  : TDateTime;
 bT  : TDateTime;
 dt  : TDateTime;
 res : string;
begin
str:=Value;
bD:=EncodeDate(1941,6,22);
bT:=EncodeTime(23,59,59,997);
sda:=SplitString(str,dlm);
res:='';
for cnt:=0 to High(sda)
     do begin
     tst:=TransStrR(sda[cnt],':/\.-_',FormatSettings.TimeSeparator);
     dt:=StrToTimeDef(tst,bT);
     if (dt<>bT) and (Pos(FormatSettings.TimeSeparator,tst)<>0)
        then begin
        if (cnt<High(sda)) and (UpperCase(sda[cnt+1])='PM')
           then begin
           dt:=dt+EncodeTime(12,0,0,0);
           sda[cnt+1]:='';
           end;
        res:=res+#160+FormatDateTime('hh:nn:ss',dt);
        Continue;
        end;
     tst:=TransStrR(sda[cnt],':/\.-_',FormatSettings.DateSeparator);
     dt:=StrToDateDef(tst,bD);
     if (dt<>bD) and (Pos(FormatSettings.DateSeparator,tst)<>0)
        then begin
        res:=res+#160+FormatDateTime('dd.mm.yyyy',dt);
        Continue;
        end;
     res:=res+IfThen(cnt>0,dlm)+sda[cnt];
     end;
Result:=res;
end;






function StringToXMLString(const aString:string):string;
begin
  Result := NormalizeNameXML(aString);
end;

function Str2XML(const aString:string):string;
begin
  Result := NormalizeNameXML(aString);
end;

function ValidXML(const aString:string):string;
begin
  Result := NormalizeNameXML(aString);
end;


function Str2JSON(const aString:string):string;
type
 TParseSymbol = record
   bad  : char;
   good : string;
 end;
const
 symbols : array[0..3] of TParseSymbol =
 (
 (bad:'"'; good:'\"'),
 (bad:#9 ; good:'\t'),
 (bad:#10; good:'\r'),
 (bad:#13; good:'\n')
 );
var
 cnt : integer;
begin
Result:=aString;
Result:=StringReplace(Result,'\','…',[rfReplaceAll]);
for cnt:=0 to High(symbols)
  do with symbols[cnt] do
     if Pos(bad,Result)<>0
        then Result:=StringReplace(Result,bad,good,[rfReplaceAll]);
Result:=StringReplace(Result,'…','\\',[rfReplaceAll]);
//Result:=StringReplace(Result,'\','\\',[rfReplaceAll]);
//Result:=StringReplace(Result,'"','\"',[rfReplaceAll]);
end;


function PrepareHTMLPhones(const aSRC : string; aDlm : char = ';') : string;
const shb = '<a href="tel:%s">%s</a>';
var
 sda  : TStringDynArray;
 cnt  : integer;
 cntC : integer;
 tmp  : string;
 res  : string;
begin
Result:=aSRC;
if aSRC='' then Exit;
res:='';
sda:=SplitString(Result,aDlm);
for cnt:=0 to High(sda)
  do begin
  tmp:='';
  for cntC:=1 to Length(sda[cnt])
     do if CharInSet(sda[cnt, cntC],['+','0'..'9']) // -- без ATT-шных команд!
           then tmp:=tmp+sda[cnt, cntC];
  res:=res+Format(shb,[tmp, sda[cnt]]);
  if cnt<High(sda) then res:=res+', ';
  end;
Result:=res;
end;


function NormalizeExcelSheetName(const Value:string):string;
var
  tmp:string;
begin
  tmp := Value;
  if Length(tmp)> 31 then
    tmp := Copy(tmp, 1, 30)+ ElipBtnChar;
  tmp := NormalizeStringSysPath(tmp);
  tmp := StringReplaceEx(tmp, PathDelim, '_',[rfReplaceAll]);
  Result := tmp;
end;


function CheckValidInteger(const Str:string; const PositivOnly: boolean = false): boolean;
var
  i, L  : integer;
  locstr:string;
  ch    : char;
begin
locstr := Str;
Result := false;
if locstr = '' then Exit;
L:=Length(locstr);
i:=Length(StringReplace(locstr,'-','',[rfReplaceAll]));
if ((L-i=1) and PositivOnly) or       // -- если позитив и есть -
   ((L-i=1) and (locstr[1]<>'-')) or  // -- если одиночный минус не в начале
   (L-i>1)                            // -- или минусов больше
   then Exit;
locstr:=StringReplace(locstr,'-','',[rfReplaceAll]);
if locstr='' then Exit;
for ch:='0' to '9' do locstr:=StringReplace(locstr,ch,'',[rfReplaceAll]);
if locstr<>'' then Exit;
(*INT64*)if StrToInt64(Str)>MAX_INTEGER then Exit;

//MAX_INTEGER
//if not PositivOnly then
//  begin
//    //if not (locstr[1] in ['-','0'..'9'])
//    if not SysUtils.CharInSet(locstr[1],['-', '0' .. '9'])then
//      Exit
//    else
//      L := Length(locstr);
//  end
//  else
//  begin
//    //if not (locstr[1] in ['0'..'9'])
//    if not SysUtils.CharInSet(locstr[1],['0' .. '9'])then
//      Exit
//    else
//      L := Length(locstr);
//  end;
//
//  for i := 2 to L do//if not (locstr[i] in ['0'..'9'])
//    if not SysUtils.CharInSet(locstr[i],['0' .. '9'])then
//      Exit;
  Result := true;
end;

function CheckValidInt64(const Str:string; const PositivOnly: boolean = false): boolean;
var
  i, L  : integer;
  locstr:string;
  ch    : char;
begin
locstr := Str;
Result := false;
if locstr = '' then Exit;
L:=Length(locstr);
i:=Length(StringReplace(locstr,'-','',[rfReplaceAll]));
if ((L-i=1) and PositivOnly) or       // -- если позитив и есть -
   ((L-i=1) and (locstr[1]<>'-')) or  // -- если одиночный минус не в начале
   (L-i>1)                            // -- или минусов больше
   then Exit;
locstr:=StringReplace(locstr,'-','',[rfReplaceAll]);
if locstr='' then Exit;
for ch:='0' to '9' do locstr:=StringReplace(locstr,ch,'',[rfReplaceAll]);
if locstr<>'' then Exit;
(*INT64*)if StrToInt64(Str)>High(int64) then Exit;
Result := true;
end;


function CheckValidHex(const Str:string): boolean;
var
  i, L: integer;
  locstr:string;
begin
  locstr := Trim(Str);
  if(locstr <> '')and(locstr[1]= '$')then
    locstr := Copy(locstr, 2, Length(locstr));
  Result := true;
  if locstr = '' then
  begin
    Result := false;
    Exit;
  end
  else
    L := Length(locstr);
  for i := 1 to L do
  //if not (locstr[i] in ['0'..'9','A','a','B','b','C','c','D','d','E','e','F','f'])
    if not CharInSet(locstr[i],['0' .. '9', 'A', 'a', 'B', 'b', 'C', 'c', 'D',
      'd', 'E', 'e', 'F', 'f'])then
    begin
      Result := false;
      Exit;
    end;
  locstr := '';
end;

function CheckValidFloat(const Str:string): boolean;
var
  _str:string;
  S: integer;
  C, D:string;
begin
{$R-}
  _str := Trim(Str);
  if CheckValidInteger(_str)then
  begin
    Result := true;
    Exit;
  end
  else
  begin
    S := AnsiPos(DecimalSeparator, _str);//ищем десятичный разделитель
    if not boolean(S)then
    begin
      Result := false;
      Exit;
    end
    else
    begin
      Result := false;
      C := Copy(_str, 1, S - 1);
      D := Copy(_str, S + 1, Length(_str));
      if D <> '' then
      begin
        if not CheckValidInteger(C) or not CheckValidInt64(D)
           then Exit;
      end
      else if not CheckValidInteger(C)then
        Exit;
      Result := true;
      Exit;
    end;
  end;
  try
    StrToFloat(_str);
    Result := true;
  except
    Result := false;
  end;
{$R+}
end;




function CheckDateInStrSafe(var DateStr:string): boolean;
var
  iSymb: integer;
  sDay, sMonth, sYear:string;
  function DaysInMonth(month, Year: Word): integer;
  const
    DaysPerMonth: array[1 .. 12]of integer =(31, 28, 31, 30, 31, 30, 31, 31, 30,
      31, 30, 31);
  begin
    Result := DaysPerMonth[month];
    if(month = 2)and IsLeapYear(Year)then
      Inc(Result);
  end;

var
  i: integer;
begin
  Result := false;
  if DateStr = '' then
    Exit;
  for i := 1 to Length(DateStr)do
    if not CharInSet(DateStr[i],[#48 .. #57])then
      DateStr[i]:= FormatSettings.DateSeparator;
  iSymb := Pos(FormatSettings.DateSeparator, DateStr);
  sDay := Copy(DateStr, 1, iSymb - 1);
  DateStr := Copy(DateStr, iSymb + 1, Length(DateStr));
  iSymb := Pos(FormatSettings.DateSeparator, DateStr);
  sMonth := Copy(DateStr, 1, iSymb - 1);
  sYear := Copy(DateStr, iSymb + 1, Length(DateStr));
  if(sDay = '')or(sMonth = '')or(sYear = '')or
  //not (Length(sYear) in [2,4]) or
    (Length(sDay)> 2)or(Length(sMonth)> 2)or not CheckValidInteger(sDay)or
    not CheckValidInteger(sMonth)or not CheckValidInteger(sYear)then
    Exit;
  if(StrToInt(sMonth)< 1)or(StrToInt(sMonth)> 12)then
    Exit;
  if(StrToInt(sDay)< 1)or(StrToInt(sDay)> DaysInMonth(StrToInt(sMonth),
    StrToInt(sYear)))then
    Exit;
  DateStr := sDay + FormatSettings.DateSeparator + sMonth +
    FormatSettings.DateSeparator + sYear;
  Result := true;
end;

function CheckDateInStrSafe(const aTestStr : string; var aDateStr:string): boolean;
var
  iSymb: integer;
  sDay, sMonth, sYear:string;
  function DaysInMonth(month, Year: Word): integer;
  const
    DaysPerMonth: array[1 .. 12]of integer =(31, 28, 31, 30, 31, 30, 31, 31, 30,
      31, 30, 31);
  begin
    Result := DaysPerMonth[month];
    if(month = 2)and IsLeapYear(Year)then
      Inc(Result);
  end;

var
  i: integer;
begin
  Result := false;
  if aTestStr = '' then
    Exit;
  aDateStr:=aTestStr;
  for i := 1 to Length(aDateStr)do
    if not CharInSet(aDateStr[i],[#48 .. #57])then
      aDateStr[i]:= FormatSettings.DateSeparator;
  iSymb := Pos(FormatSettings.DateSeparator, aDateStr);
  sDay := Copy(aDateStr, 1, iSymb - 1);
  aDateStr := Copy(aDateStr, iSymb + 1, Length(aDateStr));
  iSymb := Pos(FormatSettings.DateSeparator, aDateStr);
  sMonth := Copy(aDateStr, 1, iSymb - 1);
  sYear := Copy(aDateStr, iSymb + 1, Length(aDateStr));
  if(sDay = '')or(sMonth = '')or(sYear = '')or
  //not (Length(sYear) in [2,4]) or
    (Length(sDay)> 2)or(Length(sMonth)> 2)or not CheckValidInteger(sDay)or
    not CheckValidInteger(sMonth)or not CheckValidInteger(sYear)then
    Exit;
  if(StrToInt(sMonth)< 1)or(StrToInt(sMonth)> 12)then
    Exit;
  if(StrToInt(sDay)< 1)or(StrToInt(sDay)> DaysInMonth(StrToInt(sMonth),
    StrToInt(sYear)))then
    Exit;
  aDateStr := sDay + FormatSettings.DateSeparator + sMonth +
    FormatSettings.DateSeparator + sYear;
  Result := true;
end;


function CheckDateTimeInStrSafe(const aTestStr : string; var aResStr:string): boolean;
var
  sda : TStringDynArray;
  tmp : string;
  hasDate : boolean;
  hasTime : boolean;
begin
Result := false;
sda:=SplitString(aTestStr,' ');
if Length(sda)<>2 then Exit;
//hasDate:=CheckDateInStrSafe(sda[0],tmp);
//if not hasDate then Exit;
aResStr:='';
tmp:=FormatDateTime('dd.mm.yyyy',StrToDateTimeByFormat(sda[0],'dd.mm.yyyy'));
hasDate:=tmp=sda[0];
if hasDate then aResStr:=tmp;
tmp:=FormatDateTime('hh:nn:ss',StrToDateTimeByFormat(sda[1],'hh:nn:ss'));
hasTime:=tmp=sda[1];
if hasTime then aResStr:=aResStr+' '+tmp;
Result:=hasDate and hasTime;
end;


function CheckValidPhoneNumber(const aTestStr : string; var aPNC :TPhoneNumberCountry; var aResStr:string): boolean;
var
 tst    : string;
 cnt    : integer;
 number : string;
 code   : string;
 country: string;
begin
Result:=False;
aPNC:=pncUnknown;
tst:='';
for cnt:=1 to Length(aTestStr)
  do if CharInSet(aTestStr[cnt],['0'..'9'])
        then tst:=tst+aTestStr[cnt];
if Length(tst)<10 then Exit;
country:=Copy(tst,1,3);
if country='375' // -- Белоруссия
   then begin
   if Length(tst)<12 then Exit;
   code:=Copy(tst,4,2);
   if not InnerBool(StrToIntDef(code,0),[25,29,33,44]) and     // -- мобильный
      not InnerBool(StrToIntDef(code,0),[15,16,17,21,22,23])  // -- стационарный
      then Exit;
   aPNC:=pncBY;
   number:=Copy(tst,6,7);
   aResStr:='+'+country+'('+code+')'+Copy(number,1,3)+'-'+Copy(number,4,2)+'-'+Copy(number,6,2);
   end
   else
if country='380' // --Крым наш
   then begin
   if Length(tst)<12 then Exit;
   code:=Copy(tst,4,3);
   if not InnerBool(StrToIntDef(Copy(code,1,2),0),[65,69]) // -- стационарный, блокируем остальную Украину
      then Exit;
   aPNC:=pncKrym;
   number:=Copy(tst,7,6);
   aResStr:='+'+country+'('+code+')'+Copy(number,1,2)+'-'+Copy(number,3,2)+'-'+Copy(number,5,2);
   end
   else
if Copy(country,1,2)='77'  // --Казахстан
   then begin
   if Length(tst)<11 then Exit;
   aPNC:=pncKZ;
   code:=Copy(tst,2,3);
   number:=Copy(tst,5,7);
   aResStr:='+'+Copy(country,1,1)+'('+code+')'+Copy(number,1,3)+'-'+Copy(number,4,2)+'-'+Copy(number,6,2);
   end
   else
if (Copy(country,1,2)='79') or // -- мобильные
   (Copy(country,1,2)='89') or // -- мобильные
   (Copy(country,1,1)='7')  or
   (Copy(country,1,1)='8')
   then begin
   if Length(tst)<11 then Exit;
   if InnerBool(StrToIntDef(Copy(country,1,2),0),[79,89])
      then aPNC:=pncMobile
      else aPNC:=pncRU;
   code:=Copy(tst,2,3);
   number:=Copy(tst,5,7);
   aResStr:=IfThen(country[1]='7','+','')+Copy(country,1,1)+'('+code+')'+Copy(number,1,3)+'-'+Copy(number,4,2)+'-'+Copy(number,6,2);
   end
   else Exit;
Result:=true;
end;

function RandomByte(aPart: Byte): Byte;
begin
  Result := High(Result)- aPart + Random(aPart + 1);
end;


function RandomDateTime(aMin,aMax : TDateTime) : TDateTime;
var
 msA, msB : int64;
begin
msA:=DateTimeToUnixTime(aMin);
msB:=DateTimeToUnixTime(aMax);
Randomize;
Result:=UnixTimeToDateTime(Random(msB - msA) + msA);
end;

function RandomString : string; inline;
  function GetCaption(index : integer) : string; inline;
  begin
  Result:=Format('%d (%s)',[index, NumberToWords(index)]);
  end;
var
 mode       : integer;
// tmpInteger : integer;
// y,m,d   : word;
// h,n,s,z : word;
begin
//DecodeDate(Now, y,m,d);
//DecodeTime(Now, h,n,s,z);
mode:=Random(3);
try
case mode of
 0 : begin
//     y:=Random(DateUtils.YearOf(Now)-1900+1)+1900;
//     m:=Random(12)+1;
//     d:=Random(DaysThisMonth(m,y))+1;
//     h:=Random(24);
//     n:=Random(60);
//     s:=Random(60);
//     z:=Random(1000);
//     Result:=FormatDateTime('dd.mm.yyyy hh:nn:ss.zzz', EncodeDate(y,m,d) + EncodeTime(h,n,s,z));
     Result:=FormatDateTime('dd.mm.yyyy hh:nn:ss.zzz',
        EncodeDate(Random(DateUtils.YearOf(Now)-1899)+1900,Random(12)+1,Random(28)+1) +
        EncodeTime(Random(24),Random(60),Random(60),Random(1000)));
     end;
 1 : Result:= CreateUuidNum ;
 2 : begin
     Result:=Copy(CreateUuidNum,1,4);
     try
     Result := GetCaption(StrToInt(Result)) ;
     except
     Result:=' -- error : '+Result;
     end;
     end
 else Result:=AnsiLowercase(CreateUuid);
end;
except
// on E : EConvertError do CreateErrorMessage('RandomString', E, [mode,y,m,d,h,n,s,z], Result);
 on E : Exception do CreateErrorMessage('RandomString', E, [mode], Result);
end;
end;


function FileToArrayOfBytes(const aFileName : string ; var aBytes : TByteDynArray) : cardinal;
var
 fs : TFileStream;
begin
Result:=0;
try
fs:=TFileStream.Create(aFilename,fmOpenRead or fmShareDenyNone or fmShareCompat);
try
if fs.Size=0 then Exit;
fs.Position:=0;
SetLength(aBytes,fs.Size);
fs.Read(aBytes[0],fs.Size);
Result:=Length(aBytes);
finally
fs.Free;
end;
except
  on E : Exception do ;//LogErrorMessage('FileToArrayOfBytes',E,[]);
end;
end;

(*Открытие файла, папки, URL и т.п.*)
function FileOpenNT(const aFileName:string): boolean;
var
  res: HINST;
begin
  res := 0;
  Result := false;
  try
    try
      res := ShellExecute(Application.Handle,'open', PChar(aFileName),nil,nil,
        SW_SHOWNORMAL or SW_RESTORE);
    except
      on E: Exception do
        MessageBox(Application.Handle,
          PChar(E.Message + crlf + GetErrorString(GetLastError)),
          'Ошибка записи', MB_ICONERROR);
    end;
    if res > 32 then
      Exit;
//case res of
//0:tmp:='The operating system is out of memory or resources.';
//ERROR_FILE_NOT_FOUND:tmp:='The specified file was not found.';
//ERROR_PATH_NOT_FOUND:tmp:='The specified path was not found.';
//ERROR_BAD_FORMAT:tmp:='The .exe file is invalid (non-Win32 .exe or error in .exe image).';
//SE_ERR_ACCESSDENIED:tmp:='The operating system denied access to the specified file.';
//SE_ERR_ASSOCINCOMPLETE:tmp:='The file name association is incomplete or invalid.';
//SE_ERR_DDEBUSY:tmp:='The DDE transaction could not be completed because other DDE transactions were being processed.';
//SE_ERR_DDEFAIL:tmp:='The DDE transaction failed.';
//SE_ERR_DDETIMEOUT:tmp:='The DDE transaction could not be completed because the request timed out.';
//SE_ERR_DLLNOTFOUND:tmp:='The specified DLL was not found.';
//SE_ERR_NOASSOC:tmp:='There is no application associated with the given file name extension. This error will also be returned if you attempt to print a file that is not printable.';
//SE_ERR_OOM:tmp:='There was not enough memory to complete the operation.';
//SE_ERR_SHARE:tmp:='A sharing violation occurred.';
//end;
//if tmp<>'' then ;

//tmp:=GetErrorString();
//if tmp<>'' then ;

    if res = SE_ERR_ASSOCINCOMPLETE//SE_ERR_NOASSOC
    then
    begin
      ShellExecute(Application.Handle, 'openas',
        PChar(AnsiQuotedStr(aFileName, '"')),nil,Nil, SW_SHOWNORMAL);
      Exit;
    end;
    //ver:=WhatWindowsIsInstalled;
    if ShellExecute(Application.Handle, 'open',
      PChar(AnsiQuotedStr(aFileName, '"')),nil,nil, SW_SHOWNORMAL)
      in[SE_ERR_ASSOCINCOMPLETE, SE_ERR_NOASSOC]then
      res := ShellExecute(Application.Handle, 'open', 'rundll32.exe',
        PChar('shell32.dll,OpenAs_RunDLL ' + AnsiQuotedStr(aFileName, '"')),
        nil, SW_SHOW);
  finally
    Result := res > 32;
  end;
end;

function FileOpenNTWithParams(const aFileName, aParams:string): boolean;
var
  res: HINST;
begin
  res := 0;
  Result := false;
  try
    try
      res := ShellExecute(Application.Handle,nil, PChar(aFileName),
        PChar(aParams),nil, SW_SHOWNORMAL or SW_RESTORE);
    except
      on E: Exception do
        MessageBox(Application.Handle,
          PChar(E.Message + crlf + GetErrorString(GetLastError)),
          'Ошибка записи', MB_ICONERROR);
    end;
    if res > 32 then
      Exit;
    if res = SE_ERR_ASSOCINCOMPLETE//SE_ERR_NOASSOC
    then
    begin
      ShellExecute(Application.Handle, 'openas',
        PChar(AnsiQuotedStr(aFileName, '"')),nil,Nil, SW_SHOWNORMAL);
      Exit;
    end;
    //ver:=WhatWindowsIsInstalled;
    if ShellExecute(Application.Handle, 'open',
      PChar(AnsiQuotedStr(aFileName, '"')),nil,nil, SW_SHOWNORMAL)
      in[SE_ERR_ASSOCINCOMPLETE, SE_ERR_NOASSOC]then
      res := ShellExecute(Application.Handle, 'open', 'rundll32.exe',
        PChar('shell32.dll,OpenAs_RunDLL ' + AnsiQuotedStr(aFileName, '"')),
        nil, SW_SHOW);
  finally
    Result := res > 32;
  end;
end;

procedure SetTailingBackSlash(var aPath:string; aSetting: boolean);
var
  ind: integer;
begin
  if aPath = '' then
    Exit;
  ind := Length(aPath);
  while IsPathDelimiter(aPath, ind)do
    Dec(ind);
  aPath := Copy(aPath, 1, ind);
  if aSetting then
    aPath := aPath + PathDelim;
end;

function SetTailBackSlash(const aPath:string; aSetting: boolean = true):string;
begin
  Result := aPath;
  SetTailingBackSlash(Result, aSetting);
end;

function GetParamStr(P: PChar; var Param: string): PChar;
var
  i, Len: Integer;
  Start, S: PChar;
begin
  // U-OK
  while True do
  begin
    while (P[0] <> #0) and (P[0] <= ' ') do
      Inc(P);
    if (P[0] = '"') and (P[1] = '"') then Inc(P, 2) else Break;
  end;
  Len := 0;
  Start := P;
  while P[0] > ' ' do
  begin
    if P[0] = '"' then
    begin
      Inc(P);
      while (P[0] <> #0) and (P[0] <> '"') do
      begin
        Inc(Len);
        Inc(P);
      end;
      if P[0] <> #0 then
        Inc(P);
    end
    else
    begin
      Inc(Len);
      Inc(P);
    end;
  end;
  SetLength(Param, Len);
  P := Start;
  S := Pointer(Param);
  i := 0;
  while P[0] > ' ' do
  begin
    if P[0] = '"' then
    begin
      Inc(P);
      while (P[0] <> #0) and (P[0] <> '"') do
      begin
        S[i] := P^;
        Inc(P);
        Inc(i);
      end;
      if P[0] <> #0 then Inc(P);
    end
    else
    begin
      S[i] := P^;
      Inc(P);
      Inc(i);
    end;
  end;
  Result := P;
end;


function GetParamStrByIndex(const aCmdLine : string; aIndex : integer) : string;
var
 Prm : PChar;
begin
Prm:=PChar(aCmdLine);
while True
  do begin
  Prm := GetParamStr(Prm, Result);
  if (aIndex = 0) or (Result = '') then Break;
  Dec(aIndex);
  end;
end;

function SaveStringIntoFileAnsi(const aStr: AnsiString;
  const aFileName:string): integer;
var
  tmp: AnsiString;
  aFile: hFile;
  PSA: PSecurityAttributes;
  buf: PAnsiChar;
  WritedSize: cardinal;
begin
  tmp := AnsiString(aStr);
  PSA := Allocmem(SizeOf(TSecurityAttributes));
  //buf:=Allocmem((length(aStr)+1)*SizeOf(Char));\
  buf := Allocmem(Length(tmp)* SizeOfChar);
  aFile := 0;
  try
    PSA^.nLength := SizeOf(TSecurityAttributes);
    PSA^.lpSecurityDescriptor := nil;
    PSA^.bInheritHandle := LongBool(false);
    aFile := CreateFile(PChar(aFileName), GENERIC_WRITE or GENERIC_READ,
      FILE_SHARE_WRITE or FILE_SHARE_READ, PSA, CREATE_ALWAYS,
      FILE_ATTRIBUTE_NORMAL, 0);
    //buf:=PChar(FileText);
    //StrPCopy(buf,aStr);
    StrPCopy(buf, tmp);
    WriteFile(aFile, buf^, Length(tmp), WritedSize,nil);
    FlushFileBuffers(aFile);
  finally
    CloseHandle(aFile);
    FreeMem(PSA);
    FreeMem(buf);
  end;
  Result := WritedSize;
end;

function SaveStringIntoFileWide(const aStr, aFileName:string): integer;
var
  aFile: hFile;
  PSA: PSecurityAttributes;
  //buf        : PChar;
  WritedSize: cardinal;
begin
  PSA := Allocmem(SizeOf(TSecurityAttributes));
  //buf:=Allocmem((length(aStr)+1)*SizeOf(Char));\
  //buf:=Allocmem(length(aStr)*SizeOfChar+1);
  aFile := 0;
  try
    Result := 0;
    PSA^.nLength := SizeOf(TSecurityAttributes);
    PSA^.lpSecurityDescriptor := nil;
    PSA^.bInheritHandle := LongBool(false);
    aFile := CreateFile(PChar(aFileName), GENERIC_WRITE, FILE_SHARE_WRITE, PSA,
      CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
    //buf:=PChar(aStr);
    //StrPCopy(buf,aStr);
    //StrPCopy(buf,aStr);
    WriteFile(aFile, aStr[1], Length(aStr)* SizeOfChar, WritedSize,nil);
    FlushFileBuffers(aFile);
    Result := WritedSize;
  finally
    CloseHandle(aFile);
    FreeMem(PSA);
    //FreeMem(buf);
  end;
end;

procedure SaveStringIntoFileStream(const aStr, aFileName:string; aOverWrite : boolean = true);
var
  fs   : TfileStream;
  buf  : PAnsiChar;
  sz   : integer;
  str  : AnsiString;
  step : integer;
  dir  : string;
begin
PackMemory;
step:=0;
try
if aFileName='' then Exit;
str := AnsiString(aStr);
dir:=ExtractFilePath(aFileName);
if not DirectoryExists(dir)
   then begin
   ForceDirectories(dir) ;
   if not DirectoryExists(dir) then Exit;
   end;
sz  := Length(str);
buf := Allocmem(sz + 1);
step:=10;
if aOverWrite
   then fs  := TfileStream.Create(aFileName, fmCreate)
   else
if FileExists(aFileName)
   then begin
   fs  := TfileStream.Create(aFileName, fmOpenWrite);
   fs.Seek(0,soFromEnd);
   end
   else fs  := TfileStream.Create(aFileName, fmCreate);
try
step:=20;
StrPCopy(buf, str);
step:=30;
if str <> '' then fs.Write(buf^, sz);
step:=40;
finally
fs.Free;
FreeMem(buf);
dir:='';
end;
except
    on E: Exception do
      ShowMessageWarning(Format('Error in SaveStringIntoFileStream(%s) : %s. %s [%s]',[step, aFileName,  E.Message, GetErrorString(GetLastError)]))
  end;
end;

procedure SaveBytesIntoFileStream(const aData : TBytes; const aFileName:string; aOverWrite : boolean = true);
var
  fs   : TfileStream;
  sz   : integer;
  step : integer;
  dir  : string;
begin
PackMemory;
step:=0;
try
if aFileName='' then Exit;
dir:=ExtractFilePath(aFileName);
if not DirectoryExists(dir)
   then begin
   ForceDirectories(dir) ;
   if not DirectoryExists(dir) then Exit;
   end;
sz  := Length(aData);
step:=10;
if aOverWrite
   then fs  := TfileStream.Create(aFileName, fmCreate)
   else
if FileExists(aFileName)
   then begin
   fs  := TfileStream.Create(aFileName, fmOpenWrite);
   fs.Seek(0,soFromEnd);
   end
   else fs  := TfileStream.Create(aFileName, fmCreate);
try
step:=30;
if sz>0 then fs.Write(adata[0], sz);
step:=40;
finally
fs.Free;
dir:='';
end;
except
    on E: Exception do
      ShowMessageWarning(Format('Error in SaveBytesIntoFileStream(%s) : %s. %s [%s]',[step, aFileName,  E.Message, GetErrorString(GetLastError)]))
  end;
end;

function SaveStringIntoFileStreamEx(const aStr, aFileName:string; aOverWrite : boolean = true) : string;
var
  fs: TfileStream;
  buf: PAnsiChar;
  sz: integer;
  str : AnsiString;
  step : integer;
begin
Result:='';
PackMemory;
step:=0;
try
str := AnsiString(aStr);
if str='' then Exit;
sz  := Length(str);
buf := Allocmem(sz + 1);
step:=10;
if aOverWrite
   then fs  := TfileStream.Create(aFileName, fmCreate)
   else
if FileExists(aFileName)
   then begin
   fs  := TfileStream.Create(aFileName, fmOpenWrite);
   fs.Seek(0,soFromEnd);
   end
   else fs  := TfileStream.Create(aFileName, fmCreate);
try
step:=20;
StrPCopy(buf, str);
step:=30;
if str <> '' then fs.Write(buf^, sz);
step:=40;
finally
fs.Free;
FreeMem(buf);
end;
except
  on E: Exception do CreateErrorMessage('SaveStringIntoFileStreamEx',E,[step, aFileName],Result);
end;
end;


procedure SaveStringIntoFile(const aStr, aFileName:string);
var
  strl: TStringList;
  step:integer;
  //ior  : integer;
  //Fl   : file;
begin
PackMemory;
  //SaveStringIntoFileStream(aStr,aFileName);
  //Exit;
  step := 0;//'Вход';
  SetLastError(0);
  try
    step :=  10;//'Создание';
    strl := TStringList.Create;
    try
      //ShowMessage(ExtractFilePath(aFileName)+crlf+IntToStr(integer(DirectoryExists(ExtractFilePath(aFileName))))+crlf+aFileName);
      step :=  20;//'Присваивание';
      strl.Text := string(AnsiString(aStr));
      step :=  30;//'Сохранение';
      strl.SaveToFile(aFileName);
      //_sleep(1);
      //{$I-}
      //Assign(Fl,aFilename);
      //repeat
      //Reset(Fl); // открыть файл для чтения
      //ior := IOResult;
      //until ior=0;
      //{$I+}
      //ShowMessage('Ready for :'+aFileName);
      step :=  40;//'Разрушение';
    finally
      //CloseFile(Fl);
      strl.Free;
      //FreeStringList(strl);
    end;
  except
    on E: Exception do
      ShowMessageWarning(Format('Error in SaveStringIntoFile(%s) : %s. %s',
        [aFileName, step, E.Message, GetErrorString(GetLastError)]))
  end;
end;

procedure SaveStringIntoFileViaText(const aStr, aFileName:string);
var
  F: Text;
  step:string;
begin
  step := 'Вход';
  SetLastError(0);
  try
    step := 'Создание';
    AssignFile(F, aFileName);
    try
      //ShowMessage(ExtractFilePath(aFileName)+crlf+IntToStr(integer(DirectoryExists(ExtractFilePath(aFileName))))+crlf+aFileName);
      step := 'Присваивание';
      Rewrite(F);
      step := 'Сохранение';
      WriteLn(F, aStr);
      step := 'Сброс буфера';
      Flush(F);
    finally
      step := 'closefile';
      CloseFile(F);
    end;
  except
    on E: Exception do
      ShowMessageWarning(Format('Error in SaveStringIntoFileViaText(%s) : %s. %s',
        [step, E.Message, GetErrorString(GetLastError)]))
  end;
end;

procedure SaveStringIntoFileUTF8(const aStr, aFileName:string);
var
  strl: TStringList;
begin
  strl := TStringList.Create;
  try
    strl.Text := aStr;
    strl.SaveToFile(aFileName, TEncoding.UTF8);
  finally
    FreeStringList(strl);
  end;
end;

procedure SaveStringIntoFileDef(const aStr, aFileName:string);
var
  strl: TStringList;
begin
  strl := TStringList.Create;
  try
    strl.Text := aStr;
    strl.SaveToFile(aFileName, TEncoding.Default);
  finally
    FreeStringList(strl);
  end;
end;

function LoadStringFromFile(const aFileName:string):string;
var
  strl: TStringList;
begin
  Result := '';
  if not FileExists(aFileName)
    then Exit;
  strl := TStringList.Create;
  try
    strl.LoadFromFile(aFileName);
    Result := strl.Text;
  finally
    FreeStringList(strl);
  end;
end;

function LoadStringFromFileStream(const aFileName:string):string;
var
  fs: TFileStream;
  buf : PAnsiChar;
begin
  Result := '';
  if not FileExists(aFileName)then
    Exit;
  buf:=nil;
  fs := TFileStream.Create(aFilename,fmOpenRead or fmShareDenyNone or fmShareCompat);
  try
    buf:=AllocMem(fs.Size+1);
    fs.Position:=0;
    fs.Read(buf^, fs.Size);
    Result := string(StrPas(buf));
  finally
  if Assigned(buf) then FreeMem(buf);
  fs.Free;
  end;
end;

//procedure LoadStringFromFile(const aFileName : PChar; var aRes : PAnsiChar);
//var
//FS : TFileStream;
//begin
//if not FileExists(aFilename) then Exit;
//FS:=TFileStream.Create(aFilename,fmOpenRead);
//try
//ReallocMem(aRes,FS.Size*SizeOf(Char)+1);
//FS.Position:=0;
//FS.Read(aRes^,FS.Size*SizeOf(Char));
//finally
//FS.Free;
//end;
//end;

function LoadStringFromFileUTF8(const aFileName:string):string;
var
  strl: TStringList;
begin
  Result := '';
  if not FileExists(aFileName)then
    Exit;
  strl := TStringList.Create;
  try
    strl.LoadFromFile(aFileName, TEncoding.UTF8);
    Result := strl.Text;
  finally
    FreeStringList(strl);
  end;
end;

(*Проверка файла на возможность записи (свободен или нет) ------------------*)
function CanFileWrited(const aFileName : string) : boolean;
var
  fs : TFileStream;
begin
Result:=false;
try
if not FileExists(aFileName) then Exit;
  fs := TFileStream.Create(aFilename,fmOpenWrite);
  try
  Result := Assigned(fs) and (fs.Size>=0);
  finally
  fs.Free;
  end;
except
on E : EFOpenError
  do begin
  // -- это основная ошибка при выполнении этой функции
  end;
on E : Exception
  do begin
  // -- а вот это нештатное развитие ситуации !!!
  end
end;
end;

(*Очистка директории от файлов ---------------------------------------------*)
function ClearFiles(const aDir, aMask:string): boolean;
var
  strl: TStringDynArray;
  dir:string;
  cnt: integer;
  res: integer;
begin
  Result := false;
  dir := SetTailBackSlash(aDir);
  if not DirectoryExists(dir)then
    Exit;
  try
    res := 0;
    GetAllFiles(aDir, strl, aMask);
    for cnt := 0 to High(strl)do
    begin
      res := res + integer(DeleteFile(dir + strl[cnt]));
    end;
    Result := res = Length(strl);
  finally
    SetLength(strl, 0);
  end;
end;


procedure DeleteFilesByMask(const aFolder, aMask:string);
var
  strl: TStringDynArray;
  errcode: cardinal;
  errmsg:string;
  dir:string;
  cnt: integer;
begin
  try
    errmsg := '';
    dir := SetTailBackSlash(aFolder);
    if not DirectoryExists(dir)then
      Exit;
    try
      GetAllFiles(dir, strl, aMask);
      for cnt := 0 to High(strl)do
        try
          DeleteFile(dir + strl[cnt]);
        except
          on E: Exception do
          begin
            errcode := GetLastError;
            errmsg := Format('"%s" : %s. %s',[dir + strl[cnt], E.Message,
              GetErrorString(errcode)]);
            SetLastError(0);
          end;
        end;
    finally
      SetLength(strl, 0);
    end;
  except
    on E: Exception do
    begin
      errcode := GetLastError;
      errmsg := Format('Error in "FnCommon.DeleteFilesByMask" : %s. %s ' + crlf
        + '%s',[E.Message, GetErrorString(errcode), errmsg]);
      SetLastError(0);
    end;
  end;
end;


(*Очистка директории ---------------------------------------------*)
function IsFolderEmpty(const aDir : string) : boolean;
var
 sda : TStringDynArray;
begin
Result:=false;
try
GetAllFolders(aDir,sda);
if Length(sda)>0 then Exit;
GetAllFiles(aDir,sda);
if Length(sda)>0 then Exit;
Result:=true;
finally
Setlength(sda,0);
end;
end;


function ClearFolder(const aDir : string): boolean;
var
  folders : TStringDynArray;
  fldCnt  : integer;
  dir     : string;
begin
Result := true;
dir := SetTailBackSlash(aDir);
if not DirectoryExists(dir)
   then Exit;
try
try
Result:=false;
GetAllFoldersRecur(aDir,folders);
for fldCnt:=0 to High(folders)
  do begin
  ClearFiles(folders[fldCnt],'*.*');
  ShellDeleteFolder(0,folders[fldCnt],false);
  end;
ClearFiles(aDir,'*.*');
Result:=IsFolderEmpty(aDir);
except
end;
finally
Setlength(folders,0);
end;
end;


function ClearFolder(const aDir,Mask : string): boolean;
var
  folders : TStringDynArray;
  fldCnt  : integer;
  dir     : string;
begin
Result := true;
dir := SetTailBackSlash(aDir);
if not DirectoryExists(dir)
   then Exit;
try
try
Result:=false;
GetAllFoldersRecur(aDir,folders);
for fldCnt:=0 to High(folders)
  do begin
  ClearFiles(folders[fldCnt],Mask);
  ShellDeleteFolder(0,folders[fldCnt],false);
  end;
ClearFiles(aDir,Mask);
Result:=IsFolderEmpty(aDir);
except
end;
finally
Setlength(folders,0);
end;
end;

function DeleteFolder(const aDir : string): boolean;
var
  folders : TStringDynArray;
  fldCnt  : integer;
  dir     : string;
begin
Result := true;
dir := SetTailBackSlash(aDir);
if not DirectoryExists(dir)
   then Exit;
try
try
Result:=false;
GetAllFoldersRecur(aDir,folders);
SetLength(folders, Length(folders)+1);
folders[high(folders)]:=aDir;
for fldCnt:=0 to High(folders)
  do begin
  ClearFiles(folders[fldCnt],'*.*');
  ShellDeleteFolder(0,folders[fldCnt],false);
  end;
Result := not DirectoryExists(aDir);
except
end;
finally
Setlength(folders,0);
end;
end;

function FieldToFile(aField: TField;const aFileName:string):string;
var
  dir      : string;
  fn       : string;
  fullfn   : string;
  strm     : TfileStream;
  bytes    : array of Byte;
  ln       : integer;
begin
  Result := '';
  fullfn := '-';
  try
    if(aField.IsNull)(*or not (aField.IsBlob)*)
      then Exit;
    dir := ExtractFilePath(aFileName);
    fn  := ExtractFileName(aFileName); // -- может встретиться SysBadChar (если заменен символ из 3-4 байтовой кодировки (к примеру яп. иероглиф))
    if CheckForSysBadChars(fn) then fn:=NormalizeStringSysPath(fn);
    if not DirectoryExists(dir)
       then dir := SetTailBackSlash(GetTempFolder)
       else dir := SetTailBackSlash(dir);
    if fn=''
       then fn:=NormalizeStringSysPath(CreateUUID);
    fullfn := dir + fn;
    strm := TfileStream.Create(fullfn, fmCreate);
    try
      ln := Length(aField.AsBytes);
      if ln > 0
         then begin
         SetLength(bytes, ln);
         System.Move(aField.AsBytes[0], bytes[0], ln);
         end;
      strm.WriteBuffer((@bytes[0])^, ln);
    finally
      strm.Free;
    end;
    sleep(1);
    if FileExists(fullfn)
       then Result := fullfn;
  except
    on E: Exception do CreateErrorMessage('FieldToFile',E,[aFileName,fullfn],Result);
  end;
end;

function FieldToMemoryStream(aField: TField;
  var aMemoryStream: TMemoryStream): int64;
var
  bytes: array of Byte;
  ln: integer;
begin
  Result :=-1;
  try
    if(aField.IsNull)(*or not (aField.IsBlob)*)then
      Exit;
    try
      ln := Length(aField.AsBytes);
      if ln > 0 then
      begin
        SetLength(bytes, ln);
        System.Move(aField.AsBytes[0], bytes[0], ln);
      end;
      aMemoryStream.WriteBuffer((@bytes[0])^, ln);
      Result := aMemoryStream.Size;
    finally
      //
    end;
  except
    on E: Exception do;
    //Result:=Format('ERROR in FieldToMemoryStream : %s',[E.Message]);
  end;
end;



function StringToStream(const aStr:string;var aStream: TStream): integer;
var
  buf: PChar;
begin
  buf := Allocmem(Length(aStr)* SizeOfChar + 1);
  try
    //StrPCopy()
    aStream.ReadBuffer(buf^, Length(aStr)* SizeOfChar);
    Result := aStream.Size;
  finally
    FreeMem(buf);
  end;
end;

function StringToStream(const aStr:string;var aStream: TMemoryStream): integer;
var
  buf: PChar;
begin
  buf := Allocmem(Length(aStr)* SizeOfChar + 1);
  try
    StrPCopy(buf, aStr);
    aStream.WriteBuffer(buf^, Length(aStr)* SizeOfChar);
    Result := aStream.Size;
  finally
    FreeMem(buf);
  end;
end;

function StreamToFile(aStream: TStream;const aFileName:string): boolean;
var
  PSA: PSecurityAttributes;
  hFile: cardinal;
  fn: PWideChar;
  buf: PChar;
  WriteSize: cardinal;
begin
  Result := false;
  fn := Allocmem(Length(aFileName)* SizeOfChar + 1);
  CreatePSA(PSA);
  //StrPCopy(fn,aFileName);
  StringToWideChar(aFileName, fn, Length(aFileName)* SizeOfChar + 1);
  hFile := CreateFileW(fn, GENERIC_WRITE, 0, PSA, CREATE_ALWAYS,
    FILE_ATTRIBUTE_NORMAL, 0);
  try
    if hFile <> INVALID_HANDLE_VALUE then
    begin
      buf := Allocmem(aStream.Size + 1);
      try
        aStream.Position := 0;
        aStream.ReadBuffer(buf^, aStream.Size);
        WriteFile(hFile, buf^, aStream.Size, WriteSize,nil);
      finally
        FreeMem(buf);
      end;
      Result := aStream.Size = WriteSize;
    end
    else;
  finally
    CloseHandle(hFile);
    FreeMem(PSA);
    FreeMem(fn);
  end;
end;

function OSFileNameToURL(const afn:string):string;
begin
  Result := 'file://' + StringReplace(afn, '\', '/',[rfReplaceAll]);
end;

function ReplaceStringInFile(const aFirst, aSecond, aFileName:string): boolean;
var
  strl: TStringList;
begin
  strl := TStringList.Create;
  try
    strl.LoadFromFile(aFileName);
    strl.Text := StringReplace(strl.Text, aFirst, aSecond,[rfReplaceAll]);
    strl.SaveToFile(aFileName);
    Result := true;
  finally
    FreeStringList(strl);
  end;
end;

//-- about valid chars in system paths : http://support.microsoft.com/kb/177506
function PrepareFileName(const aSrcFileName:string;
  aMAX_LENGTH: integer = MAX_PATH):string;
  function ReplaceChars(const aInputValue:string; aReplacer:string = ''):string;
  const
    InvalidChars:string = '*\/:!?"''<>|';
  var
    cnt: integer;
  begin
    Result := aInputValue;
    for cnt := 0 to 31 do
      Result := StringReplace(Result, char(cnt), aReplacer,[rfReplaceAll]);
    for cnt := 1 to Length(InvalidChars)do
      Result := StringReplace(Result, InvalidChars[cnt], aReplacer,
        [rfReplaceAll]);
  end;

var
  _dir:string;
  _ext:string;
  fnLength: integer;
  _name:string;
  tmp:string;
begin
  _ext := ExtractFileExt(aSrcFileName);
  _dir := ExtractFilePath(aSrcFileName);
  if DirectoryExists(_dir)or ForceDirectories(_dir)then
  begin
    _dir := SetTailBackSlash(_dir);
    fnLength := aMAX_LENGTH - Length(_dir)- Length(_ext);
    if fnLength <= 0 then
      _dir := SetTailBackSlash(GetTempFolder);
  end
  else
    _dir := SetTailBackSlash(GetTempFolder);
  fnLength := aMAX_LENGTH - Length(_dir)- Length(_ext);
  _name := ReplaceChars(ChangeFileExt(ExtractFileName(aSrcFileName), ''));
  tmp := CreateGuid;
  if _name = '' then
    if fnLength >= Length(tmp)then
      _name := tmp
    else
      _name := Copy(tmp, Length(tmp)- fnLength, fnLength)
  else
    _name := Copy(_name, 1, fnLength);
  Result := _dir + Trim(_name)+ Trim(_ext);
end;

function GetAbsolutePath(const aFileName:string):string;
var
  buf: PChar;
  part: PChar;
begin
  Result := aFileName;
  try
    buf := Allocmem(1024);
    try
      GetFullPathName(PChar(aFileName), 1024, buf, part);
      Result := StrPas(buf);
    finally
      FreeMem(buf);
    end;
  except
    on E: Exception do(**);
  end;
end;


function GetLongFileName(const aSrcFileName : string) : string;
begin
Result:=aSrcFileName;
if Length(Result)<=MAX_PATH then Exit;
Result:=GetLongPath(Result);
end;

function GetLongPath(const aFileName:string):string;
var
 ps : integer;
begin
Result:=Trim(aFileName);
ps:=Pos(':',Result);
if ps = 0
   then Result := '\\?\UNC\' + copy(Result, 3, length(Result))
   else Result := '\\?\' + Copy(Result,ps-1,Length(Result));
end;

function GetUNCName(const aFileName:string):string;
begin
Result:=GetLongPath(aFileName);
end;

function ClearUNCName(const aFileName:string):string;
begin
Result:=StringReplace(aFileName,'\\?\','',[]);
if Pos('UNC\',Result)=1
   then Result:=StringReplace(aFileName,'UNC\','\\',[]);
end;





function GetStringHash(ht : THashType; const Str : string) : string;
var
  hmd : TIdHashMessageDigest;
  hif : TIdHashIntF;
  ss : TStringStream;
begin
Result:='';
if ht in [htMD2, htMD4, htMD5]
   then begin
    case ht of
     htMD2 : hmd := TIdHashMessageDigest2.Create;
     htMD4 : hmd := TIdHashMessageDigest4.Create;
     htMD5 : hmd := TIdHashMessageDigest5.Create;
    else Exit;
    end;
    ss:=TStringStream.Create(AnsiString(Str));
    ss.Position:=0;
    try
    if Assigned(ss)
       then Result := hmd.HashStreamAsHex(ss)
       else Result:='';
    finally
    hmd.Free;
    ss.Free;
    end;
    end
  else
if ht in [htSha1, htSha224, htSha256, htSha384, htSha512]
   then begin
   IdSSLOpenSSLHeaders.Load();
   case ht of
   htSha1    : hif:=TIdHashSHA1.Create;
   htSha224  : hif:=TIdHashSHA224.Create;
   htSha256  : hif:=TIdHashSHA256.Create;
   htSha384  : hif:=TIdHashSHA384.Create;
   htSha512  : hif:=TIdHashSHA512.Create;
   else Exit;
   end;
    ss:=TStringStream.Create(AnsiString(Str));
    ss.Position:=0;
    try
    if Assigned(ss)
       then Result := hif.HashStreamAsHex(ss)
       else Result:='';
    finally
    hif.Free;
    ss.Free;
    end;
   end;
end;

function GetStreamHash(ht : THashType;Stream : TStream) : string;
var
  hmd : TIdHashMessageDigest;
  hif : TIdHashIntF;
begin
Result:='';
if ht in [htMD2, htMD4, htMD5]
   then begin
    case ht of
     htMD2 : hmd := TIdHashMessageDigest2.Create;
     htMD4 : hmd := TIdHashMessageDigest4.Create;
     htMD5 : hmd := TIdHashMessageDigest5.Create;
    else Exit;
    end;
    Stream.Position:=0;
    try
    if Assigned(Stream)
       then Result := hmd.HashStreamAsHex(Stream)
       else Result:='';
    finally
    hmd.Free;
    end;
   end
 else
if ht in [htSha1, htSha224, htSha256, htSha384, htSha512]
   then begin
   IdSSLOpenSSLHeaders.Load();
   case ht of
   htSha1    : hif:=TIdHashSHA1.Create;
   htSha224  : hif:=TIdHashSHA224.Create;
   htSha256  : hif:=TIdHashSHA256.Create;
   htSha384  : hif:=TIdHashSHA384.Create;
   htSha512  : hif:=TIdHashSHA512.Create;
   else Exit;
   end;
   Stream.Position:=0;
    try
    if Assigned(Stream)
       then Result := hif.HashStreamAsHex(Stream)
       else Result:='';
    finally
    hif.Free;
    end;
   end;

end;

function GetFileHash(ht : THashType;const aFileName : string) : string;
var
  Stream : TStream;
  hmd : TIdHashMessageDigest;
  hif : TIdHashIntF;
begin
Result:='';
if ht in [htMD2, htMD4, htMD5]
   then begin
    case ht of
     htMD2 : hmd := TIdHashMessageDigest2.Create;
     htMD4 : hmd := TIdHashMessageDigest4.Create;
     htMD5 : hmd := TIdHashMessageDigest5.Create;
    else Exit;
    end;
    if FileExists(aFileName)
       then Stream := TFileStream.Create(GetUNCName(aFileName), fmOpenRead)
       else Stream := TStringStream.Create(aFileName);
    try
    if Assigned(Stream)
       then Result := hmd.HashStreamAsHex(Stream)
       else Result:='';
    finally
    hmd.Free;
    Stream.Free;
    end;
   end
  else
if ht in [htSha1, htSha224, htSha256, htSha384, htSha512]
   then begin
   IdSSLOpenSSLHeaders.Load();
   case ht of
   htSha1    : hif:=TIdHashSHA1.Create;
   htSha224  : hif:=TIdHashSHA224.Create;
   htSha256  : hif:=TIdHashSHA256.Create;
   htSha384  : hif:=TIdHashSHA384.Create;
   htSha512  : hif:=TIdHashSHA512.Create;
   else Exit;
   end;
   if FileExists(aFileName)
       then Stream := TFileStream.Create(GetUNCName(aFileName), fmOpenRead)
       else Stream := TStringStream.Create(aFileName);
    try
    if Assigned(Stream)
       then Result := hif.HashStreamAsHex(Stream)
       else Result:='';
    finally
    hif.Free;
    Stream.Free;
    end;
   end;
end;



function GetStringMD2(const Str : string) : string;
var
  hmd2 : TIdHashMessageDigest2;
  ss : TStringStream;
begin
ss:=TStringStream.Create(AnsiString(Str));
ss.Position:=0;
hmd2 := TIdHashMessageDigest2.Create;
try
if Assigned(ss)
   then Result := hmd2.HashStreamAsHex(ss)
   else Result:='';
finally
hmd2.Free;
ss.Free;
end;
end;

function GetStreamMD2(Stream : TStream) : string;
var
  hmd2 : TIdHashMessageDigest2;
begin
Stream.Position:=0;
hmd2 := TIdHashMessageDigest2.Create;
try
if Assigned(Stream)
   then Result := hmd2.HashStreamAsHex(Stream)
   else Result:='';
finally
hmd2.Free;
end;
end;

function GetFileMD2(const aFileName : string) : string;
var
  Stream : TStream;
  hmd2 : TIdHashMessageDigest2;
begin
if FileExists(aFileName)
   then Stream := TFileStream.Create(GetUNCName(aFileName), fmOpenRead)
   else Stream := TStringStream.Create(aFileName);
hmd2 := TIdHashMessageDigest2.Create;
try
if Assigned(Stream)
   then Result := hmd2.HashStreamAsHex(Stream)
   else Result:='';
finally
hmd2.Free;
Stream.Free;
end;
end;


function GetStringMD4(const Str : string) : string;
var
  hmd4 : TIdHashMessageDigest4;
  ss : TStringStream;
begin
ss:=TStringStream.Create(AnsiString(Str));
ss.Position:=0;
hmd4 := TIdHashMessageDigest4.Create;
try
if Assigned(ss)
   then Result := hmd4.HashStreamAsHex(ss)
   else Result:='';
finally
hmd4.Free;
ss.Free;
end;
end;

function GetStreamMD4(Stream : TStream) : string;
var
  hmd4 : TIdHashMessageDigest4;
begin
Stream.Position:=0;
hmd4 := TIdHashMessageDigest4.Create;
try
if Assigned(Stream)
   then Result := hmd4.HashStreamAsHex(Stream)
   else Result:='';
finally
hmd4.Free;
end;
end;

function GetFileMD4(const aFileName : string) : string;
var
  Stream : TStream;
  hmd4 : TIdHashMessageDigest4;
begin
if FileExists(aFileName)
   then Stream := TFileStream.Create(GetUNCName(aFileName), fmOpenRead)
   else Stream := TStringStream.Create(aFileName);
hmd4 := TIdHashMessageDigest4.Create;
try
if Assigned(Stream)
   then Result := hmd4.HashStreamAsHex(Stream)
   else Result:='';
finally
hmd4.Free;
Stream.Free;
end;
end;



function GetStringMD5(const Str : string) : string;
var
  hmd5 : TIdHashMessageDigest5;
  ss : TStringStream;
begin
ss:=TStringStream.Create(AnsiString(Str));
ss.Position:=0;
hmd5 := TIdHashMessageDigest5.Create;
try
if Assigned(ss)
   then Result := hmd5.HashStreamAsHex(ss)
   else Result:='';
finally
hmd5.Free;
ss.Free;
end;
end;

function GetStreamMD5(Stream : TStream) : string;
var
  hmd5 : TIdHashMessageDigest5;
begin
Stream.Position:=0;
hmd5 := TIdHashMessageDigest5.Create;
try
if Assigned(Stream)
   then Result := hmd5.HashStreamAsHex(Stream)
   else Result:='';
finally
hmd5.Free;
end;
end;

function GetFileMD5(const aFileName : string) : string;
var
  Stream : TStream;
  hmd5 : TIdHashMessageDigest5;
begin
if FileExists(aFileName)
   then Stream := TFileStream.Create(GetUNCName(aFileName), fmOpenRead)
   else Stream := TStringStream.Create(aFileName);
hmd5 := TIdHashMessageDigest5.Create;
try
if Assigned(Stream)
   then Result := hmd5.HashStreamAsHex(Stream)
   else Result:='';
finally
hmd5.Free;
Stream.Free;
end;
end;




function GetAllFiles(const dir:string;var aStrings: TStringDynArray; const Mask:string = '*.*'): integer;
var
  FSR: TSearchRec;
  Path:string;
begin
  Result :=-1;
  try
  if not DirectoryExists(dir) then Exit;
    Path := dir;
    SetTailingBackSlash(Path, true);
    FillChar(FSR, SizeOf(TSearchRec), 0);
    if FindFirst(Path + Mask, faAnyFile and not faDirectory, FSR)= 0 then
    begin
      try
        SetLength(aStrings, Length(aStrings)+ 1);
        aStrings[High(aStrings)]:= FSR.Name;
        while FindNext(FSR)= 0 do
        begin
          SetLength(aStrings, Length(aStrings)+ 1);
          aStrings[High(aStrings)]:= FSR.Name;
        end;
      finally
        FindClose(FSR);
      end;
    end;
    Result := Length(aStrings);
  except
    on E: Exception do
      ShowMessageWarning
        (Format('Ошибка во время получения списка файлов с маской "%s" в папке "%s" : %s',
        [Mask, dir, E.Message]));
  end;
end;

function GetAllFilesFullPath(const dir:string;var aStrings: TStringDynArray; const Mask:string = '*.*'): integer;
var
  FSR: TSearchRec;
  Path:string;
begin
  Result :=-1;
  try
    if not DirectoryExists(dir) then Exit;
    Path := dir;
    SetTailingBackSlash(Path, true);
    FillChar(FSR, SizeOf(TSearchRec), 0);
    if FindFirst(Path + Mask, faAnyFile and not faDirectory, FSR)= 0 then
    begin
      try
        SetLength(aStrings, Length(aStrings)+ 1);
        aStrings[High(aStrings)]:= Path+FSR.Name;
        while FindNext(FSR)= 0 do
        begin
          SetLength(aStrings, Length(aStrings)+ 1);
          aStrings[High(aStrings)]:= Path+FSR.Name;
        end;
      finally
        FindClose(FSR);
      end;
    end;
    Result := Length(aStrings);
  except
    on E: Exception do
      ShowMessageWarning
        (Format('Ошибка во время получения списка файлов с маской "%s" в папке "%s" : %s',
        [Mask, dir, E.Message]));
  end;
end;

function GetAllFilesRecur(const dir:string;var aStrings: TStringDynArray; const Mask:string = '*.*'): integer;
var
  FSR: TSearchRec;
  Path:string;
begin
  Result :=-1;
  try
    if not DirectoryExists(dir) then Exit;
    Path := SetTailBackSlash(dir);
    FillChar(FSR, SizeOf(TSearchRec), 0);
    if FindFirst(Path + Mask, faAnyFile or faDirectory, FSR)= 0 then
    begin
      try
        if(FSR.Name <> '.')and(FSR.Name <> '..')then
        begin
          SetLength(aStrings, Length(aStrings)+ 1);
          aStrings[High(aStrings)]:= FSR.Name;
        end;
        while FindNext(FSR)= 0 do
        begin
          if(FSR.Name <> '.')and(FSR.Name <> '..')then
          begin
            if((FSR.Attr and faDirectory)> 0)then
              GetAllFilesRecur(Path + FSR.Name, aStrings)
            else
            begin
              SetLength(aStrings, Length(aStrings)+ 1);
              aStrings[High(aStrings)]:= Path + FSR.Name;
            end;
          end;
        end;
      finally
        FindClose(FSR);
      end;
    end;
    Result := Length(aStrings);
  except
    on E: Exception do
      ShowMessageWarning
        (Format('Ошибка во время получения списка файлов с маской "%s" в папке "%s" : %s',
        [Mask, dir, E.Message]));
  end;
end;

function GetAllFoldersRecur(const dir:string; var aStrings: TStringDynArray): integer;
const
  Mask:string = '*.*';
var
  FSR: TSearchRec;
  Path:string;
begin
  Result :=-1;
  try
    if not DirectoryExists(dir) then Exit;
    Path := SetTailBackSlash(dir);
    //SetTailingBackSlash(path,True);
    FillChar(FSR, SizeOf(TSearchRec), 0);
    if FindFirst(Path + Mask, faDirectory, FSR)= 0 then
    begin
      try
        if(FSR.Name <> '.')and(FSR.Name <> '..')and
          ((FSR.Attr and faDirectory)> 0)then
        begin
          SetLength(aStrings, Length(aStrings)+ 1);
          aStrings[High(aStrings)]:= SetTailBackSlash(FSR.Name);
        end;
        while FindNext(FSR)= 0 do
        begin
          if(FSR.Name <> '.')and(FSR.Name <> '..')then
          begin
            if((FSR.Attr and faDirectory)> 0)then
            begin
              SetLength(aStrings, Length(aStrings)+ 1);
              aStrings[High(aStrings)]:= SetTailBackSlash(Path + FSR.Name);
              GetAllFoldersRecur(Path + FSR.Name, aStrings);
            end;
          end;
        end;
      finally
        FindClose(FSR);
      end;
    end;
    Result := Length(aStrings);
  except
    on E: Exception do
      ShowMessageWarning
        (Format('Ошибка во время получения списка файлов с маской "%s" в папке "%s" : %s',
        [Mask, dir, E.Message]));
  end;
end;

function GetAllFoldersRecur(const dir:string;var aStrings: TStringList): integer;
const
  Mask:string = '*.*';
var
  FSR: TSearchRec;
  Path:string;
begin
  Result :=-1;
  try
    if not DirectoryExists(dir) then Exit;
    Path := SetTailBackSlash(dir);
    //SetTailingBackSlash(path,True);
    FillChar(FSR, SizeOf(TSearchRec), 0);
    if FindFirst(Path + Mask, faDirectory, FSR)= 0 then
    begin
      try
        if(FSR.Name <> '.')and(FSR.Name <> '..')and
          ((FSR.Attr and faDirectory)> 0)then
        begin
          //SetLength(aStrings,Length(aStrings)+1);
          //aStrings[High(aStrings)]:=FSR.Name;
          aStrings.Add(SetTailBackSlash(FSR.Name))
        end;
        while FindNext(FSR)= 0 do
        begin
          if(FSR.Name <> '.')and(FSR.Name <> '..')then
          begin
            if((FSR.Attr and faDirectory)> 0)then
            begin
              //SetLength(aStrings,Length(aStrings)+1);
              //aStrings[High(aStrings)]:=path+FSR.Name;
              aStrings.Add(SetTailBackSlash(Path + FSR.Name));
              GetAllFoldersRecur(Path + FSR.Name, aStrings);
            end;
          end;
        end;
      finally
        FindClose(FSR);
      end;
    end;
    Result := aStrings.Count;
  except
    on E: Exception do
      ShowMessageWarning
        (Format('Ошибка во время получения списка файлов с маской "%s" в папке "%s" : %s',
        [Mask, dir, E.Message]));
  end;
end;

function GetFoldersMsg(const dir:string;var aStrings: TStringDynArray; aWnd: cardinal; aMsg: integer): integer;
var
  FSR: TSearchRec;
  Str:string;
  ind: integer;
begin
  Result := 0;
  try
    if not DirectoryExists(dir) then Exit;
    Str := SetTailBackSlash(dir);
    if FindFirst(Str + '*.*', faAnyFile, FSR)= 0 then
    begin
      try
        if(FSR.Name <> '.')and(FSR.Name <> '..')and
          (FSR.Attr and faDirectory <> 0)then
        begin
          ind := Length(aStrings);
          SetLength(aStrings, ind + 1);
          aStrings[ind]:= SetTailBackSlash(Str + FSR.Name);
          SendTextMessage(aWnd, aMsg, ind + 1, aStrings[ind]);
          sleep(1);
        end;
        while FindNext(FSR)= 0 do
          if(FSR.Name <> '.')and(FSR.Name <> '..')and
            (FSR.Attr and faDirectory <> 0)then
          begin
            ind := Length(aStrings);
            SetLength(aStrings, ind + 1);
            aStrings[ind]:= SetTailBackSlash(Str + FSR.Name);
            SendTextMessage(aWnd, aMsg, ind + 1, aStrings[ind]);
            sleep(1);
          end;
      finally
        FindClose(FSR);
      end;
    end;
    Result := Length(aStrings);
  except
    on E: Exception do
      ShowMessageWarning
        (Format('Ошибка во время получения списка папок в папке "%s" : %s',
        [dir, E.Message]));
  end;
end;

function GetFoldersThreeMsg(const dir:string;var aStrings: TStringDynArray; aWnd: cardinal; aMsg: integer): integer;
const
  Mask:string = '*.*';
var
  FSR: TSearchRec;
  Str:string;
  ind: integer;
begin
  Result :=-1;
  try
    if not DirectoryExists(dir) then Exit;
    Str := GetLongPath(SetTailBackSlash(dir));
    //SetTailingBackSlash(path,True);
    FillChar(FSR, SizeOf(TSearchRec), 0);
    if FindFirst(Str + Mask, faDirectory, FSR)= 0 then
    begin
      try
        if(FSR.Name <> '.')and(FSR.Name <> '..')and
          ((FSR.Attr and faDirectory)> 0)then
        begin
          ind := Length(aStrings);
          SetLength(aStrings, ind + 1);
          aStrings[ind]:= SetTailBackSlash(Str + FSR.Name);
          SendTextMessage(aWnd, aMsg, ind + 1, aStrings[ind]);
          sleep(1);
        end;
        while FindNext(FSR)= 0 do
        begin
          if(FSR.Name <> '.')and(FSR.Name <> '..')then
          begin
            if((FSR.Attr and faDirectory)> 0)then
            begin
              ind := Length(aStrings);
              SetLength(aStrings, ind + 1);
              aStrings[ind]:= SetTailBackSlash(Str + FSR.Name);
              SendTextMessage(aWnd, aMsg, ind + 1, aStrings[ind]);
              sleep(1);
              //SetLength(aStrings,Length(aStrings)+1);
              //aStrings[High(aStrings)]:=str+FSR.Name;
              GetAllFoldersRecur(Str + FSR.Name, aStrings);
            end;
          end;
        end;
      finally
        FindClose(FSR);
      end;
    end;
    Result := Length(aStrings);
  except
    on E: Exception do
      ShowMessageWarning
        (Format('Ошибка во время получения списка папок в папке "%s" : %s',
        [dir, E.Message]));
  end;
end;

function GetFoldersMsg(const dir:string;var aStrings: TStringList; aWnd: cardinal; aMsg: integer): integer;
var
  FSR: TSearchRec;
  Str:string;
  ind: integer;
begin
  Result := 0;
  try
    if not DirectoryExists(dir) then Exit;
    Str := SetTailBackSlash(dir);
    if FindFirst(Str + '*.*', faAnyFile, FSR)= 0 then
    begin
      try
        if(FSR.Name <> '.')and(FSR.Name <> '..')and
          (FSR.Attr and faDirectory <> 0)then
        begin
          ind := aStrings.Add(SetTailBackSlash(Str + FSR.Name));
          SendTextMessage(aWnd, aMsg, ind + 1, aStrings[ind]);
          sleep(1);
        end;
        while FindNext(FSR)= 0 do
          if(FSR.Name <> '.')and(FSR.Name <> '..')and
            (FSR.Attr and faDirectory <> 0)then
          begin
            ind := aStrings.Add(SetTailBackSlash(Str + FSR.Name));
            SendTextMessage(aWnd, aMsg, ind + 1, aStrings[ind]);
            sleep(1);
          end;
      finally
        FindClose(FSR);
      end;
    end;
    Result := aStrings.Count;
  except
    on E: Exception do
      ShowMessageWarning
        (Format('Ошибка во время получения списка папок в папке "%s" : %s',
        [dir, E.Message]));
  end;
end;

function GetFoldersThreeMsg(const dir:string;var aStrings: TStringList; aWnd: cardinal; aMsg: integer): integer;
const
  Mask:string = '*.*';
var
  FSR: TSearchRec;
  Str:string;
  ind: integer;
begin
  Result :=-1;
  try
    if not DirectoryExists(dir) then Exit;
    Str := SetTailBackSlash(dir);
    //SetTailingBackSlash(path,True);
    FillChar(FSR, SizeOf(TSearchRec), 0);
    if FindFirst(Str + Mask, faDirectory, FSR)= 0 then
    begin
      try
        if(FSR.Name <> '.')and(FSR.Name <> '..')and
          ((FSR.Attr and faDirectory)> 0)then
        begin
          ind := aStrings.Add(SetTailBackSlash(Str + FSR.Name));
          SendTextMessage(aWnd, aMsg, ind + 1, aStrings[ind]);
          sleep(1);
        end;
        while FindNext(FSR)= 0 do
        begin
          if(FSR.Name <> '.')and(FSR.Name <> '..')then
          begin
            if((FSR.Attr and faDirectory)> 0)then
            begin
              ind := aStrings.Add(SetTailBackSlash(Str + FSR.Name));
              SendTextMessage(aWnd, aMsg, ind + 1, aStrings[ind]);
              sleep(1);
              //SetLength(aStrings,Length(aStrings)+1);
              //aStrings[High(aStrings)]:=str+FSR.Name;
              GetAllFoldersRecur(Str + FSR.Name, aStrings);
            end;
          end;
        end;
      finally
        FindClose(FSR);
      end;
    end;
    Result := aStrings.Count;
  except
    on E: Exception do
      ShowMessageWarning
        (Format('Ошибка во время получения списка папок в папке "%s" : %s',
        [dir, E.Message]));
  end;
end;

(*Получение всех папок из определенной в dir папке файлов*)
function GetAllFolders(const dir: PChar;var strl: TStringList): integer;
var FSR: TSearchRec;
  Str:string;
  //procedure SetTailingBackSlash(var path : string;Setting : boolean);
  //begin
  //if path='' then Exit
  //else begin
  //if (path[length(path)]='\') and  Setting then Exit;
  //if (path[length(path)]<>'\') and  not Setting then Exit;
  //if (path[length(path)]='\') and  not Setting then path:=Copy(path,1,Length(path)-1);
  //if (path[length(path)]<>'\') and  Setting then path:=path+'\';
  //end;
  //end;
begin
  Result := 0;
  if not DirectoryExists(StrPas(dir)) then Exit;
  if not Assigned(strl)then
    Exit;
  Str := StrPas(dir);
  SetTailingBackSlash(Str, false);
  if FindFirst(Str + '\*.*', faAnyFile, FSR)= 0 then
  begin
    try
      if(FSR.Name <> '.')and(FSR.Name <> '..')and
        (FSR.Attr and faDirectory <> 0)then
        strl.Add(FSR.Name);
      while FindNext(FSR)= 0 do
        if(FSR.Name <> '.')and(FSR.Name <> '..')and
          (FSR.Attr and faDirectory <> 0)then
          strl.Add(FSR.Name);
    finally
      FindClose(FSR);
    end;
  end;
  Result := strl.Count;
end;


function GetAllFolders(const dir: string;var aSDA: TStringDynArray): integer;
var
  FSR : TSearchRec;
  ind : integer;
  sd  : string;
  tmp : string;
begin
Result:=0;
if not DirectoryExists(dir) then Exit;
sd:=SetTailBackSlash(dir);
if FindFirst(sd+'*.*', faDirectory, FSR)=0 // -- если добавить '.' то и саму себя
   then begin
   try
   // -- и здесь добавить в список (*self*)
   while (FindNext(FSR)=0)
     do begin
     tmp:=sd+FSR.Name;
     if (FSR.Name<>'.')(*self*) and (FSR.Name<>'..')(*toplevel*)
        and DirectoryExists(tmp)
        then begin
        ind:=Length(aSDA);
        SetLength(aSDA, ind+1);
        aSDA[ind]:=tmp;
        end;
     end;
   finally
   FindClose(FSR);
   end;
   end;
Result:=Length(aSDA);
end;

function GetAllFoldersFullPath(const dir: PChar;var strl: TStringList): integer;
var
  FSR: TSearchRec;
  Str:string;
  //procedure SetTailingBackSlash(var path : string;Setting : boolean);
  //begin
  //if path='' then Exit
  //else begin
  //if (path[length(path)]='\') and  Setting then Exit;
  //if (path[length(path)]<>'\') and  not Setting then Exit;
  //if (path[length(path)]='\') and  not Setting then path:=Copy(path,1,Length(path)-1);
  //if (path[length(path)]<>'\') and  Setting then path:=path+'\';
  //end;
  //end;
begin
  Result := 0;
  if not DirectoryExists(StrPas(dir)) then Exit;
  if not Assigned(strl)then
    Exit;
  Str := SetTailBackSlash(StrPas(dir));
  if FindFirst(Str + '*.*', faAnyFile, FSR)= 0 then
  begin
    try
      if(FSR.Name <> '.')and(FSR.Name <> '..')and
        (FSR.Attr and faDirectory <> 0)then
        strl.Add(Str + FSR.Name);
      while FindNext(FSR)= 0 do
        if(FSR.Name <> '.')and(FSR.Name <> '..')and
          (FSR.Attr and faDirectory <> 0)then
          strl.Add(Str + FSR.Name);
    finally
      FindClose(FSR);
    end;
  end;
  Result := strl.Count;
end;

(*Получение всех папок из определенной в dir папке файлов*)
function GetAllFoldersThree(const dir: PChar;var strl: TStringList): integer;
var
  sda: TStringDynArray;
  cnt: integer;
begin
  Result := 0;
  if not DirectoryExists(StrPas(dir)) then Exit;
  if not Assigned(strl)then
    Exit;
  GetAllFoldersRecur(StrPas(dir), sda);
  try
    strl.Clear;
    for cnt := 0 to High(sda)do
      strl.Add(sda[cnt]);
  finally
    SetLength(sda, 0);
  end;
  Result := strl.Count;
end;


function GetAllFoldersThreeEx(const dir: string): string;
var
 FL : TFolderTreeList;
begin
Result:=dir;
try
if FL.Fill(dir)>-1
   then Result:=FL.GetTreeText;
finally
FL.Clear;
end;
end;

function FolderIsEmpty(const dir:string): boolean;
const
  Mask:string = '*.*';
var
  FSR: TSearchRec;
  Str: string;
begin
Result :=false;
if not DirectoryExists(dir) then Exit;
Str := GetLongPath(SetTailBackSlash(dir))+ Mask;
FillChar(FSR, SizeOf(TSearchRec), 0);
if FindFirst(Str, faDirectory, FSR)= 0 then
  begin
  try
  while FindNext(FSR)= 0 do
    if(FSR.Name <> '.')and(FSR.Name <> '..')
       then Exit;
  finally
  FindClose(FSR);
  end;
  end;
Result := True;
end;


function GetDiskType(const aDisk : string) : integer;
//drvTypes : array[0..5] of string = ('Unknown','Removable','Fixed','Network','CD-ROM','RAM Disk');
var //https://msdn.microsoft.com/en-us/library/bstcxhf7(v=vs.84).aspx
 FSO : variant;  // https://msdn.microsoft.com/en-us/library/z9ty6h50(v=vs.84).aspx
 drv : variant;  // https://msdn.microsoft.com/en-us/library/ts2t8ybh(v=vs.84).aspx
begin
Result:=0;
if aDisk='' then Exit;
try
CoInitialize(nil);
FSO:=CreateOleObject('Scripting.FileSystemObject');
try
if VarType(FSO)=VarDispatch
   then
   try
   drv:=FSO.GetDrive(AnsiUpperCase(aDisk)[1]+':\');
   if VarType(FSO)=VarDispatch
         then Result    := integer(drv.DriveType);
   except
   on E : Exception do ;
   end;
finally
drv:=null;
FSO:=null;
CoUninitialize;
end;
except
on E : Exception do ;
end;
end;


function GetDiskShareName(const aDisk : string) : string;
//drvTypes : array[0..5] of string = ('Unknown','Removable','Fixed','Network','CD-ROM','RAM Disk');
var //https://msdn.microsoft.com/en-us/library/bstcxhf7(v=vs.84).aspx
 FSO : variant;  // https://msdn.microsoft.com/en-us/library/z9ty6h50(v=vs.84).aspx
 drv : variant;  // https://msdn.microsoft.com/en-us/library/ts2t8ybh(v=vs.84).aspx
begin
Result:=aDisk;
if aDisk='' then Exit;
try
CoInitialize(nil);
FSO:=CreateOleObject('Scripting.FileSystemObject');
try
if VarType(FSO)=VarDispatch
   then
   try
   drv:=FSO.GetDrive(AnsiUpperCase(aDisk)[1]+':\');
   if VarType(FSO)=VarDispatch
         then Result := string(drv.ShareName);
   except
   on E : Exception do ;
   end;
finally
drv:=null;
FSO:=null;
CoUninitialize;
end;
except
on E : Exception do ;
end;
end;


function SetVolumeLabelEx(lpRootPathName: PWideChar; lpVolumeName: PWideChar) : integer;
const
 key = '\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\';
var
 RegShareName : string;
 DiskType     : integer;
 RegKey       : TRegistry;
 DiskKey      : string;
begin
Result:=0;
//DiskType:=-1;
try
DiskType:=GetDiskType(StrPas(lpRootPathName));
case DiskType of
1,2 :  // 'Removable','Fixed'
  begin
  SetLastError(0);
  if not SetVolumeLabel(lpRootPathName,lpVolumeName)
     then Result:=GetlastError;
  end;
3   : // 'Network'
  begin
  RegShareName:=GetDiskShareName(StrPas(lpRootPathName));
  if RegShareName<>StrPas(lpRootPathName)
     then RegShareName:=StringReplace(RegShareName,'\','#',[rfReplaceAll])
     else Exit;
  RegKey:=TRegistry.Create;
  try
  RegKey.RootKey:=HKEY_CURRENT_USER;
  DiskKey:=key+RegShareName;
  if  not RegKey.KeyExists(DiskKey)                   // -- не существует или ...
   or not RegKey.OpenKey(DiskKey, false)              // -- не может быть открыт на запись или ...
   or not RegKey.ValueExists('_LabelFromDesktopINI')  // -- нет параметра
     then Exit;
  RegKey.WriteString('_LabelFromDesktopINI', StrPas(lpVolumeName));
  RegKey.CloseKey;
  finally
  RegKey.Free;
  end;
  end;
end;
except
 on E : Exception do ;//LogErrorMessage('SetVolumeLabelEx',E,[StrPas(lpRootPathName), StrPas(lpVolumeName), DiskType]);
end;
end;

function CheckNetWorkDisk(const aDrive, aPath, aLogin, aPassword, aVolumeName : string) : boolean;
var
  NR  : TNetResource;
  res : dword;
  msg : string;
begin
with NR do
  begin
  dwType := RESOURCETYPE_DISK;
  lpLocalName := PChar(aDrive);
  lpRemoteName:=PChar(aPath);
  dwScope:=RESOURCE_REMEMBERED or RESOURCE_CONNECTED;
  dwDisplayType:=RESOURCEDISPLAYTYPE_SHARE;
  dwUsage:=0;
  lpComment:=PChar(aVolumeName);
  lpProvider:=nil;
  end;
res:=WNetAddConnection2(NR, PChar(aPassword), PChar(aLogin), CONNECT_UPDATE_PROFILE or CONNECT_REDIRECT);
Result:=(res = NO_ERROR) or (res = ERROR_ALREADY_ASSIGNED);
if Result
   then begin
   res:=dword(SetVolumeLabelEx(PChar('Y:\'), PChar(aVolumeName)));
   if res<>0 then ShowMessageInfo(GetErrorString(res));
   end
   else begin
   case res of
   ERROR_ACCESS_DENIED             : msg:='The caller does not have access to the network resource.';
   ERROR_ALREADY_ASSIGNED          : msg:='The local device specified by the lpLocalName member is already connected to a network resource.';
   ERROR_BAD_DEV_TYPE              : msg:='The type of local device and the type of network resource do not match.';
   ERROR_BAD_DEVICE                : msg:='The specified device name is not valid. This error is returned if the lpLocalName member of the NETRESOURCE structure pointed to by the lpNetResource parameter specifies a device that is not redirectable.';
   ERROR_BAD_NET_NAME              : msg:='The network name cannot be found. This value is returned if the lpRemoteName member of the NETRESOURCE structure pointed to by the '+'lpNetResource parameter specifies a resource that is not acceptable to any network resource provider, either because the resource name is empty, not valid, or because the named resource cannot be located.';
   ERROR_BAD_PROFILE               : msg:='The user profile is in an incorrect format.';
   ERROR_BAD_PROVIDER              : msg:='The specified network provider name is not valid. This error is returned if the lpProvider member of the NETRESOURCE structure pointed to by the lpNetResource parameter specifies a value that does not match any network provider.';
   ERROR_BAD_USERNAME              : msg:='The specified user name is not valid.';
   ERROR_BUSY                      : msg:='The router or provider is busy, possibly initializing. The caller should retry.';
   ERROR_CANCELLED                 : msg:='The attempt to make the connection was canceled by the user through a dialog box from one of the network resource providers, or by a called resource.';
   ERROR_CANNOT_OPEN_PROFILE       : msg:='The system is unable to open the user profile to process persistent connections.';
   ERROR_DEVICE_ALREADY_REMEMBERED : msg:='The local device name has a remembered connection to another network resource. This error is returned if an entry for the device specified by '+'lpLocalName member of the NETRESOURCE structure pointed to by the lpNetResource parameter specifies a value that is already in the user profile for a different connection than that specified in the lpNetResource parameter.';
   ERROR_EXTENDED_ERROR            : msg:='A network-specific error occurred. Call the WNetGetLastError function to obtain a description of the error.';
   ERROR_INVALID_ADDRESS           : msg:='An attempt was made to access an invalid address. This error is returned if the dwFlags parameter specifies a value of CONNECT_REDIRECT, but the lpLocalName member of the NETRESOURCE structure pointed to by the lpNetResource parameter was unspecified.';
   ERROR_INVALID_PARAMETER         : msg:='A parameter is incorrect. This error is returned if the dwType member of the NETRESOURCE structure pointed to by the '+'lpNetResource parameter specifies a value other than RESOURCETYPE_DISK, RESOURCETYPE_PRINT, or RESOURCETYPE_ANY. This error is also returned if the dwFlags parameter specifies an incorrect or unknown value.';
   ERROR_INVALID_PASSWORD          : msg:='The specified password is invalid and the CONNECT_INTERACTIVE flag is not set.';
   ERROR_LOGON_FAILURE             : msg:='A logon failure because of an unknown user name or a bad password.';
   ERROR_NO_NET_OR_BAD_PATH        : msg:='No network provider accepted the given network path. This error is returned if no network provider recognized the lpRemoteName member of the NETRESOURCE structure pointed to by the lpNetResource parameter.';
   ERROR_NO_NETWORK                : msg:='The network is unavailable.';
   end;
   raise Exception.Create(msg);
   end;
end;


function JSON_GetValueObject(obj : TJSONObject; const tag : string) : TJSONValue; inline;
var
  jsPair  : TJSONPair;
begin
Result:=nil;
jsPair:=obj.Get(tag);
if not Assigned(jsPair) then Exit;
Result:=TJSONObject(jsPair.JsonValue);
end;

function JSON_GetValue(obj : TJSONObject; const tag : string; var value : integer) : boolean;  overload;
var
 jsValue : TJSONValue;
begin
Result:=false;
jsValue:=JSON_GetValueObject(obj,tag);
if Assigned(jsValue) and not jsValue.Null
   then begin
   value:=StrToIntDef(jsValue.Value,0);
   Result:=true;
   end
end;

function JSON_GetValue(obj : TJSONObject; const tag : string; var value : string) : boolean;
var
 jsValue : TJSONValue;
begin
Result:=false;
jsValue:=JSON_GetValueObject(obj,tag);
if Assigned(jsValue) and not jsValue.Null
   then begin
   value:=jsValue.Value;
   Result:=true;
   end
end;



procedure XML2String(const aXMLFileNameOrXMLBody:string ; var aResult  : string);
const
  NameValueDelimiter = BulletChar;
  AttrDelimiter      = DaggerChar;
var
 aTreeView: TTreeView;

  procedure FillDOMNode(aTVParent: TTreeNode; aDOMParent: IDOMNode);
  const
    attrshbl:string = '%s'+NameValueDelimiter+'%s'+AttrDelimiter;
  var
    DOM: IDOMNode;
    Node: TTreeNode;
    cnt: integer;
    Attr:string;
  begin
    DOM := aDOMParent.firstChild;
    while Assigned(DOM)do
    begin
      Attr := '';
      if Assigned(DOM.attributes)and(DOM.attributes.Length > 0)then
      begin
        for cnt := 0 to DOM.attributes.Length - 1 do
          Attr := Attr + Format(attrshbl,[DOM.attributes.Item[cnt].localName,
            DOM.attributes.Item[cnt].nodeValue]);
        Attr := ' [' + Copy(Attr, 1, Length(Attr)- 1)+ ']';
      end;
      Node := aTVParent;
      if DOM.localName = ''
         then Node.Text := Node.Text + ' '+DupeString(NameValueDelimiter,integer(DOM.nodeValue <> ''))+ DOM.nodeValue + Attr
         else Node := aTreeView.Items.AddChild(aTVParent, DOM.localName + DupeString(NameValueDelimiter, integer(DOM.nodeValue <> ''))+ DOM.nodeValue + Attr);
      FillDOMNode(Node, DOM);
      DOM := DOM.nextSibling;
    end;
  end;

var
  XML    : TXMLDocument;
  DOMNode: IDOMNode;
  TVNode : TTreeNode;
  ms     : TMemoryStream;
  buf    : PAnsiChar;
  F : TForm;
begin
  XML := TXMLDocument.Create(nil);
  F:=TForm.CreateNew(nil);
  F.Visible:=false;
  aTreeView:=TTreeView.Create(nil);
  try
  aTreeView.Parent:=F;
  aTreeView.Items.BeginUpdate;
  try
    aTreeView.Items.Clear;
    if FileExists(aXMLFileNameOrXMLBody)
       then XML.LoadFromFile(aXMLFileNameOrXMLBody)
       else XML.LoadFromXML(aXMLFileNameOrXMLBody);
    DOMNode := XML.DOMDocument.firstChild;
    while Assigned(DOMNode)do
      begin
      TVNode := aTreeView.Items.Add(nil, DOMNode.localName +
        DupeString(NameValueDelimiter, integer(DOMNode.nodeValue <> ''))+
        DOMNode.nodeValue);
      FillDOMNode(TVNode, DOMNode);
      DOMNode := DOMNode.nextSibling;
    end;
  finally
  aTreeView.Items.EndUpdate;
  end;
  ms:=TMemoryStream.Create;
  try
  aTreeView.SaveToStream(ms);
  ms.Position:=0;
  buf:=AllocMem(ms.Size+1);
  try
  ms.Read(buf^,ms.Size);
  aResult:=trim(string(StrPas(buf)));
  finally
  FreeMem(buf);
  end;
  finally
  ms.Free;
  end;
  finally
  aTreeView.Free;
  F.Free;
  FreeAndNil(XML);
  end;
end;


function ExtractTagStrings(const aXMLBody, aTag : string; var aRes : TStringDynArray) : boolean;
var
 tmp  :string;
 res : TStringDynArray;
 tst : string ;
 cnt : integer;
 ind : integer;
begin
Result:=False;
//SetLength(aRes,0);
XML2String(aXMLBody, tmp);
if tmp='' then Exit;
tmp:=StringReplace(tmp,#9,'',[rfReplaceAll]);
tmp:=StringReplace(tmp,crlf,cr,[rfReplaceAll]);
res:=SplitString(tmp,cr);
tst:=AnsiUppercase(aTag+' ');
for cnt:=0 to High(res)
  do begin
  if (AnsiPos(tst,AnsiUppercase(res[cnt]))=1) or (trim(tst) = AnsiUppercase(res[cnt]))
     then begin
     ind:=Length(aRes);
     SetLength(aRes,ind+1);
     aRes[ind]:=res[cnt];
     end;
  end;
SetLength(res,0);
Result:=true;
end;

function ExtractTagBody(const aXMLBody, aTag : string; var aRes : TStringDynArray) : boolean;
var
 tmp    : string;
 res    : TStringDynArray;
 tst    : string ;
 cnt    : integer;
 ind    : integer;
 start  : array of integer;
 finish : integer;
 cntR   : integer;
begin
Result:=False;
//SetLength(aRes,0);
XML2String(aXMLBody, tmp);
if tmp='' then Exit;
tmp:=StringReplace(tmp,#9,'',[rfReplaceAll]);
tmp:=StringReplace(tmp,crlf,cr,[rfReplaceAll]);
res:=SplitString(tmp,cr);
tst:=AnsiUppercase(aTag+' ');
SetLength(start,0);
for cnt:=0 to High(res)
  do begin
  if (AnsiPos(tst,AnsiUppercase(res[cnt]))=1) or (trim(tst) = AnsiUppercase(res[cnt]))
     then begin
     ind:=Length(start);
     SetLength(start,ind+1);
     start[ind]:=cnt;
     end
  end;

for cnt:=0 to High(start)
  do begin
  if cnt<High(start)
    then finish:=start[cnt+1]
    else finish:=High(res);
  tmp:='';
  for cntR:=start[cnt] to finish
    do tmp:=tmp+res[cntR]+crlf;
  ind:=Length(aRes);
  SetLength(aRes,ind+1);
  aRes[ind]:=tmp;
  end;

SetLength(res,0);
Result:=true;
end;


(* Получение списка значений из XML строки типа <T A="" B=""></T> ----------- *)
function GetXMLTagAttributes(const aTagRow : string; var aAttr : TStringDynArray) : boolean;
var
 XML     : TXMLDocument;
 DOMNode : IDOMNode;
 cntA    : integer;
 ind     : integer;
begin
Result:=False;
XML:=TXMLDocument.Create(nil);
try
XML.LoadFromXML(aTagRow);
DOMNode := XML.DOMDocument.firstChild;
if Assigned(DOMNode)
   then begin
   if DOMNode.attributes.length>0
      then begin
      SetLength(aAttr,DOMNode.attributes.length);
      ind:=0;
      for cntA:=0 to DOMNode.attributes.length-1
          do begin
          with DOMNode.attributes.item[cntA]
            do begin
            aAttr[cntA]:=localName+DaggerChar+nodeValue;
            inc(ind);
            end;
          end;
      Result:=DOMNode.attributes.length = ind;
      end;
     end;
finally
FreeAndNil(XML);
end;
end;



  function FindDOMNode(aDOMParent: IDOMNode; var Node :IDOMNode; const Tag : string) : boolean;
  var
    DOM: IDOMNode;
  begin
  Result:=True;
  if aDOMParent.nodeName=Tag
     then begin
     Node:=aDOMParent;
     Exit;
     end;
  Result:=false;
  if not aDOMParent.hasChildNodes
     then Exit;
  DOM := aDOMParent.firstChild;
  while Assigned(DOM)do
     begin
     if not FindDOMNode(DOM,Node,Tag)
        then DOM := DOM.nextSibling
        else begin
        Result:=true;
        Node:=DOM;
        Exit;
        end;
     end;
  end;

  function GetNode(base : IDOMNode; const Tag : string) : IDOMNode;
  var
   tst : IDOMNode;
  begin
  Result:=base;
  if Assigned(Result) and (Result.nodeName=Tag) then Exit;
  while Assigned(Result)
    do begin
    if FindDOMNode(Result,tst,Tag)
       then begin
       Result:=tst;
       Exit;
       end;
    Result:=Result.nextSibling;
    end;
  end;

function GetXMLTagValues(const XMLBody, Tag : string; var Values : TStringDynArray) : boolean;
var
 XML      : TXMLDocument;
 DOMNode  : IDOMNode;
 ind      : integer;
begin
Result:=False;
XML:=TXMLDocument.Create(nil);
try
XML.LoadFromXML(XMLBody);
DOMNode:=GetNode(XML.DOMDocument.firstChild, Tag);
if not Assigned(DOMNode)
   then Exit;
if Assigned(DOMNode) and (DOMNode.nodeName=Tag)
   then while Assigned(DOMNode) do
          begin
          ind:=Length(Values);
          SetLength(values,ind+1);
          Values[ind]:=GetNodevalue(DOMNode);
          DOMNode:=DOMNode.nextSibling;
          end;
finally
FreeAndNil(XML);
end;
end;

function GetNodeValue(aNode : IDOMNode) : string;
var
cntA    : integer;
ind     : integer;
aAttr   : TStringDynArray ;
ok      : boolean;
node    : IDOMNode;
nName   : string;
begin
if Assigned(aNode)
   then begin
   if Assigned(aNode.attributes) and (aNode.attributes.length>0)
      then begin
      SetLength(aAttr,aNode.attributes.length);
      ind:=0;
      for cntA:=0 to aNode.attributes.length-1
        do begin
        with aNode.attributes.item[cntA]
          do begin
          if localName<>''
             then aAttr[cntA]:=localName+DaggerChar+nodeValue
             else aAttr[cntA]:=nodeValue;
          inc(ind);
          end;
      end;
      ok:=aNode.attributes.length = ind;
      if ok
         then begin
         Result:='';
         for cntA:=0 to High(aAttr)
            do Result:=Result+aAttr[cntA]+IfThen(cntA<High(aAttr),'|');
         end;
      end
      else begin
       case aNode.nodeType of
       TEXT_NODE  : Result:=aNode.nodeValue;// The content of the text node.
       else begin
       Result:='';
       node:=aNode.firstChild;
       while Assigned(node) do
         begin
         nName:=node.localName;
         if nName<>''
            then Result:=Result+nName+DaggerChar+GetNodeValue(node)
            else Result:=Result+GetNodeValue(node);
         node:=node.nextSibling;
         if Assigned(node) then Result:=Result+'|';
         end;
       end; // case.else
       end; // case
      end;
   end;
end;

(*Загрузка TTreeView из файла или содержимого XML --------------------------*)
procedure FillTreeViewFromXML(const aXMLFileNameOrXMLBody:string;  aTreeView: TTreeView);
const
  NameValueDelimiter: char = ':';
  procedure FillDOMNode(aTVParent: TTreeNode; aDOMParent: IDOMNode);
  const
    attrshbl:string = '%s:"%s";';
  var
    DOM: IDOMNode;
    Node: TTreeNode;
    cnt: integer;
    Attr:string;
  begin
    DOM := aDOMParent.firstChild;
    while Assigned(DOM)do
    begin
      Attr := '';
      if Assigned(DOM.attributes)and(DOM.attributes.Length > 0)then
      begin
        for cnt := 0 to DOM.attributes.Length - 1 do
          Attr := Attr + Format(attrshbl,[DOM.attributes.Item[cnt].localName,
            DOM.attributes.Item[cnt].nodeValue]);
        Attr := ' [' + Copy(Attr, 1, Length(Attr)- 1)+ ']';
      end;
      Node := aTVParent;
      if DOM.localName = '' then
        Node.Text := Node.Text + DupeString(NameValueDelimiter,
          integer(DOM.nodeValue <> ''))+ DOM.nodeValue + Attr
      else
        Node := aTreeView.Items.AddChild(aTVParent,
          DOM.localName + DupeString(NameValueDelimiter,
          integer(DOM.nodeValue <> ''))+ DOM.nodeValue + Attr);
      //if DOM.localName=''
      //then Node.Text:=Node.Text+NameValueDelimiter+DOM.nodeValue+attr
      //else Node:=aTreeView.Items.AddChild(aTVParent,DOM.localName+NameValueDelimiter+DOM.nodeValue+attr);
      FillDOMNode(Node, DOM);
      DOM := DOM.nextSibling;
    end;
  end;

var
  XML: TXMLDocument;
  DOMNode: IDOMNode;
  TVNode: TTreeNode;
begin
  XML := TXMLDocument.Create(nil);
  aTreeView.Items.BeginUpdate;
  try
    aTreeView.Items.Clear;
    if FileExists(aXMLFileNameOrXMLBody)then
    begin
      XML.LoadFromFile(aXMLFileNameOrXMLBody);
      TXMLForm(aTreeView.Parent).SourceXMLFile := aXMLFileNameOrXMLBody;
    end
    else
    begin
      //XML.LoadFromXML(StringReplace(aXMLFileNameOrXMLBody,'%','*',[rfReplaceAll]));
      XML.LoadFromXML(aXMLFileNameOrXMLBody);
      TXMLForm(aTreeView.Parent).SourceXMLFile := '';
    end;
    TXMLForm(aTreeView.Parent).SourceXMLText := XML.XML.Text;
    DOMNode := XML.DOMDocument.firstChild;
    while Assigned(DOMNode)do
    begin
      TVNode := aTreeView.Items.Add(nil, DOMNode.localName +
        DupeString(NameValueDelimiter, integer(DOMNode.nodeValue <> ''))+
        DOMNode.nodeValue);
      FillDOMNode(TVNode, DOMNode);
      DOMNode := DOMNode.nextSibling;
    end;
  finally
    FreeAndNil(XML);
    aTreeView.Items.EndUpdate;
  end;
end;

procedure FillTreeViewFromXML(const aXMLFileNameOrXMLBody:string; const ERP : TEngRusPairs;  aTreeView: TTreeView);
const
  NameValueDelimiter: char = ':';
  function GetxmlFieldRus(const EngName : string) : string;
  var
  cnt : integer;
  begin
  for cnt:=0 to High(ERP)
    do if ERP[cnt,lerEng]=EngName
          then begin
          Result:=ERP[cnt,lerRus];
          Exit;
          end;
  Result:=EngName;
  end;



  procedure FillDOMNode(aTVParent: TTreeNode; aDOMParent: IDOMNode);
  const
    attrshbl:string = '%s:"%s";';
  var
    DOM: IDOMNode;
    Node: TTreeNode;
    cnt: integer;
    Attr:string;
  begin
    DOM := aDOMParent.firstChild;
    while Assigned(DOM)do
    begin
      Attr := '';
      if Assigned(DOM.attributes)and(DOM.attributes.Length > 0)then
      begin
        for cnt := 0 to DOM.attributes.Length - 1 do
          Attr := Attr + Format(attrshbl,[DOM.attributes.Item[cnt].localName,
            DOM.attributes.Item[cnt].nodeValue]);
        Attr := ' [' + Copy(Attr, 1, Length(Attr)- 1)+ ']';
      end;
      Node := aTVParent;
      if DOM.localName = '' then
        Node.Text := Node.Text + DupeString(NameValueDelimiter,
          integer(DOM.nodeValue <> ''))+ DOM.nodeValue + Attr
      else
        Node := aTreeView.Items.AddChild(aTVParent,
          GetxmlFieldRus(DOM.localName) + DupeString(NameValueDelimiter, integer(DOM.nodeValue <> ''))+ DOM.nodeValue + Attr);
      //if DOM.localName=''
      //then Node.Text:=Node.Text+NameValueDelimiter+DOM.nodeValue+attr
      //else Node:=aTreeView.Items.AddChild(aTVParent,DOM.localName+NameValueDelimiter+DOM.nodeValue+attr);
      FillDOMNode(Node, DOM);
      DOM := DOM.nextSibling;
    end;
  end;

var
  XML: TXMLDocument;
  DOMNode: IDOMNode;
  TVNode: TTreeNode;
begin
  XML := TXMLDocument.Create(nil);
  aTreeView.Items.BeginUpdate;
  try
    aTreeView.Items.Clear;
    if FileExists(aXMLFileNameOrXMLBody)then
    begin
      XML.LoadFromFile(aXMLFileNameOrXMLBody);
      TXMLForm(aTreeView.Parent).SourceXMLFile := aXMLFileNameOrXMLBody;
    end
    else
    begin
      //XML.LoadFromXML(StringReplace(aXMLFileNameOrXMLBody,'%','*',[rfReplaceAll]));
      XML.LoadFromXML(aXMLFileNameOrXMLBody);
      TXMLForm(aTreeView.Parent).SourceXMLFile := '';
    end;
    TXMLForm(aTreeView.Parent).SourceXMLText := XML.XML.Text;
    DOMNode := XML.DOMDocument.firstChild;
    while Assigned(DOMNode)do
    begin
      TVNode := aTreeView.Items.Add(nil,  GetxmlFieldRus(DOMNode.localName) +
        DupeString(NameValueDelimiter, integer(DOMNode.nodeValue <> ''))+
        DOMNode.nodeValue);
      FillDOMNode(TVNode, DOMNode);
      DOMNode := DOMNode.nextSibling;
    end;
  finally
    FreeAndNil(XML);
    aTreeView.Items.EndUpdate;
  end;
end;


(*Отображение результатов выполнения скриптов в формате XML ******************)
function TreeToPlainList(aTV : TTreeView) : string;
const dlmNode : array[0..1] of ansichar = (':',' ');
  function GetNodeName(aNode : TTreeNode)  :string;
  var
   cnt : integer;
  begin
  Result:='';
  if not Assigned(aNode) then Exit;
  Result:=aNode.Text;
  for cnt:=0 to High(dlmNode)
    do if Pos(char(dlmNode[cnt]), Result)>1
          then begin
          Result:=SplitString(Result,char(dlmNode[cnt]))[0];
          Exit;
          end
  end;

  function GetChain(aNode : TTreeNode) : string;
  var
   N : TTreeNode;
  begin
  N:=aNode;
  Result:='';
  if not Assigned(N) then Exit;
  Result:=N.Text;
  N:=N.Parent;
  while Assigned(N)
    do begin
    Result:=GetNodeName(N)+'.'+Result;
    N:=N.Parent;
    end;
  end;

var
 cntN : integer;
begin
Result:='';
for cntN:=0 to aTV.Items.Count-1
  do Result:=Result+GetChain(aTV.Items[cntN])+crlf;

end;


procedure TXMLForm.ProcessTreeViewText(Sender: TObject);
const
  Tab = #9;
var
  SD: TSaveDialog;
  //wnd : cardinal;
  res:string;
  cnt: integer;
begin
  res := '';
  for cnt := 0 to _TV.Items.Count - 1 do
    if _TV.Items[cnt].Level > 0 then
      res := res + DupeString(Tab, _TV.Items[cnt].Level)+ _TV.Items[cnt]
        .Text + crlf
    else
      res := res + _TV.Items[cnt].Text + crlf;
  if Sender=_TV
     then begin
     if Assigned(_TV.Selected)
        then begin
        res:=_TV.Selected.Text;
        (*check*)CopyStringIntoClipboard(res);
        if Length(res)>100
           then res:=Copy(res,1,100)+ElipBtnChar;
        ShowMessageInfo(Format('Выделенная строка%0:s%1:s%0:sскопирована в буфер обмена',[crlf,AnsiQuotedStr(res,'"')]), self.Caption);
        end;
     end
  else
 if Sender = _SpBL then
  begin
    res:=TreeToPlainList(_TV);
    (*check*)CopyStringIntoClipboard(res);
    ShowMessageInfo('Содержимое ("гладкий список") скопировано в буфер обмена', self.Caption);
  end
  else if Sender = _SpBC then
  begin
    (*check*)CopyStringIntoClipboard(res);
    ShowMessageInfo('Содержимое (иерархия [Tab]) скопировано в буфер обмена', self.Caption);
  end
  else if Sender = _SpBT then
  begin
    SD := TSaveDialog.Create(self);
    try
      SD.InitialDir := GetDocFolder;
      SD.Filter := 'Текстовые файлы (*.txt)|*.txt';
      SD.Title := 'Сохранение в файл';
      SD.DefaultExt := 'TXT';
      if SD.Execute//(wnd)
      then
        SaveStringIntoFile(res, SD.FileName);
    finally
      FreeAndNil(SD);
    end;
  end
  else if Sender = _SpBX then
  begin
    SD := TSaveDialog.Create(self);
    try
      SD.InitialDir := GetDocFolder;
      SD.Filter := 'XML файлы (*.xml)|*.xml';
      SD.Title := 'Сохранение в файл';
      SD.DefaultExt := 'XML';
      if SD.Execute//(wnd)
      then
        SaveStringIntoFile(XMLTitleWIN1251 + crlf + self.SourceXMLText,
          SD.FileName);
    finally
      FreeAndNil(SD);
    end;
  end;
end;

procedure ShowXMLTreeView(const aTitle, aXMLFileOrBody:string;
  const aCFGName:string = '');
var
  F: TXMLForm;
  cfg:string;
begin
  if aCFGName = '' then
    cfg := ChangeFileExt(ParamStr(0), '.ini')
  else
    cfg := aCFGName;
  F := TXMLForm.CreateNew(Application);
  F._TV := TTreeView.Create(F);
  F._SpBT := TSpeedButton.Create(F);
  F._SpBX := TSpeedButton.Create(F);
  F._SpBC := TSpeedButton.Create(F);
  F._SpBL := TSpeedButton.Create(F);
  F.Btn := TButton.Create(F);
  try
    with F do
    begin
      if aTitle = '' then
        Caption := 'Отображение результатов....'
      else
        Caption := 'Отображение результатов [' + aTitle + ']';
      Name := '_Form_TV_XML';
      //BorderStyle:=bsSizeToolWin;
      Position := poMainFormCenter;
    end;
    with F._TV do
    begin
      Parent := F;
      //Align:=alClient;
      onDblClick := F.ProcessTreeViewText;
      ToolTips := false;
      ReadOnly := true;
      Align := alNone;
      Top := 30;
      height := Parent.ClientHeight - Top - 2 - F.Btn.height - 2;
      Left := 2;
      Width := Parent.ClientWidth - Left * 2;
      Anchors :=[akLeft, akTop, akRight, akBottom];
      TabOrder := 0;
      ReadOnly := true;
    end;
    with F._SpBT do
    begin
      Parent := F;
      onClick := F.ProcessTreeViewText;
      Left := 2;
      Top := 2;
      Width := 25;
      height := 25;
      Hint := 'Сохранение в текстовый файл';
      ShowHint := true;
      Caption := 'txt';
    end;
    with F._SpBX do
    begin
      Parent := F;
      onClick := F.ProcessTreeViewText;
      Left := F._SpBT.Left + F._SpBT.Width + 1;;
      Top := 2;
      Width := 25;
      height := 25;
      Hint := 'Сохранение в файл XML';
      ShowHint := true;
      Caption := 'xml';
    end;
    with F._SpBC do
    begin
      Parent := F;
      onClick := F.ProcessTreeViewText;
      Left := F._SpBX.Left + F._SpBX.Width + 1;
      Top := 2;
      Width := 25;
      height := 25;
      Hint := 'Копирование в буфер (текст-иерархия)';
      ShowHint := true;
      Caption := 'clip';
    end;
    with F._SpBL do
    begin
      Parent := F;
      onClick := F.ProcessTreeViewText;
      Left := F._SpBC.Left + F._SpBC.Width + 1;
      Top := 2;
      Width := 25;
      height := 25;
      Hint := 'Копирование в буфер ("гладкий" текст)';
      ShowHint := true;
      Caption := 'list';
    end;
    with F.Btn do
    begin
      Parent := F;
      Top := Parent.ClientHeight - height - 4;//TV.Top+TV.Height+4;
      Left := F._TV.Left;
      Width := F._TV.Width;
      Anchors :=[akLeft, akRight, akBottom];
      ModalResult := mrCancel;
      Caption := 'Закрыть';
    end;
    F.SourceXMLFile := '';
    F.SourceXMLText := '';
    if not FileExists(aXMLFileOrBody)and(Pos('<?', aXMLFileOrBody)= 0)then
      FillTreeViewFromXML('<RESULT>' + crlf + Trim(aXMLFileOrBody)+ crlf +
        '</RESULT>', F._TV)
    else
      FillTreeViewFromXML(aXMLFileOrBody, F._TV);
    F._TV.FullExpand;
    F._TV.Select(F._TV.Items[0]);
    try
      RestorePosition(F, cfg);
    except
    end;
    F.ShowModal;
    try
      SavePosition(F, cfg);
    except
    end;

  finally
    //_TV.Free;
    //_SpBT.Free;
    //_SpBX.Free;
    //_SpBC.Free;
    F.SourceXMLFile := '';
    F.SourceXMLText := '';
    FreeAndNil(F);
  end;
end;

procedure ShowXMLTreeView(const aTitle, aXMLFileOrBody:string; const ERP : TEngRusPairs; const aCFGName:string = '');
var
  F: TXMLForm;
  cfg:string;
begin
  if aCFGName = '' then
    cfg := ChangeFileExt(ParamStr(0), '.ini')
  else
    cfg := aCFGName;
  F := TXMLForm.CreateNew(Application);
  F._TV := TTreeView.Create(F);
  F._SpBT := TSpeedButton.Create(F);
  F._SpBX := TSpeedButton.Create(F);
  F._SpBC := TSpeedButton.Create(F);
  F._SpBL := TSpeedButton.Create(F);
  F.Btn := TButton.Create(F);
  try
    with F do
    begin
      if aTitle = '' then
        Caption := 'Отображение результатов....'
      else
        Caption := 'Отображение результатов [' + aTitle + ']';
      Name := '_Form_TV_XML';
      //BorderStyle:=bsSizeToolWin;
      Position := poMainFormCenter;
    end;
    with F._TV do
    begin
      Parent := F;
      //Align:=alClient;
      onDblClick := F.ProcessTreeViewText;
      ToolTips := false;
      ReadOnly := true;
      Align := alNone;
      Top := 30;
      height := Parent.ClientHeight - Top - 2 - F.Btn.height - 2;
      Left := 2;
      Width := Parent.ClientWidth - Left * 2;
      Anchors :=[akLeft, akTop, akRight, akBottom];
      TabOrder := 0;
      ReadOnly := true;
    end;
    with F._SpBT do
    begin
      Parent := F;
      onClick := F.ProcessTreeViewText;
      Left := 2;
      Top := 2;
      Width := 25;
      height := 25;
      Hint := 'Сохранение в текстовый файл';
      ShowHint := true;
      Caption := 'txt';
    end;
    with F._SpBX do
    begin
      Parent := F;
      onClick := F.ProcessTreeViewText;
      Left := F._SpBT.Left + F._SpBT.Width + 1;;
      Top := 2;
      Width := 25;
      height := 25;
      Hint := 'Сохранение в файл XML';
      ShowHint := true;
      Caption := 'xml';
    end;
    with F._SpBC do
    begin
      Parent := F;
      onClick := F.ProcessTreeViewText;
      Left := F._SpBX.Left + F._SpBX.Width + 1;
      Top := 2;
      Width := 25;
      height := 25;
      Hint := 'Копирование в буфер (текст-иерархия)';
      ShowHint := true;
      Caption := 'clip';
    end;
    with F._SpBL do
    begin
      Parent := F;
      onClick := F.ProcessTreeViewText;
      Left := F._SpBC.Left + F._SpBC.Width + 1;
      Top := 2;
      Width := 25;
      height := 25;
      Hint := 'Копирование в буфер ("гладкий" текст)';
      ShowHint := true;
      Caption := 'list';
    end;
    with F.Btn do
    begin
      Parent := F;
      Top := Parent.ClientHeight - height - 4;//TV.Top+TV.Height+4;
      Left := F._TV.Left;
      Width := F._TV.Width;
      Anchors :=[akLeft, akRight, akBottom];
      ModalResult := mrCancel;
      Caption := 'Закрыть';
    end;
    F.SourceXMLFile := '';
    F.SourceXMLText := '';
    if not FileExists(aXMLFileOrBody)and(Pos('<?', aXMLFileOrBody)= 0)
       then FillTreeViewFromXML('<RESULT>' + crlf + Trim(aXMLFileOrBody)+ crlf + '</RESULT>', ERP, F._TV)
       else FillTreeViewFromXML(aXMLFileOrBody, ERP, F._TV);
    F._TV.FullExpand;
    F._TV.Select(F._TV.Items[0]);
    try
      RestorePosition(F, cfg);
    except
    end;
    F.ShowModal;
    try
      SavePosition(F, cfg);
    except
    end;

  finally
    //_TV.Free;
    //_SpBT.Free;
    //_SpBX.Free;
    //_SpBC.Free;
    F.SourceXMLFile := '';
    F.SourceXMLText := '';
    FreeAndNil(F);
  end;
end;


//-- для однообразности --
procedure ShowXMLInTreeView(const aTitle, aXMLFileOrBody:string; const aCFGName:string = '');
begin
  ShowXMLTreeView(aTitle, aXMLFileOrBody, aCFGName);
end;

procedure ShowXMLInTreeView(const aTitle, aXMLFileOrBody:string; const ERP : TEngRusPairs ;const aCFGName:string = '');
begin
  ShowXMLTreeView(aTitle, aXMLFileOrBody, ERP, aCFGName);
end;

procedure FillTreeView(aTV: TTreeView;const Value:string);
var
  ms: TMemoryStream;
  buf: PAnsiChar;
  wr: integer;
begin
  ms := TMemoryStream.Create;
  buf := Allocmem(Length(Value)* SizeOfChar + 1);
  try
    StrPCopy(buf, AnsiString(Value));
    wr := Strlen(buf);
    ms.WriteBuffer(buf^, wr);
    ms.Position := 0;
    aTV.LoadFromStream(ms);
  finally
    FreeMem(buf);
    FreeAndNil(ms);
  end;
end;

procedure TTVForm.BtnCopyClick(Sender: TObject);
begin
(*check*)CopyStringIntoClipboard(ValueText);
end;

procedure TTVForm.BtnSaveClick(Sender: TObject);
var
  SD: TSaveDialog;
begin
  SD := TSaveDialog.Create(self);
  try
    with SD do
    begin
      InitialDir := GetDocFolder;
      Filter := 'Текстовые файлы(*.txt)|*.txt';
      if SD.Execute then
      begin
        if ExtractFileExt(SD.FileName)= '' then
          SD.FileName := ChangeFileExt(SD.FileName, '.TXT');
        SaveStringIntoFile(ValueText, SD.FileName);
      end;
    end;
  finally
    FreeAndNil(SD);
  end;
end;

procedure ShowStringInTreeView(const aTitle, Value:string;
  const aCFGName:string = '');
var
  F: TTVForm;
  cfg:string;
begin
  if aCFGName = '' then
    cfg := ChangeFileExt(ParamStr(0), '.ini')
  else
    cfg := aCFGName;
  F := TTVForm.CreateNew(Application);
  try
    with F do
    begin
      ValueText := Value;
      Position := poMainFormCenter;
      BorderStyle := bsSizeToolWin;
      Caption := aTitle;
      height := Screen.height div 5 * 3;
      Name := '_Form_TV_TEXT';
    end;
    F.Btn := TButton.Create(F);
    F.BtnCopy := TButton.Create(F);
    F.BtnSave := TButton.Create(F);
    F.TV := TTreeView.Create(F);

    with F.BtnCopy do
    begin
      Parent := F;
      Top := 2;
      Left := F.TV.Left;
      Anchors :=[akLeft, akTop];
      ModalResult := mrNone;
      Caption := 'Копировать';
      onClick := F.BtnCopyClick;
    end;
    with F.BtnSave do
    begin
      Parent := F;
      Top := 2;
      Left := F.BtnCopy.Left + F.BtnCopy.Width + 2;
      Anchors :=[akLeft, akTop];
      ModalResult := mrNone;
      Caption := 'Сохранить';
      onClick := F.BtnSaveClick;
    end;
    with F.TV do
    begin
      Parent := F;
      Top := 30;
      Left := GetSystemMetrics(SM_CXFRAME);
      Width := Parent.ClientWidth - Left * 2;
      height := Parent.ClientHeight - F.Btn.height -
        GetSystemMetrics(SM_CYFRAME)- 4 - Top;
      Anchors :=[akLeft, akTop, akRight, akBottom];
      TabOrder := 0;
      ReadOnly := true;
    end;
    FillTreeView(F.TV, Value);
    F.TV.FullExpand;
    F.TV.Select(F.TV.Items[0]);
    with F.Btn do
    begin
      Parent := F;
      Top := Parent.ClientHeight - height - 4;//TV.Top+TV.Height+4;
      Left := F.TV.Left;
      Width := F.TV.Width;
      Anchors :=[akLeft, akRight, akBottom];
      ModalResult := mrCancel;
      Caption := 'Закрыть';
    end;
    try
      RestorePosition(F, cfg);
    except
    end;
    F.ShowModal;
    try
      SavePosition(F, cfg);
    except
    end;
  finally
    FreeAndNil(F);
  end;
end;

procedure TRGForm.RGFormResize(Sender: TObject);
var
  hgt: integer;
begin
  hgt := 2;
  with RG do
  begin
    Top := hgt;
    Left := 2;
    Width := Parent.ClientWidth - Left * 2;
    height :=(Items.Count + 1)*(Canvas.TextHeight('|ЙQЩ')+ 4)+ 4;
    hgt := Top + height + 2
  end;
  with ChB do
  begin
    Top := hgt;
    Left := 2;
    Width := Parent.ClientWidth - Left * 2;
    hgt := Top + height + 2;
  end;
  with Btn do
  begin
    Top := hgt;
    Left := 2;
    Width := Parent.ClientWidth - Left * 2;
    hgt := Top + height + 2
  end;
  hgt := hgt + height - ClientHeight;
  if height <> hgt then
    height := hgt;
  RG.Anchors :=[akLeft, akTop, akRight, akBottom];
  ChB.Anchors :=[akLeft, akRight, akBottom];
  Btn.Anchors :=[akLeft, akRight, akBottom];
end;

function ShowRGForm(const aRGTitle:string;const aItems: array of string;
  const aChBTitle:string;var aNeedSave: boolean;
  const aCFGName:string = ''): integer;
var
  F: TRGForm;
  cnt: integer;
  cfg:string;
begin
  if aCFGName = '' then
    cfg := ChangeFileExt(ParamStr(0), '.ini')
  else
    cfg := aCFGName;
  F := TRGForm.CreateNew(Application);
  try
    F.RG := TRadioGroup.Create(F);
    F.ChB := TCheckBox.Create(F);
    F.Btn := TButton.Create(F);
    with F.RG do
    begin
      Parent := F;
      Caption := aRGTitle;
      for cnt := 0 to High(aItems)do
        Items.Add(aItems[cnt]);
      ItemIndex := 0;
    end;
    with F.ChB do
    begin
      Parent := F;
      Caption := aChBTitle;
    end;
    with F.Btn do
    begin
      Parent := F;
      Caption := 'Ok';
      ModalResult := mrOk;
    end;
    with F do
    begin
      Position := poMainFormCenter;
      BorderStyle := bsSizeToolWin;
      Caption := 'Выбор значения из списка';
      height := Btn.Top + Btn.height + 2;
      Name := '_Form_RG';
    end;
    try
      RestorePosition(F, cfg);
    except
    end;
    F.RGFormResize(F);
    F.ShowModal;
    aNeedSave := F.ChB.Checked;
    Result := F.RG.ItemIndex;
    try
      SavePosition(F, cfg);
    except
    end;
  finally
    FreeAndNil(F);
  end;
end;





(******************************************************************************)
procedure GetCodePageName(const CP: integer;var Result:string);
begin
  case CP of
    0037:
      Result := 'EBCDIC';
    0437:
      Result := 'MS-DOS  United States';
    0500:
      Result := 'EBCDIC "500V1"';
    0708:
      Result := 'Arabic (ASMO 708)';
    0709:
      Result := 'Arabic (ASMO 449+, BCON V4)';
    0710:
      Result := 'Arabic (Transparent Arabic)';
    0720:
      Result := 'Arabic (Transparent ASMO)';
    0737:
      Result := 'Greek (formerly 437G)';
    0775:
      Result := 'Baltic';
    0850:
      Result := 'MS-DOS  Multilingual (Latin I)';
    0852:
      Result := 'MS-DOS  Slavic (Latin II)';
    0855:
      Result := 'IBM Cyrillic (primarily Russian)';
    0857:
      Result := 'IBM Turkish';
    0860:
      Result := 'MS-DOS  Portuguese';
    0861:
      Result := 'MS-DOS Icelandic';
    0862:
      Result := 'Hebrew';
    0863:
      Result := 'MS-DOS Canadian-French';
    0864:
      Result := 'Arabic';
    0865:
      Result := 'MS-DOS Nordic';
    0866:
      Result := 'MS-DOS Russian';
    0869:
      Result := 'IBM Modern Greek';
    0874:
      Result := 'Thai';
    0875:
      Result := 'EBCDIC';
    0932:
      Result := 'Japan';
    0936:
      Result := 'Chinese (PRC, Singapore)';
    0949:
      Result := 'Korean';
    0950:
      Result := 'Chinese (Taiwan, Hong Kong)';
    1026:
      Result := 'EBCDIC';
    1200:
      Result := 'Unicode (BMP of ISO 10646)';
    1250:
      Result := 'Windows Eastern European';
    1251:
      Result := 'Windows Cyrillic';
    1252:
      Result := 'Windows US (ANSI)';
    1253:
      Result := 'Windows Greek';
    1254:
      Result := 'Windows Turkish';
    1255:
      Result := 'Hebrew';
    1256:
      Result := 'Arabic';
    1257:
      Result := 'Baltic';
    1361:
      Result := 'Korean (Johab)';
    10000:
      Result := 'Macintosh Roman';
    10001:
      Result := 'Macintosh Japanese';
    10006:
      Result := 'Macintosh Greek I';
    10007:
      Result := 'Macintosh Cyrillic';
    10029:
      Result := 'Macintosh Latin 2';
    10079:
      Result := 'Macintosh Icelandic';
    10081:
      Result := 'Macintosh Turkish';
  else
    Result := '';
  end;
end;

procedure GetFileVersion(const aFileName:string;var aFileVersion: TFileVersion);
Var
  pVersionHandle: cardinal;
  pInformation: PChar;
  VersionInfoSize: cardinal;
  Lang_Charset:string;

  procedure GetLang(var LangString:string);
  var
    szReturn: cardinal;
    tmpPLI: PLongInt;
  const
    strTranslation:string = '\VarFileInfo\Translation';
  begin
    szReturn := 0;
    LangString := '00000000';
    if VerQueryValue(pInformation, PChar(strTranslation), Pointer(tmpPLI),
      szReturn)and(szReturn > 0)then
      LangString := Format('%.4x%.4x',[LoWord(tmpPLI^), HiWord(tmpPLI^)]);
  end;

  procedure GetRootVersion(var aVS_FIXEDFILEINFO: VS_FIXEDFILEINFO);
  var
    pReturn: Pointer;
    szReturn: cardinal;
  begin
    FillChar(aVS_FIXEDFILEINFO, SizeOf(VS_FIXEDFILEINFO), 0);
    szReturn := 0;
    if VerQueryValue(pInformation, PChar('\' + #0), pReturn, szReturn)and
      (szReturn > 0)then
      System.Move(PVSFixedFileInfo(pReturn)^, aVS_FIXEDFILEINFO, szReturn);
  end;

  procedure GetProductVersion(const SubBlockName:string;var Result:string);
  var
    pValue: PChar;
    szReturn: cardinal;
  begin
    if VerQueryValue(pInformation, PChar('\StringFileInfo\' + Lang_Charset + '\'
      + SubBlockName + #0), Pointer(pValue), szReturn)then
      Result := StrPas(pValue)
    else
      Result := '';
  end;

var
  sInternalName:string;
  sFileVersion:string;
  sFileDescription:string;
  sComments:string;
  sCompanyName:string;
  sProgramVendor:string;
  sLegalCopyright:string;
  sLegalTradeMarks:string;
  sOriginalFilename:string;
  sProductVersion:string;
  sProductName:string;
  sLangName:string;
  sCodePageName:string;
  sCodePageID:string;
  sLanguageID:string;

  LangName: PChar;

  cnt: integer;
  tmp:string;

begin
SetLastError(0);
  FillChar(aFileVersion, SizeOf(TFileVersion), 0);
  try
    pVersionHandle := 0;
    VersionInfoSize := SizeOf(TFileVersion);
    //GetFileVersionInfoSize(PChar(aFileName),pVersionHandle)*SizeOf(Char)+2;
    pInformation := Allocmem(VersionInfoSize);
    try
      if (VersionInfoSize <> 0) and
         GetFileVersionInfo(PChar(aFileName), pVersionHandle, VersionInfoSize, pInformation)
         then  begin
        GetLang(Lang_Charset);
        if Lang_Charset <> '' then
        begin
          GetRootVersion(aFileVersion.aVS_FIXEDFILEINFO);

          GetProductVersion('InternalName', sInternalName);
          GetProductVersion('FileVersion', sFileVersion);
          GetProductVersion('FileDescription', sFileDescription);
          GetProductVersion('CompanyName', sCompanyName);
          GetProductVersion('Comments', sComments);
          GetProductVersion('ProgramVendor', sProgramVendor);
          GetProductVersion('LegalCopyright', sLegalCopyright);
          GetProductVersion('LegalTradeMarks', sLegalTradeMarks);
          //'LegalTradeMarks2'
          if sLegalTradeMarks = '' then
          begin
            cnt := 1;
            repeat
              GetProductVersion('LegalTradeMarks' + IntToStr(cnt),
                sLegalTradeMarks);
              if sLegalTradeMarks = '' then
                Break;
              tmp := tmp + sLegalTradeMarks + ';';
              Inc(cnt);
            until sLegalTradeMarks = '';
            sLegalTradeMarks := tmp;
          end;
          GetProductVersion('OriginalFilename', sOriginalFilename);
          GetProductVersion('ProductVersion', sProductVersion);
          GetProductVersion('ProductName', sProductName);

          sLanguageID := Copy(Lang_Charset, 1, 4);
          if CheckValidHex(sLanguageID)then
          begin
            LangName := Allocmem(256);
            try
              VerLanguageName(StrToInt('$' + sLanguageID), LangName, 255);
              sLangName := StrPas(LangName);
            finally
              FreeMem(LangName);
            end;
          end;

          sCodePageID := Copy(Lang_Charset, 5, 4);
          if CheckValidHex(sCodePageID)then
            GetCodePageName(StrToInt('$' + sCodePageID), sCodePageName);
        end;
      end;
    finally
    tmp:='';
    cnt:=GetlastError;
    if cnt<>0 then tmp:=GetErrorString(cnt);
    if tmp<>'' then ;
      FreeMem(pInformation);
      Lang_Charset := '';
    end;
  except
  end;

  with aFileVersion do
  begin
    Str2AC(sInternalName, InternalName);
    Str2AC(sFileVersion, FileVersion);
    Str2AC(sFileDescription, FileDescription);
    Str2AC(sComments, Comments);
    Str2AC(sCompanyName, CompanyName);
    Str2AC(sProgramVendor, ProgramVendor);
    Str2AC(sLegalCopyright, LegalCopyright);
    Str2AC(sLegalTradeMarks, LegalTradeMarks);
    Str2AC(sOriginalFilename, OriginalFilename);
    Str2AC(sProductVersion, ProductVersion);
    Str2AC(sProductName, ProductName);
    Str2AC(sLangName, LangName);
    Str2AC(sCodePageName, CodePageName);
    Str2AC(sCodePageID, CodePageID);
    Str2AC(sLanguageID, LanguageID);
  end;

  sInternalName := '';
  sFileVersion := '';
  sFileDescription := '';
  sComments := '';
  sCompanyName := '';
  sProgramVendor := '';
  sLegalCopyright := '';
  sLegalTradeMarks := '';
  sOriginalFilename := '';
  sProductVersion := '';
  sProductName := '';
  sLangName := '';
  sCodePageName := '';
  sCodePageID := '';
  sLanguageID := '';
end;

(******************************************************************************)

(*Подчистка символов если подряд больше одного*)
function SlimFastEx(const InString:string;const Chars:string):string;
var
  cntChar: integer;
  cntStr: integer;
  CanNextChar: boolean;
  ln: integer;
begin
  Result := '';
  if Length(InString)>= 1 then
    Result := InString[1]
  else
    Exit;
  for cntStr := 2 to Length(InString)do
  begin
    CanNextChar := true;
    ln := Length(Result);
    for cntChar := 1 to Length(Chars)do
    begin
      CanNextChar :=(Result[ln]<> Chars[cntChar])or (Result[ln]<> InString[cntStr]);
    if not CanNextChar then
        Break;
    end;
    if CanNextChar
       then Result := Result + InString[cntStr];
  end;
end;

procedure SlimFastEx(const InString:string;const Chars:string;
  var Result:string);
var
  cntChar: integer;
  cntStr: integer;
  CanNextChar: boolean;
  ln: integer;
begin
  Result := '';
  if Length(InString)>= 1 then
    Result := InString[1]
  else
    Exit;
  for cntStr := 2 to Length(InString)do
  begin
    CanNextChar := true;
    ln := Length(Result);
    for cntChar := 1 to Length(Chars)do
    begin
      CanNextChar :=(Result[ln]<> Chars[cntChar])or
        (Result[ln]<> InString[cntStr]);
      if not CanNextChar then
        Break;
    end;
    if CanNextChar then
      Result := Result + InString[cntStr];
  end;
end;

procedure TokenNT2(const Value, Delim:string;var ResTokens: TStringList);
begin
  if Assigned(ResTokens)then
    ResTokens.Clear
  else
    ResTokens := TStringList.Create;
  ResTokens.Text := StringReplace(Value, Delim, crlf,[rfReplaceAll]);
end;

(*Получение всех элементов строки*)
procedure OneTokenNT(const Value, Delim:string;const Index: integer;
  var Result:string);
var
  strl: TStringList;
begin
  Result := '';
  strl := TStringList.Create;
  try
    if(Value <> '')and not boolean(AnsiPos(Delim, Value))then
      TokenNT2(Value + Delim, Delim, strl)
    else
      TokenNT2(Value, Delim, strl);
    if(Index >= 0)and(Index <= strl.Count - 1)then
      Result := strl[Index];
  finally
    if Assigned(strl)then
    begin
      strl.Clear;
      FreeAndNil(strl);
    end;
  end;
end;

function OneTokenNT(const Value, Delim:string;const Index: integer):string;
begin
  OneTokenNT(Value, Delim, Index, Result);
end;

(*Описание единиц словами*)
function GetDefUnit(Number: integer; aDefUnits: TDefUnits):string;
var
  tmp:string;
  numb: integer;
begin
  if Number < 10 then
    numb := Number
  else
  begin
    tmp := IntToStr(Number);
    tmp := Copy(tmp, Length(tmp)- 1, 2);
    numb := StrToInt(tmp);
    if(numb >= 10)and(numb <= 19)then
      numb := 5
    else
      numb := StrToInt(tmp[2]);
  end;

  case aDefUnits of
    dfDay:
      case numb of
        1:
          Result := 'день';
        2 .. 4:
          Result := 'дня';
      else
        Result := 'дней';
      end;
    dfRuble:
      case numb of
        1:
          Result := 'рубль';
        2 .. 4:
          Result := 'рубля';
      else
        Result := 'рублей';
      end;
    dfKop:
      case numb of
        1:
          Result := 'копейка';
        2 .. 4:
          Result := 'копейки';
      else
        Result := 'копеек';
      end;
    dfUSD:
      case numb of
        1:
          Result := 'доллар США';
        2 .. 4:
          Result := 'доллара США';
      else
        Result := 'долларов США';
      end;
    dfMonth:
      case numb of
        1:
          Result := 'месяц';
        2 .. 4:
          Result := 'месяца';
      else
        Result := 'месяцев';
      end;
    dfYear:
      case numb of
        1:
          Result := 'год';
        2 .. 4:
          Result := 'года';
      else
        Result := 'лет';
      end;
    
    dfWeek:
      case numb of
        1:
          Result := 'неделя';
        2 .. 4:
          Result := 'недели';
      else
        Result := 'недель';
      end;
    dfHour:
      case numb of
        1:
          Result := 'час';
        2 .. 4:
          Result := 'часа';
      else
        Result := 'часов';
      end;
    dfMinute:
      case numb of
        1:
          Result := 'минута';
        2 .. 4:
          Result := 'минуты';
      else
        Result := 'минут';
      end;
    dfSecond:
      case numb of
        1:
          Result := 'секунда';
        2 .. 4:
          Result := 'секунды';
      else
        Result := 'секунд';
      end;
    dfFile:
      case numb of
        1:
          Result := 'файл';
        2 .. 4:
          Result := 'файла';
      else
        Result := 'файлов';
      end;
     dfFileIn:
      case numb of
        1:
          Result := 'файле';
        else
          Result := 'файлах';
      end;
    dfSymbol:
      case numb of
        1:
          Result := 'символ';
        2 .. 4:
          Result := 'символа';
      else
        Result := 'символов';
      end;
    dfPart:
      case numb of
        1:
          Result := 'часть';
        2 .. 4:
          Result := 'части';
      else
        Result := 'частей';
      end;
    dfByte:
      case numb of
        1:
          Result := 'байт';
        2 .. 4:
          Result := 'байта';
      else
        Result := 'байтов';
      end;
    dfRecords:
      case numb of
        1:
          Result := 'запись';
        2 .. 4:
          Result := 'записи';
      else
        Result := 'записей';
      end;
    dfOrder:
      case numb of
        1,4,5,9 : Result := '-ый';
        3       : Result := '-ий';
        2,6,7,8 : Result := '-ой';
      else begin
      if Number=0
         then Result := '-ой'
         else Result := '-ый';
      end;
      end;
    dfTest:
      case numb of
        1:
          Result := 'тест';
        2 .. 4:
          Result := 'теста';
      else
        Result := 'тестов';
      end;
  else
    Result := '';
  end;
end;

function GetEnding(Number: integer; const SourceWord : string; ending: TDefEnding):string;
var
  tmp:string;
  numb: integer;
  last : char;
// http://info-4all.ru/obrazovanie/kakie-mozhno-privesti-primeri-slov-3-tretego-skloneniya/
// https://kartaslov.ru/%D0%BF%D1%80%D0%BE%D1%81%D0%BA%D0%BB%D0%BE%D0%BD%D1%8F%D1%82%D1%8C-%D1%81%D1%83%D1%89%D0%B5%D1%81%D1%82%D0%B2%D0%B8%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D0%BE%D0%B5/%D0%BA%D0%BE%D0%B4
begin
Result:='';
if Length(SourceWord)=0 then Exit;
  if Number < 10 then
    numb := Number
  else
  begin
    tmp := IntToStr(Number);
    tmp := Copy(tmp, Length(tmp)- 1, 2);
    numb := StrToInt(tmp);
    if(numb >= 10)and(numb <= 19)then
      numb := 5
    else
      numb := StrToInt(tmp[2]);
  end;
last:=AnsiLowerCase(Sourceword[length(Sourceword)])[1];
//  -- по падежам и числам соотносятся
// -- 1   : Именительный , единственное
// -- 2-4 : Дательный , единственное
// -- 5   : Родительный , множественное
  case ending of
    deOne:  // --> Муж., Жен. на -а, -я
      case numb of
        1    : Result := SourceWord; // -- малина
        2,3,4: Result := Copy(SourceWord,1,Length(SourceWord)-1)+'ы'; // -- малины
      else     Result := Copy(SourceWord,1,Length(SourceWord)-1); // -- малин
      end;
    deTwo:  // --> Муж. без окончания, Муж. на -ь (шмель), Ср. на -о, -е,
     case numb of
        1    : Result := SourceWord;                                    // -- кот, шмель
        2,3,4: Result := ifthen(last='ь'
                               , Copy(SourceWord,1,Length(SourceWord)-1)+'я'     // -- шмеля
                               , SourceWord+'а');   // -- кота
      else     Result := ifthen(last='ь'
                               , Copy(SourceWord,1,Length(SourceWord)-1)+'ей'    // -- шмелей
                               , SourceWord+'ов');  // -- котов
      end;
    deThree: // Жен. на -ь +Путь, Ср. на -мя
     case numb of
        1    : Result := SourceWord;                                    // -- сирень, племя
        2,3,4: Result := ifthen(last='я'
                               , Copy(SourceWord,1,Length(SourceWord)-1)+'ени'   // -- племени
                               , Copy(SourceWord,1,Length(SourceWord)-1)+'и');   // -- сирени
      else     Result := ifthen(last='я'
                               , Copy(SourceWord,1,Length(SourceWord)-1)+'ен'    // -- племен
                               , Copy(SourceWord,1,Length(SourceWord)-1)+'ей');  // -- сиреней
      end;
   else Result:=SourceWord;
   end;
end;

(*Запись числа словами  с указанием типа ед.измерения*)
function NumberByWords(aNumber: extended; DefUnits: TDefUnits = dfNone):string;
var
  i10: integer;
  s10: integer;
  str1:string;
  str2:string;
  res:string;

  DRA: array of integer;
  DKA: array of integer;
  dt:string;
  DRS:string;
  DKS:string;
  Wordg:string;
  LR: integer;
  LK: integer;
  ir: integer;
  Pos: integer;
  twel: boolean;

  //~~~~~~~~~~~~~~~~~~~~  ROUTINE  ~~~~~~~~~~~~~~~~~~~~~~~
  function IntToWord(Pos, Number: integer):string;
  const
    aWords: array[1 .. 4, 0 .. 9]of string =(('', 'один', 'два', 'три',
      'четыре', 'пять', 'шесть', 'семь', 'восемь', 'девять'),
      ('', 'десять', 'двадцать', 'тридцать', 'сорок', 'пятьдесят', 'шестьдесят',
      'семьдесят', 'восемьдесят', 'девяносто'),('', 'сто', 'двести', 'триста',
      'четыреста', 'пятьсот', 'шестьсот', 'семьсот', 'восемьсот', 'девятьсот'),
      ('', 'одна', 'две', 'три', 'четыре', 'пять', 'шесть', 'семь', 'восемь',
      'девять'));

  begin
    try
      Result := ' ' + aWords[Pos, Number];
    except
      on E: Exception do
        ShowMessageInfo(Format('%s,[%d,%d]',[E.Message, Pos, Number]))
    end;
  end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  function DecDefine(LastNum, DecimalSymbolsCount: integer):string;
  const
    DSC_def: array[1 .. 10]of string =('десятых', 'сотых', 'тысячных',
      'десятитысячных', 'статысячных', 'миллионных', 'десятимилионных',
      'стамиллионных', 'миллиардных', 'десятимиллиардных');
  begin
    Result := '';
    if DecimalSymbolsCount > 10 then
      Exit;
    Result := DSC_def[DecimalSymbolsCount];
    if LastNum = 1 then
      Result := Copy(Result, 1, Length(Result)- 2)+ 'ая';
  end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
begin
  Result := '';
  try
    try
      if aNumber = 0 then
      begin
        if DefUnits = dfUSD then
          Result := 'Ноль 0/100 ' + GetDefUnit(trunc(aNumber), DefUnits)
        else
          Result := 'Ноль ' + GetDefUnit(trunc(aNumber), DefUnits);
        Exit;
      end;
      //if aNumber<0
      //then DT:=FloatToStr(Abs(aNumber))
      //else DT:=FloatToStr(aNumber);
      if aNumber < 0 then
        dt := FormatFloat('#0.#########', Abs(aNumber))
      else
        dt := FormatFloat('#0.#########', aNumber);
      OneTokenNT(dt, DecimalSeparator, 0, DRS);
      OneTokenNT(dt, DecimalSeparator, 1, DKS);
      if DKS = '' then
        DKS := '00';
      LR := Length(DRS);
      LK := Length(DKS);
      SetLength(DRA, LR);
      SetLength(DKA, LK);
      for ir := 0 to LR - 1 do
        DRA[ir]:= StrToInt(Copy(DRS, ir + 1, 1));
      for ir := 0 to LK - 1 do
        DKA[ir]:= StrToInt(Copy(DKS, ir + 1, 1));

      if(Length(DRA)= 1)and(DRA[0]= 0)then
      begin
        res := 'Ноль';
        twel := false;
      end
      else
      begin
        for ir := LR downto 1 do
        begin
          case LR - ir + 1 of
            04:
              begin
                if Copy(DRS, LR - 5, 3)<> '000'//типа 9000345
                then
                begin
                  case DRA[LR - 4]of
                    1:
                      Wordg := ' тысяча' + Wordg;
                    2 .. 4:
                      Wordg := ' тысячи' + Wordg;
                  else
                    Wordg := ' тысяч' + Wordg;
                  end;
                end;
              end;
            07:
              begin
                if Copy(DRS, LR - 8, 3)<> '000'//типа 1000012345
                then
                begin
                  case DRA[LR - 7]of
                    1:
                      Wordg := ' миллион' + Wordg;
                    2 .. 4:
                      Wordg := ' миллиона' + Wordg;
                  else
                    Wordg := ' миллионов' + Wordg;
                  end;
                end;
              end;
            10:
              begin
                case DRA[LR - 10]of
                  1:
                    Wordg := ' миллиард' + Wordg;
                  2 .. 4:
                    Wordg := ' миллиарда' + Wordg;
                else
                  Wordg := ' миллиардов' + Wordg;
                end;
              end;
          end;

          Case(LR - ir + 1)of
            2, 5, 8, 11:
              Pos := 2;
            1, 7, 10:
              Pos := 1;
            3, 6, 9, 12:
              Pos := 3;
            4:
              Pos := 4;
          else
            Pos :=-1;
          end;
          if Pos = 1 then
            Wordg := IntToWord(Pos + 3 * integer((DefUnits in[dfKop, dfMinute,
              dfSecond, dfPart])), DRA[ir - 1])+ Wordg
          else
            Wordg := IntToWord(Pos, DRA[ir - 1])+ Wordg;
        end;

        s10 := 1;
        i10 := 0;
        case LR of
          1 .. 3:
            i10 := LR + 1;
          4 .. 6:
            i10 := LR + 2;
          7 .. 9:
            i10 := LR + 3;
          10 .. 12:
            i10 := LR + 4;
        end;
        twel := false;
        while s10 <= i10 do
        begin
          Wordg := Trim(Wordg);
          OneTokenNT(Wordg, ' ', s10 - 1, str1);
          if str1 = 'десять' then
          begin
            OneTokenNT(Wordg, ' ', s10, str2);
            str2 := Copy(str2, 1, 2);
            if str2 = 'од' then
            begin
              twel := true;
              str1 := 'одиннадцать'
            end
            else if str2 = 'дв' then
            begin
              twel := true;
              str1 := 'двенадцать'
            end
            else if str2 = 'тр' then
            begin
              twel := true;
              str1 := 'тринадцать'
            end
            else if str2 = 'че' then
            begin
              twel := true;
              str1 := 'четырнадцать'
            end
            else if str2 = 'пя' then
            begin
              twel := true;
              str1 := 'пятнадцать'
            end
            else if str2 = 'ше' then
            begin
              twel := true;
              str1 := 'шестнадцать'
            end
            else if str2 = 'се' then
            begin
              twel := true;
              str1 := 'семнадцать'
            end
            else if str2 = 'во' then
            begin
              twel := true;
              str1 := 'восемнадцать'
            end
            else if str2 = 'де' then
            begin
              twel := true;
              str1 := 'девятнадцать'
            end
            else
              twel := false;
            OneTokenNT(Wordg, ' ', s10 + 1, str2);
            {тысячи}if Copy(str2, 1, 4)= 'тыся' then
              str1 := str1 + ' тысяч';
            {миллионы}if Copy(str2, 1, 7)= 'миллион' then
              str1 := str1 + ' миллионов';
            {миллиарды}if Copy(str2, 1, 7)= 'миллиар' then
              str1 := str1 + ' миллиардов';
            s10 := s10 + 3;
          end
          else
          begin
            s10 := s10 + 1;
            twel := false;
          end;
          res := res + ' ' + str1;
        end;
      end;//закончился анализ целочисленной части
      res := Trim(res);
      Result := SlimFastEx(AnsiUpperCase(Copy(res, 1, 1))+ Copy(res, 2,
        Length(res)), ' '#160);
      res := Result;
      Pos := StrToInt(DKS);
      if Pos <> 0 then
      begin
        case DefUnits of
          dfNone:
            begin
              str1 := AnsiLowerCase(NumberByWords(Pos, dfNone));
              Result := Result + ' и ' + str1 +
                DecDefine(StrToInt(DKS[Length(DKS)]), Length(DKS));
            end;
          dfRuble:
            begin
              if twel then
                res := res + ' ' + GetDefUnit(5, DefUnits)
              else
                res := res + ' ' + GetDefUnit(DRA[High(DRA)], DefUnits);
              Pos := Round(Pos /(power(10,(Length(DKS)- 2))));
              (*str1:=AnsiLowerCase(NumberByWords(Pos,dfNone));*)
              str1 := FormatFloat('00', Pos);
              if(Pos >= 10)and(Pos <= 19)then
                Result := res + ' ' + str1 + ' ' + GetDefUnit(5, dfKop)
              else
                Result := res + ' ' + str1 + ' ' +
                  GetDefUnit(StrToInt(str1[2]), dfKop);
            end;
          dfUSD:
            begin
              Pos := Round(Pos /(power(10,(Length(DKS)- 2))));
              str1 := IntToStr(Pos)+ '/100';
              if twel then
                Result := Result + ' ' + str1 + ' ' + GetDefUnit(5, dfUSD)
              else
                Result := Result + ' ' + str1 + ' ' +
                  GetDefUnit(StrToInt(str1[2]), dfUSD);
            end;
        end;
      end
      else
      begin
        case DefUnits of
          dfUSD:
            begin
              Pos := Round(Pos /(power(10,(Length(DKS)- 2))));
              str1 := IntToStr(Pos)+ '/100';
              if twel then
                Result := Result + ' ' + str1 + ' ' + GetDefUnit(5, dfUSD)
              else
                Result := Result + ' ' + str1 + ' ' +
                  GetDefUnit(StrToInt(str1[2]), dfUSD);
            end;
          dfDay:
            begin
              if twel then
                Result := Result + ' ' + GetDefUnit(5, DefUnits)
              else
                Result := Result + ' ' + GetDefUnit(DRA[High(DRA)], DefUnits);
            end;
          dfRuble:
            begin
              if twel then
                Result := Result + ' ' + GetDefUnit(5, DefUnits)+ ' 00 коп.'
              else
                Result := Result + ' ' + GetDefUnit(DRA[High(DRA)], DefUnits)+
                  ' 00 коп.';
            end;
          dfYear:
            begin
              if twel then
                Result := Result + ' ' + GetDefUnit(5, DefUnits)
              else
                Result := Result + ' ' + GetDefUnit(DRA[High(DRA)], DefUnits);
            end;
          dfMonth:
            begin
              if twel then
                Result := Result + ' ' + GetDefUnit(5, DefUnits)
              else
                Result := Result + ' ' + GetDefUnit(DRA[High(DRA)], DefUnits);
            end;
        else
          if twel then
            Result := Result + ' ' + GetDefUnit(5, DefUnits)
          else
            Result := Result + ' ' + GetDefUnit(DRA[High(DRA)], DefUnits);
        end;

      end;
      if aNumber < 0 then
        Result := 'Минус ' + AnsiLowerCase(Result);
    except
      Result := '';
    end;
  finally
    SetLength(DRA, 0);
    SetLength(DKA, 0);
  end;
end;

function NumericToWords(aNumber: extended; DefUnits: TDefUnits = dfNone):string;
begin
  Result := NumberByWords(aNumber, DefUnits);
end;

function NumberToWords(aNumber: extended; DefUnits: TDefUnits = dfNone):string;
begin
  Result := NumberByWords(aNumber, DefUnits);
end;

function Num2Str(aNumber: extended; DefUnits: TDefUnits):string;
begin
  Result := NumberByWords(aNumber, DefUnits);
end;


const
  BOOL: array[boolean]of string =('0', '1');
  sep: array[boolean]of string =('', '.');

function IntToBin(Value: smallint; aNeedSep: boolean = false):string;
var
  cnt, sz: integer;
begin
  Result := '';
  sz := SizeOf(Value)* 8;
  for cnt := 0 to sz - 1 do
    Result := BOOL[(Value and(1 shl cnt))<> 0]+
      sep[((cnt + 1)mod 8 = 1)and(cnt > 0)and aNeedSep]+ Result;
end;

function IntToBin(Value: Byte; aNeedSep: boolean = false):string; overload;
var
  cnt, sz: integer;
begin
  Result := '';
  sz := SizeOf(Value)* 8;
  for cnt := 0 to sz - 1 do
    Result := BOOL[(Value and(1 shl cnt))<> 0]+
      sep[((cnt + 1)mod 8 = 1)and(cnt > 0)and aNeedSep]+ Result;
end;

function IntToBin(Value: Word; aNeedSep: boolean = false):string; overload;
var
  cnt, sz: integer;
begin
  Result := '';
  sz := SizeOf(Value)* 8;
  for cnt := 0 to sz - 1 do
    Result := BOOL[(Value and(1 shl cnt))<> 0]+
      sep[((cnt + 1)mod 8 = 1)and(cnt > 0)and aNeedSep]+ Result;
end;

function IntToBin(Value: DWORD; aNeedSep: boolean = false):string; overload;
var
  cnt, sz: integer;
begin
  Result := '';
  sz := SizeOf(Value)* 8;
  for cnt := 0 to sz - 1 do
    Result := BOOL[(Value and(1 shl cnt))<> 0]+
      sep[((cnt + 1)mod 8 = 1)and(cnt > 0)and aNeedSep]+ Result;
end;

function IntToBin(Value: integer; aNeedSep: boolean = false):string; overload;
var
  cnt, sz: integer;
begin
  Result := '';
  sz := SizeOf(Value)* 8;
  for cnt := 0 to sz - 1 do
    Result := BOOL[(Value and(1 shl cnt))<> 0]+
      sep[((cnt + 1)mod 8 = 1)and(cnt > 0)and aNeedSep]+ Result;
end;

function IntToBin(Value: int64; aNeedSep: boolean = false):string; overload;
var
  cnt, sz: integer;
begin
  Result := '';
  sz := SizeOf(Value)* 8;
  for cnt := 0 to sz - 1 do
    Result := BOOL[(Value and(1 shl cnt))<> 0]+
      sep[((cnt + 1)mod 8 = 1)and(cnt > 0)and aNeedSep]+ Result;
end;

(*Копирование части строки с указанием начального и конечного "якоря"*)
function CopyFromTo(const aInput, aFrom, aTo:string;
  aCI, aWithAnchors: boolean):string;
var
  tmp:string;
  st:string;
  ps: integer;
  fn:string;
  pf: integer;
begin
  if aCI then
  begin
    tmp := AnsiUpperCase(aInput);
    st := AnsiUpperCase(aFrom);
    fn := AnsiUpperCase(aTo);
  end
  else
  begin
    tmp := aInput;
    st := aFrom;
    fn := aTo;
  end;
  pf := AnsiPos(fn, tmp)- 1;
  if pf < 0 then//pf:=Length(tmp)
    pf := 0//-- new 20120514 (если тэга нет , то пусть всё же будет пустышка а не полная входная строка)
  else if(pf > 0)and aWithAnchors then
    pf := pf + Length(aTo);

  Result := Copy(aInput, 1, pf);
  ps := AnsiPos(st, tmp);
  if ps > 0 then
    if aWithAnchors then
    else
      ps := ps + Length(aFrom)
  else if ps = 0 then
    ps := 1;
  Result := Copy(Result, ps, Length(Result));
end;

function SplitStringCI(const S, Delimiter:string): TStringDynArray;
var
  one:string;
  tmp:string;
  st:string;
  ps: integer;
  pf: integer;
  cnt: integer;
begin
  SetLength(Result, 0);
  tmp := AnsiUpperCase(S);
  st := AnsiUpperCase(Delimiter);
  ps := PosEx(st, tmp, 1);
  while ps > 0 do
  begin
    pf := PosEx(st, tmp, ps + 1);
    if pf = 0 then
      pf := Length(tmp)+ 1;
    one := Copy(S, ps, pf - 1 - ps);
    cnt := Length(Result);
    SetLength(Result, cnt + 1);
    Result[cnt]:= one;
    ps := PosEx(st, tmp, ps + 1);
  end;
end;

function SplitStringCIstrl(const S, Delimiter:string): TStringDynArray;
var
  cnt: integer;
  strl: TStringList;
begin
  SetLength(Result, 0);
  strl := TStringList.Create;
  try
    strl.Text := StringReplace(S, Delimiter, crlf,[rfReplaceAll, rfIgnoreCase]);
    SetLength(Result, strl.Count);
    for cnt := 0 to strl.Count - 1 do
      Result[cnt]:= strl[cnt];
  finally
    FreeStringList(strl);
  end;
end;

function TransStrR(const S:string;const Old:string;const New: char):string;
var
  j: integer;
begin
  Result := S;
  for j := 1 to Length(Old)do
    Result := StringReplace(Result, Old[j], IfThen(New=#0,'',New),[rfReplaceAll]);
end;

function TransStrR(const S:string;const Old:string;const New:string):string;
var
  j: integer;
begin
  Result := S;
  for j := 1 to Length(Old)do
    Result := StringReplace(Result, Old[j], New,[rfReplaceAll]);
end;

// -- Этот вариант функции работает только с цифрами и латинскими символами !!!! ---
function LeaveChars(const aInput : String; aLeaveChars : TSysCharSet) : string;
var
 cnt : integer;
 //chr : char;
begin
Result:='';
//for chr in aInput
//  do if CharInSet(chr,aLeaveChars) then Result:=Result+chr;
for cnt:=1 to Length(aInput)
  do if CharInSet(aInput[cnt],aLeaveChars) then Result:=Result+aInput[cnt];
end;

function LeaveChars(const aInput : AnsiString; aLeaveChars : TSysCharSet) : string;
var
 //cnt : integer;
 chr : ansichar;
begin
Result:='';
for chr in aInput
  do if CharInSet(chr,aLeaveChars) then Result:=Result+string(chr);
//for cnt:=1 to Length(aInput)
//  do if CharInSet(aInput[cnt],aLeaveChars) then Result:=Result+aInput[cnt];
end;

function Translit(const src : string) : string;
type
  TranslitPair = record
    rus : string;
    trn : string;
  end;
const
 TranslitSymb : array[0..65] of TranslitPair =
 (
  (rus: 'а'; trn: 'a'),
  (rus: 'б'; trn: 'b'),
  (rus: 'в'; trn: 'v'),
  (rus: 'г'; trn: 'g'),
  (rus: 'д'; trn: 'd'),
  (rus: 'е'; trn: 'e'),
  (rus: 'ё'; trn: 'jo'),
  (rus: 'ж'; trn: 'zh'),
  (rus: 'з'; trn: 'z'),
  (rus: 'и'; trn: 'i'),
  (rus: 'й'; trn: 'jj'),
  (rus: 'к'; trn: 'k'),
  (rus: 'л'; trn: 'l'),
  (rus: 'м'; trn: 'm'),
  (rus: 'н'; trn: 'n'),
  (rus: 'о'; trn: 'o'),
  (rus: 'п'; trn: 'p'),
  (rus: 'р'; trn: 'r'),
  (rus: 'с'; trn: 's'),
  (rus: 'т'; trn: 't'),
  (rus: 'у'; trn: 'u'),
  (rus: 'ф'; trn: 'f'),
  (rus: 'х'; trn: 'kh'),
  (rus: 'ц'; trn: 'c'),
  (rus: 'ч'; trn: 'ch'),
  (rus: 'ш'; trn: 'sh'),
  (rus: 'щ'; trn: 'shh'),
  (rus: 'ъ'; trn: '"'),
  (rus: 'ы'; trn: 'y'),
  (rus: 'ь'; trn: ''''),
  (rus: 'э'; trn: 'eh'),
  (rus: 'ю'; trn: 'ju'),
  (rus: 'я'; trn: 'ja'),

  (rus: 'А'; trn: 'A'),
  (rus: 'Б'; trn: 'B'),
  (rus: 'В'; trn: 'V'),
  (rus: 'Г'; trn: 'G'),
  (rus: 'Д'; trn: 'D'),
  (rus: 'Е'; trn: 'E'),
  (rus: 'Ё'; trn: 'JO'),
  (rus: 'Ж'; trn: 'ZH'),
  (rus: 'З'; trn: 'Z'),
  (rus: 'И'; trn: 'I'),
  (rus: 'Й'; trn: 'JJ'),
  (rus: 'К'; trn: 'K'),
  (rus: 'Л'; trn: 'L'),
  (rus: 'М'; trn: 'M'),
  (rus: 'Н'; trn: 'N'),
  (rus: 'О'; trn: 'O'),
  (rus: 'П'; trn: 'P'),
  (rus: 'Р'; trn: 'R'),
  (rus: 'С'; trn: 'S'),
  (rus: 'Т'; trn: 'T'),
  (rus: 'У'; trn: 'U'),
  (rus: 'Ф'; trn: 'F'),
  (rus: 'Х'; trn: 'KH'),
  (rus: 'Ц'; trn: 'C'),
  (rus: 'Ч'; trn: 'CH'),
  (rus: 'Ш'; trn: 'SH'),
  (rus: 'Щ'; trn: 'SHH'),
  (rus: 'Ъ'; trn: '"'),
  (rus: 'Ы'; trn: 'Y'),
  (rus: 'Ь'; trn: ''''),
  (rus: 'Э'; trn: 'EH'),
  (rus: 'Ю'; trn: 'JU'),
  (rus: 'Я'; trn: 'JA')
);
var
 cnt : integer;
begin
Result:=AnsiLowerCase(src);
for cnt:=0 to High(TranslitSymb)
  do with TranslitSymb[cnt]
      do Result:=StringReplace(Result,rus,trn,[rfReplaceAll]);
end;


function rumetaphone(const Source : string) : string;
// https://moluch.ru/archive/19/1967/
type
  TReplaceItem = record
   old : string;
   new : string;
  end;

const
 replacers : array [0..3] of TReplaceItem = // -- посимвольная замена
 (
  (old: 'ОЫАЯ'  ; new: 'A')
 ,(old: 'ЮУ'    ; new: 'У')
 ,(old: 'ЕЁЭИЙ' ; new: 'И')
 ,(old: 'ЬЪ-'   ; new: '')
// ,(old: 'Б'  ; new: 'П')
// ,(old: 'Д'  ; new: 'Т')
// ,(old: 'Г'  ; new: 'К')
// ,(old: 'З'  ; new: 'С')
// ,(old: 'Ж'  ; new: 'Ш')
 );

 replacersDop : array [0..3] of TReplaceItem = // -- полнострочная замена (https://github.com/rossvs/Metaphone_Rus/blob/master/metaphone_rus.php)
 (
   (old: 'ЙО'  ; new: 'И')
  ,(old: 'ИО'  ; new: 'И')
  ,(old: 'ЙЕ'  ; new: 'И')
  ,(old: 'ИЕ'  ; new: 'И')
 );

// -- дополнительно
// http://www.morfoedro.it/doc.php?n=222&lang=ru


var
 cnt : integer;
 rs  : string;
 rsR : string;
begin
Result:=AnsiUpperCase(Source);
if Length(Result)<2 then Exit;

for cnt:=0 to High(replacersDop) // -- 0 step (присутствет тут : https://github.com/rossvs/Metaphone_Rus/blob/master/metaphone_rus.php)
  do Result:=StringReplace(Result, replacersDop[cnt].old, replacersDop[cnt].new, [rfReplaceAll]);

for cnt:=0 to High(replacers) // -- 1, 5 step 1.подменяем гласные (без учета ударения), 5.
  do Result:=TransStrR(Result, replacers[cnt].old, replacers[cnt].new);

for cnt:=1 to Length(Result)-1  // -- 2 step (в "слабой" позиции)
  do if CharInSet(Result[cnt],['Б','В','Г','Д','Ж','З']) // -- звонкие
      and CharInSet(Result[cnt+1],['Б','В','Г','Д','Ж','З','К','Л','М','Н','П','Р','С','Т','Ф','Х','Ц','Ч','Ш','Щ']) // -- все

      // -- https://habr.com/post/341142/
      // --and CharInSet(Result[cnt+1],['Б','В','Г','Д','Ж','З','Й']

      // -- https://github.com/rossvs/Metaphone_Rus/blob/master/metaphone_rus.php  (изменил порядок для лучшего восприятия)
      // --and CharInSet(Result[cnt+1],['Б','П','В','Ф','Г','К','Д','Т','Ж','Ш','З','С','Х','Ц','Ч','Щ']
      then case Result[cnt] of
           'Б' : Result[cnt]:='П';
           'В' : Result[cnt]:='Ф';
           'Г' : Result[cnt]:='Л';
           'Д' : Result[cnt]:='Т';
           'Ж' : Result[cnt]:='Ш';
           'З' : Result[cnt]:='С';
           end;
cnt:=Length(Result);  // -- 2 step (в конце слова)
case Result[cnt] of
 'Б' : Result[cnt]:='П';
 'В' : Result[cnt]:='Ф';
 'Г' : Result[cnt]:='Л';
 'Д' : Result[cnt]:='Т';
 'Ж' : Result[cnt]:='Ш';
 'З' : Result[cnt]:='С';
 end;

Result:=SlimFastEx(Result,'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'); // -- 3 step
// -- 4 step , чистим фамилии, если слово - фамилия
rs:=RightStr(Result,6);
rsR:='';
if (rs='ОВСКИЙ') then rsR:='@' else
if (rs='ЕВСКИЙ') then rsR:='#' else
if (rs='ОВСКАЯ') then rsR:='$' else
if (rs='ЕВСКАЯ') then rsR:='%' else ;
if rsR<>''
   then Result:=Copy(Result,1,Length(Result)-6)+rsR;

rs:=RightStr(Result,4);
rsR:='';
if (rs='ИЕВА') or (rs='ЕЕВА') then rsR:='9' else;
if rsR<>''
   then Result:=Copy(Result,1,Length(Result)-4)+rsR;

rs:=RightStr(Result,3);
rsR:='';
if (rs='ОВА') or (rs='ЕВА') then rsR:='9' else
if (rs='ИЕВ') or (rs='ЕЕВ') then rsR:='4' else
if (rs='ИНА')  then rsR:='1' else
if (rs='НКО')  then rsR:='3' else ;
if rsR<>''
   then Result:=Copy(Result,1,Length(Result)-3)+rsR;

rs:=RightStr(Result,2);
rsR:='';
if (rs='ЕВ') or (rs='ОВ') then rsR:='4' else
if (rs='ИЙ') or (rs='ЫЙ') then rsR:='7' else
if (rs='ЫХ') or (rs='ИХ') then rsR:='5' else
if (rs='ИК') or (rs='ЕК') then rsR:='2' else
if (rs='УК') or (rs='ЮК') then rsR:='0' else
if (rs='АЯ')  then rsR:='6' else
if (rs='ИН')  then rsR:='8' else;
if rsR<>''
   then Result:=Copy(Result,1,Length(Result)-2)+rsR;

end;


function StringBeginWith(const StrValue, BeginValue : string; CI : boolean = true) : boolean;
begin
if CI
   then Result:=AnsiPos(AnsiLowercase(BeginValue),AnsiLowercase(StrValue))=1
   else Result:=AnsiPos(BeginValue,StrValue)=1
end;

function StringHasA(const StrValue, MidValue : string; CI : boolean = true) : boolean;
begin
if CI
   then Result:=AnsiPos(AnsiLowercase(MidValue),AnsiLowercase(StrValue))<>0
   else Result:=AnsiPos(MidValue,StrValue)<>0
end;


function StringEndIn(const StrValue, EndValue : string; CI : boolean = true) : boolean;
begin
if CI
   then Result:=AnsiPos(ReverseString(AnsiLowercase(EndValue)),ReverseString(AnsiLowercase(StrValue)))=1
   else Result:=AnsiPos(ReverseString((EndValue)),ReverseString((StrValue)))=1
end;


(*Массив символов в строку (ленивка) *****************************************)
function ArrayOfCharToString(const aArray: array of char):string;
begin
Result := '';
if (Length(aArray)> 0)
   then Result := Trim(StrPas(PChar(@aArray[Low(aArray)])));
end;

function ArrayOfCharToString(const aArray: array of ansichar):string;
begin
Result := '';
if (Length(aArray)> 0)
   then Result := Trim(StrPas(PChar(@aArray[Low(aArray)])));
end;

function AC2Str(const aArray: array of char):string;
begin
  Result := ArrayOfCharToString(aArray(*, aNeedQuoted*));
end;

function AC2Str(const aArray: array of ansichar):string;
begin
  Result := ArrayOfCharToString(aArray);
end;


function AC2StrQuote(const aArray: array of char;aQuote: char = #0 ):string;
begin
Result := AC2Str(aArray);
if aQuote<>#0
   then Result := AnsiQuotedStr(Result, aQuote);
end;

function AC2StrQuote(const aArray: array of ansichar;aQuote: char = #0 ):string;
begin
Result := AC2Str(aArray);
if aQuote<>#0
   then Result := AnsiQuotedStr(Result, aQuote);
end;

procedure AC2AC(const Source : array of char; var Dest : array of char);
begin
FillChar(Dest,Length(Dest)*SizeOf(char),0);
System.Move(Source[Low(Source)],Dest[Low(Dest)],Length(Dest)*SizeOf(char));
end;

procedure AC2AC(const Source : array of ansichar; var Dest : array of ansichar);
begin
FillChar(Dest,Length(Dest)*SizeOf(ansichar),0);
System.Move(Source[Low(Source)],Dest[Low(Dest)],Length(Dest)*SizeOf(ansichar));
end;


(*Строка в массив символов (ленивка) *****************************************)
procedure StringToArrayOfChar(const aString:string;var aArray: array of char);
begin
FillChar(aArray[Low(aArray)], Length(aArray) * SizeOfChar, 0);
StrPLCopy(PChar(@aArray[Low(aArray)]), aString, Length(aArray)- 1);
end;

procedure Str2AC(const aString:string; var aArray: array of char);
begin
StringToArrayOfChar(aString, aArray);
end;

procedure StringToArrayOfChar(const aString: AnsiString; var aArray: array of ansichar);
begin
FillChar(aArray[Low(aArray)], Length(aArray)*SizeOf(AnsiChar), 0);
StrPLCopy(PAnsiChar(@aArray[Low(aArray)]), aString, Length(aArray)- 1);
end;

procedure Str2AC(const aString: AnsiString;var aArray: array of ansichar);
begin
FillChar(aArray[Low(aArray)], Length(aArray), 0);
StrPLCopy(PAnsiChar(@aArray[Low(aArray)]), aString, Length(aArray)- 1);
end;

procedure Str2PChar(const aString:string; var aDest : PChar);
begin
try
if Assigned(aDest)
   then FreeMem(aDest);
except
end;
aDest:=AllocMem(Length(aString)*SizeOfChar+1);
StrPCopy(aDest, aString);
end;

procedure Str2PChar(const aString:ansistring; var aDest : PAnsiChar);
begin
try
if Assigned(aDest)
   then FreeMem(aDest);
except
end;
aDest:=AllocMem(Length(aString)+1);
StrPCopy(aDest, aString);
end;


function String2DynInt(const aDelimiters,aSource : string; var aIDA : TIntegerDynArray) : boolean;
var
 sda : TStringDynArray;
 cnt : integer;
 tmp : string;
 ind : integer;
begin
Result:=false;
try
sda:=SplitString(aSource,aDelimiters);
for cnt:=0 to High(sda)
  do begin
  tmp:=trim(sda[cnt]);
  if CheckValidInteger(tmp)
     then begin
     ind:=Length(aIDA);
     SetLength(aIDA,ind+1);
     aIDA[ind]:=StrToInt(tmp);
     end;
  end;
Result:=Length(sda) = Length(aIDA);
except
on E : Exception do ;
end;
end;

function DynInt2String(const aDelimiter : string; const aIDA : TIntegerDynArray) : string;
var
 cnt : integer;
begin
Result:='';
if Length(aIDA)=0 then Exit;
for cnt:=0 to High(aIDA)-1 do Result:=Result+Format('%d%s',[aIDA[cnt], aDelimiter]);
Result:=Result+Format('%d',[aIDA[High(aIDA)]]);
end;


(*Перевод кодировок WIN - DOS. Обертка для CharToOEM и OEMToChar*)
function AnsiToOEM(const aSourceAnsi: AnsiString):string;
var
  res: PAnsiChar;
begin
  Result := '';
  if aSourceAnsi = '' then
    Exit;
  res := Allocmem(Length(aSourceAnsi)+ 1);
  try
    CharToOEMA(PAnsiChar(aSourceAnsi), res);
    Result := string(StrPas(res));
  finally
    FreeMem(res);
  end;
end;

function OEMToAnsi(const aSourceOEM: AnsiString):string;
var
  res: PAnsiChar;
begin
  Result := '';
  if aSourceOEM = '' then
    Exit;
  res := Allocmem(cardinal(Length(aSourceOEM))+ 1);
  try
    OEMToCharA(PAnsiChar(aSourceOEM), res);
    Result := string(StrPas(res));
  finally
    FreeMem(res);
  end;
end;

function StringInArray(const aTest:string; const aArray: array of string): boolean;
var
  cnt: integer;
begin
  Result := true;
  for cnt := 0 to High(aArray)do
    if aTest = aArray[cnt]then
      Exit;
  Result := false;
end;

// а вот тут по RFC5322 RegExp: http://habrahabr.ru/post/171667/
function CheckValidEMailAddress(const aAddr:string; var aResAddr : string): boolean;
var
 tst  : string;
 sda  : TStringDynArray;
 ln   : integer;
 ps   : integer;
 usr  : string;
 dom  : string;
 addr : string;
 cnt  : integer;
 ndc  : boolean;
 ipv4 : string;
begin
Result:=false;
aResAddr:='';
tst:=lowercase(trim(aAddr));
ln:=Length(tst);
if (ln=0) or (ln<>Length(StringReplace(tst,'@','',[rfReplaceAll]))+1) then Exit;
usr:='';
dom:='';
ps:=Pos('@',tst);
if (ps=1) or (ps=ln) then Exit;
for cnt:=ps-1 downto 1
  do if CharInSet(tst[cnt],['-', '+', '.', '_', 'a' .. 'z','0' .. '9'])
        then usr:=tst[cnt]+usr
        else Break;
if usr='' then Exit;
for cnt:=ps+1 to ln
  do if CharInSet( tst[cnt],['-', '.', '_', 'a' .. 'z','0' .. '9'])
        then dom:=dom+tst[cnt]
        else Break;
if dom='' then Exit;
// -- замедляет очень
ndc:=false;
if ndc
   then begin
   sda:=SplitString(dom,'.');
   if (Length(sda)>=2) and (Trim(sda[0])<>'') and (Length(Trim(sda[High(sda)]))=2)
      then begin
      ipv4:=NameToIPv4(dom);
      if ipv4='0.0.0.0' then Exit;
      end;
   end;
addr:=usr+'@'+dom;
usr:='';
SetLength(sda,0);
tst:=StringReplace(aAddr,addr,'',[rfIgnoreCase]);
if tst<>''
   then begin
   usr:=CopyFromTo(tst,'<','>',true,true);
   while usr<>'' do
     begin
     tst:=StringReplace(tst,usr,'',[]);
     cnt:=Length(sda);
     SetLength(sda,cnt+1);
     sda[cnt]:=usr;
     sda[cnt]:=trim(StringReplace(StringReplace(sda[cnt],'<',' ',[rfReplaceAll]),'>',' ',[rfReplaceAll]));
     usr:=CopyFromTo(tst,'<','>',true,true);
     end;
   usr:='';
   for cnt:=0 to High(sda)
      do usr:=usr+' '+sda[cnt];
  usr:=trim(usr);
  end;
if usr<>''
   then aResAddr:='<'+usr+'>'+addr
   else aResAddr:=addr;
Result:=True;
end;


(*проверка EMail адресов с возвратом валидного списка ************************)
function PrepareAddrList(const aSource:string; aCaseSensitive: boolean):string;
  function GetDottedText(const aSrc:string):string;
  var
    sda: TStringDynArray;
    cnt: integer;
    part:string;
  begin
    try
      sda := SplitString(aSrc, '.');
      Result := '';
      for cnt := 0 to High(sda)do
      begin
        part := Trim(sda[cnt]);
        if part <> '' then
          Result := Result + part + '.';
      end;
      SetLength(Result, Length(Result)- 1);
    finally
      SetLength(sda, 0);
    end;
  end;

var
  cnt: integer;
  sda: TStringDynArray;
  sdt: TStringDynArray;
  strl: TStringList;
  tmpAddr:string;
  //ipv4 : string;

begin
  Result := Trim(aSource);
  for cnt := 1 to Length(Result)do
    if not CharInSet(Result[cnt],['-', '.', '_', '@', 'a' .. 'z', 'A' .. 'Z',
      '0' .. '9'])then
      Result[cnt]:= ' ';
  sda := SplitString(Result, ' ');
  strl := TStringList.Create;
  try
    strl.CaseSensitive := aCaseSensitive;
    for cnt := 0 to High(sda)do
    begin
      tmpAddr := Trim(sda[cnt]);
      sdt := SplitString(tmpAddr, '@');
      if(tmpAddr <> '')//-- не пустой
        and(Length(sdt)= 2)//-- не 2 и больше @
        and((Trim(sdt[0])<> '')and(Trim(sdt[1])<> ''))
      //-- единственная @ не в начале и не в конце
        and(strl.IndexOf(tmpAddr)=-1)//-- еще не существует в списке
      then
        strl.Add(GetDottedText(sdt[0])+ '@' + GetDottedText(sdt[1]));
    end;
    //-- через это можно проверить валидность доменной части адреса....
    //for cnt:=0 to strl.Count-1
    //do begin
    //sdt:=SplitString(strl[cnt],'@');
    //try
    //if Length(sdt)>=2
    //then ipv4:=FnCommon.NameToIPv4(sdt[1]);
    //if ipv4<>'0.0.0.0'
    //then strl[cnt]:=strl[cnt]+Format(' (%s)',[ipv4]);
    //finally
    //SetLength(sdt,0);
    //end;
    //end;
    Result := trim(strl.CommaText);
  finally
    FreeStringList(strl);
    SetLength(sda, 0);
    SetLength(sdt, 0);
  end;

{UserPart:='';
while (cnt>=1) and (CharInSet(UPtest[cnt],['0'..'9','A'..'Z','-','.','_','$']))
  do begin
  UserPart:=Result[cnt]+Userpart;
  dec(cnt);
  end;
cnt:=AT_Pos+1;
DomainPart:='';
while (cnt<=Length(Result)) and (CharInSet(UPtest[cnt],['0'..'9','A'..'Z','-','.','_']))
  do begin
  DomainPart:=DomainPart+Result[cnt];
  inc(cnt);
  end;}
end;


function ExtractMsgId(const aSRC : string) : string;
var
 sda : TStringDynArray;
 cnt : integer;
begin
Result:='';
sda:=SplitString(aSRC,'<');
for cnt:=0 to High(sda)
  do if (Pos('@',sda[cnt])>0) and (Pos('>',sda[cnt])>0)
        then Result:=Result+'<'+Copy(sda[cnt],1,Pos('>',sda[cnt]))+daggerChar;
Result:=Copy(Result,1,Length(Result)-1);
end;


(*типа Soundex, Metaphone : возвращает "дистанцию" между буквами , поиск с опечатками*)
// ---------------------- old -----------------------------------
//from : http://www.delphimaster.net/view/15-1278909803
//function LevenshteinDistance(S, t:string): integer;
//  function Min(A, B, C: integer): integer;
//  begin
//    if A > B then
//      Result := B
//    else
//      Result := A;
//    if Result > C then
//      Result := C;
//  end;
//
//var
//  D: array[0 .. 50, 0 .. 50]of integer;
//  //хорошее число 50, если 4 отнять, и на 46 поделить - 1 будет :)
//  i, j: integer;
//  M, n: integer;
//begin
//  M := Length(S);
//  n := Length(t);
//  for i := 0 to M do
//    D[i, 0]:= i;//deletion
//  for j := 0 to n do
//    D[0, j]:= j;//insertion
//  for j := 1 to n do
//  begin
//    for i := 1 to M do
//    begin
//      if S[i]= t[j]then
//        D[i, j]:= D[i - 1, j - 1]
//      else
//        D[i, j]:= Min(D[i - 1, j]+ 1,//deletion
//          D[i, j - 1]+ 1,//insertion
//          D[i - 1, j - 1]+ 1//substitution
//          )
//    end;
//  end;
//  Result := D[M, n];
//end;


// поиск опечаток по методу "Расстояние Левенштейна"
// https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D1%81%D1%81%D1%82%D0%BE%D1%8F%D0%BD%D0%B8%D0%B5_%D0%9B%D0%B5%D0%B2%D0%B5%D0%BD%D1%88%D1%82%D0%B5%D0%B9%D0%BD%D0%B0
// http://wiki.freepascal.org/Levenshtein_distance

{------------------------------------------------------------------------------
  Name:    LevenshteinDistance
  Params: s1, s2 - UTF8 encoded strings
  Returns: Minimum number of single-character edits.
  Compare 2 UTF8 encoded strings, case sensitive.
------------------------------------------------------------------------------}

function LevenshteinDistance(const s1,s2 : string) : integer;
var
  length1, length2, i, j ,
  value1, value2, value3 : integer;
  matrix : array of array of integer;
begin
  length1 := Length( s1 );
  length2 := Length( s2 );
  SetLength (matrix, length1 + 1, length2 + 1);
  for i := 0 to length1 do matrix [i, 0] := i;
  for j := 0 to length2 do matrix [0, j] := j;
  for i := 1 to length1 do
    for j := 1 to length2 do
      begin
        if Copy( s1, i, 1) = Copy( s2, j, 1 )
          then matrix[i,j] := matrix[i-1,j-1]
          else  begin
            value1 := matrix [i-1, j] + 1;
            value2 := matrix [i, j-1] + 1;
            value3 := matrix[i-1, j-1] + 1;
            matrix [i, j] := min( value1, min( value2, value3 ));
          end;
      end;
  result := matrix [length1, length2];
end;

{------------------------------------------------------------------------------
  Name:    LevenshteinDistanceText
  Params: s1, s2 - UTF8 encoded strings
  Returns: Minimum number of single-character edits.
  Compare 2 UTF8 encoded strings, case insensitive.
------------------------------------------------------------------------------}
function LevenshteinDistanceText(const s1, s2: string): integer;
var
  s1lower, s2lower: string;
begin
  s1lower := LowerCase( s1 );
  s2lower := LowerCase( s2 );
  result := LevenshteinDistance( s1lower, s2lower );
end;


function UnQuotedStr(const aStr, aQuot:string):string;
var
  operstr : PChar;
  quot    : char;
begin
if Length(aQuot)=1
   then Result:=AnsiDequotedStr(aStr,aQuot[1])
   else begin
   operstr := AllocMem(Length(aStr)*SizeOfChar+1);
   try
   StrPCopy(operstr,aStr);
   quot:=(aQuot+' ')[1];
   Result := AnsiExtractQuotedStr(operstr,quot);
   finally
   Freemem(operstr);
   end;
  end
end;



function Old_FloatToHex(aFloat : single) : string;
var
 flt : single; // size = 4 bytes
 int : integer absolute flt;  // size = 4 bytes
begin
flt := aFloat;
Result:=IntTohex(int,8);
end;


function Old_FloatToHex(aFloat : double) : string;
var
 flt : double; // size = 8 bytes
 int : int64 absolute flt;  // size = 8 bytes
begin
flt := aFloat;
Result:=IntTohex(int,16);
end;


//  TSingleStruct = record
//  case boolean of
//    false : (float : single);
//    true  : (int   : integer);
//  end;
//  TDoubleStruct = record
//  case boolean of
//    false : (float : double);
//    true  : (int   : integer);
//  end;
//  TExtendedStruct = record
//  case boolean of
//    false : (float : extended);
//    true  : (int   : int64);
//  end;

function FloatToHex(aFloat : single) : string;  //4 bytes
var
 ss : TSingleStruct;
begin
ss.float:=aFloat;
Result:=IntToHex(ss.Int,8);
end;

function HexToFloat(const aHex : string; var aFloat : single): boolean;
var
 ss : TSingleStruct;
begin
Result:=false;
try
ss.int:=StrToInt('$'+StringReplace(aHex,'$','',[]));
aFloat:=ss.float;
Result:=true;
except
end;
end;

function FloatToHex(aFloat : double) : string; //8 bytes
var
 ds : TDoubleStruct;
begin
ds.float:=aFloat;
Result:=IntToHex(ds.Int,16);
end;

function HexToFloat(const aHex : string; var aFloat : double): boolean;
var
 ds : TDoubleStruct;
begin
Result:=false;
try
ds.int:=StrToInt('$'+StringReplace(aHex,'$','',[]));
aFloat:=ds.float;
Result:=true;
except
end;
end;

function FloatToHex(aFloat : extended) : string; //10 bytes
var
 es : TExtendedStruct;
begin
es.float:=aFloat;
Result:=IntToHex(es.Int,20);
end;

function HexToFloat(const aHex : string; var aFloat : extended): boolean;
var
 es : TExtendedStruct;
begin
Result:=false;
try
es.int:=StrToInt64('$'+StringReplace(aHex,'$','',[]));
aFloat:=es.float;
Result:=true;
except
end;
end;


//  HexDigit = ['0'..'9','A'..'F'];
function HexToBinary(val : int64) : string;
var
 hex : string;
 cnt : integer;
const
 BinValues : array[0..15] of string = ('0000','0001','0010','0011','0100','0101','0110','0111','1000','1001','1010','1011','1100','1101','1110','1111');
begin
hex:=IntToHex(val,16);
while (hex<>'') and (hex[1]='0') do hex:=Copy(hex,2,Length(hex));
if hex=''
   then Result:='00000000'
   else begin
   if odd(Length(hex)) then hex:='0'+hex;
   Result:='';
   for cnt:=1 to Length(hex) do Result:=Result+BinValues[StrToInt('$0'+hex[cnt])];
   end;
end;




(*
 procedure writedouble(doub : double);
  var
  fDecimal : double; // size = 8 bytes
  fInteger : int64 absolute fDecimal;  // size = 8 bytes
  str : ansistring;
  begin
  fDecimal := doub;
  ShowMessageInfo(format('%x=%f '+crlf+'%s',[fInteger,fDecimal,FloatToHex(doub)]));
  str:=FloatToHex(doub);
  fDecimal:=0;
  fInteger:=StrToInt64('$'+str);
  ShowMessageInfo(FloatToStr(fDecimal)+'='+Format('%x',[fInteger]));
  end;


  procedure writesingle(sing : single);
  var
  fDecimal : single; // size = 4 bytes
  fInteger : integer absolute fDecimal;  // size = 4 bytes
  str : ansistring;
  begin
  fDecimal := sing;
  ShowMessageInfo(format('%x=%f '+crlf+'%s',[fInteger,fDecimal,FloatToHex(sing)]));
  str:=FloatToHex(sing);
  fDecimal:=0;
  fInteger:=StrToInt('$'+str);
  ShowMessageInfo(FloatToStr(fDecimal)+'='+Format('%x',[fInteger]));
  end;
*)



procedure ShowMessageInfo(const aMessage:string;const aTitle:string = '');
var
  Title:string;
  Wnd: cardinal;
begin
  if aTitle = '' then
    Title := Application.Title
  else
    Title := aTitle;
  if Assigned(Application)//and Assigned(Application.MainForm)
     then Wnd := Application.Handle
     else Wnd := GetForegroundWindow;
  MessageBox(Wnd, PChar(aMessage), PChar(Title), MB_ICONINFORMATION + MB_OK);
end;

procedure ShowMessageWarning(const aMessage:string;const aTitle:string = '');
var
  Title:string;
  Wnd: cardinal;
begin
  if aTitle = '' then
    Title := Application.Title
  else
    Title := aTitle;
  if Assigned(Application)//and Assigned(Application.MainForm)
  then
    Wnd := Application.Handle
  else
    Wnd := GetForegroundWindow;
  MessageBox(Wnd, PChar(aMessage), PChar(Title), MB_ICONWARNING + MB_OK);
end;


threadvar
  MB_Wnd   : cardinal;
  MB_Dlg   : cardinal;
  MB_Title : string;
  MB_timer : integer;
  MB_Check : cardinal;
  MB_Wnds  : TWndDescrs;
  MB_Time  : TTime;
  MB_Btns  : array of  TMsgBoxBtnItem;


function EnumDlgChilds(WND : hwnd ; PARAM  : lParam) : boolean;stdcall; // -- поиск кнопок на MessageBox-е
var
 ind  :integer;
begin
Result := True;
if wnd <> 0
   then begin
   ind:=Length(MB_Wnds);
   Setlength(MB_Wnds,ind+1);
   MB_Wnds[ind].Handle:=Wnd;
   Str2AC(GetWindowClassName(Wnd),MB_Wnds[ind].ClassName);
   Str2AC(GetWndText(Wnd),MB_Wnds[ind].WndText);
   end
   else Result := False;
end;




procedure MBTimerProc(wnd: HWND; Msg: UINT; idEvent: UINT; Time: DWORD); stdcall;
var
 cnt    : integer;
 rctDlg : TRect;
 rctBtn : Trect;
 dlgdc  : hDC;
 dlgfnt : hFont;
 lf : TLogFont;
begin
MB_Dlg:=FindWindow('#32770',PChar(MB_Title));
try
if MB_Dlg<>0
 then begin
 dlgdc:=GetDC(MB_Dlg);
 try
 FillChar(lf, 0, SizeOf(TLogFont));
 dlgfnt:=SelectObject(dlgdc,CreateFontIndirect(lf));
 DeleteObject(SelectObject(dlgdc,dlgfnt));
 GetWindowRect(MB_Dlg, rctDlg);
 SetLength(MB_Wnds,0);
 EnumChildWindows(MB_Dlg,@EnumDlgChilds,0);
 for cnt:=0 to High(MB_Wnds)
   do if (Ac2Str(MB_Wnds[cnt].ClassName)='Button') and (MB_Check=0)
         then begin
         GetWindowRect(MB_Wnds[cnt].Handle, rctBtn);
         OffSetRect(rctBtn,-rctDlg.Left, -rctDlg.Top);
         MB_Check:=CreateWindow( 'BUTTON'
                               , PChar('Не показывать в дальнейшем')
                               , WS_CHILD or BS_AUTOCHECKBOX or BS_CHECKBOX or BS_NOTIFY
                               , GetSystemMetrics(SM_CXFRAME),rctBtn.Top - 20-2 - GetSystemMetrics(SM_CYCAPTION)
                               , rctDlg.Right- rctDlg.Left - GetSystemMetrics(SM_CXFRAME)*2, 20
                               , MB_Dlg
                               , 2001
                               , 0
                               , nil);
         //SetDlgItemInt(MB_DLG,2001,cardinal(PChar('Проверка свзяи!')),true);
         SendMessage(MB_Check,WM_SETFONT, SendMessage(MB_Wnds[cnt].Handle,WM_GETFONT,0,0),0);
         ShowWindow(MB_Check, SW_SHOW);
         Break;
         end;
 finally
 ReleaseDC(MB_Dlg,dlgdc);
 KillTimer(MB_Wnd,MB_timer);
 end;
 end;
finally

end;
end;


procedure ShowMessageWarning(var NoShow : boolean; const aMessage:string;const aTitle:string = '');
var
  Title:string;
  res : integer;
begin
  if aTitle = ''
    then Title := Application.Title
    else Title := aTitle;
  if Assigned(Application)//and Assigned(Application.MainForm)
     then MB_Wnd := Application.Handle
     else MB_Wnd := GetForegroundWindow;
MB_Title:=Title;
MB_timer:=integer(MB_Wnd);
MB_Check:=0;
SetTimer(MB_Wnd,MB_timer,10,@MBTimerProc);
try
sleep(1);
MessageBox(MB_Wnd, PChar(aMessage), PChar(Title), MB_ICONWARNING + MB_OK);
finally
NoShow:=false;
if MB_Check<>0
   then begin
   res:=SendDlgItemMessage(MB_Dlg,2001,BM_GETSTATE,0,0);
   if res=0 then res:=SendMessage(MB_Check,BM_GETSTATE,0,0);
   sleep(1);
   NoShow:=boolean(res=BST_CHECKED);
   DestroyWindow(MB_Check);
   end;
MB_timer:=0;
MB_Title:='';
SetLength(MB_Wnds,0);
KillTimer(MB_Wnd,MB_timer);
end;
end;


procedure ShowMessageError(const aMessage:string;const aTitle:string = '');
var
  Title:string;
  Wnd: cardinal;
begin
  if aTitle = '' then
    Title := Application.Title
  else
    Title := aTitle;
  if Assigned(Application)//and Assigned(Application.MainForm)
  then
    Wnd := Application.Handle
  else
    Wnd := GetForegroundWindow;
  MessageBox(Wnd, PWideChar(aMessage), PWideChar(Title), MB_ICONERROR + MB_OK);
end;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

procedure EnableOkButtons(dlg : cardinal; MakeEnabled : boolean);
var
 cnt : integer;
begin
SetLength(MB_Wnds,0);
EnumChildWindows(MB_Dlg,@EnumDlgChilds,0);
for cnt:=0 to High(MB_Wnds)
   do if (Ac2Str(MB_Wnds[cnt].ClassName)='Button')
     and (
          (GetDlgCtrlID(MB_Wnds[cnt].Handle) in [IDOK, IDYES]) or
          (((GetDlgCtrlID(MB_Wnds[cnt].Handle)=IDCANCEL) and ((AC2Str(MB_Wnds[cnt].WndText)='OK') or (AC2Str(MB_Wnds[cnt].WndText)='ОК')  // eng rus
           ))))
         then EnableWindow( MB_Wnds[cnt].Handle, MakeEnabled);
end;

procedure MBTimerProcThinkTime(wnd: HWND; Msg: UINT; idEvent: UINT; Time: DWORD); stdcall;
  procedure ShowThinkTime;
  var
    Sec    : int64;
    txtS   : string;
    txtP   : PChar;
    nowtime: TTime;
  begin
  try
  if MB_Check<>0
     then begin
     nowtime:=SysUtils.Time;
     Sec:=TimeToSeconds(MB_Time - nowtime);
     txtS:=Format('Осталось на размышление %d %s',[Sec, GetDefUnit(Sec, dfSecond)]);
     txtP:=AllocMem(Length(txtS)*SizeOfChar+1);
     try
     StrPCopy(txtP,txtS);
     SetWindowText(MB_Check, txtP);
     finally
     Freemem(txtP);
     txtS:='';
     end;
     if MB_Time<=nowtime
        then begin
        DestroyWindow(MB_Check);
        MB_Check:=0;
        EnableOkButtons(MB_Dlg, true);
        KillTimer(MB_Wnd,MB_timer);
        end;
     end;
  finally
  end;
  end;
var
 cnt    : integer;
 rctDlg : TRect;
 rctBtn : Trect;
begin
if MB_Check<>0 then ShowThinkTime
else begin
MB_Dlg:=FindWindow('#32770',PChar(MB_Title));
if MB_Dlg<>0
 then begin
 GetWindowRect(MB_Dlg, rctDlg);
 SetLength(MB_Wnds,0);
 EnumChildWindows(MB_Dlg,@EnumDlgChilds,0);
 for cnt:=0 to High(MB_Wnds)
   do if (Ac2Str(MB_Wnds[cnt].ClassName)='Button') and (MB_Check=0)
         then begin
         GetWindowRect(MB_Wnds[cnt].Handle, rctBtn);
         OffSetRect(rctBtn,-rctDlg.Left, -rctDlg.Top);
         MB_Check:=CreateWindow( 'STATIC'
                               , PChar('Время на размышление ...')
                               , WS_CHILD
                               , GetSystemMetrics(SM_CXFRAME),rctBtn.Top - 20-2 - GetSystemMetrics(SM_CYCAPTION)
                               , rctDlg.Right- rctDlg.Left - GetSystemMetrics(SM_CXFRAME)*2, 20
                               , MB_Dlg
                               , 2001
                               , 0
                               , nil);
         SendMessage(MB_Check,WM_SETFONT, SendMessage(MB_Wnds[cnt].Handle,WM_GETFONT,0,0),0);
         ShowWindow(MB_Check, SW_SHOW);
         ShowThinkTime;
         EnableOkButtons(MB_Dlg, false);
         Break;
         end;
end;
end;
end;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

function ShowMessageThink(ThinkTimeMS : integer; const strText, strCaption:string; uType : cardinal) :integer;
begin
  if Assigned(Application)//and Assigned(Application.MainForm)
     then MB_Wnd := Application.Handle
     else MB_Wnd := GetForegroundWindow;
MB_Title:=strCaption;
MB_timer:=integer(MB_Wnd);
MB_Check:=0;
MB_Time:=Time+MSecToTime(ThinkTimeMS);
if ThinkTimeMS>0
   then begin
   MB_Time:=Time+MSecToTime(ThinkTimeMS);
   SetTimer(MB_Wnd,MB_timer,10,@MBTimerProcThinkTime);
   end;
try
sleep(1);
Result:=MessageBox(MB_Wnd, PChar(strText), PChar(strCaption),uType);
finally
MB_timer:=0;
MB_Title:='';
SetLength(MB_Wnds,0);
if ThinkTimeMS>0
   then KillTimer(MB_Wnd,MB_timer);
end;
end;


function MsgBoxBtnItem(id: integer; const text : string) : TMsgBoxBtnItem; inline;
begin
Result.id:=id;
Result.text:=shortstring(text);
end;

procedure MBBtnChanger(wnd: HWND; Msg: UINT; idEvent: UINT; Time: DWORD); stdcall;
var
 cntB     : integer;
 cntW     : integer;
 wds      : TWndDescrs;
 winText  : string;
begin
try
MB_Dlg:=FindWindow('#32770',PChar(MB_Title));
if MB_Dlg<>0
   then begin
   try
   //wds.Fill(MB_Dlg, true);  // -- if wds is TWndDescrsEx
   ListOfWindows(MB_Dlg, wds);
   for cntW:=0 to High(wds)
     do begin
     for cntB:=0 to High(MB_Btns)
        do begin
        winText:=StringReplace(AnsiLowerCase(Ac2Str(wds[cntW].WndText)),'&','',[rfReplaceAll]);
        if Ac2Str(wds[cntW].ClassName)='Button'
           then begin
           if GetWindowLong(wds[cntW].Handle, GWL_ID) = MB_Btns[cntB].id
              then begin
              SetWindowText(wds[cntW].Handle,PChar(String(MB_Btns[cntB].text)));
              Break;
              end;
           end;
        end;
     end
   finally
   winText:='';
   SetLength(wds, 0);
   Setlength(MB_Btns,0);
   KillTimer(MB_Wnd,MB_timer);
   end;
   end;
finally
MB_Title:='';
end;
end;

procedure MessageBoxBtnChange(const DlgTitle : string; const Btns : array of TMsgBoxBtnItem);
var
 ln : integer;
begin
  if Assigned(Application)//and Assigned(Application.MainForm)
     then MB_Wnd := Application.Handle
     else MB_Wnd := GetForegroundWindow;
SetLength(MB_Title, Length(DlgTitle));
StrCopy(PChar(MB_Title),PChar(DlgTitle));
//MB_Title:=DlgTitle;  // -- memoryLeak in this case (threadvar, not clear)
ln:=Length(Btns);
Setlength(MB_Btns, ln);
if ln>0
   then System.Move(Btns[0],MB_Btns[0],ln*SizeOf(TMsgBoxBtnItem));
SetTimer(MB_Wnd,MB_timer,10,@MBBtnChanger);
end;


function MessageBoxBtns(hWnd: HWND; lpText, lpCaption: PWideChar; uType: UINT; const Btns : array of TMsgBoxBtnItem) : Integer;
begin
MessageBoxBtnChange(StrPas(lpCaption), Btns);
Result:=MessageBox(hWnd, lpText, lpCaption, uType);
end;


procedure CreatePSA(var aPSA: PSecurityAttributes);
var
  szPSA: integer;
begin
  szPSA := SizeOf(TSecurityAttributes);
  aPSA := Allocmem(szPSA);
  with aPSA^do
  begin
    nLength := szPSA;
    lpSecurityDescriptor := nil;
    bInheritHandle := LongBool(false);
  end;
end;

procedure InitalizePSA(var aPSA: PSecurityAttributes);
begin
  CreatePSA(aPSA);
end;

procedure CreatePSAEx(var aPSA: PSecurityAttributes);
var
  PSD  : PSecurityDescriptor;
  szPSA: integer;
begin
PSD := PSecurityDescriptor(LocalAlloc(LPTR, SECURITY_DESCRIPTOR_MIN_LENGTH));
if not Assigned(PSD) then RaiseLastOSError;
if not InitializeSecurityDescriptor(PSD, SECURITY_DESCRIPTOR_REVISION) then RaiseLastOSError;
if not SetSecurityDescriptorDacl(PSD, True, nil, False) then RaiseLastOSError;
szPSA := SizeOf(TSecurityAttributes);
aPSA := Allocmem(szPSA);
with aPSA^
  do begin
  nLength := szPSA;
  lpSecurityDescriptor := PSD;
  bInheritHandle := LongBool(true);
  end;
end;

procedure InitalizePSAEx(var aPSA: PSecurityAttributes);
begin
  CreatePSAEx(aPSA);
end;

(*Возвращает IP адрес локального компьютера*)
function LocalIP:string;
var
  phe: PHostEnt;
  pptr: PaPInAddr;
  Buffer: array[0 .. 63]of ansichar;
  i: integer;
  GInitData: TWSAData;
begin
  WSAStartup($101, GInitData);
  Result := '';
  try
    GetHostName(Buffer, SizeOf(Buffer));
    phe := gethostbyname(Buffer);
    if phe = nil then
      Exit;
    pptr := PaPInAddr(phe^.h_addr_list);
    i := 0;
    while pptr^[i]<> nil do
    begin
      Result := string(StrPas(inet_ntoa(pptr^[i]^)));
      Inc(i);
    end;
  finally
    WSACleanup;
  end;
end;


function GetIpConfig : string;
var
 fns : string;
 fnr : string;
 cmd : string;
 wtc : integer;
begin
Result:='';
try
fns:=SetTailBackSlash(GetTempFolder)+'get_ipconfig.bat';
fnr:=SetTailBackSlash(GetTempFolder)+'ipconfig.txt';
cmd:='chcp 1251'+crlf+'ipconfig /all >'+fnr;
SaveStringIntoFile(string(ansistring(cmd)),fns);
wtc:=0;
while not FileExists(fns)
  do begin
  _sleep(10);
  sleep(10);
  inc(wtc);
  if wtc>20 then Break;
  end;
if fileexists(fns)
   then WinExec(PAnsiChar(ansistring(fns)),SW_NORMAL)
   else begin
   Result:=Format('File "%s" not exists!',[fns]) ;
   Exit;
   end ;
wtc:=0;
_sleep(10);
sleep(10);
while not CanFileWrited(fnr)
  do begin
  _sleep(10);
  sleep(10);
  inc(wtc);
  if wtc>40 then Break;
  end;
//Result:=IntToStr(wtc)+crlf;  // --DEBUG ~3-5 cycles of waiting
if fileExists(fnr)
   then begin
   cmd:=LoadStringFromFileStream(fnr);
   cmd:=OEMToAnsi(ansiString(cmd));
   Result:=Result+cmd;
   DeleteFile(fnr);
   end;
if fileExists(fns)
   then DeleteFile(fns);
cmd := '';
fns := '';
fnr := '';
except
on E  : Exception
  do begin
  CreateErrorMessage('GetIpConfig',E,[],Result);
  end;
end;
end;

(*Получение имени рабочий станции*)
function GetWorkStationName:string;
var
  cnSize: cardinal;
  ComName: PChar;
begin
  cnSize := MAX_COMPUTERNAME_LENGTH * SizeOfChar+ 1;
  Result := '';
  ComName := Allocmem(cnSize);
  try
    GetComputerName(ComName, cnSize);
    Result := StrPas(ComName);
  finally
    FreeMem(ComName);
  end;
end;

function GetFullWorkStationName:string;
begin
Result:=IPv4ToName(LocalIP);
end;

(*Получение имени пользователя*)
function GetUserName:string;
var
  pUserName: PChar;
  iUserName: cardinal;
begin
  Result := '';
  iUserName := 255 * SizeOfChar+ 1;
  pUserName := Allocmem(iUserName);
  try
    Windows.GetUserName(pUserName, iUserName);
    Result := StrPas(pUserName);
  finally
    FreeMem(pUserName);
  end;
end;



function GetUserNameEx(ANameFormat: DWORD): string;
var
  Buf: array[0..256] of AnsiChar;
  BufSize: DWORD;
  _GetUserNameEx: function (NameFormat: DWORD; lpNameBuffer: LPSTR; var nSize: ULONG): boolean; stdcall;
begin
  Result := '';
  BufSize := SizeOf(Buf) div SizeOf(Buf[0]);
  _GetUserNameEx := GetProcAddress(GetModuleHandle('secur32.dll'), 'GetUserNameExA');
  if Assigned(_GetUserNameEx) then
    if _GetUserNameEx(ANameFormat, Buf, BufSize) then Result := string(StrPas(Buf));
end;

// есди надо выполнить команду ДОС , то это будет выглядеть так "cmd /C[command]"
// например
// command:='cmd /Cdir "C:\"';  // содержимое папки C:\
// command:='cmd /Cver';  // верия ОС
// ключ /C для cmd означает, что команда выполняется с завершением работы cmd (/K без завершения)
function RunCMD(const command: string):string;
const
    BUFSIZE = 1024 * 64;
var
    PSA         : PSecurityAttributes;
    hReadPipe   : THandle;
    hWritePipe  : THandle;
    StartupInfo : TStartUpInfoA;
    ProcessInfo : TProcessInformation;
    Buffer      : PAnsiChar;
    WaitReason  : dword;
    BytesRead   : dword;
    cmd         : ansistring;
begin  // start
 SetLastError(0);
 result:='';
 try
 CreatePSA(PSA);
 try
 PSA^.nLength:=SizeOf(TSecurityAttributes);
 PSA^.bInheritHandle:=true;
 PSA^.lpSecurityDescriptor:=nil;
 if Createpipe(hReadPipe, hWritePipe, PSA, 0)
    then begin
    Buffer:= AllocMem(BUFSIZE + 1);
    try
    FillChar(StartupInfo, Sizeof(TStartUpInfoA), #0);
    FillChar(ProcessInfo, Sizeof(TProcessInformation), #0);
    StartupInfo.cb:= SizeOf(TStartUpInfoA);
    StartupInfo.hStdOutput:= hWritePipe;
    StartupInfo.hStdInput:= hReadPipe;
    StartupInfo.dwFlags:= STARTF_USESTDHANDLES + STARTF_USESHOWWINDOW;
    StartupInfo.wShowWindow:= SW_HIDE;
    cmd:=AnsiString(command);
    if CreateProcessA(nil, PAnsiChar(cmd), PSA, PSA, true, NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo)
       then begin
       repeat
         WaitReason:= WaitForSingleObject( ProcessInfo.hProcess,100);
         Application.ProcessMessages;
       until(WaitReason <> WAIT_TIMEOUT);
       repeat
         BytesRead := 0;
         if ReadFile(hReadPipe, Buffer[0], BUFSIZE, BytesRead, nil)
            then
            else Break;
         Buffer[BytesRead]:= #0;
         //oemtoansi(Buffer,Buffer);
         result := result + String(StrPas(Buffer));
         //FillChar(Buffer,BUFSIZE,#0);
       until(BytesRead < BUFSIZE);
       end
       else begin
       Result:=GetErrorString(GetLastError);
       Exit;
       end; //end create process
    finally
    FreeMem(Buffer);
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
    CloseHandle(hReadPipe);
    CloseHandle(hWritePipe);
    end;
    end; //end create pipe
 finally
 FreeMem(PSA);
 end;
 Result:=OEMtoAnsi(AnsiString(Result));
 except
  on E : Exception do CreateErrorMessage('RunCMD',E,[command],Result);
 end;
end;

function RunCMD2(const command: string; toAnsi : boolean = true):string;
//function ExecAndWait(const FileName, Params: ShortString; const WinState: Word): boolean; export;
var
 StartInfo: TStartupInfo;
 ProcInfo : TProcessInformation;
 PSA      : PSecurityAttributes;
 fnm      : string;
 cmd      : string;
 cmd2      : string;
 res      : string;
 src      : string;
 Started  : boolean;
 errCode  : integer;
 errStr   : string;
 valComSpec : PChar;
begin
valComSpec:=AllocMem(1024);
Windows.GetEnvironmentVariable(PChar('COMSPEC'),valComSpec,1023);
SetLastError(0);
errCode:=0;
fnm := CreateUuid;
res := SetTailBackSlash(GetTempFolder)+fnm+'.txt';
cmd := SetTailBackSlash(GetTempFolder)+fnm+'.cmd';
try
//DeleteFile(PChar(res));
//DeleteFile(PChar(cmd));
src:=command+'>"'+res+'"'+crlf+'pause';
SaveStringIntoFile(src,cmd);
SaveStringIntoFile('result'+crlf,res);
  FillChar(StartInfo, SizeOf(StartInfo), #0);
  CreatePSA(PSA);

  with StartInfo do
  begin
    cb := SizeOf(TStartupInfo);
    dwFlags := (*STARTF_USESTDHANDLES or *)STARTF_USESHOWWINDOW;
    wShowWindow := SW_SHOW;
  end;
  cmd2:=StrPas(valComSpec)+' /C'+src ;
  Started := CreateProcess(nil
                          , PChar(cmd2)
                          , PSA
                          , PSA
                          , false
                          , CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS
                          , nil
                          , PChar(SetTailBackSlash(ExtractFilePath(StrPas(valComSpec))))//PChar(SetTailBackSlash(ExtractFilePath(cmd)))
                          , StartInfo
                          , ProcInfo);
//  _sleep(10);
  if Started then
  begin
    WaitForSingleObject(ProcInfo.hProcess, INFINITE);
    { Free the Handles }
    CloseHandle(ProcInfo.hProcess);
    CloseHandle(ProcInfo.hThread);
    FreeMem(PSA);
  end
  else begin
  errCode:=GetLastError;
  errStr:=GetErrorString(errCode);
  end;
if FileExists(res)
   then begin
   Result:=LoadStringFromFileStream(res);
   if toAnsi then
      Result:=OEMtoAnsi(AnsiString(Result));
   end
   else Result:='';
if errCode<>0
 then Result:=Result+crlf+errStr;
finally
DeleteFile(PChar(res));
DeleteFile(PChar(cmd));
//if StrPas(valComSpec)<>''
//   then Windows.SetEnvironmentVariable(PChar('COMSPEC'),valComSpec);
FreeMem(valComSpec);
end;
end;

// http://www.delphitop.com/html/xitong/3676.html
function RunCMD3(const command:string; toAnsi : boolean = true): string;
var
hReadPipe,hWritePipe:THandle;
si:STARTUPINFO;
lsa:SECURITY_ATTRIBUTES;
pi:PROCESS_INFORMATION;
cchReadBuffer:DWORD;
ph:PansiChar;
fname:PChar;
valComSpec : PChar;
begin
Result:='';
valComSpec:=AllocMem(1024);
Windows.GetEnvironmentVariable(PChar('COMSPEC'),valComSpec,1023);
fname:=allocmem(255);
ph:=AllocMem(5000);
lsa.nLength :=sizeof(SECURITY_ATTRIBUTES);
lsa.lpSecurityDescriptor :=nil;
lsa.bInheritHandle :=True;
try
try
if CreatePipe(hReadPipe,hWritePipe,@lsa,0)=false then
begin
//ShowMessage('Can not create pipe!');
exit;
end;
fillchar(si,sizeof(STARTUPINFO),0);
si.cb :=sizeof(STARTUPINFO);
si.dwFlags :=(STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW);
si.wShowWindow :=SW_HIDE;
si.hStdOutput :=hWritePipe;
//StrPCopy(fname,'C:\Windows\System32\cmd.exe /c '+command);
StrPCopy(fname,StrPas(valComSpec)+' /c '+command);
if CreateProcess( nil, fname, nil, nil, true, 0, nil, nil, si, pi) = False then
begin
ShowMessage('can not create process');
FreeMem(ph);
FreeMem(fname);
Exit;
end;
while(true) do
begin
if not PeekNamedPipe(hReadPipe,ph,1,@cchReadBuffer,nil,nil) then break;
if cchReadBuffer<>0 then
begin
if ReadFile(hReadPipe,ph^,4096,cchReadBuffer,nil)=false then break;
ph[cchReadbuffer]:=chr(0);
if ph<>'' then
begin
 Result := Result+string(AnsiString(ph));
end;
end
else if(WaitForSingleObject(pi.hProcess ,0)=WAIT_OBJECT_0) then break;
Application.ProcessMessages;
Sleep(100);
end;
ph[cchReadBuffer]:=chr(0);
if ph<>'' then Result := Result + string(AnsiString(ph));
if ToAnsi
   then Result:=OemToAnsi(AnsiString(Result));
CloseHandle(hReadPipe);
CloseHandle(pi.hThread);
CloseHandle(pi.hProcess);
CloseHandle(hWritePipe);
FreeMem(ph);
FreeMem(fname);
FreeMem(valComSpec);
except
end;
finally
end;
end;


function ConsolExec(const cmd : string; toAnsi : boolean) : string;
begin
Screen.Cursor:=crAppStart;
try
Result:=cmd+crlf+Replicate('-',15)+crlf;
try
Result:=Result+trim(RunCMD3(cmd,toAnsi))+crlf;
except
end;
finally
Screen.Cursor:=crDefault;
end;
end;

function ExecViaCMDFile(const command : string; needshowcommand : boolean) : string;
var
 csv : PChar;
 fnm : string;
 cmd : string;
 res : string;
 src : string;
begin
SetLastError(0);
csv:=AllocMem(1024);
Windows.GetEnvironmentVariable(PChar('COMSPEC'),csv,1023);
fnm := CreateUuidNum;
res := SetTailBackSlash(GetTempFolder)+fnm+'.txt';
SaveStringIntoFile('',res);
cmd := SetTailBackSlash(GetTempFolder)+fnm+'.cmd';
try
src:=command;//+'>'+res;
SaveStringIntoFile(src,cmd);
//Result:=RunCMD(StrPas(csv)+' /C'+cmd+''); //-- работает, но результат пустой
//Result:=RunCMD2(command); //-- работает, но результат пустой
//Result:=RunCMD('cmd /C'+command); //-- работает, но результат пустой
//Result:=RunCMD2('cmd /C'+src);
Result:=RunCMD2(src);
if FileExists(res)
   then Result:=Result+crlf+IfThen(needshowcommand,command+crlf,'')+LoadStringFromFile(res)
   else Result:=Result+crlf+GetErrorString;
finally
DeleteFile(PChar(res));
DeleteFile(PChar(cmd));
FreeMem(csv);
Result:=trim(Result);
end;

end;


function IsValidURL(const aURL : string) : boolean; // : http://www.bog.pp.ru/sitelife/URI.html
var
 scheme : string;
 url    : string;
 cnt    : integer;
begin
Result:=false;
scheme:=trim(LowerCase(Copy(aURL,1,Pos('://',aURL)-1)));
if scheme='' then Exit;
for cnt:=1 to Length(scheme)
  do if not CharInSet(scheme[cnt],['a'..'z','0'..'9','+','-','.'])
            then Exit;
url:=trim(lowercase(Copy(aURL,Pos('://',aURL)+3,Length(aURL))));
if url='' then Exit;
Result:=true;
end;

procedure ParseURL(const aURL : string; var aProto, aHost, aParams : string);
var
 url : string;
 ps  : integer;
begin
aProto :='';
aHost  :='';
aParams:='';
url:=Trim(aURL);
ps:=Pos(':',url);
if ps>0
   then aProto:=Copy(url,1,ps)+'//';
url:=StringReplace(url,aProto,'',[]);
ps:=Pos('/',url);
if ps>0
   then aHost:=Copy(url,1,ps-1)+'/'
   else aHost:=url;
aParams:=StringReplace(url,aHost,'',[]);
end;

 function GetDefaultPrinter: string;
 //var
 //  ResStr: array[0..255] of Char;
 begin
//   GetProfileString('Windows', 'device', '', ResStr, 255);
//   Result := StrPas(ResStr);
// или
 Result:='';
 if Printer.PrinterIndex>-1
   then Result:=Printer.Printers[Printer.PrinterIndex];
 end;


(*Нажать кнопку клавиатуры в окне*)
procedure WndKeyPress(const Wnd: HWND;const aKey: integer);
begin
  SendMessage(Wnd, WM_KEYDOWN, aKey, 1);
  SendMessage(Wnd, WM_KEYUP, aKey, 1);
end;

procedure SafeSetFocus2(aWinControl: TWinControl;var Focused: boolean);
begin
  Focused := boolean(Windows.SetFocus(aWinControl.Handle));
end;

procedure SetVisibleRow3(aGrid: TDrawGrid; aRow: integer);
//-- Вот эта вроде устойчиво работает
var
  IsFocused: boolean;
begin
  try
    SafeSetFocus2(aGrid, IsFocused);
    if not IsFocused then
      Exit;
    if(aRow >= aGrid.TopRow)and
      (aRow <= aGrid.TopRow + aGrid.VisibleRowCount - 1)then
    begin
      aGrid.Row := aRow;
      Exit;
    end;
    aGrid.Row := aRow;
    if(aRow >= 1)and(aRow < aGrid.RowCount - 1)then
    begin
      WndKeyPress(aGrid.Handle, VK_DOWN);
      sleep(1);
      WndKeyPress(aGrid.Handle, VK_UP);
      sleep(1);
    end
    else if(aRow = aGrid.RowCount - 1)and(aGrid.FixedRows - 1 < aRow)then
    begin
      WndKeyPress(aGrid.Handle, VK_UP);
      sleep(1);
      WndKeyPress(aGrid.Handle, VK_DOWN);
      sleep(1);
    end;
  except
    on E: Exception do
    begin
     //   ShowMessageError(Format('%d %d',[aGrid.RowCount, aRow]));
    end;
  end;
end;

function GetColRow(aDrGr : TDrawGrid; var aCol, aRow : integer) : boolean;
var
 pt : TPoint;
 gc : TGridCoord;
begin
GetCursorPos(pt);
Windows.ScreenToClient(aDrGr.Handle,pt);
gc:=aDrGr.MouseCoord(pt.X, pt.Y);
aCol:=gc.X;
aRow:=gc.Y;
Result:=(aCol>-1) and (aRow>-1)
end;

(*Получение имени приложения по имени файла (документа)*)
procedure GetDocumentEXEName(const FileName:string;var Result:string);
var
  dir, exe: PChar;
begin
  dir := Allocmem(MAX_PATH);
  exe := Allocmem(MAX_PATH);
  try
    if FindExecutable(PChar(FileName), dir, exe)> 0 then
      Result := StrPas(exe)
    else
      Result := '';
  finally
    FreeMem(dir);
    FreeMem(exe);
  end;
end;

(*Получение имени приложения по расширению файла (документа)*)
procedure GetEXENameForDocument(const DocExtention:string;var aEXEName:string);
var
  TestName:string;
  DocExtTmp:string;
  FileStream: TfileStream;
begin
  DocExtTmp := DocExtention;
  if(Length(DocExtTmp)> 0)and(DocExtTmp[1]<> '.')then
    DocExtTmp := '.' + DocExtTmp;
  TestName := SetTailBackSlash(GetTempFolder, true);
  TestName := ChangeFileExt(TestName + '_$$TestDoc$$_', DocExtTmp);
  FileStream := TfileStream.Create(TestName, fmCreate);
  try
    GetDocumentEXEName(TestName, aEXEName);
  finally
    FileStream.Free;
    if FileExists(TestName)then
      DeleteFile(TestName);
  end;
end;

function GetCurrentWordApp:string;
var
  EXEName:string;
  FileVer: TFileVersion;
  ResStr:string;
  RegKey: TRegistry;
begin
  Result := 'Word.Application';
  RegKey := TRegistry.Create;
  try
    RegKey.RootKey := HKEY_CLASSES_ROOT;
    if RegKey.KeyExists(Result + '\CurVer')then
    begin
      RegKey.OpenKeyReadOnly(Result + '\CurVer');
      Result := RegKey.ReadString('');
      RegKey.CloseKey;
    end
    else
      Result := '';
  finally
    RegKey.Free;
  end;
  if Result = '' then
  begin
    GetEXENameForDocument('.DOC', EXEName);
    FillChar(FileVer, SizeOf(TFileVersion), 0);
    GetFileVersion(EXEName, FileVer);
    if AnsiUpperCase(FileVer.InternalName)= 'WINWORD' then
    begin
      with FileVer do
        ResStr := StrPas(PChar(@ProductVersion[0]));
      ResStr := Copy(ResStr, 1, Pos('.', ResStr)- 1);
      if CheckValidInteger(ResStr)then
        Result := 'Word.Application.' + ResStr;
    end
    else
    begin
      //Типа FreeOffice
    end;
  end;
end;

function GetCurrentExcelApp:string;
var
  EXEName:string;
  FileVer: TFileVersion;
  ResStr:string;
  RegKey: TRegistry;
begin
  Result := 'Excel.Application';
  RegKey := TRegistry.Create();
  try
    RegKey.RootKey := HKEY_CLASSES_ROOT;
    if RegKey.KeyExists(Result + '\CurVer')then
    begin
      RegKey.OpenKeyReadOnly(Result + '\CurVer');
      Result := RegKey.ReadString('');
      RegKey.CloseKey;
    end
    else
      Result := '';
  finally
    RegKey.Free;
  end;
  if Result = '' then
  begin
    GetEXENameForDocument('.XLS', EXEName);
    FillChar(FileVer, SizeOf(TFileVersion), 0);
    GetFileVersion(EXEName, FileVer);
    if AnsiUpperCase(FileVer.InternalName)= 'EXCEL' then
    begin
      with FileVer do
        ResStr := StrPas(PChar(@ProductVersion[0]));
      ResStr := Copy(ResStr, 1, Pos('.', ResStr)- 1);
      if CheckValidInteger(ResStr)then
        Result := 'Excel.Application.' + ResStr;
    end
    else
    begin
      //Типа FreeOffice
    end;
  end;
end;

//алгоритм взят здесь : http://www.planetaexcel.ru/forum/index.php?PAGE_NAME=read&FID=8&TID=17978
function ExcelColNumIntoMnemonic(aNum: integer):String;
var
  Str:string;
  Val: Word;
begin
  Result := '';
  if(aNum < 0)or(aNum > 16384)then
    Exit;
  Val := Word(aNum);
  repeat
    Str := Chr(64 + Val Mod 26)+ Str;
    Val := Val div 26;
  until Val = 0;
  Result := Str;
  /// / max Col XFD    Row 1048576
  /// /         16384
End;

function ExcelColMnemonicToNum(const aValue:string): integer;
var
  cnt: integer;
  bytes: TByteDynArray;
begin
  SetLength(bytes, Length(aValue));
  for cnt := 0 to High(bytes)do
    bytes[cnt]:= Byte(ansichar(AnsiString(aValue)[cnt + 1]));
  Result := 0;
  for cnt := 0 to High(bytes)do
    Result := 26 * Result +(bytes[cnt]and 31);
End;

(*Выгрузка двухмерной таблицы в MSExcel через variant ************************)
procedure ArrayVariantToExcel(const aTitle:string;const aVarArray2D: variant;
  aBoldRowCount: integer = 0);
var
  _Excel: variant;
  _Book: variant;
  _Sheet: variant;
  _Select: variant;
  rows: cardinal;
  cols: cardinal;
  erc: integer;
  ers:string;
  tmp:string;
  res:string;
  defprn  :string;
  //c,r : integer;
const
  RowOffset: integer = 1;
  xlCenter =-4108;
  xlContinuous = 1;
  xlThin = 2;
  xlAutomatic =-4105;
  xlPortrait = 1;
  xlLandscape = 2;
  xlReadOnly = 3;//Read only.
  xlReadWrite = 2;//Read/write.

begin
defprn:=GetDefaultPrinter;
  CoInitialize(nil);
  try
    _Excel := CreateOleObject('Excel.Application');
    _Book := _Excel.Application.WorkBooks.Add;
    try
      while _Book.WorkSheets.Count > 1 do
        _Book.WorkSheets[_Book.WorkSheets.Count].Delete;
      _Sheet := _Book.WorkSheets[1];
      _Sheet.Activate;
      if defprn<>'' then try _Sheet.PageSetup.Orientation := xlLandscape; except  end;
      tmp := _Sheet.Name;
      try
        res := NormalizeExcelSheetName(aTitle);
        _Sheet.Name := res;
      except
        _Sheet.Name := tmp;
      end;
      _Book.WorkSheets[1].Select;
      rows := VarArrayHighBound(aVarArray2D, 1)+ 1;
      cols := VarArrayHighBound(aVarArray2D, 2)+ 1;
      //for r:=0 to rows-1 do
      //for c:=0 to cols-1 do
      //if aVarArray2D[r,c]=Unassigned
      //then aVarArray2D[r,c]:='';
      rows := rows + cardinal(integer(rows)= 1);
      cols := cols + cardinal(integer(cols)= 1);

      _Sheet.Range[_Sheet.Cells[1, 1], _Sheet.Cells[rows - 1, cols]].Select;
      _Select := _Excel.Selection;
      _Select.NumberFormat := '#0' + DecimalSeparator + '00';
      //_Select.NumberFormat:= '#0';
      _Sheet.Range[_Sheet.Cells[1, 1], _Sheet.Cells[rows - 1, cols]].Value :=
        aVarArray2D;
      //: // для формул _Sheet.Range[_Sheet.Cells[1,1],_Sheet.Cells[rows-1,cols]].FormulaArray:=aVarArray2D;
      //_Sheet.Range[_Sheet.Cells[1,1],_Sheet.Cells[rows-1,cols]].CopyPicture;
      _Sheet.Range[_Sheet.Cells[1, 1], _Sheet.Cells[rows - 1, cols]].Select;
      _Select := _Excel.Selection;
      _Select.VerticalAlignment := xlCenter;
      _Select.Borders.LineStyle := xlContinuous;
      _Select.Borders.Weight := xlThin;
      _Select.Borders.ColorIndex := xlAutomatic;
      _Select.Font.Name := 'Times New Roman';
      _Select.Font.Size := 10;

      if aBoldRowCount > 0 then
      begin
        _Sheet.Range[_Sheet.Cells[1, 1], _Sheet.Cells[aBoldRowCount,
          cols]].Select;
        _Select := _Excel.Selection;
        _Select.Font.Bold := true;
      end;
      _Book.WorkSheets[1].Range[_Book.WorkSheets[1].Cells[1, 1],
        _Book.WorkSheets[1].Cells[1, 1]].Select;
      _Sheet.UsedRange.EntireColumn.AutoFit;
      //_Sheet.UsedRange.Locked:=True;
      //_Sheet.Protect(DrawingObjects:=False
      //, Contents:=True
      //, Scenarios:=False
      //, AllowInsertingColumns:=True
      //, AllowInsertingRows:=True
      //, AllowInsertingHyperlinks:=True
      //, AllowDeletingColumns:=True
      //, AllowDeletingRows:=True);
      try
        (*work*)//_Book.ProtectSharing(Password:='jopa',SharingPassword:='jopa',WriteResPassword:='jopa');
        //_Book.Password:='jopa';
        //_Book.Protect(Password:='jopa',Structure:=True,Windows:=True);
      except

      end;

      _Excel.Visible := true;
    finally
      _Select := Unassigned;
      _Sheet := Unassigned;
      _Book := Unassigned;
      _Excel := Unassigned;
      CoUninitialize;
    end;
  except
    on E: Exception do
    begin
      _Excel.DisplayAlerts := false;
      if(_Excel <> Unassigned)and(_Excel.Application.WorkBooks.Count <= 1)then
        _Excel.Quit;
      erc := GetLastError;
      ers := Format('ArrayVariantToExcel("' + aTitle + '") : %s (%s).',
        [E.Message, GetErrorString(erc),GetWorkStationName,'Prn:'+DefPrn]);
      ShowMessageWarning(ers, 'Сообщение об ошибке');
    end;
  end;
end;

(*
 Name Value Description
 msoLanguageIDExeMode 4 Execution mode language.
 msoLanguageIDHelp 3 Help language.
 msoLanguageIDInstall 1 Install language.
 msoLanguageIDUI 2 User interface language.
 msoLanguageIDUIPrevious 5 User interface language used prior to the current user interface language.
*)



procedure ArrayVariantToExcelEx(const aTitle:string;const aVarArray2D: variant;
  aBoldRowCount: integer = 0);
var
  _Excel: variant;
  _Book: variant;
  _Sheet: variant;
  _Select: variant;
  rows: cardinal;
  cols: cardinal;
  erc: integer;
  ers:string;
  tmp:string;
  res:string;
  cnt: integer;
  hgt: integer;
  dtFormat:string;
  numFormat:string;
  intFormat:string;
  lcid: integer;
  defprn  :string;
const
  RowOffset: integer = 1;
  xlCenter =-4108;
  xlContinuous = 1;
  xlThin = 2;
  xlAutomatic =-4105;
  xlPortrait = 1;
  xlLandscape = 2;
  msoLanguageIDUI = 2;
begin
defprn:=GetDefaultPrinter;
  CoInitialize(nil);
  try
    _Excel := CreateOleObject('Excel.Application');
    lcid := _Excel.LanguageSettings.LanguageID[msoLanguageIDUI];
    if lcid = 1049{или $0419}
    then
      dtFormat := 'ДД.ММ.ГГГГ чч:мм:сс'
    else
      dtFormat := 'dd.mm.yyyy hh:nn:ss';
    intFormat := XL_GetIntFormat(_Excel);
    numFormat := XL_GetNumberFormat(_Excel);
    //dtFormat:=XL_GetShortDateFormat(_Excel);
    _Book := _Excel.Application.WorkBooks.Add;
    try
      while _Book.WorkSheets.Count > 1 do
        _Book.WorkSheets[_Book.WorkSheets.Count].Delete;
      _Sheet := _Book.WorkSheets[1];
      if defprn<>'' then try _Sheet.PageSetup.Orientation := xlLandscape; except end;
      tmp := _Sheet.Name;
      try
        res := NormalizeExcelSheetName(aTitle);
        _Sheet.Name := res;
      except
        _Sheet.Name := tmp;
      end;
      _Book.WorkSheets[1].Select;
      rows := VarArrayHighBound(aVarArray2D, 1);//+1;
      cols := VarArrayHighBound(aVarArray2D, 2);//+1;
      if(rows = 0)or(cols = 0)then
        Exit;
      //for r:=0 to rows-1 do
      //for c:=0 to cols-1 do
      //if aVarArray2D[r,c]=Unassigned
      //then aVarArray2D[r,c]:='';
      rows := rows + cardinal(integer(rows)= 1);
      cols := cols + cardinal(integer(cols)= 1);
      _Sheet.Range[_Sheet.Cells[1, 1], _Sheet.Cells[rows(*-1*), cols]].Select;
      _Select := _Excel.Selection;
      _Select.Value := aVarArray2D;
      //_Sheet.Range[_Sheet.Cells[1,1],_Sheet.Cells[rows-1,cols]].Value:=aVarArray2D;
      _Sheet.Range[_Sheet.Cells[1, 1], _Sheet.Cells[rows(*-1*), cols]].Select;
      _Select := _Excel.Selection;
      _Select.VerticalAlignment := xlCenter;
      _Select.Borders.LineStyle := xlContinuous;
      _Select.Borders.Weight := xlThin;
      _Select.Borders.ColorIndex := xlAutomatic;
      _Select.Font.Name := 'Times New Roman';
      _Select.Font.Size := 10;

      if aBoldRowCount > 0 then
      begin
        _Sheet.Range[_Sheet.Cells[1, 1], _Sheet.Cells[aBoldRowCount, cols]].Select;
        _Select := _Excel.Selection;
        _Select.Font.Bold := true;
//      Rows("1:1").Select
//    With ActiveWindow
//        .SplitColumn = 0
//        .SplitRow = 1
//    End With
//    ActiveWindow.FreezePanes = True
      end;

      //-- если без заголовка , то формат не нужен!....
      //-- а еще здесь : http://www.delphikingdom.com/asp/viewitem.asp?catalogid=920
      cnt := 0;
      try
        if VarArrayHighBound(aVarArray2D, 2)> 0 then
        begin
          hgt := VarArrayHighBound(aVarArray2D, 1)- 1;
          cnt := 1;
          //for cnt:=1 to cols
          while cnt <= integer(cols)do
          begin
            _Sheet.Range[_Sheet.Cells[1, cnt], _Sheet.Cells[rows, cnt]].Select;
            _Select := _Excel.Selection;
            case VarType(aVarArray2D[hgt, cnt - 1])of
              varDate:
                _Select.NumberFormat := dtFormat;

              varSmallint, varInteger, varBoolean, varShortInt, varByte,
                varWord, varLongWord, varInt64:
                _Select.NumberFormat := intFormat;

              varSingle, varDouble, varCurrency:
                _Select.NumberFormat := numFormat;
            else
              _Select.NumberFormat := '#0'
            end;
            Inc(cnt);
          end;
        end;
      except
        on E: Exception do
        begin
          CreateErrorMessage('ArrayVariantToExcelEx', E,[cnt, cols, rows], tmp);
          ShowMessageInfo(tmp);
        end;
      end;
      _Book.WorkSheets[1].Range[_Book.WorkSheets[1].Cells[1, 1],
        _Book.WorkSheets[1].Cells[1, 1]].Select;
      _Sheet.UsedRange.EntireColumn.AutoFit;
      //_Sheet.Protect(DrawingObjects:=False
      //, Contents:=True
      //, Scenarios:=False
      //, AllowInsertingColumns:=True
      //, AllowInsertingRows:=True
      //, AllowInsertingHyperlinks:=True
      //, AllowDeletingColumns:=True
      //, AllowDeletingRows:=True);
      _Excel.Visible := true;
    finally
      _Select := Unassigned;
      _Sheet := Unassigned;
      _Book := Unassigned;
      _Excel := Unassigned;
      CoUninitialize;
    end;
  except
    on E: Exception do
    begin
      if(_Excel <> Unassigned)and(_Excel.Application.WorkBooks.Count <= 1)then
      begin
        _Excel.DisplayAlerts := false;
        if _Excel.Application.WorkBooks.Count = 1 then
          _Book.Close;
        _Excel.Quit;
      end;
      erc := GetLastError;
      ers := Format('ArrayVariantToExcelEx("' + aTitle + '") : %s (%s).',
        [E.Message, GetErrorString(erc),GetWorkstationName,'Prn:'+defprn]);
      ShowMessageWarning(ers, 'Сообщение об ошибке');
    end;
  end;
end;

//----------------------------------------------------------------------------------------------
procedure ArrayVariantToExcelByCells(const aTitle:string;const aVarArray2D: variant; aECLS : TExcelCellLinkSet; aBoldRowCount: integer = 0);
begin
ArrayVariantToExcelByCells(null,aTitle,aVarArray2D,aECLS,aBoldRowCount);
end;


procedure ArrayVariantToExcelByCells(_Book : variant; const aTitle:string;const aVarArray2D: variant; aECLS : TExcelCellLinkSet; aBoldRowCount: integer = 0);
var
  needFree  : boolean;
  _Excel    : variant;
  _Sheet    : variant;
  _Select   : variant;
  defprn    : string;
  dtFormat  : string;
  numFormat : string;
  intFormat : string;
  lcid      : integer;
  rows      : cardinal;
  cols      : cardinal;
  cnt       : integer;
  hgt       : integer;
  cntR      : integer;
  cntC      : integer;
  fn        : string;
  fnDisp    : string;
const
  RowOffset       =       1;
  xlCenter        =   -4108;
  xlContinuous    =       1;
  xlThin          =       2;
  xlAutomatic     =   -4105;
  xlPortrait      =       1;
  xlLandscape     =       2;
  msoLanguageIDUI =       2;
begin
defprn:=GetDefaultPrinter;
needFree:=VarType(_Book)<>varDispatch;
try
if needFree
   then begin
   CoInitialize(nil);
   _Excel := CreateOleObject('Excel.Application');
   _Book := _Excel.Application.WorkBooks.Add;
   while _Book.WorkSheets.Count > 1
      do  _Book.WorkSheets[_Book.WorkSheets.Count].Delete;
   _Book.WorkSheets[1].Name:='new';
   end
   else _Excel:=_Book.Application;
try
lcid := _Excel.LanguageSettings.LanguageID[msoLanguageIDUI];
if lcid = 1049{или $0419}
   then dtFormat := 'ДД.ММ.ГГГГ чч:мм:сс'
   else dtFormat := 'dd.mm.yyyy hh:nn:ss';
intFormat := XL_GetIntFormat(_Excel);
numFormat := XL_GetNumberFormat(_Excel);
if (_Book.WorkSheets.Count=1) and (_Book.WorkSheets[1].Name='new')
    then _Sheet:= _Book.WorkSheets[1]
    else begin
    _Sheet:= _Book.WorkSheets.Add;
    _Sheet.Select;
    _Sheet.Move(After:=_Book.WorkSheets[_Book.WorkSheets.Count]);
    end;
if defprn<>''
    then try _Sheet.PageSetup.Orientation := xlLandscape; except end;
_Sheet.Name:=NormalizeExcelSheetName(aTitle);
_Sheet.Select;
rows := VarArrayHighBound(aVarArray2D, 1);//+1;
cols := VarArrayHighBound(aVarArray2D, 2);//+1;
if (rows = 0) or (cols = 0)
   then  Exit;
rows := rows + cardinal(integer(rows)= 1);
cols := cols + cardinal(integer(cols)= 1);
for cntR:=0 to rows -1
  do begin
  for cntC:=0 to cols -1
    do try
       fn:=aVarArray2D[cntR,cntC];
       if ((eclFile in aECLS) and FileExists(fn))
        or ((eclFolder in aECLS) and DirectoryExists(fn))
        or ((eclFolderOne in aECLS) and DirectoryExists(fn))
        or ((eclURL in aECLS) and (IsValidURL(fn)))
          then begin
          _Sheet.Range[_Sheet.Cells[cntR+1, cntC+1], _Sheet.Cells[cntR+1, cntC+1]].Select;
          _Select := _Excel.Selection;
          if DirectoryExists(fn) and (eclFolderOne in aECLS)
             then fnDisp:=SetTailbackSlash(StringReplace(fn,FnCommon.UpDirectoryN(fn,1),'',[rfIgnoreCase]),false)
             else fnDisp:=IfThen(FileExists(fn),ExtractFilename(fn),fn);
          _Sheet.Hyperlinks.Add(Anchor:=_Select, Address:=fn, ScreenTip:='Открыть '+AnsiQuotedStr(fn,'"'), TextToDisplay:=fnDisp);
          end
          else _Sheet.Cells[cntR+1, cntC+1]:=aVarArray2D[cntR,cntC];
      except
      end;
   end;
_Sheet.Range[_Sheet.Cells[1, 1], _Sheet.Cells[rows(*-1*), cols]].Select;
_Select := _Excel.Selection;
_Select.VerticalAlignment := xlCenter;
_Select.Borders.LineStyle := xlContinuous;
_Select.Borders.Weight := xlThin;
_Select.Borders.ColorIndex := xlAutomatic;
_Select.Font.Name := 'Times New Roman';
_Select.Font.Size := 10;
if aBoldRowCount > 0
   then  begin
   _Sheet.Range[_Sheet.Cells[1, 1], _Sheet.Cells[aBoldRowCount, cols]].Select;
   _Select := _Excel.Selection;
   _Select.Font.Bold := true;
   end;
cnt := 0;
try
  if VarArrayHighBound(aVarArray2D, 2)> 0
     then begin
     hgt := VarArrayHighBound(aVarArray2D, 1)- 1;
     cnt := 1;
     while cnt <= integer(cols)
       do begin
       _Sheet.Range[_Sheet.Cells[1, cnt], _Sheet.Cells[rows, cnt]].Select;
       _Select := _Excel.Selection;
       case VarType(aVarArray2D[hgt, cnt - 1]) of
          varDate:      _Select.NumberFormat := dtFormat;
          varSmallint
        , varInteger
        , varBoolean
        , varShortInt
        , varByte
        , varWord
        , varLongWord
        , varInt64:     _Select.NumberFormat := intFormat;
          varSingle
        , varDouble
        , varCurrency:  _Select.NumberFormat := numFormat;
      else              _Select.NumberFormat := '#0'
      end;
      Inc(cnt);
      end;
    end;

except
on E: Exception do ;//LogErrorMessage('Excel_WriteSheet(format)', E,[cnt, cols, rows]);
end;
_Sheet.Range[_Sheet.Cells[1, 1], _Sheet.Cells[1, 1]].Select;
_Sheet.UsedRange.EntireColumn.AutoFit;
except
on E: Exception
   do begin
   //LogErrorMessage('Excel_WriteSheet(format)', E,[aTitle]);
   if needFree
      then begin
      if(_Excel <> Unassigned)and(_Excel.Application.WorkBooks.Count <= 1)
        then  begin
        _Excel.DisplayAlerts := false;
         _Excel.DisplayAlerts := false;
         if(_Excel <> Unassigned)and(_Excel.Application.WorkBooks.Count <= 1)
            then begin
            _Excel.Quit;
            _Book:=Unassigned;
            end;
         _Excel:=Unassigned;
        end;
     end;
  end;
end;
finally
_Select := Unassigned;
_Sheet  := Unassigned;
if needFree
   then begin
   _Excel.Visible:=true;
   _Book   := Unassigned;
   _Excel  := Unassigned;
   CoUninitialize;
   end;
end;
end;
//------------------------------------------------------------------------------------------------------------------


procedure ArrayVariantToExcelEx(const aShablonName,aListName,aTitle : string;const aVarArray2D : variant; const aFormatList : TStringDynArray; aIsFormatCol: boolean; const aOffset : TGridCoord);
const
 xlOpenXMLWorkbook = 51;
 xlWorkbookDefault = 51;
 xlOpenXMLWorkbookMacroEnabled = 52;
var
 defprn     : string;
 r,c        : integer;
  _Excel    : variant;
  _Book     : variant;
  _Sheet    : variant;
  _Select   : variant;
  rows      : cardinal;
  cols      : cardinal;
  tmp       : string;
  erc : integer;
  ers : string;
//  xlFN: string;
begin
defprn:=GetDefaultPrinter;
try
CoInitialize(nil);
_Excel := CreateOleObject('Excel.Application');
try
_Book:=_Excel.Workbooks.Add(Template:=aShablonName);
_Sheet:=Unassigned;
for c:=1 to _Book.WorkSheets.Count
   do begin
   tmp:=_Book.WorkSheets[c].Name;
   if tmp=aListName
      then begin
      _Sheet:=_Book.WorkSheets[c];
      Break;
      end;
   end;
if VarType(_Sheet)<>VarDispatch
   then _Sheet:=_Book.WorkSheets.Add;
_Sheet.Name:=NormalizeExcelSheetName(aTitle);
_Sheet.Select;
rows := VarArrayHighBound(aVarArray2D, 1)+ 1;
cols := VarArrayHighBound(aVarArray2D, 2)+ 1;
cols := cols + cardinal(integer(cols)= 1);
rows := rows + cardinal(integer(rows)= 1);
_Sheet.Range[_Sheet.Cells[aOffset.Y, aOffset.X], _Sheet.Cells[cardinal(rows+cardinal(aOffset.Y-1)),cardinal(cols+cardinal(aOffset.X-1))]].Select;   //(ExStartCell.Y-1)
_Select := _Excel.Selection;
_Select.Value :=  aVarArray2D;
if aIsFormatCol
   then begin
   for c:=aOffset.X to cols
      do begin
      try
      _Sheet.Columns[c].Select;
      _Select := _Excel.Selection;
      if ((c-aOffset.X)>=Low(aFormatList)) and ((c-aOffset.X)<=High(aFormatList))
         then _Select.NumberFormat := aFormatList[c-aOffset.X];
      except
      on E  : Exception
        do begin
        CreateErrorMessage('ArrayVariantToExcelEx(Format)',E,[c,aIsFormatCol],tmp);
        end;
      end;
      end;
   end
   else begin
   for r:=aOffset.Y to rows
      do begin
      try
      _Sheet.Rows[r].Select;
      _Select := _Excel.Selection;
      if ((r-aOffset.Y)>=Low(aFormatList)) and ((r-aOffset.Y)<=High(aFormatList))
         then _Select.NumberFormat := aFormatList[r-aOffset.Y];
      except
      on E  : Exception
        do begin
        CreateErrorMessage('ArrayVariantToExcelEx(Format)',E,[c,aIsFormatCol],tmp);
        end;
      end;
      end;
   end;
_Sheet.Cells[aOffset.Y, aOffset.X].Select;

//
//   //xlFn:=_Excel.Application.GetSaveAsFilename;
//   //if xlFN<>'' then ;
//   xlFN:=SetTailBackSlash('C:\Users\s.kholin.KUPIVIP\Documents\KhS_Soft\MO_2585')+'Results\';
//   if not DirectoryExists(xlFN)
//      then if not ForceDirectories(xlFN)
//              then xlFN:=SetTailBackSlash(GetTempFolder);
//   xlFN:=xlFN+FormatDateTime('yyyymmdd_hhnnss_',Now)+_Book.FullName;//+'.xlxs';
//   if (VarType(_Book)=VarDispatch) and (VarType(_Excel)=VarDispatch)
//      then begin
//      _Excel.DisplayAlerts:=false;
//      //_Book.SaveAs(Filename:='D:\Work\res.xlsm', FormatFile:=xlOpenXMLWorkbookMacroEnabled, CreateBackup:=False,Local:=true);
//      _Book.SaveAs(Filename:='D:\Work\res.xlsm');
//      //_Book.Close;
////      ChDir "C:\Users\s.kholin.KUPIVIP\Documents\KhS_Soft\MO_2585\Results"
////    ActiveWorkbook.SaveAs Filename:= _
////        "C:\Users\s.kholin.KUPIVIP\Documents\KhS_Soft\MO_2585\Results\20151204_112953_REPORT2.xlxs.xlsx" _
////        , FileFormat:=xlOpenXMLWorkbook, CreateBackup:=False
//      end;
//   xlFN:=_Book.FullName;
//   ShowMessageInfo(xlFN);

//'OLE error 800A03EC'.


finally
_Excel.Visible := true;
CoUnInitialize;
_Select := Unassigned;
_Sheet := Unassigned;
_Book := Unassigned;
_Excel := Unassigned;
end;
  except
    on E: Exception do
    begin
      if(_Excel <> Unassigned)and(_Excel.Application.WorkBooks.Count <= 1)then
      begin
        _Excel.DisplayAlerts := false;
        if _Excel.Application.WorkBooks.Count = 1 then
          _Book.Close;
        _Excel.Quit;
      end;
      erc := GetLastError;
      ers := Format('ArrayVariantToExcelEx(Shablon) : %s (%s).',
        [E.Message, GetErrorString(erc),GetWorkstationName,'Prn:'+defprn,aShablonName,aListName,aTitle]);
      ShowMessageWarning(ers, 'Сообщение об ошибке');
    end;
  end;
end;

procedure GetExcelSheets(const ExcelFileName : string; var sheets : TStringDynArray);
var
 appName  : string;
 excel    : variant;
 workbook : variant;
 cnt  : integer;
begin
SetLength(sheets,0);
appName:=GetCurrentExcelApp;
excel:=CreateOleObject(IfThen(appName<>'',appName,'Excel.Application'));
try
excel.DisplayAlerts := false;
workbook:=excel.Workbooks.Open(ExcelFileName,True) ;
SetLength(sheets, integer(workbook.Sheets.Count));
for cnt:=0 to high(sheets)
  do sheets[cnt]:=workbook.Sheets[cnt+1].Name;
finally
if excel.Workbooks.Count = 1 then excel.Quit;
workbook:=unassigned;
excel:=unassigned;
end
end;

procedure ExcelToArrayVariant(const ExcelFileName : string; SheetNum,Rows,Columns : integer; var Cells : variant);
var
 appName  : string;
 excel    : variant;
 workbook : variant;
 sheet    : variant;
 select   : variant;
 col,row  : integer;
begin
Cells:=Unassigned;
appName:=GetCurrentExcelApp;
excel:=CreateOleObject(IfThen(appName<>'',appName,'Excel.Application'));
try
excel.DisplayAlerts := false;
sheet:=excel.Workbooks.Open(ExcelFileName,True) ;
sheet:=sheet.Worksheets[SheetNum];
sheet.Activate;
if Rows>0
   then row:=Rows
   else row:=sheet.UsedRange.Rows.Count;
if Columns>0
   then col:=Columns
   else col:=sheet.UsedRange.Columns.Count;
Cells:=VarArrayCreate([1,col+1,1,row+1],varVariant);
sheet.Range[sheet.Cells[1, 1], sheet.Cells[row,col]].Select;
select:=excel.Selection;
Cells:=select.Value;
finally
if excel.Workbooks.Count = 1 then excel.Quit;
select:=unassigned;
sheet:=unassigned;
workbook:=unassigned;
excel:=unassigned;
end
end;



const
  xl24HourClock = 33;
  //True if you’re using 24-hour time; False if you’re using 12-hour time.
  xl4DigitYears = 43;
  //True if you’re using four-digit years; False if you’re using two-digit years.
  xlAlternateArraySeparator = 16;
  //Alternate array item separator to be used if the current array separator is the same as the decimal separator.
  xlColumnSeparator = 14;//Character used to separate columns in array literals.
  xlCountryCode = 1;//Country/Region version of Microsoft Excel.
  xlCountrySetting = 2;
  //Current country/region setting in the Windows Control Panel.
  xlCurrencyBefore = 37;
  //True if the currency symbol precedes the currency values; False if it follows them.
  xlCurrencyCode = 25;//Currency symbol.
  xlCurrencyDigits = 27;
  //Number of decimal digits to be used in currency formats.
  xlCurrencyLeadingZeros = 40;
  //True if leading zeros are displayed for zero currency values.
  xlCurrencyMinusSign = 38;
  //True if you’re using a minus sign for negative numbers; False if you’re using parentheses.
  xlCurrencyNegative = 28;
  //Currency format for negative currency values:0 = (symbolx) or (xsymbol)1 = -symbolx or -xsymbol2 = symbol-x or x-symbol3 = symbolx- or xsymbol-where symbol is the currency symbol of the country or region. Note that the position of the currency symbol is determined by xlCurrencyBefore.
  xlCurrencySpaceBefore = 36;
  //True if a space is added before the currency symbol.
  xlCurrencyTrailingZeros = 39;
  //True if trailing zeros are displayed for zero currency values.
  xlDateOrder = 32;
  //Order of date elements:0 = month-day-year1 = day-month-year2 = year-month-day
  xlDateSeparator = 17;//Date separator (/).
  xlDayCode = 21;//Day symbol (d).
  xlDayLeadingZero = 42;//True if a leading zero is displayed in days.
  xlDecimalSeparator = 3;//Decimal separator.
  xlGeneralFormatName = 26;//Name of the General number format.
  xlHourCode = 22;//Hour symbol (h).
  xlLeftBrace = 12;
  //Character used instead of the left brace ({) in array literals.
  xlLeftBracket = 10;
  //Character used instead of the left bracket ([) in R1C1-style relative references.
  xlListSeparator = 5;//List separator.
  xlLowerCaseColumnLetter = 9;//Lowercase column letter.
  xlLowerCaseRowLetter = 8;//Lowercase row letter.
  xlMDY = 44;
  //True if the date order is month-day-year for dates displayed in the long form; False if the date order is day-month-year.
  xlMetric = 35;
  //True if you’re using the metric system; False if you’re using the English measurement system.
  xlMinuteCode = 23;//Minute symbol (m).
  xlMonthCode = 20;//Month symbol (m).
  xlMonthLeadingZero = 41;
  //True if a leading zero is displayed in months (when months are displayed as numbers).
  xlMonthNameChars = 30;
  //Always returns three characters for backward compatibility. Abbreviated month names are read from Microsoft Windows and can be any length.
  xlNoncurrencyDigits = 29;
  //Number of decimal digits to be used in noncurrency formats.
  xlNonEnglishFunctions = 34;
  //True if you’re not displaying functions in English.
  xlRightBrace = 13;
  //Character used instead of the right brace (}) in array literals.
  xlRightBracket = 11;
  //Character used instead of the right bracket (]) in R1C1-style references.
  xlRowSeparator = 15;//Character used to separate rows in array literals.
  xlSecondCode = 24;//Second symbol (s).
  xlThousandsSeparator = 4;//Zero or thousands separator.
  xlTimeLeadingZero = 45;//True if a leading zero is displayed in times.
  xlTimeSeparator = 18;//Time separator (:).
  xlUpperCaseColumnLetter = 7;//Uppercase column letter.
  xlUpperCaseRowLetter = 6;//Uppercase row letter (for R1C1-style references).
  xlWeekdayNameChars = 31;
  //Always returns three characters for backward compatibility. Abbreviated weekday names are read from Microsoft Windows and can be any length.
  xlYearCode = 19;//Year symbol in number formats (y).
  xlWorkbookDefault = 51;

function XL_GetDecimalSeparator : string;
var
  XLApp : variant;
begin
Result:=FormatSettings.DecimalSeparator;
XLApp:= CreateOleObject('Excel.Application');
try
Result := VarToStr(XLApp.Application.International[xlDecimalSeparator]);
finally
XLApp:=Unassigned;
end;
end;


function XL_GetShortDateFormat:String;
var
  XLApp : variant;
begin
XLApp:= CreateOleObject('Excel.Application');
try
Result:=XL_GetShortDateFormat(XLApp);
finally
XLApp:=Unassigned;
end
end;


function XL_GetShortDateFormat(XLApp: variant):String;
var
  D, M, Y: integer;
begin
  D := 1 + integer(boolean(XLApp.Application.International[xlDayLeadingZero]));
  M := 1 + integer(boolean(XLApp.Application.International[xlMonthLeadingZero])
    );//-- или как в следующем, но! не прямым в integer
  Y := 2 + 2 * integer(XLApp.Application.International[xl4DigitYears]= true);
  Result := Format('%1:s%0:s%2:s%0:s%3:s',
    [DateSeparator, StringOfChar(VarToStr(XLApp.Application.International
    [xlDayCode])[1], D), StringOfChar(VarToStr(XLApp.Application.International
    [xlMonthCode])[1], M), StringOfChar(VarToStr(XLApp.Application.International
    [xlYearCode])[1], Y)]);
end;

function XL_GetNumberFormat:String;
var
  XLApp : variant;
begin
XLApp:= CreateOleObject('Excel.Application');
try
Result := XL_GetNumberFormat(XLApp);
finally
XLApp:=Unassigned;
end
end;

function XL_GetNumberFormat(XLApp: variant):String;
var
  thSep:string;
  decSep:string;
  curDig:string;
begin
  thSep := VarToStr(XLApp.Application.International[xlThousandsSeparator]);
  decSep := VarToStr(XLApp.Application.International[xlDecimalSeparator]);
  curDig := StringOfChar('0',
    integer(XLApp.Application.International[xlCurrencyDigits]));
  Result := Format('#%s##0%s%s',[thSep, decSep, curDig]);
end;

function XL_GetIntFormat:String;
var
  XLApp : variant;
begin
XLApp:= CreateOleObject('Excel.Application');
try
Result := XL_GetIntFormat(XLApp);
finally
XLApp:=Unassigned;
end
end;

function XL_GetIntFormat(XLApp: variant):String;
var
  thSep:string;
begin
  thSep := VarToStr(XLApp.Application.International[xlThousandsSeparator]);
  Result := Format('#%s##0',[thSep]);
end;


function XL_GetCurrencyFormat(aLCID: integer):String;
var
   XLApp : variant;
begin
XLApp:= CreateOleObject('Excel.Application');
try
 Result := XL_GetCurrencyFormat(XLApp,aLCID);
finally
XLApp:=Unassigned;
end
end;

function XL_GetCurrencyFormat(XLApp: variant; aLCID: integer):String;
begin
  Result := Format('%s "%s"',[XL_GetNumberFormat(XLApp),
    XLApp.Application.International[xlCurrencyCode]]);
end;


//
//procedure ExcelToArrayVariant(const aFileName : string;var aVarArray2D : variant);
//var
//_Excel : variant;
//_Book  : variant;
//_Sheet : variant;
//_Select: variant;
//rows : cardinal;
//cols : cardinal;
//erc : integer;
//ers : string;
//tmp : string;
//res : string;
/// / c,r : integer;
//const
//RowOffset : integer = 1;
//xlCenter     = -4108;
//xlContinuous = 1;
//xlThin       = 2;
//xlAutomatic  = -4105;
//xlPortrait   = 1;
//xlLandscape  = 2;
//xlReadOnly   = 3;// Read only.
//xlReadWrite  = 2;// Read/write.
//
//begin
//CoInitialize(nil);
//try
//_Excel:=CreateOleObject('Excel.Application');
//_Book:=_Excel.Application.WorkBooks.Add;
//try
//while _Book.WorkSheets.Count>1 do _Book.WorkSheets[_Book.WorkSheets.Count].Delete;
//_Sheet:=_Book.WorkSheets[1];
//try _Sheet.PageSetup.Orientation := xlLandscape; except end;
//tmp:=_Sheet.Name;
//try
//res:=NormalizeExcelSheetName(aTitle);
//_Sheet.Name:=res;
//except
//_Sheet.Name:=tmp;
//end;
//_Book.WorkSheets[1].Select;
//rows:=VarArrayHighBound(aVarArray2D,1)+1;
//cols:=VarArrayHighBound(aVarArray2D,2)+1;
/// /for r:=0 to rows-1 do
/// /  for c:=0 to cols-1 do
/// /    if aVarArray2D[r,c]=Unassigned
/// /       then aVarArray2D[r,c]:='';
//rows:=rows+cardinal(integer(rows)=1);
//cols:=cols+cardinal(integer(cols)=1);
//
//_Sheet.Range[_Sheet.Cells[1,1],_Sheet.Cells[rows-1,cols]].Select;
//_Select:=_Excel.Selection;
//_Select.NumberFormat:= '#0'+DecimalSeparator+'00';
/// /_Select.NumberFormat:= '#0';
//_Sheet.Range[_Sheet.Cells[1,1],_Sheet.Cells[rows-1,cols]].Value:=aVarArray2D;
/// / : // для формул _Sheet.Range[_Sheet.Cells[1,1],_Sheet.Cells[rows-1,cols]].FormulaArray:=aVarArray2D;
/// /_Sheet.Range[_Sheet.Cells[1,1],_Sheet.Cells[rows-1,cols]].CopyPicture;
//_Sheet.Range[_Sheet.Cells[1,1],_Sheet.Cells[rows-1,cols]].Select;
//_Select:=_Excel.Selection;
//_Select.VerticalAlignment:= xlCenter;
//_Select.Borders.LineStyle:= xlContinuous ;
//_Select.Borders.Weight:= xlThin;
//_Select.Borders.ColorIndex:= xlAutomatic;
//_Select.Font.Name:='Times New Roman';
//_Select.Font.Size:=10;
//
//if aBoldRowCount>0
//then begin
//_Sheet.Range[_Sheet.Cells[1,1],_Sheet.Cells[aBoldRowCount,cols]].Select;
//_Select:=_Excel.Selection;
//_Select.Font.Bold:=True;
//end;
//_Book.WorkSheets[1].Range[_Book.WorkSheets[1].Cells[1,1],_Book.WorkSheets[1].Cells[1,1]].Select;
//_Sheet.UsedRange.EntireColumn.AutoFit;
/// /_Sheet.UsedRange.Locked:=True;
/// /_Sheet.Protect(DrawingObjects:=False
/// /             , Contents:=True
/// /             , Scenarios:=False
/// /             , AllowInsertingColumns:=True
/// /             , AllowInsertingRows:=True
/// /             , AllowInsertingHyperlinks:=True
/// /             , AllowDeletingColumns:=True
/// /             , AllowDeletingRows:=True);
//try
//(*work*)//_Book.ProtectSharing(Password:='jopa',SharingPassword:='jopa',WriteResPassword:='jopa');
/// /_Book.Password:='jopa';
/// /_Book.Protect(Password:='jopa',Structure:=True,Windows:=True);
//except
//
//end;
//
//
//_Excel.Visible:=True;
//finally
//_Select:=Unassigned;
//_Sheet:=Unassigned;
//_Book:=Unassigned;
//_Excel:=Unassigned;
//CoUninitialize;
//end;
//except
//on E : Exception
//do begin
//_Excel.DisplayAlerts:=False;
//if (_Excel<>Unassigned) and (_Excel.Application.WorkBooks.Count<=1)
//then _Excel.Quit;
//erc:=GetLastError;
//ers:=Format('ArrayVariantToExcel("'+aTitle+'") : %s (%s).',[E.Message,GetErrorString(erc)]);
//ShowMessageWarning(ers,'Сообщение об ошибке');
//end;
//end;
//end;

function ScrollMessageBox(const aTopText, aMLText, aBottomText, ACaption:string;
  aIconType: integer; aBtnType: integer; HTML : boolean = false): integer;
var
  _mbForm: TForm;
  _mbIco: TImage;
  _mbTopText: TLabel;
  _mbText: TMemo;
  _mbWB : TWebBrowser;
  _mbBottomText: TLabel;
  _mbBtns: array of TBitBtn;
  cnt: integer;

  procedure CreateButton(aIndex, aModalResult: integer);
  var
    ln: integer;
  begin
    ln := Length(_mbBtns);
    _mbBtns[aIndex]:= TBitBtn.Create(_mbForm);
    with _mbBtns[aIndex]do
    begin
      Parent := _mbForm;
      Top := _mbBottomText.Top + _mbBottomText.height + 4;
      Width := cnt;
      case aIndex of
        0:
          case ln of
            1:
              Left := Parent.ClientWidth div 2 - cnt div 2;
            2:
              Left := Parent.ClientWidth div 2 - cnt - 2;
            3:
              Left := Parent.ClientWidth div 2 - cnt div 2 - cnt - 4;
          end;
        1:
          case ln of
            2:
              Left := Parent.ClientWidth div 2 + 2;
            3:
              Left := Parent.ClientWidth div 2 - cnt div 2;
          end;
        2:
          case ln of
            3:
              Left := Parent.ClientWidth div 2 + cnt div 2 + 2;
          end;
      end;
      ModalResult := aModalResult;
      case ModalResult of
        mrNone:     Caption := '&None';
        mrOk:       Caption := '&Ok';
        mrCancel:   Caption := '&Cancel';
        mrAbort:    Caption := '&Abort';
        mrRetry:    Caption := '&Retry';
        mrIgnore:   Caption := '&Ignore';
        mrYes:      Caption := '&Yes';
        mrNo:       Caption := '&No';
        mrAll:      Caption := '&All';
        mrNoToAll:  Caption := '&No to all';
        mrYesToAll: Caption := '&Yes to all';
      end;
      //Anchors:=[AkBottom];
    end;
  end;

  procedure SetLabelHeight(aLabel : TLabel);
  var
    strHgt : integer;
    tmpHgt : integer;
    needDop: boolean;
  begin
  if ''=aLabel.Caption
     then aLabel.Height:=1
     else begin
     strHgt:=aLabel.Canvas.TextHeight('QЙ');
     tmpHgt:=GetTextHeightByWidth(aLabel.Caption,aLabel.Font, aLabel.Width, true);
     needDop:=(tmpHgt / strHgt)>1;
     tmpHgt:=(Trunc(tmpHgt / strHgt)+integer(needDop))*strHgt+4;
     aLabel.Height:=tmpHgt;
     end;
  end;

var
 wdt : integer;
 hgt : integer;
 fn  : string;
begin
  _mbForm := TForm.Create(Application);
  _mbIco := TImage.Create(_mbForm);
  _mbTopText := TLabel.Create(_mbForm);
  if not HTML
     then begin
     _mbText := TMemo.Create(_mbForm);
     _mbWB:=nil;
     end
     else begin
     _mbWB := TWebBrowser.Create(_mbForm);
     _mbText:=nil;
     end;
  _mbBottomText := TLabel.Create(_mbForm);
  try
    with _mbForm do
    begin
      Width := Screen.Width div 3;
      Left := Screen.Width div 2 - Width div 2;
      Top := Screen.height div 2 - height div 2;
      Caption := ACaption;
      //BorderStyle:=bsDialog;
      BorderStyle := bsSizeable;
      BorderIcons :=[];
      Position := poMainFormCenter;
      Autoscroll := false;
    end;
    with _mbIco do
    begin
      Parent := _mbForm;
      Left := 4;
      Top := 8;
      Width := 45;
      height := 45;
      AutoSize := true;
      case aIconType of
        MB_ICONERROR:       Picture.Icon.Handle := LoadIcon(0, IDI_ERROR);
        MB_ICONQUESTION:    Picture.Icon.Handle := LoadIcon(0, IDI_QUESTION);
        MB_ICONWARNING:     Picture.Icon.Handle := LoadIcon(0, IDI_WARNING);
        MB_ICONINFORMATION: Picture.Icon.Handle := LoadIcon(0, IDI_INFORMATION);
        MB_ICONAPPLICATION: Picture.Icon.Handle := Application.Icon.Handle;// LoadIcon(0,IDI_APPLICATION);
        else Picture.Icon.Handle := LoadIcon(0, IDI_WINLOGO);
      end;
    end;
    with _mbTopText do
    begin
      Parent := _mbForm;
      Top := 4;
      Left := _mbIco.Left + _mbIco.Width + 4;
      AutoSize := false;
      WordWrap:=true;
      Width:=Parent.ClientWidth - Left - 4;
      Caption := aTopText;
    end;
    SetLabelHeight(_mbTopText);

    hgt:=(_mbForm.Canvas.TextHeight('QЙ')+ 1)* 6 + GetSystemMetrics(SM_CYHSCROLL) +  GetSystemMetrics(SM_CYFRAME);//100;
    wdt:=_mbForm.ClientWidth - (_mbIco.Left + _mbIco.Width + 4) - 4;
    if not HTML and Assigned(_mbText)
       then begin
       with _mbText do
       begin
         Parent := _mbForm;
         Top := _mbTopText.Top + _mbTopText.height + 2;
         Left := _mbIco.Left + _mbIco.Width + 4;
         Width := wdt;
         height := hgt;
         if Pos(CopyRightChar,aMLText)=1
            then begin
            WordWrap := true;
            Lines.Text := Copy(aMLText,2,Length(aMLText));
            ScrollBars := ssVertical;
            end
            else begin
            WordWrap := false;
            Lines.Text := aMLText;
            ScrollBars := ssBoth;
            end;
         ReadOnly := true;
       end;
       end
       else
    if Assigned(TWinControl(_mbWB))
       then begin
         TWinControl(_mbWB).Parent := _mbForm;
         TWinControl(_mbWB).Top := _mbTopText.Top + _mbTopText.height + 2;
         TWinControl(_mbWB).Left := _mbIco.Left + _mbIco.Width + 4;
         TWinControl(_mbWB).Width := wdt;
         TWinControl(_mbWB).height := hgt;
         TWinControl(_mbWB).Update;
         TWinControl(_mbWB).Visible:=true;
         if aMLText<>''
            then begin
            fn:=SetTailbackSlash(GetTempFolder)+NormalizeStringSysPath(CreateUuid)+'.html';
            try
            SaveStringIntoFileStream(aMLText, fn);
            _mbWB.Navigate('file://'+fn);
            finally
            DeleteFile(fn);
            end;
            end
            else _mbWB.Navigate('about:blank');

       end;
    hgt:=hgt+ _mbTopText.Top + _mbTopText.height + 2;
    with _mbBottomText do
    begin
      Parent := _mbForm;
      Top := hgt + 6;
      Left := _mbIco.Left + _mbIco.Width + 4;
      AutoSize := false;
      WordWrap := true;
      Width:=Parent.ClientWidth - Left - 4;
      Caption := aBottomText;
    end;
    SetLabelHeight(_mbBottomText);

    cnt :=(_mbForm.Width div 5)- 4;
    case aBtnType of
      MB_OKCANCEL:
        begin
          SetLength(_mbBtns, 2);
          CreateButton(0, mrOk);
          CreateButton(1, mrCancel);
        end;
      MB_ABORTRETRYIGNORE:
        begin
          SetLength(_mbBtns, 2);
          CreateButton(0, mrAbort);
          CreateButton(1, mrRetry);
          CreateButton(2, mrIgnore);
        end;
      MB_YESNOCANCEL:
        begin
          SetLength(_mbBtns, 3);
          CreateButton(0, mrYes);
          CreateButton(1, mrNo);
          CreateButton(2, mrCancel);
        end;
      MB_YESNO:
        begin
          SetLength(_mbBtns, 2);
          CreateButton(0, mrYes);
          CreateButton(1, mrNo);
        end;
      MB_RETRYCANCEL:
        begin
          SetLength(_mbBtns, 2);
          CreateButton(0, mrRetry);
          CreateButton(1, mrCancel);
        end;
    else
      begin
        SetLength(_mbBtns, 1);
        CreateButton(0, mrOk);
      end;
    end;
    _mbForm.Constraints.MinHeight := 0;
    _mbForm.ClientHeight := _mbBtns[0].Top + _mbBtns[0].height+4;
    with _mbForm.Constraints do
      begin
        MinWidth := _mbForm.Width;
        MinHeight := _mbForm.Height;
      end;
    _mbTopText.Anchors :=[akLeft, akTop, akRight];
    if not HTML and Assigned(_mbText)
      then _mbText.Anchors :=[akLeft, akTop, akRight, akBottom]
      else
    if Assigned(TWinControl(_mbWB))
      then begin
      TWinControl(_mbWB).Width := wdt;
      if Length(_mbBtns)>0
         then TWinControl(_mbWB).Height := _mbBtns[0].Top - TWinControl(_mbWB).Top - 4
         else TWinControl(_mbWB).Height := _mbForm.ClientHeight - TWinControl(_mbWB).Top - 4;
      TWinControl(_mbWB).Anchors :=[akLeft, akTop, akRight, akBottom];
      end;
    _mbBottomText.Anchors :=[akLeft, akRight, akBottom];
    for cnt := 0 to High(_mbBtns)do
      _mbBtns[cnt].Anchors :=[akBottom];
    if Assigned(TWinControl(_mbWB))
       then _mbForm.Height:=_mbForm.Height*2;
    try
    _mbForm.Position := poDesigned;
    RestorePosition(_mbForm,Application.ExeName,aCaption);
    except
    _mbForm.Position := poMainFormCenter;
    end;
    Result := _mbForm.ShowModal;
  finally
    for cnt := High(_mbBtns)downto 0 do
      FreeAndNil(_mbBtns[cnt]);
    SetLength(_mbBtns, 0);
    FreeAndNil(_mbIco);
    if Assigned(_mbText)then FreeAndNil(_mbText);
    //if Assigned(_mbWB)then FreeAndNil(_mbWB);
    try
    SavePosition(_mbForm,Application.ExeName,aCaption);
    except
    end;
    FreeAndNil(_mbForm);
  end;
end;

procedure SetWidthOfDropDownList(aCB: TComboBox);
var
  cnt: integer;
  wdt: integer;
begin
  wdt := aCB.Width;
  for cnt := 0 to aCB.Items.Count - 1 do
    if aCB.Canvas.TextWidth(aCB.Items[cnt])> wdt then
      wdt := aCB.Canvas.TextWidth(aCB.Items[cnt]);
  wdt := wdt + GetSystemMetrics(SM_CXVSCROLL)* 2;
  SendMessage(aCB.Handle, CB_SETDROPPEDWIDTH, wdt, 0);
end;

procedure SetWidthOfDropDownList(aCB: TComboBox; aWidth : integer);
begin
  SendMessage(aCB.Handle, CB_SETDROPPEDWIDTH, aWidth, 0);
end;

function ShiftDown: boolean;
var
  State: TKeyboardState;
begin
  GetKeyboardState(State);
  Result :=((State[vk_Shift]and 128)<> 0);
end;

function AltDown: boolean;
var
  State: TKeyboardState;
begin
  GetKeyboardState(State);
  Result :=((State[vk_Menu]and 128)<> 0);
end;

function CtrlDown: boolean;
var
  State: TKeyboardState;
begin
  GetKeyboardState(State);
  Result :=((State[vk_Control]And 128)<> 0);
end;



(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)
procedure Sound(Frequency, Duration: integer);
asm
  push edx
  push eax
  mov eax, Win32Platform
  cmp eax, VER_PLATFORM_WIN32_NT
  jne @@9X
  call Windows.Beep
  ret
@@9X:
  pop eax
  pop edx
  push ebx
  push edx
  mov bx, ax
  mov ax, 34DDh
  mov dx, 0012h
  cmp dx, bx
  jnc @@2
  div bx
  mov bx, ax
  in al, 61h
  test al, 3
  jnz @@1
  or al, 3
  out 61h, al
  mov al, 0B6h
  out 43h, al
@@1:
  mov al, bl
  out 42h, al
  mov al, bh
  out 42h, al
  call Windows.Sleep
  in al, 61h
  and al, 0FCh
  out 61h, al
  jmp @@3
@@2:
  pop edx
@@3:
  pop ebx
end;
(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)


procedure Monitor_On;
begin
SendMessage(HWND_BROADCAST, WM_SYSCOMMAND, SC_MONITORPOWER, -1);
end;

procedure Monitor_Off;
begin
SendMessage(HWND_BROADCAST, WM_SYSCOMMAND, SC_MONITORPOWER, 2);
end;

procedure Monitor_SavePower;
begin
SendMessage(HWND_BROADCAST, WM_SYSCOMMAND, SC_MONITORPOWER, 1);
end;

function GetMonitorAspectRatio(Width,Height : integer) : string;
var
 cnt : integer;
begin   //https://www.scp-garant.ru/service/news/razreshenie_jekranov_sootnoshenie_storon/
for cnt:=0 to High(MonitorAspectRatio)
  do if (MonitorAspectRatio[cnt].Width = Width) and
        (MonitorAspectRatio[cnt].Height = Height)
        then begin
        Result:=string(MonitorAspectRatio[cnt].Aspect);
        Exit;
        end;
end;

(******************************************************************************)
(******************************************************************************)
(******************************************************************************)

function IsModal(aForm : TForm) : boolean;
begin
Result:=False;
try
Result:=(fsModal in aForm.FormState);
except
end;
end;

(* Удаление секции из файла INI*)
function DeleteSection(const INIFileName, SectionName : string) : boolean;
var
 ini : TIniFile;
begin
Result:=false;
try
if not FileExists(INIFileName) then Exit;
ini:= TIniFile.Create(INIFileName);
try
if ini.SectionExists(SectionName)
     then ini.EraseSection(SectionName);
Result:=not ini.SectionExists(SectionName);
finally
ini.Free;
end
except
end;
end ;

(*Сохранение позиции формы*)
procedure SavePosition(aCtrl: TWinControl;const aEXEName:string;
  const aSection:string = 'Position');
var
  ext:string;
  cfg: TINIFile;
begin
  //if not Assigned(aCtrl)
  //then Exit;
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    cfg.WriteInteger(aSection, aCtrl.Name + '_Top', aCtrl.Top);
    cfg.WriteInteger(aSection, aCtrl.Name + '_Left', aCtrl.Left);
    cfg.WriteInteger(aSection, aCtrl.Name + '_Width', aCtrl.Width);
    cfg.WriteInteger(aSection, aCtrl.Name + '_Height', aCtrl.height);
    if aCtrl is TForm then cfg.WriteInteger(aSection, aCtrl.Name + '_WS', integer((aCtrl as TForm).WindowState));
//      case(aCtrl as TForm).WindowState of
//        wsNormal:
//          cfg.WriteInteger(aSection, aCtrl.Name + '_WS', 0);
//        wsMinimized:
//          cfg.WriteInteger(aSection, aCtrl.Name + '_WS', 1);
//        wsMaximized:
//          cfg.WriteInteger(aSection, aCtrl.Name + '_WS', 2);
//      end;

  finally
    FreeAndNil(cfg);
  end;
end;

procedure SaveSize(aCtrl: TWinControl;const aEXEName:string;
  const aSection:string = 'Position');
var
  ext:string;
  cfg: TINIFile;
begin
  //if not Assigned(aCtrl)
  //then Exit;
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    cfg.WriteInteger(aSection, aCtrl.Name + '_Width', aCtrl.Width);
    cfg.WriteInteger(aSection, aCtrl.Name + '_Height', aCtrl.height);
  finally
    FreeAndNil(cfg);
  end;
end;

procedure SavePos(aCtrl: TWinControl;const aEXEName:string;
  const aSection:string = 'Position');
var
  ext:string;
  cfg: TINIFile;
begin
  //if not Assigned(aCtrl)
  //then Exit;
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    cfg.WriteInteger(aSection, aCtrl.Name + '_Top', aCtrl.Top);
    cfg.WriteInteger(aSection, aCtrl.Name + '_Left', aCtrl.Left);
  finally
    FreeAndNil(cfg);
  end;
end;

(*Восстановление позиции формы*)
procedure RestorePosition(aCtrl: TWinControl;const aEXEName:string; const aSection:string = 'Position');
var
  //WS         : Byte;//-1,wsNormal, wsMinimized, wsMaximized
  cfg        : TINIFile;
  rctF       : TRect;
  rctD       : TRect;
  rgnD       : hRGN;
  cntMonitor : integer;
  onMonitor  : boolean;
const
  Divider = 5;
var
  ext:string;
begin
  if not Assigned(aCtrl)then
    Exit;
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;

  try
    aCtrl.Top := cfg.ReadInteger(aSection, aCtrl.Name + '_Top', aCtrl.Top);
    aCtrl.Left := cfg.ReadInteger(aSection, aCtrl.Name + '_Left', aCtrl.Left);
    aCtrl.Width := cfg.ReadInteger(aSection, aCtrl.Name + '_Width',
      aCtrl.Width);
    aCtrl.height := cfg.ReadInteger(aSection, aCtrl.Name + '_Height',
      aCtrl.height);
    if aCtrl is TForm
       then  begin
       (aCtrl as TForm).WindowState := TWindowState(cfg.ReadInteger(aSection, aCtrl.Name + '_WS', 0));
//      WS := cfg.ReadInteger(aSection, aCtrl.Name + '_WS', 0);
//      case WS of
//        1:
//          (aCtrl as TForm).WindowState := wsMinimized;
//        2:
//          (aCtrl as TForm).WindowState := wsMaximized;
//      else
//        (aCtrl as TForm).WindowState := wsNormal;
//    end;
    (*HIDED PATH*) (*20131007*)
     if (((aCtrl as TForm)= Application.MainForm)or
        not Assigned(Application.MainForm))and
        ((aCtrl as TForm).WindowState = wsMinimized)
        then (aCtrl as TForm).WindowState := wsNormal;
      end;
  if aCtrl.InheritsFrom(TForm)
     then begin
     //rctF :=(aCtrl as TForm).BoundsRect;
     //with (aCtrl as TForm) do rctF:=Bounds(Left,Top,Width,Height);
     with aCtrl do rctF:=Bounds(Left,Top,Width,Height);
     onMonitor:=false;
     for cntMonitor:=0 to Screen.MonitorCount-1
        do begin
        with Screen.Monitors[cntMonitor].BoundsRect do rgnD := CreateRectRgn(Left,Top,Right,Bottom);
        try
        if RectInRegion(rgnD, rctF)
           then begin
           onMonitor:=true;
           if Screen.MonitorCount>1
              then (aCtrl as TForm).DefaultMonitor:=dmDesktop;
           Break;
           end;
        finally
        DeleteObject(rgnD);
        end;
        end;
     if not onMonitor
        then begin
        if (aCtrl as TForm).FormStyle=fsMDIChild
           then begin
           with (aCtrl as TForm) do
              begin
              WindowState := wsNormal;
              Position:=poDefault;
              end;
           end
           else begin
           SystemParametersInfo(SPI_GETWORKAREA,0,@rctD,0); // -- это основной монитор
           with (aCtrl as TForm) do
              begin
              WindowState := wsNormal;
              Left:=Random(100)+10;
              Top:=Random(100)+10;
//              Left:=20;
//              Top:=20;
              Width:=(rctD.Right-rctD.Left) - Left*2;
              Height:=(rctD.Bottom-rctD.Top) - Top*2;
              end;
              end;
           end;

  end;
finally
  FreeAndNil(cfg);
end;
end;

procedure RestoreSize(aCtrl: TWinControl;const aEXEName:string;
  const aSection:string = 'Position');
var
  cfg: TINIFile;
  ext:string;
begin
  if not Assigned(aCtrl)then
    Exit;
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    aCtrl.Width := cfg.ReadInteger(aSection, aCtrl.Name + '_Width',
      aCtrl.Width);
    aCtrl.height := cfg.ReadInteger(aSection, aCtrl.Name + '_Height',
      aCtrl.height);
  finally
    FreeAndNil(cfg);
  end;
end;

procedure RestorePos(aCtrl: TWinControl;const aEXEName:string;
  const aSection:string = 'Position');
var
  cfg: TINIFile;
  ext:string;
begin
  if not Assigned(aCtrl)then
    Exit;
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    aCtrl.Left := cfg.ReadInteger(aSection, aCtrl.Name + '_Left', aCtrl.Left);
    aCtrl.Top := cfg.ReadInteger(aSection, aCtrl.Name + '_Top', aCtrl.Top);
  finally
    FreeAndNil(cfg);
  end;
end;


procedure CheckFormPos(aForm : TCustomForm);
var
 Scr   : TRect;
 IsMax : boolean;
begin
IsMax:=aForm.WindowState = wsMaximized;
Scr:=Screen.WorkAreaRect;
aForm.WindowState := wsNormal;
if Scr.Left-10>aForm.Left then aForm.Left:=0;
if Scr.Top-10>aForm.Top then aForm.Top:=0;
if Scr.Right-Scr.Left>aForm.Width then aForm.Width:=Scr.Right-Scr.Left;
if Scr.Bottom-Scr.Top>aForm.Height then aForm.Height:=Scr.Bottom-Scr.Top;
if IsMax then aForm.WindowState := wsMaximized;
end;


procedure CheckWindowPos(aWnd : cardinal);
var
 Rct   : TRect;
 Scr   : TRect;
 IsMax : boolean;
begin
isMax:=IsZoomed(aWnd);
GetWindowRect(aWnd,rct);
SystemParametersInfo(SPI_GETWORKAREA,0,@Scr,0);
ShowWindow(aWnd,SW_NORMAL);
if Scr.Left>Rct.Left then Rct.Left:=Scr.Left;
if Scr.Top>Rct.Top then Rct.Top:=Scr.Top;
if Rct.Right-Rct.Left>Scr.Right then Rct.Right:=Scr.Right;
if Rct.Bottom-Rct.Top>Scr.Bottom then Rct.Bottom:=Scr.Bottom;
SetWindowPos(aWnd,0,rct.Left, rct.Top, rct.Right-rct.Left, rct.Bottom-rct.Top, SWP_NOZORDER or SWP_SHOWWINDOW);
if isMax then ShowWindow(aWnd,SW_MAXIMIZE);
end;

function GetWindowByCursor : cardinal;
var
 pt  : TPoint;
begin
GetCursorPos(pt);
Result:=WindowFromPoint(pt);
end;

(*Сохранение размеров колонок*)
procedure SaveColumns(aForm: TForm; aGrid: TDrawGrid;const aEXEName:string;
  const aSection:string = 'Position');
var
  cnt: integer;
  ext:string;
  cfg: TINIFile;
begin
  if not Assigned(aForm)or not Assigned(aGrid)then
    Exit;
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    for cnt := 0 to aGrid.ColCount - 1 do
      cfg.WriteInteger(aSection, aForm.Name + '_' + aGrid.Name + '_Col' +
        IntToStr(cnt), aGrid.ColWidths[cnt]);
  finally
    FreeAndNil(cfg);
  end;
end;

procedure SaveColumns(aForm: TForm; aListView: TListView;const aEXEName:string;
  const aSection:string = 'Position');
var
  cnt: integer;
  ext:string;
  cfg: TINIFile;
begin
  if not Assigned(aForm)or not Assigned(aListView)then
    Exit;
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    for cnt := 0 to aListView.Columns.Count - 1 do
      cfg.WriteInteger(aSection, aForm.Name + '_' + aListView.Name + '_Col' +
        IntToStr(cnt), aListView.Columns[cnt].Width);
  finally
    FreeAndNil(cfg);
  end;
end;

(*Восстановление размеров колонок*)
procedure RestoreColumns(aForm: TForm; aGrid: TDrawGrid;const aEXEName:string;
  const aSection:string = 'Position');
var
  cnt: integer;
  ext:string;
  cfg: TINIFile;
begin
  if not Assigned(aForm)or not Assigned(aGrid)then
    Exit;
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    aForm.Update;
    for cnt := 0 to aGrid.ColCount - 1
      do aGrid.ColWidths[cnt]:= cfg.ReadInteger(aSection,aForm.Name + '_' + aGrid.Name + '_Col' + IntToStr(cnt), aGrid.DefaultColWidth);
  finally
    FreeAndNil(cfg);
  end;
end;

procedure RestoreColumns(aForm: TForm; aListView: TListView;
  const aEXEName:string;const aSection:string = 'Position');
var
  cnt: integer;
  ext:string;
  cfg: TINIFile;
begin
  if not Assigned(aForm)or not Assigned(aListView)then
    Exit;
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    aForm.Update;
    for cnt := 0 to aListView.Columns.Count - 1 do
      aListView.Columns[cnt].Width := cfg.ReadInteger(aSection,
        aForm.Name + '_' + aListView.Name + '_Col' + IntToStr(cnt), 50);
  finally
    FreeAndNil(cfg);
  end;
end;

(*Сохранение размеров колонок при разных конфигурациях*)
procedure SaveColumnsEx(aForm: TForm; aGrid: TDrawGrid;const aEXEName:string;
  const aSection:string = 'Position');
var
  cnt: integer;
  ext:string;
  cfg: TINIFile;
begin
  if not Assigned(aForm)or not Assigned(aGrid)then
    Exit;
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    for cnt := 0 to aGrid.ColCount - 1 do
      cfg.WriteInteger(aSection, aForm.Name + '_' + aGrid.Name + '_cfg' +
        IntToStr(aGrid.ColCount)+ '_Col' + IntToStr(cnt), aGrid.ColWidths[cnt]);
  finally
    FreeAndNil(cfg);
  end;
end;


(*Восстановление размеров колонок  при разных конфигурациях*)
procedure RestoreColumnsEx(aForm: TForm; aGrid: TDrawGrid;const aEXEName:string;
  const aSection:string = 'Position');
var
  cnt: integer;
  ext:string;
  cfg: TINIFile;
begin
  if not Assigned(aForm)or not Assigned(aGrid)then
    Exit;
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    aForm.Update;
    for cnt := 0 to aGrid.ColCount - 1 do
      aGrid.ColWidths[cnt]:= cfg.ReadInteger(aSection,
        aForm.Name + '_' + aGrid.Name + '_cfg' + IntToStr(aGrid.ColCount)+
        '_Col' + IntToStr(cnt), aGrid.DefaultColWidth);
  finally
    FreeAndNil(cfg);
  end;
end;

(*Saving Active Page Index of PageControl*)
procedure SavePageControl(aForm: TForm; aPageControl: TCustomTabControl;
  const aEXEName:string;const aSection:string = 'Position');
var
  ext:string;
  cfg: TINIFile;
begin
  if not Assigned(aForm)or not Assigned(aPageControl)then
    Exit;
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    cfg.WriteInteger(aSection, aForm.Name + '_' + aPageControl.Name,
      THackCustomTabControl(aPageControl).TabIndex);
  finally
    FreeAndNil(cfg);
  end;
end;

procedure SavePageControlByTabname(aForm: TForm; aPageControl: TPageControl;
  const TabName:string;const aEXEName:string;
  const aSection:string = 'Position');
var
  ext:string;
  cfg: TINIFile;
begin
  if not Assigned(aForm)or not Assigned(aPageControl)then
    Exit;
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    cfg.WriteString(aSection, aForm.Name + '_' + aPageControl.Name, TabName);
  finally
    FreeAndNil(cfg);
  end;
end;

procedure SavePageControlOrder(aForm: TForm; aPageControl: TPageControl;
  const aEXEName:string;const aSection:string = 'Position');
var
  ext:string;
  cnt: integer;
  cfg: TINIFile;
begin
  if not Assigned(aForm)or not Assigned(aPageControl)then
    Exit;
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    for cnt := 0 to aPageControl.PageCount - 1 do
      cfg.WriteInteger(aSection, aForm.Name + '_' + aPageControl.Name + '_' +
        aPageControl.Pages[cnt].Name, aPageControl.Pages[cnt].PageIndex);
  finally
    FreeAndNil(cfg);
  end;
end;

(*Restoring  Active Page Index of PageControl*)
procedure RestorePageControl(aForm: TForm; aPageControl: TCustomTabControl;
  const aEXEName:string;const aSection:string = 'Position');
var
  ext:string;
  cfg: TINIFile;
begin
  if not Assigned(aForm)or not Assigned(aPageControl)then
    Exit;
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    THackCustomTabControl(aPageControl).TabIndex := cfg.ReadInteger(aSection,
      aForm.Name + '_' + aPageControl.Name, 0);
    if not THackCustomTabControl(aPageControl).CanShowTab(THackCustomTabControl(aPageControl)
      .TabIndex)then
      THackCustomTabControl(aPageControl).TabIndex := 0;
    THackCustomTabControl(aPageControl).Change;
    //this need for a accepting of change else displayed previous page
  finally
    FreeAndNil(cfg);
  end;
end;

procedure RestorePageControlByTabName(aForm: TForm; aPageControl: TPageControl;
  const aEXEName:string;const aSection:string = 'Position');
var
  ext:string;
  cnt: integer;
  tmpName:string;
  cfg: TINIFile;
begin
  if not Assigned(aForm)or not Assigned(aPageControl)then
    Exit;
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    tmpName := cfg.ReadString(aSection, aForm.Name + '_' +
      aPageControl.Name, '');
    if tmpName = '' then
      THackCustomTabControl(aPageControl).TabIndex := 0
    else
      for cnt := 0 to aPageControl.PageCount - 1 do
        if aPageControl.Pages[cnt].Name = tmpName then
        begin
          aPageControl.ActivePage := aPageControl.Pages[cnt];
          Break;
        end;
    if THackCustomTabControl(aPageControl).TabIndex > THackCustomTabControl(aPageControl)
      .ControlCount - 1 then
    else if(THackCustomTabControl(aPageControl).TabIndex < 0)then
      THackCustomTabControl(aPageControl).TabIndex := 0;
    if not THackCustomTabControl(aPageControl).CanShowTab(THackCustomTabControl(aPageControl)
      .TabIndex)then
      THackCustomTabControl(aPageControl).TabIndex := 0;
    THackCustomTabControl(aPageControl).Change;
    //this need for a accepting of change else displayed previous page
  finally
    FreeAndNil(cfg);
  end;
end;

procedure RestorePageControlOrder(aForm: TForm; aPageControl: TPageControl;
  const aEXEName:string;const aSection:string = 'Position');
var
  arr: array of TTabSheetInfo;
  function getIndex(const aTSName:string; DefIndex: integer): integer;
  var
    cnt: integer;
  begin
    Result := DefIndex;
    for cnt := 0 to High(arr)do
      if aTSName = string(arr[cnt].TabSheetname)then
      begin
        Result := arr[cnt].TabSheetIndex;
        Break;
      end;
  end;

var
  ext:string;
  cnt: integer;
  ind: integer;
  basename:string;
  strl: TStringList;
  cfg: TINIFile;
begin
  if not Assigned(aForm)or not Assigned(aPageControl)then
    Exit;
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  strl := TStringList.Create;
  try
    cfg.ReadSection(aSection, strl);
    basename := aForm.Name + '_' + aPageControl.Name + '_';
    for cnt := 0 to strl.Count - 1 do
      if Pos(basename, strl[cnt])= 1 then
      begin
        ind := Length(arr);
        SetLength(arr, ind + 1);
        with arr[ind]do
        begin
          TabSheetname := shortstring(Copy(strl[cnt], Length(basename)+ 1,
            Length(strl[cnt])));
          TabSheetIndex := cfg.ReadInteger(aSection, strl[cnt], ind);
        end;
      end;
    for cnt := 0 to aPageControl.PageCount - 1 do
      aPageControl.Pages[cnt].PageIndex :=
        getIndex(aPageControl.Pages[cnt].Name,
        aPageControl.Pages[cnt].PageIndex);
  finally
    SetLength(arr, 0);
    strl.Clear;
    FreeAndNil(strl);
    FreeAndNil(cfg);
  end;
end;

(*Установка двойной буфферизации на все контролы родительского контрола*)
procedure SetDoubleBuffered(aCtrl: TWinControl; Value: boolean = true);
var
  cnt: integer;
begin
  if not Assigned(aCtrl)then
    Exit;
  for cnt := 0 to aCtrl.ControlCount - 1 do
    if aCtrl.Controls[cnt]is TWinControl then
    begin
      (aCtrl.Controls[cnt]as TWinControl).DoubleBuffered := Value;
      SetDoubleBuffered((aCtrl.Controls[cnt]as TWinControl), Value);
    end;
end;

procedure SetDoubleBufferedNoCheckListBox(aCtrl: TWinControl;
  Value: boolean = true);
var
  cnt: integer;
begin
  if not Assigned(aCtrl)then
    Exit;
  for cnt := 0 to aCtrl.ControlCount - 1 do
    if(aCtrl.Controls[cnt]is TWinControl)then
    begin
      if(aCtrl.Controls[cnt]is TCheckListBox)then
        (aCtrl.Controls[cnt]as TCheckListBox).DoubleBuffered :=
          false else begin(aCtrl.Controls[cnt]as TWinControl)
          .DoubleBuffered := Value;
      SetDoubleBuffered((aCtrl.Controls[cnt]as TWinControl), Value);
    end;
end;
end;

(*Установка размера (Width) TCheckBox-а (типа AutoSize)*)
procedure SetCheckBoxSize(const aCheckBox: TCheckBox);
var
  dc: hDC;
  wdt: integer;
  rct: TRect;
begin
  if not Assigned(aCheckBox)then
    Exit;
  with aCheckBox do
  begin
    dc := GetWindowDC(Handle);
    try
      SelectObject(dc, Font.Handle);
      rct := Bounds(0, 0, Width, height);
      DrawText(dc, PChar(Caption), Length(Caption), rct,
        DT_LEFT or DT_CALCRECT or DT_SINGLELINE);
      wdt := rct.Right + rct.Bottom  + 4;
      if wdt <> Width then
        Width := wdt;
      if Left + Width > Parent.ClientWidth then
        Width := Parent.ClientWidth - Left;
    finally
      ReleaseDC(Handle, dc);
    end;
  end;
end;

(*Получение реальной клиентской области TGroupBox и размера(pix) его Caption*)
function GetRealClientRectGroupBox(const aGroupBox: TGroupBox;
  var ResRect: TRect): integer;
const
  DT_LEFT_CALC = DT_SINGLELINE + DT_VCENTER + DT_LEFT + DT_CALCRECT;
var
  dc: hDC;
  rct: TRect;
begin
  with aGroupBox do
  begin
    dc := GetWindowDC(aGroupBox.Handle);
    try
      SelectObject(dc, aGroupBox.Font.Handle);
      rct := Bounds(0, 0, 10, 10);
      DrawText(dc, PChar(aGroupBox.Caption), Length(aGroupBox.Caption), rct,
        DT_LEFT_CALC);
    finally
      ReleaseDC(aGroupBox.Handle, dc);
    end;
    ResRect := Bounds(4, rct.Bottom, Width - 8, height - rct.Bottom - 4);
  end;
  Result := rct.Right;
end;


// -->-- из  ExtCtrls.TCustomRadioGroup.ArrangeButtons;
function GetTopOfRadioGroupItem(RG : TRadioGroup; Index : integer): integer;
var
 DC : hDC;
 Metrics: TTextMetric;
 TopMargin,I,ButtonHeight : integer;
begin
DC:=GetWindowDC(RG.Handle);
try
SelectObject(DC, RG.Font.Handle);
GetTextMetrics(DC, Metrics);
finally
ReleaseDC(RG.Handle, DC);
end;
I := RG.Height - Metrics.tmHeight - 5;
ButtonHeight := Round(I / RG.Items.Count); // -- для простого одноколоночного расположения см
TopMargin := Metrics.tmHeight + 1 + Round((I mod RG.Items.Count) / 2);
Result:= (Index mod RG.Items.Count) * ButtonHeight + TopMargin + Round(ButtonHeight / 2);
end;

function GetTextHeightByWidth(const aText:string; aFont: TFont; aWidth: integer;
  aNeedWordBreak: boolean = false): integer;
var
  dc: hDC;
  rct: TRect;
  flg: integer;
begin
  dc := getDC(0);
  try
    rct := Bounds(0, 0, aWidth, 1);
    SelectObject(dc, aFont.Handle);
    flg := DT_LEFT or DT_TOP or DT_CALCRECT;
    DrawText(dc, aText, Length(aText), rct, flg);
    if aNeedWordBreak then
    begin
      flg := DT_LEFT or DT_WORDBREAK or DT_TOP or DT_CALCRECT;
      if rct.Right - rct.Left > aWidth then
      begin
        rct.Right := aWidth;
        rct.Bottom := 0;
        DrawText(dc, aText, Length(aText), rct, flg);
      end;
    end;
    Result := rct.Bottom;
  finally
    DeleteDC(dc);
  end;
end;

function GetTextWidthByHeight(const aText:string; aFont: TFont;
  aHeight: integer; aNeedWordBreak: boolean = false): integer;
var
  dc: hDC;
  rct: TRect;
  strl: TStringList;
  cnt: integer;
begin
  Result := 0;
  dc := getDC(0);
  SelectObject(dc, aFont.Handle);
  try
    if aNeedWordBreak and(Pos(cr, aText)> 0)then
    begin
      strl := TStringList.Create;
      try
        strl.Text := aText;
        for cnt := 0 to strl.Count - 1 do
        begin
          rct := Bounds(0, 0, 0, aHeight);
          DrawText(dc, strl[cnt], Length(strl[cnt]), rct,
            DT_LEFT or DT_SINGLELINE or DT_TOP or DT_CALCRECT);
          if rct.Right > Result then
            Result := rct.Right;
        end;
      finally
        FreeStringList(strl);
      end;
    end
    else
    begin
      rct := Bounds(0, 0, 0, aHeight);
      DrawText(dc, aText, Length(aText), rct, DT_LEFT or DT_SINGLELINE or
        DT_TOP or DT_CALCRECT);
      Result := rct.Right;
    end;
  finally
    DeleteDC(dc);
  end;
end;

function GetTextSize(const aText:string; aFont: TFont): TSize;
var
  dc: hDC;
  //rct : Trect;
  //flg : integer;
begin
  dc := getDC(0);
  SelectObject(dc, aFont.Handle);
  try
    //rct:=Bounds(0,0,1,1);
    //flg:=DT_CALCRECT or DT_LEFT or DT_TOP or DT_WORDBREAK*integer(Pos(cr,aText)>-1);
    //DrawText(dc,aText,Length(aText),rct,flg);
    //Result.cx:=rct.Right;
    //Result.cy:=rct.Bottom;

    Windows.GetTextExtentPoint32(dc, aText, Length(aText), Result);
  finally
    DeleteDC(dc);
  end;
end;
//
//function GetTextRect(const aText:string; aFont: TFont; aAlign: integer): TRect;
//var
//  dc: hDC;
//  //rct : Trect;
//  //flg : integer;
//begin
//  dc := getDC(0);
//  SelectObject(dc, aFont.Handle);
//  try
//    Result := Bounds(0, 0, 0, 0);
//    DrawText(dc, aText, Length(aText), Result, aAlign or DT_CALCRECT);
//    //rct:=Bounds(0,0,1,1);
//    //flg:=DT_CALCRECT or DT_LEFT or DT_TOP or DT_WORDBREAK*integer(Pos(cr,aText)>-1);
//    //DrawText(dc,aText,Length(aText),rct,flg);
//    //Result.cx:=rct.Right;
//    //Result.cy:=rct.Bottom;
//
//    //Windows.GetTextExtentPoint32(dc, aText, Length(aText), Result);
//  finally
//    DeleteDC(dc);
//  end;
//end;

function GetTextRect(const aText:string; aFont: TFont; aAlign: integer): TRect;
var
  dc: hDC;
  sda : TStringDynArray;
  mxWidth : integer;
  mxHeight: integer;
  rct : Trect;
  cnt : integer;
begin
dc := getDC(0);
SelectObject(dc, aFont.Handle);
try
rct:=Bounds(0, 0, 0, 1);
DrawText(dc, 'W', 1, rct, DT_SINGLELINE or DT_LEFT or DT_CALCRECT);
mxWidth:=rct.Right;
sda:=SplitString(aText,cr);
for cnt:=0 to High(sda)
  do begin
  rct:=Bounds(0, 0, 0, 1);
  DrawText(dc, sda[cnt], Length(sda[cnt]), rct, DT_SINGLELINE or DT_LEFT or DT_CALCRECT);
  if  mxWidth<rct.Right then mxWidth:=rct.Right;
  end;
rct:=Bounds(0, 0, 1, 0);
DrawText(dc, 'QЙ', 2, rct, DT_SINGLELINE or DT_LEFT or DT_CALCRECT);
mxHeight:=rct.Bottom;
Result:=Bounds(0,0,mxWidth+4,mxHeight*(Length(sda)+integer(Length(sda)=0)));
finally
 DeleteDC(dc);
end;
end;

procedure CalculateTextRectByWidth(const aText:string; aWidth: integer;
  aFont: TFont; aAlign: integer;var aRect: TRect;var FontSize: integer;
  aMaxFont: integer = 46);
var
  fnt: TFont;
  dc: hDC;
begin
  fnt := TFont.Create;
  fnt.Assign(aFont);
  fnt.Size := 8;
  dc := getDC(0);
  SelectObject(dc, aFont.Handle);
  try
    while fnt.Size < aMaxFont do
    begin
      aRect := Bounds(0, 0, aWidth, 0);
      SelectObject(dc, fnt.Handle);
      DrawText(dc, aText, Length(aText), aRect, aAlign or DT_CALCRECT);
      if aRect.Right > aWidth then
        Break;
      fnt.Size := fnt.Size + 1;
    end;
  finally
    FontSize := fnt.Size;
    DeleteDC(dc);
    fnt.Free;
  end;
end;

function CalculateTextFont(const aText:string; aFont: TFont;
  aWidth, aHeight, aStSize, aFnSize: integer;var aRect: TRect): integer;
const
  alg: cardinal = DT_LEFT or DT_VCENTER or DT_WORDBREAK or DT_CALCRECT or
    DT_MODIFYSTRING;
var
  fnt: TFont;
  dc: hDC;
  rgn: hRGN;
  rct: TRect;
begin
  Result := aStSize;
  fnt := TFont.Create;
  fnt.Assign(aFont);
  fnt.Size := aStSize;
  rgn := CreateRectRgn(0, 0, aWidth, aHeight);
  dc := getDC(0);
  try
    while fnt.Size <= aFnSize do
    begin
      rct := Bounds(0, 0, aWidth, 0);
      SelectObject(dc, fnt.Handle);
      DrawTextEx(dc, PChar(aText), Length(aText), rct, alg,nil);
      if PtInRegion(rgn, rct.Left, rct.Top)and
        PtInRegion(rgn, rct.Right, rct.Bottom)then
        Result := fnt.Size;
      fnt.Size := fnt.Size + 1;
    end;
    aRect := Bounds(0, 0, 1, 1);
    fnt.Size := Result;
    SelectObject(dc, fnt.Handle);
    DrawTextEx(dc, PChar(aText), Length(aText), aRect, alg,nil);
  finally
    DeleteDC(dc);
    DeleteObject(rgn);
    fnt.Free;
  end;
end;

//http://www.sql.ru/forum/931116/perenos-teksta-v-dlinnoy-stroke-drawtext-ne-umeet
procedure DrawTextMemo(aCanvas: hDC; aFont: hFont; aText:String; aRect: TRect);
var
  memo: HWND;
  Len: integer;
  i: integer;
  S:String;
  Buffer: array[0 .. $FF]of char;
begin
  memo := CreateWindow('EDIT',nil, WS_CHILD or ES_MULTILINE, 0, 0,
    aRect.Right - aRect.Left, aRect.Bottom - aRect.Top, GetDesktopWindow, 0,
    HInstance,nil);
  SendMessage(memo, WM_SETFONT, aFont, 0);
  SetWindowText(memo, PChar(aText + #0));
  Len := SendMessage(memo, EM_GETLINECOUNT, 0, 0);
  S := '';
  for i := 0 to Len - 1 do
  begin
    Buffer[0]:= char($FF);
    S := S + Copy(Buffer, 0, SendMessage(memo, EM_GETLINE, i,
      integer(@Buffer[0])))+ #13#10;
  end;
  DestroyWindow(memo);
  Windows.DrawText(aCanvas, PChar(S),-1, aRect, 0);
end;

procedure SetMemLogScroll(aMemo: TMemo);
  function GetTextHeight(const aText:string): integer;
  var
    sz: TSize;
    dc: hDC;
  begin
    dc := GetWindowDC(aMemo.Handle);
    try
      SelectObject(dc, aMemo.Font.Handle);
      sz.cx := 0;
      sz.cy := 0;
      Windows.GetTextExtentPoint32(dc, aText, Length(aText), sz);
      Result := sz.cy;
    finally
      ReleaseDC(aMemo.Handle, dc);
    end;
  end;

  function GetTextWidth(const aText:string): integer;
  var
    sz: TSize;
    dc: hDC;
  begin
    dc := GetWindowDC(aMemo.Handle);
    try
      SelectObject(dc, aMemo.Font.Handle);
      sz.cx := 0;
      sz.cy := 0;
      Windows.GetTextExtentPoint32(dc, aText, Length(aText), sz);
      Result := sz.cx + 6;
    finally
      ReleaseDC(aMemo.Handle, dc);
    end;
  end;

  function NeedHorzScroll: boolean;
  var
    cnt: integer;
  begin
    Result := false;
    for cnt := 0 to aMemo.Lines.Count - 1 do
    begin
      Result := GetTextWidth(aMemo.Lines[cnt])>= aMemo.ClientWidth;
      if Result then
        Break;
    end;
  end;

  function NeedVertScroll: boolean;
  begin
    Result :=(GetTextHeight('QЙщ|,')* aMemo.Lines.Count)+ 1 >=
      aMemo.ClientHeight;
  end;

var
  needVert: boolean;
  needHorz: boolean;
begin
  needHorz := NeedHorzScroll;
  needVert := NeedVertScroll;
  if needHorz and needVert then
    aMemo.ScrollBars := ssBoth
  else if needHorz and not needVert then
    aMemo.ScrollBars := ssHorizontal
  else if not needHorz and needVert then
    aMemo.ScrollBars := ssVertical
  else
    aMemo.ScrollBars := ssNone;
end;

procedure SetListBoxHorzScrolWidth(aLB: TListBox);
var
  cnt: integer;
  tmp: integer;
  wdt: integer;
begin
  wdt := aLB.ClientWidth;
  for cnt := 0 to aLB.Items.Count - 1 do
  begin
    tmp := aLB.Canvas.TextWidth(aLB.Items[cnt]);
    if tmp > wdt then
      wdt := tmp;
  end;
  wdt := wdt + GetSystemMetrics(SM_CXVSCROLL)+ GetSystemMetrics(SM_CXFRAME)* 2;
  SendMessage(aLB.Handle, LB_SETHORIZONTALEXTENT, wdt, 0);
end;

procedure SetListBoxHorzScrolWidth(aLB: TListBox; aScrollWidth : integer);
begin
SendMessage(aLB.Handle, LB_SETHORIZONTALEXTENT, aScrollWidth, 0);
end;

procedure SetListBoxHorzScrolWidth(aLB: TCheckListBox);
var
  cnt: integer;
  tmp: integer;
  wdt: integer;
begin
  wdt := aLB.ClientWidth;
  for cnt := 0 to aLB.Items.Count - 1 do
  begin
    tmp := aLB.Canvas.TextWidth(aLB.Items[cnt]);
    if tmp > wdt then
      wdt := tmp;
  end;
  wdt := wdt + GetSystemMetrics(SM_CXVSCROLL)+ GetSystemMetrics(SM_CXFRAME)* 2;
  SendMessage(aLB.Handle, LB_SETHORIZONTALEXTENT, wdt, 0);
end;



procedure SetListBoxHorzScrolWidth(aLB: TCheckListBox; aScrollWidth : integer);
begin
SendMessage(aLB.Handle, LB_SETHORIZONTALEXTENT, aScrollWidth, 0);
end;

procedure SetListBoxWidth(aLB: TListBox);
var
  cnt: integer;
  tmp: integer;
  wdt: integer;
begin
  wdt := GetSystemMetrics(SM_CXHSCROLL);
  for cnt := 0 to aLB.Items.Count - 1 do
  begin
    tmp := aLB.Canvas.TextWidth(aLB.Items[cnt]);
    if tmp > wdt then
      wdt := tmp;
  end;
  aLB.Width:=wdt+GetSystemMetrics(SM_CXHSCROLL);
end;
//
//procedure SetListBoxHorzScrolWidth(aChLB : TCheckListBox; aDop : integer = 0);
//var
//cnt  : integer;
//tmp  : integer;
//wdt  : integer;
//tsi  : TScrollInfo;
//begin
//wdt:=aChLB.ClientWidth;
//for cnt:=0 to aChLB.Items.Count-1
//do begin
//tmp:=aChLB.Canvas.TextWidth(aChLB.Items[cnt]);
//if tmp>wdt then wdt:=tmp;
//end;
//wdt:=wdt+GetSystemMetrics(SM_CXVSCROLL)+GetSystemMetrics(SM_CXFRAME)*2;
//FillChar(tsi,SizeOf(tagScrollInfo),0);
//tsi.cbSize:=SizeOf(tagScrollInfo);
//tsi.nMax:=wdt;
//tsi.nPage:=wdt div 10;
//tsi.fMask:=SIF_RANGE or SIF_PAGE;
//SetScrollInfo(aChLB.Handle,SB_HORZ,tsi,true);
//end;

(*Сохранение строки в INI файле*)
procedure SaveString(const Section, Param, Value, aEXEName:string);
var
  ext:string;
  cfg: TINIFile;
begin
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    try
      cfg.WriteString(Section, Param, Value);
    except
    end;
  finally
    FreeAndNil(cfg);
  end;
end;

(*Загрузка строки из INI файла*)
procedure LoadString(const Section, Param:string;var Value:string;
  const aEXEName:string);
var
  ext:string;
  cfg: TINIFile;
begin
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    Value := cfg.ReadString(Section, Param, Value);
  finally
    FreeAndNil(cfg);
  end;
end;

(*Сохранение BOOL в INI файле*)
procedure SaveBool(const Section, Param:string;const Value: boolean;
  const aEXEName:string);
var
  ext:string;
  cfg: TINIFile;
begin
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    cfg.WriteBool(Section, Param, Value);
  finally
    FreeAndNil(cfg);
  end;
end;

(*Загрузка Bool из INI файла*)
procedure LoadBool(const Section, Param:string;var Value: boolean;
  const aEXEName:string);
var
  ext:string;
  cfg: TINIFile;
begin
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    Value := cfg.ReadBool(Section, Param, Value);
  finally
    FreeAndNil(cfg);
  end;
end;

(*Сохранение Integer в INI файле*)

function ArrayOfIntegerToString(const Value : TIntegerDynArray): string; // string of hex(8)
var
 cnt  : integer;
begin
Result:='';
for cnt:=0 to High(Value)
    do Result:=Result+IntToHex(Value[cnt],8);
end;

procedure StringToArrayOfInteger(const aStr : string; var Value : TIntegerDynArray); // string of hex(8)
var
 cnt : integer;
 sub : string;
 ind : integer;
begin
SetLength(Value,0);
cnt:=1;
while cnt<=Length(aStr)
  do begin
  sub:=Copy(aStr,cnt,8);
  if CheckValidHex(sub)
     then begin
     ind:=Length(Value);
     SetLength(Value,ind+1);
     Value[ind]:=StrToInt('$'+sub);
     end;
  inc(cnt,8);
  end;
end;

procedure SaveInteger(const Section, Param:string;const Value: integer;
  const aEXEName:string);
var
  ext:string;
  cfg: TINIFile;
begin
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    cfg.WriteInteger(Section, Param, Value);
  finally
    FreeAndNil(cfg);
  end;
end;


procedure SaveArrayOfInteger(const Section, Param:string;const Value : TIntegerDynArray; const aEXEName:string);
var
  ext : string;
  cfg : TINIFile;
begin
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
  cfg.WriteString(Section, Param, ArrayOfIntegerToString(Value));
  finally
    FreeAndNil(cfg);
  end;
end;

(*Загрузка Integer из INI файла*)
procedure LoadInteger(const Section, Param:string;var Value: integer; const aEXEName:string);
var
  ext:string;
  res: integer;
  cfg: TINIFile;
begin
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    res := cfg.ReadInteger(Section, Param, Value);
    Value := res;
  finally
    FreeAndNil(cfg);
  end;
end;

procedure LoadArrayOfInteger(const Section, Param:string;var Value: TIntegerDynArray; const aEXEName:string);
var
  ext : string;
  cfg : TINIFile;
  str : string;
begin
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
  str := cfg.ReadString(Section, Param, ArrayOfIntegerToString(Value));
  StringToArrayOfInteger(str, Value);
  finally
    FreeAndNil(cfg);
  end;
end;

(*Сохранение Float в INI файле*)
procedure SaveFloat(const Section, Param:string;const Value: double;
  const aEXEName:string);
var
  ext:string;
  cfg: TINIFile;
begin
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    cfg.WriteFloat(Section, Param, Value);
  finally
    FreeAndNil(cfg);
  end;
end;

procedure SaveFloat(const Section, Param:string;const Value: Single;
  const aEXEName:string);
var
  Val: double;
begin
  Val := Value;
  SaveFloat(Section, Param, Val, aEXEName);
end;

procedure SaveFloat(const Section, Param:string;const Value: extended;
  const aEXEName:string);
var
  Val: double;
begin
  Val := Value;
  SaveFloat(Section, Param, Val, aEXEName);
end;

(*Загрузка Float из INI файла*)
procedure LoadFloat(const Section, Param:string;var Value: double;
  const aEXEName:string);
var
  ext:string;
  res: double;
  cfg: TINIFile;
begin
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    res := cfg.ReadFloat(Section, Param, Value);
    Value := res;
  finally
    FreeAndNil(cfg);
  end;
end;

procedure LoadFloat(const Section, Param:string;var Value: Single; const aEXEName:string);
var
  res: double;
begin
  LoadFloat(Section, Param, res, aEXEName);
  Value := res;
end;

procedure LoadFloat(const Section, Param:string;var Value: extended;
  const aEXEName:string);
var
  res: double;
begin
  LoadFloat(Section, Param, res, aEXEName);
  Value := res;
end;


procedure LoadFloatEx(const Section, Param:string;var Value: double; const aEXEName:string);
var
  tmp : string;
begin
tmp:=FloatToStr(Value);
LoadString(Section, Param, tmp,aEXEName);
tmp:=TransStrR(trim(tmp),'.,\/|; ',FormatSettings.DecimalSeparator);
if CheckValidFloat(tmp)
   then Value:=StrToFloat(tmp);
end;

procedure LoadFloatEx(const Section, Param:string;var Value: single; const aEXEName:string);
var
  tmp : string;
begin
tmp:=FloatToStr(Value);
LoadString(Section, Param, tmp,aEXEName);
tmp:=TransStrR(trim(tmp),'.,\/|; ',FormatSettings.DecimalSeparator);
if CheckValidFloat(tmp)
   then Value:=StrToFloat(tmp);
end;

procedure LoadFloatEx(const Section, Param:string;var Value: extended; const aEXEName:string);
var
  tmp : string;
begin
tmp:=FloatToStr(Value);
LoadString(Section, Param, tmp,aEXEName);
tmp:=TransStrR(trim(tmp),'.,\/|; ',FormatSettings.DecimalSeparator);
if CheckValidFloat(tmp)
   then Value:=StrToFloat(tmp);
end;


(*Сохранение DateTime в INI файле*)
procedure SaveDateTime(const Section, Param:string;const Value: TDateTime;
  const aEXEName:string);
var
  ext:string;
  cfg: TINIFile;
begin
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    cfg.WriteDateTime(Section, Param, Value);
  finally
    FreeAndNil(cfg);
  end;
end;

(*Загрузка DateTime из INI файла*)
procedure LoadDateTime(const Section, Param:string;var Value: TDateTime;
  const aEXEName:string);
var
  ext:string;
  cfg: TINIFile;
begin
  ext := AnsiUpperCase(ExtractFileExt(aEXEName));
  if(ext = '.INI')or(ext = '.CFG')then
    cfg := TINIFile.Create(aEXEName)
  else
    cfg := TINIFile.Create(ExtractFilePath(ParamStr(0))+
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.INI'));
  if not Assigned(cfg)then
    Exit;
  try
    Value := cfg.ReadDateTime(Section, Param, Value);
  finally
    FreeAndNil(cfg);
  end;
end;

(*Восстановление TDateTime из строки по формату*)
//var
//FmtStr : string;
//DTStr  :string;
//begin
//FmtStr:='yyyy год день и месяц : ddmm hh часов nn минут ss';
//DTStr:=FormatDateTime(FmtStr,Now);
//ShowMyMessage('Формат : '+FmtStr+crlf+DTStr+crlf+dateTimeToStr(StrToDateTimeByFormat(DTStr,FmtStr)));
function StrToDateTimeByFormat(const aInputStrDate, aFormatStr:string)
  : TDateTime;
  function CharCount(const aStartPos: integer;const aStr:string;
    aChar: char): integer;
  var
    cnt: integer;
  begin
    Result := 0;
    if aStartPos = 0 then
      Exit;
    for cnt := aStartPos to Length(aStr)do
      if aStr[cnt]= aChar then
      begin
        Result := Result + 1;
        if cnt + 1 <= Length(aStr)then
          if aStr[cnt + 1]<> aChar then
            Break;
      end;
  end;

var
  Fstr:string;
  IStr:string;
  bY, cy: integer;
  bM, cM: integer;
  bD, cD: integer;
  sY, sM, SD:string;
  Y, M, D: integer;
  bh, cH: integer;
  bN, cN: integer;
  bS, cs: integer;
  bZ, cZ: integer;
  sH, sn, sS, sz:string;
  H, n, S, z: integer;
  msg : string;
begin
Result:=0;
try
  Fstr := UpperCase(aFormatStr);
  IStr := UpperCase(Trim(aInputStrDate));
  if Length(Fstr)>Length(IStr)
     then begin
     IStr:=DupeString('0',Length(Fstr)-Length(IStr))+IStr;
     end;
  bY := Pos('Y', Fstr);
  cy := CharCount(bY, Fstr, 'Y');
  bM := Pos('M', Fstr);
  cM := CharCount(bM, Fstr, 'M');
  bD := Pos('D', Fstr);
  cD := CharCount(bD, Fstr, 'D');
  sY := Copy(IStr, bY, cy);
  if sY <> '' then
    Y := StrToInt(sY)
  else
    Y := 0;
  sM := Copy(IStr, bM, cM);
  if sM <> '' then
    M := StrToInt(sM)
  else
    M := 0;
  SD := Copy(IStr, bD, cD);
  if SD <> '' then
    D := StrToInt(SD)
  else
    D := 0;
  bh := Pos('H', Fstr);
  cH := CharCount(bh, Fstr, 'H');
  bN := Pos('N', Fstr);
  cN := CharCount(bN, Fstr, 'N');
  bS := Pos('S', Fstr);
  cs := CharCount(bS, Fstr, 'S');
  bZ := Pos('Z', Fstr);
  cZ := CharCount(bZ, Fstr, 'Z');
  sH := Copy(IStr, bh, cH);
  if sH <> '' then
    H := StrToInt(sH)
  else
    H := 0;
  sn := Copy(IStr, bN, cN);
  if sn <> '' then
    n := StrToInt(sn)
  else
    n := 0;
  sS := Copy(IStr, bS, cs);
  if sS <> '' then
    S := StrToInt(sS)
  else
    S := 0;
  sz := Copy(IStr, bZ, cZ);
  if sz <> '' then
    z := StrToInt(sz)
  else
    z := 0;
  if(M <> 0)and(D <> 0)then
    Result := Encodedate(Y, M, D)+ EncodeTime(H, n, S, z)
  else
    Result := EncodeTime(H, n, S, z);
except
on E : Exception
   do begin
   CreateErrorMessage('StrToDateTimeByFormat',E,[aInputStrDate, aFormatStr],msg);
   if DebugHook>0
      then begin
      Result:=0;
      //ShowMessageError(msg);
      end
   end;
end;
end;

(* Выдает дату строкой с падежом месяца                                       *)
function GetLongDate(ThisDate : Tdate;QuotesDay : string = ''): string;
var
 d,m,y : word;
begin
DecodeDate(ThisDate,y,m,d);
result:=QuotesDay+FormatFloat('00',d)+' '+OfMonth[m]+' '+FormatFloat('0000',y);
System.Insert(QuotesDay,result,4);
end;

function GetLongDateY(ThisDate : Tdate;QuotesDay : string = ''): string;
var
 d,m,y : word;
begin
if ThisDate=0
   then begin
   Result:='';
   Exit;
   end;
DecodeDate(ThisDate,y,m,d);
result:=QuotesDay+FormatFloat('00',d)+' '+OfMonth[m]+' '+FormatFloat('0000',y)+' года';
System.Insert(QuotesDay,result,4);
end;

function SecondsToHMS(aBigNumSeconds: int64; var aHours, aMinutes, aSeconds: Word): TTime;
var
 msg  : string;
 days : integer;
begin
Result:=0;
aHours:=0;
aMinutes:=0;
aSeconds:=0;
try
if aBigNumSeconds >= 24*60*60
  then begin
  Result:=SecondsToTime(aBigNumSeconds,days);
  Result:=days+Result;
  end
  else begin
  aHours := aBigNumSeconds div(60 * 60);
  if aHours > 23 then
    aHours := aHours - aHours div 24 * 24;
  aMinutes :=(aBigNumSeconds -(aHours *(60 * 60)))div 60;
  aSeconds := aBigNumSeconds -(aHours *(60 * 60))- aMinutes * 60;
  Result := EncodeTime(aHours, aMinutes, aSeconds, 0);
  end
except
on E : Exception
  do begin
  CreateErrorMessage('SecondsToHMS',E,[aBigNumSeconds,aHours, aMinutes, aSeconds],msg);
  ShowMessageInfo(msg);
  end;
end;
end;

function SecondsToDecimal(aSeconds : integer) : single;
var
 h, m, s : word;
begin
SecondsToHMS(aSeconds,h,m,s);
Result:= h*60 + m  + 100/60 * s / 100;
end;

function MinutesToHM(aBigNumMinutes: integer;
  var aHours, aMinutes: integer): TTime;
var
  Src: integer;
  res:string;
  hr: integer;
  neg: boolean;
begin
  Result := 0;
  try
    neg :=(aBigNumMinutes < 0);
    Src := Abs(aBigNumMinutes);
    aHours := Src div 60;
    hr := aHours;
    if aHours > 23 then
    begin
      aHours := aHours - aHours div 24 * 24;
    end;
    aMinutes := integer(Src)- hr * 60;
    Result := EncodeTime(aHours, aMinutes, 0, 0);
    if neg then
      Result := Result *-1;
  except
    on E: Exception do
    begin
      CreateErrorMessage('MinutesToHM', E,[aBigNumMinutes, aHours,
        aMinutes], res);
      if res <> '' then;
    end;
  end;
end;

function MinSecToMinDecimal(const aMinSecStr : string) : single;
var
 sda : TStringDynArray;
 h, m,s : word;
begin
Result:=0;
try
if Pos('''',aMinSecStr)<>0
   then begin
   sda:=SplitString(aMinSecStr,'''');
   h:=0;
   if Length(sda)>=2
      then begin
      if CheckValidInteger(sda[0],true)
         then begin
         m:=StrToInt(sda[0]);
         if m>=1440 then m:=1439;
         h:=m div 60;
         m:=m - h * 60;
         //if m>59 then m:=59;
         end
         else m:=0;
      if CheckValidInteger(sda[1],true)
         then begin
         s:=StrToInt(sda[1]);
         if s>59 then s:=59;
         end
         else s:=0;
      Result:=SecondsToDecimal(h*60*60+m*60+s);
      end
   end
   else Result:=StrToFloat(TransStrR(aMinSecStr, '.,\|/ -:;',FormatSettings.DecimalSeparator));
except

end;
end;

function SecondsToTime(aSeconds: int64): TTime;
var
  H, M, S: Word;
begin
  Result := SecondsToHMS(aSeconds, H, M, S)
end;

function SecondsToTime(aSeconds: int64; var Days : integer): TTime;
const
 day = 24*60*60;
var
  H, M, S: Word;
  val    : int64;
begin
Days:=0;
val:=aSeconds;
if aSeconds>=day
   then begin
   Days:=aSeconds div day;
   val:=aSeconds - Days*day;
   end;
Result := SecondsToHMS(val, H, M, S)
end;

function MinutesToTime(aMinutes: cardinal): TTime;
var
  H, M: integer;
begin
  Result := MinutesToHM(aMinutes, H, M);
end;

function MinutesToDateTime(aMinutes: int64): TDateTime;
var
  days : DWORD;
  hours: DWORD;
  mins : DWORD;
  err  : string;
begin
Result:=EncodeTime(0, 0, 0, 0);
try
  if aMinutes<=0 then Exit;
  days := aMinutes div 60 div 24;
  hours :=(aMinutes div 60)-(days * 24);
  mins := aMinutes - hours * 60 - days * 24 * 60;
  Result := days + EncodeTime(hours, mins, 0, 0);
except
 on E : Exception
    do begin
    CreateErrorMessage('MinutesToDateTime',E,[aMinutes],err);
    if err<>'' then ;
    end;
end;
end;

function TimeToMinutes(aTime: TTime): int64;
var
  H, n, S, z: Word;
begin
  DecodeTime(aTime, H, n, S, z);
  Result := H * 60 + n;
end;


function DateTimeToMinutes(aDateTime: TDateTime): int64;
var
  H, n, S, z: Word;
begin
  DecodeTime(aDateTime, H, n, S, z);
  Result := Trunc(aDateTime)* 1440+H * 60 + n ;
end;

function TimeToSeconds(aTime: TTime): int64;
var
  H, M, S, z: Word;
begin
  DecodeTime(aTime, H, M, S, z);
  Result := H * 60 * 60 + M * 60 + S + Round(z / 1000);
end;

function TimeToSecondsDouble(aTime: TTime): double;
var
  H, M, S, z: Word;
begin
  DecodeTime(aTime, H, M, S, z);
  Result := H * 60 * 60 + M * 60 + S + z / 1000;
end;

function TimeToMSec(aDateTime: TDateTime): int64;
var
  H, M, S, z: Word;
begin
  DecodeTime(aDateTime, H, M, S, z);
  Result := H * 60 * 60 * 1000 + M * 60 * 1000 + S * 1000 + z;
end;

function MSecToTime(aMS : int64) : TTime;
var
 secs : int64;
begin
secs:=aMS div 1000;
Result:=SecondsToTime(secs)+EncodeTime(0,0,0,aMS - aMS div 1000 * 1000);
//Result:=Result+EncodeTime(0,0,0,aMS - TimeToMSec(Result)); // или так если в предыдущей строке отсечь EncodeTime
end;
(*  проверка
procedure TForm1.Button2Click(Sender: TObject);
var
 int : int64;
begin
int:=TimeToMSec(EncodeTime(12,34,56,789));
ShowMessageInfo(FormatDateTime('hh:nn:ss.zzz',MSecToTime(int))) ;
end;
*)

function MSecToDateTime(aMS: int64): TDateTime;
var
  TS      : TTimeStamp;
  TempTime: Comp;
begin
  TS := DateTimeToTimeStamp(0);
  TempTime := TimeStampToMSecs(TS);
  TempTime := TempTime + aMS;
  TS := MSecsToTimeStamp(TempTime);
  Result := TimeStampToDateTime(TS);
end;

function GetWindowsWorkTime(out days : integer) : TDateTime;
var
 gtc,gtcd : integer;
 s,m,h,d  : integer;
begin
gtc:=GetTickCount;
gtcd:=gtc;
h:=gtc div 1000 div 60 div 60;
gtc:=gtc-h*1000*60*60;
m:=gtc div 1000 div 60;
gtc:=gtc-m*1000*60;
s:=gtc div 1000;
//ms:=gtc-s*1000;
d:=gtcd div 1000 div 60 div 60 div 24;
days:=d;
h:=h-d*24;
Result:=StrToTime(FormatFloat('00',h)+TimeSeparator+FormatFloat('00',m)+TimeSeparator+FormatFloat('00',s));
end;

procedure GetWorkTime(aStartDateTime: TDateTime;var aDays: integer;
  var aTimes: TTime;var aDisplayString:string; aNeedMs: boolean = false);
const
  ms: array[boolean]of string =('', '.zzz');
var
  //d,m,y : word;
  Delta: TDateTime;
begin
  Delta := Now - aStartDateTime;
  aDays := trunc(Delta);
  aTimes := Delta - aDays;
  if aDays = 0 then
    aDisplayString := FormatDateTime('hh:nn:ss' + ms[aNeedMs], aTimes)
  else
    aDisplayString := Format('%d %s %s',[aDays, GetDefUnit(aDays, dfDay),
      FormatDateTime('hh:nn:ss' + ms[aNeedMs], aTimes)]);
end;

procedure GetWorkTime(aStartDateTime, aFinishDateTime: TDateTime; var aDays: integer;var aTimes: TTime;var aDisplayString:string; aNeedMs: boolean = false);
const
  ms: array[boolean]of string =('', '.zzz');
var
  //d,m,y : word;
  Delta: TDateTime;
begin
  Delta := aFinishDateTime - aStartDateTime;
  aDays := trunc(Delta);
  aTimes := Delta - aDays;
  if aDays = 0 then
    aDisplayString := FormatDateTime('hh:nn:ss', aTimes)
  else
    aDisplayString := Format('%d %s %s',[aDays, GetDefUnit(aDays, dfDay),
      FormatDateTime('hh:nn:ss'+ ms[aNeedMs], aTimes)]);
end;

function AboutInterval(aDateTime: TDateTime):string;
const
  ms: array[boolean]of string =('', '.zzz');
var
  //d,m,y : word;
  Delta: TDateTime;
  _Days : integer;
  _Time : TTime;
begin
  Delta := aDateTime;
  _Days := trunc(Delta);
  _Time := Delta - _Days;
  if _Days = 0
     then Result := FormatDateTime('hh:nn:ss', _Time)
     else Result := Format('%d %s %s',[_Days, GetDefUnit(_Days, dfDay),FormatDateTime('hh:nn:ss', _Time)]);
end;

//!!!! требуется тщательная проверка на отрицательных данных .....
procedure GetRealWorkTime(aMinutes: integer;var aDays: integer;var aTime: TTime;
  var aStr:string; aWorkDay: integer = 9);
const
  sign: array[boolean]of string =('-', '');
var
  Src: integer;
  hours: integer;
  H, M: integer;
  res:string;
begin
  try
    Src := Abs(aMinutes);
    hours := Src div 60;
    M := Src - hours * 60;
    aDays := hours div aWorkDay;
    H := hours - aDays * aWorkDay;
    aTime := EncodeTime(H, M, 0, 0);
    if aDays = 0 then
      aStr := Format('%s %s',[sign[aMinutes = Src],
        FormatDateTime('hh:nn', aTime)])
    else
      aStr := Format('%s %d %s %s',[sign[aMinutes = Src], aDays,
        GetDefUnit(aDays, dfDay), FormatDateTime('hh:nn', aTime)]);
  except
    on E: Exception do
    begin
      CreateErrorMessage('GetRealWorkTime', E,[aMinutes], res);
      if res <> '' then;
    end;
  end;
end;

function DateTime(aValue : single) : TDateTime;
begin
Result:=RoundTo(aValue,-10);
end;

function DateTime(aValue : real) : TDateTime;
begin
Result:=RoundTo(aValue,-10);
end;

function DateTime(aValue : extended) : TDateTime;
begin
Result:=RoundTo(aValue,-10);
end;

function UnixTimeToDateTime(UnixTime : int64) : TDateTime;
begin
  result:=25569+UnixTime/86400;
end;

function DateTimeToUnixTime(DateTime : TDateTime) : int64;
begin
  result:=Round((DateTime-25569)*86400);
end;


function GetCPUCount : integer;
var
 si : SYSTEM_INFO;
begin
GetSystemInfo(si);
Result:=si.dwNumberOfProcessors;
end;

(*Количество дней в месяце*)
function DaysThisMonth(const month, Year: Word): integer;
const
  DaysPerMonth: array[1 .. 12]of integer =(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
begin
  if month > 12
     then Result := 0
     else Result := DaysPerMonth[month];
  if(month = 2)and IsLeapYear(Year)
     then Inc(Result);
end;

function GetLastDay(const month, Year: Word): integer;
begin
  Result := DaysThisMonth(month, Year);
end;

(*Week Number*)
function GetWeek(const ADate: TDateTime): Word;//1-JAN is FIRST WEEK ALWAYS
var
  Year: Word;
  month: Word;
  Day: Word;
  nYear: Word;
  nMonth: Word;
  nDay: Word;

  pr: boolean;
begin
  DecodeDate(ADate + 1 - DayOfWeek(ADate + 6), Year, month, Day);
  DecodeDate(ADate, nYear, nMonth, nDay);
  pr :=(DayOfWeek(Encodedate(nYear, 1, 1))in[6, 7, 1]);
  Result := 1 + trunc((ADate - Encodedate(Year, 1,
    5)+ DayOfWeek(Encodedate(Year, 1, 3)))/ 7);
  if(Year < nYear)then
    Result := 1
  else
    Result := Result + integer(pr);
  //DecodeDate(ADate+1 - DayOfWeek(ADate + 6),Year,Month,Day);
  //DecodeDate(ADate,nYear,nMonth,nDay);
  //Result:=1+Trunc((ADate-EncodeDate(Year,1,5) + DayOfWeek(EncodeDate(Year,1,3))) / 7);
  //if (Year<nYear)
  //then Result:=1
  //else Result:=Result+Integer(pr);
end;

(*Номер квартала по месяцу*)
function GetQuart(const aMonth: integer): integer;
begin
  Result := aMonth div 3 + integer(aMonth mod 3 <> 0);
end;

(*Попытка сэмулировать DATEDIFF MSSQL*)
function DateDiff(aDatePart: TDatePart; const aStartDate, aEndDate: TDateTime): int64;
var
  _sy, _sm, _SD, _sh, _sn, _ss, _sz: Word;
  _ey, _em, _ed, _eh, _en, _es, _ez: Word;
  _ry, _rm, _rd, _rh, _rn, _rs, _rz: Word;
begin
  Result := 0;
  DecodeDate(aStartDate, _sy, _sm, _SD);
  DecodeTime(aStartDate, _sh, _sn, _ss, _sz);
  DecodeDate(aEndDate, _ey, _em, _ed);
  DecodeTime(aEndDate, _eh, _en, _es, _ez);
  DecodeDate(trunc(aEndDate)- trunc(aStartDate)- Encodedate(1899, 12, 30), _ry,
    _rm, _rd);
  DecodeTime(aEndDate - aStartDate, _rh, _rn, _rs, _rz);
  case aDatePart of
    ddYear:
      Result := _ry - 1900;
    ddQuart:
      Result := 4 *(_ey - _sy)- GetQuart(_sm)+ GetQuart(_em);
    ddMonth:
      Result := 12 *(_ey - _sy)- _sm + _em;
    ddDay, ddDayOfYear:
      Result :=(trunc(aEndDate)- trunc(aStartDate));
    ddWeek:
      Result :=(trunc(aEndDate)- trunc(aStartDate))div 7;
    ddHour:
      Result :=(trunc(aEndDate)- trunc(aStartDate))* 24 + _rh;
    ddMinute:
      Result :=(trunc(aEndDate)- trunc(aStartDate))* 24 * 60 - _sh * 60 - _sn + _eh * 60 + _en;
    ddSecond:
      Result :=((trunc(aEndDate)- trunc(aStartDate))* 24 * 60 - _sh * 60 - _sn + _eh * 60 + _en)* 60 - _ss + _es;
    ddMSecond:
      Result :=((trunc(aEndDate)- trunc(aStartDate))* 24 * 60 - _sh * 60 - _sn +
        _eh * 60 + _en)* 60 - _ss + _es;
  end;
end;

procedure DateDiffYMD(const aStartDate, aEndDate: TDateTime;
  var aYearsCount, aMonthsCount, aDaysCount: integer);
begin
  aYearsCount := DateDiff(ddYear, aStartDate, aEndDate);
  aMonthsCount := DateDiff(ddMonth, aStartDate, aEndDate);
  aDaysCount := DateDiff(ddDay, aStartDate, aEndDate);
end;

procedure DateDiffYMD_Diff(const aStartDate, aEndDate: TDateTime;
  var aYearsCount, aMonthsCount, aDaysCount: integer);
var
  Y, M, D: Word;
  SD, ed: TDateTime;
begin
  if aStartDate > aEndDate then
  begin
    ed := aStartDate;
    SD := aEndDate;
  end
  else
  begin
    SD := aStartDate;
    ed := aEndDate;
  end;
  aYearsCount := DatePart(ddYear, ed)- DatePart(ddYear, SD);
  aMonthsCount := DatePart(ddMonth, ed)- DatePart(ddMonth, SD);
  //- aYearsCount * 12;
  aDaysCount := DatePart(ddDay, ed)- DatePart(ddDay, SD);
  //DateDiff(ddDay,aStartDate, aEndDate);
  DecodeDate(SD, Y, M, D);
  if aDaysCount < 0 then
  begin
    aDaysCount := GetLastDay(M, Y)+ aDaysCount;//DatePart(ddDay,aEndDate)+
    aMonthsCount := aMonthsCount - 1;
  end;
  if aMonthsCount < 0 then
  begin
    aMonthsCount := 12 + aMonthsCount;
    aYearsCount := aYearsCount - 1;
  end;
end;

function DateDiffYMD_Diff_ByWords(const aStartDate, aEndDate: TDateTime):string;
var
  Y, M, D: integer;
  ys, ms, ds:string;
begin
  if aStartDate = aEndDate then
  begin
    Result := 'Ноль дней';
    Exit;
  end;
  DateDiffYMD_Diff(aStartDate, aEndDate, Y, M, D);
  if Y <> 0 then
    ys := NumberByWords(Y, dfYear)+ ', '
  else
    ys := '';
  if M <> 0 then
    ms := NumberByWords(M, dfMonth)+ ', '
  else
    ms := '';
  if D <> 0 then
    ds := NumberByWords(D, dfDay)+ ', '
  else
    ds := '';
  Result := Trim(AnsiLowerCase(ys + ms + ds));
  Result := AnsiUpperCase(Copy(Result, 1, 1))+ Copy(Result, 2, Length(Result));
  Result := Copy(Result, 1, Length(Result)- 1);
end;

(*Попытка сэмулировать DATEPART MSSQL*)
function DatePart(aDatePart: TDatePart;const ADate: TDateTime): integer;
var
  _y, _m, _d, _h, _n, _s, _z: Word;
begin
  Result := 0;
  DecodeDate(ADate, _y, _m, _d);
  DecodeTime(ADate, _h, _n, _s, _z);
  case aDatePart of
    ddYear:
      Result := _y;
    ddQuart:
      Result := GetQuart(_m);
    ddMonth:
      Result := _m;
    ddDay:
      Result := _d;
    ddDayOfWeek:
      begin
        _d := DateTimeToTimeStamp(ADate).Date mod 7;
        Result := _d + integer(_d = 0)* 7;
        //Result:=DayOfWeek(aDate-1); -- это если средствами Delphi
      end;
    ddDayOfYear:
      Result := trunc(ADate)- trunc(Encodedate(_y, 1, 1))+ 1;
    ddWeek:
      Result := GetWeek(ADate);
    ddHour:
      Result := _h;
    ddMinute:
      Result := _n;
    ddSecond:
      Result := _s;
    ddMSecond:
      Result := _z;
  end;
end;

function DayOfWeekRus(aDate : TDateTime) : integer;
begin
Result:=DatePart(ddDayOfWeek, aDate);
end;

procedure GetQuartDates(aNumQuart, aYear: Word;var aStDate, aFndate: TDate);
var
  M: integer;
begin
  aStDate := Date;
  aFndate := Date;
  M :=(aNumQuart - 1)* 3 + 1;
  if(M < 1)or(M > 12)then
    Exit;
  aStDate := Encodedate(aYear, M, 1);
  aFndate := IncMonth(aStDate, 3)- 1;
end;


function GetRusMonthNumber(const aFullRusMonthName : string) : integer;
var
 cnt  : integer;
 test : string;
begin
Result:=0;
test:=AnsiUpperCase(aFullRusMonthName);
for cnt:=1 to 12
  do if test=AnsiUpperCase(FormatSettings.LongMonthNames[Result])
     then begin
     Result:=cnt;
     Exit;
     end;
Result:=0;
end;

function ThisYear : word;
var m,d : word;
begin
DecodeDate(now,Result,m,d);
end;

function Replicate(const aStr : string; aNumber : integer) : string;
begin
Result:=DupeString(aStr, aNumber);
end;

function GetWindowClassName(aWnd: HWND):string;
var
  buf: PChar;
const
  bufsz: integer = 255;
begin
  buf := Allocmem(bufsz * SizeOfChar + 1);
  try
    GetClassName(aWnd, buf, bufsz);
    Result := StrPas(buf);
  finally
    FreeMem(buf);
  end;
end;

function GetWindowClassNameArr(aWnd: HWND):string;
var
  buf: array[0 .. 255]of char;
begin
  GetClassName(aWnd, buf, Length(buf));
  Result := StrPas(buf);
end;

function GetWndText(aWnd: HWND):string;
var
  Len: integer;
  buf: PChar;
begin
  Len := MAX_PATH_EX;//GetWindowTextW(aWnd,nil,200);
  buf := Allocmem(Len * integer(SizeOfChar)+ 1);
  try
    GetWindowTextW(aWnd, buf, Len);
    Result := StrPas(buf);
  finally
    FreeMem(buf);
  end;
end;

function GetWindowTextEx(aWnd: HWND):string;
var
 sz  : integer;
 buf : PChar;
 tmp  :string;
begin
try
tmp:='';
try
sz:=GetWindowTextLength(aWnd)+1;
if sz>1
   then begin
   buf:=AllocMem(sz * SizeOfChar+1);
   try
   GetWindowText(aWnd,buf,sz);
   tmp:=StrPas(buf);
   finally
   FreeMem(buf);
   end;
   end;
finally
Result:=tmp;
end;
except
on E : Exception do ShowMessageError(E.Message,'GetWindowTextEx');
end;
end;

function GetWindowAppHandle(aWnd: HWND): cardinal;
var
  ProcessID: DWORD;
  snap: cardinal;
  pe32: TPROCESSENTRY32;
  me32: TMODULEENTRY32;
begin
  Result := aWnd;
  GetWindowThreadProcessId(aWnd, ProcessID);
  snap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS or TH32CS_SNAPMODULE,
    ProcessID);
  try
    if snap <> 0 then
    begin
      pe32.dwSize := SizeOf(TPROCESSENTRY32);
      me32.dwSize := SizeOf(TMODULEENTRY32);
      if Process32First(snap, pe32)then
      begin
        Module32First(snap, me32);
        Result := me32.hModule;
        //if pe32.th32ProcessID = ProcessId
        //then begin
        //
        //end
        //else begin
        //while Process32Next(snap, pe32)
        //do begin
        //Module32Next(snap,me32);
        //if pe32.th32ProcessID = ProcessId
        //then begin
        //
        //break;
        //end;
        //end;
        //end;
        //ExtractIcon(hInstance,pe32.szExeFile,0);
      end;
    end;
  finally
    CloseHandle(snap);
  end;
end;

function GetWindowPID(aWnd: HWND): cardinal;
begin
  GetWindowThreadProcessId(aWnd, Result);
end;



function GetCurrentProcessHandle: cardinal;
var
  ProcessID: DWORD;
  snap: cardinal;
  pe32: TPROCESSENTRY32;
  me32: TMODULEENTRY32;
begin
Result:=HInstance;
ProcessID:=GetCurrentProcessId;
snap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS or TH32CS_SNAPMODULE,ProcessID);
try
if snap <> 0
   then begin
   pe32.dwSize := SizeOf(TPROCESSENTRY32);
   me32.dwSize := SizeOf(TMODULEENTRY32);
   if Process32First(snap, pe32)
      then begin
      Module32First(snap, me32);
      Result := me32.hModule;
      end;
   end;
finally
CloseHandle(snap);
end;
end;

function GetProcessModule(aPID : cardinal): string;
var
  snap: cardinal;
  pe32: TPROCESSENTRY32;
  me32: TMODULEENTRY32;
  errcode : integer;
begin
Result:='';
snap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS or TH32CS_SNAPMODULE,aPID);
try
if (snap <> INVALID_HANDLE_VALUE) and (snap>0)
   then begin
   FillChar(pe32, SizeOf(TPROCESSENTRY32), 0);
   pe32.dwSize := SizeOf(TPROCESSENTRY32);
   FillChar(me32, SizeOf(TMODULEENTRY32), 0);
   me32.dwSize := SizeOf(TMODULEENTRY32);
   if Process32First(snap, pe32)
      then begin
      Module32First(snap, me32);
//      Result := me32.hModule;
      Result:=AC2Str(me32.szExePath);
      end;
   end
   else begin
   errcode:=GetLastError;
   if errcode=5 // access denied
      then Result:='System. См. в Process Explorer'
      else Result:=Format('Error %d: %s',[errcode, GetErrorString(errcode)]);
   end;
finally
CloseHandle(snap);
end;
end;

function GetParentProcess(aPID  :cardinal; var aParentPID : cardinal; var aParentEXE : string): boolean;
var
  snap: cardinal;
  pe32: TPROCESSENTRY32;
  me32: TMODULEENTRY32;
begin
Result:=false;
aParentPID:=0;
aParentEXE:='';
snap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS or TH32CS_SNAPMODULE,  aPID);
try
if snap <> 0
   then begin
   pe32.dwSize := SizeOf(TPROCESSENTRY32);
   me32.dwSize := SizeOf(TMODULEENTRY32);
   if not Process32First(snap, pe32) then Exit;
   Module32First(snap, me32);
   if pe32.th32ProcessID = aPID
      then begin
      //ShowMessageInfo('') ;
      end
      else begin
      while Process32Next(snap, pe32)
         do begin
         Module32Next(snap,me32);
         if pe32.th32ProcessID = aPID
            then begin
            CloseHandle(snap);
            aParentPID:=pe32.th32ParentProcessID;
            snap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS or TH32CS_SNAPMODULE,  aParentPID);
            if snap <> 0
               then begin
               if Process32First(snap, pe32)
                  then Module32First(snap, me32);
               aParentEXE:=AC2Str(me32.szExePath);
               Result:=true;
               break;
               end;
            end;
         end;
      end;
   end;
finally
  CloseHandle(snap);
end;
end;


function TParentProcessList.FillFor(aPID : cardinal) : boolean;
var
 par_pid  : cardinal;
 par_path : string;
 res      : boolean;
 ind      : integer;
begin
Result:=false;
try
Clear;
pid:=aPID;
res:=GetParentProcess(pid,par_pid, par_path);
while res and (par_pid>0)
  do begin
  ind:=length(Items);
  Setlength(Items, ind+1);
  with Items[ind] do
    begin
    pid:=par_pid;
    Str2AC(par_Path, path);
    end;
  res:=GetParentProcess(Items[ind].pid,par_pid, par_path);
  end;
Result:=true;
except
 on E : Exception do ;
end;
end;

function TParentProcessList.Clear : boolean;
begin
Result:=false;
try
Setlength(Items,0);
Result:=true;
except
 on E : Exception do ;
end;
end;

(*----------------------------------------------------------------------------------------*)
var
  tmpPWL: TProcessWindowList;

function PWLEnumWindows(hwndNext: HWND; lp: LParam): boolean; stdcall;
var
  PWI  : TProcessWindowItem;
  ind  : integer;
begin
Result := true;
if hwndNext <> 0
    then begin
    PWI.Handle := hwndNext;
    PWI.Parent := GetParent(PWI.Handle);
    GetWindowThreadProcessId(PWI.Handle,@PWI.pid);
    ind := Length(tmpPWL.Items);
    SetLength(tmpPWL.Items, ind + 1);
    System.Move(PWI, tmpPWL.Items[ind], SizeOf(TProcessWindowItem));
    end
    else Result := false;
end;


(*----------------------------------------------------------------------------------------*)

function TProcessWindowList.Fill  : boolean;
var
  ln: integer;
begin
Clear;
tmpPWL.Clear;
 try
  EnumChildWindows(0,@PWLEnumWindows, 0);
  ln:=Length(tmpPWL.Items);
  SetLength(Items, ln);
  if ln> 0
     then  System.Move(tmpPWL.Items[0], Items[0], SizeOf(TProcessWindowItem) * ln);
 finally
  tmpPWl.Clear;
 end;
Result:=true;
end;

function TProcessWindowList.About(aPID : cardinal; var aStr : string) : integer;
var
  cnt : integer;
  cls : string;
  txt : string;
  exe : string;
begin
Result:=0;
aStr:='';
for cnt:=0 to High(Items)
  do with Items[cnt] do
      if pid = aPID
        then begin
        cls:=GetWindowClassName(handle);
        txt:=GetWindowTextEx(handle);
        //exe:=GetFullFileNameForWindow(handle);
        exe:='';
        aStr:=aStr+Format(#9#9#9'%10s %10s %10s %-50s %-100s %-200s'#13#10,[IntToStr(pid), IntToStr(handle), IntToStr(parent), cls, txt, exe]);
        inc(Result);
        end
end;


function TProcessWindowList.Clear : boolean;
begin
Setlength(Items,0);
Result:=true;
end;

function TProcessList.GetIndex(aPID  :cardinal) : integer;
var
 cnt : integer;
begin
Result:=-1;
for cnt:=0 to High(Items)
  do if Items[cnt].selfpid = aPID
   then begin
   Result:=cnt;
   Exit;
   end;
end;

function TProcessList.Add(aPID : cardinal; const aModuleNameOnly : string; aParentPID : cardinal) : integer;
begin
Result:=GetIndex(aPID);
if Result>-1 then Exit;
Result:=Length(Items);
Setlength(Items, Result+1);
with Items[Result]
   do begin
   selfpid:=aPID;
   //Str2AC(aModule,path);
   Str2AC(GetFullFileNameForPID(aPID),path);
   parentpid:=aParentPID;
   end;
end;

function TProcessList.Add(aPID : cardinal; aParentPID : cardinal) : integer;
begin
Result:=GetIndex(aPID);
if Result>-1 then Exit;
Result:=Length(Items);
Setlength(Items, Result+1);
with Items[Result]
   do begin
   selfpid:=aPID;
   //Str2AC(aModule,path);
   Str2AC(GetFullFileNameForPID(aPID),path);
   parentpid:=aParentPID;
   end;
end;

function TProcessList.Fill(aParent : cardinal = 0): boolean;
var
  snap: cardinal;
  pe32: TPROCESSENTRY32;
begin
Clear;
ProcessWindowList.Fill;
snap := CreateToolhelp32Snapshot(TH32CS_SNAPALL{TH32CS_SNAPPROCESS}, aParent);
try
pe32.dwSize := SizeOf(TPROCESSENTRY32);
Result:=Process32First(snap, pe32);
while Result
  do begin
  Add(pe32.th32ProcessID, pe32.th32ParentProcessID);
  Result:=Process32Next(snap, pe32);
  end;
finally
  CloseHandle(snap);
end;
end;


function TProcessList.Fill(const EXEName : string; aParent : cardinal = 0) : boolean;
var
  snap: cardinal;
  pe32: TPROCESSENTRY32;
  exe : string;
  res : string;
begin
exe:=AnsiLowerCase(EXEName);
Clear;
ProcessWindowList.Fill;
snap := CreateToolhelp32Snapshot(TH32CS_SNAPALL{TH32CS_SNAPPROCESS}, aParent);
try
pe32.dwSize := SizeOf(TPROCESSENTRY32);
Result:=Process32First(snap, pe32);
while Result
  do begin
  res:=AnsiLowercase(StrPas(PChar(@pe32.szExeFile[Low(pe32.szExeFile)])));
  if (AnsiPos(exe, res)<>0)
     then Add(pe32.th32ProcessID, pe32.th32ParentProcessID);
  Result:=Process32Next(snap, pe32);
  end;
finally
  CloseHandle(snap);
end;
end;

function TProcessList.Clear : boolean;
begin
ProcessWindowList.Clear;
Setlength(Items,0);
Result:=false;
end;

function TDriveList.Fill  : integer;
//drvTypes : array[0..5] of string = ('Unknown','Removable','Fixed','Network','CD-ROM','RAM Disk');
var //https://msdn.microsoft.com/en-us/library/bstcxhf7(v=vs.84).aspx
 FSO : variant;  // https://msdn.microsoft.com/en-us/library/z9ty6h50(v=vs.84).aspx
 drv : variant;  // https://msdn.microsoft.com/en-us/library/ts2t8ybh(v=vs.84).aspx
 cnt : integer;
 ind : integer;
begin
Result:=-1;
try
Clear;
CoInitialize(nil);
FSO:=CreateOleObject('Scripting.FileSystemObject');
try
if VarType(FSO)=VarDispatch
   then begin
   for cnt:=Ord('A') to Ord('Z')
     do try
        drv:=FSO.GetDrive(Chr(cnt)+':\');
        if VarType(FSO)=VarDispatch
              then begin
              ind:=Length(Items);
              SetLength(Items, ind+1);
              with Items[ind] do
                begin
                DriveLetter   := shortstring(drv.DriveLetter);
                VolumeName    := shortstring(drv.VolumeName);
                ShareName     := shortstring(drv.ShareName);
                RootFolder    := shortstring(drv.RootFolder);
                DriverType    := integer(drv.DriveType);
                TotalSize     := drv.TotalSize;
                FreeSpace     := drv.FreeSpace;
                AvailableSpace:= drv.AvailableSpace;
                end;
              end;
           except
           on E : Exception do ;//LogErrorMessage();
           end;
       end;
finally
drv:=null;
FSO:=null;
CoUninitialize;
end;
except
on E : Exception do ;
end;
end;


function  TDriveList.ToString : string;
const
  drvTypes : array[0..5] of string = ('Unknown','Removable','Fixed','Network','CD-ROM','RAM Disk');
  delimiter =  crlf + tab; // ';'
var
 cnt : integer;
begin
Result:='';
try
for cnt:=0 to High(Items)
  do with Items[cnt] do
  Result:=Result+ Format(
     'DriveLetter: %s' + delimiter +
     'VolumeName: %s'  + delimiter +
     'ShareName: %s'   + delimiter +
     'RootFolder: %s'  + delimiter +
     'DriverType: %s'  + delimiter +
     'TotalSize: %f'   + delimiter +
     'FreeSpace: %f'   + delimiter +
     'AvailableSpace: %f' +crlf
     ,
     [
      DriveLetter
     ,VolumeName
     ,ShareName
     ,RootFolder
     ,drvTypes[DriverType]
     ,TotalSize       / Divider_GB
     ,FreeSpace       / Divider_GB
     ,AvailableSpace  / Divider_GB
     ]);
except
on E : Exception do ;
end;
end;



function TDriveList.Clear : boolean;
begin
Result:=false;
try
SetLength(Items,0);
Result:=true;
except
on E : Exception do ;
end;
end;


(*Список окон со свойствами*)

(*-------------- Примерный вызов ----------------------------------------------
 procedure ENumAllWnds(const ParentWnd : cardinal; const FileName : string);
 var
 strl  :TStringList;
 procedure ENumWnds(ParentWnd : cardinal; Level : integer = 0);
 var
 wnds : TWndDescrs;
 cnt  : integer;
 // ar   : array[0..100] of char;
 begin
 ListOfWindows(ParentWnd,wnds);
 try
 for cnt:=0 to High(wnds)
 do begin
 //FillChar(ar,Level,#9);
 //strl.Add((trPas(ar)+FormatFloat('00000000',ParentWnd)+' > '+FormatFloat('00000000',wnds[cnt].Handle)+' Class : '+StrPas(wnds[cnt].ClassName)+' ['+StrPas(wnds[cnt].WndText)+']');
 //FillChar(ar,101,#0);
 strl.Add(FormatFloat('00000000',ParentWnd)+' > '+FormatFloat('00000000',wnds[cnt].Handle)+' CLS : '+StrPas(wnds[cnt].ClassName)+' ['+StrPas(wnds[cnt].WndText)+'] "'+StrPas(wnds[cnt].FileName)+'"');
 ENumWnds(wnds[cnt].Handle,Level+1);
 end;
 finally
 SetLength(Wnds,0);
 end;
 end;
 begin
 strl:=TStringList.Create;
 strl.Sorted:=True;
 strl.Duplicates:=dupIgnore;
 try
 ENumWnds(ParentWnd);
 strl.SaveToFile(FileName);
 finally
 strl.Clear;FreeAndNil(strl);
 end;
 end;
*)



procedure ListOfWindows(const ParentHandle: cardinal;var WndDescrs: TWndDescrs);
var
  ln: integer;
begin
  SetLength(WndDescrs, 0);
  ln := Length(WndDescrs);
  SetLength(WndDesrscLocal, 0);
  try
    EnumChildWindows(ParentHandle,@EWPChilds, 0);//integer(PChar('t_main'))); // 0
    SetLength(WndDescrs, ln + Length(WndDesrscLocal));
    if Length(WndDesrscLocal)> 0 then
      System.Move(WndDesrscLocal[0], WndDescrs[0],
        SizeOf(TWndDescr)* Length(WndDesrscLocal));
    //for ln:=0 to High(WndDescrs)
    //do if WndDescrs[ln].Parent<>ParentHandle then ListOfWindows(WndDescrs[ln].Handle,WndDescrs);
  finally
    SetLength(WndDesrscLocal, 0);
  end;
end;

function GetWindowEXEModuleName(wnd:HWND):string; // для Win2K/XP. В Win9x нужно юзать GetWindowModuleFileName
var
 wt   : PChar;
 prc  : THandle;
 prcID: cardinal;
begin
result:='';
if GetWindowThreadProcessID(wnd,prcID)<>0
   then begin
   prc:=OpenProcess(PROCESS_ALL_ACCESS,false,prcID);
   if prc<>0
      then begin
      wt:=AllocMem(MAX_Path+SizeOfChar+1);
      try
      if GetModuleFileNameExW(prc,0,wt,MAX_PATH*2)<>0
         then result:=StrPas(wt);
      finally
      CloseHandle(prc);
      FreeMem(wt);
      end;
      end;
   end;
end;


function GetFullFileNameForPID(const aPID: cardinal) : string;
var
  snap      : cardinal;
  sz        : integer;
  me32      : TMODULEENTRY32;
  ok        : boolean;
begin
Result:='';
snap := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, aPID);
try
if snap <> 0
   then begin
   sz := SizeOf(TMODULEENTRY32);
   FillChar(me32, sz, 0);
   me32.dwSize := sz;
   ok:=Module32First(snap, me32);
   while ok do
     begin
     if me32.th32ProcessID = aPID
        then begin
        Result:=AC2Str(me32.szExePath);
        Break;
        end;
     ok:=Module32Next(snap, me32)
     end;
   end;
finally
  CloseHandle(snap);
end;
end;


function GetFullFileNameForWindow(const WndHandle: cardinal) : string;
var
  ProcessID : DWORD;
begin
GetWindowThreadProcessId(WndHandle,@ProcessID);
Result:=GetFullFileNameForPID(ProcessID);
end;

procedure SaveBytes(const aBytes: TByteDynArray;const aFileName:string);
var
  fs: TfileStream;
begin
  fs := TfileStream.Create(aFileName, fmCreate);
  try
  fs.WriteBuffer((@aBytes[0])^, Length(aBytes));
  finally
  fs.Free;
  end;
end;


procedure SaveBytes(const aBytes: array of byte;const aFileName:string);
var
  fs: TfileStream;
begin
  fs := TfileStream.Create(aFileName, fmCreate);
  try
  fs.WriteBuffer((@aBytes[0])^, Length(aBytes));
  finally
  fs.Free;
  end;
end;

procedure SaveBytes(const aBytes: TBytes;const aFileName:string);
var
  fs: TfileStream;
begin
  fs := TfileStream.Create(aFileName, fmCreate);
  try
  fs.WriteBuffer((@aBytes[0])^, Length(aBytes));
  finally
  fs.Free;
  end;
end;


function GDV(const Value: variant):string;
const
  BoolChars: array[boolean]of String =('Нет', 'Да');
var
  tmp: integer;
  tmpFN:string;
//  E  :Exception;
begin
//  try
    case VarType(Value)of
      //vtInteger:    Result:=IntToStr(Value);
      //vtBoolean:    Result:=BoolChars[Boolean(Value)];
      //vtChar:       Result:=Value;
      //vtExtended:   Result:=FloatToStr(Value);
      //vtString:     Result:=Value;
      //vtPChar:      Result:=String(Value);
      //vtObject:     Result:=Value.ClassName;
      //vtClass:      Result:=Value.ClassName;
      //vtAnsiString: Result:=string(Value);
      //vtCurrency:   Result:=CurrToStr(Value);
      //varVariant:    Result:=string(Value);
      //vtInt64:      Result:=IntToStr(Value);
      varEmpty:
        Result := '';//= $0000; { vt_empty        0 }
      varNull:
        Result := '';//= $0001; { vt_null         1 }
      varSmallint:
        Result := IntToStr(Value);//= $0002; { vt_i2           2 }
      varInteger:
        Result := IntToStr(Value);//= $0003; { vt_i4           3 }
      varSingle:
        Result := FloatToStr(Value);//= $0004; { vt_r4           4 }
      varDouble:
        Result := FloatToStr(Value);//= $0005; { vt_r8           5 }
      varCurrency:
        Result := CurrToStr(Value);//= $0006; { vt_cy           6 }
      varDate:
        Result := DateTimeToStr(Value);//= $0007; { vt_date         7 }
      varOleStr:
        Result := String(Value);
        //'varOLEStr';                   //= $0008; { vt_bstr         8 }
      varDispatch:
        //Result := Value.Get_LastLogin;
        //Result := String(Value);//'varDispath';                  //= $0009; { vt_dispatch     9 }
        Result := IntToStr(Value);
      varError:
        Result:='ERROR:'+IntToStr(TVarData(Value).VError);
      varBoolean:
        Result := BoolChars[boolean(Value)];//= $000B; { vt_bool        11 }
      varVariant:
        Result := String(Value);//= $000C; { vt_variant     12 }
      varUnknown:
        Result := 'varUnknown';//= $000D; { vt_unknown     13 }
      varShortInt:
        Result := IntToStr(Value);//= $0010; { vt_i1          16 }
      varByte:
        Result := IntToStr(Value);//= $0011; { vt_ui1         17 }
      varWord:
        Result := IntToStr(Value);//= $0012; { vt_ui2         18 }
      varLongWord:
        Result := IntToStr(Value);//= $0013; { vt_ui4         19 }
      varInt64:
        Result := IntToStr(Value);//= $0014; { vt_i8          20 }
      varUInt64:
        Result := IntToStr(Value);//= $0015; { vt_i8          21 }
      varStrArg:
        Result := String(Value);//= $0048; { vt_clsid       72 }
      varString:
        Result := String(Value);
        //= $0100; { Pascal string 256 } {not OLE compatible }
      varAny:
        Result := String(Value);
        //'varAny';                      //= $0101; { Corba any     257 } {not OLE compatible }
      varTypeMask:
        Result := String(Value);//'varTypeMask';                 //= $0FFF;
      varArray:
        Result := String(Value);//'varArray';                    //= $2000;
      varByRef:
        Result := String(Value);//'varByRef';                    //= $4000;
      varUString:
        Result := String(Value);{Unicode string 258} {not OLE compatible}
      //custom types range from $110 (272) to $7FF (2047)
      $0111:
        Result := FormatFloat('#00.000000########', Value);
        //использовалось(как min один раз) как numeric(17,14)
      $2011:
        begin//как правило в ADO DB это поле типа Image
          tmpFN := SetTailBackSlash(GetTempFolder)+ CreateGuid;
          SaveBytes(TByteDynArray(Value), tmpFN);
          Result := tmpFN;
        end;
    else
      begin
        tmp := integer(VarType(Value));
        Result := IntToStr(tmp)+ '>>' + String(Value);
      end;
    end;
//  except
//  end;
end;

{
 case Integer of
 0: (case Byte of
 vtInteger:       (VInteger: Integer);
 vtBoolean:       (VBoolean: Boolean);
 vtChar:          (VChar: AnsiChar);
 vtExtended:      (VExtended: PExtended);
 vtString:        (VString: PShortString);
 vtPointer:       (VPointer: Pointer);
 vtPChar:         (VPChar: PAnsiChar);
 vtObject:        (VObject: TObject);
 vtClass:         (VClass: TClass);
 vtWideChar:      (VWideChar: WideChar);
 vtPWideChar:     (VPWideChar: PWideChar);
 vtAnsiString:    (VAnsiString: Pointer);
 vtCurrency:      (VCurrency: PCurrency);
 vtVariant:       (VVariant: PVariant);
 vtInterface:     (VInterface: Pointer);
 vtWideString:    (VWideString: Pointer);
 vtInt64:         (VInt64: PInt64);
 vtUnicodeString: (VUnicodeString: Pointer);
 );
 1: (_Reserved1: NativeInt;
 VType:      Byte;
 );
 end;
}

function GDV(aValue: TVarRec):string;
const
  BoolChars: array[boolean]of String =('Нет', 'Да');
begin
  with aValue do
    case VType of
      vtInteger:
        Result := IntToStr(VInteger);
      vtBoolean:
        Result := BoolChars[VBoolean];
      vtChar:
        Result := string(VChar);
      vtExtended:
        Result := FloatToStr(VExtended^);
      vtString:
        Result := string(VString^);
      vtPointer:
        Result := string(aValue.VPointer^);
      vtPChar:
        Result := string(StrPas(VPChar));
      vtObject:
        Result := VObject.ClassName;
      vtClass:
        Result := VClass.ClassName;
      vtWideChar:
        Result := VWideChar;
      vtPWideChar:
        Result := StrPas(VPWideChar);
      vtAnsiString:
        Result := string(StrPas(PAnsiChar(VAnsiString)));
      vtCurrency:
        Result := FloatToStr(VCurrency^);
      vtVariant:
        Result := GDV(VVariant^);
      vtInterface:
        Result := string(VInterface^);
      vtWideString:
        Result := StrPas(PWideChar(VWideString));
      vtInt64:
        Result := IntToStr(VInt64^);
      vtUnicodeString:
        Result := StrPas(PChar(VUnicodeString));
    end;
end;


function VarArrayToString(Value : variant) : string;
var
 dim : array of integer;
 vt  : word;
 cnt : integer;
begin
Result:='';
vt:=VarType(Value);
if vt=varEmpty then Exit;
if vt and varArray=0
   then begin
   Result:=GDV(Value);
   Exit;
   end;
SetLength(dim,VarArrayDimCount(Value));
try
for cnt:=0 to High(dim)
  do dim[cnt]:=VarArrayHighBound(Value,cnt+1);
if Length(dim)<>0
 then ;
//            cntD:=VarArrayHighBound(ADOQ.Fields[cnt].Value,1);
//            while cntD>=0
//              do begin
//              tmp:=tmp+Format('%s, ',[ADOQ.Fields[cnt].Value[cntD]]);
//              dec(cntD);
//              end;
finally
SetLength(dim,0);
end;
end;

function VarArray1DToString(Value : variant) : string;
var
 vt  : word;
 cnt : integer;
begin
Result:='';
vt:=VarType(Value);
if vt=varEmpty then Exit;
if vt and varArray=0
   then begin
   Result:=GDV(Value);
   Exit;
   end;
cnt:=VarArrayHighBound(Value,1);
if cnt=-1 then Exit;
while cnt>=0
  do begin
  Result:=Result+Format('%s,',[Value[cnt]]);
  dec(cnt);
  end;
Result:=Copy(Result,1,Length(Result)-1);
end;


procedure GetDataSet(aADOc: TADOConnection;const aTableName, aOrder:string; var aResdataSet: TVariantArrayD2);
var
  ADOSP: TADOStoredProc;
  erc: integer;
  ers:string;
  cntR: integer;
  Fldcnt: integer;
  cntF: integer;
begin
  SetLength(aResdataSet, 0);
  if not Assigned(aADOc)then
    Exit;
  ADOSP := TADOStoredProc.Create(nil);
  try
    try
      with ADOSP do
      begin
        Connection := aADOc;
        ProcedureName := 'map_GetDataSet;1';
        if not Parameters.Refresh then
        begin
          Exit;
        end;
        Parameters.ParamByName('@TableName').Value := aTableName;
        Parameters.ParamByName('@Order').Value := aOrder;
        Active := true;
        cntR := 0;
        SetLength(aResdataSet, RecordCount + 1);
        Fldcnt := Fields.Count;
        SetLength(aResdataSet[cntR], Fldcnt);
        for cntF := 0 to Fields.Count - 1 do
          aResdataSet[cntR][cntF]:= Fields[cntF].FieldName;
        Inc(cntR);
        while not Eof do
        begin
          SetLength(aResdataSet[cntR], Fldcnt);
          for cntF := 0 to Fields.Count - 1 do
            aResdataSet[cntR][cntF]:= Fields[cntF].Value;
          Inc(cntR);
          Next;
        end;
        Active := false;
      end;
    except
      on E: Exception do
      begin
        erc := GetLastError;
        ers := Format('Error in GetDataSet : %s (%s)',
          [E.Message, GetErrorString(erc)]);
        ShowMessageWarning(ers, 'Сбой в общем модуле');
      end;
    end;
  finally
    if Assigned(ADOSP)then
    begin
      if ADOSP.Active then
        ADOSP.Close;
      FreeAndNil(ADOSP);
    end;
  end;
end;

function GetTagData(const aXMLUnit, aTag:string):string;
//var
//stPos : integer;
//fnPos : integer;
begin
  //stPos:=Pos('<'+aTag+'>',aXMLUnit)+Length(aTag)+2;
  //fnPos:=PosEx('</'+aTag+'>',aXMLUnit,stPos);
  //Result:=Copy(aXMLUnit,stPos,fnPos-stPos);

  Result := CopyFromTo(aXMLUnit, Format('<%s>',[aTag]), Format('</%s>',[aTag]),
    true, false);
end;

(*3D треугольник показывающий сортировку*)
procedure SimpleTriAngleOrder(aCanvas: TCanvas; aLeft, aTop: integer;
  Desc: boolean; TriangleOrderBaseColor: TTriangleOrderBaseColor = ttobcGray;
  height: integer = 17);
var
  cnt: integer;
  pnClr, brClr: TColor;
  pnStyle: TPenStyle;
  pnWdt: integer;
  deltaClr: Byte;
  ColorByte: Byte;
begin
  pnClr := aCanvas.Pen.Color;
  pnStyle := aCanvas.Pen.Style;
  pnWdt := aCanvas.Pen.Width;
  brClr := aCanvas.Brush.Color;
  aCanvas.Pen.Color := clBlack;
  aCanvas.Pen.Style := psSolid;
  aCanvas.Pen.Width := 1;
  deltaClr := Round((255 -(127 / height))/ height);
  for cnt := 0 to height div 2 do
  begin

    if cnt = 0 then
      aCanvas.Pen.Color := clBlack
    else
    begin
      ColorByte := 128 + deltaClr * cnt;
      case TriangleOrderBaseColor of
        ttobcRed:
          aCanvas.Pen.Color := RGB(ColorByte, 0, 0);
        ttobcGreen:
          aCanvas.Pen.Color := RGB(0, ColorByte, 0);
        ttobcBlue:
          aCanvas.Pen.Color := RGB(0, 0, ColorByte);
        ttobcYellow:
          aCanvas.Pen.Color := RGB(ColorByte, ColorByte, 0);
      else
        aCanvas.Pen.Color := RGB(ColorByte, ColorByte, ColorByte);//ttobcGray
      end;
    end;
    if Desc then
    begin
      aCanvas.MoveTo(aLeft + cnt, aTop + height - cnt);
      aCanvas.LineTo(aLeft + height div 2, aTop + cnt);
      aCanvas.LineTo(aLeft + height - cnt, aTop + height - cnt);
      aCanvas.LineTo(aLeft + cnt, aTop + height - cnt);
    end
    else
    begin
      aCanvas.MoveTo(aLeft + cnt, aTop + cnt);
      aCanvas.LineTo(aLeft + height div 2, aTop + height - cnt);
      aCanvas.LineTo(aLeft + height - cnt, aTop + cnt);
      aCanvas.LineTo(aLeft + cnt, aTop + cnt);
    end;
  end;
  aCanvas.Pen.Color := pnClr;
  aCanvas.Pen.Style := pnStyle;
  aCanvas.Pen.Width := pnWdt;
  aCanvas.Brush.Color := brClr;
end;

procedure SimpleTriAngleOrder(aDC: hDC; aLeft, aTop: integer; Desc: boolean;
  TriangleOrderBaseColor: TTriangleOrderBaseColor = ttobcGray;
  height: integer = 17);
var
  opn, pn: hPen;
  cnt: integer;
  deltaClr: Single;
  deltaClrRes: integer;
  ColorByte: Byte;
  clrRef: TColorRef;
begin
  pn := CreatePen(PS_SOLID, 1, clBlack);
  opn := SelectObject(aDC, pn);
  deltaClr :=(255 / height);
  for cnt := 0 to height div 2 do
  begin
    if cnt = 0 then
      clrRef := Graphics.ColorToRGB(clBlack)
    else
    begin
      deltaClrRes := Round(cnt * deltaClr);
      if deltaClrRes > 127 then
        deltaClrRes := 127;
      ColorByte := 128 + deltaClrRes;
      case TriangleOrderBaseColor of
        ttobcRed:
          clrRef := RGB(ColorByte, 0, 0);
        ttobcGreen:
          clrRef := RGB(0, ColorByte, 0);
        ttobcBlue:
          clrRef := RGB(0, 0, ColorByte);
        ttobcYellow:
          clrRef := RGB(ColorByte, ColorByte, 0);
      else
        clrRef := RGB(ColorByte, ColorByte, ColorByte);//ttobcGray
      end;
    end;
    DeleteObject(SelectObject(aDC, CreatePen(PS_SOLID, 1, clrRef)));
    if Desc then
    begin
      MoveToEx(aDC, aLeft + cnt, aTop + height - cnt,nil);
      LineTo(aDC, aLeft + height div 2, aTop + cnt);
      LineTo(aDC, aLeft + height - cnt, aTop + height - cnt);
      LineTo(aDC, aLeft + cnt, aTop + height - cnt);
    end
    else
    begin
      MoveToEx(aDC, aLeft + cnt, aTop + cnt,nil);
      LineTo(aDC, aLeft + height div 2, aTop + height - cnt);
      LineTo(aDC, aLeft + height - cnt, aTop + cnt);
      LineTo(aDC, aLeft + cnt, aTop + cnt);
    end;
  end;
  DeleteObject(SelectObject(aDC, opn));
end;

procedure DrawOrder(aDC: hDC; aRct: TRect; Desc: boolean; TriangleOrderBaseColor: TTriangleOrderBaseColor = ttobcGray);
var
  opn, pn: hPen;
  cnt: integer;
  deltaClr: Single;
  deltaClrRes: integer;
  ColorByte: Byte;
  clrRef: TColorRef;
  height : integer;
begin
  height:=aRct.Bottom - aRct.Top;
  pn := CreatePen(PS_SOLID, 1, clBlack);
  opn := SelectObject(aDC, pn);
  deltaClr :=(255 / height);
  for cnt := 0 to height div 2 do
  begin
    if cnt = 0 then
      clrRef := Graphics.ColorToRGB(clBlack)
    else
    begin
      deltaClrRes := Round(cnt * deltaClr);
      if deltaClrRes > 127 then
        deltaClrRes := 127;
      ColorByte := 128 + deltaClrRes;
      case TriangleOrderBaseColor of
        ttobcRed:
          clrRef := RGB(ColorByte, 0, 0);
        ttobcGreen:
          clrRef := RGB(0, ColorByte, 0);
        ttobcBlue:
          clrRef := RGB(0, 0, ColorByte);
        ttobcYellow:
          clrRef := RGB(ColorByte, ColorByte, 0);
      else
        clrRef := RGB(ColorByte, ColorByte, ColorByte);//ttobcGray
      end;
    end;
    DeleteObject(SelectObject(aDC, CreatePen(PS_SOLID, 1, clrRef)));
    with aRct do
    if not Desc then
    begin
      MoveToEx(aDC, Left + cnt, Top + height - cnt,nil);
      LineTo(aDC, Left + height div 2, Top + cnt);
      LineTo(aDC, Left + height - cnt, Top + height - cnt);
      LineTo(aDC, Left + cnt, Top + height - cnt);
    end
    else
    begin
      MoveToEx(aDC, Left + cnt, Top + cnt,nil);
      LineTo(aDC, Left + height div 2, Top + height - cnt);
      LineTo(aDC, Left + height - cnt, Top + cnt);
      LineTo(aDC, Left + cnt, Top + cnt);
    end;
  end;
  DeleteObject(SelectObject(aDC, opn));
end;

(*Красно-зеленый 3D треугольник с с основанием и высотой 17  (ВПРАВО)*)
procedure SimpleTriAngleRight(aDC: hDC; aTop, aLeft: integer; IsOn: boolean;
  height: integer = 17);
var
  cnt: integer;
  CurColor: cardinal;
  opn, pn: hPen;
  deltaClr: Byte;
begin

  pn := CreatePen(PS_SOLID, 1, Graphics.ColorToRGB(clBlack));
  opn := SelectObject(aDC, pn);
  try
    deltaClr := Round((255 -(127 / height))/ height);
    for cnt := 0 to height div 2 do
      if IsOn then
      begin
        CurColor := RGB(0, 128 + deltaClr * cnt, 0);
        if cnt = 0 then
          CurColor := clBlack;
        pn := CreatePen(PS_SOLID, 1, CurColor);
        DeleteObject(SelectObject(aDC, pn));
        MoveToEx(aDC, aLeft + cnt, aTop + cnt,nil);
        LineTo(aDC, aLeft + height - cnt, aTop + height div 2);
        LineTo(aDC, aLeft + cnt, aTop + height - cnt);
        LineTo(aDC, aLeft + cnt, aTop + cnt);
      end
      else
      begin
        CurColor := RGB(128 + deltaClr * cnt, 0, 0);
        if cnt = 0 then
          CurColor := clBlack;
        pn := CreatePen(PS_SOLID, 1, CurColor);
        DeleteObject(SelectObject(aDC, pn));
        MoveToEx(aDC, aLeft + cnt, aTop + cnt,nil);
        LineTo(aDC, aLeft + height - cnt, aTop + height div 2);
        LineTo(aDC, aLeft + cnt, aTop + height - cnt);
        LineTo(aDC, aLeft + cnt, aTop + cnt);
      end;
  finally
    DeleteObject(SelectObject(aDC, opn));
  end;
end;

(*Градиентная раскраска от FromRGB до TRGB (сверху вниз) указанного DC*)
{$R-}

procedure DrawGradient(aCanvas: TCanvas; Rect: TRect; aVertical: boolean;
  Colors: array of TColor);
var
  X, Y, z, stelle, mx, bis, faColorsh, mass: integer;
  Faktor: double;
  A: RGBArray;
  B: array of RGBArray;
  merkw: integer;
  merks: TPenStyle;
  merkp: TColor;
begin
  mx := High(Colors);
  if mx > 0 then
  begin
    if aVertical then
      mass :=(Rect.Right - Rect.Left)
    else
      mass :=(Rect.Bottom - Rect.Top);
    SetLength(B, mx + 1);
    for X := 0 to mx do
    begin
      Colors[X]:= Graphics.ColorToRGB(Colors[X]);
      B[X][0]:= GetRvalue(Colors[X]);
      B[X][1]:= GetGvalue(Colors[X]);
      B[X][2]:= GetBvalue(Colors[X]);
    end;
    merkw := aCanvas.Pen.Width;
    merks := aCanvas.Pen.Style;
    merkp := aCanvas.Pen.Color;
    aCanvas.Pen.Width := 1;
    aCanvas.Pen.Style := psSolid;
    faColorsh := Round(mass / mx);
    for Y := 0 to mx - 1 do
    begin
      if Y = mx - 1 then
        bis := mass - Y * faColorsh - 1
      else
        bis := faColorsh;
      for X := 0 to bis do
      begin
        stelle := X + Y * faColorsh;
        Faktor := X / bis;
        for z := 0 to 3 do
          A[z]:= trunc(B[Y][z]+((B[Y + 1][z]- B[Y][z])* Faktor));
        aCanvas.Pen.Color := TColor(RGB(A[0], A[1], A[2]));
        if aVertical then
        begin
          aCanvas.MoveTo(Rect.Left + stelle, Rect.Top);
          aCanvas.LineTo(Rect.Left + stelle, Rect.Bottom);
        end
        else
        begin
          aCanvas.MoveTo(Rect.Left, Rect.Top + stelle);
          aCanvas.LineTo(Rect.Right, Rect.Top + stelle);
        end;
      end;
    end;
    B := nil;
    aCanvas.Pen.Width := merkw;
    aCanvas.Pen.Style := merks;
    aCanvas.Pen.Color := merkp;
  end
  else
    //Please specify at least two colors
    raise EMathError.Create
      ('Es mussen mindestens zwei Farben angegeben werden.');
end;
{$R+}
{$R-}

procedure DrawGradient(aDC: hDC; Rect: TRect; Horizontal: boolean;
  Colors: array of TColor);
var
  X, Y, z, stelle, mx, bis, faColorsh, mass: integer;
  Faktor: double;
  A: RGBArray;
  B: array of RGBArray;
  pn: hPen;
  tpn: hPen;
  opn: hPen;
begin
  mx := High(Colors);
  if mx > 0 then
  begin
    if Horizontal then
      mass :=(Rect.Right - Rect.Left)
    else
      mass :=(Rect.Bottom - Rect.Top);
    SetLength(B, mx + 1);
    for X := 0 to mx do
    begin
      //Colors[x] := ColorToRGB(Colors[x]);
      if Colors[X]< 0 then
        Colors[X]:= GetSysColor(Colors[X]and $000000FF);

      B[X][0]:= GetRvalue(Colors[X]);
      B[X][1]:= GetGvalue(Colors[X]);
      B[X][2]:= GetBvalue(Colors[X]);
    end;
    pn := CreatePen(PS_SOLID, 1, RGB(255, 255, 255));
    opn := SelectObject(aDC, pn);
    faColorsh := Round(mass / mx);
    for Y := 0 to mx - 1 do
    begin
      if Y = mx - 1 then
        bis := mass - Y * faColorsh - 1
      else
        bis := faColorsh;
      for X := 0 to bis do
      begin
        stelle := X + Y * faColorsh;
        if bis = 0 then
          Faktor := 0
        else
          Faktor := X / bis;
        for z := 0 to 3 do
          A[z]:= Round{Trunc}(B[Y][z]+((B[Y + 1][z]- B[Y][z])* Faktor));
        pn := CreatePen(PS_SOLID, 1, RGB(A[0], A[1], A[2]));
        tpn := SelectObject(aDC, pn);
        DeleteObject(tpn);
        if Horizontal then
        begin
          MoveToEx(aDC, Rect.Left + stelle, Rect.Top,nil);
          LineTo(aDC, Rect.Left + stelle, Rect.Bottom);
        end
        else
        begin
          MoveToEx(aDC, Rect.Left, Rect.Top + stelle,nil);
          LineTo(aDC, Rect.Right, Rect.Top + stelle);
        end;
      end;
    end;
    B := nil;
    SelectObject(aDC, opn);
    DeleteObject(pn);
    //ACanvas.Pen.Width := merkw;
    //ACanvas.Pen.Style := merks;
    //ACanvas.Pen.Color := merkp;
  end
  else
    //Please specify at least two colors
    raise EMathError.Create
      ('Es mussen mindestens zwei Farben angegeben werden.');
end;
{$R+}

procedure FillRGB(aColor: TColor;var aR, aG, aB: Byte);
var
  cr: TColorRef;
begin
  cr := Graphics.ColorToRGB(aColor);
  aR := GetRvalue(cr);
  aG := GetGvalue(cr);
  aB := GetBvalue(cr);
end;

//function InvertColor(aColor : TColor) : TColor;
//var
//r,g,b : byte;
//begin
//FillRGB(aColor,r,g,b);
//{$R-}
//Result:=TColor(RGB(255-r,255-g,255-b));
//{$R+}
//end;

procedure ConvertColor(aStartColor, aFinishColor: TColor;
  var aCurrentColor: TColor;var aToFinishColor: boolean);
var
  ColorTo: TColor;
  rR, gR, br: boolean;
  rT, gT, bt: Byte;
  rC, gC, bC: Byte;
begin
  if aToFinishColor
     then begin
     ColorTo := aFinishColor;
     end
     else begin
     ColorTo := aStartColor;
     end;
  rR := false;
  gR := false;
  br := false;
  FillRGB(ColorTo, rT, gT, bt);
  FillRGB(aCurrentColor, rC, gC, bC);
  if rC <> rT then
    if rC < rT then
      rC := rC + 1
    else
      rC := rC - 1
  else
    rR := true;
  if gC <> gT then
    if gC < gT then
      gC := gC + 1
    else
      gC := gC - 1
  else
    gR := true;
  if bC <> bt then
    if bC < bt then
      bC := bC + 1
    else
      bC := bC - 1
  else
    br := true;
  aCurrentColor := TColor(RGB(rC, gC, bC));
  if rR and gR and br then
    aToFinishColor := not aToFinishColor;
end;

procedure ConvertColor(var aColors: array of TColor;
  var aToFinishColor: boolean);
begin
  if Length(aColors)= 3 then
    ConvertColor(aColors[0], aColors[1], aColors[2], aToFinishColor);
end;

(*Отображение текста под определенным углом . Угол 10 задается как 100*)
{*********************************************************************}
{Для отображения текста под определенным углом}
{hwnd - Handle окна , в котором рисуется текст}
{X,Y - Координаты начала текста}
{lf  - TlogFont (для описания его названия, высоты и т.п.).}
{Подробнее см. win32sdk.hlp}
{Rc,Gc,Bc - RGB color}
{sRotate - текст}
{angle - угол поворота 360 градусов соотв. 3600 в функции}
{Переписано из примера на C (Win32sdk.hlp)}
{*********************************************************************}
procedure TextRotateDC(dc: hDC; X, Y: integer; lf: TLogFont; ClrTxt: TColor;
  sRotate: PChar; angle: integer); stdcall;
var
  hfnt, hfntPrev: hFont;
begin
  SetTextColor(dc, ClrTxt);
  SetBkMode(dc, Transparent);
  lf.lfEscapement := angle;
  hfnt := CreateFontIndirect(lf);
  hfntPrev := SelectObject(dc, hfnt);
  TextOut(dc, X, Y, sRotate, Length(sRotate));
  SelectObject(dc, hfntPrev);
  DeleteObject(hfnt);
  SetBkMode(dc, Opaque);
end;

procedure TextRotateDC(dc: hDC; Font: TFont; aRct: TRect; ShowStr: PChar;
  angle: integer; alg: integer = 0); overload; stdcall;
var
  hfnt, hfntPrev: hFont;
  lf: TLogFont;
begin
  GetObject(Font.Handle, SizeOf(TLogFont),@lf);
  SetBkMode(dc, Transparent);
  lf.lfEscapement := angle;
  hfnt := CreateFontIndirect(lf);
  hfntPrev := SelectObject(dc, hfnt);
  SetTextColor(dc, Font.Color);
  if alg = 0 then
    DrawText(dc, ShowStr, Strlen(ShowStr), aRct, DT_SINGLELINE + DT_BOTTOM +
      DT_LEFT + DT_END_ELLIPSIS)
  else
    DrawText(dc, ShowStr, Strlen(ShowStr), aRct, alg);
  SelectObject(dc, hfntPrev);
  DeleteObject(hfnt);
  SetBkMode(dc, Opaque);
end;

procedure TextRotateDC(dc: hDC; Font: hFont; aRct: TRect; ShowStr: PChar;
  angle: integer; alg: integer = 0); overload; stdcall;
var
  hfnt, hfntPrev: hFont;
  lf: TLogFont;
begin
  GetObject(Font, SizeOf(TLogFont),@lf);
  SetBkMode(dc, Transparent);
  lf.lfEscapement := angle;
  hfnt := CreateFontIndirect(lf);
  hfntPrev := SelectObject(dc, hfnt);
  if alg = 0 then
    DrawText(dc, ShowStr, Strlen(ShowStr), aRct, DT_SINGLELINE + DT_BOTTOM +
      DT_LEFT + DT_END_ELLIPSIS)
  else
    DrawText(dc, ShowStr, Strlen(ShowStr), aRct, alg);
  SelectObject(dc, hfntPrev);
  DeleteObject(hfnt);
  SetBkMode(dc, Opaque);
end;

procedure FillImageListFromResource(aIL: TImageList;const aResourceName:string; aDefSize: integer = 16);
var
  bmp: TBitmap;
  oneBMP: TBitmap;
  cntX, lnX: integer;
  cntY, lnY: integer;
begin
  bmp := TBitmap.Create;
  oneBMP := TBitmap.Create;
  aIL.BeginUpdate;
  try
    aIL.Clear;
    bmp.PixelFormat := pf32bit;
    with oneBMP do
    begin
      Width := aDefSize;
      height := aDefSize;
    end;
    if FileExists(aResourceName)then
      bmp.LoadFromFile(aResourceName)
    else
      bmp.LoadFromResourceName(HInstance, aResourceName);
    lnX := bmp.Width div aDefSize;
    lnY := bmp.height div aDefSize;
    aIL.AllocBy := 0;
    for cntX := 0 to lnX - 1 do
      for cntY := 0 to lnY - 1 do
      begin
        BitBlt(oneBMP.Canvas.Handle, 0, 0, aDefSize, aDefSize,
          bmp.Canvas.Handle, cntX * aDefSize, cntY * aDefSize, SRCCOPY);
        aIL.AddMasked(oneBMP, clFuchsia);
      end;
  finally
    aIL.EndUpdate;
    oneBMP.Free;
    bmp.Free;
  end;
end;


function AddIconForFile(aIL: TImageList;const aFileName:string) : integer;
var
  bmp: TBitmap;
begin
Result := -1;
  try
    bmp := TBitmap.Create;
    try
    bmp.Width:=16;
    bmp.Height:=16;
    GetBmp16FromFileIcon(aFileName, bmp, clFuchsia);
    if Assigned(bmp)and not bmp.Empty
       then Result := aIL.AddMasked(bmp, clFuchsia);
    finally
      bmp.Free;
    end;
  except
    on E: Exception do
  end;
end;



(*Преобразует цвет в оттенки серого*)
{$R-}

function RgbToGray(RGBColor: TColor): ColorRef;
var
  Gray: Byte;
  clr: ColorRef;
begin
  clr := Graphics.ColorToRGB(RGBColor);
  Gray := Round((0.30 * GetRvalue(clr))+(0.59 * GetGvalue(clr))+
    (0.11 * GetBvalue(clr)));
  Result := RGB(Gray, Gray, Gray);
end;
{$R+}
(*Преобразует цвета в указанном Rectangle в оттенки серого*)
{$R-}

function ColorToGray(aColor: TColor) : TColor; overload;
begin
Result:=TColor(RgbToGray(aColor));
end;

procedure Color2RGB(aColor: TColor; var R,G,B : byte); inline;
var
 cr : TColorRef;
begin
cr:=Graphics.ColorToRGB(aColor);
R:=GetRValue(cr);
G:=GetGValue(cr);
B:=GetBValue(cr);
end;

procedure ColorToGray(aDC: hDC; aRect: TRect);
var
  X, Y: integer;
begin
  for X := aRect.Left to aRect.Right - 1 do
    for Y := aRect.Top to aRect.Bottom - 1 do
      Windows.SetPixel(aDC, X, Y, RgbToGray(Windows.GetPixel(aDC, X, Y)));
end;
{$R+}
{$R-}

procedure ColorToGrayExColor(aDC: hDC; aRect: TRect; aColor: TColor);
var
  X, Y: integer;
  clr: TColor;
begin
  for X := aRect.Left to aRect.Right - 1 do
    for Y := aRect.Top to aRect.Bottom - 1 do
    begin
      clr := Windows.GetPixel(aDC, X, Y);
      if clr <> aColor then
        Windows.SetPixel(aDC, X, Y, RgbToGray(clr));
    end;
end;
{$R+}
{$R-}

procedure RGBtoHLS(RGB: TColor;var H, L, S: integer);
Var
  cMax, cMin: integer;
  Rdelta, Gdelta, Bdelta: Single;
  R, G, B: integer;{цвета}
Begin
  R := GetRvalue(RGB);
  G := GetGvalue(RGB);
  B := GetBvalue(RGB);
  cMax := Max(Max(R, G), B);
  cMin := Min(Min(R, G), B);
  L := Round((((cMax + cMin)* HLSMAX)+ RGBMAX)/(2 * RGBMAX));
  if(cMax = cMin)then
  begin
    S := 0;
    H := UNDEFINED;
  end
  else
  begin
    if(L <=(HLSMAX / 2))then
      S := Round((((cMax - cMin)* HLSMAX)+((cMax + cMin)/ 2))/(cMax + cMin))
    else
      S := Round((((cMax - cMin)* HLSMAX)+((2 * RGBMAX - cMax - cMin)/ 2))/
        (2 * RGBMAX - cMax - cMin));
    Rdelta :=(((cMax - R)*(HLSMAX / 6))+((cMax - cMin)/ 2))/(cMax - cMin);
    Gdelta :=(((cMax - G)*(HLSMAX / 6))+((cMax - cMin)/ 2))/(cMax - cMin);
    Bdelta :=(((cMax - B)*(HLSMAX / 6))+((cMax - cMin)/ 2))/(cMax - cMin);
    if(R = cMax)then
      H := Round(Bdelta - Gdelta)
    else if(G = cMax)then
      H := Round((HLSMAX / 3)+ Rdelta - Bdelta)
    else
      H := Round(((2 * HLSMAX)/ 3)+ Gdelta - Rdelta);
    if(H < 0)then
      H := H + HLSMAX;
    if(H > HLSMAX)then
      H := H - HLSMAX;
  end;
  if S < 0 then
    S := 0;
  if S > HLSMAX then
    S := HLSMAX;
  if L < 0 then
    L := 0;
  if L > HLSMAX then
    L := HLSMAX;
end;
{$R+}

(*Преобразование HLS в RGB*)
function HLStoRGB(H, L, S: integer): TColor;
Var
  Magic1, Magic2: Single;
  R, G, B: integer;
  function HueToRGB(n1, n2, hue: Single): Single;
  begin
    if(hue < 0)then
      hue := hue + HLSMAX;
    if(hue > HLSMAX)then
      hue := hue - HLSMAX;
    if(hue <(HLSMAX / 6))then
      Result :=(n1 +(((n2 - n1)* hue +(HLSMAX / 12))/(HLSMAX / 6)))
    else if(hue <(HLSMAX / 2))then
      Result := n2
    else if(hue <((HLSMAX * 2)/ 3))then
      Result :=(n1 +(((n2 - n1)*(((HLSMAX * 2)/ 3)- hue)+(HLSMAX / 12))/
        (HLSMAX / 6)))
    else
      Result :=(n1);
  end;

begin
  if(S = 0)then
  begin
    B := Round((L * RGBMAX)/ HLSMAX);
    R := B;
    G := B;
  end
  else
  begin
    if(L <=(HLSMAX / 2))then
      Magic2 :=(L *(HLSMAX + S)+(HLSMAX / 2))/ HLSMAX
    else
      Magic2 := L + S -((L * S)+(HLSMAX / 2))/ HLSMAX;
    Magic1 := 2 * L - Magic2;
    R := Round((HueToRGB(Magic1, Magic2, H +(HLSMAX / 3))* RGBMAX +(HLSMAX / 2))
      / HLSMAX);
    G := Round((HueToRGB(Magic1, Magic2, H)* RGBMAX +(HLSMAX / 2))/ HLSMAX);
    B := Round((HueToRGB(Magic1, Magic2, H -(HLSMAX / 3))* RGBMAX +(HLSMAX / 2))
      / HLSMAX);
  end;
  if R < 0 then
    R := 0;
  if R > RGBMAX then
    R := RGBMAX;
  if G < 0 then
    G := 0;
  if G > RGBMAX then
    G := RGBMAX;
  if B < 0 then
    B := 0;
  if B > RGBMAX then
    B := RGBMAX;
  Result := RGB(R, G, B);
end;

procedure RGBToCMYK(R ,G ,B : byte; var C ,M ,Y ,K : byte);
begin
  C := 255 - R;
  M := 255 - G;
  Y := 255 - B;
  if C < M then
    K := C else
    K := M;
  if Y < K then
    K := Y;
  if k > 0 then begin
    c := c - k;
    m := m - k;
    y := y - k;
  end;
end;

procedure CMYKTORGB(C ,M ,Y ,K : byte; var R ,G ,B : byte);
begin
   if (Integer(C) + Integer(K)) < 255 then
     R := 255 - (C + K) else
     R := 0;
   if (Integer(M) + Integer(K)) < 255 then
     G := 255 - (M + K) else
     G := 0;
   if (Integer(Y) + Integer(K)) < 255 then
     B := 255 - (Y + K) else
     B := 0;
end;

function AsByte(val : integer) : byte;
  begin
  if val<0
     then Result:=0
     else
  if val>255
     then Result:=255
     else Result:=byte(val)
  end;

function LightColor(aColor: TColor; aLighter: Byte): TColor; inline;
var
  H, L, S: integer;
begin
  RGBtoHLS(ColorToRGB(aColor), H, L, S);
  if L+aLighter<=High(byte)
     then L := Byte(L + aLighter)
     else L := 255;
  Result := HLStoRGB(H, L, S);
end;

function DarkColor(aColor: TColor; aLighter: Byte): TColor;
var
  H, L, S: integer;
begin
  RGBtoHLS(ColorToRGB(aColor), H, L, S);
  if L-aLighter>=0
     then L := Byte(L - aLighter)
     else L := 0;
  Result := HLStoRGB(H, L, S);
end;


procedure LightBitmap(bmp : TBitmap; aLighter: Byte; trnColor : TColor = clFuchsia);
var
 cntX,cntY : integer;
 clr : TColor;
begin
for cntX:=0 to bmp.Width-1
 do for cntY:=0 to bmp.Height-1
     do begin
     clr:=bmp.Canvas.Pixels[cntX, cntY];
     if clr<>trnColor
        then begin
        clr:=LightColor(clr,aLighter);
        bmp.Canvas.Pixels[cntX, cntY]:=clr;
        end;
     end;
end;


procedure VistaButton(aCanvas: TCanvas; aRect: TRect; aBaseColor: TColor;
  aUp: boolean = true);
var
  qrt: integer;
  rct: TRect;
  clrL: TColor;
const
  Lighter = 60;
begin
  qrt := Round((aRect.Bottom - aRect.Top)/ 4);
  clrL := LightColor(aBaseColor, Lighter);
  if aUp then
  begin
    aCanvas.Brush.Color := clrL;
    aCanvas.FillRect(aRect);
    DrawGradient(aCanvas, Bounds(aRect.Left, aRect.Bottom - qrt * 2,
      aRect.Right - aRect.Left, qrt * 2), false,[aBaseColor, clrL]);
  end
  else
  begin
    aCanvas.Brush.Color := aBaseColor;
    aCanvas.FillRect(aRect);
    DrawGradient(aCanvas, Bounds(aRect.Left, aRect.Bottom - qrt * 2,
      aRect.Right - aRect.Left, qrt * 2), false,[clrL, aBaseColor]);
  end;
  aCanvas.Brush.Style := bsClear;
  System.Move(aRect, rct, SizeOf(TRect));
  aCanvas.Pen.Color := clBlack;
  aCanvas.Rectangle(rct);
  rct.Left := rct.Left + 1;
  rct.Top := rct.Top + 1;
  rct.Right := rct.Right - 1;
  rct.Bottom := rct.Bottom - 1;
  aCanvas.Pen.Color := LightColor(aBaseColor, Lighter * 3);
  aCanvas.Rectangle(rct);
end;

procedure VistaButtonRound(aCanvas: TCanvas; aRect: TRect; aBaseColor: TColor; aUp: boolean = true);
var
  qrt: integer;
  rct: TRect;
  clrL: TColor;
const
  Lighter = 60;
begin
  qrt := Round((aRect.Bottom - aRect.Top)/ 4);
  clrL := LightColor(aBaseColor, Lighter);
  if aUp then
  begin
    aCanvas.Brush.Color := clrL;
    aCanvas.FillRect(aRect);
    DrawGradient(aCanvas, Bounds(aRect.Left, aRect.Bottom - qrt * 2,
      aRect.Right - aRect.Left, qrt * 2), false,[aBaseColor, clrL]);
  end
  else
  begin
    aCanvas.Brush.Color := aBaseColor;
    aCanvas.FillRect(aRect);
    DrawGradient(aCanvas, Bounds(aRect.Left, aRect.Bottom - qrt * 2,
      aRect.Right - aRect.Left, qrt * 2), false,[clrL, aBaseColor]);
  end;
  aCanvas.Brush.Style := bsClear;
  System.Move(aRect, rct, SizeOf(TRect));
  aCanvas.Pen.Color := clBlack;
  aCanvas.RoundRect(rct,2,2);
  rct.Left := rct.Left + 1;
  rct.Top := rct.Top + 1;
  rct.Right := rct.Right - 1;
  rct.Bottom := rct.Bottom - 1;
  aCanvas.Pen.Color := LightColor(aBaseColor, Lighter * 3);
  aCanvas.RoundRect(rct,2,2);
end;

procedure VistaButton(aDC: hDC; aRect: TRect; aBaseColor: TColor;
  aUp: boolean = true);
var
  brD, brL, brC: hBrush;
  LB: TLogBrush;
  obr: hBrush;
  pnB, pnW: hPen;
  opn: hPen;
  qrt: integer;
  rct: TRect;
  clrL: TColor;
const
  Lighter = 60;
begin
  clrL := LightColor(aBaseColor, Lighter);
  brD := CreateSolidBrush(ColorToRGB(aBaseColor));
  brL := CreateSolidBrush(ColorToRGB(clrL));
  LB.lbStyle := BS_NULL;
  brC := CreateBrushIndirect(LB);
  obr := SelectObject(aDC, brC);
  pnB := CreatePen(PS_SOLID, 1, ColorToRGB(clBlack));
  pnW := CreatePen(PS_SOLID, 1, ColorToRGB(clWhite));
  opn := SelectObject(aDC, pnB);
  try
    qrt := Round((aRect.Bottom - aRect.Top)/ 4);
    if aUp then
    begin
      FillRect(aDC, aRect, brL);
      //DrawGradient(aDC,Bounds(aRect.Left,0,aRect.Right-aRect.Left,qrt*2-1),false,[clWhite,clrL]);
      DrawGradient(aDC, Bounds(aRect.Left, aRect.Bottom - qrt * 2,
        aRect.Right - aRect.Left, qrt * 2), false,[aBaseColor, clrL]);
    end
    else
    begin
      FillRect(aDC, aRect, brD);
      DrawGradient(aDC, Bounds(aRect.Left, aRect.Bottom - qrt * 2,
        aRect.Right - aRect.Left, qrt * 2), false,[clrL, aBaseColor]);
    end;
    System.Move(aRect, rct, SizeOf(TRect));
    Rectangle(aDC, rct.Left, rct.Top, rct.Right, rct.Bottom);
    rct.Left := rct.Left + 1;
    rct.Top := rct.Top + 1;
    rct.Right := rct.Right - 1;
    rct.Bottom := rct.Bottom - 1;
    DeleteObject(SelectObject(aDC, pnW));
    Rectangle(aDC, rct.Left, rct.Top, rct.Right, rct.Bottom);
  finally
    DeleteObject(SelectObject(aDC, obr));
    DeleteObject(brL);
    DeleteObject(brD);
    DeleteObject(SelectObject(aDC, opn));
  end;
end;

procedure VistaButtonRound(aDC: hDC; aRect: TRect; aBaseColor: TColor; aUp: boolean = true);
var
  brD, brL, brC: hBrush;
  LB: TLogBrush;
  obr: hBrush;
  pnB, pnW: hPen;
  opn: hPen;
  qrt: integer;
  rct: TRect;
  clrL: TColor;
const
  Lighter = 20;
begin
  qrt := Round((aRect.Bottom - aRect.Top)/ 4);
  clrL := LightColor(aBaseColor, Lighter);
  brD := CreateSolidBrush(ColorToRGB(aBaseColor));
  brL := CreateSolidBrush(ColorToRGB(clrL));
  LB.lbStyle := BS_NULL;
  brC := CreateBrushIndirect(LB);
  obr := SelectObject(aDC, brC);
  pnB := CreatePen(PS_SOLID, 1, ColorToRGB(clBlack));
  pnW := CreatePen(PS_SOLID, 1, ColorToRGB(LightColor(aBaseColor,40)));
  opn := SelectObject(aDC, pnB);
  try
  if aUp then
  begin
    brL := CreateSolidBrush(ColorToRGB(LightColor(aBaseColor, Lighter)));
    FillRect(aDC, aRect, brL);
    clrL := LightColor(aBaseColor, Byte(Round(Lighter*1.5)));
    DrawGradient(aDC, Bounds(aRect.Left, aRect.Bottom - qrt * 2 - 1,
      aRect.Right - aRect.Left, qrt * 2), false,[aBaseColor, clrL]);
  end
  else
  begin
    FillRect(aDC, aRect, brD);
    DrawGradient(aDC, Bounds(aRect.Left, aRect.Bottom - qrt * 2,
      aRect.Right - aRect.Left, qrt * 2), false,[clrL, aBaseColor]);
  end;
    System.Move(aRect, rct, SizeOf(TRect));
    RoundRect(aDC, rct.Left, rct.Top, rct.Right, rct.Bottom,2,2);
    rct.Left := rct.Left + 1;
    rct.Top := rct.Top + 1;
    rct.Right := rct.Right - 1;
    rct.Bottom := rct.Bottom - 1;
    DeleteObject(SelectObject(aDC, pnW));
    RoundRect(aDC, rct.Left, rct.Top, rct.Right, rct.Bottom,2,2);
  finally
    DeleteObject(SelectObject(aDC, obr));
    DeleteObject(brL);
    DeleteObject(brD);
    DeleteObject(SelectObject(aDC, opn));
  end;
end;


procedure VistaButtonRoundCaption(wnd: hWnd; aRect: TRect; aBaseColor: TColor; aOver : boolean; aUp: boolean = true);
const
  clOutBorder3Dbtn = TColor($00886F5D);
  clInBorder3Dbtn = TColor($00F2E7DE);
// в покое (not pressed & not over) цвет зависит от цветов Caption
// а иначе вот эти цвета
// -- over --
  clLightOver3Dbtn =  TColor($00EFCB96);
  clDarkOverTop3Dbtn =  TColor($00A3732D);
  clDarkOverBottom3Dbtn = TColor($00EBC624);//    clDarkOverBottom3DbtnL = TColor($00F9EF85); // -- это светлый самый , по внутренней рамке
// -- pressed --
  clLightOver3DbtnDown =  TColor($00A59378);
  clDarkOverTop3DbtnDown =  TColor($00523B20);
  clDarkOverBottom3DbtnDown = TColor($00C8C927);

var
  dc : hDC ;
  brD, brL, brC: hBrush;
  LB: TLogBrush;
  pnB, pnW: hPen;
  qrt: integer;
  rct: TRect;
  clrL: TColor;
const
  Lighter = 20;
begin
dc:=GetWindowDC(wnd);
qrt := Round((aRect.Bottom - aRect.Top)/ 4);
//clrL := LightColor(aBaseColor, Lighter);
brD := CreateSolidBrush(ColorToRGB(aBaseColor));
LB.lbStyle := BS_NULL;
brC := CreateBrushIndirect(LB);
pnB := CreatePen(PS_SOLID, 1, ColorToRGB(clOutBorder3Dbtn));//clBlack
pnW := CreatePen(PS_SOLID, 1, ColorToRGB(LightColor(aBaseColor,40)));
try
SelectObject(dc, brC);
SelectObject(dc, pnB);
if aUp
   then begin
   if not aOver
      then begin
      brL := CreateSolidBrush(ColorToRGB(LightColor(aBaseColor, Lighter)));
      try
      FillRect(dc, aRect, brL);
      finally
      DeleteObject(brL);
      end;
      clrL := LightColor(aBaseColor, Byte(Round(Lighter*1.5)));
      DrawGradient(dc, Bounds(aRect.Left, aRect.Bottom - qrt * 2 - 1, aRect.Right - aRect.Left, qrt * 2), false,[aBaseColor, clrL]);
      end
      else begin
      brL := CreateSolidBrush(ColorToRGB(clLightOver3Dbtn));
      try
      FillRect(dc, aRect, brL);
      finally
      DeleteObject(brL);
      end;
      DrawGradient(dc, Bounds(aRect.Left, aRect.Bottom - qrt * 2 - 1, aRect.Right - aRect.Left, qrt * 2), false,[clDarkOverTop3Dbtn, clDarkOverBottom3Dbtn]);
      end;
  end
  else begin
  brL := CreateSolidBrush(ColorToRGB(clLightOver3DbtnDown));
  try
  FillRect(dc, aRect, brL);
  finally
  DeleteObject(brL);
  end;
  DrawGradient(dc, Bounds(aRect.Left, aRect.Bottom - qrt * 2 - 1, aRect.Right - aRect.Left, qrt * 2), false,[clDarkOverTop3DbtnDown, clDarkOverBottom3DbtnDown]);
  end;
System.Move(aRect, rct, SizeOf(TRect));
RoundRect(dc, rct.Left, rct.Top, rct.Right, rct.Bottom,2,2);
rct.Left := rct.Left + 1;
rct.Top := rct.Top + 1;
rct.Right := rct.Right - 1;
rct.Bottom := rct.Bottom - 1;
DeleteObject(SelectObject(dc, pnW));
RoundRect(dc, rct.Left, rct.Top, rct.Right, rct.Bottom,2,2);
finally
ReleaseDC(wnd, dc);
DeleteObject(brD);
DeleteObject(brC);
DeleteObject(pnB);//clBlack
DeleteObject(pnW);
end;
end;


function ThemeIsAero : boolean;
const
 chars : integer = 255;
var
 fn,cn,sn : PChar;
begin
fn:=AllocMem(chars*SizeOfChar+1);
cn:=AllocMem(chars*SizeOfChar+1);
sn:=AllocMem(chars*SizeOfChar+1);
try
GetCurrentThemeName(fn,chars,cn,chars,sn,chars);
Result:=(fn<>'') and (AnsiPos('aero', AnsiLowerCase(StrPas(fn)))<>0);
finally
FreeMem(sn);
FreeMem(cn);
FreeMem(fn);
end;


end;

function HTMLRGBtoColor(const aClrStr6 : shortstring) : TColor;
  function GetByte(const aStr : string; aSt : integer) : byte;
  begin
  Result:=byte(StrToInt('$'+Copy(aStr,aSt,2)));
  end;
var
 tmp : string;
begin
tmp:=Copy(string(aClrStr6+'FFFFFF'),1,6);
Result:=TColor(RGB(GetByte(tmp,1),GetByte(tmp,3),GetByte(tmp,5)));
end;

function HTMLRGBtoColor(const aClrStr6 : string) : TColor; inline;
begin
Result:=HTMLRGBtoColor(shortstring(aClrStr6));
end;

function ColorToHTMLColor(aColor : TColor) : string;
var
 clr : TColorRef;
begin
clr:=ColorToRGB(aColor);
Result:=IntToHex(GetRValue(clr),2)+IntToHex(GetGValue(clr),2)+IntToHex(GetBValue(clr),2);
Result:=UpperCase(Result);
end;

function ColorToRGBString(aColor : TColor) : string;
begin
Result:=ColorToHTMLColor(aColor);
end;






(*Список доступных MSSQL серверов*)
function GetListOfMSSQLServers(var aListOfServers: TStringList): integer;
var
  dmo: OleVariant;
  //dso : OleVariant;
  i: integer;
  tmp:string;
begin
  Result := 0;
  if not Assigned(aListOfServers)then
    Exit;
  try
    try
      dmo := CreateOleObject('SQLDMO.SQLServer');
      dmo := dmo.Application;
      dmo := dmo.ListAvailableSQLServers;
      if dmo.Count > 1 then
      begin
        aListOfServers.Add(tmp);
        for i := 1 to dmo.Count do
        begin
          aListOfServers.Add(AnsiUpperCase(dmo.Item(i)));
        end;
      end;

      //-- или так...
      //dso:=CreateOleObject('SQLDMO.Application');
      //aListOfServers.Add('---------------'+IntToStr(dso.SQLServers.Count)+'---------------');
      //dso:=dso.ListAvailableSQLServers;
      //if dso.Count > 1
      //then begin
      //for i:= 1 to dso.Count
      //do begin
      //aListOfServers.Add(AnsiUpperCase(dso.Item(i)));
      //end;
      //end;

      Result := aListOfServers.Count;
    except
      on E: Exception do
        CreateErrorMessage('GetListOfMSSQLServers', E,[], tmp);
    end;
  finally
    dmo := Unassigned;
    //dso:=Unassigned;
  end;
end;

(*Сортировки (Содрано из Demos\Threads)*)
procedure BubbleSort(var A: array of integer);
var
  i, j, t: integer;
begin
  for i := High(A)downto Low(A)do
    for j := Low(A)to High(A)- 1 do
      if A[j]> A[j + 1]then
      begin
        t := A[j];
        A[j]:= A[j + 1];
        A[j + 1]:= t;
      end;
end;

procedure BubbleSort(var A: array of Real);
var
  i, j: integer;
  t: Real;
begin
  for i := High(A)downto Low(A)do
    for j := Low(A)to High(A)- 1 do
      if A[j]> A[j + 1]then
      begin
        t := A[j];
        A[j]:= A[j + 1];
        A[j + 1]:= t;
      end;
end;

procedure SelectionSort(var A: array of integer);
var
  i, j, t: integer;
begin
  for i := Low(A)to High(A)- 1 do
    for j := High(A)downto i + 1 do
      if A[i]> A[j]then
      begin
        t := A[i];
        A[i]:= A[j];
        A[j]:= t;
      end;
end;

procedure SelectionSort(var A: array of Real);
var
  i, j: integer;
  t: Real;
begin
  for i := Low(A)to High(A)- 1 do
    for j := High(A)downto i + 1 do
      if A[i]> A[j]then
      begin
        t := A[i];
        A[i]:= A[j];
        A[j]:= t;
      end;
end;

procedure QuickSort(var A: array of integer);
  procedure _QuickSort(var A: array of integer; iLo, iHi: integer);
  var
    Lo, Hi, Mid, t: integer;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi)div 2];
    repeat
      while A[Lo]< Mid do
        Inc(Lo);
      while A[Hi]> Mid do
        Dec(Hi);
      if Lo <= Hi then
      begin
        t := A[Lo];
        A[Lo]:= A[Hi];
        A[Hi]:= t;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then
      _QuickSort(A, iLo, Hi);
    if Lo < iHi then
      _QuickSort(A, Lo, iHi);
  end;

begin
  if Length(A)> 0 then
    _QuickSort(A, Low(A), High(A));
end;

procedure QuickSort(var A: array of Real);
  procedure _QuickSort(var A: array of Real; iLo, iHi: integer);
  var
    Lo, Hi: integer;
    Mid, t: Real;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi)div 2];
    repeat
      while A[Lo]< Mid do
        Inc(Lo);
      while A[Hi]> Mid do
        Dec(Hi);
      if Lo <= Hi then
      begin
        t := A[Lo];
        A[Lo]:= A[Hi];
        A[Hi]:= t;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then
      _QuickSort(A, iLo, Hi);
    if Lo < iHi then
      _QuickSort(A, Lo, iHi);
  end;

begin
  if Length(A)> 0 then
    _QuickSort(A, Low(A), High(A));
end;

procedure QuickSort(var A: array of Word);
  procedure _QuickSort(var A: array of Word; iLo, iHi: integer);
  var
    Lo, Hi: integer;
    Mid, t: Word;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi)div 2];
    repeat
      while A[Lo]< Mid do
        Inc(Lo);
      while A[Hi]> Mid do
        Dec(Hi);
      if Lo <= Hi then
      begin
        t := A[Lo];
        A[Lo]:= A[Hi];
        A[Hi]:= t;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then
      _QuickSort(A, iLo, Hi);
    if Lo < iHi then
      _QuickSort(A, Lo, iHi);
  end;

begin
  if Length(A)> 0 then
    _QuickSort(A, Low(A), High(A));
end;

procedure QuickSort(var A: array of DWord);
  procedure _QuickSort(var A: array of DWord; iLo, iHi: integer);
  var
    Lo, Hi: integer;
    Mid, t: Word;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi)div 2];
    repeat
      while A[Lo]< Mid do
        Inc(Lo);
      while A[Hi]> Mid do
        Dec(Hi);
      if Lo <= Hi then
      begin
        t := A[Lo];
        A[Lo]:= A[Hi];
        A[Hi]:= t;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then
      _QuickSort(A, iLo, Hi);
    if Lo < iHi then
      _QuickSort(A, Lo, iHi);
  end;

begin
  if Length(A)> 0 then
    _QuickSort(A, Low(A), High(A));
end;


function CheckExistsForm(aFormClass: TClass): boolean;
var
  cnt: integer;
begin
  for cnt := Application.ComponentCount - 1 downto 0 do
    if Application.Components[cnt].InheritsFrom(aFormClass)then
    begin
      Result := true;
      Exit;
    end;
  Result := false;
end;



(* Сортировка точек по кругу                                                  *)
(* aPoints      - input/output массив точек*)
(* CentralPoint - output центральная вычисленная точка*)
procedure SortPointsByCircle(var aPoints : TPointDynArray; var CentralPoint : TPoint);//; CloseLine : boolean = True);
// Максимальная точка (True - по X , False - по Y);
function MaxPoint(A,B : TPoint;CheckX : boolean): TPoint;
begin
if CheckX
  then if A.x>B.X then Result:=A
                  else Result:=B
  else if A.Y>B.Y then Result:=A
                  else Result:=B
end;

// Минимальная точка (True - по X , False - по Y);
function MinPoint(A,B : TPoint;CheckX : boolean): TPoint;
begin
if CheckX
  then if A.x<B.X then Result:=A
                   else Result:=B
  else if A.Y<B.Y then Result:=A
                   else Result:=B
end;


// Упорядочивание массива Tpoint относительно центральной точки
procedure SetRangeArr(var ap : TPointDynArray);
  function GetAngle(A,C : TPoint):extended;
  const
    RtD = 180 / PI;
  begin
  if C.x=A.x
  then Result:=999999999//A.x:=A.x+1;
  else Result:=RtD*(ArcTan((C.y-A.y) / (C.x-A.x)));
  end;
var
 p     : TPoint;
 i,j,h : integer;
begin
h:=Length(ap);
 for i:=0 to h-2
   do begin
     for j:=i to h-1
     do begin
      if GetAngle(ap[i],CentralPoint)<GetAngle(ap[j],CentralPoint)
         then begin
         p:=ap[i];
         ap[i]:=ap[j];
         ap[j]:=p;
         end;
     end;
   end;
end;

var
 pt               : integer;         // кол-во точек
 ap               : TPointDynArray;       // местный
 i,s,lt,lb        : integer;         //
 BX, BY           : array[0..1] of TPoint;
 apTop,apBottom   : TPointDynArray;       // верхний и нижний массивы точек (относительно средней, см. CentralPoint)
 x,y              : integer;
const
 sz = SizeOf(TPoint);
begin
pt:=Length(aPoints);
SetLength(ap,pt);
try
// 1-ый этап : Получение граничных точек и вычисление центра
BX[0]:=aPoints[0];
BX[1]:=aPoints[0];
BY[0]:=aPoints[0];
BY[1]:=aPoints[0];
for i:=1 to pt-1 do BX[0]:=MinPoint(aPoints[i],BX[0],True);
for i:=1 to pt-1 do BX[1]:=MaxPoint(aPoints[i],BX[1],True);
for i:=1 to pt-1 do BY[0]:=MinPoint(aPoints[i],BY[0],False);
for i:=1 to pt-1 do BY[1]:=MaxPoint(aPoints[i],BY[1],False);
x:=Round(BX[0].X + (BX[1].X-BX[0].X) / 2);
y:=Round(BY[0].Y + (BY[1].Y-BY[0].Y) / 2);
CentralPoint:=Point(x,y);
// 2-ой этап : Разделение базового массива на два относительно горизонтального центра
lt:=0;lb:=0;
SetLength(apTop,lt);
SetLength(apBottom,lb);
for i:=0 to pt-1
do begin
if aPoints[i].x<CentralPoint.x
   then begin
   inc(lt);
   SetLength(apTop,lt);
   apTop[lt-1]:=aPoints[i];
   end
   else if aPoints[i].x=CentralPoint.x
           then begin
           if aPoints[i].y<CentralPoint.y
              then begin
              inc(lt);
              SetLength(apTop,lt);
              apTop[lt-1]:=aPoints[i];
              end
              else begin
              inc(lb);
              SetLength(apBottom,lb);
              apBottom[lb-1]:=aPoints[i];
              end;
           end
           else begin
           inc(lb);
           SetLength(apBottom,lb);
           apBottom[lb-1]:=aPoints[i];
           end;
end;
// 3-ой этап : Упорядочивание "верхнего" и "нижнего" массива по порядку следования точек
SetRangeArr(apTop);
SetRangeArr(apBottom);
// 4-ый этап : "Склеивание" массивов
lt:=Length(apTop);
s:=0;
for i:=0 to lt-1
  do begin
  ap[s]:=apTop[i];
  inc(s);
  end;
lb:=Length(apBottom);
 for i:=0 to lb-1
   do begin
   ap[s]:=apBottom[i];
   inc(s);
   end;
// 5-ый этап : Добавление заключительной (завершающей точки)
//if CloseLine
//   then begin
//   s:=Length(ap);
//   SetLength(ap,s+1);
//   ap[s]:=ap[0];
//   end;
//if pt<Length(ap) then SetLength(aPoints,Length(ap));
System.Move(ap[0],aPoints[0],Length(aPoints)*sz);
finally
SetLength(ap,0);
SetLength(apTop,0);
SetLength(apBottom,0);
end;
end;


procedure SortPointsByCircle2(var aPoints : array of TPoint; var CentralPoint : TPoint);
var
 arr : TPointDynArray;
begin
SetLength(arr,Length(aPoints));
try
System.Move(aPoints[0],arr[0],SizeOf(TPoint)*Length(aPoints));
SortPointsByCircle(arr,CentralPoint);
System.Move(arr[0],aPoints[0],SizeOf(TPoint)*Length(aPoints));
finally
Setlength(arr,0);
end;
end;




(******************** FUNCTION WITHOUT INTERFACE PARTS ************************)

initialization InitProc;
finalization FinalProc;


end.


(**************************************************************************************************)
(*                           ПРИМЕРЫ  И  ШАБЛОНЫ                                                  *)
(**************************************************************************************************)


(* ~~~~~~~ Удаление элемента из массива по индексу ~~~~~~~~~~~~~~~~~~~~~~~~~~ *)
//if (Index<High(RecordList))
//     then System.Move(RecordList[Index+1],RecordList[Index],(High(RecordList)-Index) * SizeOf(TRecord));
//SetLength(RecordList,Length(RecordList)-1);

(**************************************************************************************************)
// * проверка валидности TEdit (CheckEdit, CheckValidEdit, OnChange)
//procedure TForm1.Edit1Change(Sender: TObject);
//var
// ss   : integer;
// sl   : integer;
// nt   : TNotifyEvent;
//begin
//if not (Sender is TEdit) then Exit;
//nt:=(Sender as TEdit).OnChange;
//(Sender as TEdit).OnChange:=nil;
//ss:=(Sender as TEdit).SelStart;
//sl:=(Sender as TEdit).SelLength;
//try
//if ((Sender as TEdit).Text<>'') and not CheckValidInteger((Sender as TEdit).Text,true)
//   then begin
//   SendMessage((Sender as TEdit).Handle,EM_UNDO,0,0);
//   _sleep(1);
//   SendMessage((Sender as TEdit).Handle, EM_EMPTYUNDOBUFFER, 0, 0);
//   _sleep(1);
//   end;
//finally
//(Sender as TEdit).OnChange:=nt;
//(Sender as TEdit).SelStart:=ss;
//(Sender as TEdit).SelLength:=sl;
//end;
//end;


(**************************************************************************************************)

//procedure EditFloatChange(Sender : TObject);
// function ClearDS(const str : string) : string;
// var
//  sda : TStringDynArray;
//  cnt : integer;
// begin
// Result:=str;
// sda:=SplitString(str,FormatSettings.DecimalSeparator);
// if Length(sda)<=2
//    then Exit
//    else begin
//    Result:='';
//    for cnt:=1 to High(sda)
//      do Result:=Result+sda[cnt];
//    Result:=sda[0]+FormatSettings.DecimalSeparator+Result;
//    end;
// end;
//var
// ed   : TEdit;
// ss   : integer;
// sl   : integer;
// nt   : TNotifyEvent;
// neg  : boolean;
// str  : string;
//begin
//try
//if not (Sender is TEdit) then Exit;
//ed:=(Sender as TEdit);
//   if Trim(ed.text)='-' then Exit;
//   neg:=Pos('-', ed.text)<>0;
//   str:=StringReplace(Trim(ed.text),'-','',[rfReplaceAll]);
//   str:=ClearDS(TransStrR(str, '.,\|/:;',FormatSettings.DecimalSeparator));
//   if CheckValidFloat(str)
//      then begin
//      nt:=ed.OnChange;
//      sl:=ed.SelLength;
//      ss:=ed.SelStart;
//      try
//      ed.OnChange:=nil;
//      if neg
//         then ed.Text:='-'+str
//         else ed.Text:=str
//      finally
//      ed.OnChange:=nt;
//      ed.SelStart :=ss;
//      ed.SelLength:=sl;
//      end;
//      ed.Color:=clWindow;
//      end
//      else begin
//      ed.Color:=clPaleRed;
//      SendMessage(ed.Handle,EM_UNDO,0,0);
//      _sleep(1);
//      SendMessage(ed.Handle, EM_EMPTYUNDOBUFFER, 0, 0);
//      _sleep(1);
//      end;
//except
// on E : Exception do LogErrorMessage(Format('%s(%s)',[AOS(Sender),GMN(Sender)]),E,[]);
//end;
//end ;

(****************************************)
(*
type
 TDialogText = record
   mainWnd : cardinal;
   wnd     : cardinal;
   timer   : cardinal;
   oldText : string[128];
   newText : string[128];
   counter : integer;
 end;
var
 dt : TDialogText;


  procedure CaptionChanger(wnd : hWnd; uMsg : UINT; idEvent : UINT_PTR; dwTime : DWORD); stdcall;
  begin
  dt.wnd:=GetForegroundWindow;
  if GetWindowClassName(dt.wnd)<>'#32770'
     then dt.wnd:=0;
  //FindWindow(, PChar(string(dt.oldText)));
  if dt.wnd<>0
     then begin
     SetWindowText(wnd,PChar(string(dt.newText)));
     dt.counter:=0;
     end;
  if dt.counter<=0
     then begin
     KillTimer(dt.mainWnd, dt.timer);
     Exit;
     end
     else dec(dt.counter);
  end;

  procedure ChangeCaptionDialog(const aOldText, aNewText : string; aTimerID : cardinal);
  begin
  dt.mainWnd:=Main_Window;
  dt.wnd:=0;
  if aTimerID=0
     then dt.timer:=WM_TIMER
     else dt.timer:=aTimerID;
  dt.oldText:=shortstring(aOldText);
  dt.newText:=shortstring(aNewText);
  dt.counter:=100;
  SetTimer(dt.mainWnd,dt.timer,50,@CaptionChanger);
  end;
*)
(****************************************)
(*
procedure ShowBalloonTip(Control: TWinControl; Icon: integer; Title: pchar; Text: PWideChar; BackCL, TextCL: TColor);
const
  TOOLTIPS_CLASS = 'tooltips_class32';
  TTS_ALWAYSTIP = $01;
  TTS_NOPREFIX = $02;
  TTS_BALLOON = $40;
  TTF_SUBCLASS = $0010;
  TTF_TRANSPARENT = $0100;
  TTF_CENTERTIP = $0002;
  TTM_ADDTOOL = $0400 + 50;
  TTM_SETTITLE = (WM_USER + 32);
  ICC_WIN95_CLASSES = $000000FF;
  TTM_SETTIPBKCOLOR = $000000FF;
  TTM_SETTIPTEXTCOLOR =$000000FF;
type
  TOOLINFO = packed record
    cbSize: Integer;
    uFlags: Integer;
    hwnd: THandle;
    uId: Integer;
    rect: TRect;
    hinst: THandle;
    lpszText: PWideChar;
    lParam: Integer;
  end;
var
  hWndTip: THandle;
  ti: TOOLINFO;
  hWnd: THandle;
begin
  hWnd    := Control.Handle;
  hWndTip := CreateWindow(TOOLTIPS_CLASS, nil, WS_POPUP or TTS_NOPREFIX or TTS_BALLOON or TTS_ALWAYSTIP, 0, 0, 0, 0, hWnd, 0, HInstance, nil);
  if hWndTip <> 0 then
    begin
    SetWindowPos(hWndTip, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
    ti.cbSize := SizeOf(ti);
    ti.uFlags := TTF_CENTERTIP or TTF_TRANSPARENT or TTF_SUBCLASS;
    ti.hwnd := hWnd;
    ti.lpszText := Text;
      Windows.GetClientRect(hWnd, ti.rect);
      SendMessage(hWndTip, TTM_SETTIPBKCOLOR, BackCL, 0);
      SendMessage(hWndTip, TTM_SETTIPTEXTCOLOR, TextCL, 0);
      SendMessage(hWndTip, TTM_ADDTOOL, 1, Integer(@ti));
      SendMessage(hWndTip, TTM_SETTITLE, Icon mod 4, Integer(Title));
    end;
end;
*)


(*
TForm.BorderStyle:=bsNone;
procedure TForm.CreateParams(var Params: TCreateParams);
begin
inherited CreateParams(Params);
with Params do Style := Style and not WS_CAPTION and not WS_SYSMENU or WS_SIZEBOX;// or WS_CLIPCHILDREN;
end;
*)

(* TDrawGrid.onDrawCell отображение поиска

const
 ...
 BS : array[boolean] of TColor = (clAqua, clAqua);
 FS : array[boolean] of TColor = (clWindowText, clNavy);
 ...

var
 sel  : boolean;
 rct  : TRect;
 str  : string;
 alg  : integer;
 ind  : integer;
 psS  : integer;
 rctS : TRect;
 strS : string;
 lft  : integer;
 ...

begin

with DrawGrid.Canvas
  do begin
  ......
  // -- text and find draw block -------------------------------
   SetBkMode(Handle, TRANSPARENT);
   DrawText(Handle, str, Length(str), rct, alg);
   SetBkMode(Handle, OPAQUE);

  // -- display block of results of searching : begin -----------------
  str:=StringReplace(str,'&&','&',[rfReplaceAll]);
  psS:=AnsiPos(AnsiUpperCase(Ed_SimpleSearch.Text),AnsiUpperCase(str));
  strS:=Copy(str,psS,Length(Ed_SimpleSearch.Text));
  if (ARow>0) and (Ed_SimpleSearch.Text<>'') and (psS>0)
     then begin
     case alg of  // -- calculation of rectangle for display of the search phrase
     DT_RIGHT_ALIGN:
        begin
        lft:=rct.Right-TextWidth(str)-2;
        rctS.Left:=rct.Left+TextWidth(Copy(str,1,psS-1))+lft;
        rctS.Right:=rctS.Left+TextWidth(strS);
        rctS.Top:=Rect.Top;
        rctS.Bottom:=Rect.Bottom;
        alg:=DT_LEFT_ALIGN;
        end;
     DT_CENTER_ALIGN:
        begin
        rct:=Bounds(0,0,0,1);
        alg:=DT_LEFT_CALC;
        DrawText(Handle,str,Length(str),rct,alg);
        rct.Bottom:=Rect.Bottom-Rect.Top;
        OffsetRect(rct,Rect.Left+((Rect.Right-Rect.Left) - (rct.Right-rct.Left))div 2, Rect.Top);
        System.Move(rct,rctS,SizeOf(TRect));
        OffsetRect(rctS,TextWidth(Copy(str,1,psS-1)),0);
        rctS.Right:=rctS.Left+TextWidth(strS);
        alg:=DT_LEFT_ALIGN;
        end;
     else begin
     rctS.Left:=rct.Left+TextWidth(Copy(str,1,psS-1));
     rctS.Right:=rctS.Left+TextWidth(strS);
     rctS.Top:=Rect.Top;
     rctS.Bottom:=Rect.Bottom;
     end
     end;
     if (rctS.Right>0) and (rctS.Left>0)
        then begin
        // -- типа FireFox --
        //   Brush.Color:=BS[sel];
        //   Font.Color:=FS[sel];
        //   Windows.FillRect(Handle,rctS,Brush.Handle);
        //   SetBkMode(Handle,TRANSPARENT);
        //   DrawText(Handle,strS,Length(strS),rctS,alg);
        //   SetBkMode(Handle,OPAQUE);
        if alg<>0 then ; // -- затычка для комментренного фрагмента
        Pen.Color:=InvertColor(ColorToRGB(Brush.Color));
        Brush.Style:=bsClear;
        Rectangle(rctS.Left,rctS.Top,rctS.Right,rctS.Bottom);
        end;
     end
   // -- display block of results of searching : end -----------------
  ......
  end;
end;

*)
