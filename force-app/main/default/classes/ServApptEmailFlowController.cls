public class ServApptEmailFlowController {

    // Instance of the flow
    public static Flow.Interview.Email_to_Patient_on_Service_Appointment emailToPatientFlow;
    public static String serviceAppointmentId;

    // Start method
    public static void start() {
        Map<String, Object> inputMap = new Map<String, Object>{'ServAppId' => serviceAppointmentId};

        emailToPatientFlow = new Flow.Interview.Email_to_Patient_on_Service_Appointment(inputMap);

        emailToPatientFlow.start();
    }
}