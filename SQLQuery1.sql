/* 
Cleaning Data in SQL Queries
*/

Select * from [dbo].[DataCleaning]

-- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From [dbo].[DataCleaning]

Update [dbo].[DataCleaning]
Set SaleDate = CONVERT(Date,SaleDate)

-- Populate Property Address date

Select *
From [dbo].[DataCleaning]
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [dbo].[DataCleaning] a
JOIN [dbo].[DataCleaning] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [dbo].[DataCleaning] a
JOIN [dbo].[DataCleaning] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From [dbo].[DataCleaning]
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From [dbo].[DataCleaning]


ALTER TABLE [dbo].[DataCleaning]
Add PropertySplitAddress Nvarchar(255);

Update [dbo].[DataCleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE [dbo].[DataCleaning]
Add PropertySplitCity Nvarchar(255);

Update [dbo].[DataCleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From [dbo].[DataCleaning] 

Select OwnerAddress
From [dbo].[DataCleaning]

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [dbo].[DataCleaning]



ALTER TABLE [dbo].[DataCleaning]
Add OwnerSplitAddress Nvarchar(255);

Update [dbo].[DataCleaning]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [dbo].[DataCleaning]
Add OwnerSplitCity Nvarchar(255);

Update [dbo].[DataCleaning]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE [dbo].[DataCleaning]
Add OwnerSplitState Nvarchar(255);

Update [dbo].[DataCleaning]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [dbo].[DataCleaning]
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [dbo].[DataCleaning]


Update [dbo].[DataCleaning]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [dbo].[DataCleaning]
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From [dbo].[DataCleaning]

-- Delete Unused Columns

ALTER TABLE [dbo].[DataCleaning]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From [dbo].[DataCleaning]
