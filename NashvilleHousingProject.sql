SELECT *
FROM [NashvilleHousingProject]..NashvilleHousing
Order by 1

----------------------------------------------------------------------------------------------------------------------------------
-----------------Standardize Date Format-------------------------
----------------------------------------------------------------------------------------------------------------------------------
SELECT SaleDateConverted, CONVERT(date,SaleDate) as SaleDateConverted2
FROM [NashvilleHousingProject]..NashvilleHousing
Order by 2 DESC

ALTER TABLE [NashvilleHousingProject]..NashvilleHousing
Add SaleDateConverted date;

Update [NashvilleHousingProject]..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



----------------------------------------------------------------------------------------------------------------------------------
-----------------Populate Property Address Data-------------------------
----------------------------------------------------------------------------------------------------------------------------------
SELECT *
FROM [NashvilleHousingProject]..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

--Make a SelfJoin table
--ISNULL used to populate aPropertyAddress
SELECT a.ParcelID as aParcelID, a.PropertyAddress as aPropertyAddress, b.ParcelID as bParcelID, b.PropertyAddress as bPropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [NashvilleHousingProject]..NashvilleHousing a
JOIN [NashvilleHousingProject]..NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [NashvilleHousingProject]..NashvilleHousing a
JOIN [NashvilleHousingProject]..NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


----------------------------------------------------------------------------------------------------------------------------------
-----------------Breaking out Address into Individual Columns (Street, City, State)-------------------------
----------------------------------------------------------------------------------------------------------------------------------

SELECT PropertyAddress
FROM [NashvilleHousingProject]..NashvilleHousing
 
--Use SUBSTRING to Split Address
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as PropertyStreetAddress 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as PropertyCityAddress 
FROM [NashvilleHousingProject]..NashvilleHousing

ALTER TABLE [NashvilleHousingProject]..NashvilleHousing
Add PropertyStreetAddress nvarchar(255);

Update [NashvilleHousingProject]..NashvilleHousing
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)



ALTER TABLE [NashvilleHousingProject]..NashvilleHousing
Add PropertyCityAddress nvarchar(255);

Update [NashvilleHousingProject]..NashvilleHousing
SET PropertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select *
FROM [NashvilleHousingProject]..NashvilleHousing

Select OwnerAddress
FROM [NashvilleHousingProject]..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) as OwnerStreetAddress
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) as OwnerCityAddress
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) as OwnerStateAddress
FROM [NashvilleHousingProject]..NashvilleHousing


ALTER TABLE [NashvilleHousingProject]..NashvilleHousing
Add OwnerStreetAddres nvarchar(255);

Update [NashvilleHousingProject]..NashvilleHousing
SET OwnerStreetAddres = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)


ALTER TABLE [NashvilleHousingProject]..NashvilleHousing
Add OwnerCityAddress nvarchar(255);

Update [NashvilleHousingProject]..NashvilleHousing
SET OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)


ALTER TABLE [NashvilleHousingProject]..NashvilleHousing
Add OwnerStateAddress nvarchar(255);

Update [NashvilleHousingProject]..NashvilleHousing
SET OwnerStateAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)



----------------------------------------------------------------------------------------------------------------------------------
-----------------Change Y & N to Yes & No in the SoldAsVacant Field-------------------------
----------------------------------------------------------------------------------------------------------------------------------

SELECT SoldAsVacant, Count(SoldAsVacant)
FROM [NashvilleHousingProject]..NashvilleHousing
Group by SoldAsVacant


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [NashvilleHousingProject]..NashvilleHousing

Update [NashvilleHousingProject]..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END




----------------------------------------------------------------------------------------------------------------------------------
-----------------Remove Duplicates-------------------------
----------------------------------------------------------------------------------------------------------------------------------

Select *
FROM [NashvilleHousingProject]..NashvilleHousing;


WITH CTE_RowNum as (
Select *, 
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID, 
               PropertyAddress,
			   SaleDate,
			   SalePrice,
			   LegalReference
			   ORDER BY UniqueID
			   ) row_num
			 
FROM [NashvilleHousingProject]..NashvilleHousing
--Order by ParcelID
)

--SELECT *
--From CTE_RowNum
--Where row_num > 1
--Order By PropertyAddress

DELETE
From CTE_RowNum
Where row_num > 1




----------------------------------------------------------------------------------------------------------------------------------
-----------------Delete UnUsed Columns-------------------------
----------------------------------------------------------------------------------------------------------------------------------

Select *
FROM [NashvilleHousingProject]..NashvilleHousing;

ALTER TABLE [NashvilleHousingProject]..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate