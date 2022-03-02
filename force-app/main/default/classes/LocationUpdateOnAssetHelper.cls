public with sharing class LocationUpdateOnAssetHelper{
	public static Asset LocationUpdateOnAssetHelperWithId(List<Asset> queriedToUpdate, List<Schema.Location> locationsWithAccounts , String serialnumber , String locationid ){
		Map<String, String> assetEquipmentKeyMap = new Map<String, String>();
		// map the asset id and asset equipmentkey
		for (Asset asset : queriedToUpdate){
			assetEquipmentKeyMap.put(asset.Equipment_Key__c, asset.Id);
		}
		//map the location id and account related to the location
		Map<String, String> locationandaccountmap = new Map<String, String>();
		for (Schema.Location Location : locationsWithAccounts){
			locationandaccountmap.put(Location.Id, Location.Account__c);
		}
		//Create the list of assets
		Asset tmp = new Asset();
		tmp.id = assetEquipmentKeyMap.get(serialnumber);
		tmp.LocationId = locationid ;
		// if the location has an account field, then update the asset with that account
		if (String.isNotBlank(locationandaccountmap.get(locationid))){
			tmp.AssetServicedById = locationandaccountmap.get(locationid);
		} else{
			tmp.AssetServicedById = null;
			tmp.Account_Treatment__c = null;
        }
        return tmp ;
	}

	/*     public static void LocationUpdateOnAssetHelperWithId(listString SerialNumber, String LocationId){
	//get the asset where equipmentkey is equal to the serial number
	 Asset[] Assetfromquery = AssetDAO.getAssetbyequipmentkey(SerialNumber);
	 if (Assetfromquery.size() > 0){
	 Asset Assettoupdate = Assetfromquery[0];
	 try {
	//get location using the location id
	 Schema.Location Locationtofind = LocationDAO.getLocationsFromlocationid(LocationId);
	// if the location has an account field, then update the asset with that account
	 if (String.isNotBlank(Locationtofind.Account__c)){
	 Assettoupdate.AccountId = Locationtofind.Account__c;
	 } else{
	 Assettoupdate.AssetServicedById = null;
	 Assettoupdate.Account_Treatment__c = null;
	 }
	//update the asset
	 update Assettoupdate;q
	 }
	 catch (Exception e) {
	 System.debug('An exception occurred: ' + e.getMessage());

	 }

	 }
	 } */
}