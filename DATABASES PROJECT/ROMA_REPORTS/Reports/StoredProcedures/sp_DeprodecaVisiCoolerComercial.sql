

CREATE Procedure [Reports].[sp_DeprodecaVisiCoolerComercial]
@Period Char(6)
As
Begin

	--Declare @Period Char(6) = 202310



	drop table if exists #data_censo
	drop table if exists #venta
	drop table if exists #categorias
	drop table if exists #table_categorias
	drop table if exists #clientecat
	drop table if exists #venta_cat_cli



	--Tabla con las categorías dentro de los visicoolers
	create table #table_categorias (categoria varchar(50))
	insert into #table_categorias values ('YOGURT'),('QUESOS'),('MANTEQUILLA'),('MARGARINA'),('REFRESCOS'),('NÉCTAR'),('BEBIDAS LÁCTEAS'),('LECHE RTD'),('AGUA')




	--Traemos la vista de todos los registros de censos
	select 
		/*distinct ROW_NUMBER() over (order by codcliente) as id,*/ codcliente, 
		cliente, address , domi, marca, modelo, cuota, codproveedor, estado,
		proveedor, serie, codven, trim(nomven) nomven, codsup, nomsup, id_cartera, createdby
	into #data_censo 
	from vw_EquipmentInventory
	where codproveedor = 'PM00000066' and estado = 'O'

	--select distinct nomven from #data_censo where NomVen like '%carr%'


	--Traemos el fact de ventas
	select 
		cardcode, domi, ItemCode, UnitMsr, QUANTITY, LineTotal*VatPrcnt LineTotal, ctipdoc,
		ItemName, ccliente_d, cvendedor, U_U_BKS_CODSEDE, LINEA, codcar
	into #venta 
	from  ROMA_DATAMART.[Gloria].[Extractor_Ventas] 
	where periodo = @Period --and cvendedor = @@CodVen
	--select * from #venta where codcar = 'K08'
	--select top 10 * from [Gloria].[Extractor_Ventas]



	--Traemos todos los productos que pertenezcan a la tabla de categorias requerida
	select 
		CardCode, ItemName, ItemCode, Categoria, Linea
	into #categorias 
	from ROMA_DATAMART.[Gloria].vw_ItemsxLineaxOrden 
	where Categoria collate SQL_Latin1_General_CP850_CI_AS in (select Categoria from #table_categorias)
	--select * from #Categorias
	--select distinct linearw from [Gloria].vw_ItemsxLineaxOrden 












	--Cruzamos los clientes del censo (equipos) con cada categorias.
	select distinct	
		a.codcliente, a.cliente,	b.categoria, a.address , a.domi, a.marca, a.id_cartera,
		a.modelo, a.cuota, serie, a.codven, a.nomven, a.codsup, a.nomsup, a.estado
	into #clientecat
	from #data_censo a, #table_categorias b
	




	select
		 a.CardCode, b.Categoria, a.domi,
		SUM(case when a.ctipdoc <> 'NC' then a.LineTotal else -(a.LineTotal) end) as total
	into #venta_cat_cli
	from #venta a
	inner join #categorias b on a.itemcode = b.itemcode collate SQL_Latin1_General_CP1_CI_AS
	group by a.CardCode, b.Categoria, a.domi

	--select * from #clientecat where codcliente = 'CL00014387' and estado = 'O'
	--select * from #venta where cardcode = 'CL00014387'
	--select * from #venta_cat_cli where cardcode = 'CL00014387'









	drop table if exists #fdata
	drop table if exists #Tdata



	select  a.*, convert(varchar,'') CodSede, convert(varchar,'') DiaVisita, ISNULL(b.total,0) as total
	into #TData
	from #clientecat a
	left join #venta_cat_cli b on a.codcliente = b.CardCode collate SQL_Latin1_General_CP850_CI_AS and a.categoria = b.Categoria collate SQL_Latin1_General_CP850_CI_AS
	and a.domi = b.domi collate SQL_Latin1_General_CP850_CI_AS
	order by 2 asc
	
	--select * from #TData where codcliente  = 'CL00014387'

	
	select codcliente, categoria, domi, total, count(*) count 
	into #Fdata 
	from #Tdata 
	group by codcliente, categoria, domi, total having COUNT(*) > 1 
	--select * from #Fdata where codcliente = 'CL00000997'
	--select distinct nomven from #Tdata where NomVen like '%carr%'



	update #Tdata
		set  total = #Tdata.total/2
	from #Tdata, #Fdata 
	where #Tdata.codcliente = #Fdata.codcliente and #Tdata.total  = #Fdata.total and #Tdata.domi  = #Fdata.domi
	
	update a
		set 
		a.CodSede = b.CodSede,
		a.DiaVisita = c.DiaVisita
	from #TData a 
	left join ROMA_DATAMART.Ventas.DimVendedores b on a.codven = b.CodVen
	left join ROMA_DATAMART.Ventas.DimClientes c on a.codcliente = c.CodCli collate SQL_Latin1_General_CP850_CI_AS and a.domi = c.CodDom collate SQL_Latin1_General_CP850_CI_AS

	update #TData set DiaVisita = 'Lun A Sab' where DiaVisita is null

	

	--select * from #tdata WHERE CODVEN = 1843
	--select * from ventas.Fact_Cobertura_Visicooler 
	--drop table ventas.Fact_Cobertura_Visicooler
	
	delete from Reports.DeprodecaVisiCoolerComercial where period = @Period


	insert into Reports.DeprodecaVisiCoolerComercial
	select @Period,* from #TData

	

	/*
	;with dt as 
		(
			select
				a.[codigo roma],
				a.cliente,
				a.vendedor, b.CodVen, b.CodCar, b.U_Login,
				a.[vendedor actual] vendedor_Actual, c.CodVen codven_actual, c.CodCar codcar_actual, c.U_Login u_login_actual
			from ROMA_REPOSITORIO.[dbo].[data$] a 
			inner join Ventas.DimVendedores b on a.vendedor = b.NomVen
			inner join ventas.DimVendedores c on a.[vendedor actual] = c.NomVen
			where a.vendedor <> a.[vendedor actual]	
		)
		update a
			set a.codven = b.codven_actual, a.nomven = b.vendedor_Actual, a.id_cartera = b.codcar_actual
		from ventas.Fact_Cobertura_Visicooler a 
		inner join dt b on a.codcliente = b.[codigo roma] collate SQL_Latin1_General_CP850_CI_AS
		where a.periodo = @Period
		
		*/
End

GO

