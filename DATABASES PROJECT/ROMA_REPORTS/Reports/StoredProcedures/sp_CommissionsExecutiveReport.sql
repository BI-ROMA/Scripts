CREATE procedure [Reports].[sp_CommissionsExecutiveReport] @Period char(6)

as

begin
	
	
	--declare @Period varchar(6) = 202311
	declare @periodoant varchar(6) = @Period -1

	

	drop table if exists #fact_ventas, #fact_cartera, #fact_cobertura, #fact_ventas_ant, #fact_cuotas, #fact_devoluciones, #factor_proyectado,			 
						 #comision_venta, #comision_venta_prev, #comision_cobertura, #comision_cobertura_prev, #comision_devolucion, #comision_devolucion_prev, 
						 #num_cat, #comision_final, #DimComisiones, #Fact_Cartera_Inicial, #comision_venta_f, #comision_cobertura_f, #comision_devolucion_f


	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS LA VENTA DEL PERIODO ACTUAL
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select  
			LEFT(a.FechaKey, 6) Periodo, b.ExecutiveCode, a.IdProveedor, SUM(a.TotalIGV) TotalIGV
	into #fact_ventas 
	from ROMA_DATAMART.Planillas.Fact_Ventas a
	inner join Reports.SupplierDistributionsExecutive b on a.IdProveedor = b.IdSupplier
	where left(a.FechaKey, 6) = @Period
	group by 
			left(FechaKey, 6),        b.ExecutiveCode, a.IdProveedor

	--select * from #fact_ventas
	
	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS LA CARTERA DEL PERIODO ACTUAL
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select * into #Fact_Cartera_Inicial
	from ROMA_DATAMART.Ventas.Fact_CarteraInicial_xVendedor a
	inner join Reports.SupplierDistributionsExecutive b on a.IdProveedor = b.idSupplier 
	where periodo = @Period

	select  
			LEFT(a.FechaKey, 6) Periodo, a.ExecutiveCode, a.IdProveedor,
			(select count(distinct b.CodCli) from #Fact_Cartera_Inicial b where a.ExecutiveCode = b.ExecutiveCode and a.IdProveedor = b.IdProveedor) Cartera,
			(select count(distinct b.CodCli) from #Fact_Cartera_Inicial b where a.ExecutiveCode = b.ExecutiveCode ) Cartera_total
	into #fact_cartera
	from #Fact_Cartera_Inicial a
	group by 
			LEFT(a.FechaKey, 6),         a.ExecutiveCode, a.IdProveedor

	--select * from #fact_cartera

	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS LA COBERTURA DEL PERIODO ACTUAL
	------------------------------------------------------------------------------------------------------------------------------------------------------
	;with dt as (
		select  
				left(a.fechakey, 6) periodo, b.ExecutiveCode, a.IdProveedor, a.idcliente, sum(a.TotalIGV) total
		from ROMA_DATAMART.planillas.fact_ventas a
		inner join Reports.SupplierDistributionsExecutive b on a.IdProveedor = b.IdSupplier
		where left(a.fechakey, 6) = @Period 
		group by 
				left(a.fechakey, 6),		 b.ExecutiveCode, a.IdProveedor, a.idcliente
		having sum(a.TotalIGV) > 0
	) 
	select 
			periodo, ExecutiveCode, IdProveedor,
			(select count(distinct sub.IdCliente) from dt sub where dt.ExecutiveCode = sub.ExecutiveCode and dt.IdProveedor = sub.IdProveedor) cobertura,
			(select count(distinct sub.IdCliente) from dt sub where dt.ExecutiveCode = sub.ExecutiveCode) cobertura_total
	into #fact_cobertura 
	from dt
	group by 
			periodo, ExecutiveCode, IdProveedor
	
	--select * from #fact_cobertura
	
	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS LA VENTA DEL PERIODO ANTERIOR
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select  
			left(a.fechakey, 6) periodo, b.ExecutiveCode, a.IdProveedor,  sum(a.totaligv) totaligv
	into #fact_ventas_ant 
	from ROMA_DATAMART.planillas.fact_ventas a
	inner join Reports.SupplierDistributionsExecutive b on a.IdProveedor = b.IdSupplier
	where left(a.fechakey, 6) = @periodoant
	group by 
			left(fechakey, 6),		  b.ExecutiveCode, IdProveedor
	--select * from #fact_ventas_ant where idsupervisor = 73

	
	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS LAS CUOTAS DEL PERIODO ACTUAL
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select 
			left(a.fechakey, 6) periodo, b.ExecutiveCode, a.IdPrv, sum(a.cuota) cuota, sum(a.CobMeta) cobmeta, max(a.FactorCob_xLinea) FactorCob
	into #fact_cuotas
	from ROMA_DATAMART.ventas.fact_cuotas a
	inner join Reports.SupplierDistributionsExecutive b on a.IdPrv = b.IdSupplier
	where left(a.fechakey, 6) = @Period
	group by 	
			left(fechakey, 6),		 b.ExecutiveCode, a.IdPrv
	--select * from #fact_cuotas where idsupervisor = 73

	
	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS LAS DEVOLUCIONES DEL PERIODO ACTUAL
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select  
		left(a.fechakey, 6) periodo, b.ExecutiveCode, a.IdProveedor, sum(a.totaligv) totaligv
	into #fact_devoluciones
	from ROMA_DATAMART.planillas.fact_ventas a
	inner join Reports.SupplierDistributionsExecutive b on a.IdProveedor = b.IdSupplier 
	where left(a.fechakey, 6) = @Period and a.TotalIGV < 0
	group by 
		left(a.fechakey, 6),		 b.ExecutiveCode, a.IdProveedor
	--select * from #fact_devoluciones where idsupervisor = 73


	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS EL FACTOR DE PROYECCION DEL PERIODO
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select 
		left(FechaKey,6) periodo, FechaActual, DiasFaltantes, DiasValidosMes,DiasValidosTranscurridos, DiasFeriadosMes,FactorPryMes FactorPry
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


	-----------------------------------------------------------------------------------------------------------------------------------------------------------
	--CALCULAMOS EL PESO POR CATEGORIAS DE JEFES DE VENTA
	-----------------------------------------------------------------------------------------------------------------------------------------------------------
	select 
		ExecutiveCode, count(distinct IdPrv) numcat, convert(decimal(10,4), COUNT(distinct IdPrv)) peso
	into #num_cat from #fact_cuotas 
	group by ExecutiveCode

	update #num_cat set peso = convert(decimal(10,4), 1/peso)
	--select * from #num_cat


	/*
	select * from #fact_cartera order by IdProveedor
	select * from #fact_cobertura order by IdProveedor
	select * from #fact_cuotas order by IdPrv 
	select * from #fact_ventas order by IdProveedor
	select * from #fact_ventas_ant order by IdProveedor
	*/
	-----------------------------------------------------------------------------------------------------------------------------------------------------------
	--GENERAMOS LA TABLA DE VENTAS
	-----------------------------------------------------------------------------------------------------------------------------------------------------------
	select 
		a.periodo, a.ExecutiveCode, a.IdPrv, isnull(c.TotalIGV,0) vtamesant, a.cuota, isnull(b.TotalIGV,0) vta	
	into #comision_venta_prev
	from #fact_cuotas a
	left join #fact_ventas b on a.IdPrv = b.IdProveedor and a.ExecutiveCode = b.ExecutiveCode
	left join #fact_ventas_ant c on a.IdPrv = c.IdProveedor and a.ExecutiveCode = c.ExecutiveCode
	
	select 
		periodo, ExecutiveCode, IdPrv, sum(vtamesant) vtamesant, sum(cuota) cuota, sum(vta) vta
	into #comision_venta from #comision_venta_prev
	group by 
		periodo, ExecutiveCode, IdPrv

	--select * from #comision_venta




	-----------------------------------------------------------------------------------------------------------------------------------------------------------
	--CALCULAMOS LAS CUOTAS Y AVANCE DE COBERTURA
	-----------------------------------------------------------------------------------------------------------------------------------------------------------
	select 
		a.periodo, a.ExecutiveCode, a.IdPrv, 			
		isnull(b.cartera, 0) cartera, isnull(b.Cartera_total, 0) cartera_total,
		isnull(c.cobertura, 0) cobertura, isnull(c.cobertura_total, 0) cobertura_total,
		isnull(a.FactorCob, 0) FactorCob, convert(decimal(18,4), 0) FactorCob_total,
		convert(decimal(18,2), 0) cobmeta, convert(decimal(18,2), 0) cobmeta_total
	into #comision_cobertura_prev
	from #fact_cuotas a
	left join #fact_cartera b on a.IdPrv = b.IdProveedor and a.ExecutiveCode = b.ExecutiveCode
	left join #fact_cobertura c on a.IdPrv = c.IdProveedor and a.ExecutiveCode = c.ExecutiveCode


	select 
		periodo, ExecutiveCode, IdPrv,
		max(cartera) cartera, max(cartera_total) cartera_total,
		max(cobertura) cobertura, max(cobertura_total) cobertura_total, 
		max(FactorCob) FactorCob, max(FactorCob_total) FactorCob_total,
		max(cobmeta) cobmeta, max(cobmeta_total) cobmeta_total
	into #comision_cobertura from #comision_cobertura_prev
	group by 
		periodo, ExecutiveCode, IdPrv




	update #comision_cobertura
	set FactorCob_total =  (
							select max(FactorCob) from #comision_cobertura x
							where x.ExecutiveCode = #comision_cobertura.ExecutiveCode)
	
	update #comision_cobertura set cobmeta = cartera * FactorCob
	update #comision_cobertura set cobmeta_total = cartera_total * FactorCob_total


	-----------------------------------------------------------------------------------------------------------------------------------------------------------
	--CALCULAMOS EL AVANCE DE DEVOLUCIONES 
	-----------------------------------------------------------------------------------------------------------------------------------------------------------
	select 
		a.periodo, a.ExecutiveCode, a.IdPrv, isnull(b.TotalIGV,0) devolucion 
	into #comision_devolucion_prev 
	from #fact_cuotas a
	left join #fact_devoluciones b on a.IdPrv = b.IdProveedor and a.ExecutiveCode = b.ExecutiveCode

	select 
		periodo, ExecutiveCode, IdPrv, sum(devolucion) devolucion
	into #comision_devolucion 
	from #comision_devolucion_prev
	group by periodo, ExecutiveCode, IdPrv



	-----------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS LA ESCALA REMUNERATIVA DE LOS JEFES DE VENTA
	-----------------------------------------------------------------------------------------------------------------------------------------------------------
	select * into #DimComisiones
	from ROMA_DATAMART.Ventas.DimComisiones
	 
	 


	/*
	select * from #comision_venta_f order by 4
	select * from #comision_cobertura_f order by 4
	select * from #comision_devolucion_f order by 4
	*/
	------------------------------------------------------------------------------------------------------------------------------------------------
	--CONSTRUIMOS LA TABLA DE COMISIONES 
	------------------------------------------------------------------------------------------------------------------------------------------------
	
	select 
		a.periodo,
		a.ExecutiveCode ExecutiveCode,
		g.ExecutiveName ExecutiveName,
		kk.CodPrv, kk.NomPrvAbr,
		a.vtamesant,  
		sum(a.vtamesant) over (partition by a.executiveCode) TotalVtaMesAnt,		
		a.cuota, 
		sum(a.cuota) over (partition by a.executiveCode) TotalCuota,
		a.vta, 
		sum(a.vta) over (partition by a.executiveCode) TotalVta,
		(a.vta*FactorPry) VtaPry,
		sum(a.vta*FactorPry) over (partition by a.executiveCode) TotalVtaPry,
		(a.vta*FactorPry)/a.cuota VtaPryPrc,
		convert(decimal(10,4), 0) TotalVtaPryPrc,
		b.cartera,
		b.cartera_total TotalCartera,
		b.FactorCob,
		b.FactorCob_total TotalFactorCob,
		b.cobmeta,
		b.cobmeta_total TotalCobMeta,
		b.cobertura,
		b.cobertura_total TotalCobertura,
		(b.cobertura*FactorPry) CobPry,
		(b.cobertura_total*FactorPry) TotalCobPry,
		isnull((b.cobertura*FactorPry) / nullif(b.cobmeta,0),0) CobPryPrc,
		convert(decimal(10,4), 0) TotalCobPryPrc,
		c.devolucion,
		sum(c.devolucion) over (partition by a.executiveCode) TotalDevolucion,
		(c.devolucion*FactorPry) devPry,
		sum(c.devolucion*FactorPry) over (partition by a.executiveCode) TotalDevPry,
		isnull((c.devolucion*FactorPry)/(nullif(a.vta,0)*FactorPry),0) devPryPrc,
		convert(decimal(10,4), 0) TotalDevPryPrc,
		d.DiasValidosMes, d.DiasValidosTranscurridos, d.DiasFaltantes, 
		h.numcat numcat,
		h.peso peso,
		convert(decimal(18,2), 0) remfija, 
		convert(decimal(18,2), 0) excedenteporc, 
		convert(decimal(18,2), 0) BaseVtaCom, 
		convert(decimal(18,2), 0) BaseCobCom,
		convert(decimal(18,2), 0) ComVta, convert(decimal(18,2), 0) TotalComVta,
		convert(decimal(18,2), 0) ComCob, convert(decimal(18,2), 0) TotalComCob, 
		convert(decimal(18,2), 0) ComTotal, convert(decimal(18,2), 0) TotalComTotal, 
		convert(decimal(18,2), 0) Sueldo
	into #comision_final
	from #comision_venta a
	inner join #comision_cobertura b on a.IdPrv = b.IdPrv  and a.ExecutiveCode = b.ExecutiveCode
	inner join #comision_devolucion c on a.IdPrv = c.IdPrv and a.ExecutiveCode = c.ExecutiveCode
	inner join #factor_proyectado d on  a.periodo = d.periodo 
	inner join #num_cat h on a.ExecutiveCode = h.ExecutiveCode
	inner join Reports.SupplierDistributionsExecutive g on a.ExecutiveCode = g.ExecutiveCode and a.IdPrv = g.IdSupplier 
	inner join Roma_Datamart.ventas.DimProveedores kk on a.IdPrv = kk.IdPrv
	

	;with dt as (
		select * from #comision_final 
		where ExecutiveCode <> '0001'
	) 
	update dt 
		set dt.remfija = dr.remfija, dt.excedenteporc = dr.excedenteporc, 
		dt.BaseVtaCom = ((dr.escala-dr.remfija)*dr.factor_xvta), 
		dt.BaseCobCom = ((dr.escala-dr.remfija)*dr.factor_xcob)
	from dt , (select * from #DimComisiones where IdTipoUser = 6) dr 



	;with dt as (
		select * from #comision_final 
		where ExecutiveCode = '0001'
	) 
	update dt 
		set dt.remfija = dr.remfija, dt.excedenteporc = dr.excedenteporc, 
		dt.BaseVtaCom = ((dr.escala-dr.remfija)*dr.factor_xvta), 
		dt.BaseCobCom = ((dr.escala-dr.remfija)*dr.factor_xcob)
	from dt , (select * from #DimComisiones where IdTipoUser = 7) dr 


	------------------------------------------------------------------------------------------------------------------------------------------------
	--CALCULAMOS LAS COMISIONES S/. DE VENTA Y COBERTURA
	------------------------------------------------------------------------------------------------------------------------------------------------
	update #comision_final set TotalCobMeta = 1 where TotalCobMeta = 0
	update #comision_final set TotalVtaPry = 1 where TotalVtaPry = 0

	update #comision_final set TotalVtaPryPrc = TotalVtaPry/TotalCuota
	update #comision_final set TotalCobPryPrc = TotalCobPry/TotalCobMeta
	
	update #comision_final set TotalDevPryPrc = TotalDevPry/TotalVtaPry

	--SELECT * FROM #COMISION_FINAL
	update  #comision_final 
		set ComVta = BaseVtaCom*peso * (case when VtaPryPrc > 1.20 then 1.20 else VtaPryPrc end)
	update  #comision_final 
		set ComCob = BaseCobCom*peso * (case when CobPryPrc > 1.20 then 1.20 else CobPryPrc end) 

	update #comision_final
	set ComTotal = ComVta + ComCob
	
	------------------------------------------------------------------------------------------------------------------------------------------------
	--CALCULAMOS EL TOTAL DE COMISION (SUELDO) S/.
	------------------------------------------------------------------------------------------------------------------------------------------------
	update #comision_final 
		set TotalComVta = ( 
				select sum(ComVta)
				from #comision_final x where x.ExecutiveCode = #comision_final.ExecutiveCode
		)
	update #comision_final 
		set TotalComCob = ( 
				select sum(ComCob)
				from #comision_final x where x.ExecutiveCode = #comision_final.ExecutiveCode
		)
	update #comision_final 
		set TotalComTotal = ( 
				select sum(ComTotal)
				from #comision_final x where x.ExecutiveCode = #comision_final.ExecutiveCode
		)
	
	update #comision_final set Sueldo = TotalComTotal + remfija

		
	
	delete from Reports.CommissionsExecutiveReport where period = @Period



	insert into Reports.CommissionsExecutiveReport
	select * from #comision_final


end

GO

