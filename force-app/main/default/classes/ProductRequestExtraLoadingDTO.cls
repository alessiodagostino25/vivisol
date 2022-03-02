public class ProductRequestExtraLoadingDTO {
    
    public ProductRequestClass productRequest;
    public List<ProductRequestLineItemClass> productRequestLineItem;

    public class ProductRequestClass {
        public String productRequestNumber;
        public String destinationLocation;
        public String sapStorageLocation;
        public String sapPlant;
        public String sourceLocation; //Sul file di mapping è sourceLocationId, mentre Caroline ha scritto sourceLocation
        public String loadingPlant;
        public String owner;
    }

    public class ProductRequestLineItemClass {
        public String product2Id;
        public String batchNumber;
        public String serialNumber;
        public Decimal loadedQuantity; //Decimal?
    }

    public static ProductRequestExtraLoadingDTO parse(String json) {
		return (ProductRequestExtraLoadingDTO) System.JSON.deserialize(json, ProductRequestExtraLoadingDTO.class);
    }

    public ProductRequestExtraLoadingDTO(ProductRequest pr, List<ProductRequestLineItem> lineItems) {
        // Product Request
        this.productRequest = new ProductRequestClass();

        productRequest.productRequestNumber = pr.ProductRequestNumber; //?
        productRequest.destinationLocation = pr.DestinationLocation.Location_Id__c;
        productRequest.sapStorageLocation = pr.SAP_Storage_Location__r.Location_Id__c;
        productRequest.sapPlant = pr.SAP_Plant__r.Location_Id__c;
        productRequest.sourceLocation = pr.SourceLocation.Location_Id__c;
        productRequest.loadingPlant = pr.Loading_Plant__r.Location_Id__c;
        productRequest.owner = pr.BPResource__c;

        //Product Request Line Items
        this.productRequestLineItem = new List<ProductRequestLineItemClass>();

        if(lineItems != null) {
            for(ProductRequestLineItem lineItem : lineItems) {
                ProductRequestLineItemClass prli = new ProductRequestLineItemClass();

                prli.product2Id = lineItem.Product2.Product_Code__c;
                prli.batchNumber = lineItem.Batch_Number__c;
                prli.serialNumber = lineItem.Serial_Number__c;
                prli.loadedQuantity = lineItem.Loaded_Quantity__c;

                productRequestLineItem.add(prli);
            }
        }
    }
}