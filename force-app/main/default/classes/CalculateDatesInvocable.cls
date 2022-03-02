global class CalculateDatesInvocable {

    @InvocableMethod
    public static List<DatesResponseDTO> calculateDatesInvocable(List<CalculateDatesRequest> inputList) {

        List<DatesResponseDTO> dtoList = new List<DatesResponseDTO>();
        CalculateDatesRequest request = inputList[0];

        Datetime startDateTime = request.startDateTime;
        Decimal maxTime = request.maxTime;
        String maxTimeUnitOfMeasure = request.maxTimeUnitOfMeasure;
        String maxTimeCalculationMode = request.maxTimeCalculationMode;
        Decimal offsetStartDateTime = request.offsetStartDateTime;
        Decimal offsetEndDateTime = request.offsetEndDateTime;
        String offsetUnitOfMeasure = request.offsetUnitOfMeasure;
        String offsetCalculationMode = request.offsetCalculationMode;
        BusinessHours businessHoursRecord = request.businessHoursRecord;

        DatesResponseDTO dto = ATMainComponentService.calculateDates(
            startDateTime, 
            maxTime, 
            maxTimeUnitOfMeasure, 
            maxTimeCalculationMode, 
            offsetStartDateTime, 
            offsetEndDateTime, 
            offsetUnitOfMeasure, 
            offsetCalculationMode,
            businessHoursRecord,
            false
        );

        dtoList.add(dto);

        return dtoList;
    }

    global class CalculateDatesRequest {

        @InvocableVariable
        global Datetime startDateTime;

        @InvocableVariable
        global Decimal maxTime;

        @InvocableVariable
        global String maxTimeUnitOfMeasure;

        @InvocableVariable
        global String maxTimeCalculationMode;

        @InvocableVariable
        global Decimal offsetStartDateTime;

        @InvocableVariable
        global Decimal offsetEndDateTime;

        @InvocableVariable
        global String offsetUnitOfMeasure;

        @InvocableVariable
        global String offsetCalculationMode;

        @InvocableVariable
        global BusinessHours businessHoursRecord;

        public CalculateDatesRequest(Datetime startDateTime, Decimal maxTime, String maxTimeUnitOfMeasure, String maxTimeCalculationMode,
        Decimal offsetStartDateTime, Decimal offsetEndDateTime, String offsetUnitOfMeasure, String offsetCalculationMode, BusinessHours businessHoursRecord) {
            this.startDateTime = startDateTime;
            this.maxTime = maxTime;
            this.maxTimeUnitOfMeasure = maxTimeUnitOfMeasure;
            this.maxTimeCalculationMode = maxTimeCalculationMode;
            this.offsetStartDateTime = offsetStartDateTime;
            this.offsetEndDateTime = offsetEndDateTime;
            this.offsetUnitOfMeasure = offsetUnitOfMeasure;
            this.offsetCalculationMode = offsetCalculationMode;
            this.businessHoursRecord = businessHoursRecord;
        }

        public CalculateDatesRequest() {
            
        }
    }
}