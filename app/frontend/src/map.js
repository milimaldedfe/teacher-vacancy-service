const getSchools = () => {
  if (document.getElementById('map').dataset.schools) {
    return JSON.parse(document.getElementById('map').dataset.schools);
  }
};

// Stops working if I change to const initMap = () => {}
window.initMap = function() {
  const schools = getSchools();

  const bounds = new google.maps.LatLngBounds();

  // Create map with default position and zoom as fitBounds sometimes
  // does nothing
  
  const school1 = schools[0]
  const firstLatLng = { lat: school1.lat, lng: school1.lng }

  const map = new google.maps.Map(document.getElementById('map'), {
    zoom: 16,
    center: firstLatLng
  })

  // Use one infoWindow for all markers.
  // This means that only one infoWindow can be open at a time.
  const infoWindow = new google.maps.InfoWindow;
  
  schools.forEach((school) => {
    const contentString = `<p>${school.name_link}</p>` +
                          `<p>${school.address}</p>` +
                          `<p>${school.school_type}</p>`

    const latLng = { lat: school.lat, lng: school.lng };

    const marker = new google.maps.Marker({
      position: latLng,
      map: map,
      title: school.name
    });

    marker.addListener('click', function() {
      infoWindow.setContent(contentString);
      infoWindow.open(map, marker);
      map.setCenter(latLng);
    });

    bounds.extend(latLng);
  })

  map.fitBounds(bounds);

  // Close the infoWindow on clicking outside the infoWindow.
  google.maps.event.addListener(map, "click", function(event) {
    infoWindow.close();
  });
};