SELECT * 
FROM PortfolioProject1..NashvilleHousing

-- Standardize Date Format
SELECT SaleDateCoverted, CONVERT(DATE, SaleDate)
FROM PortfolioProject1..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate) 

ALTER TABLE NashvilleHousing
Add SaleDateCoverted Date; 

UPDATE NashvilleHousing
SET SaleDateCoverted = CONVERT(Date, SaleDate) 

-------------------------------------------------------

-- Populate Property Address Data 

SELECT *
FROM PortfolioProject1..NashvilleHousing
WHERE PropertyAddress Is Null 
--WHERE PropertyAddress is null
ORDER BY ParcelID 
-- Here we find if the ParcelID belongs to a specific Address 
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject1..NashvilleHousing a
JOIN PortfolioProject1..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is Null 

--We have found that a specific ParcelID belongs to specific addres, now we must add that to our table. We use Isnull(column a (if it is null then), Column b(what is placed))
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject1..NashvilleHousing a
JOIN PortfolioProject1..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is Null 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject1..NashvilleHousing a
JOIN PortfolioProject1..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is Null 

-- Breaking out address into individual columns ( address, city, state)

SELECT PropertyAddress
FROM PortfolioProject1..NashvilleHousing
WHERE PropertyAddress Is Null 
--WHERE PropertyAddress is null
--ORDER BY ParcelID 

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) AS address
FROM PortfolioProject1..NashvilleHousing 

--# This query is looking at the PropertyAddress column starting with the first character and going to the comma, giving us the street address only. -THe minus one
-- at the end of the CHARINDEX query is deleting the comma.

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) AS address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject1..NashvilleHousing 
-- this second queury will add the city column. Now we need to add these to the table officially 

ALTER TABLE PortfolioProject1..NashvilleHousing
Add PropertySplitAddress Nvarchar(255); 

UPDATE PortfolioProject1..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) 


ALTER TABLE PortfolioProject1..NashvilleHousing
Add PropertySplitCity Nvarchar(255); 


UPDATE PortfolioProject1..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress))

-- City and Address split columns have been added at the end of table. 


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 
FROM PortfolioProject1..NashvilleHousing

-- This is an easier way to split the values from the address than substring

ALTER TABLE PortfolioProject1..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255); 

UPDATE PortfolioProject1..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE PortfolioProject1..NashvilleHousing
Add OwnerSplitCity Nvarchar(255); 


UPDATE PortfolioProject1..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject1..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject1..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Change Y and N to Yes and No in "Sold As Vacant" column. 

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject1..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No' 
		 ELSE SoldAsVacant END 
From PortfolioProject1..NashvilleHousing

Update  PortfolioProject1..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No' 
		 ELSE SoldAsVacant END 

--------------------------------------------------
-- Remove Duplicates 

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
				ORDER BY UniqueID) row_num 
FROM PortfolioProject1..NashvilleHousing)
--ORDER BY ParcelID
SELECT *   
FROM RowNumCTE
WHERE row_num > 1

--Delete unused columns 

SELECT * 
FROM PortfolioProject1..NashvilleHousing

ALTER TABLE PortfolioProject1..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress 


ALTER TABLE PortfolioProject1..NashvilleHousing
DROP COLUMN SaleDate




