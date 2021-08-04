declare @xmltext varchar(max)='<DATA USER="S.KHOLIN" WORKSTATION="KUPIVIP00000">
<I uiID="0" uiDOMAINNAME="a.taranenko" uiNORMALNAME="Тараненко Анна" uiMO2_USERID="0" uiACTIVE="255"/>
<I uiID="0" uiDOMAINNAME="d.barabanova" uiNORMALNAME="Барабанова Дарья" uiMO2_USERID="0" uiACTIVE="255"/>
<I uiID="0" uiDOMAINNAME="d.sobitnyak" uiNORMALNAME="Караева Дарья" uiMO2_USERID="0" uiACTIVE="255"/>
<I uiID="0" uiDOMAINNAME="el.sharapova" uiNORMALNAME="Шарапова Елена" uiMO2_USERID="0" uiACTIVE="255"/>
<I uiID="0" uiDOMAINNAME="el.tarasova" uiNORMALNAME="Тарасова Елена" uiMO2_USERID="0" uiACTIVE="255"/>
<I uiID="0" uiDOMAINNAME="f.nazaralieva" uiNORMALNAME="Назаралиева Фатима" uiMO2_USERID="0" uiACTIVE="255"/>
<I uiID="0" uiDOMAINNAME="j.varakina" uiNORMALNAME="Варакина Юлия" uiMO2_USERID="0" uiACTIVE="255"/>
<I uiID="0" uiDOMAINNAME="l.tarasov" uiNORMALNAME="Тарасов Леонид" uiMO2_USERID="0" uiACTIVE="255"/>
<I uiID="0" uiDOMAINNAME="m.tarakanova" uiNORMALNAME="Тараканова Марина" uiMO2_USERID="0" uiACTIVE="255"/>
<I uiID="0" uiDOMAINNAME="m.tarasova" uiNORMALNAME="Тарасова Марина" uiMO2_USERID="0" uiACTIVE="255"/>
<I uiID="0" uiDOMAINNAME="m.uraev" uiNORMALNAME="Ураев Марат" uiMO2_USERID="0" uiACTIVE="255"/>
<I uiID="0" uiDOMAINNAME="n.tarasova" uiNORMALNAME="Тарасова Надежда" uiMO2_USERID="0" uiACTIVE="255"/>
<I uiID="0" uiDOMAINNAME="s.aparatu" uiNORMALNAME="Апарату Сабина" uiMO2_USERID="0" uiACTIVE="255"/>
<I uiID="0" uiDOMAINNAME="s.tarasova" uiNORMALNAME="Тарасова Светлана" uiMO2_USERID="0" uiACTIVE="255"/>
<I uiID="0" uiDOMAINNAME="t.gasparyan" uiNORMALNAME="Гаспарян Тамара" uiMO2_USERID="0" uiACTIVE="255"/>
<I uiID="0" uiDOMAINNAME="t.jilkina" uiNORMALNAME="Жилкина Тамара" uiMO2_USERID="0" uiACTIVE="255"/>
<I uiID="0" uiDOMAINNAME="t.minchenkova" uiNORMALNAME="Минченкова Тамара" uiMO2_USERID="0" uiACTIVE="255"/>
<I uiID="0" uiDOMAINNAME="v.korneva" uiNORMALNAME="Корнева Варвара" uiMO2_USERID="0" uiACTIVE="255"/>
<I uiID="0" uiDOMAINNAME="v.shkvara" uiNORMALNAME="Шквара Валерия" uiMO2_USERID="0" uiACTIVE="255"/>
<I uiID="0" uiDOMAINNAME="v.taraskina" uiNORMALNAME="Тараскина Вера" uiMO2_USERID="0" uiACTIVE="255"/>
<I uiID="0" uiDOMAINNAME="s.kholin" uiNORMALNAME="Холин Сергей" uiMO2_USERID="125" uiACTIVE="255"/>
<I uiID="-183" uiDOMAINNAME="" uiNORMALNAME="" uiMO2_USERID="" uiACTIVE=""/>
</DATA>'
declare @xml xml = CAST(@xmltext as xml)
--------------------------------------------------------

declare @user varchar(64)
declare @workstation varchar(64)

select 
   @user  = t.r.value('@USER[1]'	, 'varchar(128)')
  ,@workstation = t.r.value('@WORKSTATION[1]'	, 'varchar(128)')
from 
 @xml.nodes('/DATA') as t(r)
-- ok -- select @user, @workstation

