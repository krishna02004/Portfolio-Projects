/*

Cleaning Data in SQL queries

*/

SELECT * 
FROM PortfolioProject2.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT (Date,SaleDate)
FROM PortfolioProject2.dbo.NashvilleHousing

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM PortfolioProject2.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject2.dbo.NashvilleHousing AS a
JOIN PortfolioProject2.dbo.NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject2.dbo.NashvilleHousing AS a
JOIN PortfolioProject2.dbo.NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into  Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject2.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT SUBSTRING(PropertyAddress, 1 , CHARINDEX(',' , PropertyAddress) -1) as Address ,
       SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1, len(PropertyAddress)) as Address
FROM  PortfolioProject2.dbo.NashvilleHousing


ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',' , PropertyAddress) -1)

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1, len(PropertyAddress))


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Another method of splitting through ParseName now using Owner Address

SELECT PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
       PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
       PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
From PortfolioProject2.dbo.NashvilleHousing

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET OwnerSplitState =    PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject2.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 

SELECT SoldAsVacant,
   CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END
FROM PortfolioProject2.dbo.NashvilleHousing

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET SoldAsVacant =    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates 
WITH RowNUMCTE AS(
SELECT * ,
ROW_NUMBER() OVER( PARTITION BY  ParcelID, Propertyaddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueId) row_num
FROM PortfolioProject2.dbo.NashvilleHousing
--ORDERBY ParcelID
)
DELETE
FROM RowNUMCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


SELECT *
FROM RowNUMCTE
WHERE row_num > 1
ORDER BY PropertyAddress

---------------------------------------------------------------------------------------------------------------------------------

-- Delete unused columns

SELECT * 
FROM PortfolioProject2.dbo.NashvilleHousing

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
DROP COLUMN SaleDate 











