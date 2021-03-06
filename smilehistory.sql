     
 /* + --------------------------------------+    
    | --- Import data from multiple CSV --- |
    + --------------------------------------+ */
  

	CREATE TABLE DerivativesDB.dbo.RawData 
	(name varchar(50), 	ticker varchar(10), 
	xtime varchar(50), 	fut float, 
	s float, a float,   b float, c float, 
	d float, e float,   t float)


	-- A table to loop thru filenames drop table ALLFILENAMES
	CREATE TABLE ALLFILENAMES(WHICHPATH VARCHAR(255),WHICHFILE varchar(255))

	--some variables
	declare @filename varchar(255), 
			@path varchar(255),
			@sql varchar(8000), 
			@cmd varchar(1000)


	/* -- Get the list of files to process: */
	
	SET @path = 'c:\1\'
	SET @cmd = 'dir ' + @path + '*.csv /b'
	
	
	/* -- Prepare system for file read -- */
	/*
	exec sp_configure 'show advanced options', 1
	RECONFIGURE
	
	exec sp_configure 'xp_cmdshell', 1
	RECONFIGURE
*/
	INSERT INTO  ALLFILENAMES(WHICHFILE)
	EXEC Master..xp_cmdShell @cmd
	UPDATE ALLFILENAMES SET WHICHPATH = @path where WHICHPATH is null
	
	--cursor loop
	DECLARE c1 CURSOR FOR SELECT WHICHPATH,WHICHFILE FROM ALLFILENAMES WHERE WHICHFILE like '%.csv%'
	OPEN c1
	FETCH NEXT FROM c1 INTO @path,@filename
	WHILE @@fetch_status <> -1
	  BEGIN
		  --bulk insert won't take a variable name, so make a sql and execute it instead:
		  BEGIN TRY
		   SET @sql = 'BULK INSERT DerivativesDB.dbo.RawData FROM ''' + @path + @filename + ''' '
			       + ' WITH ( 
					   FIELDTERMINATOR = '';'', 
					   ROWTERMINATOR = ''\n'', 
					   BATCHSIZE = 25,
					   FIRSTROW = 2 
					) '
			EXEC (@sql)
		   END TRY
		   BEGIN CATCH
			   print( ERROR_MESSAGE())
		   END CATCH
			
		  fetch next from c1 into @path,@filename
	  END
	  
	CLOSE c1
	DEALLOCATE c1
	
	DROP TABLE ALLFILENAMES
	
--select * from ALLFILENAMES
  -----------------------------------------------------------------------------------------------------
  
 /* + -----------------------------------+    
    | --- Prepare data for selection --- |
    + -----------------------------------+ */
  USE DerivativesDB;
  
 /* -- Convert text to date and insert into table -- */

	 ALTER TABLE RawData DROP COLUMN dtime
	       
	  ALTER TABLE RawData ADD dtime AS (   
		CONVERT(datetime,
		substring([xtime],1,4) + '-' + substring([xtime],5,2)  + '-' + substring([xtime],7,2) + ' ' +
		substring([xtime],9,2) + ':' + substring([xtime],11,2) + ':' + substring([xtime],13,2) + '.' +
		substring([xtime],15,3), 121)
	) PERSISTED

 /* -- Создаём таблицу для вывода данных -- */
  
	  CREATE TABLE data_RTS(
		name varchar(50),	small_name varchar(50),
		tms datetime,		fut_price float,
		s float, a float,	b float, c float,	
		d float, e float,	t float
		)
  -----------------------------------------------------------------------------------------------------
   /* + -----------------------------------------+    
    | --- GROUP BY and PARTITION BY solution --- |
    + -------------------------------------------+ */
  
USE DerivativesDB;
 
 IF OBJECT_ID('tempdb..#lasttime') IS NOT NULL DROP TABLE #lasttime
 
SELECT DISTINCT sname,
  MAX(dtime) OVER (
  PARTITION BY 
  sname,
  DATEPART(year, dtime), 
  DATEPART(month, dtime), 
  DATEPART(day, dtime) ) as xtime
  INTO #lasttime
  FROM [DerivativesDB].[dbo].[RawData]
  WHERE sname LIKE 'RI%' AND DATEPART(HOUR, dtime)<19 
  ORDER BY sname, xtime
  
  INSERT INTO data_RTS
  SELECT RawData.name, RawData.sname, RawData.dtime, RawData.f, RawData.s,  
		 RawData.a, RawData.b, RawData.c, RawData.d, RawData.e, RawData.t
  FROM RawData
  INNER JOIN #lasttime AS lt
  ON dtime=xtime AND RawData.sname=lt.sname
  ORDER BY sname, dtime
  
  
  
  
  Select sname, max(dtime) AS xtime from RawData 
  Where DATEPART(hour, dtime)<19
  Group By sname,  DATEPART(year, dtime), DATEPART(month, dtime), DATEPART(day, dtime)
  having sname LIKE 'RI%' 
  Order By sname, xtime
  
  -----------------------------------------------------------------------------------------------------
  
	
		
  /* + ------------------------------+    
    | --- Temp Table for ticker  --- |
    + -------------------------------+ */
    
   /*	drop table #oneticker
		select * from #oneticker */
 
	 SELECT * INTO #oneticker 
	 FROM DerivativesDB.dbo.RawData WHERE ticker Like 'RI%' 
	 ORDER BY  ticker, dtime
 
  /****Get dates by interval****/
 
	/*	select * from #distdates1 order by ticker, dates */
 
	IF OBJECT_ID('tempdb..#distdates') IS NOT NULL 
    DROP TABLE #distdates

	SELECT DISTINCT convert(varchar(10), dtime, 104)
	AS dates, ticker  INTO #distdates 
	FROM #oneticker ORDER BY dates
	

	-- drop table #dateticker
 	select ticker, CONVERT(datetime, dates , 104) as dates into #dateticker from #distdates ORDER BY ticker, dates

	 
 
  /* + -----------------------+    
    | --- Cursor solution --- |
    + ------------------------+ */
 
	 declare @disttime  datetime
	 declare @disttikr	varchar(10)
	 declare @cursor1 cursor
	 
	 set @cursor1 = CURSOR scroll local for  select * from #dateticker 
	 
	 open @cursor1
	 fetch next from @cursor1 into @disttikr, @disttime
	 while @@FETCH_STATUS=0
	 
	 BEGIN
		INSERT into DerivativesDB.dbo.data_RTS(fut_price, small_name, s, a, b, c, d, e, t, tms) 
		SELECT fut, ticker, s, a, b, c, d, e, t, dtime 
		FROM   #oneticker
		WHERE  ticker = @disttikr 
			and 
			dtime =( 
				SELECT MAX(dtime) 
				FROM #oneticker 
				WHERE cast(floor(cast(dtime as float)) as datetime)=@disttime AND DATEPART(hh, dtime)<19 AND ticker=@disttikr 
			) 
		FETCH NEXT FROM @cursor1 INTO @disttikr, @disttime
	 END
	 
	 CLOSE @cursor1
	 DEALLOCATE @cursor1
 