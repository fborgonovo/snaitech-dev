USE [dipendenti]
GO

/****** Object:  Table [dbo].[dipendentiAD]    Script Date: 17/02/2020 20:19:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [test].[dipendentiAD](
	[id_dipendente] [int] IDENTITY(1,1) PRIMARY KEY,
	[samAccountName] [varchar](255) NULL,
	[dataCreazione] [nvarchar](50) NULL,
	[mailResp] [nvarchar](50) NULL,
	[codAzienda] [tinyint] NULL,
	[codDipendente] [smallint] NULL,
	[cognome] [nvarchar](50) NULL,
	[nome] [nvarchar](50) NULL,
	[mail] [nvarchar](50) NULL,
	[id_reparto] [int] NULL,
	[id_squadra] [int] NULL,
	[id_divisione] [int] NULL,
	[id_mansione] [int] NULL,
	[codBU] [smallint] NULL,
	[codRespStringa] [nvarchar](50) NULL,
	[samResp] [nvarchar](50) NULL,
	[codAzResp] [tinyint] NULL,
	[codDipResp] [smallint] NULL,
	[id_avatar] [nvarchar](4) NULL,
	[dataAssunzione] [date] NULL,
	[dataNascita] [date] NULL,
	[inquadramento] [nvarchar](1) NULL,
	[unitaLocale] [int] NULL,
	[unitaProduttiva] [int] NULL,
	[cellulare] [nvarchar](50) NULL,
	[interno] [nvarchar](50) NULL,
	[sede] [nvarchar](255) NULL,
	[Azienda] [varchar](255) NULL,
	[Reparto] [varchar](255) NULL,
	[Squadra] [varchar](255) NULL,
	[Divisione] [varchar](255) NULL,
	[Mansione] [varchar](255) NULL,
	[Thumbnailphoto] [varchar](255) NULL,
	[customAttribute6] [varchar](255) NULL,
	[gruppoSPOwner] [varchar](255) NULL,
	[gruppoSPReader] [varchar](255) NULL
) ON [PRIMARY]
GO


