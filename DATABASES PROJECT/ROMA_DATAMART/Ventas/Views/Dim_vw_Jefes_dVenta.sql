

















CREATE View [Ventas].[Dim_vw_Jefes_dVenta]

As

	Select 
		Convert(Smallint, Code) IdJV, 
		Code CodJV, 
		Name NomJV, 
		U_bks_codigo CodJVSAP, 
		u_login, 
		'DSROMASAC\' + u_login u_loginFull,
		u_bks_estatus EstSup,
		u_sedes Sede
	From SrvSAP.Roma_Productiva.dbo.[@BKS_SUPERVISORES]
	Where u_tipo ='J'
	
	Union All
	Select Cast (74 as Smallint), '0074', 'AUGUSTO URIBE OCAÑA', 'EM43490441', 'a_uribe', 'DSROMASAC\a_uribe', 'I', ''
	Union All
	Select Cast (89 as Smallint), '0089', 'NAPA BERRIOS, JOSE MARTIN', 'PE42501550', 'j_napa', 'DSROMASAC\j_napa', 'I', ''
	Union All
	Select Cast (79 as Smallint), '0079', 'FUENTES MUÑANTE, JONY MARINO', 'EM21860138', 'j_fuentes', 'DSROMASAC\j_fuentes', 'I', ''
	Union All
	Select Cast (71 as Smallint), '0071', 'VALDEZ ALVAREZ, ROXANA MARGOT', 'EM41946977', 'r_valdez', 'DSROMASAC\r_valdez', 'I', ''
	Union All
	Select Cast (99 as Smallint), '0000', 'No Definido', '000000000', '', '', 'A' ,''

GO

