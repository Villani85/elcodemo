public with sharing class CrifCoreRefreshInvocable {

    public class Request {
        @InvocableVariable(required=true label='Account ID' description='ID dell Account da aggiornare')
        public String accountId;
    }

    public class Response {
        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Error Message')
        public String errorMessage;
    }

    @InvocableMethod(
        label='CRIF - Core Refresh Wrapper'
        description='Wrapper per invocare CRIF_Core_Refresh flow da Screen Flow'
        category='CRIF Integration'
    )
    public static List<Response> refreshAccount(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for (Request req : requests) {
            Response resp = new Response();

            try {
                // Prepare flow input
                Map<String, Object> flowInputs = new Map<String, Object>();
                flowInputs.put('recordId', req.accountId);

                // Invoke autolaunched flow
                Flow.Interview crifFlow = new Flow.Interview.CRIF_Core_Refresh(flowInputs);
                crifFlow.start();

                // Get flow outputs
                resp.success = (Boolean) crifFlow.getVariableValue('success');
                resp.errorMessage = (String) crifFlow.getVariableValue('errorMessage');

            } catch (Exception e) {
                resp.success = false;
                resp.errorMessage = e.getMessage();
            }

            responses.add(resp);
        }

        return responses;
    }
}
