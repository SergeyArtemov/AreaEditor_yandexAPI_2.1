select 
  CallId
 ,op_id as ccOper
 ,[User] as ccUser
 ,CallLine
 ,CallType
 ,StartCall
 ,StartTalk
 ,EndCall

from CallOCall_Log_Call(nolock) CLC
--left join cc_Ref_Outline ROL on ROL.Line = CLC.CallLine 
where 1=1
   and CAST(Startcall as date) = '20161122'
   and [User]		= 542
   and CallLine		= '84952258343'
   and CallResult	= 1
   and '20161122 11:44:48.420' between DATEADD(MINUTE,-5,Startcall) and DATEADD(MINUTE,5,Startcall)
   --and DATEADD(MINUTE,-10,Startcall)<='20161122 11:44:48.420'
   --and DATEADD(MINUTE,10,Startcall)>='20161122 11:44:48.420'

   




