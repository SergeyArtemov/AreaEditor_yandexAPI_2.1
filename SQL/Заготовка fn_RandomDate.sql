
declare @mindate date = '20130701'
declare @maxdate date = cast(dateadd(dd,-1,getdate()) as date)
declare @tmpdate datetime = null 
select @tmpdate=rd from [dbo].[vfn_RandomDate]
declare @y int = 0
declare @m int = 0
declare @d int = 0
if @tmpdate<@mindate
   begin 
   --set @y = datepart(yy,@tmpdate)
   set @tmpdate = dateadd(yy,Abs(datepart(yy,@mindate)-datepart(yy,@tmpdate)/*@y*/),@tmpdate)
   if @tmpdate<@mindate
      begin 
      --set @m = datepart(mm,@tmpdate)
      set @tmpdate = dateadd(mm,abs(datepart(mm,@mindate)-datepart(mm,@tmpdate)/*@m*/),@tmpdate)
      end
   if @tmpdate<@mindate
      begin 
      --set @d = datepart(dd,@tmpdate)
      set @tmpdate = dateadd(dd,abs(datepart(dd,@mindate)-datepart(dd,@tmpdate)/*@d*/),@tmpdate)
      end
   end
   else
if @tmpdate>@maxdate
   begin 
   --set @y = datepart(yy,@tmpdate)  
   set @tmpdate = dateadd(yy,datepart(yy,@maxdate)-datepart(yy,@tmpdate)/*@y*/,@tmpdate)
   if @tmpdate>@maxdate
      begin 
      --set @m = datepart(mm,@tmpdate)
      set @tmpdate = dateadd(mm,datepart(mm,@maxdate)- datepart(mm,@tmpdate)/*@m*/,@tmpdate)
      end
  if @tmpdate>@maxdate
     begin 
     --set @d = datepart(dd,@tmpdate)
     set @tmpdate = dateadd(dd,datepart(dd,@maxdate)-datepart(dd,@tmpdate)/*@d*/,@tmpdate)
     end
  end
select @mindate, @tmpdate, @maxDate