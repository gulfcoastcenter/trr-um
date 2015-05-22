
if OBJECT_ID('trr_um_service_package_map') is not null
	drop table trr_um_service_package_map
go

if OBJECT_ID('trr_um_service_sac_map') is not null
	drop table trr_um_service_sac_map
go

if object_id('trr_um_service_type') is not null
   drop table trr_um_service_type
go

if object_id('trr_um_service') is not null
   drop table trr_um_service
go

if object_id('trr_um_service_unit_type') is not null
   drop table trr_um_service_unit_type
go

if OBJECT_ID('trr_um_service_package') is not null
	drop table trr_um_service_package
go


create table trr_um_service_type (
   ServiceTypeId int identity (1,1),
   Name nvarchar(255),
   constraint PK_ServiceType_ID primary key clustered ( [ServiceTypeId] asc )
)
go

create table trr_um_service_unit_type (
	ServiceUnitTypeId int identity (1,1),
	Name nvarchar(255),
	constraint PK_ServiceUnitType_ID primary key clustered ( [ServiceUnitTypeId] asc )
)
go

create table trr_um_service (
   ServiceId int identity (1,1),
   Name nvarchar(255),
   UnitType int,
   ValuePerUnit float,
   constraint PK_Service_ID primary key clustered ([ServiceID] asc ),
   constraint FK_UnitType_ID foreign key (UnitType) references trr_um_service_unit_type(ServiceUnitTypeId)
)
go   

create table trr_um_service_package (
	ServicePackageId int identity (1,1),
	Code int,
	Name nvarchar(255),
	EffectiveDate datetime,
	ExpirationDate datetime,
	constraint PK_ServicePackage_ID primary key clustered ([ServicePackageId] asc)
)
go

create table trr_um_service_sac_map (
	ServiceMapId int identity (1,1),
	ServiceId int,
	ServiceActivityCode int,
	constraint PK_ServiceMap_ID primary key clustered ([ServiceMapId] asc),
	--constraint FK_SAC foreign key (ServiceActivityCode) references Sysfile.SAC(SAC),
	constraint FK_Service_ID foreign key (ServiceId) references trr_um_service(ServiceId)
)
go

create table trr_um_service_package_map (
	ServicePackageMapId int identity (1,1),
	ServiceTypeId int,
	ServicePackageId int,
	ServiceId int,
	StandardUnits int,
	HighNeedUnits int,
	constraint PK_ServicePackageMap_ID primary key clustered ([ServicePackageMapId] asc),
	constraint FK_ServiceType_ID foreign key (ServiceTypeId) references trr_um_service_type(ServiceTypeId),
	constraint FK_ServicePackage_ID foreign key (ServicePackageId) references trr_um_service_package(ServicePackageId),
)
go

insert into trr_um_service_type values ('CORE')
insert into trr_um_service_type values ('ADJUNCT')

insert into trr_um_service_unit_type values ('HOURS')
insert into trr_um_service_unit_type values ('EVENT')
insert into trr_um_service_unit_type values ('DOLLARS')

insert into trr_um_service_package values (101, 'Level of Care 1', '9/1/2014', '8/31/2015')

insert into trr_um_service values ('Psychiatric Diagnostic INterview Examination', 2, 1)

insert into trr_um_service_sac_map values (1, 1500)
insert into trr_um_service_sac_map values (1, 1501)

insert into trr_um_service_package_map values (1, 1, 1, 0, 1)

select * from trr_um_service_type
select * from trr_um_service_unit_type
select * from trr_um_service_package
select * from trr_um_service
select * from trr_um_service_sac_map
select spm.ServicePackageMapId, spm.ServicePackageId, sp.Name, spm.ServiceTypeId, st.Name, spm.ServiceId, s.Name, spm.StandardUnits, spm.HighNeedUnits
from trr_um_service_package_map spm
join trr_um_service_package sp
  on spm.ServicePackageId = sp.ServicePackageId
join trr_um_service_type st
  on st.ServiceTypeId = spm.ServiceTypeId
join trr_um_service s
  on s.ServiceId = spm.ServiceId