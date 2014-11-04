declare
@xml xml,
@sql nvarchar(max)
 
select @xml = '<row xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Id>1</Id>
  <Name>Company 1</Name>
  <CreatedBy>TestUser</CreatedBy>
  <Created>2014-07-26T02:38:30.8841179Z</Created>
  <ModifiedBy>TestUser</ModifiedBy>
  <Modified>2014-07-26T04:12:25.1752401Z</Modified>
  <RowVersion>AAAAAAAAB9I=</RowVersion>
</row>
<row xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Id>2</Id>
  <Name>Company 2</Name>
  <CreatedBy>TestUser</CreatedBy>
  <Created>2014-07-26T04:07:20.8495373Z</Created>
  <ModifiedBy xsi:nil="true"/>
  <Modified xsi:nil="true"/>
  <RowVersion>AAAAAAAAF3M=</RowVersion>
</row>
<row xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Id>3</Id>
  <Name>Company 3</Name>
  <CreatedBy>TestUser</CreatedBy>
  <Created>2014-07-26T04:07:32.6675379Z</Created>
  <ModifiedBy xsi:nil="true"/>
  <Modified xsi:nil="true"/>
  <RowVersion>AAAAAAAAF3Q=</RowVersion>
</row>
';
 
with nodes
as
(
select
NodeName
from
(
select
r .value ( 'fn:local-name(.)', 'nvarchar(128)') as NodeName
FROM @xml.nodes ('/row[1]/*' ) AS records (r )
) x
)
select @sql =
(
select
'p.value(''./' + NodeName + '[1][not(@xsi:nil = "true")]'', ''nvarchar(max)'') as [' + NodeName + '],'
from nodes
for xml path('node')
)
;
 
select @sql =
replace(
replace(@sql, '<node>', '')
, '</node>', '
')
;
 
select @sql = 'select
' + left(@sql, len(@sql) - 3) + '
from @xml.nodes(''/row'') t(p)'
;
 
exec sp_executesql @sql, N'@xml xml', @xml;