CREATE Procedure [Gloria].[SP_Sincroniza_Extractores] 
@Opc Char(1)
As
Begin

	-- 0: Extractor
	-- 1: SP desde el SAP del SR3
	-- Gloria.SP_Sincroniza_Extractores '0'

	If @Opc = '0'
	Begin
		Truncate Table Gloria.Extractor_Clientes 
		;With dt As (Select cdist, Max(IdProceso) IdProces From SrvRepo.Roma_Repositorio.gloria.Extractor_Clientes Group By cdist)
		Insert Into Gloria.Extractor_Clientes 
		Select * From SrvRepo.Roma_Repositorio.gloria.Extractor_Clientes
		Where Idproceso In (Select IdProces From dt)

		
		Declare @Periodo Char(6)
		Set @Periodo = Convert(Char(6), GETDATE(), 112)
		If Day(Getdate()) = 1 Set @Periodo = Convert(Char(6), Getdate()-1, 112)

		Delete Gloria.Extractor_Ventas Where Left(Periodo, 6) = @Periodo

		;With 
		dt As (Select Distinct Sucursal, iKey From SrvRepo.Roma_Repositorio.Gloria.ExtractoGloria Where Left(Periodo, 6) = @Periodo),
		dt1 As (Select Sucursal, iKey, ROW_NUMBER() Over(Partition  By Sucursal Order By iKey Desc) Ord From dt)
		Insert Into Gloria.Extractor_Ventas
		Select 
			a.iKey, a.DocEntry, a.NumDoc, a.CardCode, a.LineNum, a.ItemCode, a.UnitMsr, a.QUANTITY, a.LineTotal, a.LineVat, a.ItemName, a.BaseEntry, a.DiscPrcnt,
			a.cdist, a.cserie, a.ccorrelativo, a.contieneItems, a.ccliente_d, a.cgruven1, a.cvendedor, a.fpedido, a.ctipdoc, a.cconpag, a.femision, a.cmotdoc,
			a.fentregaprog, a.cmoneda, a.ivtabruto, a.idsctos, a.ivtaneto, a.ivtatot, a.fanula, a.flagAnula, a.fentrega, a.Npos, a.cmaterial, a.Cumv, a.qpedido,
			a.qfactura, a.qentrega, a.ivtabruto_p, a.idsctos_p, a.ivtaneto_p, a.Sbonif, a.Scombo, a.npos_bonif, a.ctipdoc_ref, a.cserie_ref, a.ccorrel_ref,
			a.sum_ivtabruto, a.sum_idsctos, a.Tipo_Tran, a.Descuento_cabecera, a.IGV, a.U_VAR_Anda, a.U_OK1_Anulada, a.CardCode2, a.anulado, a.gloria, a.domi,
			a.docentrync, a.objtype, a.U_BKP_CODMESA, a.comentario, a.U_U_BKS_CODSEDE, a.VatPrcnt, a.TaxDate, a.Valor1, a.Peso, a.Volumen, a.U_BKS_LINEA,
			a.LINEA, a.UMES, a.Periodo, a.Sucursal, null, a.codcar, c.clasifDeprodeca
		 From SrvRepo.Roma_Repositorio.Gloria.ExtractoGloria a
		Inner Join dt1 b On a.sucursal = b.sucursal And a.iKey = b.ikey And b.Ord = 1
		inner join Ventas.DimClientes c on a.cardcode collate SQL_Latin1_General_CP850_CI_AS = c.CodCli and a.domi collate SQL_Latin1_General_CP850_CI_AS = c.CodDom
		

		/*
		update Gloria.Extractor_Ventas set ItemCode = 'DEP001251' where itemcode = 'DEP001027' and Periodo = 202303
		update Gloria.Extractor_Ventas set ItemCode = 'DEP001255' where itemcode = 'DEP001039' and Periodo = 202303
		update Gloria.Extractor_Ventas set ItemCode = 'DEP001215' where itemcode = 'DEP001017' and Periodo = 202303
		update Gloria.Extractor_Ventas set ItemCode = 'DEP001219' where itemcode = 'DEP001025' and Periodo = 202303
		*/
		--Declare @QtdRegOrigen Int, @QtdRegdestino Int 
		
		--Select @QtdRegOrigen = Count(1) From SrvRepo.Roma_Repositorio.Gloria.ExtractoGloria 
		--Select @QtdRegdestino = Count(1) From Gloria.Extractor_Ventas

		--If @QtdRegdestino = @QtdRegOrigen
		--Begin
		--	Print 'SI'
		--End


	End

	If @Opc = '1'
	Begin
		Truncate Table Gloria.tbl_SP_deprodeca_cobertura_plantilla_general
		InserT Into Gloria.tbl_SP_deprodeca_cobertura_plantilla_general
		Select * From SrvSAP.Roma_Productiva.Gloria.tbl_SP_deprodeca_cobertura_plantilla_general
	End
	
End

GO

