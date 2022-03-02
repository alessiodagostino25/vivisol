({
    init: function (cmp, event, helper) {

        console.log("RecordLIST####" + cmp.get("v.ServiceTerritoryList"));
        console.log('init');
        
       	var mapMarkers = [];
        var serviceTerritories = cmp.get("v.ServiceTerritoryList");
        
        for (var i = 0; i < serviceTerritories.length; i++) {
            var st = serviceTerritories[i];
            var marker = {
                'location': {
                    'Street': st.Street,
                    'City': st.City,
                    'Country': st.Country
                },
                
                value: st.Id,
                icon: 'custom:custom26',
                title: st.Name
            };
            mapMarkers.push(marker);
        };
        var locationMarkers={
            'location': {
                    'Street': cmp.get("v.workOrderStreet"),
                    'City': cmp.get("v.workOrderCity"),
                    'Country': cmp.get("v.workOrderCountry")
                },
                
                icon: 'standard:location',
                title: 'Patient Home'
            };
            mapMarkers.push(locationMarkers);
 
        cmp.set('v.mapMarkers', mapMarkers);
    },

    handleMarkerSelect: function (cmp, event, helper) {
        var marker = event.getParam("selectedMarkerValue");
        console.log("RecordLIST####" + cmp.get("v.selectedMarkerValue"));
    }
});