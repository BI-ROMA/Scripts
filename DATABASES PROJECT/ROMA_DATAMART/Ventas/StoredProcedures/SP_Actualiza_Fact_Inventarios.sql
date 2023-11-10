CREATE Procedure [Ventas].[SP_Actualiza_Fact_Inventarios]
As

Begin 

	Declare @Fecha_DiaAnterior Varchar(11) = Convert(Varchar(11), Getdate()-1, 112),
			@Fecha_DiaActual Varchar(11) = Convert(Varchar(11), Getdate(), 112)

	--Select @Periodo = Max(Left(FechaKey, 6)) From Ventas.Fact_Inventarios
	/*
	If Not Exists (Select * From Ventas.Fact_Inventarios_Acum Where FechaKey = @Fecha_DiaAnterior)
	Begin
		Insert Into Ventas.Fact_Inventarios_Acum 
		Select FechaKey, IdAlmacen, IdProveedor, IdProducto, IdCat_xPrv, Cantidad, Valorizado 
		From Ventas.Fact_Inventarios
		Where FechaKey = @Fecha_DiaAnterior
		Truncate Table Ventas.Fact_Inventarios
	End
	*/
	If Exists (Select * From Ventas.Fact_Inventarios Where FechaKey = @Fecha_DiaActual)
	Begin
		Delete Ventas.Fact_Inventarios Where FechaKey = @Fecha_DiaActual
	End
			   
	Insert Into Ventas.Fact_Inventarios(FechaKey, IdAlmacen, IdProveedor, IdProducto, Cantidad, Cantidad_xPiezas, Valorizado, IdCat_xPrv)
	Select @Fecha_DiaActual, IdAlmacen, d.IdPrv, IdPro, Stock , Stock_Piezas, Stock*PrecioCompra , c.IdCat_xPrv	
	From ROMA_REPOSITORIO.Temp.Inventarios a 
	Inner Join ventas.dimalmacenes b On a.CodAlmacen = b.CodAlmacen
	Inner Join ventas.DimProductos c On a.codpro = c.CodPro
	inner join Ventas.DimCategorias d on c.IdCat_xPrv = d.IdCat_xPrv


	--Select * From Ventas.DimFechas Where Left(FechaKey, 6)=Convert(Char(6), GETDATE()-1, 112) And FechaKey <> Convert(Char(8), GETDATE(), 112)
	--Select * From Ventas.Dim_vw_FactorProyectado

	--Alter Table Ventas.Fact_Inventarios Add Qtd Decimal(18,2), QtdPry Decimal(18,2), Vta Decimal(18,2), VtaPry Decimal(18,2)

	--Select * From Ventas.DimProductos Where CodPro = 'DEP001007'
	--Select * From Ventas.Fact_Inventarios Where IdProducto = 177

	--Select * From  Ventas.Dim_vw_FactorProyectado
	;With 
	dtFechas As (Select a.FechaKey, b.DiasValidosTranscurridos, b.FactorPryMes
				From Ventas.DimFechas a, Ventas.Dim_vw_FactorProyectado b
				Where Left(a.FechaKey, 6)=Convert(Char(6), GETDATE()-1, 112) And a.FechaKey <> Convert(Char(8), GETDATE(), 112)),
	dt As (Select IdProducto, sed.IdAlmacen,
				Sum(Cantidad)/Max(b.DiasValidosTranscurridos) Qtd,
				Sum(TotalIGV)/Max(b.DiasValidosTranscurridos) Vta,
				Sum(Cantidad)/Max(b.DiasValidosTranscurridos)*Max(b.FactorPryMes) QtdPry,
				Sum(TotalIGV)/Max(b.DiasValidosTranscurridos)*Max(b.FactorPryMes) VtaPry				
				From Planillas.Fact_Ventas a
				Inner Join Ventas.DimSedes sed On a.IdSede = sed.IdSede
				Inner Join dtFechas b On a.FechaKey = b.FechaKey
				Group By IdProducto, sed.IdAlmacen)
	Update a Set Qtd = b.Qtd, QtdPry = b.QtdPry, Vta = b.Vta, VtaPry = b.VtaPry	
	From Ventas.Fact_Inventarios a
	Inner Join dt b On a.IdProducto = b.IdProducto And a.IdAlmacen = b.IdAlmacen
	
	--Select * From Ventas.Fact_Inventarios	
	
	;With 
	dtCuotas As (Select IdAlmacen, IdPrv, IdCat_xPrv, Sum(Cuota) Cuota From ventas.Fact_Cuotas a
				Inner Join ventas.DimSedes b On a.IdSede = b.IdSede
				Where Left(FechaKey, 6) = Left(@Fecha_DiaActual, 6)
				Group By IdAlmacen, IdPrv, IdCat_xPrv),
	dt As (Select a.*, b.Cuota, Cuota/Count(IdProducto) Over(Partition By a.IdAlmacen, a.IdProveedor, a.IdCat_xPrv) Cuota_xCatEstimada
				From Ventas.Fact_Inventarios a
				Inner Join dtCuotas b On a.IdAlmacen = b.IdAlmacen And a.IdCat_xPrv = b.IdCat_xPrv And a.IdProveedor = b.IdPrv)
	Update a Set Cuota_xCat = b.Cuota_xCatEstimada	
	From Ventas.Fact_Inventarios a
	Inner Join dt b On a.IdAlmacen = b.IdAlmacen And a.IdCat_xPrv = b.IdCat_xPrv And a.IdProveedor = b.IdProveedor And a.IdProducto = b.IdProducto
	   
End

GO

