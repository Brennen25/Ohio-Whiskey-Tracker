import React from 'react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';

// Replace with your actual OHLQ locations data
const ohlqLocations = [
    { id: 1, name: 'Location A', lat: 39.7589, lng: -84.1916, release: 'Whiskey A', releaseDate: '2026-04-25 14:00:00' },
    { id: 2, name: 'Location B', lat: 39.9612, lng: -82.9988, release: 'Whiskey B', releaseDate: '2026-05-05 10:00:00' }
];

// Fix Leaflet's default marker icon issue
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
    iconRetinaUrl: 'https://unpkg.com/leaflet@1.7.7/dist/images/marker-icon-2x.png',
    iconUrl: 'https://unpkg.com/leaflet@1.7.7/dist/images/marker-icon.png',
    shadowUrl: 'https://unpkg.com/leaflet@1.7.7/dist/images/marker-shadow.png',
});

const MapComponent = () => {
    return (
        <MapContainer center={[39.9612, -82.9988]} zoom={7} style={{ height: '100vh', width: '100%' }}>
            <TileLayer
                url='https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
                attribution='&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
            />
            {
                ohlqLocations.map(location => (
                    <Marker key={location.id} position={[location.lat, location.lng]}>
                        <Popup>
                            <strong>{location.name}</strong><br />
                            Allocated Whiskey: {location.release}<br />
                            Release Date: {location.releaseDate}
                        </Popup>
                    </Marker>
                ))
            }
        </MapContainer>
    );
};

export default MapComponent;