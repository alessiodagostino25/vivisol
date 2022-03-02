public class AccountTreatmentAddressDTO {
    
    @AuraEnabled
    public String Id { get; set; }
    @AuraEnabled
    public String locationName { get; set; }
    @AuraEnabled
    public String addressType { get; set; }
    @AuraEnabled
    public String address { get; set; }
    @AuraEnabled
    public Date startDate { get; set; }
    @AuraEnabled
    public Date endDate { get; set; }
    @AuraEnabled
    public Boolean isDefault { get; set; }

    public AccountTreatmentAddressDTO(String Id, String locationName, String addressType, String address, Date startDate, Date endDate, Boolean isDefault) {
        this.Id = Id;
        this.locationName = locationName;
        this.addressType = addressType;
        this.address = address;
        this.startDate = startDate;
        this.endDate = endDate;
        this.isDefault = isDefault;
    }

}