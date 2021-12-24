--Cleaning data in SQL queries

SELECT *
FROM dbo.[Nashville Housing]


--Standardize Date Format


SELECT SaleDate, CONVERT(date, SaleDate) AS Converted_SaleDate
FROM PortfolioProject.dbo.[Nashville Housing]

ALTER TABLE [Nashville Housing]
ALTER COLUMN SaleDate Date;

-- Populate Property Address Data

--SELECT PropertyAddress

SELECT *
FROM PortfolioProject.dbo.[Nashville Housing]
where PropertyAddress is NULL
order by UniqueID


SELECT a.ParcelID, a.PropertyAddress,  b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.[Nashville Housing] a
JOIN PortfolioProject.dbo.[Nashville Housing] b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.[Nashville Housing] a
JOIN PortfolioProject.dbo.[Nashville Housing] b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

-- Breaking out Address into individual column (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.[Nashville Housing]
--where PropertyAddress is NULL
--order by UniqueID

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.[Nashville Housing]


ALTER TABLE [Nashville Housing]
ADD PropertySplitAddress Nvarchar(255);

UPDATE [Nashville Housing]
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE [Nashville Housing]
ADD PropertySplitCity Nvarchar(255);

UPDATE [Nashville Housing]
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM [Nashville Housing]

--------------------------------------------
SELECT OwnerAddress
FROM [Nashville Housing]

SELECT 
PARSENAME(REPLACE (OwnerAddress,',', '.' ), 3) as OwnerSplitAddress,
PARSENAME(REPLACE (OwnerAddress,',', '.' ), 2) as OwnerSplitCity,
PARSENAME(REPLACE (OwnerAddress,',', '.' ), 1) as OwnerSplitState
FROM [Nashville Housing]

ALTER TABLE [Nashville Housing]
ADD OwnerSplitAddress Nvarchar(255);

UPDATE [Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE (OwnerAddress,',', '.' ), 3)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitCity Nvarchar(255);

UPDATE [Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE (OwnerAddress,',', '.' ), 2)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitState Nvarchar(255);

UPDATE [Nashville Housing]
SET OwnerSplitState = PARSENAME(REPLACE (OwnerAddress,',', '.' ), 1)


SELECT *
FROM [Nashville Housing]

---------------------------------------------------------

--Change Y and N to Yes and No in 'Sold as Vacant' Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Nashville Housing]
GROUP BY (SoldAsVacant)
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' then 'YES'
     WHEN SoldAsVacant = 'N' then 'NO'
     ELSE SoldAsVacant
     END
FROM [Nashville Housing]

UPDATE [Nashville Housing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' then 'YES'
     WHEN SoldAsVacant = 'N' then 'NO'
     ELSE SoldAsVacant
     END

----------------------------------------

--REMOVE DUPLICATES

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress, 
			 SaleDate,
			 SalePrice,
			 LegalReference
			 ORDER BY UniqueID)
			 row_num

FROM [Nashville Housing]
--ORDER BY ParcelID
)
--DELETE
--FROM RowNumCTE
--WHERE row_num > 1


SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

---------------------------------------------------

--DELETE UNUSED COLUMN

SELECT *
FROM [Nashville Housing]

ALTER TABLE [Nashville Housing]
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

