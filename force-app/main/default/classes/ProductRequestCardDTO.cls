public class ProductRequestCardDTO {
    @AuraEnabled
    public String Id {get; set;}
    @AuraEnabled
    public String productRequestNumber {get; set;}
    @AuraEnabled
    public String sourceLocationId {get; set;}
    @AuraEnabled
    public String sourceLocationName {get; set;}
    @AuraEnabled
    public String destinationLocationId {get; set;}
    @AuraEnabled
    public String destinationLocationName {get; set;}
    @AuraEnabled
    public Datetime needByDate {get; set;}
    @AuraEnabled
    public String outboundDeliveryNumber {get; set;}
    @AuraEnabled
    public String ownerId {get; set;}

    public ProductRequestCardDTO(String Id, String productRequestNumber, String sourceLocationId, String sourceLocationName, String destinationLocationId,
    String destinationLocationName, Datetime needByDate, String outboundDeliveryNumber, String ownerId) {
        this.Id = Id;
        this.productRequestNumber = productRequestNumber;
        this.sourceLocationId = sourceLocationId;
        this.sourceLocationName = sourceLocationName;
        this.destinationLocationId = destinationLocationId;
        this.destinationLocationName = destinationLocationName;
        this.needByDate = needByDate;
        this.outboundDeliveryNumber = outboundDeliveryNumber;
        this.ownerId = ownerId;
    }
}