CREATE procedure [Reports].[sp_CommissionsSupervisorReport] @Period char(6)

as

begin
	
	
	--declare @Period varchar(6) = 202311
	declare @periodoant varchar(6) = @Period -1

	

	drop table if exists #fact_ventas, #fact_cartera, #fact_cobertura, #fact_ventas_ant, #fact_cuotas, #fact_devoluciones, 
						 #factor_proyectado, #comision_venta, #comision_venta_prev, #comision_cobertura, #comision_cobertura_prev, 
						 #comision_devolucion, #comision_devolucion_prev, #num_cat, #comision_final, #Fact_Cartera_Inicial


	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS LA VENTA DEL PERIODO ACTUAL
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select  
		LEFT(FechaKey, 6) Periodo, IdCartera, IdSupervisor, IdCat_xPrv, IdProveedor, IdJefe_dVenta, SUM(TotalIGV) TotalIGV
	into #fact_ventas 
	from ROMA_DATAMART.ventas.Fact_Ventas
	where left(FechaKey, 6) = @Period
	group by 
		left(FechaKey, 6),         IdCartera, IdSupervisor, IdCat_xPrv,	IdProveedor, IdJefe_dVenta

	
	
	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS LA CARTERA DEL PERIODO ACTUAL
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select * into #Fact_Cartera_Inicial
	from ROMA_DATAMART.Ventas.Fact_CarteraInicial_xVendedor where periodo = @Period

	select  
		LEFT(a.FechaKey, 6) Periodo, a.IdCartera, a.IdSupervisor, a.IdCat_xPrv, a.IdProveedor, a.IdJefe_dVenta,
		(select count(distinct CodCli) from #Fact_Cartera_Inicial b where a.IdSupervisor = b.IdSupervisor and a.IdProveedor = b.IdProveedor and a.IdCat_xPrv = b.IdCat_xPrv) Cartera,
		(select count(distinct CodCli) from #Fact_Cartera_Inicial b where a.IdSupervisor = b.IdSupervisor and a.IdProveedor = b.IdProveedor) Cartera_subtotal,
		(select count(distinct CodCli) from #Fact_Cartera_Inicial b where a.IdSupervisor = b.IdSupervisor) Cartera_total
	into #fact_cartera
	from #Fact_Cartera_Inicial a
	group by 
		LEFT(a.FechaKey, 6),        a.IdCartera, a.IdSupervisor, a.IdCat_xPrv, a.IdProveedor, a.IdJefe_dVenta



	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS LA COBERTURA DEL PERIODO ACTUAL
	------------------------------------------------------------------------------------------------------------------------------------------------------
	;with dt as (
		select  
				left(fechakey, 6) periodo, IdCartera, idsupervisor, idcat_xprv, IdProveedor, idjefe_dventa, idcliente, sum(TotalIGV) total
		from ROMA_DATAMART.ventas.fact_ventas a
		where left(fechakey, 6) = @Period 
		group by 
				left(fechakey, 6),		   IdCartera, idsupervisor, idcat_xprv, IdProveedor, idjefe_dventa, idcliente
		having sum(TotalIGV) > 0
	) 
	select 
		periodo, IdCartera, IdSupervisor, IdCat_xPrv, IdProveedor, IdJefe_dVenta,
		(select count(distinct IdCliente) from dt sub where dt.IdSupervisor = sub.IdSupervisor and dt.IdProveedor = sub.IdProveedor and  dt.IdCat_xPrv = sub.IdCat_xPrv) cobertura,
		(select count(distinct IdCliente) from dt sub where dt.IdSupervisor = sub.IdSupervisor and dt.IdProveedor = sub.IdProveedor) cobertura_subtotal,
		(select count(distinct IdCliente) from dt sub where dt.IdSupervisor = sub.IdSupervisor) cobertura_total
	into #fact_cobertura 
	from dt
	group by 
			periodo, IdCartera, IdSupervisor, IdCat_xPrv, IdProveedor, IdJefe_dVenta

	--select * from #fact_cobertura where idsupervisor = 31 and idproveedor = 10
	
	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS LA VENTA DEL PERIODO ANTERIOR
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select  
		left(fechakey, 6) periodo, IdCartera, idsupervisor, idcat_xprv, IdProveedor, idjefe_dventa, sum(totaligv) totaligv
	into #fact_ventas_ant 
	from ROMA_DATAMART.ventas.fact_ventas 
	where left(fechakey, 6) = @periodoant
	group by 
		left(fechakey, 6),		   IdCartera, idsupervisor, idcat_xprv, IdProveedor, idjefe_dventa


	
	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS LAS CUOTAS DEL PERIODO ACTUAL
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select 
		left(fechakey, 6) periodo, IdCar, idsupervisor, idcat_xprv, IdPrv, idjefe_dventa, sum(cuota) cuota, max(FactorCob_xLinea) FactorCob
	into #fact_cuotas
	from ROMA_DATAMART.ventas.fact_cuotas
	where left(fechakey, 6) = @Period
	group by 	
		left(fechakey, 6),		   IdCar, idsupervisor, idcat_xprv, IdPrv, idjefe_dventa


	
	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS LAS DEVOLUCIONES DEL PERIODO ACTUAL
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select  
		left(fechakey, 6) periodo, IdCartera, IdSupervisor, idcat_xprv, IdProveedor, idjefe_dventa, sum(totaligv) totaligv
	into #fact_devoluciones
	from ROMA_DATAMART.ventas.fact_ventas 
	where left(fechakey, 6) = @Period and TotalIGV < 0
	group by 
		left(fechakey, 6),		  IdCartera, idsupervisor, idcat_xprv, IdProveedor, idjefe_dventa



	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS EL FACTOR DE PROYECCION DEL PERIODO
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select 
		left(FechaKey,6) periodo, FechaActual, DiasFaltantes, DiasValidosMes, DiasValidosTranscurridos, DiasFeriadosMes, FactorPryMes FactorPry
	into #factor_proyectado
	from ROMA_DATAMART.Ventas.Dim_vw_FactorProyectado

	if (select periodo from #factor_proyectado) <> @Period
		update #factor_proyectado 
			set periodo = @Period, 
			FechaActual = CAST(CONVERT(char(8), @Period + '01', 112) AS date), 
			DiasFaltantes = 0, 
			DiasValidosMes = 25, 
			DiasValidosTranscurridos = 25,
			DiasFeriadosMes = 5, 
			FactorPry = 1

	------------------------------------------------------------------------------------------------------------------------------------------------
	--CALCULAMOS EL PESO DE CATEGORIAS POR SUPERVISORES
	------------------------------------------------------------------------------------------------------------------------------------------------
	select 
		a.IdSupervisor, count(distinct b.CodCat) numcat, convert(decimal(10,4), COUNT(distinct b.CodCat)) peso
	into #num_cat from #fact_cuotas a 
	inner join ROMA_DATAMART.Ventas.DimCategorias b on a.IdCat_xPrv =  b.IdCat_xPrv
	group by IdSupervisor
	
	update #num_cat set peso = convert(decimal(10,4), 1/peso)





	------------------------------------------------------------------------------------------------------------------------------------------------
	--GENERAMOS LA TABLA DE VENTAS
	------------------------------------------------------------------------------------------------------------------------------------------------
	select 
		a.periodo, a.idcar, a.IdSupervisor, a.IdCat_xPrv, a.IdPrv, a.IdJefe_dVenta, isnull(c.TotalIGV,0) vtamesant, isnull(a.cuota,0) cuota, isnull(b.TotalIGV,0) vta	
	into #comision_venta_prev
	from #fact_cuotas a
	left join #fact_ventas b on a.IdCar = b.IdCartera and a.IdSupervisor = b.IdSupervisor and a.IdCat_xPrv = b.IdCat_xPrv and a.IdPrv = b.IdProveedor 
	left join #fact_ventas_ant c on a.IdCar = c.IdCartera and a.IdSupervisor = c.IdSupervisor and a.IdCat_xPrv = c.IdCat_xPrv and a.IdPrv = c.IdProveedor 
	
	select 
		periodo, IdSupervisor, IdCat_xPrv, IdPrv, IdJefe_dVenta, sum(vtamesant) vtamesant, sum(cuota) cuota, sum(vta) vta
	into #comision_venta from #comision_venta_prev
	group by 
		periodo, IdSupervisor, IdCat_xPrv, IdPrv, IdJefe_dVenta





	------------------------------------------------------------------------------------------------------------------------------------------------
	--GENERAMOS LA TABLA DE COBERTURA
	------------------------------------------------------------------------------------------------------------------------------------------------
	select 
		a.periodo, a.IdCar, a.IdSupervisor, a.IdCat_xPrv, a.IdPrv, a.IdJefe_dVenta,			
		isnull(b.cartera, 0) cartera, isnull(b.Cartera_subtotal, 0) cartera_subtotal, isnull(b.Cartera_total, 0) cartera_total,
		isnull(c.cobertura, 0) cobertura, isnull(c.cobertura_subtotal, 0) cobertura_subtotal, isnull(c.cobertura_total, 0) cobertura_total,
		isnull(a.FactorCob, 0) FactorCob, convert(decimal(18,4), 0) FactorCob_subtotal, convert(decimal(18,4), 0) FactorCob_total,
		convert(decimal(18,2), 0) cobmeta, convert(decimal(18,2), 0) cobmeta_subtotal, convert(decimal(18,2), 0) cobmeta_total
	into #comision_cobertura_prev
	from #fact_cuotas a
	left join #fact_cartera b on a.IdCar = b.IdCartera and a.IdSupervisor = b.IdSupervisor and a.IdCat_xPrv = b.IdCat_xPrv and a.IdPrv = b.IdProveedor  
	left join #fact_cobertura c on a.IdCar = c.IdCartera and a.IdSupervisor = c.IdSupervisor and a.IdPrv = c.IdProveedor and a.IdCat_xPrv = c.IdCat_xPrv


	select 
		periodo, IdSupervisor, IdCat_xPrv, IdPrv, IdJefe_dVenta, 
		max(cartera) cartera, max(cartera_subtotal) cartera_subtotal, max(cartera_total) cartera_total,
		max(cobertura) cobertura, max(cobertura_subtotal) cobertura_subtotal, max(cobertura_total) cobertura_total, 
		max(FactorCob) FactorCob, max(FactorCob_subtotal) FactorCob_subtotal, max(FactorCob_total) FactorCob_total,
		max(cobmeta) cobmeta, max(cobmeta_subtotal) cobmeta_subtotal, max(cobmeta_total) cobmeta_total
	into #comision_cobertura from #comision_cobertura_prev
	group by 
		periodo, IdSupervisor, IdCat_xPrv, IdPrv, IdJefe_dVenta



	update #comision_cobertura
	set FactorCob_subtotal =  (
								select max(FactorCob) from #comision_cobertura x 
								where x.IdSupervisor = #comision_cobertura.IdSupervisor and x.IdPrv = #comision_cobertura.IdPrv)
	update #comision_cobertura
	set FactorCob_total =  (
							select max(FactorCob_subtotal) from #comision_cobertura x 
							where x.IdSupervisor = #comision_cobertura.IdSupervisor)
	
	update #comision_cobertura set cobmeta = cartera * FactorCob
	update #comision_cobertura set cobmeta_subtotal = cartera_subtotal * FactorCob_subtotal
	update #comision_cobertura set cobmeta_total = cartera_total * FactorCob_total


	------------------------------------------------------------------------------------------------------------------------------------------------
	--GENERAMOS LA TABLA DE DEVOLUCIONES
	------------------------------------------------------------------------------------------------------------------------------------------------
	select 
		a.periodo, a.IdCar, a.IdSupervisor, a.IdCat_xPrv, a.IdPrv, a.IdJefe_dVenta, isnull(b.TotalIGV,0) devolucion 
	into #comision_devolucion_prev 
	from #fact_cuotas a
	left join #fact_devoluciones b on a.IdCar = b.IdCartera and a.IdSupervisor = b.IdSupervisor and a.IdPrv = b.IdProveedor and a.IdCat_xPrv = b.IdCat_xPrv

	select 
		periodo, IdSupervisor, IdCat_xPrv, IdPrv, IdJefe_dVenta, sum(devolucion) devolucion
	into #comision_devolucion 
	from #comision_devolucion_prev
	group by periodo, IdSupervisor, IdCat_xPrv, IdPrv, IdJefe_dVenta


	/*
	select * from #comision_venta where IdSupervisor = 31 and IdPrv = 10
	select * from #comision_cobertura where IdSupervisor = 31 and IdPrv =  10
	select * from #comision_devolucion where IdSupervisor = 31 and IdPrv = 10
	*/

		
	------------------------------------------------------------------------------------------------------------------------------------------------
	--CONSTRUIMOS LA TABLA DE COMISIONES 
	------------------------------------------------------------------------------------------------------------------------------------------------
	select 
		a.periodo, convert(varchar(120), '') Codsede, convert(varchar(120), '') NameSede, 
		kk.CodPrv, kk.NomPrvAbr, k.CodCat, k.NomCat, n.CodSup, n.NomSup, o.CodJV, o.NomJV,
		a.vtamesant,  
		sum(a.vtamesant) over (partition by n.codsup, kk.CodPrv) SubVtaMesAnt,
		sum(a.vtamesant) over (partition by n.codsup) TotalVtaMesAnt,		
		a.cuota, 
		sum(a.cuota) over (partition by n.codsup, kk.CodPrv) SubCuota,
		sum(a.cuota) over (partition by n.codsup) TotalCuota,
		a.vta, 
		sum(a.vta) over (partition by n.codsup, kk.CodPrv) SubVta,
		sum(a.vta) over (partition by n.codsup) TotalVta,
		(a.vta*FactorPry) VtaPry,
		sum(a.vta*FactorPry) over (partition by n.codsup, kk.CodPrv) SubVtaPry,
		sum(a.vta*FactorPry) over (partition by n.codsup) TotalVtaPry,
		(a.vta*FactorPry)/a.cuota VtaPryPrc,
		convert(decimal(10,4), 0) SubVtaPryPrc,
		convert(decimal(10,4), 0) TotalVtaPryPrc,
		b.cartera,
		b.cartera_subtotal SubCartera,
		b.cartera_total TotalCartera,
		b.FactorCob,
		b.FactorCob_subtotal SubFactorCob,
		b.FactorCob_total TotalFactorCob,
		b.cobmeta,
		b.cobmeta_subtotal SubCobMeta,
		b.cobmeta_total TotalCobMeta,
		b.cobertura,
		b.cobertura_subtotal SubCobertura,
		b.cobertura_total TotalCobertura,
		(b.cobertura*FactorPry) CobPry,
		(b.cobertura_subtotal*FactorPry) SubCobPry,
		(b.cobertura_total*FactorPry) TotalCobPry,
		isnull((b.cobertura*FactorPry) / nullif(b.cobmeta,0),0) CobPryPrc,
		convert(decimal(10,4), 0) SubCobPryPrc,
		convert(decimal(10,4), 0) TotalCobPryPrc,
		c.devolucion,
		sum(c.devolucion) over (partition by n.codsup, kk.CodPrv) SubDevolucion,
		sum(c.devolucion) over (partition by n.codsup) TotalDevolucion,
		(c.devolucion*FactorPry) devPry,
		sum(c.devolucion*FactorPry) over (partition by n.codsup, kk.CodPrv) SubDevPry,
		sum(c.devolucion*FactorPry) over (partition by n.codsup) TotalDevPry,
		isnull((c.devolucion*FactorPry)/(nullif(a.vta,0)*FactorPry),0) devPryPrc,
		convert(decimal(10,4), 0) SubDevPryPrc,
		convert(decimal(10,4), 0) TotalDevPryPrc,
		d.DiasValidosMes, d.DiasValidosTranscurridos, d.DiasFaltantes, 
		e.numcat, e.peso, 
		f.remfija, f.excedenteporc, ((f.escala-f.remfija) *f.factor_xvta) BaseVtaCom, ((f.escala-f.remfija)*f.factor_xcob) BaseCobCom,
		convert(decimal(18,2), 0) ComVta, convert(decimal(18,2), 0) SubComVta, convert(decimal(18,2), 0) TotalComVta,
		convert(decimal(18,2), 0) ComCob, convert(decimal(18,2), 0) SubComCob, convert(decimal(18,2), 0) TotalComCob, 
		convert(decimal(18,2), 0) ComTotal, convert(decimal(18,2), 0) SubComTotal, convert(decimal(18,2), 0) TotalComTotal, 
		convert(decimal(18,2), 0) Sueldo
	into #comision_final
	from #comision_venta a
	inner join #comision_cobertura b on a.IdSupervisor = b.IdSupervisor and a.IdCat_xPrv = b.IdCat_xPrv and a.IdPrv = b.IdPrv 
	inner join #comision_devolucion c on a.IdSupervisor = c.IdSupervisor and a.IdCat_xPrv = c.IdCat_xPrv and a.IdPrv = c.IdPrv
	inner join #factor_proyectado d on  a.periodo = d.periodo 
	inner join #num_cat e on a.IdSupervisor = e.IdSupervisor
	inner join ROMA_DATAMART.Ventas.DimComisiones f on  f.IdTipoUser = 2
	inner join ROMA_DATAMART.Ventas.DimCategorias k on a.IdCat_xPrv = k.IdCat_xPrv
	inner join ROMA_DATAMART.ventas.DimProveedores kk on k.IdPrv = kk.IdPrv
	inner join ROMA_DATAMART.Ventas.Dim_vw_Supervisores n on a.IdSupervisor = n.IdSup
	inner join ROMA_DATAMART.Ventas.Dim_vw_Jefes_dVenta o on a.IdJefe_dVenta = o.IdJV



	------------------------------------------------------------------------------------------------------------------------------------------------
	--INSERTAMOS LAS SEDES DE LOS SUPERVISORES
	------------------------------------------------------------------------------------------------------------------------------------------------
	drop table if exists #sedes, #sedes_sup

	;with dt as (
				select distinct CodSup, CodSede, NomSede from Reports.CommissionsDeprodecaReport
				union all
				select distinct SupervisorCode, TerritoryCode, TerritoryName from Reports.CommissionsMultibrandReport
	) select distinct * into #sedes from dt

	select
		a.CodSup,
		STUFF((select ', ' + b.NomSede as [text()] from #sedes b where a.CodSup = b.CodSup for xml path('')),1,1,'') nomsede,
		STUFF((select ', ' + b.CodSede as [text()] from #sedes b where a.CodSup = b.CodSup for xml path('')),1,1,'') codsede
	into #sedes_sup from #sedes a group by a.CodSup
	
	update a set a.NameSede = b.nomsede, a.Codsede = b.codsede from #comision_final a inner join #sedes_sup b on a.CodSup = b.CodSup collate SQL_Latin1_General_CP850_CI_AS


	
	------------------------------------------------------------------------------------------------------------------------------------------------
	--CALCULAMOS LAS COMISIONES S/. DE VENTA Y COBERTURA
	------------------------------------------------------------------------------------------------------------------------------------------------

	update #comision_final set SubCobMeta = 1 where SubCobMeta = 0
	update #comision_final set TotalCobMeta = 1 where TotalCobMeta = 0

	update #comision_final set SubVtaPry = 1 where SubVtaPry = 0
	update #comision_final set TotalVtaPry = 1 where TotalVtaPry = 0
	


	update #comision_final set SubVtaPryPrc = SubVtaPry/SubCuota	
	update #comision_final set TotalVtaPryPrc = TotalVtaPry/TotalCuota

	update #comision_final set SubCobPryPrc = SubCobPry/SubCobMeta
	update #comision_final set TotalCobPryPrc = TotalCobPry/TotalCobMeta
	


	update #comision_final set SubDevPryPrc = SubDevPry/SubVtaPry
	update #comision_final set TotalDevPryPrc = TotalDevPry/TotalVtaPry




	--SELECT * FROM #COMISION_FINAL

	update  #comision_final 
		set ComVta = BaseVtaCom*peso * (case when VtaPryPrc > 1.20 then 1.20 else VtaPryPrc end) 

	update  #comision_final 
		set ComCob = BaseCobCom*peso * (case when CobPryPrc > 1.20 then 1.20 else CobPryPrc end) 



	update #comision_final
	set ComTotal = ComVta + ComCob


	update #comision_final 
		set SubComVta = ( 
				select sum(ComVta)
				from #comision_final x
				where x.CodSup = #comision_final.CodSup and x.CodPrv = #comision_final.CodPrv
		)
	update #comision_final 
		set SubComCob = ( 
				select sum(ComCob)
				from #comision_final x
				where x.CodSup = #comision_final.CodSup and x.CodPrv = #comision_final.CodPrv 
		)
	update #comision_final 
		set SubComTotal = ( 
				select sum(ComTotal)
				from #comision_final x
				where x.CodSup = #comision_final.CodSup and x.CodPrv = #comision_final.CodPrv
		)





	update #comision_final 
		set TotalComVta = ( 
				select sum(ComVta)
				from #comision_final x
				where x.CodSup = #comision_final.CodSup 
		)
	update #comision_final 
		set TotalComCob = ( 
				select sum(ComCob)
				from #comision_final x
				where x.CodSup = #comision_final.CodSup  
		)
	update #comision_final 
		set TotalComTotal = ( 
				select sum(ComTotal)
				from #comision_final x
				where x.CodSup = #comision_final.CodSup
		)


	------------------------------------------------------------------------------------------------------------------------------------------------
	--CALCULAMOS EL TOTAL DE COMISION (SUELDO) S/.
	------------------------------------------------------------------------------------------------------------------------------------------------
	update #comision_final set Sueldo = TotalComTotal + remfija

		
	delete from Reports.CommissionsSupervisorReport where period =@Period


	insert into Reports.CommissionsSupervisorReport
	select * from #comision_final
	
	

end

GO

