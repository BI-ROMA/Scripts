CREATE procedure [Reports].[sp_DeprodecaFocusSeller] @period VARCHAR(6)
AS

BEGIN



	--declare @period varchar(6) = '202311'



	drop table if exists #items, #cartera, #items_group, #dimClientes, #cliente_item, #cliente_peso, #cliente_peso_f
	drop table if exists #extractor_ventas, #data_mes_act, #data_mes_tre, #data_mes_ant
	drop table if exists #vta, #cob, #cob_mes_ant, #peso_vendedor, #data, #data_final, #data_null



	select 
		a.*, b.NomPro
	into #items
	from Upload.FocusProducts  a
	inner join ROMA_DATAMART.Ventas.DimProductos b on a.ProductCode = b.CodPro
	--select * from #items


	select * 
	into #extractor_ventas 
	from ROMA_DATAMART.[Gloria].[Extractor_Ventas]
	where Periodo >= Convert(Char(6), DateAdd(Month,-3, Cast(@period+'01' As Date)), 112) 
			and ItemCode in (select ProductCode from #items)  and Sbonif = 0 and flagAnula = 0
	--select * from #extractor_ventas where cardcode = 'CL00939653' and itemcode = 'DEP506107' and cvendedor = 1905


	select  
		a.periodo, a.codcar, a.Sucursal, a.CardCode, a.ItemCode, b.item, 
		SUM(case ctipdoc when 'NC' then - LineTotal else LineTotal end) as total
	into #data from #extractor_ventas a
	inner join #items b on a.ItemCode = b.ProductCode 
	where ItemCode in (select ProductCode from #items) and cvendedor not in (1, 16)
	group by a.periodo, a.codcar, a.Sucursal, a.U_U_BKS_CODSEDE, a.CardCode, a.ItemCode, b.item
	having  SUM(case ctipdoc when 'NC' then - LineTotal else LineTotal end) > 0
	--select * from #Data where cardcode = 'CL00939653' and itemcode = 'DEP506107' and cvendedor = 1905

	select distinct codcli, nomcli, CodDom, DiaVisita into #dimClientes from ROMA_DATAMART.ventas.DimClientes

	select * into #data_mes_act
	from #data where Periodo = @period

	select * into #data_mes_tre
	from #data where Periodo <> @period

	select periodo, codcar, CardCode, item, Sucursal, sum(total) vta 
	into #vta from #data_mes_act
	group by periodo, codcar, CardCode, item, Sucursal


	--calcular la cartera inicial
	SELECT distinct b.CodVen, b.CodCar, a.CodCli, c.Sucursal
	INTO #cartera
	FROM [ROMA_DATAMART].ventas.[Fact_CarteraInicial_xVendedor] a
	inner join [ROMA_DATAMART].ventas.DimVendedores b on a.IdVen = b.IdVen
	inner join [ROMA_DATAMART].ventas.DimSedes c on a.IdSede = c.IdSede
	where left(a.FechaKey,6) = @period and IdProveedor = 16
	--select * from #cartera order by codven


	select distinct CodVen, CodCar, CodCli, sucursal, Item 
	into #cliente_item
	from #cartera, #items
	--SELECT * FROM #cliente_item


	select distinct
		a.CodCli, a.CodCar, a.Sucursal, a.Item,
		convert(decimal(18,2), sum(b.total) over (partition by a.CodCli, a.sucursal, b.item)) /convert(decimal(18,2),sum(b.total) over (partition by a.sucursal, b.item)) peso
	into #cliente_peso
	from #cliente_item a
	left join #data_mes_tre b on a.CodCar = b.codcar and a.CodCli = b.CardCode and a.Item = b.Item
	--SELECT * FROM #cliente_peso


	select CodCli, CodCar, Sucursal, Item, peso
	into #cliente_peso_f
	from #cliente_peso
	



	select  
		a.CodCli, c.NomCli, e.CodVen, convert(varchar(20), '-') DiaVisita, '001' CodDom,
		a.Item, isnull(b.vta,0) vta, a.Sucursal, convert(decimal(18,2), 0) cuo_vta_tot, convert(decimal(18,2), 0) cuo_vta_cli, a.peso
	into #data_final
	from #cliente_peso_f a
	left join #vta b on a.CodCli = b.CardCode and a.Item = b.Item and a.Sucursal = b.Sucursal and a.CodCar = b.codcar
	left join #dimClientes c on a.CodCli = c.CodCli and c.CodDom = '001'
	left join ROMA_DATAMART.ventas.DimVendedores e on a.CodCar = e.CodCar and e.Estado = 'A'
	/*
	select  * from #cliente_peso_f
	select top 10 * from #vta
	select top 10 * from #dimClientes
	*/
	;with dt as (
		select a.sucursal, a.item, b.CodCli 
		from #data_final a 
		inner join (SELECT distinct CodCli, Sucursal FROM #cliente_item) b on a.Sucursal = b.Sucursal
		group by a.sucursal, a.item, b.CodCli 
		having sum(a.peso) is null
	) 
	select Sucursal, Item,  1/convert(decimal(18,8),count(distinct codcli)) peso
	into #data_null
	from dt group by sucursal, item



	update a
		set a.peso = b.peso 
	--select *
	from #data_final a
	inner join #data_null b on a.Sucursal = b.Sucursal and a.Item = b.Item
	where a.peso is null
	

	update #data_final set peso = 0.000005 where peso is null






	select 
		Item, max(WeightCoverage) peso_cob, 
		sum(Goal_ica) cuota_ica, sum(Goal_aya) cuota_aya, 
		sum(Goal_ica_sinigv) cuota_ica_sinigv, sum(Goal_aya_sinigv) cuota_aya_sinigv
	into #items_group
	from #items
	group by Item

	

	update a
		set a.cuo_vta_tot = b.cuota_ica_sinigv
	from #data_final a
	inner join #items_group b on a.Sucursal = 'Ica' and b.Item = a.Item



	update a
		set a.cuo_vta_tot = b.cuota_aya_sinigv
	from #data_final a
	inner join #items_group b on a.Sucursal = 'Ayacucho' and b.Item = a.Item



	update #data_final
	set cuo_vta_cli = peso * cuo_vta_tot



	update a
		set a.diavisita = b.DiaVisita 
	from #data_final a
	inner join #dimClientes b on a.CodCli = b.CodCli and a.CodDom = b.CodDom

	--select codven, count(distinct codcli) from #data_final group by codven
	--select * from #cliente_peso_f
	delete from Reports.DeprodecaFocusSeller where period = @period

	insert into Reports.DeprodecaFocusSeller
	select @period, * 
	from #data_final 
	
END

GO

