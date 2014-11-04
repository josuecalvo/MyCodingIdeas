declare @text nvarchar(max);
 
select @text = 'Place your text here
It can be up to 32767 lines long
';
 
if right(@text, 2) <>  + CHAR(13) + CHAR(10)
 select @text = @text + CHAR(13) + CHAR(10);
 
with line as
(
select
convert(int, 0) as posi1,
CHARINDEX(CHAR(13) + CHAR(10), @text) + 2 as posi2,
SUBSTRING(@text, 0, CHARINDEX(CHAR(13) + CHAR(10), @text, 0)) as line
union all
select
convert(int, posi2) as posi1,
CHARINDEX(CHAR(13) + CHAR(10), @text, posi2) + 2 as posi2,
SUBSTRING(@text, posi2, CHARINDEX(CHAR(13) + CHAR(10), @text, posi2) - posi2) as line
from line
where CHARINDEX(CHAR(13) + CHAR(10), @text, posi2) - posi2 >= 0
)
select line
from line option (maxrecursion 32767)