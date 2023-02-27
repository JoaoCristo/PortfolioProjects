/*

Cleaning Data in SQL Queries

*/

Select *
From NashvilleHousing

------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

Alter TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

------------------------------------------------------------------------------------------------

--Populate Property Adress Data

Select *
From NashvilleHousing
--Where PropertyAddress is null
order by ParcelId

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, city,State)

Select PropertyAddress
From NashvilleHousing

SELECT 
SUBSTRING( PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING( PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address

From NashvilleHousing

Alter TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING( PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) 

Select *
From NashvilleHousing




Select OwnerAddress
From NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From NashvilleHousing

Alter TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

Alter TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2) 

Alter TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1) 

Select *
From NashvilleHousing

------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and NO in 'Sold as Vacant' field

Select Distinct(SoldasVacant), Count(SoldasVacant)
From NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END
From NashvilleHousing

UPDATE NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END

------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNUmCTE AS(
Select * ,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num

From NashvilleHousing
--order by ParcelID
)
--Delete
Select *
From RowNUmCTE
Where row_num > 1

------------------------------------------------------------------------------------------------

--Delete unused Columns

Select *
From NashvilleHousing

Alter TABLE NashvilleHousing
Drop COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter TABLE NashvilleHousing
Drop COLUMN SaleDate