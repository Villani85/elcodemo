({
    init : function(component, event, helper) {
        // Ottieni recordId (Account) e flow component
        var recordId = component.get("v.recordId");
        var flow = component.find("flowCmp");

        // Prepara input variables per il flow
        var inputVariables = [
            {
                name: "recordId",
                type: "String",
                value: recordId
            }
        ];

        // Avvia il flow PCB_Configuratore con recordId
        flow.startFlow("PCB_Configuratore", inputVariables);
    },

    onStatusChange : function(component, event, helper) {
        var status = event.getParam("status");

        // Chiudi la Quick Action modal quando il flow finisce
        if (status === "FINISHED" || status === "FINISHED_SCREEN") {
            var closeEvt = $A.get("e.force:closeQuickAction");
            if (closeEvt) {
                closeEvt.fire();
            }
        }
    }
})
