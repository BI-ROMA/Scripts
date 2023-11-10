CREATE procedure [Reports].[sp_DeprodecaFocusSupervisor] @period VARCHAR(6)
AS

BEGIN
	--declare @period varchar(6) = '202311'



	drop table if exists #items, #cartera, #items_group
	drop table if exists #extractor_ventas, #data_mes_act, #data_mes_tre, #data_mes_ant
	drop table if exists #vta, #cob, #cob_mes, #peso_vendedor, #data, #data_final




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
		a.periodo, a.TaxDate, a.codcar, a.Sucursal, a.CardCode, a.ItemCode, b.item, 
		SUM(case ctipdoc when 'NC' then - LineTotal else LineTotal end) as total,
		SUM(case ctipdoc when 'NC' then - UMES else UMES end) as UME
	into #data from #extractor_ventas a
	inner join #items b on a.ItemCode = b.ProductCode 
	where ItemCode in (select ProductCode from #items) and cvendedor not in (1, 16)
	group by a.periodo, a.TaxDate, a.codcar, a.Sucursal, a.U_U_BKS_CODSEDE, a.CardCode, a.ItemCode, b.item
	having  SUM(case ctipdoc when 'NC' then - LineTotal else LineTotal end) > 0
	--select * from #Data where cardcode = 'CL00939653' and itemcode = 'DEP506107' and cvendedor = 1905


	
	select * into #data_mes_act
	from #data where Periodo = @period

	select * into #data_mes_tre
	from #data where Periodo <> @period
	--select * from #data_mes_act where item = 'Bebida Lactea' and cvendedor = '2298'
	

	select periodo, taxdate, codcar, item, Sucursal,  sum(total) vta, sum(UME) UME
	into #vta from #data_mes_act
	group by periodo, taxdate, codcar, Sucursal, item
	
	select periodo, taxdate, codcar, Sucursal, item, count(distinct CardCode) cob 
	into #cob from #data_mes_act
	group by periodo, taxdate, codcar, Sucursal, item

	select periodo, codcar, Sucursal, item, count(distinct CardCode) cob_mes
	into #cob_mes from #data_mes_act
	group by periodo, codcar, Sucursal, item
	
	
	select 
		distinct codcar, Sucursal, item, 
		convert(decimal(18,2), sum(total) over (partition by  codcar, sucursal, item)) /convert(decimal(18,2),sum(total) over (partition by sucursal, item)) pesovta, 
		convert(decimal(18,2),sum(UME) over (partition by  codcar, sucursal, item)) / convert(decimal(18,2),sum(UME) over (partition by sucursal, item)) pesoume
	into #peso_vendedor
	from #data_mes_tre
	--select * from #peso_vendedor where cardcode = 'CL00000003'



	--calcular la cartera inicial
	SELECT a.IdVen, b.CodCartera, count(distinct a.CodCli) car
	INTO #cartera
	FROM [ROMA_DATAMART].ventas.[Fact_CarteraInicial_xVendedor] a
	inner join  [ROMA_DATAMART].ventas.DimCarteras b on a.IdCartera = b.IdCartera
	where left(a.FechaKey,6) = @period
	group by a.IdVen, b.CodCartera
	--select * from #cartera order by codven
	--select top 10 * from ventas.[Fact_CarteraInicial_xVendedor]



	select 
		a.TaxDate, a.codcar, e.NomVen, 
		f.NomSup, f.CodSup, a.Sucursal, 
		e.CodSede, a.item,  a.vta, a.ume,b.cob, 
		c.cob_mes, d.car, g.pesovta, g.pesoume, 
		cast(0.0 as int) cuo_cob, 
		cast(0.0 as int) cuo_vta, 
		cast(0.0 as int) cuo_vta_tot,
		cast(0.0 as int) cuo_ume,
		cast(0.0 as int) cuo_ume_tot
	into #data_final
	from #vta a
	left join #cob b on a.item = b.item and a.codcar = b.codcar and a.TaxDate = b.TaxDate
	left join #cob_mes c on a.item = c.item and a.codcar = c.codcar and a.TaxDate = b.TaxDate
	left join #cartera d on a.codcar = d.CodCartera
	left join #peso_vendedor g on a.codcar = g.codcar and a.item = g.item
	left join ROMA_DATAMART.ventas.DimVendedores e on a.codcar = e.codcar and e.Estado = 'a'
	left join ROMA_DATAMART.ventas.Dim_vw_Supervisores f on e.CodSup collate SQL_Latin1_General_CP1_CI_AS = f.CodSup


	select 
		Item, max(WeightCoverage) peso_cob, 
		sum(Goal_ica) cuota_ica, sum(Goal_aya) cuota_aya, 
		sum(Goal_ica_sinigv) cuota_ica_sinigv, sum(Goal_aya_sinigv) cuota_aya_sinigv, 
		sum(Goal_ume_ica) cuota_ume_ica, sum(Goal_ume_aya) cuota_ume_aya  
	into #items_group
	from #items
	group by Item

	--select * from #data_final where item ='Battimix'


	update a
		set a.cuo_vta_tot = b.cuota_ica_sinigv
	from #data_final a
	inner join #items_group b on a.Sucursal = 'Ica' and b.Item = a.Item
	update a
		set a.cuo_vta_tot = b.cuota_aya_sinigv
	from #data_final a
	inner join #items_group b on a.Sucursal = 'Ayacucho' and b.Item = a.Item

	update a
		set a.cuo_ume_tot = b.cuota_ume_ica
	from #data_final a
	inner join #items_group b on a.Sucursal = 'Ica' and b.Item = a.Item

	update a
		set a.cuo_ume_tot = b.cuota_ume_aya
	from #data_final a
	inner join #items_group b on a.Sucursal = 'Ayacucho' and b.Item = a.Item





	update #data_final
	set cuo_vta = isnull(pesovta,0.01) * cuo_vta_tot

	update #data_final
	set cuo_ume = isnull(pesoume,0.01) * cuo_ume_tot


	
	update a
		set a.cuo_cob = a.car * b.peso_cob
	from #data_final a
	inner join #items_group b on a.item = b.item



	delete from [Reports].[DeprodecaFocusSupervisor] where period = @period

	insert into [Reports].[DeprodecaFocusSupervisor]
	select @period, * from #data_final

END

GO

