global class DatesResponseDTO {
    
    @InvocableVariable
    global Datetime startDate;

    @InvocableVariable
    global Datetime endDate;

    @InvocableVariable
    global Datetime dueDate;

    public DatesResponseDTO(Datetime startDate, Datetime endDate, Datetime dueDate) {
        this.startDate = startDate;
        this.endDate = endDate;
        this.dueDate = dueDate;
    }
}