--Select * From Reportes.Registro_CarteraInicial Where Periodo = 202208
--Drop Table #CarteraInicial
Declare 
	@FlActualizar Bit = 1,
	@Periodo Int = 202208

If @FlActualizar=1
Begin
	Delete Reportes.Registro_CarteraInicial Where Periodo = @Periodo
End

;With dt as (Select Distinct slpcode codven, U_BKS_CodSed codsede, SlpName nomven, U_BKS_Mesa codmesa, U_BKS_CodCart codcar, U_BKP_GRUPO grupovnd 
			From OSLP
			Where U_BKS_ESTATUS = 'A')
Select Distinct @Periodo Periodo, codven, U_BKP_CLIENTE CodCli, codmesa, codsede, codcar, grupovnd CodCanal, Right(b.U_BKP_CODCNL, 2) CodCanal_Cnf,
U_BKP_CODDOM
--Select codven, b.*
Into #CarteraInicial
From dt a
Inner Join [@BKS_CLIENTE_MESA] b On a.codmesa = U_BKP_CODMESA And a.codcar = u_bkp_codven And u_bkp_estado = 'A'
Inner Join [@BKS_MESA] c On b.U_BKP_CODMESA = c.Code
Where U_BKP_CLIENTE Is Not Null And iSnULL(U_BKP_CODRUT, '')!=''
And IsNull(U_BKP_CODDIA, '')<>'' And IsNull(U_BKP_CODVEN, '')<>'' And U_BKP_CODMESA <> '000'
And Not Exists (Select * From Reportes.Registro_CarteraInicial c Where periodo = @Periodo And a.codven = c.codven)

Insert Into Reportes.Registro_CarteraInicial(Periodo, CodVen, CodCli, CodMesa, CodSede, CodCar, CodCanal, CodDom)
Select Distinct Periodo, CodVen, CodCli, CodMesa, CodSede, CodCar, CodCanal_Cnf, U_BKP_CODDOM
From #CarteraInicial 

-- Select * From #CarteraInicial Where CodCli In ('CL00931594', 'CL00940487')

--Drop Table #Cuo
Select distinct codven, codsede, nomven, codmesa, codcar, grupovnd CodCanal
Into #Cuo
-- Select *
From reportes.mov_cuotas 
Where periodo = 202108 And codven In (575, 993, 1433, 1819) And cuota > 0

--Select * From #Cuo  Where codven = 1819

Update #Cuo Set codven = 1201, nomven = 'URIBE OCA�A, AUGUSTO' Where codven=993
Update #Cuo Set codven = 1593, nomven = 'DIAZ CAMPOVERDE, RONALD SANTOS' Where codven=1433
Update #Cuo Set codven = 72, nomven = 'TORO LLALLI WALTER YIMI' Where codven=1819

