if object_id('trr_um_service_type') is not null
   drop table trr_um_service_type
go

create table trr_um_service_type (
   ServiceTypeId int identity (1,1),
   Name nvarchar(255),
   constraint primary key 'PK_ServiceType_ID' clustered ( asc )
)

