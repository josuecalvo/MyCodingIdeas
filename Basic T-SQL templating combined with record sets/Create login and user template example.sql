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