;With dt as (Select * From #Cuo)
Insert Into Reportes.Registro_CarteraInicial(Periodo, CodVen, CodCli, CodMesa, CodSede, CodCar, CodCanal, CodDom)
Select Distinct 202208, codven, U_BKP_CLIENTE CodCli, codmesa, codsede, codcar, CodCanal, U_BKP_CODDOM
From dt a
Inner Join [@BKS_CLIENTE_MESA] b On a.codmesa = U_BKP_CODMESA And Ltrim(Str(a.codven)) = u_bkp_codven And u_bkp_estado = 'A'
Inner Join [@BKS_ZONAS] bb On b.U_BKP_CODZON = bb.Code And a.codsede = bb.U_BKP_CODSEDE
Where Not Exists (Select * From Reportes.Registro_CarteraInicial c Where c.Periodo = 202208 And a.codven = c.codven)
And codven In (1201, 1593, 72)
Group By codsede, codmesa, codcar, codven, U_BKP_CLIENTE, CodCanal, U_BKP_CODDOM
Order BY CodVen, CodCli


--------------------------------------------------------------------------------------------------------
											/* FIN CARTERA INICIAL*/
--------------------------------------------------------------------------------------------------------

Select * From OSLP Where SlpCode In (1201, 1593, 72)
Select distinct CodCli From Reportes.Registro_CarteraInicial Where Periodo = 202204 And CodVen = 1201

Select * From Reportes.Registro_CarteraInicial Where Periodo = 202204 And CodSede = 'AY'And CodCanal='07'

Select * From Reportes.Registro_CarteraInicial Where Periodo = 202208 And CodCar = 'HIC07'

Select * From [@BKS_CLIENTE_MESA] where U_BKP_CODVEN = '1989'

Select * From reportes.mov_cuotas Where periodo = 202108 And codven = 993

Select distinct codven, codsede, nomven, codmesa, codcar, grupovnd CodCanal
From reportes.mov_cuotas 
Where periodo = 202204 


Select * From OSLP Where SlpName Like '%napa%'
Select * From OSLP Where SlpName Like '%rosalia%'

Select Periodo, Count(*) From Reportes.Registro_CarteraInicial Group By Periodo Order By 1 Desc


Select * fRom OSLP Where SlpCode = 72

Select Top 2000 * From Reportes.Registro_CarteraInicial Where Periodo = 202107 And CodVen = 72
Select * From [@BKS_CLIENTE_MESA] Where U_BKP_CODVEN = 'HCH05'


Select *
-- Update a Set codven = 72
			From reportes.mov_cuotas a 
			Where codven = 575 


Select *
-- Update a Set codven = 72
From reportes.cmvta_vendedor_New  a 
Where codven = 575 


Select* From OSLP Where SlpCode In (993, 691)

Select * 
-- Update a Set u_bks_estatus ='A'
From [@BKS_SUPERVISORES] a Where Code In ('0066', '0071')

Select * 
-- Update a Set u_bks_estatus ='I'
From [@BKS_SUPERVISORES] a Where Code In ('0078', '0086', '0003')


Select * From Reportes.FormaPagoCabecera Where Periodo = 202204
Select * From Reportes.FormaPago Where Periodo = 202204



Select codcat, Count(distinct codmesa) 
From reportes.cm_pesomesaprvcat 
Where numano+nummes = 202204 And codprv Like '%000066'
Group By codcat



Select * From reportes.rel_mesa_prv
Where numano+nummes = 202204 And codprv Like '%000066'


Select * From Reportes.rel_mesa_prv Where numano+nummes=202204

select * From reportes.Registro_CarteraInicial
Where Periodo = '202204' And CodMesa = '015'


select distinct CodMesa From reportes.Registro_CarteraInicial
Where Periodo = '202204' And CodMesa = '027'

select distinct CodMesa From reportes.Registro_CarteraInicial
Where Periodo = '202204' And CodMesa = '027'

Select * From [@BKS_SUPERVISORES] Where Name Like '%cesar%'
Select * From [@BKS_SUPERVISORES] Where Name Like '%uribe%'


Select * From OSLP Where SlpName Like '%macha%'
Select * From OSLP Where SlpName Like '%uribe%'

Select * From OSLP Where SlpCode IN (691, 1201)

Select * From OSLP Where u_bks_Mesa = '029'

Select * From OSLP
Where SlpName Like '%leche%'

Select TaxDate, CardCode, DocTotal, * From OINV Where SlpCode = 1411

Select * From reportes.Registro_CarteraInicial Where CodVen In (691, 1201) And Periodo = 202204

Select * From reportes.mov_cuotas Where CodVen In (691, 1201) And Periodo = 202204


Select Distinct CodSede, CodSedeNew From reportes.Registro_CarteraInicial Where Periodo=202204




Select * From reportes.mov_cuotas Where CodVen In (691, 1201) And Periodo = 202201

Select * From reportes.mov_cuotas Where CodVen In (691, 1201) And Periodo = 202204
