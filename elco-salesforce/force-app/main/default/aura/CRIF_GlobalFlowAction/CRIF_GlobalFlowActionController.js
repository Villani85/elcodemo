({
    init : function(component, event, helper) {
        var flow = component.find("flow");
        // avvia il Flow (nessun input)
        flow.startFlow("CRIF_NEW_da_PIVA");
    },

    onStatusChange : function(component, event, helper) {
        var status = event.getParam("status");
        // Se vuoi NON chiudere la modale, commenta queste righe
        if (status === "FINISHED" || status === "FINISHED_SCREEN") {
            var closeEvt = $A.get("e.force:closeQuickAction");
            if (closeEvt) closeEvt.fire();
        }
    }
})
