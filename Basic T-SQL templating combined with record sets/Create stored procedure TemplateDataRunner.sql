create procedure [dbo].[TemplateDataRunner]
@Template nvarchar(max),
@Data nvarchar(128),
@StartMark varchar(10) = '<%',
@EndMark varchar(10) = '%>'
as
 
set nocount on
set ansi_warnings off
 
declare
@StartPosi int,
@EndPosi int,
@LastPosi int,
@ColumnName varchar(128)
 
declare @ColumnNames table
(
ColumnName varchar(128)
)
 
select
@StartPosi = 1,
@LastPosi = 0
 
while @StartPosi > 0
begin
   select @StartPosi = charindex(@StartMark, @Template, @LastPosi + 1)
  
    if @StartPosi > 0
    begin
       select @ColumnName = substring(@Template, @StartPosi + 2, 99999)
 
        select @EndPosi = charindex(@EndMark, @ColumnName)
       
        if @EndPosi > 0
      begin
           select @ColumnName = left(@ColumnName, @EndPosi - 1)
             
            insert into @ColumnNames (ColumnName) values (@ColumnName)
      end
     select
      @LastPosi = @StartPosi
  end
end
 
declare
@sql nvarchar(max),
@TemplateSQL nvarchar(max)
 
select @sql = '@Template'
 
declare RunTemplate cursor
fast_forward
for
select distinct
ColumnName
from @ColumnNames
 
open RunTemplate
 
fetch next from RunTemplate
into @ColumnName
 
while @@fetch_status = 0
begin
  select @sql = 'replace(
' + @sql + '
,''' + @StartMark + @ColumnName + @EndMark + ''', '''''' + convert(varchar(max), [' + @ColumnName + ']) + '''''')'
   fetch next from RunTemplate
 into @ColumnName
end
 
close RunTemplate
deallocate RunTemplate
 
select @sql = '
select @Template = '''''''' + replace(@Template, '''''''', '''''''''''') + ''''''''
 
select @TemplateSQL = 
' + @sql
 
exec sp_executesql @sql, N'@Template nvarchar(max), @TemplateSQL nvarchar(max) out', @Template, @TemplateSQL out
 
select @sql = 'select ' + @TemplateSQL + '
from ' + @Data
 
exec sp_executesql @sql