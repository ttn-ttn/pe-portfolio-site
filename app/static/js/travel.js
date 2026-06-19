// The following setup code is based in the tutorial at
// https://leafletjs.com/examples/quick-start/
let map = L.map('map').setView([41.505, 0], 1.8);
L.tileLayer(
  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  {
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
  }).addTo(map);

export function markLocations(locations) {
  locations.forEach(loc => {
    L.marker([loc.lat, loc.lon]).bindTooltip(loc.name).addTo(map);
  });
}
