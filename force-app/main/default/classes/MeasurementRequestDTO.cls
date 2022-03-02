public class MeasurementRequestDTO {
    
    public class Measurement {
        public String correlationID;
        public String serializedItem;
        public String dateMeasurement;
        public String timezoneMeasurement;
        public String measure;
        public Decimal parameterValue;
    }

    public List<Measurement> measurementList;

    public static MeasurementRequestDTO parse(String json) {
        return (MeasurementRequestDTO) System.JSON.deserialize(json, MeasurementRequestDTO.class);
    }

    public MeasurementRequestDTO(Measurement__c measurement) {
        this.measurementList = new List<Measurement>();
        Measurement m = new Measurement();

        m.correlationID = measurement.Id; // External ID?
        m.serializedItem = measurement.Serialized_Item__r.Equipment_Key__c; 

        if(measurement.Date_Measurement__c != null) {
            m.dateMeasurement = measurement.Date_Measurement__c.formatGMT('dd/MM/yyyy HH.mm.ss');
        }
        
        m.timezoneMeasurement = 'GMT';
        m.measure = measurement.Measure__c;
        m.parameterValue = measurement.Parameter_1_Value__c;
        
        measurementList.add(m); 
    }
}