if object_id('tempdb..#Users') is not null
drop table #Users
 
select [user] = 'UserExample1', [login] = 'UserExample1', [password] = 'gshjwm172XX'
into #Users
union all
select 'UserExample2', 'UserExample2', '57HXlkao'
 
exec TemplateDataRunner
'
use [master]
go
create login [<%login%>]
with
password = N''<%password%>'',
default_database=[sandbox]
go
use [Sandbox]
go
create user [<%user%>] for login [<%login%>]
go
',
'#Users'


if object_id('tempdb..#DbObjects') is not null
drop table #DbObjects
 
select
[Schema] = s.name,
[Object] = o.name,
ObjectType = o.type_desc,
[login] = u.[login],
[user] = u.[user],
[permission] = case
    when o.type_desc = 'SQL_STORED_PROCEDURE' then 'execute'
    else 'select'
   end
into #DbObjects
from Sandbox.sys.objects o
join Sandbox.sys.schemas s on s.schema_id = o.schema_id
cross join #Users u
where o.type_desc in
(
'SQL_STORED_PROCEDURE',
'USER_TABLE'
)
 
exec TemplateDataRunner
'grant <%permission%> on [<%schema%>].[<%object%>] to <%user%>',
'#DbObjects'