SELECT *
FROM portfolio_sql.dbo.Nashvillehousing

--Now seperate date from Saledate column

SELECT saledate, CONVERT(date, saledate)
FROM portfolio_sql.dbo.Nashvillehousing

Alter TABLE Nashvillehousing
ADD converteddates date

update Nashvillehousing
set converteddates = CONVERT(date, saledate) 

SELECT converteddates
FROM portfolio_sql.dbo.Nashvillehousing

Alter table Nashvillehousing
drop column date, dates

--Now we need to fill Null values in address column

SELECT *
FROM portfolio_sql.dbo.Nashvillehousing
where PropertyAddress is null

--There are 29 rows with null values

--Let see how we can fill these data
SELECT *
FROM portfolio_sql.dbo.Nashvillehousing
order by ParcelID

--Here We see some same parcel Id have but with different unique Id have property addresses.
--we will do self join

SELECT a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress
FROM portfolio_sql.dbo.Nashvillehousing a
JOIN portfolio_sql.dbo.Nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

SELECT a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolio_sql.dbo.Nashvillehousing a
JOIN portfolio_sql.dbo.Nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolio_sql.dbo.Nashvillehousing a
JOIN portfolio_sql.dbo.Nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID

--NOW we can check if tehre is null value in there

SELECT *
FROM portfolio_sql.dbo.Nashvillehousing
where PropertyAddress is null

--Next, WE are going to break PropertyAddress into city and state column

select*
From portfolio_sql.dbo.Nashvillehousing

Select PropertyAddress,
substring(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as address,
substring(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,len(PropertyAddress)) as city
From portfolio_sql.dbo.Nashvillehousing

Alter Table Nashvillehousing

ADD city varchar(255)


UPDATE portfolio_sql..Nashvillehousing
set city = substring(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,len(PropertyAddress)) 

Alter Table Nashvillehousing
ADD address varchar(255)

UPDATE portfolio_sql..Nashvillehousing
set address = substring(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) 

SELECT *
FROM Nashvillehousing


--Now its time to break OwnerAddress as well

SELECT OwnerAddress
FROM portfolio_sql..Nashvillehousing

select
parsename(Replace(OwnerAddress,',','.'),1), 
parsename(Replace(OwnerAddress,',','.'),2) ,
parsename(Replace(OwnerAddress,',','.'),3) 

FROM portfolio_sql..Nashvillehousing

Alter table portfolio_sql..Nashvillehousing
ADD Ownerstate varchar(255)

UPDATE portfolio_sql..Nashvillehousing
set OwnerState = parsename(Replace(OwnerAddress,',','.'),1)

 Alter table portfolio_sql..Nashvillehousing
 ADD OwnerCity varchar(255)
 UPDATE portfolio_sql..Nashvillehousing
set Ownercity = parsename(Replace(OwnerAddress,',','.'),2)

Alter table portfolio_sql..Nashvillehousing
 ADD OwnerAddresssplit varchar(255)
 UPDATE portfolio_sql..Nashvillehousing
set OwnerAddresssplit = parsename(Replace(OwnerAddress,',','.'),3)
 
 Select*
 FROM portfolio_sql..Nashvillehousing


 --Lets change Y andN to YES, No in soldasvacant column

SELECT soldasvacant
FROM portfolio_sql..Nashvillehousing

SELECT soldasvacant ,
CASE When soldasvacant = 'y' then 'yes'
When soldasvacant='N' then 'NO'
ELSE soldasvacant
END
FROM portfolio_sql..Nashvillehousing

update Nashvillehousing
SET soldasvacant= CASE When soldasvacant = 'y' then 'yes'
When soldasvacant='N' then 'NO'
ELSE soldasvacant
END


--Remove duplicates


 Select*
 FROM portfolio_sql..Nashvillehousing


 WITH rownumCTE as
 (select*, ROW_NUMBER()over(PARTITION BY ParcelID,PropertyAddress,SalePrice,
                                        Saledate,LegalReference ORDER BY UniqueID) rn
FROM portfolio_sql..Nashvillehousing)
DELETE
FROM rownumCTE
WHERE rn>1


select*
FROM portfolio_sql..Nashvillehousing