declare @temptable table (uiID int
                        , uiDomainName varchar(128)
						, uiNormalName varchar(128)
						, uiMO2_UserID int
						, uiActive tinyint
						, resID int)
declare @restable table ( ID int
                        , DomainName varchar(128)
						)

--  0 -- добавление 
--  1 -- изменение
--  2 -- удаление
-- 30 -- отключение
-- 31 -- включение
declare @logtable table (Entity int
						,RecordID int
						,[Event] tinyint
						,[EventDate] datetime
						,[User] varchar(64)
						,[WorkStation] varchar(64))
insert into @temptable
select 
   t.r.value('@uiID[1]'			, 'int')
  ,t.r.value('@uiDOMAINNAME[1]'	, 'varchar(128)')
  ,t.r.value('@uiNORMALNAME[1]'	, 'varchar(128)')
  ,t.r.value('@uiMO2_USERID[1]'	, 'int')
  ,t.r.value('@uiACTIVE[1]'		, 'tinyint')
  ,0
from 
 @xml.nodes('/DATA/I') as t(r)


begin tran
-- защита от повторного добавления, НО  (!!!!) не изменения (могут быть изменены NormalName, Active)
 update @temptable 
     set uiID = CHK.id
 from 
 (select id from dbo.lst_PermUser PU
 join (select uiID, uiDomainName from @temptable where uiID=0 and resID=0) T on T.uiDomainName = PU.DomainName) CHK
-- А ЭТО уже защита существующих записей от групповых изменений
 declare @cnt int = 0
 select @cnt=COUNT(*) from @temptable
 if (@cnt>1) and (IsNull(@group_update,0)=0) -- если групповая операция и ЗАПРЕЩЕНЫ групповые изменения 
   update @temptable 
      set resID = CHK.id -- помечаем записи как "ужо изменены, однако!"
    from (select id from dbo.lst_PermUser PU
          join (select uiID, uiDomainName from @temptable where uiID=0 and resID=0) T on T.uiDomainName = PU.DomainName) CHK


-- insert --------------------------------------------------------------
insert into dbo.lst_PermUser(DomainName, NormalName, MO2_UserID, Active)
output inserted.ID, inserted.DomainName into @restable
select uiDomainName, uiNormalName, uiMO2_UserID, uiActive from @temptable where uiID=0 and resID=0
update @temptable
 set resID = Res.ID
 from (select ID, DomainName from @restable) RES 
where uiDomainName = Res.DomainName
/*log*/insert @logtable(Entity, RecordID,[Event], [EventDate],[User],[WorkStation]) select 3, ID, 0/*insert*/,getdate(), @user, @workstation from @restable
delete @restable


-- ok -- select * from dbo.lst_PermUser
-- update --------------------------------------------------------------
select uiID,uiDomainName, uiNormalName, uiMO2_UserID, uiActive from @temptable where uiID>0 and resID=0
update dbo.lst_PermUser
 set DomainName = SRC.uiDomainName
    ,NormalName = SRC.uiNormalName
	,mo2_userId = SRC.uiMO2_UserID
	,Active = SRC.uiActive
output deleted.ID into @restable(ID)
from (select uiID,uiDomainName, uiNormalName, uiMO2_UserID, uiActive from @temptable where uiID>0 and resID=0) SRC
where ID = SRC.uiID
select * from dbo.lst_PermUser

update @temptable
 set resID = Res.ID
 from (select ID from @restable) RES 
where uiID = Res.ID
/*log*/insert @logtable(Entity, RecordID,[Event], [EventDate],[User],[WorkStation]) select 3, ID, 1/*update*/,getdate(), @user, @workstation from @restable
delete @restable

-- ok --select * from dbo.lst_PermUser
-- delete --------------------------------------------------------------
delete from dbo.lst_PermLink 
where ID_PermUser in (select abs(uiID) from @temptable where uiID<0 and resID=0)

delete from dbo.lst_PermUser
output deleted.ID into @restable(ID)
where ID in (select abs(uiID) from @temptable where uiID<0 and resID=0)

update @temptable
 set resID = Res.ID
 from (select ID from @restable) RES 
where abs(uiID) = Res.ID
/*log*/insert @logtable(Entity, RecordID,[Event], [EventDate] ,[User],[WorkStation]) select 3, ID, 2/*delete*/,getdate(), @user, @workstation from @restable
delete @restable

-- ok -- select * from dbo.lst_PermUser

/*
insert into dbo.lst_PermLog
select [Entity], [RecordID], [Event], [EventDate], [User], [WorkStation] from @logtable 
*/

select count(*) from @temptable where resID<>0
rollback tran










