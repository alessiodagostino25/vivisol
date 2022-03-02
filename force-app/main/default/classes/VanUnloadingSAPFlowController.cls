public class VanUnloadingSAPFlowController {
    // Instance of the flow
    public static Flow.Interview.VanUnloadingFromSAPOrchestrator vanUnloadingSAPFlow;
    public static String productRequestId;

    // Start method
    public static void start() {
        Map<String, Object> inputMap = new Map<String, Object>{'Id' => productRequestId};

        vanUnloadingSAPFlow = new Flow.Interview.VanUnloadingFromSAPOrchestrator(inputMap);

        vanUnloadingSAPFlow.start();
    }
}