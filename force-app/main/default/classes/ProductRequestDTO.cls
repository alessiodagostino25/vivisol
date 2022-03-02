public class ProductRequestDTO {
	
	public String outboundDeliveryNumber;
	public String destinationLocationId;
	public String ownerId;

	public static ProductRequestDTO parse(String json) {
		return (ProductRequestDTO) System.JSON.deserialize(json, ProductRequestDTO.class);
	}

	public ProductRequestDTO(ProductRequest productRequest) {
		this.outboundDeliveryNumber = productRequest.Outbound_Delivery_Number__c;
		if (productRequest.Partner_Function__c == 'Z1' && productRequest.Account != null){
			this.destinationLocationId = productRequest.Account.Account_External_Id__c;
		} else{
			this.destinationLocationId = productRequest.DestinationLocation.Location_Id__c;
		}
		this.ownerId = productRequest.BPResource__c;
	}
}