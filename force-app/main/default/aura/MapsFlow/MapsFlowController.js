({
    init: function (cmp, event, helper) {
        cmp.set('v.mapMarkers', [
            {
                location: {
                    Street: cmp.get("v.Street"),
                    City: cmp.get("v.City"),
                    State: cmp.get("v.State")
                },

                title: '',
                description: ''
            }
        ]);
        cmp.set('v.zoomLevel', 16);
    }
});