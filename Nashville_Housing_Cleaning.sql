/* Cleaning data in SQL Queries */



CREATE table nashvillehousing(
"UniqueID " VARCHAR primary KEY,
ParcelID VARCHAR,
LandUse VARCHAR,
PropertyAddress VARCHAR,
SaleDate date,
SalePrice NUMERIC,
LegalReference VARCHAR,
SoldAsVacant VARCHAR,
OwnerName VARCHAR,
OwnerAddress VARCHAR,
Acreage NUMERIC,
TaxDistrict VARCHAR,
LandValue NUMERIC,
BuildingValue NUMERIC,
TotalValue NUMERIC,
YearBuilt NUMERIC,
Bedrooms NUMERIC,
FullBath NUMERIC,
HalfBath NUMERIC
);

update nashvillehousing set ownername=null where ownername='';
update nashvillehousing set owneraddress=null where owneraddress='';
update nashvillehousing set taxdistrict=null where taxdistrict='';
update nashvillehousing set propertyaddress=null where propertyaddress='';

select count (*) from nashvillehousing

select * from nashvillehousing



/* Populate property address data */


select * from nashvillehousing 
/*where propertyaddress is null */
order by parcelid

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, coalesce(a.propertyaddress,b.propertyaddress)  
from nashvillehousing a
join nashvillehousing b
	on a.parcelid = b.parcelid 
	and a."UniqueID " <> b."UniqueID "
where a.propertyaddress is null 	


update nashvillehousing c 
set propertyaddress = coalesce(a.propertyaddress, b.propertyaddress)
from nashvillehousing a
join nashvillehousing b
	on a.parcelid = b.parcelid 
	and a."UniqueID " <> b."UniqueID "
where a.propertyaddress is null and c."UniqueID " = a."UniqueID " 


/* Breaking out address into individual columns (Address, city, state) */


select propertyaddress 
from nashvillehousing 
/*where propertyaddress is null*/
/*order by parcelid*/ 

select 
substring(propertyaddress, 1, strpos(propertyaddress, ',') -1 ) as address

from nashvillehousing 

select 
substring(propertyaddress, 1, strpos(propertyaddress, ',') -1 ) as address
, substring(propertyaddress, strpos(propertyaddress, ',') + 1 , length(PropertyAddress)) as address
from nashvillehousing 

alter table nashvillehousing
add propertysplitaddress varchar(255);

update nashvillehousing
set propertysplitaddress = substring(PropertyAddress, 1, strpos(propertyaddress, ',') -1 )


alter table nashvillehousing
add propertysplitcity varchar(255);

update nashvillehousing
set propertysplitcity = SUBSTRING(propertyaddress, strpos(propertyaddress, ',') + 1 , length(propertyaddress))




select * 
from nashvillehousing 


select owneraddress  
from nashvillehousing 

select
split_part(owneraddress, ',', 1),
split_part(owneraddress, ',', 2),
split_part(owneraddress, ',', 3)
from nashvillehousing


alter table nashvillehousing
add ownershipsplitaddress varchar(255);

update nashvillehousing
set ownershipsplitaddress = split_part(owneraddress, ',', 1)


alter table nashvillehousing
add ownershipsplitcity varchar(255);

update nashvillehousing
set ownershipsplitcity = split_part(owneraddress, ',', 2)

alter table nashvillehousing
add ownershipsplitstate varchar(255);

update nashvillehousing
set ownershipsplitstate = split_part(owneraddress, ',', 3)


select * 
from nashvillehousing



/* Change Y and N in Soldasvacant */



select distinct(soldasvacant), count(soldasvacant)
from nashvillehousing
group by soldasvacant 
order by 2



select soldasvacant
, case when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	end
from nashvillehousing 


update nashvillehousing 
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	end



/* Identify duplicates */
	

with tmp as(
select *,
	row_number() over (
	partition by parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by
					"UniqueID "
					) row_num

from nashvillehousing 
)
select *
from tmp
where row_num > 1
order by propertyaddress



/* delete unused columns */



select *
from nashvillehousing 

alter table nashvillehousing 
drop column if exists owneraddress,
drop column if exists taxdistrict,
drop column if exists propertyaddress,
drop column if exists saledate;



